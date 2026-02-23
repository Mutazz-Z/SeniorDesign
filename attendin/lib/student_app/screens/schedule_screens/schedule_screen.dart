import 'package:attendin/common/widgets/class_info_card.dart';
import 'package:attendin/student_app/screens/schedule_screens/class_details_screen.dart';
import 'package:attendin/common/utils/app_router.dart';
import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/widgets/custom_refresh_indicator.dart';
import 'package:attendin/common/theme/app_text_styles.dart';
import 'package:attendin/student_app/widgets/custom_bottom_nav_bar.dart';
import 'package:attendin/common/models/class_info.dart';
import 'package:provider/provider.dart';
import 'package:attendin/common/data/user_data_provider.dart';
import 'package:attendin/common/data/enrollment_data_provider.dart';
import 'package:attendin/common/data/class_data_provider.dart';
import 'package:attendin/common/theme/theme_provider.dart';

import 'package:flutter/material.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _selectedIndex = 2;

  void _handleBottomNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleRefresh() async {
    final userProvider = Provider.of<UserDataProvider>(context, listen: false);
    final enrollmentProvider =
        Provider.of<EnrollmentProvider>(context, listen: false);
    final classProvider =
        Provider.of<ClassDataProvider>(context, listen: false);

    // Refresh everything
    await userProvider.fetchUserData();
    await enrollmentProvider.fetchClassIdsForStudent(userProvider.uid);
    await classProvider.fetchClassesByIds(enrollmentProvider.studentClassIds);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final enrollmentProvider = Provider.of<EnrollmentProvider>(context);
    final classProvider = Provider.of<ClassDataProvider>(context);
    final AppColorScheme colors = AppColors.of(context);

    final double topPadding = MediaQuery.of(context).padding.top;

    if (enrollmentProvider.loading || classProvider.loading) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      final bool isDarkMode;
      if (themeProvider.themeMode == ThemeMode.system) {
        isDarkMode =
            MediaQuery.of(context).platformBrightness == Brightness.dark;
      } else {
        isDarkMode = themeProvider.themeMode == ThemeMode.dark;
      }
      final String logoPath = isDarkMode
          ? 'assets/WelcomeLogo_Dark.png'
          : 'assets/WelcomeLogo_Light.png';

      return Scaffold(
        backgroundColor: colors.secondaryBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.asset(logoPath, fit: BoxFit.contain),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    final List<ClassInfo> scheduledClasses = classProvider.classes
        .where((cls) => enrollmentProvider.studentClassIds.contains(cls.id))
        .toList();

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colors.secondaryBackground,
        body: CustomRefreshIndicator(
          onRefresh: _handleRefresh,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            padding: EdgeInsets.zero,
            itemCount: scheduledClasses.length + 1,
            itemBuilder: (context, index) {
              // --- ITEM 0: THE HEADER ---
              if (index == 0) {
                return Container(
                  padding: EdgeInsets.only(
                      top: topPadding + 20, bottom: 20, left: 16, right: 16),
                  alignment: Alignment.center,
                  child: Text(
                    'Schedule',
                    style: AppTextStyles.screentitle(context),
                  ),
                );
              }
              final classData = scheduledClasses[index - 1];

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ClassInfoCard(
                  classInfo: classData,
                  onTap: () {
                    Navigator.push(
                      context,
                      customFadePageRoute(
                        ClassDetailScreen(classInfo: classData),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onTabTapped: _handleBottomNavItemTapped,
        ),
      ),
    );
  }
}
