import 'package:attendin/admin_web/widgets/admin_schedule_panel.dart';
import 'package:attendin/admin_web/widgets/current_session_card.dart';
import 'package:attendin/admin_web/widgets/attendance_card.dart';
import 'package:attendin/common/models/class_info.dart';
import 'package:attendin/common/theme/app_text_styles.dart';
import 'package:attendin/common/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:attendin/common/data/class_data_provider.dart';
import 'package:attendin/common/data/attendance_data_provider.dart';
import 'package:attendin/common/data/user_data_provider.dart';
import 'package:attendin/common/data/enrollment_data_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'dart:async';

class DashboardScreen extends StatefulWidget {
  final bool isSmallScreen;

  const DashboardScreen({
    super.key,
    this.isSmallScreen = false,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // We keep track of the ID to know when to switch streams
  String _trackedSessionId = "";

  Timer? _sessionCheckTimer;
  String _todayDateString = "";
  List<ClassStudent> _enrolledStudents = [];
  Stream<QuerySnapshot>? _attendanceStream;

  @override
  void initState() {
    super.initState();
    _updateDateString();

    // Timer just forces a rebuild every minute to check time-based logic
    _sessionCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });

    // Initial fetch of classes if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final classProvider =
          Provider.of<ClassDataProvider>(context, listen: false);
      final userProvider =
          Provider.of<UserDataProvider>(context, listen: false);
      if (classProvider.classes.isEmpty) {
        classProvider.fetchClassesForAdmin(userProvider.uid);
      }
    });
  }

  @override
  void dispose() {
    _sessionCheckTimer?.cancel();
    super.dispose();
  }

  void _updateDateString() {
    final now = DateTime.now();
    _todayDateString =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  // Called only when the Class ID changes (e.g. Class A ends, Class B starts)
  void _handleSessionSwitch(ClassInfo? newSession) {
    if (newSession?.id == _trackedSessionId) return;

    _trackedSessionId = newSession!.id;

    if (newSession != null) {
      // 1. Create new Stream
      _attendanceStream = FirebaseFirestore.instance
          .collection('attendance')
          .where('classId', isEqualTo: newSession.id)
          .where('date', isEqualTo: _todayDateString)
          .snapshots();

      // 2. Fetch Roster
      _fetchRoster(newSession.id);
    } else {
      _attendanceStream = null;
      _enrolledStudents = [];
    }
  }

  Future<void> _fetchRoster(String classId) async {
    final enrollmentProvider =
        Provider.of<EnrollmentProvider>(context, listen: false);
    await enrollmentProvider.fetchStudentUidsForCurrentClass(classId);
    if (mounted) {
      setState(() {
        _enrolledStudents = enrollmentProvider.currentClassStudents;
      });
    }
  }

  Future<void> _updateAttendanceStatus(
      ClassStudent student, String newStatus) async {
    final attendanceProvider =
        Provider.of<AttendanceProvider>(context, listen: false);

    if (newStatus == 'present') {
      await attendanceProvider.markPresent(
          _trackedSessionId, student.id, _todayDateString);
    } else {
      await attendanceProvider.markAbsent(
          _trackedSessionId, student.id, _todayDateString);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);
    final userProvider = Provider.of<UserDataProvider>(context);

    // LISTEN: React to Class Data Updates immediately
    final classProvider = Provider.of<ClassDataProvider>(context);

    final now = DateTime.now();
    final timeNow = TimeOfDay.fromDateTime(now);

    // Calculate current session from the *latest* data
    final ClassInfo? currentSession = findCurrentSession(
        classProvider.classes, userProvider.uid, now, timeNow);

    // Check if we need to switch streams (Side Effect)
    if (currentSession?.id != _trackedSessionId) {
      // Schedule state update to avoid "setState during build"
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _handleSessionSwitch(currentSession);
        });
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmall = widget.isSmallScreen || constraints.maxWidth < 975;

        return Scaffold(
          backgroundColor: colors.primaryBackground,
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: colors.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dashboard',
                            style: AppTextStyles.screentitle(context).copyWith(
                                fontSize: 32,
                                color: colors.classesTextColorWeb),
                          ),
                          const SizedBox(height: 5),
                          Text('Overview of your current and upcoming classes',
                              style: AppTextStyles.plaintext(context)),
                          const SizedBox(height: 30),

                          // UI uses 'currentSession' directly (Reactive)
                          if (currentSession != null)
                            Expanded(
                              child: StreamBuilder<QuerySnapshot>(
                                stream: _attendanceStream,
                                builder: (context, snapshot) {
                                  Set<String> presentIds = {};
                                  if (snapshot.hasData &&
                                      snapshot.data != null) {
                                    for (var doc in snapshot.data!.docs) {
                                      final data =
                                          doc.data() as Map<String, dynamic>;
                                      if (data['status'] == 'present' &&
                                          data.containsKey('studentUid')) {
                                        presentIds.add(data['studentUid']);
                                      }
                                    }
                                  }

                                  List<ClassStudent> presentList = [];
                                  List<ClassStudent> absentList = [];

                                  for (var student in _enrolledStudents) {
                                    if (presentIds.contains(student.id)) {
                                      presentList.add(student);
                                    } else {
                                      absentList.add(student);
                                    }
                                  }

                                  return Column(
                                    children: [
                                      CurrentSessionCard(
                                        sessionInfo:
                                            currentSession, // Updated Info
                                        presentStudents: presentList.length,
                                        totalStudents: _enrolledStudents.length,
                                        timeLeftForAttendance:
                                            getAttendanceWindowLeft(
                                                currentSession, now),
                                      ),
                                      const SizedBox(height: 24),
                                      Expanded(
                                        child: AttendanceCard(
                                            presentStudents: presentList,
                                            absentStudents: absentList,
                                            onStatusChange:
                                                _updateAttendanceStatus),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            )
                          else
                            _buildNoClassActiveState(colors),
                        ],
                      ),
                    ),
                  ),
                  if (!isSmall) ...[
                    const SizedBox(width: 24),
                    const Expanded(
                      flex: 1,
                      child: AdminSchedulePanel(),
                    ),
                  ]
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoClassActiveState(AppColorScheme colors) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 80, color: colors.secondaryTextColor),
            const SizedBox(height: 20),
            Text(
              "No Class in Session",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.secondaryTextColor),
            ),
          ],
        ),
      ),
    );
  }
}

// HELPERS
ClassInfo? findCurrentSession(
    List<ClassInfo> classes, String adminId, DateTime today, TimeOfDay now) {
  try {
    return classes.firstWhere((c) {
      if (c.adminId != adminId) return false;
      if (!c.daysOfWeek.contains(today.weekday)) return false;
      if (c.isActive == false) return false;
      final nowMinutes = now.hour * 60 + now.minute;
      final startMinutes = c.startTime.hour * 60 + c.startTime.minute;
      final endMinutes = c.endTime.hour * 60 + c.endTime.minute;
      return nowMinutes >= startMinutes && nowMinutes < endMinutes;
    });
  } catch (e) {
    return null;
  }
}

Duration getAttendanceWindowLeft(ClassInfo session, DateTime now) {
  final endMinutes = session.endTime.hour * 60 + session.endTime.minute;
  final nowMinutes = now.hour * 60 + now.minute;
  final minutesLeft = endMinutes - nowMinutes;
  return Duration(minutes: minutesLeft > 0 ? minutesLeft : 0);
}
