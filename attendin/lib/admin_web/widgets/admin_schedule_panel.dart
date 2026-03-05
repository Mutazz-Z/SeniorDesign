import 'package:attendin/admin_web/widgets/class_tile.dart';
import 'package:attendin/common/theme/app_text_styles.dart';
import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/models/class_info.dart';
import 'package:attendin/common/data/class_data_provider.dart';
import 'package:attendin/common/data/attendance_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:attendin/common/data/enrollment_data_provider.dart';
import 'dart:async';

class AdminSchedulePanel extends StatefulWidget {
  const AdminSchedulePanel({super.key});

  @override
  State<AdminSchedulePanel> createState() => _AdminSchedulePanelState();
}

class _AdminSchedulePanelState extends State<AdminSchedulePanel> {
  Timer? _scheduleUpdateTimer;

  @override
  void initState() {
    super.initState();
    _scheduleUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _scheduleUpdateTimer?.cancel();
    super.dispose();
  }

  List<ClassInfo> _getSortedSessionsForDay(
      List<ClassInfo> allClasses, int weekday) {
    final List<ClassInfo> sessions = allClasses
        .where((classInfo) =>
            classInfo.isActive && classInfo.daysOfWeek.contains(weekday))
        .toList();

    sessions.sort((a, b) {
      int aMinutes = a.startTime.hour * 60 + a.startTime.minute;
      int bMinutes = b.startTime.hour * 60 + b.startTime.minute;
      return aMinutes.compareTo(bMinutes);
    });
    return sessions;
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, AppColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.classTitle(context)
              .copyWith(color: colors.textColor),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          height: 1,
          color: colors.textColor.withAlpha(180),
        ),
      ],
    );
  }

  Widget _buildNoClassesMessage(
      BuildContext context, AppColorScheme colors, String message) {
    return Text(
      message,
      style: AppTextStyles.plaintext(context)
          .copyWith(color: colors.secondaryTextColor),
    );
  }

  Future<int> _getAttendancePercentage(
      BuildContext context, String classId, String date) async {
    final attendanceProvider =
        Provider.of<AttendanceProvider>(context, listen: false);
    final enrollmentProvider =
        Provider.of<EnrollmentProvider>(context, listen: false);

    // Fetch roster for this class
    await enrollmentProvider.fetchStudentUidsForCurrentClass(classId);
    final roster = enrollmentProvider.currentClassStudents;

    await attendanceProvider.fetchAttendance(classId, date);
    if (roster.isEmpty) return 0;
    return ((attendanceProvider.presentCount / roster.length) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);
    final DateTime now = DateTime.now();

    final classProvider = Provider.of<ClassDataProvider>(context);
    final List<ClassInfo> allAdminClasses = classProvider.classes;

    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final enrollmentProvider = Provider.of<EnrollmentProvider>(context);

    // Today's classes
    final int todayWeekday = now.weekday;
    final String todayDateStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final List<ClassInfo> todaySessions =
        _getSortedSessionsForDay(allAdminClasses, todayWeekday);

    ClassInfo? highlightedSession;
    final TimeOfDay currentTime = TimeOfDay.fromDateTime(now);

    for (var session in todaySessions) {
      final int sessionStartMinutes =
          session.startTime.hour * 60 + session.startTime.minute;
      final int sessionEndMinutes =
          session.endTime.hour * 60 + session.endTime.minute;
      final int currentMinutes = currentTime.hour * 60 + currentTime.minute;

      if ((currentMinutes >= sessionStartMinutes &&
              currentMinutes < sessionEndMinutes) ||
          currentMinutes < sessionStartMinutes) {
        highlightedSession = session;
        break;
      }
    }

    // Tomorrow's classes
    final DateTime tomorrowDate = now.add(const Duration(days: 1));
    final int tomorrowWeekday = tomorrowDate.weekday;
    final String tomorrowDateStr =
        "${tomorrowDate.year}-${tomorrowDate.month.toString().padLeft(2, '0')}-${tomorrowDate.day.toString().padLeft(2, '0')}";
    final String tomorrowFormattedDate =
        "${tomorrowDate.month}/${tomorrowDate.day}/${tomorrowDate.year}";
    final List<ClassInfo> tomorrowSessions =
        _getSortedSessionsForDay(allAdminClasses, tomorrowWeekday);

    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        color: colors.secondaryBackground,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's Classes Section
            _buildSectionHeader(context, 'Today', colors),
            const SizedBox(height: 10),
            if (todaySessions.isEmpty)
              _buildNoClassesMessage(
                  context, colors, 'No classes scheduled for today.')
            else
              ...todaySessions.map(
                (session) => StreamBuilder<QuerySnapshot>(
                  stream: attendanceProvider.attendanceStream(
                      session.id, todayDateStr),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    final docs = snapshot.data!.docs;
                    final presentCount =
                        docs.where((doc) => doc['status'] == 'present').length;
                    final totalCount = enrollmentProvider
                            .getStudentsForClass(session.id)
                            ?.length ??
                        0;
                    final percentage = totalCount > 0
                        ? ((presentCount / totalCount) * 100).round()
                        : 0;
                    return ClassTile(
                      session: session,
                      attendancePercentage: percentage,
                      isHighlighted: session == highlightedSession,
                    );
                  },
                ),
              ),
            const SizedBox(height: 30),

            // Tomorrow's Classes Section
            _buildSectionHeader(context, tomorrowFormattedDate, colors),
            const SizedBox(height: 15),
            if (tomorrowSessions.isEmpty)
              _buildNoClassesMessage(
                  context, colors, 'No classes scheduled for tomorrow.')
            else
              ...tomorrowSessions.map(
                (session) => StreamBuilder<QuerySnapshot>(
                  stream: attendanceProvider.attendanceStream(
                      session.id, tomorrowDateStr),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    final docs = snapshot.data!.docs;
                    final presentCount =
                        docs.where((doc) => doc['status'] == 'present').length;
                    final totalCount = enrollmentProvider
                            .getStudentsForClass(session.id)
                            ?.length ??
                        0;
                    final percentage = totalCount > 0
                        ? ((presentCount / totalCount) * 100).round()
                        : 0;
                    return ClassTile(
                      session: session,
                      attendancePercentage: percentage,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
