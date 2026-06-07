import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whistles_in_the_mist/screens/home_screen.dart';
import 'package:whistles_in_the_mist/screens/showcase_screen.dart';
import 'package:whistles_in_the_mist/screens/stats_screen.dart';
import 'package:whistles_in_the_mist/utils/const.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});
  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _currentIndex = 0;
  final _screens = const [HomeScreen(), ShowcaseScreen(), StatsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens),
          Positioned(left: 0, right: 0, bottom: 0, child: _buildNav()),
        ],
      ),
    );
  }

  Widget _buildNav() {
    return Container(
      height: 68.h,
      margin: EdgeInsets.fromLTRB(
        20.w,
        0,
        20.w,
        MediaQuery.of(context).padding.bottom + 16.h,
      ),
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusPill),
        border: Border.all(color: kOutline),
        boxShadow: const [kShadowFloat],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(0, Icons.view_agenda_outlined, Icons.view_agenda, 'Line'),
          _navItem(
            1,
            Icons.account_tree_outlined,
            Icons.account_tree,
            'Route Map',
          ),
          _navItem(2, Icons.analytics_outlined, Icons.analytics, 'Logbook'),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label) {
    final selected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 50.h,
        padding: EdgeInsets.symmetric(horizontal: selected ? 18.w : 14.w),
        decoration: BoxDecoration(
          color: selected ? kAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(kRadiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? activeIcon : icon,
              color: selected ? Colors.white : kSecondaryText,
              size: 21.sp,
            ),
            if (selected) ...[
              SizedBox(width: 8.w),
              Text(
                label,
                style: GoogleFonts.ibmPlexSans(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
