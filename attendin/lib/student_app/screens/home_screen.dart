import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/student_app/widgets/calendar_widget.dart';
import 'package:attendin/student_app/widgets/mock_attendance_controls.dart';
import 'package:attendin/common/widgets/class_attendance_card.dart';
import 'package:attendin/student_app/widgets/custom_bottom_nav_bar.dart';
import 'package:attendin/common/widgets/home_header.dart';
import 'package:attendin/common/models/class_info.dart';
import 'package:attendin/common/utils/date_time_utils.dart';
import 'package:attendin/student_app/screens/schedule_screens/class_details_screen.dart';
import 'package:attendin/common/utils/app_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:attendin/common/data/attendance_data_provider.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:attendin/common/models/class_info.dart';
import 'package:provider/provider.dart';
import 'package:attendin/common/data/user_data_provider.dart';
import 'package:attendin/common/data/class_data_provider.dart';
import 'package:attendin/common/data/enrollment_data_provider.dart';
import 'package:attendin/common/theme/theme_provider.dart';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:confetti/confetti.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1; // 0: Profile, 1: Home, 2: Schedule
  Offset _buttonPosition = Offset.zero;
  Size _buttonSize = Size.zero;

  AttendanceStatus _currentAttendanceStatus = AttendanceStatus.markAttendance;
  ClassInfo? _currentClass;
  Timer? _timer;

  bool _mockUserInLocation = true;

  late ConfettiController _confettiController;
  final GlobalKey _markAttendanceButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // Check immediately on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCurrentClassAndAttendance();
    });

    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateCurrentClassAndAttendance();
    });

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  void _measureButtonPosition() {
    // 1. Check if the button is mounted and ready
    final RenderBox? renderBox = _markAttendanceButtonKey.currentContext
        ?.findRenderObject() as RenderBox?;

    if (renderBox != null && renderBox.hasSize) {
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;

      // 2. Only update state if the values changed (prevents infinite loops)
      if (position != _buttonPosition || size != _buttonSize) {
        setState(() {
          _buttonPosition = position;
          _buttonSize = size;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    final userProvider = Provider.of<UserDataProvider>(context, listen: false);
    final enrollmentProvider =
        Provider.of<EnrollmentProvider>(context, listen: false);
    final classProvider =
        Provider.of<ClassDataProvider>(context, listen: false);

    await userProvider.fetchUserData(); // If you want to refresh user info
    await enrollmentProvider.fetchClassIdsForStudent(userProvider.uid);
    await classProvider.fetchClassesByIds(
        enrollmentProvider.studentClassIds); // Always fetch fresh data
    setState(() {});
  }

  Future<void> _updateCurrentClassAndAttendance() async {
    final classProvider =
        Provider.of<ClassDataProvider>(context, listen: false);
    final authUser = FirebaseAuth.instance.currentUser; // Get current user
    final now = DateTime.now();
    final int currentDay = now.weekday;
    final currentTime = TimeOfDay.fromDateTime(now);

    ClassInfo? classCurrentlyInSession;
    ClassInfo? nextUpcomingClass;

    final List<ClassInfo> classesToday = classProvider.classes
        .where((cls) => cls.daysOfWeek.contains(currentDay))
        .toList();

    classesToday.sort((a, b) {
      final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
      final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
      return aMinutes.compareTo(bMinutes);
    });

    for (var cls in classesToday) {
      if (_isClassCurrentlyInSession(cls, currentTime)) {
        classCurrentlyInSession = cls;
        break;
      } else if (_isClassUpcoming(cls, currentTime)) {
        nextUpcomingClass ??= cls;
      }
    }

    setState(() {
      if (classCurrentlyInSession != null) {
        _currentClass = classCurrentlyInSession;
        if (_currentAttendanceStatus != AttendanceStatus.attended &&
            _currentAttendanceStatus != AttendanceStatus.missed) {
          _currentAttendanceStatus = AttendanceStatus.markAttendance;
        }
      } else if (nextUpcomingClass != null) {
        _currentClass = nextUpcomingClass;
        if (_currentAttendanceStatus != AttendanceStatus.attended &&
            _currentAttendanceStatus != AttendanceStatus.missed) {
          _currentAttendanceStatus = AttendanceStatus.markAttendance;
        }
      } else {
        _currentClass = null;
        _currentAttendanceStatus = AttendanceStatus.markAttendance;
      }
    });

    ClassInfo? detectedClass;
    if (classCurrentlyInSession != null) {
      detectedClass = classCurrentlyInSession;
    } else if (nextUpcomingClass != null) {
      detectedClass = nextUpcomingClass;
    }

    // 3. IF the class changed, or if we haven't checked the DB yet...
    if (detectedClass != _currentClass &&
        detectedClass != null &&
        authUser != null) {
      // Check the Database!
      final attendanceProvider =
          Provider.of<AttendanceProvider>(context, listen: false);

      // Format today's date (YYYY-MM-DD) to match your DB format
      final now = DateTime.now();
      final dateString =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final statusFromDb = await attendanceProvider.checkStudentStatus(
          detectedClass.id, authUser.uid, dateString);

      // Update UI with the Real DB Status
      if (mounted) {
        setState(() {
          _currentClass = detectedClass;

          if (statusFromDb == 'present') {
            _currentAttendanceStatus = AttendanceStatus.attended;
          } else if (statusFromDb == 'absent') {
            _currentAttendanceStatus = AttendanceStatus.missed;
          } else {
            _currentAttendanceStatus = AttendanceStatus.markAttendance;
          }
        });
      }
    } else if (detectedClass == null) {
      if (mounted) {
        setState(() {
          _currentClass = null;
          _currentAttendanceStatus = AttendanceStatus.markAttendance;
        });
      }
    }
  }

  bool _isClassCurrentlyInSession(ClassInfo cls, TimeOfDay currentTime) {
    final int startMinutes = cls.startTime.hour * 60 + cls.startTime.minute;
    final int endMinutes = cls.endTime.hour * 60 + cls.endTime.minute;
    final int currentMinutes = currentTime.hour * 60 + currentTime.minute;

    return currentMinutes >= startMinutes && currentMinutes < endMinutes;
  }

  bool _isClassUpcoming(ClassInfo cls, TimeOfDay currentTime) {
    final int startMinutes = cls.startTime.hour * 60 + cls.startTime.minute;
    final int currentMinutes = currentTime.hour * 60 + currentTime.minute;
    return currentMinutes < startMinutes;
  }

  bool _isUserInLocation() {
    return _mockUserInLocation;
  }

  Future<void> _markAttendance() async {
    if (_currentClass == null) return;
    final userProvider = Provider.of<UserDataProvider>(context, listen: false);
    final attendanceProvider =
        Provider.of<AttendanceProvider>(context, listen: false);

    // 2. Check Location (Keep your mock logic for now, later we add Geolocator)
    if (_isUserInLocation()) {
      // 3. Optimistic UI Update (Show success immediately before DB finishes)
      setState(() {
        _currentAttendanceStatus = AttendanceStatus.attended;
      });
      _confettiController.play();

      // 4. Prepare Data for Database
      final now = DateTime.now();
      final dateString =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      try {
        // 5. Write to Firebase
        await attendanceProvider.markPresent(
            _currentClass!.id, userProvider.uid, dateString);
        print("Attendance saved to database!");
      } catch (e) {
        setState(() {
          _currentAttendanceStatus = AttendanceStatus.markAttendance;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving attendance: $e")),
        );
      }
    } else {
      setState(() {
        _currentAttendanceStatus = AttendanceStatus.outOfLocation;
      });
    }
  }

  void _handleBottomNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserDataProvider>(context);
    final enrollmentProvider = Provider.of<EnrollmentProvider>(context);
    final classProvider = Provider.of<ClassDataProvider>(context);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _measureButtonPosition());

    final List<ClassInfo> studentClasses = classProvider.classes
        .where((cls) => enrollmentProvider.studentClassIds.contains(cls.id))
        .toList();

    if (userData.loading ||
        classProvider.loading ||
        enrollmentProvider.loading) {
      final AppColorScheme colors = AppColors.of(context);
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
                  widthFactor: 0.5, // 50% of screen width
                  child: AspectRatio(
                    aspectRatio: 1, // Keep logo square
                    child: Image.asset(
                      logoPath,
                      fit: BoxFit.contain,
                    ),
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

    final AppColorScheme colors = AppColors.of(context);

    final now = DateTime.now();
    final todayWeekday = now.weekday;

    const double kSectionSpacing = 30.0;
    const double kPadding = 24.0;

    final RenderBox? buttonRenderBox = _markAttendanceButtonKey.currentContext
        ?.findRenderObject() as RenderBox?;

    return Scaffold(
      backgroundColor: colors.secondaryBackground,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(), // ensures scroll even if content is short
                padding: const EdgeInsets.all(kPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeScreenHeader(
                        userName: userData.userName,
                        profilePicture: userData.profilePicture),
                    const SizedBox(height: kSectionSpacing),
                    CalendarWidget(
                      userClasses: studentClasses,
                      now: now,
                      todayWeekday: todayWeekday,
                    ),
                    const SizedBox(height: kSectionSpacing),
                    if (_currentClass != null)
                      StreamBuilder<DocumentSnapshot>(
                        // 1. Listen specifically to the CURRENT class document
                        stream: FirebaseFirestore.instance
                            .collection('classes')
                            .doc(_currentClass!.id)
                            .snapshots(),
                        builder: (context, snapshot) {
                          // 2. If we have fresh data, update our local _currentClass object
                          if (snapshot.hasData &&
                              snapshot.data != null &&
                              snapshot.data!.exists) {
                            final data =
                                snapshot.data!.data() as Map<String, dynamic>;

                            // // Update the location/time/status dynamically
                            // _currentClass!.location =
                            //     data['location'] ?? _currentClass!.location;
                            // _currentClass!.isActive =
                            //     data['is_active'] ?? _currentClass!.isActive;
                            // // You can update other fields here too if needed
                          }

                          return ClassCard(
                            currentClass: _currentClass,
                            currentAttendanceStatus: _currentAttendanceStatus,
                            onMarkAttendancePressed: _markAttendance,
                            getDaysString: getDaysString,
                            formatTimeOfDay: formatTimeOfDay,
                            markAttendanceButtonKey: _markAttendanceButtonKey,
                            onInfoIconPressed: () {
                              if (_currentClass != null) {
                                Navigator.push(
                                  context,
                                  customFadePageRoute(ClassDetailScreen(
                                      classInfo: _currentClass!)),
                                );
                              }
                            },
                          );
                        },
                      )
                    else
                      ClassCard(
                        currentClass: null,
                        currentAttendanceStatus:
                            AttendanceStatus.markAttendance,
                        onMarkAttendancePressed: _markAttendance,
                        getDaysString: getDaysString,
                        formatTimeOfDay: formatTimeOfDay,
                        markAttendanceButtonKey: _markAttendanceButtonKey,
                        onInfoIconPressed: () {},
                      ),
                    const SizedBox(height: kSectionSpacing),
                    MockAttendanceControls(
                      onStatusChanged: (status) {
                        setState(() {
                          _currentAttendanceStatus = status;
                        });
                      },
                      onToggleLocation: () {
                        setState(() {
                          _mockUserInLocation = !_mockUserInLocation;
                          if (_currentClass != null &&
                              _currentAttendanceStatus ==
                                  AttendanceStatus.markAttendance) {
                            _markAttendance();
                          }
                        });
                      },
                      mockUserInLocation: _mockUserInLocation,
                      onNoClass: () {
                        setState(() {
                          _currentClass = null;
                          _currentAttendanceStatus =
                              AttendanceStatus.markAttendance;
                        });
                      },
                      onMarkAttendanceSet: () {
                        setState(() {
                          _currentClass = studentClasses.isNotEmpty
                              ? studentClasses.first
                              : null;
                          _currentAttendanceStatus =
                              AttendanceStatus.markAttendance;
                        });
                      },
                    ),
                    const SizedBox(height: kSectionSpacing),
                  ],
                ),
              ),
            ),
            if (_buttonSize != Size.zero)
              Positioned(
                left: _buttonPosition.dx + _buttonSize.width / 2,
                top: _buttonPosition.dy - 10,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: -pi / 2,
                  emissionFrequency: 0.03,
                  numberOfParticles: 20,
                  gravity: 0.2,
                  colors: [
                    colors.primaryBlue,
                    colors.accentGreen,
                    colors.cardColor,
                    colors.errorOrange,
                    colors.errorRed,
                  ],
                  shouldLoop: false,
                  minBlastForce: 10,
                  maxBlastForce: 20,
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTabTapped: _handleBottomNavItemTapped,
      ),
    );
  }
}
