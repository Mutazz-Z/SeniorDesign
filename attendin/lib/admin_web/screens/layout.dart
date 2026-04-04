import 'package:attendin/admin_web/screens/class_screens/classes_screen.dart';
import 'package:attendin/admin_web/screens/profile_screen.dart';
import 'package:attendin/admin_web/widgets/sidebar_navigation_widget.dart';
import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/admin_web/screens/dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:attendin/common/data/user_data_provider.dart';
import 'package:attendin/common/widgets/profile_picture_widget.dart';
import 'package:attendin/common/models/class_info.dart';

import 'package:flutter/material.dart';

class LayoutScreen extends StatefulWidget {
  const LayoutScreen({super.key});

  @override
  State<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _transitionDuration = Duration(milliseconds: 300);
  static const Curve _transitionCurve = Curves.easeInOut;

  int _selectedIndex = 0;
  ClassesView _classesView = ClassesView.list;
  dynamic _selectedClassItem;
  Color? _colorOverride;

  static const double _breakpointWidth = 950.0;

  final List<String> _navigationItems = [
    'Dashboard',
    'Classes',
    'Profile',
  ];

  final List<IconData> _navigationIcons = [
    Icons.dashboard,
    Icons.people,
    Icons.person,
  ];

  late List<Color> _sectionBackgroundColors;
  bool _didInitSectionColors = false;

  late final AnimationController _transitionController;
  Animation<Color?>? _navColorAnimation;
  Animation<Color?>? _textColorAnimation;
  Color? _lastResolvedNavColor;
  Color? _lastResolvedTextColor;

  void _handleClassSelected(dynamic classItem) {
    setState(() {
      _selectedClassItem = classItem;
      _classesView = ClassesView.details;
      _colorOverride = null;
    });
    _animateThemeColors();
  }

  void _handleNavigateToSettings() {
    final colors = AppColors.of(context);
    setState(() {
      _classesView = ClassesView.settings;
      _colorOverride = colors.accentYellow;
    });
    _animateThemeColors();
  }

  void _handleClassesBack() {
    setState(() {
      if (_classesView == ClassesView.settings) {
        // Need to update on back? only updates on main view
        _classesView = ClassesView.details;
        _colorOverride = null;
      } else {
        _classesView = ClassesView.list;
        _selectedClassItem = null;
        _colorOverride = null;
      }
    });
    _animateThemeColors();
  }

  void _handleClassesSave(ClassInfo updatedClass) {
    setState(() {
      _selectedClassItem = updatedClass;
      _classesView = ClassesView.details;
      _colorOverride = null;
    });
    _animateThemeColors();
  }

  void _handleNavigateToAddClass() {
    setState(() {
      _classesView = ClassesView.add;
      _colorOverride = null;
    });
    _animateThemeColors();
  }

  @override
  void initState() {
    super.initState();
    _transitionController =
        AnimationController(vsync: this, duration: _transitionDuration)
          ..addListener(() {
            if (mounted) setState(() {});
          });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final AppColorScheme colors = AppColors.of(context);
    _sectionBackgroundColors = [
      colors.primaryBlue,
      colors.accentTeal,
      colors.errorRed,
    ];

    final targets = _resolveTargetColors(colors);
    if (!_didInitSectionColors) {
      _didInitSectionColors = true;
      _lastResolvedNavColor = targets.navColor;
      _lastResolvedTextColor = targets.textColor;
      _navColorAnimation = AlwaysStoppedAnimation(targets.navColor);
      _textColorAnimation = AlwaysStoppedAnimation(targets.textColor);
      return;
    }

    _animateThemeColors();
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index != 1) {
        _colorOverride = null;
        _classesView = ClassesView.list;
        _selectedClassItem = null;
      }
    });
    _animateThemeColors();
  }

  ({Color navColor, Color textColor}) _resolveTargetColors(
      AppColorScheme colors) {
    final Color navColor =
        _colorOverride ?? _sectionBackgroundColors[_selectedIndex];
    final Color textColor =
        _colorOverride != null ? Colors.black : colors.whiteColor;
    return (navColor: navColor, textColor: textColor);
  }

  void _animateThemeColors() {
    if (!_didInitSectionColors || !mounted) return;

    final targets = _resolveTargetColors(AppColors.of(context));
    final Color currentNav =
        _navColorAnimation?.value ?? _lastResolvedNavColor ?? targets.navColor;
    final Color currentText = _textColorAnimation?.value ??
        _lastResolvedTextColor ??
        targets.textColor;

    if (currentNav == targets.navColor && currentText == targets.textColor) {
      return;
    }

    _lastResolvedNavColor = targets.navColor;
    _lastResolvedTextColor = targets.textColor;

    final Animation<double> curved = CurvedAnimation(
      parent: _transitionController,
      curve: _transitionCurve,
    );

    _navColorAnimation = ColorTween(
      begin: currentNav,
      end: targets.navColor,
    ).animate(curved);

    _textColorAnimation = ColorTween(
      begin: currentText,
      end: targets.textColor,
    ).animate(curved);

    _transitionController
      ..stop()
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < _breakpointWidth;

    assert(_didInitSectionColors,
        '_sectionBackgroundColors must be initialized before build.');

    final fallbackTargets = _resolveTargetColors(colors);
    final Color currentTextColor =
        _textColorAnimation?.value ?? fallbackTargets.textColor;
    final Color currentNavColor =
        _navColorAnimation?.value ?? fallbackTargets.navColor;

    final List<Widget> pages = [
      DashboardScreen(isSmallScreen: isSmallScreen),
      ClassesScreen(
          currentView: _classesView,
          selectedItem: _selectedClassItem,
          onClassSelected: _handleClassSelected,
          onNavigateToSettings: _handleNavigateToSettings,
          onBack: _handleClassesBack,
          onSave: _handleClassesSave,
          onAddClass: _handleNavigateToAddClass),
      const ProfileScreen(),
    ];

    if (isSmallScreen) {
      // Small screen layout
      return Scaffold(
        backgroundColor: currentNavColor,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: Container(
            decoration: BoxDecoration(
              color: currentNavColor,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: IndexedStack(
              index: _selectedIndex,
              children: pages,
            ),
          ),
        ),
        bottomNavigationBar: Consumer<UserDataProvider>(
          builder: (context, adminProvider, _) {
            return BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              backgroundColor: currentNavColor,
              selectedItemColor: currentTextColor,
              unselectedItemColor: currentTextColor.withValues(alpha: 0.7),
              type: BottomNavigationBarType.fixed,
              items: _navigationItems.asMap().entries.map((entry) {
                int index = entry.key;
                String item = entry.value;
                if (item == 'Profile') {
                  return BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: ProfilePictureWidget(
                        alignment: CrossAxisAlignment.center,
                        profileShape: ProfileShape.circle,
                        size: 24,
                        imageUrl: adminProvider.profilePicture,
                        name: adminProvider.userName,
                        showName: false,
                        showEditBadge: false,
                        color: _selectedIndex == index
                            ? currentTextColor
                            : currentTextColor.withValues(alpha: 0.7),
                      ),
                    ),
                    label: item,
                  );
                } else {
                  return BottomNavigationBarItem(
                    icon: Icon(_navigationIcons[index]),
                    label: item,
                  );
                }
              }).toList(),
            );
          },
        ),
      );
    } else {
      // Large screen layout
      return Scaffold(
        body: Row(
          children: [
            Sidebar(
              selectedIndex: _selectedIndex,
              navigationItems: _navigationItems,
              onItemSelected: _onItemTapped,
              sidebarBackgroundColor: currentNavColor,
              selectedTextColor: currentTextColor,
              unselectedTextColor: currentTextColor.withValues(alpha: 0.7),
              fixedWidth: 250.0,
            ),
            Expanded(
              flex: 4,
              child: Container(
                color: currentNavColor,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 550.0),
                    child: Container(
                      margin: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: currentNavColor,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: IndexedStack(
                        index: _selectedIndex,
                        children: pages,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
