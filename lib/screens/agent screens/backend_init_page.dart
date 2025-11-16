import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../../providers/backend_manage.dart';
import '../auth_wrapper.dart';

class BackendInitPage extends StatefulWidget {
  const BackendInitPage({super.key});

  @override
  State<BackendInitPage> createState() => _BackendInitPageState();
}

class _BackendInitPageState extends State<BackendInitPage>
    with TickerProviderStateMixin {
  final BackendManagerWithCallbacks _backendManager =
      BackendManagerWithCallbacks();

  final List<LogMessage> _logs = [];
  bool _isInitializing = true;
  bool _hasError = false;
  String? _errorMessage;

  late AnimationController _pulseController;
  late AnimationController _glitchController;
  late AnimationController _logoController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glitchAnimation;
  late Animation<double> _logoAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startBackendInitialization();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glitchController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _logoController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _glitchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _glitchController, curve: Curves.elasticOut));

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack));

    _logoController.forward();
  }

  Future<void> _startBackendInitialization() async {
    try {
      setState(() {
        _isInitializing = true;
        _hasError = false;
        _errorMessage = null;
        _logs.clear();
      });

      final success = await _backendManager.startBackend(_onMessage);

      if (success) {
        // Wait a moment to show success message
        await Future.delayed(const Duration(seconds: 1));

        // Navigate to AuthWrapper
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const AuthWrapper(), // Replace with your AuthWrapper
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        }
      } else {
        setState(() {
          _isInitializing = false;
          _hasError = true;
          _errorMessage = _backendManager.lastError ?? 'Unknown error occurred';
        });
      }
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _onMessage(String message, MessageType type) {
    if (mounted) {
      setState(() {
        _logs.add(LogMessage(
          message: message,
          type: type,
          timestamp: DateTime.now(),
        ));
      });

      if (_logs.length > 50) {
        _logs.removeAt(0);
      }

      // Trigger glitch effect on errors
      if (type == MessageType.error) {
        _glitchController.forward().then((_) => _glitchController.reset());
      }
    }
  }

  Future<void> _retryInitialization() async {
    await _startBackendInitialization();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glitchController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Color(0xFF1A0A2E),
              Color(0xFF0D0D0D),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildLogo(),
                ),
                Expanded(
                  flex: 3,
                  child: _buildStatusSection(),
                ),
                if (_hasError) ...[
                  const SizedBox(height: 24),
                  _buildRetryButton(),
                ],
                const SizedBox(height: 32),
                Expanded(
                  flex: 2,
                  child: _buildLogTerminal(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoAnimation, _glitchAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_glitchAnimation.value * 3, 0),
          child: Transform.scale(
            scale: _logoAnimation.value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF00FFFF), Color(0xFFFF0080)],
                  ).createShader(bounds),
                  child: const Text(
                    'INITIALIZING BACKEND POSA AI',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_isInitializing) _buildLoadingIndicator(),
        if (kDebugMode) ...[
          if (_hasError) _buildErrorIndicator(),
        ],
        if (!_isInitializing && !_hasError) _buildSuccessIndicator(),
        const SizedBox(height: 24),
        _buildStatusText(),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Color.lerp(
                const Color(0xFF00FFFF).withValues(alpha: 0.3),
                const Color(0xFF00FFFF),
                _pulseAnimation.value,
              )!,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FFFF)
                    .withValues(alpha: 0.3 * _pulseAnimation.value),
                blurRadius: 20 * _pulseAnimation.value,
                spreadRadius: 5 * _pulseAnimation.value,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(
                    Color.lerp(
                      const Color(0xFF00FFFF).withValues(alpha: 0.5),
                      const Color(0xFF00FFFF),
                      _pulseAnimation.value,
                    ),
                  ),
                ),
              ),
              const Icon(
                Icons.sync,
                color: Color(0xFF00FFFF),
                size: 24,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorIndicator() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFFF0080), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF0080).withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.error_outline,
        color: Color(0xFFFF0080),
        size: 32,
      ),
    );
  }

  Widget _buildSuccessIndicator() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF00FF41), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FF41).withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.check,
        color: Color(0xFF00FF41),
        size: 32,
      ),
    );
  }

  Widget _buildStatusText() {
    String statusText;
    Color statusColor;

    if (_isInitializing) {
      statusText = 'ESTABLISHING NEURAL PATHWAYS...';
      statusColor = const Color(0xFF00FFFF);
    } else if (_hasError) {
      statusText = 'SYSTEM ERROR DETECTED';
      statusColor = const Color(0xFFFF0080);
    } else {
      statusText = 'MATRIX ONLINE • TRANSITIONING...';
      statusColor = const Color(0xFF00FF41);
    }

    return Column(
      children: [
        Text(
          statusText,
          style: TextStyle(
            color: statusColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          SelectableText(
            _errorMessage!,
            style: const TextStyle(
              color: Color(0xFF888888),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (_isInitializing && _logs.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            _logs.last.message,
            style: const TextStyle(
              color: Color(0xFFFFAA00),
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildRetryButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _retryInitialization,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          decoration: BoxDecoration(
            color: const Color(0xFF00FFFF).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF00FFFF), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FFFF).withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.refresh,
                color: Color(0xFF00FFFF),
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'RETRY INITIALIZATION',
                style: TextStyle(
                  color: Color(0xFF00FFFF),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogTerminal() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF333333), width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF0080),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFAA00),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00FF41),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'SYSTEM LOG',
                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _logs.isEmpty
                ? const Center(
                    child: Text(
                      'Awaiting system initialization...',
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      return _buildLogEntry(log);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogEntry(LogMessage log) {
    Color getTypeColor(MessageType type) {
      switch (type) {
        case MessageType.loading:
          return const Color(0xFFFFAA00);
        case MessageType.info:
          return const Color(0xFF00FFFF);
        case MessageType.success:
          return const Color(0xFF00FF41);
        case MessageType.warning:
          return const Color(0xFFFFAA00);
        case MessageType.error:
          return const Color(0xFFFF0080);
      }
    }

    final color = getTypeColor(log.type);
    debugPrint(log.message.toString());
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            '[${log.timestamp.toString().substring(11, 19)}]',
            style: const TextStyle(
              color: Color(0xFF555555),
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              log.message,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LogMessage {
  final String message;
  final MessageType type;
  final DateTime timestamp;

  LogMessage({
    required this.message,
    required this.type,
    required this.timestamp,
  });
}
