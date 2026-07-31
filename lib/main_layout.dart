import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'profile_screen.dart';

enum _BottomMenuTab {
  home,
  example,
  barcode,
  camera;

  const _BottomMenuTab();
}

class MainLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFE0E0E0), height: 1.0),
        ),
        title: const Row(
          children: [
            FlutterLogo(size: 30),
            SizedBox(width: 8),
            Text(
              'Route Aware Sandbox',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.pushNamed(ProfileScreen.name);
            },
            icon: const Icon(Icons.person, color: Colors.black),
          ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  tab: _BottomMenuTab.home,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                ),
                _buildNavItem(
                  tab: _BottomMenuTab.example,
                  icon: Icons.animation_outlined,
                  activeIcon: Icons.animation,
                ),
                _buildNavItem(
                  tab: _BottomMenuTab.barcode,
                  icon: Icons.barcode_reader,
                  activeIcon: Icons.barcode_reader,
                ),
                _buildNavItem(
                  tab: _BottomMenuTab.camera,
                  icon: Icons.camera_alt_outlined,
                  activeIcon: Icons.camera_alt,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required _BottomMenuTab tab,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isSelected = navigationShell.currentIndex == tab.index;
    const primaryColor = Colors.blue;
    const secondaryColor = Colors.grey;
    return GestureDetector(
      onTap: () {
        final currentIndex = navigationShell.currentIndex;
        navigationShell.goBranch(
          tab.index,
          initialLocation: tab.index == currentIndex,
        );
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? primaryColor : secondaryColor,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              tab.name.toUpperCase(),
              style: TextStyle(
                color: isSelected ? primaryColor : secondaryColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
