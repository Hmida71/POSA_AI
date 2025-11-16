from flask import Flask, render_template, request, jsonify, send_from_directory
from flask_socketio import SocketIO, emit
import asyncio
import os
import sys
import json
import threading
from datetime import datetime
import logging
import re
import atexit
import asyncio

# Fix encoding issues for Windows - ADD THIS AT THE TOP
import io
if sys.platform.startswith('win'):
    # Set UTF-8 encoding for stdout and stderr on Windows
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')
    
    # Set console encoding to UTF-8
    try:
        import locale
        locale.setlocale(locale.LC_ALL, 'en_US.UTF-8')
    except:
        pass
    
    # Set environment variable for UTF-8
    os.environ['PYTHONIOENCODING'] = 'utf-8'

# Add the parent directory to sys.path if needed
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from dotenv import load_dotenv
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_openai import ChatOpenAI
from langchain_anthropic import ChatAnthropic
from browser_use import Agent, BrowserSession, BrowserProfile

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your-secret-key-here'
socketio = SocketIO(app, cors_allowed_origins="*", async_mode='threading')

# Custom handler to capture logs and send to frontend
class SocketIOHandler(logging.Handler):
    def __init__(self, socketio):
        super().__init__()
        self.socketio = socketio
        
    def emit(self, record):
        # Filter out unwanted log messages
        try:
            message = self.format(record)
        except UnicodeEncodeError:
            # Fallback for encoding issues - replace problematic characters
            message = str(record.getMessage()).encode('utf-8', errors='replace').decode('utf-8')
        
        # Skip action logs that contain JSON data
        if self.should_skip_message(message):
            return
            
        # Clean up the message for better user experience
        cleaned_message = self.clean_message(message)
        
        log_entry = {
            'timestamp': datetime.now().strftime('%H:%M:%S'),
            'level': record.levelname,
            'message': cleaned_message,
            'module': record.name
        }
        self.socketio.emit('agent_log', log_entry)
    
    def should_skip_message(self, message):
        """Determine if a log message should be filtered out"""
        skip_patterns = [
            r'🛠️\s*Action \d+/\d+:',  # Action logs with JSON
            r'Action \d+/\d+:.*\{.*\}',  # Any action logs with JSON
            r'\{"done":\{"text":',  # Done action JSON
            r'\{"search_google":',  # Search action JSON
            r'\{"click":',  # Click action JSON
            r'\{"type":',  # Type action JSON
            r'\{"navigate":',  # Navigate action JSON
            r'\{"scroll":',  # Scroll action JSON
            r'\{"extract":',  # Extract action JSON
        ]
        
        for pattern in skip_patterns:
            if re.search(pattern, message, re.IGNORECASE):
                return True
        return False
    
    def clean_message(self, message):
        """Clean up log messages for better user presentation"""
        # Remove excessive emojis or technical prefixes
        cleanups = [
            (r'^\[agent\]\s*', ''),  # Remove [agent] prefix
            (r'^\[controller\]\s*', ''),  # Remove [controller] prefix
            (r'^\[browser_use\]\s*', ''),  # Remove [browser_use] prefix
        ]
        
        cleaned = message
        for pattern, replacement in cleanups:
            cleaned = re.sub(pattern, replacement, cleaned)
        
        return cleaned.strip()

# Setup logging with UTF-8 support
def setup_logging():
    # Get the browser_use logger
    browser_logger = logging.getLogger('browser_use')
    browser_logger.setLevel(logging.INFO)
    
    # Get the agent logger
    agent_logger = logging.getLogger('agent')
    agent_logger.setLevel(logging.INFO)
    
    # Get the controller logger
    controller_logger = logging.getLogger('controller')
    controller_logger.setLevel(logging.INFO)
    
    # Add our custom handler
    socket_handler = SocketIOHandler(socketio)
    # Use UTF-8 friendly formatter
    formatter = logging.Formatter('%(message)s')
    socket_handler.setFormatter(formatter)
    
    browser_logger.addHandler(socket_handler)
    agent_logger.addHandler(socket_handler)
    controller_logger.addHandler(socket_handler)

def safe_emit_log(level, message, module='agent'):
    """Safely emit logs with proper encoding handling"""
    try:
        # Ensure message is properly encoded
        if isinstance(message, bytes):
            message = message.decode('utf-8', errors='replace')
        elif not isinstance(message, str):
            message = str(message)
        
        socketio.emit('agent_log', {
            'timestamp': datetime.now().strftime('%H:%M:%S'),
            'level': level,
            'message': message,
            'module': module
        })
    except Exception as e:
        # Fallback: emit without emojis if there's still an issue
        fallback_message = message.encode('ascii', errors='ignore').decode('ascii')
        socketio.emit('agent_log', {
            'timestamp': datetime.now().strftime('%H:%M:%S'),
            'level': level,
            'message': f"{fallback_message} [encoding issue resolved]",
            'module': module
        })

def get_llm(model_type, model_version, api_key):
    """Initialize the appropriate LLM based on model selection"""
    try:
        if model_type == 'gemini':
            # Set environment variable for Google API
            os.environ["GOOGLE_API_KEY"] = api_key
            return ChatGoogleGenerativeAI(
                model=model_version,
                temperature=0.0,
                google_api_key=api_key
            )
        
        elif model_type == 'gpt':
            # Set environment variable for OpenAI
            os.environ["OPENAI_API_KEY"] = api_key
            return ChatOpenAI(
                model=model_version,
                temperature=0.0,
                openai_api_key=api_key
            )
        
        elif model_type == 'claude':
            # Set environment variable for Anthropic
            os.environ["ANTHROPIC_API_KEY"] = api_key
            return ChatAnthropic(
                model=model_version,
                temperature=0.0,
                anthropic_api_key=api_key
            )
        
        elif model_type == 'deepseek':
            # DeepSeek uses OpenAI-compatible API
            return ChatOpenAI(
                model=model_version,
                temperature=0.0,
                openai_api_key=api_key,
                base_url="https://api.deepseek.com/v1"
            )
        
        else:
            raise ValueError(f"Unsupported model type: {model_type}")
            
    except Exception as e:
        safe_emit_log('ERROR', f'Failed to initialize {model_type.upper()} model: {str(e)}', 'llm')
        raise

def extract_clean_result(raw_result):
    """
    Extract clean, user-friendly result from the agent's raw output and handle quotes properly
    """
    try:
        # Handle AgentHistoryList object (browser-use specific)
        if hasattr(raw_result, 'all_model_outputs') and hasattr(raw_result, 'all_results'):
            # Look through all_model_outputs for the 'done' action
            for output in reversed(raw_result.all_model_outputs):  # Start from the last output
                if isinstance(output, dict) and 'done' in output:
                    done_data = output['done']
                    if isinstance(done_data, dict) and 'text' in done_data:
                        return done_data['text'].strip()
            
            # Fallback: Look through all_results for the last successful result
            for result in reversed(raw_result.all_results):
                if hasattr(result, 'is_done') and result.is_done and hasattr(result, 'extracted_content'):
                    content = result.extracted_content
                    if content and not content.startswith('🔍 Searched for'):
                        return content.strip()
        
        # Handle direct string result
        if isinstance(raw_result, str):
            return raw_result.strip()
        
        # Handle list of results
        if isinstance(raw_result, list) and raw_result:
            last_item = raw_result[-1]
            if hasattr(last_item, 'extracted_content'):
                return str(last_item.extracted_content).strip()
            return str(last_item).strip()
        
        # Try to parse string representation for 'done' text with improved regex
        result_str = str(raw_result)
        
        # Look for the 'done' pattern in string representation with more flexible patterns
        done_patterns = [
            # Handle single quotes with escaped content
            r"'done':\s*\{\s*'text':\s*'([^']*(?:\\'[^']*)*)'",
            # Handle double quotes with escaped content
            r'"done":\s*\{\s*"text":\s*"([^"]*(?:\\"[^"]*)*)"',
            # Handle mixed quotes
            r"'done':\s*\{\s*'text':\s*\"([^\"]+)\"",
            r'"done":\s*\{\s*"text":\s*\'([^\']+)\'',
            # More flexible patterns that capture everything until the closing brace
            r"'done':\s*\{\s*'text':\s*'([^']+(?:'[^'}]*)*)",
            r'"done":\s*\{\s*"text":\s*"([^"]+(?:"[^"}]*)*)',
            # Last resort: capture everything between text and success
            r"'text':\s*['\"]([^'\"]*(?:['\"][^'\"]*)*)['\"](?:\s*,\s*'success'|$)",
        ]
        
        for pattern in done_patterns:
            matches = re.findall(pattern, result_str, re.IGNORECASE | re.DOTALL)
            if matches:
                # Return the last (most recent) match and clean it up
                result = matches[-1]
                # Unescape quotes and clean up
                result = result.replace("\\'", "'").replace('\\"', '"').strip()
                if result and len(result) > 10:  # Make sure we got a meaningful result
                    return result
        
        # Alternative approach: try to extract from the 'done' section more directly
        done_match = re.search(r"'done':\s*\{([^}]+)\}", result_str, re.DOTALL)
        if done_match:
            done_content = done_match.group(1)
            text_match = re.search(r"'text':\s*['\"]([^'\"]+)['\"]", done_content, re.DOTALL)
            if text_match:
                return text_match.group(1).replace("\\'", "'").replace('\\"', '"').strip()
        
        # Look for extracted_content from done results
        extracted_patterns = [
            r"is_done=True[^,]*extracted_content=['\"]([^'\"]+)['\"]",
            r"extracted_content=['\"]([^'\"]*(?:\$|worth|billion|million)[^'\"]*)['\"]",
        ]
        
        for pattern in extracted_patterns:
            matches = re.findall(pattern, result_str, re.IGNORECASE | re.DOTALL)
            if matches:
                # Filter out search messages
                for match in reversed(matches):
                    if not match.startswith('🔍 Searched for'):
                        return match.replace("\\'", "'").replace('\\"', '"').strip()
        
        # Final fallback: try to find any meaningful text result
        # Look for common result patterns
        fallback_patterns = [
            r"net worth[^.]*\$[0-9.,]+[^.]*billion[^.]*\.",
            r"worth[^.]*\$[0-9.,]+[^.]*billion[^.]*\.",
            r"estimated[^.]*\$[0-9.,]+[^.]*billion[^.]*\.",
        ]
        
        for pattern in fallback_patterns:
            matches = re.findall(pattern, result_str, re.IGNORECASE | re.DOTALL)
            if matches:
                return matches[-1].strip()
        
        # Fallback: return generic success message
        return "Task completed successfully"
        
    except Exception as e:
        print(f"Error extracting result: {e}")
        return "Task completed"

class BrowserAgent:
    def __init__(self):
        self.agent = None
        self.is_running = False
        self.browser_session = None  # Store browser session reference
        
    async def run_task(self, task, model_config, keep_browser_open=True):
        try:
            self.is_running = True
            socketio.emit('agent_status', {'status': 'running', 'task': task})
            
            # Log model initialization with safe emoji handling
            safe_emit_log('INFO', f'🧠 Initializing {model_config["model"].upper()} {model_config["model_version"]}', 'llm')
            
            # Initialize the selected LLM
            llm = get_llm(
                model_config['model'], 
                model_config['model_version'], 
                model_config['api_key']
            )
            
            safe_emit_log('INFO', f'✅ {model_config["model"].upper()} model loaded successfully', 'llm')
            
            # Initialize the browser-use Agent with custom browser options
            # Create browser profile with window size
            browser_profile = BrowserProfile(
                window_size={"width": 1400, "height": 800}
            )
            
            # Set keep_alive based on user preference
            self.browser_session = BrowserSession(
                keep_alive=keep_browser_open,
                browser_profile=browser_profile
            )
            
            # Initialize the browser-use Agent
            self.agent = Agent(task=task, llm=llm, browser_session=self.browser_session,enable_memory=False)
            
            safe_emit_log('INFO', f'🌐 Browser session initialized (keep_alive: {keep_browser_open})', 'browser')
            
            # Run the agent
            raw_result = await self.agent.run()
            
            # Debug: Print the raw result to understand its structure
            try:
                print(f"Raw result type: {type(raw_result)}")
                print(f"Raw result: {raw_result}")
            except UnicodeEncodeError:
                print("Raw result contains unicode characters - logged safely")
            
            # Extract clean result
            clean_result = extract_clean_result(raw_result)
            
            # Try to get the last action result
            if clean_result == "Task completed successfully" or clean_result == "Task completed":
                try:
                    # Try to get the last action result
                    if hasattr(self.agent, 'history') and self.agent.history:
                        last_action = self.agent.history[-1]
                        if hasattr(last_action, 'extracted_content') and last_action.extracted_content:
                            clean_result = last_action.extracted_content.replace("'", "'").strip()
                        elif hasattr(last_action, 'result') and last_action.result:
                            clean_result = str(last_action.result).replace("'", "'").strip()
                except Exception as e:
                    print(f"Error getting result from history: {e}")
            
            # Log the final result for debugging
            safe_emit_log('INFO', f'📊 Final result: {clean_result}', 'agent')

            # Also emit a special result log that can be styled differently in the frontend
            socketio.emit('final_result', {
                'timestamp': datetime.now().strftime('%H:%M:%S'),
                'result': clean_result,
                'formatted_result': f'📄 Result: {clean_result}'
            })
            
            # If keep_browser_open is False, close the browser after task completion
            if not keep_browser_open:
                await self.close_browser()
                safe_emit_log('INFO', '🔒 Browser closed automatically (keep_browser_open: False)', 'browser')
            
            socketio.emit('agent_status', {'status': 'completed', 'result': clean_result})
            socketio.emit('task_completed', {'result': clean_result})
            
        except Exception as e:
            error_msg = f"Error: {str(e)}"
            socketio.emit('agent_status', {'status': 'error', 'error': error_msg})
            safe_emit_log('ERROR', error_msg, 'agent')
        finally:
            self.is_running = False
    

    async def close_browser(self):
            """Manually close the browser when needed"""
            try:
                browser_closed = False
                
                safe_emit_log('INFO', '🔄 Attempting to close browser...', 'browser')
                
                # Method 1: Force close browser processes (formerly Method 3)
                try:
                    import psutil
                    processes_killed = 0
                    
                    safe_emit_log('INFO', '🔧 Attempting force close of browser processes...', 'browser')
                    
                    # Look for browser processes
                    for proc in psutil.process_iter(['pid', 'name', 'cmdline']):
                        try:
                            proc_info = proc.info
                            if not proc_info['name']:
                                continue
                                
                            proc_name = proc_info['name'].lower()
                            
                            # Check if it's a browser process
                            if any(browser in proc_name for browser in ['chrome', 'chromium', 'msedge', 'firefox']):
                                cmdline = proc_info.get('cmdline', [])
                                if cmdline:
                                    cmdline_str = ' '.join(cmdline)
                                    
                                    # Look for browser-use specific indicators
                                    if any(indicator in cmdline_str for indicator in [
                                        '--remote-debugging-port',
                                        'browseruse',
                                        '--user-data-dir',
                                        '--disable-blink-features=AutomationControlled'
                                    ]):
                                        safe_emit_log('INFO', f'🎯 Found browser process: {proc_name} (PID: {proc.pid})', 'browser')
                                        
                                        proc.terminate()
                                        try:
                                            proc.wait(timeout=5)
                                        except psutil.TimeoutExpired:
                                            proc.kill()
                                            proc.wait()
                                        
                                        processes_killed += 1
                                        
                        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.TimeoutExpired):
                            continue
                        except Exception as e:
                            continue
                    
                    if processes_killed > 0:
                        browser_closed = True
                        safe_emit_log('INFO', f'✅ Force closed {processes_killed} browser process(es)', 'browser')
                    else:
                        safe_emit_log('WARNING', '⚠️ No browser processes found to close', 'browser')
                        
                except ImportError:
                    safe_emit_log('ERROR', '❌ psutil not available. Install with: pip install psutil', 'browser')
                except Exception as e:
                    safe_emit_log('ERROR', f'❌ Force close failed: {str(e)}', 'browser')
                
                # Clean up references
                if browser_closed:
                    self.browser_session = None
                    if self.agent:
                        self.agent.browser_session = None
                        
                return browser_closed
                        
            except Exception as e:
                safe_emit_log('ERROR', f'❌ Error in close_browser: {str(e)}', 'browser')
                return False

# Global agent instance
browser_agent = BrowserAgent()

# Add these routes to your app.py file (put them after the existing imports and before the socketio handlers)

@app.route('/')
def index():
    """Main route"""
    return jsonify({
        "service": "POSA Backend", 
        "status": "running",
        "message": "Browser Use Agent Web UI Backend is running",
        "port": 5000,
        "socketio_available": True
    })

@app.route('/status')
def status():
    """Status endpoint"""
    return jsonify({
        "status": "healthy",
        "agent_running": browser_agent.is_running if browser_agent else False,
        "timestamp": datetime.now().isoformat(),
        "service": "POSA Backend"
    })

# Update your existing health check route to be more reliable
@app.route('/health')
def health_check():
    """Health check endpoint - this is what Flutter calls to verify the backend is running"""
    try:
        return jsonify({
            "status": "healthy", 
            "service": "POSA Backend",
            "port": 5000,
            "timestamp": datetime.now().isoformat(),
            "agent_available": browser_agent is not None,
            "socketio_running": True
        }), 200
    except Exception as e:
        return jsonify({
            "status": "error",
            "error": str(e),
            "timestamp": datetime.now().isoformat()
        }), 500

@socketio.on('connect')
def handle_connect():
    print('Client connected')
    emit('agent_status', {'status': 'ready'})

@socketio.on('disconnect')
def handle_disconnect():
    print('Client disconnected')


@socketio.on('start_task')
def handle_start_task(data):
    task = data.get('task', '')
    keep_open = data.get('keep_browser_open', True)  # Get the keep_browser_open setting
    
    # Extract model configuration
    model_config = {
        'model': data.get('model', 'gemini'),
        'model_version': data.get('model_version', 'gemini-2.0-flash'),
        'api_key': data.get('api_key', '')
    }
    
    if not task:
        safe_emit_log('ERROR', 'No task provided', 'server')
        return
    
    if not model_config['api_key']:
        safe_emit_log('ERROR', 'API key is required', 'server')
        return
    
    if browser_agent.is_running:
        safe_emit_log('WARNING', 'Agent is already running a task', 'server')
        return
    
    # Log the keep_browser_open setting
    safe_emit_log('INFO', f'🔧 Keep browser open after task: {keep_open}', 'server')
    
    # Run the task in a separate thread
    def run_async_task():
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        loop.run_until_complete(browser_agent.run_task(task, model_config, keep_open))
        loop.close()
    
    thread = threading.Thread(target=run_async_task)
    thread.daemon = True
    thread.start()

@socketio.on('stop_task')
def handle_stop_task():
    if browser_agent.agent and browser_agent.is_running:
        # Note: browser_use doesn't have a direct stop method, 
        # but we can set the flag to prevent new actions
        browser_agent.is_running = False
        emit('agent_status', {'status': 'stopped'})
        safe_emit_log('INFO', 'Task stopped by user', 'server')

@atexit.register
def cleanup_on_exit():
    """Clean up resources when app exits"""
    try:
        loop = asyncio.get_event_loop()
        if not loop.is_closed():
            # Cancel all pending tasks
            pending = asyncio.all_tasks(loop)
            for task in pending:
                task.cancel()
            # Wait for tasks to complete cancellation
            if pending:
                loop.run_until_complete(asyncio.gather(*pending, return_exceptions=True))
    except:
        pass

@socketio.on('close_browser')
def handle_close_browser():
    """Manually close the browser"""
    def close_async():
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        loop.run_until_complete(browser_agent.close_browser())
        loop.close()
    
    thread = threading.Thread(target=close_async)
    thread.daemon = True
    thread.start()

if __name__ == '__main__':
    setup_logging()
    try:
        print("Starting Browser Use Agent Web UI... 🚀")
        print("Open http://localhost:5000 in your browser 🌐")
    except UnicodeEncodeError:
        print("Starting Browser Use Agent Web UI...")
        print("Open http://localhost:5000 in your browser")
    
    socketio.run(app, debug=False, host='0.0.0.0', port=5000, allow_unsafe_werkzeug=True)