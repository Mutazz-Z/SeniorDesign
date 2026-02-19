import 'package:attendin/common/models/class_info.dart';
import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/theme/app_text_styles.dart';
import 'package:attendin/student_app/widgets/custom_bottom_nav_bar.dart';
import 'package:attendin/common/utils/date_time_utils.dart';
import 'package:attendin/common/widgets/expanded_calendar_widget.dart';
import 'package:attendin/common/widgets/class_attendance_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:attendin/common/data/user_data_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class ClassDetailScreen extends StatefulWidget {
  final ClassInfo classInfo;

  const ClassDetailScreen({super.key, required this.classInfo});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  int _selectedIndex = 2;
  late Future<Map<String, List<DateTime>>> _attendanceDaysFuture;

  @override
  void initState() {
    super.initState();
    _attendanceDaysFuture = fetchAttendanceDays();
  }

  Future<Map<String, List<DateTime>>> fetchAttendanceDays() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return {'absent': [], 'present': [], 'excused': []};

    final snapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .where('studentUid', isEqualTo: userId)
        .where('classId', isEqualTo: widget.classInfo.id)
        .get();

    final Map<String, List<DateTime>> result = {
      'absent': [],
      'present': [],
      'excused': [],
    };

    for (final doc in snapshot.docs) {
      final dateString = doc['date'] as String;
      final status = doc['status'] as String;
      final date = DateTime.parse(dateString);
      if (result.containsKey(status)) {
        result[status]!.add(date);
      }
    }
    return result;
  }

  // NEW: Refresh handler
  Future<void> _handleRefresh() async {
    setState(() {
      _attendanceDaysFuture = fetchAttendanceDays();
    });
    await _attendanceDaysFuture;
  }

  void _handleBottomNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.secondaryBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Info', style: AppTextStyles.screentitle(context)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: colors.fieldTitleColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: FutureBuilder<Map<String, List<DateTime>>>(
          future: _attendanceDaysFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Wrap spinner in container to allow scroll physics to work with RefreshIndicator
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Center(child: Text('Error loading missed days')),
              );
            }
            final attendanceDays =
                snapshot.data ?? {'absent': [], 'present': [], 'excused': []};
            final missedCount = attendanceDays['absent']?.length ?? 0;

            final presentDays = attendanceDays['present'] ?? [];
            final excusedDays = attendanceDays['excused'] ?? [];
            final missedDays = attendanceDays['absent'] ?? [];

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0).copyWith(
                top: MediaQuery.of(context).padding.top + kToolbarHeight + 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClassCard(
                    currentClass: widget.classInfo,
                    showAttendanceActions: false,
                    getDaysString: getDaysString,
                    formatTimeOfDay: formatTimeOfDay,
                  ),
                  const SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      color: colors.errorRed,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(51),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    child: Text(
                      'Classes Missed: $missedCount',
                      style: AppTextStyles.button(context)
                          .copyWith(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ClassCalendar(
                    classInfo: widget.classInfo,
                    missedDays: missedDays,
                    presentDays: presentDays,
                    excusedDays: excusedDays,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTabTapped: _handleBottomNavItemTapped,
      ),
    );
  }
}
