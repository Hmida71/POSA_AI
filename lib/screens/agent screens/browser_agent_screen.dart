import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../utils/app_utils.dart';

class AgentScreen extends StatefulWidget {
  const AgentScreen({super.key});

  @override
  State<AgentScreen> createState() => _AgentScreenState();
}

class _AgentScreenState extends State<AgentScreen>
    with TickerProviderStateMixin {
  late io.Socket socket;
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  final ScrollController _logScrollController = ScrollController();
  late AnimationController _pulseController;
  late AnimationController _statusController;

  List<LogEntry> logs = [];
  String agentStatus = 'ready';
  String selectedModel = 'gemini';
  String selectedModelVersion = 'gemini-2.0-flash';
  bool keepBrowserOpen = true;
  bool obscureApiKey = true;
  String? finalResult;

  final Map<String, List<String>> modelVersions = {
    // GOOGLE GEMINI - Updated with latest
    'gemini': [
      'gemini-2.0-flash', // Default
      'gemini-2.5-pro', // 🆕 NEWEST - May 2025
      'gemini-2.0-flash-exp', // 🆕 EXPERIMENTAL
      'gemini-1.5-pro', // Stable
    ],

    // OPENAI GPT - Updated with latest
    'gpt': [
      'gpt-4.5', // 🆕 NEWEST - May 2025
      'gpt-4.1', // 🆕 Coding focused - April 2025
      'gpt-4o', // Current flagship
      'gpt-4o-mini', // Lightweight
      'gpt-4-turbo', // Previous gen
      'o3-mini', // 🆕 Reasoning model
    ],

    // ANTHROPIC CLAUDE - Updated with latest
    'claude': [
      'claude-4-opus', // 🆕 NEWEST - June 2025
      'claude-4-sonnet', // 🆕 NEWEST - June 2025
      'claude-3.7-sonnet', // 🆕 Latest 3.x - May 2025
      'claude-3-5-sonnet-20241022', // Current
      'claude-3-5-haiku-20241022', // Fast
      'claude-3-opus-20240229', // Previous flagship
    ],

    // DEEPSEEK - Updated with latest
    'deepseek': [
      'deepseek-r1', // 🆕 NEWEST Reasoning - Jan 2025
      'deepseek-v3-0324', // 🆕 Updated general - Mar 2025
      'deepseek-chat', // Current
      'deepseek-coder', // Coding specialist
    ],
  };
  final Map<String, IconData> modelIcons = {
    'gemini': Icons.auto_awesome,
    'gpt': Icons.psychology,
    'claude': Icons.smart_toy,
    'deepseek': Icons.memory,
  };

  final Map<String, Color> modelColors = {
    'gemini': Colors.blue,
    'gpt': Colors.green,
    'claude': Colors.orange,
    'deepseek': Colors.purple,
  };
  Map<String, String> savedApiKeys = {};
  int taskCounts = 0;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _statusController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _connectSocket();
    _loadSavedData();
  }

  // Add these new methods
  Future<void> _loadSavedData() async {
    _prefs = await SharedPreferences.getInstance();

    setState(() {
      // Load saved API keys for each model
      for (String model in modelVersions.keys) {
        savedApiKeys[model] = _prefs?.getString('api_key_$model') ?? '';
      }

      // Load task counts for each model
      taskCounts = _prefs?.getInt('task_count') ?? 0;

      // Set current controllers with saved data
      _apiKeyController.text = savedApiKeys[selectedModel] ?? '';
    });
  }

  Future<void> _saveApiKey(String model, String apiKey) async {
    savedApiKeys[model] = apiKey;
    await _prefs?.setString('api_key_$model', apiKey);
  }

  Future<void> _incrementTaskCount(String model) async {
    taskCounts = taskCounts + 1;
    await _prefs?.setInt('task_count', taskCounts);
  }

  void _connectSocket() {
    socket = io.io('http://localhost:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.on('connect', (_) {
      debugPrint('Connected to server');
    });

    socket.on('agent_status', (data) async {
      if (!mounted) return;

      setState(() {
        agentStatus = data['status'];
        if (data.containsKey('result')) {
          finalResult = data['result'];
        }
      });
      if (data.containsKey('result')) {
        await _incrementTaskCount(selectedModel);
      }
      _statusController.forward();
    });

    socket.on('agent_log', (data) {
      // Check if widget is still mounted before calling setState
      if (!mounted) return;

      setState(() {
        logs.add(LogEntry.fromJson(data));
      });

      _scrollToBottom();
    });

    socket.on('final_result', (data) {
      // Check if widget is still mounted before calling setState
      if (!mounted) return;

      setState(() {
        finalResult = data['result'];
        logs.add(LogEntry(
          timestamp: data['timestamp'],
          level: 'RESULT',
          message: data['formatted_result'],
          module: 'result',
        ));
      });
      _scrollToBottom();
    });

    socket.on('task_completed', (data) {
      // Check if widget is still mounted before calling setState
      if (!mounted) return;

      setState(() {
        finalResult = data['result'];
      });
    });
  }

  void _scrollToBottom() {
    // Check if widget is still mounted and controller has clients
    if (!mounted || !_logScrollController.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _logScrollController.hasClients) {
        _logScrollController.animateTo(
          _logScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startTask() async {
    if (_taskController.text.isEmpty || _apiKeyController.text.isEmpty) {
      _showSnackBar('Please fill in both task and API key', Colors.red);
      return;
    }

    await _ensureBrowserClosed();
    setState(() {
      logs.clear();
      finalResult = null;
    });

    socket.emit('start_task', {
      'task': _taskController.text,
      'model': selectedModel,
      'model_version': selectedModelVersion,
      'api_key': _apiKeyController.text.trim(),
      'keep_browser_open': keepBrowserOpen,
    });
  }

  void _stopTask() {
    socket.emit('stop_task');
  }

  void _closeBrowser() {
    socket.emit('close_browser');

    // Check if widget is still mounted before calling setState
    if (!mounted) return;

    setState(() {
      logs.add(LogEntry(
        timestamp: DateTime.now().toString().substring(11, 19),
        level: 'INFO',
        message: '🔄 Requesting browser closure...',
        module: 'client',
      ));
    });
    _scrollToBottom();
  }

  Future<void> _ensureBrowserClosed() async {
    // Add cleanup log
    if (mounted) {
      setState(() {
        logs.add(LogEntry(
          timestamp: DateTime.now().toString().substring(11, 19),
          level: 'INFO',
          message: '🧹 Ensuring browser is closed before starting new task...',
          module: 'client',
        ));
      });
      _scrollToBottom();
    }

    // Send close browser command (using existing server endpoint)
    socket.emit('close_browser');

    // Wait for browser to close gracefully
    await Future.delayed(const Duration(milliseconds: 2000));

    // Send stop_task to ensure any running task is stopped
    socket.emit('stop_task');

    // Additional wait to ensure everything is cleaned up
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  void _showSnackBar(String message, Color color) {
    // Check if widget is still mounted before showing snackbar
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Color _getLogColor(String level) {
    switch (level.toLowerCase()) {
      case 'error':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'info':
        return Colors.blue;
      case 'result':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    // Disconnect socket and remove all listeners before disposing
    socket.disconnect();
    socket.dispose();

    // Dispose controllers
    _taskController.dispose();
    _apiKeyController.dispose();
    _logScrollController.dispose();
    _pulseController.dispose();
    _statusController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple.withValues(alpha: 0.8),
                Colors.cyan.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'AI Browser Agent',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              Color(0xFF1E1B4B),
              Color(0xFF0F0F23),
              Color(0xFF0A0A0B),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              // ? Left Panel - Agent Configuration
              leftPanel(context),
              const SizedBox(width: 24),
              // ? Right Panel -  Logs and Results
              rightPanel(context),
            ],
          ),
        ),
      ),
    );
  }

  Expanded rightPanel(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          // Final Result Display
          if (finalResult != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.withValues(alpha: 0.1),
                    Colors.green.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.check_circle,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Task Completed Successfully',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SelectableText(
                      finalResult!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Enhanced Logs Panel
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.cyan.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan.withValues(alpha: 0.05),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Logs Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.cyan.withValues(alpha: 0.1),
                          Colors.purple.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.cyan, Colors.purple],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.terminal,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Agent Execution Logs',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                logs.clear();
                              });
                              _showSnackBar(
                                  'Logs cleared successfully', Colors.green);
                            },
                            icon: const Icon(Icons.clear_all,
                                color: Colors.white),
                            tooltip: 'Clear All Logs',
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Logs Content
                  Expanded(
                    child: logs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.memory,
                                  size: 64,
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No logs yet...',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Start a task to see execution logs here',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context).copyWith(
                              dragDevices: {
                                PointerDeviceKind.mouse,
                                PointerDeviceKind.touch,
                              },
                              scrollbars: false,
                            ),
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              controller: _logScrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: logs.length,
                              itemBuilder: (context, index) {
                                final log = logs[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: log.level == 'RESULT'
                                        ? Colors.green.withValues(alpha: 0.1)
                                        : Colors.white.withValues(alpha: 0.03),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: log.level == 'RESULT'
                                          ? Colors.green.withValues(alpha: 0.3)
                                          : Colors.white.withValues(alpha: 0.1),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Timestamp
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          log.timestamp,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.white
                                                .withValues(alpha: 0.7),
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 12),

                                      // Log Level Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getLogColor(log.level),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          log.level,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 12),

                                      // Log Message
                                      Expanded(
                                        child: SelectableText(
                                          log.message,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: log.level == 'RESULT'
                                                ? Colors.white
                                                : Colors.white
                                                    .withValues(alpha: 0.9),
                                            fontFamily: 'monospace',
                                            fontWeight: log.level == 'RESULT'
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SizedBox leftPanel(BuildContext context) {
    return SizedBox(
      width: 420,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.cyan.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.cyan.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.mouse,
                PointerDeviceKind.touch,
              },
              scrollbars: false,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.cyan, Colors.purple],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.settings,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Flexible(
                        child: Text(
                          'Agent Configuration',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Model Selection
                  const Text(
                    'AI Model',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedModel,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1E1B4B),
                        style: const TextStyle(color: Colors.white),
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: Colors.white),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        onChanged: (String? newValue) async {
                          await _saveApiKey(
                              selectedModel, _apiKeyController.text);
                          setState(() {
                            selectedModel = newValue!;
                            selectedModelVersion =
                                modelVersions[selectedModel]!.first;

                            // Load saved data for new model
                            _apiKeyController.text =
                                savedApiKeys[selectedModel] ?? '';
                          });
                        },
                        items: modelVersions.keys
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                Icon(
                                  modelIcons[value],
                                  color: modelColors[value],
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Text(
                                    value.toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Model Version
                  const Text(
                    'Model Version',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedModelVersion,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1E1B4B),
                        style: const TextStyle(color: Colors.white),
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: Colors.white),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedModelVersion = newValue!;
                          });
                        },
                        items: modelVersions[selectedModel]!
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // API Key
                  const Text(
                    'API Key',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: TextField(
                      controller: _apiKeyController,
                      style: const TextStyle(color: Colors.white),
                      onChanged: (value) {
                        _saveApiKey(selectedModel, value);
                      },
                      decoration: InputDecoration(
                        hintText:
                            'Enter your ${selectedModel.toUpperCase()} API key',
                        hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5)),
                        prefixIcon: const Icon(Icons.key, color: Colors.cyan),
                        suffixIcon: IconButton(
                          splashRadius: 20,
                          onPressed: () {
                            setState(() {
                              obscureApiKey = !obscureApiKey;
                            });
                          },
                          icon: Icon(
                            obscureApiKey ? Ionicons.eye : Ionicons.eye_off,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      obscureText: obscureApiKey,
                      maxLines: 1,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Get Free API Key Button (only visible for Gemini)
                  if (selectedModel == 'gemini') ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.indigo],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          const url = 'https://aistudio.google.com/app/apikey';
                          AppUtils.urlLauncher(url: url, isExternal: true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(
                          Ionicons.gift_outline,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text(
                          'Get Free API Key',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Task Input
                  const Text(
                    'Task Description',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 180, // Fixed height instead of Expanded
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: TextField(
                      controller: _taskController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText:
                            'Describe what you want the AI agent to do...',
                        hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Keep Browser Open Toggle
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          keepBrowserOpen ? Icons.web : Icons.web_asset_off,
                          color: keepBrowserOpen ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Keep Browser Open',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Browser stays open after task completion',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: keepBrowserOpen,
                          onChanged: (bool value) {
                            setState(() {
                              keepBrowserOpen = value;
                            });
                          },
                          activeThumbColor: Colors.cyan,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Control Buttons
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Responsive button layout
                      bool isNarrow = constraints.maxWidth < 350;

                      if (isNarrow) {
                        // Stack buttons vertically on narrow screens
                        return Column(
                          children: [
                            // Start Task Button
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: agentStatus == 'running'
                                      ? [Colors.grey, Colors.grey.shade700]
                                      : [Colors.green, Colors.green.shade700],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ElevatedButton.icon(
                                onPressed: agentStatus == 'running'
                                    ? null
                                    : _startTask,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.play_arrow,
                                    color: Colors.white),
                                label: const Text(
                                  'Start Task',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Stop Button
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: agentStatus == 'running'
                                      ? [Colors.red, Colors.red.shade700]
                                      : [Colors.grey, Colors.grey.shade700],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ElevatedButton.icon(
                                onPressed:
                                    agentStatus == 'running' ? _stopTask : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon:
                                    const Icon(Icons.stop, color: Colors.white),
                                label: const Text(
                                  'Stop Task',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        // Side-by-side layout for wider screens
                        return Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: agentStatus == 'running'
                                        ? [Colors.grey, Colors.grey.shade700]
                                        : [Colors.green, Colors.green.shade700],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: agentStatus == 'running'
                                      ? null
                                      : _startTask,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.play_arrow,
                                      color: Colors.white),
                                  label: const Text(
                                    'Start Task',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: agentStatus == 'running'
                                      ? [Colors.red, Colors.red.shade700]
                                      : [Colors.grey, Colors.grey.shade700],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ElevatedButton.icon(
                                onPressed:
                                    agentStatus == 'running' ? _stopTask : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.all(16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon:
                                    const Icon(Icons.stop, color: Colors.white),
                                label: const Text(''),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  // Close Browser Button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange, Colors.orange.shade700],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _closeBrowser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.close, color: Colors.white),
                      label: const Text(
                        'Close Browser',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Status Indicator
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: agentStatus == 'running'
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: agentStatus == 'running'
                            ? Colors.green.withValues(alpha: 0.3)
                            : Colors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: agentStatus == 'running'
                                    ? Colors.green.withValues(
                                        alpha:
                                            0.8 + 0.2 * _pulseController.value)
                                    : Colors.grey.withValues(alpha: 0.8),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                agentStatus == 'running'
                                    ? Icons.play_circle
                                    : Icons.pause_circle,
                                color: Colors.white,
                                size: 16,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Agent Status',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                agentStatus.toUpperCase(),
                                style: TextStyle(
                                  color: agentStatus == 'running'
                                      ? Colors.green
                                      : Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Extra padding at bottom for scroll comfort
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LogEntry {
  final String timestamp;
  final String level;
  final String message;
  final String module;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    required this.module,
  });

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    final message = json['message'] ?? '';
    final level = json['level'] ?? 'INFO';

    // Skip this specific warning
    if (level.toLowerCase() == 'warning' &&
        message.contains(
            'Agent(enable_memory=True) is set but missing some required packages')) {
      debugPrint("CATCHING Agent(enable_memory=True) is missing !");
      return LogEntry(
        timestamp: json['timestamp'] ?? '',
        level: level,
        message:
            "Agent memory is missing. Please wait for a future POSA AI version to fix this issue.",
        module: json['module'] ?? '',
      );
    }

    // Replace browser-use with posa-ai in messages and remove version numbers
    if (message.contains('browser-use')) {
      debugPrint("CATCHING Browser-use name !!");
      String modifiedMessage = message.replaceAll('browser-use', 'posa-ai');
      // Remove version patterns like v0.2.2, v1.0.0, etc.
      modifiedMessage =
          modifiedMessage.replaceAll(RegExp(r'\s+v\d+\.\d+\.\d+'), '');

      return LogEntry(
        timestamp: json['timestamp'] ?? '',
        level: level,
        message: modifiedMessage,
        module: json['module'] ?? '',
      );
    }

    return LogEntry(
      timestamp: json['timestamp'] ?? '',
      level: level,
      message: message,
      module: json['module'] ?? '',
    );
  }
}
