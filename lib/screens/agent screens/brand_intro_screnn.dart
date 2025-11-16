import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_utils.dart';
import 'browser_agent_screen.dart';

class BrandIntroScreen extends StatefulWidget {
  const BrandIntroScreen({super.key});

  @override
  State<BrandIntroScreen> createState() => _BrandIntroScreenState();

  static Widget _buildFeatureBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.cyan.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyan.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.cyan,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Widget _buildTechBadge(String text, String url) {
    return InkWell(
      onTap: () async {
        await AppUtils.urlLauncher(url: url, isExternal: true);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.purple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Colors.purple,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.open_in_new,
              color: Colors.purple,
              size: 10,
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandIntroScreenState extends State<BrandIntroScreen> {
  int taskCounts = 0;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _initUser(context);
    debugPrint('BackendInitPage initialized');
    getTaskCountFromShared();
  }

  Future<void> getTaskCountFromShared() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      taskCounts = _prefs?.getInt('task_count') ?? 0;
    });
  }

  void _initUser(BuildContext context) async {
    bool status = await AuthProvider().loadUserData();
    if (!status && context.mounted) {
      _showCyberpunkSecurityAlert(context);
    }
  }

  void _showCyberpunkSecurityAlert(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.red.shade900.withValues(alpha: 0.95),
                    Colors.black.withValues(alpha: 0.98),
                    Colors.purple.shade900.withValues(alpha: 0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.8),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Skull icon with glowing effect
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.8),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.warning,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title with cyber font styling
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.red, Colors.orange, Colors.red],
                    ).createShader(bounds),
                    child: const Text(
                      '⚠️ SECURITY BREACH DETECTED ⚠️',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Message
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '🔒 UNAUTHORIZED ACCESS ATTEMPT 🔒',
                          style: TextStyle(
                            color: Colors.red.shade300,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '🚨 System integrity compromised!\n'
                          '💀 Potential security vulnerability detected\n'
                          '⚡ Application termination required\n\n'
                          '🌐 Please download the latest version from\n'
                          '🏢 Official POSA AI Website',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Glowing OK button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.6),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await AuthProvider().signOut();
                        } catch (e) {
                          debugPrint("signOut in cyber alert erorr : $e");
                        }
                        exit(0);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: Colors.red.shade400,
                            width: 2,
                          ),
                        ),
                      ),
                      child: const Text(
                        '⚡ TERMINATE & EXIT ⚡',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              Color(0xFF1E1B4B),
              Color(0xFF0F0F23),
              Color(0xFF0A0A0B),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles/grid effect
            ...List.generate(
                20,
                (index) => Positioned(
                      left: (index * 100.0) % MediaQuery.of(context).size.width,
                      top: (index * 80.0) % MediaQuery.of(context).size.height,
                      child: Container(
                        width: 2,
                        height: 2,
                        decoration: BoxDecoration(
                          color: Colors.cyan.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    )),

            SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05),

                      // Animated logo container
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.cyan.withValues(alpha: 0.3),
                              Colors.purple.withValues(alpha: 0.3),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyan.withValues(alpha: 0.3),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Main title with glow effect
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.cyan, Colors.purple, Colors.pink],
                        ).createShader(bounds),
                        child: const Text(
                          'AI Browser Agent',
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Most Powerful Browser Agent Ever Built',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white60,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          BrandIntroScreen._buildFeatureBadge('4 AI Models'),
                          const SizedBox(width: 12),
                          BrandIntroScreen._buildFeatureBadge(
                              '95% Success Rate'),
                          const SizedBox(width: 12),
                          BrandIntroScreen._buildFeatureBadge('24/7 Available'),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                              color: Colors.cyan.withValues(alpha: 0.3)),
                        ),
                        child: const Text(
                          '🤖 Powered by GPT-4, Claude 3 & Google Gemini',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // CTA Button with premium styling
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          gradient: const LinearGradient(
                            colors: [Colors.cyan, Colors.purple],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyan.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 48, vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => const AgentScreen(),
                                // This gives you the default iOS slide transition
                              ),
                            );
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.rocket_launch,
                                  color: Colors.white, size: 24),
                              SizedBox(width: 12),
                              Text(
                                'Launch Agent',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      const Spacer(),
                      // Developer Credits
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Built with ❤️ by TM71',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Algerian App Development Studio',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                BrandIntroScreen._buildTechBadge(
                                  'TM 71 COMPANY',
                                  'https://tm71.netlify.app/',
                                ),
                                const SizedBox(width: 8),
                                BrandIntroScreen._buildTechBadge(
                                  'POSA AI',
                                  'https://posa-agent.free.nf/',
                                ),
                                const SizedBox(width: 8),
                                BrandIntroScreen._buildTechBadge(
                                  'LGX V8',
                                  'https://lgxv8.free.nf/?i=1',
                                ),
                                const SizedBox(width: 8),
                                BrandIntroScreen._buildTechBadge(
                                  'LGX VISION PRO',
                                  'https://lgxvisionpro.netlify.app/',
                                ),
                                const SizedBox(width: 8),
                                BrandIntroScreen._buildTechBadge(
                                  'ELGUIDE APP',
                                  'https://elguide.infinityfreeapp.com/?i=1',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // User Profile Section (Top Right)
            Positioned(
              top: 40,
              right: 40,
              child: UserProfileWidget(taskCounts: taskCounts),
            ),
          ],
        ),
      ),
    );
  }
}

class UserProfileWidget extends StatefulWidget {
  final int taskCounts;
  const UserProfileWidget({
    super.key,
    required this.taskCounts,
  });

  @override
  State<UserProfileWidget> createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends State<UserProfileWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;

        if (user == null) {
          return const SizedBox.shrink();
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: isExpanded ? 320 : 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.cyan.withValues(alpha: 0.3),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile Header
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.cyan.withValues(alpha: 0.7),
                          Colors.purple.withValues(alpha: 0.7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withValues(alpha: 0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getUserDisplayName(user.email ?? 'User'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    icon: AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(
                        Icons.expand_more,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              // Expanded Details
              if (isExpanded) ...[
                const SizedBox(height: 16),
                const Divider(color: Colors.white12),
                const SizedBox(height: 16),

                // User Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    buildStatItem('Sessions', '${getSessionCount()}'),
                    buildStatItem('Status', 'Free'),
                    buildStatItem('Tasks', '${getTaskCount()}'),
                  ],
                ),

                const SizedBox(height: 16),

                // User Info
                buildInfoRow(Icons.email, user.email ?? 'No email'),
                const SizedBox(height: 8),
                buildInfoRow(
                  Icons.access_time,
                  getLastSignIn(
                    DateTime.parse(user.lastSignInAt ?? "${DateTime.now()}"),
                  ),
                ),
                const SizedBox(height: 8),
                buildInfoRow(Icons.shield, user.role ?? 'User'),

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    // Expanded(
                    //   child: _buildActionButton(
                    //     icon: Icons.settings,
                    //     label: 'Settings',
                    //     onPressed: () => _navigateToProfile(context),
                    //   ),
                    // ),
                    // const SizedBox(width: 8),
                    Expanded(
                      child: buildActionButton(
                        icon: Icons.logout,
                        label: 'Sign Out',
                        onPressed: () =>
                            showSignOutDialog(context, authProvider),
                        isDestructive: true,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.cyan,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.cyan,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: isDestructive
            ? LinearGradient(
                colors: [
                  Colors.red.withValues(alpha: 0.3),
                  Colors.red.withValues(alpha: 0.1),
                ],
              )
            : LinearGradient(
                colors: [
                  Colors.cyan.withValues(alpha: 0.3),
                  Colors.purple.withValues(alpha: 0.3),
                ],
              ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isDestructive ? Colors.red : Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isDestructive ? Colors.red : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getUserDisplayName(String email) {
    if (email.isEmpty) return 'User';
    final parts = email.split('@');
    if (parts.isNotEmpty) {
      final name = parts[0];
      return name.length > 10 ? '${name.substring(0, 10)}...' : name;
    }
    return 'User';
  }

  int getSessionCount() {
    // You can implement this based on your backend data
    return 1;
  }

  int getTaskCount() {
    return widget.taskCounts;
  }

  String getLastSignIn(DateTime? lastSignIn) {
    if (lastSignIn == null) return 'Never';
    final now = DateTime.now();
    final difference = now.difference(lastSignIn);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // void _navigateToProfile(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => const ProfileScreen(),
  //     ),
  //   );
  // }

  void showSignOutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Text(
            'Sign Out',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to sign out?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white60),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                authProvider.signOut();
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
