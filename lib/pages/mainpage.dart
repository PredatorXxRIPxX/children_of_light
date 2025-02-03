import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lumiers/pages/lyrics.dart';
import 'package:lumiers/pages/musics.dart';
import 'package:lumiers/pages/profile.dart';

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
      screen: Lyrics(),
    ),
    NavigationItem(
      icon: HugeIcons.strokeRoundedMusicNoteSquare02,
      label: 'Chanson audio',
      screen: Musics(),
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
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              enableFeedback: true,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Colors.grey,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              items: _navigationItems
                  .map((item) => BottomNavigationBarItem(
                        activeIcon: Container(
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: HugeIcon(
                            icon: item.icon,
                            color: Theme.of(context).primaryColor,
                            size: 24.0,
                          ),
                        ),
                        icon: Padding(
                          padding: const EdgeInsets.all(8),
                          child: HugeIcon(
                            icon: item.icon,
                            color: Colors.grey,
                            size: 24.0,
                          ),
                        ),
                        label: item.label,
                      ))
                  .toList(),
            ),
          )),
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
