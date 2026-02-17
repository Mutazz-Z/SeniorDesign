import 'package:flutter/material.dart';

import 'package:attendin/student_app/screens/home_screen.dart';
import 'package:attendin/student_app/screens/profile_screens/profile_screen.dart';
import 'package:attendin/student_app/screens/schedule_screens/schedule_screen.dart';
import 'package:attendin/common/utils/app_router.dart';
import 'package:attendin/common/theme/app_colors.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onTabTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabTapped,
  });

  @override
  CustomBottomNavBarState createState() => CustomBottomNavBarState();
}

class CustomBottomNavBarState extends State<CustomBottomNavBar>
    with SingleTickerProviderStateMixin<CustomBottomNavBar> {
  late AnimationController _controller;
  late Animation<double> _animation;

  static const double _baseIconSize = 28.0;
  static const double _selectedIconSizeIncrease = 20.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween<double>(
      begin: _baseIconSize,
      end: _baseIconSize + _selectedIconSizeIncrease,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    if (widget.selectedIndex != -1) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      if (widget.selectedIndex != -1) {
        _controller.forward(from: 0.0);
      } else {
        _controller.reverse(from: 1.0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(BuildContext context, int index) {
    if (index == widget.selectedIndex) {
      return;
    }

    widget.onTabTapped(index);

    if (index == 0) {
      Navigator.push(
        context,
        customFadePageRoute(const ProfileScreen()),
      );
    } else if (index == 1) {
      Navigator.pushAndRemoveUntil(
        context,
        customFadePageRoute(const HomeScreen()),
        (Route<dynamic> route) => false,
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        customFadePageRoute(const ScheduleScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);

    const double borderRadius = 50.0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Material(
          color: colors.primaryBlue,
          borderRadius: BorderRadius.circular(borderRadius),
          elevation: 5,
          child: Container(
            height: kBottomNavigationBarHeight,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildNavItem(
                  context,
                  icon: Icons.person_outline,
                  index: 0,
                  colors: colors,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.home_outlined,
                  index: 1,
                  colors: colors,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.calendar_month_outlined,
                  index: 2,
                  colors: colors,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required int index,
    required AppColorScheme colors,
  }) {
    final bool isSelected = index == widget.selectedIndex;
    final Color itemColor =
        isSelected ? colors.accentYellow : colors.whiteColor;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: () => _handleTap(context, index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: SizedBox(
          height: kBottomNavigationBarHeight,
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final double currentIconSize =
                    isSelected ? _animation.value : _baseIconSize;
                return Icon(
                  icon,
                  color: itemColor,
                  size: currentIconSize,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
