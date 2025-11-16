import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bottom_navigation_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';

class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider =
        Provider.of<BottomNavigationBarProvider>(context);
    final currentIndex = navigationProvider.currentIndex;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkTheme = themeProvider.isDarkMode;
        return NavigationBar(
          selectedIndex: currentIndex,
          backgroundColor: isDarkTheme
              ? AppColors.darkBackground
              : AppColors.lightBackground,
          height: 65,
          indicatorColor: AppColors.colorApp,
          onDestinationSelected: (index) {
            navigationProvider.setIndex(index);
            if (index == 0) {
              navigationProvider.setRouting('Home');
            } else if (index == 1) {
              navigationProvider.setRouting('Profile');
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        );
      },
    );
  }
}
