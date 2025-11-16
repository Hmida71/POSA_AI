import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:posa_ai_app/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';


enum LaunchType {
  url,
  phoneNumber,
  whatsapp,
  email,
}

class AppUtils {
  static Future<void> log(String message) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/app_log.txt');
      final timestamp = DateTime.now().toIso8601String();
      await file.writeAsString('[$timestamp] $message\n',
          mode: FileMode.append);
    } catch (e) {
      debugPrint('Failed to write to log file: $e');
    }
  }

  static void showSnackbar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  static bool isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    ).hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= AppConstants.minPasswordLength;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String formatPrice(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }

  static Future<void> urlLauncher({
    required String url,
    LaunchType type = LaunchType.url,
    bool isExternal = true,
    bool inAppWebViewWithHeader = false,
    String? subject,
    String? body,
  }) async {
    try {
      if (url.isNotEmpty) {
        if (type == LaunchType.url) {
          final Uri uri = Uri.parse(url);
          final bool launched = await launchUrl(
            uri,
            mode: isExternal
                ? LaunchMode.externalApplication
                : inAppWebViewWithHeader
                    ? LaunchMode.inAppBrowserView
                    : LaunchMode.inAppWebView,
          );
          if (!launched) {
            throw Exception('Could not launch URL: $url');
          }
        } else if (type == LaunchType.phoneNumber) {
          final String telUri = 'tel:$url';
          final Uri uri = Uri.parse(telUri);
          final bool launched = await launchUrl(uri);
          if (!launched) {
            throw Exception('Could not launch phone number: $url');
          }
        } else if (type == LaunchType.whatsapp) {
          final String whatsappUri = 'https://wa.me/$url';
          final Uri uri = Uri.parse(whatsappUri);
          final bool launched = await launchUrl(uri);
          if (!launched) {
            throw Exception('Could not launch WhatsApp number: $url');
          }
        } else if (type == LaunchType.email) {
          final String emailUri =
              'mailto:$url?subject=${Uri.encodeComponent(subject ?? '')}&body=${Uri.encodeComponent(body ?? '')}';

          final Uri uri = Uri.parse(emailUri);
          final bool launched = await launchUrl(uri);
          if (!launched) {
            throw Exception('Could not launch email address: $url');
          }
        }
      }
    } catch (e) {
      throw Exception('Error launching: $e');
    }
  }

  static void copyText(BuildContext context, {required String text}) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.white,
        content: Text(
          'Copied to clipboard!',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  static bool isIOS() {
    return Platform.isIOS;
  }

  static bool isAndroid() {
    return Platform.isAndroid;
  }

  static void hideStatusBar() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  static void hideStatusBarBottom() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );
  }

  static void makeFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ));
  }

  static void showStatusBar() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  static Future<bool> hasInternetConnection() async {
    try {
      final res = await InternetAddress.lookup("example.com");
      return res.isNotEmpty && res[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  static Future<void> setStatusBarColor(Color? color, bool? isDark) async {
    await Future.delayed(Duration.zero).then((_) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: color,
          statusBarIconBrightness: isDark == null
              ? null
              : !isDark
                  ? Brightness.light
                  : Brightness.dark,
        ),
      );
    });
  }

  static Future<void> setSystemNavigationBarColor(
      Color color, bool isDark) async {
    await Future.delayed(Duration.zero).then((value) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          systemNavigationBarColor: color,
          systemNavigationBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
        ),
      );
    });
  }
}
