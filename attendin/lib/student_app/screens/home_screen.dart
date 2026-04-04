import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/student_app/widgets/calendar_widget.dart';
import 'package:attendin/student_app/widgets/mock_attendance_controls.dart';
import 'package:attendin/common/widgets/class_attendance_card.dart';
import 'package:attendin/common/widgets/custom_refresh_indicator.dart';
import 'package:attendin/student_app/widgets/custom_bottom_nav_bar.dart';
import 'package:attendin/common/widgets/home_header.dart';
import 'package:attendin/common/models/class_info.dart';
import 'package:attendin/common/utils/date_time_utils.dart';
import 'package:attendin/student_app/screens/schedule_screens/class_details_screen.dart';
import 'package:attendin/common/utils/app_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:attendin/common/data/attendance_data_provider.dart';
import 'package:attendin/common/services/location_service.dart';

import 'package:firebase_auth/firebase_auth.dart';
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

  bool _mockUserInLocation = true; //

  StreamSubscription<DocumentSnapshot>? _classSubscription;
  String? _listenedClassId;

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
    _classSubscription?.cancel();
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

  bool _isAttendanceWindowOpen(ClassInfo cls) {
    final now = DateTime.now();
    final classStart = DateTime(
        now.year, now.month, now.day, cls.startTime.hour, cls.startTime.minute);
    final classEnd = DateTime(
        now.year, now.month, now.day, cls.endTime.hour, cls.endTime.minute);

    if (now.isAfter(classEnd)) return false;

    if (cls.attendanceMode == 'manual') {
      return cls.isManualWindowOpen;
    } else if (cls.attendanceMode == 'auto_end') {
      final openTime =
          classEnd.subtract(Duration(minutes: cls.attendanceWindowMinutes));
      return now.isAfter(openTime) && now.isBefore(classEnd);
    } else if (cls.attendanceMode == 'auto_full') {
      // NEW: Math for two separate windows
      final firstWindowEnd =
          classStart.add(Duration(minutes: cls.attendanceWindowMinutes));
      final secondWindowStart =
          classEnd.subtract(Duration(minutes: cls.attendanceWindowMinutes));

      final inFirstWindow =
          now.isAfter(classStart) && now.isBefore(firstWindowEnd);
      final inSecondWindow =
          now.isAfter(secondWindowStart) && now.isBefore(classEnd);

      return inFirstWindow || inSecondWindow;
    } else {
      // Default: auto_start
      final end =
          classStart.add(Duration(minutes: cls.attendanceWindowMinutes));
      return now.isAfter(classStart) && now.isBefore(end);
    }
  }

  bool _attendanceWindowHasPassed(ClassInfo cls) {
    final now = DateTime.now();
    final classEnd = DateTime(
        now.year, now.month, now.day, cls.endTime.hour, cls.endTime.minute);

    if (now.isAfter(classEnd)) return true;

    if (cls.attendanceMode == 'manual' ||
        cls.attendanceMode == 'auto_end' ||
        cls.attendanceMode == 'auto_full') {
      // For these modes, they always have a chance to check in at the very end of class.
      // So the window hasn't truly "passed" until the class is completely over.
      return false;
    } else {
      // For auto_start, if they miss the first 15 mins, they are out of luck.
      final start = DateTime(now.year, now.month, now.day, cls.startTime.hour,
          cls.startTime.minute);
      final end = start.add(Duration(minutes: cls.attendanceWindowMinutes));
      return now.isAfter(end);
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

    _updateCurrentClassAndAttendance();
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
        if (_currentAttendanceStatus != AttendanceStatus.attended) {
          if (_attendanceWindowHasPassed(classCurrentlyInSession)) {
            _currentAttendanceStatus = AttendanceStatus.missed;
          }
        }
      } else if (nextUpcomingClass != null) {
        _currentClass = nextUpcomingClass;
        _currentAttendanceStatus = AttendanceStatus.markAttendance;
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

    if (detectedClass != null && authUser != null) {
      if (_listenedClassId != detectedClass.id) {
        _classSubscription?.cancel();
        _listenedClassId = detectedClass.id;

        _classSubscription = FirebaseFirestore.instance
            .collection('classes')
            .doc(detectedClass.id)
            .snapshots()
            .listen((snapshot) {
          if (snapshot.exists && mounted) {
            final data = snapshot.data() as Map<String, dynamic>;

            setState(() {
              _currentClass = ClassInfo.fromMap(data, snapshot.id);

              // 2. Instantly update the UI status if the teacher closes the window
              if (_currentAttendanceStatus != AttendanceStatus.attended) {
                // Notice we are using _currentClass! here, NOT detectedClass!
                if (_attendanceWindowHasPassed(_currentClass!)) {
                  _currentAttendanceStatus = AttendanceStatus.missed;
                } else {
                  _currentAttendanceStatus = AttendanceStatus.markAttendance;
                }
              }
            });
          }
        });
      }

      // Check the Database!
      final attendanceProvider =
          Provider.of<AttendanceProvider>(context, listen: false);

      // Format today's date (YYYY-MM-DD) to match your DB format
      final now = DateTime.now();
      final dateString =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final statusFromDb = await attendanceProvider.checkStudentStatus(
          detectedClass.id, authUser.uid, dateString);

      print(statusFromDb);

      // Update UI with the Real DB Status
      if (mounted) {
        setState(() {
          if (statusFromDb == 'present') {
            _currentAttendanceStatus = AttendanceStatus.attended;
          } else if (statusFromDb == 'pending') {
            // NEW: Server says they did the morning check-in!
            _currentAttendanceStatus = AttendanceStatus.pending;
          } else if (_attendanceWindowHasPassed(detectedClass!)) {
            _currentAttendanceStatus = AttendanceStatus.missed;
          } else {
            _currentAttendanceStatus = AttendanceStatus.markAttendance;
          }
        });
      }
    } else if (detectedClass == null) {
      _classSubscription?.cancel();
      _listenedClassId = null;

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

    // 1. THE DOUBLE-TAP LOCK: Prevent spam-clicking while it's already processing!
    if (_currentAttendanceStatus == AttendanceStatus.marking) return;

    if (!_isAttendanceWindowOpen(_currentClass!)) {
      ScaffoldMessenger.of(context)
          .clearSnackBars(); // Clear old popups instantly
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("The attendance window is currently closed."),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    // Show "Marking Attendance..." state
    setState(() {
      _currentAttendanceStatus = AttendanceStatus.marking;
    });

    try {
      final userProvider =
          Provider.of<UserDataProvider>(context, listen: false);
      final attendanceProvider =
          Provider.of<AttendanceProvider>(context, listen: false);

      final String locationId = _currentClass!.locationId;

      if (locationId.isEmpty) {
        throw Exception("This class does not have an assigned location.");
      }

      final locationDoc = await FirebaseFirestore.instance
          .collection('location')
          .doc(locationId)
          .get();

      if (!locationDoc.exists) {
        throw Exception("Classroom location data is missing in the database.");
      }

      final GeoPoint targetGeoPoint = locationDoc['location'];
      final double targetLat = targetGeoPoint.latitude;
      final double targetLng = targetGeoPoint.longitude;

      final double radius = locationDoc.data()!.containsKey('radius')
          ? (locationDoc['radius'] as num).toDouble()
          : 50.0;

      final userPos = await LocationService().getCurrentPosition();

      if (userPos == null) {
        throw Exception("Location permission denied or GPS is disabled.");
      }

      final double distance = LocationService().getDistanceInMeters(
        userPos.latitude,
        userPos.longitude,
        targetLat,
        targetLng,
      );

      print(
          "Debug: Distance to class is ${distance.round()}m. Required: ${radius.round()}m.");

      if (distance <= radius || _isUserInLocation()) {
        // --- SUCCESS: IN RANGE ---

        final now = DateTime.now();
        final dateString =
            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

// 1. Determine which phase of class we are in
        String targetDbStatus =
            'present'; // Default for auto_start, auto_end, and manual

        if (_currentClass!.attendanceMode == 'auto_full') {
          final classStart = DateTime(now.year, now.month, now.day,
              _currentClass!.startTime.hour, _currentClass!.startTime.minute);
          final firstWindowEnd = classStart
              .add(Duration(minutes: _currentClass!.attendanceWindowMinutes));

          if (now.isBefore(firstWindowEnd)) {
            // --- MORNING WINDOW ---
            targetDbStatus = 'pending';
          } else {
            // --- AFTERNOON WINDOW ---
            // The Bulletproof Check: Ask Firestore directly to avoid UI state bugs!
            final realDbStatus = await attendanceProvider.checkStudentStatus(
                _currentClass!.id, userProvider.uid, dateString);

            if (realDbStatus == 'pending') {
              // They successfully checked in this morning. Allow the check-out!
              targetDbStatus = 'present';
            } else {
              // They tried to skip class and just check out at the end. Block it.
              setState(() {
                _currentAttendanceStatus = AttendanceStatus.missed;
              });

              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      "Check Out failed. You missed the initial Check In window."),
                  duration: Duration(seconds: 4),
                ),
              );
              return; // STOP EXECUTION!
            }
          }
        }

        // 2. Fire the correct string to the Database
        // Note: You will need to add a markPending method to your AttendanceProvider
        // that works exactly like markPresent, but sends 'pending' instead!
        if (targetDbStatus == 'pending') {
          await attendanceProvider.markPending(
              _currentClass!.id, userProvider.uid, dateString);
          setState(() {
            _currentAttendanceStatus = AttendanceStatus.pending;
          });
          print("Morning Check In saved as Pending!");
        } else {
          await attendanceProvider.markPresent(
              _currentClass!.id, userProvider.uid, dateString);
          setState(() {
            _currentAttendanceStatus = AttendanceStatus.attended;
          });
          _confettiController.play(); // Only fire confetti on full completion!
          print("Full Attendance saved to database!");
        }
      } else {
        // --- FAILURE: OUT OF RANGE ---
        setState(() {
          _currentAttendanceStatus = AttendanceStatus.outOfLocation;
        });

        // 2. THE QUEUE CLEARER: Instantly destroy old snackbars before showing the new one
        ScaffoldMessenger.of(context).clearSnackBars();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "You are ${distance.round()}m away. Must be within ${radius.round()}m."),
              duration: const Duration(seconds: 3)),
        );

        // Wait 3 seconds then reset to allow trying again
        await Future.delayed(const Duration(seconds: 3));

        // Safety check: Only reset to "markAttendance" if they are STILL in the "outOfLocation" state.
        // (Prevents bugs if the class ended during those 3 seconds)
        if (mounted &&
            _currentAttendanceStatus == AttendanceStatus.outOfLocation) {
          setState(() {
            _currentAttendanceStatus = AttendanceStatus.markAttendance;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentAttendanceStatus = AttendanceStatus.markAttendance;
        });

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  Future<void> _handleMockStatusChange(AttendanceStatus status) async {
    // 1. Instantly update the UI so the button changes color locally
    setState(() {
      _currentAttendanceStatus = status;
    });

    if (_currentClass == null) return;

    final userProvider = Provider.of<UserDataProvider>(context, listen: false);
    final attendanceProvider =
        Provider.of<AttendanceProvider>(context, listen: false);

    final now = DateTime.now();
    final dateString =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    try {
      // 2. Route the mock status to your REAL Firestore database provider!
      if (status == AttendanceStatus.attended) {
        await attendanceProvider.markPresent(
            _currentClass!.id, userProvider.uid, dateString);
        _confettiController.play();
      } else if (status == AttendanceStatus.pending) {
        await attendanceProvider.markPending(
            _currentClass!.id, userProvider.uid, dateString);
      } else if (status == AttendanceStatus.missed) {
        // Change 'markAbsent' to whatever you named your absent method in the provider
        await attendanceProvider.markAbsent(
            _currentClass!.id, userProvider.uid, dateString);
      }
    } catch (e) {
      print("Mock DB Update Failed: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Mock update failed: $e")));
      }
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

    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: colors.secondaryBackground,
      body: Stack(
        children: [
          CustomRefreshIndicator(
            onRefresh: _handleRefresh,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              padding: EdgeInsets.only(
                  top: kPadding + statusBarHeight,
                  left: kPadding,
                  right: kPadding,
                  bottom: kPadding),
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
                    ClassCard(
                      currentClass: _currentClass,
                      currentAttendanceStatus: _currentAttendanceStatus,
                      onMarkAttendancePressed: _markAttendance,
                      markAttendanceButtonKey: _markAttendanceButtonKey,
                      onInfoIconPressed: () {
                        if (_currentClass != null) {
                          Navigator.push(
                            context,
                            customFadePageRoute(
                                ClassDetailScreen(classInfo: _currentClass!)),
                          );
                        }
                      },
                    )
                  else
                    ClassCard(
                      currentClass: null,
                      currentAttendanceStatus: AttendanceStatus.markAttendance,
                      onMarkAttendancePressed: _markAttendance,
                      markAttendanceButtonKey: _markAttendanceButtonKey,
                      onInfoIconPressed: () {},
                    ),
                  const SizedBox(height: kSectionSpacing),
                  if (true) // For removing the mock controls easily
                    MockAttendanceControls(
                      onStatusChanged: (status) {
                        _handleMockStatusChange(status);
                      },
                      onToggleLocation: () {
                        setState(() {
                          _mockUserInLocation = !_mockUserInLocation;
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
                          if (_currentClass == null &&
                              studentClasses.isNotEmpty) {
                            _currentClass = studentClasses.first;
                          }
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
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTabTapped: _handleBottomNavItemTapped,
      ),
    );
  }
}
