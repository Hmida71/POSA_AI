// lib/backend/backend_manager_with_callbacks.dart
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart' as path;

typedef MessageCallback = void Function(String message, MessageType type);

enum MessageType {
  loading,
  info,
  success,
  warning,
  error,
}

class BackendManagerWithCallbacks {
  Process? _backendProcess;
  static const int _backendPort = 5000;
  static const String _backendHost = '127.0.0.1';
  String? _lastError;
  MessageCallback? _messageCallback;

  String? get lastError => _lastError;
  bool get isRunning => _backendProcess != null;

  Future<bool> startBackend(MessageCallback messageCallback) async {
    try {
      _messageCallback = messageCallback;
      _lastError = null;
      _sendMessage('Starting backend...', MessageType.loading);

      // Kill existing processes first
      await stopBackend();
      await _killPort5000AndPython();
      await Future.delayed(const Duration(milliseconds: 500));

      // Resolve paths for both Debug and Release layouts
      final executableDir = path.dirname(Platform.resolvedExecutable);
      final backendDir = await _resolveBackendDir(executableDir);
      final appPy = path.join(backendDir, 'app_secure.py');

      // Find Python
      final pythonExe = await _findPython(executableDir);

      _sendMessage(
          'Using Python: ${path.basename(pythonExe)}', MessageType.info);
      _sendMessage(
          'Working directory: ${path.basename(backendDir)}', MessageType.info);

      // Ensure Python dependencies are installed (especially for Debug runs)
      final depsOk = await _ensurePythonDependencies(pythonExe, backendDir);
      if (!depsOk) {
        throw Exception(
            'Python dependencies installation failed. Please check the logs above.');
      }

      // Verify files exist
      if (!await File(appPy).exists()) {
        throw Exception('app_secure.py not found at: $appPy');
      }

      _sendMessage('Starting Python process...', MessageType.info);

      // Start Python process directly
      _backendProcess = await Process.start(
        pythonExe,
        ['app_secure.py'],
        workingDirectory: backendDir,
        environment: {
          'PYTHONPATH': backendDir,
          'FLASK_ENV': 'development',
        },
      );

      // Monitor output
      _monitorProcess();

      _sendMessage('Waiting for server to be ready...', MessageType.info);

      // Wait for server
      final ready = await _waitForServer();

      if (ready) {
        _sendMessage('Backend started successfully!', MessageType.success);
        return true;
      } else {
        throw Exception('Server not responding after 30 seconds');
      }
    } catch (e) {
      _lastError = e.toString();
      _sendMessage('Failed to start backend: $_lastError', MessageType.error);
      await stopBackend();
      return false;
    }
  }

  void _sendMessage(String message, MessageType type) {
    _messageCallback?.call(message, type);
  }

  // Try multiple candidate locations to find the backend directory in both
  // Debug and Release setups.
  Future<String> _resolveBackendDir(String executableDir) async {
    final candidates = <String>[
      // 1) Next to the executable (Release packaging layout)
      path.join(executableDir, 'backend'),
      // 2) Current working directory (sometimes set to runner dir)
      path.join(Directory.current.path, 'backend'),
      // 3) One or two levels up from executable
      path.normalize(path.join(executableDir, '..', 'backend')),
      path.normalize(path.join(executableDir, '..', '..', 'backend')),
      // 4) Typical Flutter Windows Debug layout:
      //    <project>/build/windows/x64/runner/Debug -> go up to <project>
      path.normalize(path.join(executableDir, '..', '..', '..', '..', '..', 'backend')),
      // 5) Built flutter assets location (when assets are bundled there)
      path.normalize(path.join(executableDir, '..', '..', '..', '..', 'flutter_assets', 'backend')),
    ];

    final attempted = <String>[];
    for (final dir in candidates) {
      attempted.add(dir);
      final backendDir = Directory(dir);
      final appSecure = path.join(dir, 'app_secure.py');
      if (await backendDir.exists() && await File(appSecure).exists()) {
        _sendMessage('Resolved backend directory: ${path.normalize(dir)}', MessageType.info);
        return dir;
      }
    }

    throw Exception(
        'Could not locate backend directory. Attempted: ${attempted.map((d) => path.normalize(d)).join(' | ')}');
  }

  Future<String> _findPython(String executableDir) async {
    // Try bundled Python first
    final bundled = path.join(executableDir, 'python', 'python.exe');
    if (await File(bundled).exists()) {
      try {
        final result = await Process.run(bundled, ['--version'])
            .timeout(const Duration(seconds: 3));
        if (result.exitCode == 0) {
          _sendMessage('Found bundled Python', MessageType.info);
          return bundled;
        }
      } catch (e) {
        _sendMessage('Bundled Python failed: $e', MessageType.warning);
      }
    }

    // Try system Python
    final systemPythons = ['python', 'py', 'python3'];
    for (final py in systemPythons) {
      try {
        final result = await Process.run(py, ['--version'])
            .timeout(const Duration(seconds: 3));
        if (result.exitCode == 0) {
          _sendMessage('Using system Python: $py', MessageType.info);
          return py;
        }
      } catch (e) {
        continue;
      }
    }

    throw Exception('No Python found. Install Python or check bundled Python.');
  }

  void _monitorProcess() {
    if (_backendProcess == null) return;

    // Monitor stdout
    _backendProcess!.stdout.transform(utf8.decoder).listen((data) {
      final message = data.trim();
      if (message.isNotEmpty) {
        _sendMessage('Backend: $message', MessageType.info);
      }
    });

    // Monitor stderr
    _backendProcess!.stderr.transform(utf8.decoder).listen((data) {
      final message = data.trim();
      if (message.isNotEmpty) {
        if (data.contains('Address already in use')) {
          _lastError = 'Port 5000 is busy';
          _sendMessage('Port 5000 is already in use', MessageType.error);
        } else if (data.contains('No module named')) {
          final moduleName =
              data.split('No module named')[1].split('\n')[0].trim();
          _lastError = 'Python module missing: $moduleName';
          _sendMessage('Missing Python module: $moduleName', MessageType.error);
        } else {
          _sendMessage('Backend Warning: $message', MessageType.warning);
        }
      }
    });

    // Monitor exit
    _backendProcess!.exitCode.then((code) {
      if (code == 0) {
        _sendMessage('Backend stopped normally', MessageType.info);
      } else {
        _sendMessage('Backend exited with code: $code', MessageType.warning);
      }
      _backendProcess = null;
    });
  }

  Future<bool> _waitForServer() async {
    for (int i = 0; i < 30; i++) {
      try {
        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 2);
        final request = await client.get(_backendHost, _backendPort, '/');
        final response = await request.close();
        client.close();

        if (response.statusCode < 500) {
          _sendMessage('Server is ready and responding!', MessageType.success);
          return true;
        }
      } catch (e) {
        // Server not ready yet
      }

      // Show progress every 5 seconds
      if (i % 5 == 4) {
        _sendMessage(
            'Still waiting for server... (${i + 1}/30)', MessageType.info);
      }

      await Future.delayed(const Duration(seconds: 1));
    }
    return false;
  }

  Future<void> _killPort5000AndPython() async {
    if (!Platform.isWindows) return;

    try {
      // First, kill processes using port 5000
      final netstatResult = await Process.run('netstat', ['-ano']);
      final netstatLines = netstatResult.stdout.toString().split('\n');
      bool killedPort = false;

      for (final line in netstatLines) {
        if (line.contains(':5000 ') && line.contains('LISTENING')) {
          final parts = line.trim().split(RegExp(r'\s+'));
          if (parts.isNotEmpty) {
            final pid = parts.last;
            _sendMessage('Killing process $pid on port 5000', MessageType.info);
            await Process.run('taskkill', ['/F', '/PID', pid]);
            killedPort = true;
          }
        }
      }

      if (!killedPort) {
        _sendMessage('Port 5000 is free', MessageType.info);
      }

      // Then, kill all Python processes
      await _killAllPythonProcesses();
    } catch (e) {
      _sendMessage('Could not clean port/processes: $e', MessageType.warning);
    }
  }

  Future<void> _killAllPythonProcesses() async {
    if (!Platform.isWindows) return;

    try {
      // Get all running processes
      final tasklistResult = await Process.run('tasklist', ['/FO', 'CSV']);
      final lines = tasklistResult.stdout.toString().split('\n');
      bool killedAny = false;

      for (final line in lines) {
        // Skip header and empty lines
        if (line.isEmpty || line.startsWith('"Image Name"')) continue;

        // Parse CSV format: "Image Name","PID","Session Name","Session#","Mem Usage"
        final parts = line.split('","');
        if (parts.length >= 2) {
          final imageName = parts[0].replaceAll('"', '').toLowerCase();
          final pidStr = parts[1].replaceAll('"', '');

          // Check if it's a Python process
          if (imageName == 'python.exe' ||
              imageName == 'pythonw.exe' ||
              imageName == 'py.exe') {
            try {
              final pid = int.parse(pidStr);
              _sendMessage('Killing Python process: $imageName (PID: $pid)',
                  MessageType.info);
              await Process.run('taskkill', ['/F', '/PID', pid.toString()]);
              killedAny = true;
            } catch (e) {
              _sendMessage(
                  'Could not kill process $pidStr: $e', MessageType.warning);
            }
          }
        }
      }

      if (killedAny) {
        _sendMessage('Python processes cleared', MessageType.success);
        // Wait a moment for processes to fully terminate
        await Future.delayed(const Duration(milliseconds: 1000));
      } else {
        _sendMessage('No Python processes found', MessageType.info);
      }
    } catch (e) {
      _sendMessage('Could not check Python processes: $e', MessageType.warning);
    }
  }

  Future<void> stopBackend() async {
    if (_backendProcess != null) {
      _sendMessage('Stopping backend process...', MessageType.info);
      _backendProcess!.kill();
      _backendProcess = null;
    }
    await _killPort5000AndPython();
  }

  // New method to clean everything without starting backend
  Future<void> cleanAllProcesses() async {
    _sendMessage(
        'Cleaning all Python processes and port 5000...', MessageType.loading);
    await _killPort5000AndPython();
    _sendMessage('Cleanup completed', MessageType.success);
  }

  // Ensure required Python packages are installed using requirements.txt
  Future<bool> _ensurePythonDependencies(
      String pythonExe, String backendDir) async {
    try {
      final requirementsPath = path.join(backendDir, 'requirements.txt');
      if (!await File(requirementsPath).exists()) {
        _sendMessage('No requirements.txt found; proceeding without install',
            MessageType.warning);
        return true; // Nothing to install
      }

      _sendMessage('Checking pip...', MessageType.info);
      bool hasPip = false;
      try {
        final pipCheck = await Process.run(
                pythonExe, ['-m', 'pip', '--version'])
            .timeout(const Duration(seconds: 6));
        hasPip = pipCheck.exitCode == 0;
      } catch (_) {
        hasPip = false;
      }

      if (!hasPip) {
        _sendMessage('pip not found; attempting to install ensurepip',
            MessageType.info);
        try {
          final ensure = await Process.run(
              pythonExe, ['-m', 'ensurepip', '--upgrade']);
          if (ensure.exitCode != 0) {
            _sendMessage('Failed to install pip via ensurepip',
                MessageType.warning);
          }
        } catch (e) {
          _sendMessage('ensurepip failed: $e', MessageType.warning);
        }
      }

      _sendMessage('Installing backend Python dependencies (this may take minutes)...',
          MessageType.loading);

      final ok = await _runPipInstallStreaming(
          pythonExe: pythonExe, backendDir: backendDir);
      if (ok) {
        _sendMessage(
            'Dependencies installed/verified successfully', MessageType.success);
        // Ensure Playwright and its browsers are ready
        final pwOk = await _ensurePlaywrightInstalledAndBrowsers(pythonExe);
        if (!pwOk) {
          _sendMessage(
              'Playwright setup failed; backend may not be able to launch browsers',
              MessageType.warning);
        }
        return true;
      }
      return false;
    } catch (e) {
      _sendMessage('Dependency installation failed: $e', MessageType.error);
      return false;
    }
  }

  Future<bool> _runPipInstallStreaming(
      {required String pythonExe, required String backendDir}) async {
    try {
      final proc = await Process.start(
        pythonExe,
        [
          '-m',
          'pip',
          'install',
          '-r',
          'requirements.txt',
          '--no-warn-script-location',
          '--disable-pip-version-check',
          '--progress-bar',
          'off',
        ],
        workingDirectory: backendDir,
      );

      proc.stdout.transform(utf8.decoder).listen((data) {
        final lines = data.split(RegExp(r'\r?\n'));
        for (final line in lines) {
          final msg = line.trim();
          if (msg.isNotEmpty) {
            _sendMessage('pip: $msg', MessageType.info);
          }
        }
      });

      proc.stderr.transform(utf8.decoder).listen((data) {
        final lines = data.split(RegExp(r'\r?\n'));
        for (final line in lines) {
          final msg = line.trim();
          if (msg.isNotEmpty) {
            _sendMessage('pip error: $msg', MessageType.warning);
          }
        }
      });

      final code = await proc.exitCode;
      if (code == 0) {
        return true;
      } else {
        _sendMessage('pip exited with code $code', MessageType.error);
        return false;
      }
    } catch (e) {
      _sendMessage('Failed to run pip: $e', MessageType.error);
      return false;
    }
  }

  Future<bool> _ensurePlaywrightInstalledAndBrowsers(String pythonExe) async {
    try {
      // Check if playwright module is available
      final hasModule = await _isPythonModuleAvailable(pythonExe, 'playwright');
      if (!hasModule) {
        _sendMessage('Installing Playwright Python package...',
            MessageType.loading);
        final pip = await Process.start(
          pythonExe,
          ['-m', 'pip', 'install', 'playwright', '--disable-pip-version-check'],
        );
        pip.stdout.transform(utf8.decoder).listen((d) {
          final msg = d.trim();
          if (msg.isNotEmpty) _sendMessage('pip: $msg', MessageType.info);
        });
        pip.stderr.transform(utf8.decoder).listen((d) {
          final msg = d.trim();
          if (msg.isNotEmpty) _sendMessage('pip error: $msg', MessageType.warning);
        });
        final code = await pip.exitCode;
        if (code != 0) {
          _sendMessage('Failed to install Playwright (exit $code)',
              MessageType.error);
          return false;
        }
      }

      // Install browsers (Chromium is enough for most cases)
      _sendMessage('Downloading Playwright Chromium browser (once-off)...',
          MessageType.loading);
      final installBrowsers = await Process.start(
        pythonExe,
        ['-m', 'playwright', 'install', 'chromium'],
      );
      installBrowsers.stdout.transform(utf8.decoder).listen((d) {
        final msg = d.trim();
        if (msg.isNotEmpty) _sendMessage('playwright: $msg', MessageType.info);
      });
      installBrowsers.stderr.transform(utf8.decoder).listen((d) {
        final msg = d.trim();
        if (msg.isNotEmpty) _sendMessage('playwright error: $msg', MessageType.warning);
      });
      final code = await installBrowsers.exitCode;
      if (code == 0) {
        _sendMessage('Playwright Chromium ready', MessageType.success);
        return true;
      } else {
        _sendMessage('Playwright install exited with code $code',
            MessageType.error);
        return false;
      }
    } catch (e) {
      _sendMessage('Playwright setup failed: $e', MessageType.error);
      return false;
    }
  }

  Future<bool> _isPythonModuleAvailable(String pythonExe, String module) async {
    try {
      final res = await Process.run(
        pythonExe,
        ['-c', 'import importlib,sys; sys.exit(0) if importlib.util.find_spec("$module") else sys.exit(1)'],
      );
      return res.exitCode == 0;
    } catch (_) {
      return false;
    }
  }
}
