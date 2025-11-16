import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bottom_navigation_provider.dart';
// import '../providers/auth_provider.dart';
// import '../providers/locale_provider.dart';
// import '../providers/theme_provider.dart';
// import '../utils/constants.dart';
// import '../widgets/custom_navigation_bar.dart';
import 'agent screens/brand_intro_screnn.dart';
import 'profile_screen.dart';

class IndexScreen extends StatelessWidget {
  const IndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider =
        Provider.of<BottomNavigationBarProvider>(context);
    final currentIndex = navigationProvider.currentIndex;

    // void signOut() async {
    //   await Provider.of<AuthProvider>(context, listen: false).signOut();
    // }

    final List<Widget> screens = [
      const BrandIntroScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(navigationProvider.currentRoute),
      //   backgroundColor: AppColors.colorApp,
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.brightness_6),
      //       onPressed: () => context.read<ThemeProvider>().toggleTheme(),
      //       tooltip: 'Toggle Theme',
      //     ),
      //     IconButton(
      //       icon: const Icon(Icons.language),
      //       onPressed: () {
      //         Locale currentLocale = Localizations.localeOf(context);
      //         Locale newLocale = currentLocale.languageCode == 'en'
      //             ? const Locale('ar', 'DZ')
      //             : const Locale('en', 'US');
      //         context.read<LocaleProvider>().setLocale(newLocale);
      //       },
      //       tooltip: 'Switch Language',
      //     ),
      //     IconButton(
      //       icon: const Icon(Icons.logout),
      //       onPressed: signOut,
      //       tooltip: 'Sign Out',
      //     ),
      //   ],
      // ),
      body: screens[currentIndex],
      // bottomNavigationBar: const CustomNavigationBar(),
    );
  }
}
