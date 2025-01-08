import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lumiers/pages/profile.dart';
import 'package:lumiers/pages/recherchepage.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  static const List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: HugeIcons.strokeRoundedBook02,
      label: 'Chanson ecrite',
      screen: Center(child: Text('Chanson ecrite')),
    ),
    NavigationItem(
      icon: HugeIcons.strokeRoundedSearch01,
      label: 'Recherche',
      screen: SearchPage(),
    ),
    NavigationItem(
      icon: HugeIcons.strokeRoundedMusicNoteSquare02,
      label: 'Chanson audio',
      screen: Center(child: Text('Chanson audio')),
    ),
    NavigationItem(
      icon: HugeIcons.strokeRoundedUser,
      label: 'Profil',
      screen: Profile(),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: PageView.builder(
          itemCount: _navigationItems.length,
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (_, index) => _navigationItems[index].screen,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: _navigationItems
              .map((item) => BottomNavigationBarItem(
                    icon: HugeIcon(
                      icon: item.icon,
                      color: Colors.black,
                      size: 24.0,
                    ),
                    label: item.label,
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final Widget screen;

  const NavigationItem({
    required this.icon,
    required this.label,
    required this.screen,
  });
}
