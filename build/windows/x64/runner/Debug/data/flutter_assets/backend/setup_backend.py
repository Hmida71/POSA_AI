import subprocess
import sys
import os
import json
import zipfile
import urllib.request
import shutil
from pathlib import Path

class BackendSetup:
    def __init__(self, app_dir=None):
        self.app_dir = Path(app_dir) if app_dir else Path.cwd()
        self.python_dir = self.app_dir / "python_runtime"
        self.backend_dir = self.app_dir / "backend"
        self.venv_dir = self.python_dir / "venv"
        self.python_exe = self.venv_dir / "Scripts" / "python.exe" if os.name == 'nt' else self.venv_dir / "bin" / "python"
        self.pip_exe = self.venv_dir / "Scripts" / "pip.exe" if os.name == 'nt' else self.venv_dir / "bin" / "pip"
        
    def log(self, message):
        """Log setup progress"""
        print(f"[POSA Setup] {message}")
        
    def download_python_embedded(self):
        """Download and extract embedded Python"""
        if self.python_dir.exists():
            self.log("Python runtime already exists")
            return True
            
        try:
            self.log("Downloading Python embedded runtime...")
            python_url = "https://www.python.org/ftp/python/3.11.8/python-3.11.8-embed-amd64.zip"
            python_zip = self.app_dir / "python-embed.zip"
            
            urllib.request.urlretrieve(python_url, python_zip)
            
            self.log("Extracting Python runtime...")
            with zipfile.ZipFile(python_zip, 'r') as zip_ref:
                zip_ref.extractall(self.python_dir)
            
            python_zip.unlink()  # Remove zip file
            
            # Enable site-packages by editing pth file
            pth_file = self.python_dir / "python311._pth"
            if pth_file.exists():
                content = pth_file.read_text()
                if "#import site" in content:
                    content = content.replace("#import site", "import site")
                    pth_file.write_text(content)
            
            self.log("Python runtime setup completed")
            return True
            
        except Exception as e:
            self.log(f"Error setting up Python runtime: {e}")
            return False
    
    def setup_virtual_environment(self):
        """Create virtual environment"""
        if self.venv_dir.exists():
            self.log("Virtual environment already exists")
            return True
            
        try:
            self.log("Creating virtual environment...")
            python_exe = self.python_dir / "python.exe"
            
            # First, install pip in embedded Python
            self.install_pip_in_embedded()
            
            # Create virtual environment
            subprocess.run([
                str(python_exe), "-m", "venv", str(self.venv_dir)
            ], check=True, capture_output=True)
            
            self.log("Virtual environment created successfully")
            return True
            
        except Exception as e:
            self.log(f"Error creating virtual environment: {e}")
            return False
    
    def install_pip_in_embedded(self):
        """Install pip in embedded Python"""
        try:
            self.log("Installing pip in embedded Python...")
            python_exe = self.python_dir / "python.exe"
            
            # Download get-pip.py
            get_pip_url = "https://bootstrap.pypa.io/get-pip.py"
            get_pip_path = self.python_dir / "get-pip.py"
            urllib.request.urlretrieve(get_pip_url, get_pip_path)
            
            # Install pip
            subprocess.run([str(python_exe), str(get_pip_path)], 
                         check=True, capture_output=True)
            
            get_pip_path.unlink()  # Remove get-pip.py
            
        except Exception as e:
            self.log(f"Error installing pip: {e}")
    
    def install_requirements(self):
        """Install Python requirements"""
        try:
            self.log("Installing Python requirements...")
            
            requirements = [
                "flask==2.3.3",
                "flask-socketio==5.3.6",
                "python-socketio==5.9.0",
                "python-engineio==4.7.1",
                "langchain-google-genai==1.0.8",
                "langchain-openai==0.1.17",
                "langchain-anthropic==0.1.20",
                "browser-use==0.1.15",
                "python-dotenv==1.0.0",
                "psutil==5.9.8",
                "asyncio",
                "aiohttp==3.9.1"
            ]
            
            for req in requirements:
                self.log(f"Installing {req}...")
                result = subprocess.run([
                    str(self.pip_exe), "install", req, "--no-warn-script-location"
                ], capture_output=True, text=True)
                
                if result.returncode != 0:
                    self.log(f"Warning: Failed to install {req}: {result.stderr}")
            
            self.log("Requirements installation completed")
            return True
            
        except Exception as e:
            self.log(f"Error installing requirements: {e}")
            return False
    
    def copy_backend_files(self):
        """Copy backend files to app directory"""
        try:
            if not self.backend_dir.exists():
                self.backend_dir.mkdir(parents=True)
            
            # Copy your app.py and templates
            source_files = [
                "app.py",
                "templates",
                "static"  # if you have static files
            ]
            
            for file_name in source_files:
                source_path = Path(file_name)
                if source_path.exists():
                    dest_path = self.backend_dir / file_name
                    if source_path.is_dir():
                        if dest_path.exists():
                            shutil.rmtree(dest_path)
                        shutil.copytree(source_path, dest_path)
                    else:
                        shutil.copy2(source_path, dest_path)
            
            self.log("Backend files copied successfully")
            return True
            
        except Exception as e:
            self.log(f"Error copying backend files: {e}")
            return False
    
    def create_launcher_script(self):
        """Create launcher script for Flask app"""
        try:
            launcher_content = f'''import sys
import os
import subprocess
from pathlib import Path

# Add backend directory to Python path
backend_dir = Path(__file__).parent / "backend"
sys.path.insert(0, str(backend_dir))

# Set environment variables
os.environ["PYTHONPATH"] = str(backend_dir)

# Change to backend directory
os.chdir(backend_dir)

# Import and run the Flask app
try:
    from app import app, socketio, setup_logging
    setup_logging()
    print("Starting POSA Backend Server...")
    socketio.run(app, debug=False, host='127.0.0.1', port=5000, 
                allow_unsafe_werkzeug=True)
except Exception as e:
    print(f"Error starting backend: {{e}}")
    input("Press Enter to exit...")
'''
            
            launcher_path = self.app_dir / "launch_backend.py"
            launcher_path.write_text(launcher_content)
            
            # Create batch file for Windows
            if os.name == 'nt':
                batch_content = f'''@echo off
cd /d "{self.app_dir}"
"{self.python_exe}" launch_backend.py
pause
'''
                batch_path = self.app_dir / "launch_backend.bat"
                batch_path.write_text(batch_content)
            
            self.log("Launcher scripts created successfully")
            return True
            
        except Exception as e:
            self.log(f"Error creating launcher script: {e}")
            return False
    
    def setup_all(self):
        """Run complete setup process"""
        self.log("Starting POSA backend setup...")
        
        steps = [
            ("Downloading Python Runtime", self.download_python_embedded),
            ("Setting up Virtual Environment", self.setup_virtual_environment),
            ("Installing Requirements", self.install_requirements),
            ("Copying Backend Files", self.copy_backend_files),
            ("Creating Launcher Scripts", self.create_launcher_script)
        ]
        
        for step_name, step_func in steps:
            self.log(f"Step: {step_name}")
            if not step_func():
                self.log(f"Setup failed at step: {step_name}")
                return False
        
        self.log("POSA backend setup completed successfully!")
        return True

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description='Setup POSA Backend')
    parser.add_argument('--app-dir', help='Application directory path')
    args = parser.parse_args()
    
    setup = BackendSetup(args.app_dir)
    success = setup.setup_all()
    
    if not success:
        sys.exit(1)