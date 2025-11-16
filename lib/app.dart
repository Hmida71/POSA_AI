import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:posa_ai_app/providers/auth_provider.dart';
import 'package:posa_ai_app/providers/theme_provider.dart';
import 'package:posa_ai_app/utils/theme_utils.dart';
import 'providers/locale_provider.dart';
import 'providers/product_provider.dart';
import 'providers/bottom_navigation_provider.dart';
import 'screens/agent screens/backend_init_page.dart';
// import 'screens/auth_wrapper.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    LocalJsonLocalization.delegate.directories = ['lib/i18n'];
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => BottomNavigationBarProvider()),
      ],
      child: Consumer2<LocaleProvider, ThemeProvider>(
          builder: (context, localeProvider, themeProvider, child) {
        return MaterialApp(
          title: 'Template App',
          theme: ThemeUtils.lightTheme,
          darkTheme: ThemeUtils.darkTheme,
          themeMode:
              themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          debugShowCheckedModeBanner: false,
          locale: localeProvider.locale,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            LocalJsonLocalization.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('ar', 'DZ'),
          ],
          home: const BackendInitPage(),
          // ? if debug run this line
          // home: const AuthWrapper(),
        );
      }),
    );
  }
}
