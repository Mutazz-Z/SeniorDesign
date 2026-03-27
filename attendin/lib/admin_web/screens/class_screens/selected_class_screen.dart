import 'package:attendin/admin_web/widgets/modal_widget.dart';
import 'package:attendin/common/data/enrollment_data_provider.dart';
import 'package:attendin/common/widgets/expanded_calendar_widget.dart';
import 'package:attendin/common/widgets/primary_button.dart';
import 'package:attendin/common/widgets/profile_picture_widget.dart';
import 'package:attendin/common/widgets/labeled_input_field.dart';
import 'package:attendin/common/models/class_info.dart';
import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/theme/app_text_styles.dart';
import 'package:attendin/common/utils/date_time_utils.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:attendin/common/data/attendance_data_provider.dart';
import 'package:attendin/common/data/class_data_provider.dart';

import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:web/web.dart' as web;

import 'package:flutter/material.dart';

class SelectedClassScreen extends StatefulWidget {
  final ClassInfo classInfo;
  final List<ClassStudent>? students;
  final VoidCallback onBack;
  final VoidCallback onSettingsTap;

  const SelectedClassScreen({
    super.key,
    required this.classInfo,
    required this.onBack,
    required this.onSettingsTap,
    this.students,
  });
  @override
  State<SelectedClassScreen> createState() => _SelectedClassScreenState();
}

class _SelectedClassScreenState extends State<SelectedClassScreen> {
  ClassStudent? _selectedStudent;
  OverlayEntry? _overlayEntry;
  final TextEditingController _addStudentController = TextEditingController();

  final Map<ClassStudent, Map<DateTime, AttendanceOverrideStatus>>
      _allOverrides = {};

  @override
  void initState() {
    super.initState();
  }

  Future<void> _addStudentToClass(
      String schoolId, List<ClassStudent> students) async {
    // Look up the user by schoolId
    final userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('schoolId', isEqualTo: schoolId)
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user found with that School ID.')),
      );
      return;
    }

    final userDoc = userQuery.docs.first;
    final studentUid = userDoc.id;
    final data = userDoc.data();

    // Check if already enrolled
    if (students.any((s) => s.id == studentUid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Student is already enrolled in this class.')),
      );
      return;
    }

    // Add to enrollment collection
    await FirebaseFirestore.instance.collection('enrollment').add({
      'classId': widget.classInfo.id,
      'studentUid': studentUid,
    });

    final newStudent = ClassStudent(
      id: studentUid,
      name: data['name'] ?? '',
      profilePicture: data['profilePicture'] ?? '',
      schoolId: data['schoolId'] ?? '',
    );

    // 3. Update Provider Cache (Frontend)
    // This instantly updates the UI because ClassDetailsPanel is listening
    Provider.of<EnrollmentProvider>(context, listen: false)
        .addToCache(widget.classInfo.id, newStudent);

    _addStudentController.clear();
  }

  Future<void> _applyOverride(
      DateTime date, AttendanceOverrideStatus status) async {
    if (_selectedStudent == null) return;

    // Convert date to string (format must match your attendance records)
    final dateStr =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    // Map override status to Firestore status string
    String statusString;
    switch (status) {
      case AttendanceOverrideStatus.attended:
        statusString = 'present';
        break;
      case AttendanceOverrideStatus.absent:
        statusString = 'absent';
        break;
      case AttendanceOverrideStatus.excused:
        statusString = 'excused';
        break;
      default:
        statusString = 'absent';
    }

    // Write to Firestore
    final recordId = "${widget.classInfo.id}_${_selectedStudent!.id}_$dateStr";
    await FirebaseFirestore.instance
        .collection('attendance')
        .doc(recordId)
        .set({
      'classId': widget.classInfo.id,
      'studentUid': _selectedStudent!.id,
      'date': dateStr,
      'status': statusString,
    });

    Provider.of<AttendanceProvider>(context, listen: false).updateHistoryCache(
        widget.classInfo.id, _selectedStudent!.id, dateStr, statusString);

    setState(() {
      final studentMap = _allOverrides.putIfAbsent(_selectedStudent!, () => {});
      studentMap[date] = status;
    });
    _removeOverlay();
  }

  Future<void> _removeOverride(DateTime date) async {
    if (_selectedStudent == null) return;

    final dateStr =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final recordId = "${widget.classInfo.id}_${_selectedStudent!.id}_$dateStr";

    // Remove from Firestore
    await FirebaseFirestore.instance
        .collection('attendance')
        .doc(recordId)
        .delete();

    Provider.of<AttendanceProvider>(context, listen: false).updateHistoryCache(
        widget.classInfo.id, _selectedStudent!.id, dateStr, null);

    setState(() {
      _allOverrides[_selectedStudent!]?.remove(date);
    });
    _removeOverlay();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverrideMenu(BuildContext cellContext, DateTime date) {
    _removeOverlay();
    if (_selectedStudent == null) {
      return;
    }
    final overlay = Overlay.of(context);
    final renderBox = cellContext.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final bool openUpwards = position.dy > screenHeight / 2;
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeOverlay,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            left: position.dx,
            top: openUpwards ? null : position.dy + size.height,
            bottom: openUpwards ? screenHeight - position.dy : null,
            child: _buildMenu(date),
          ),
        ],
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  Future<void> _generateAndDownloadCsv(List<ClassStudent> students) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating CSV...')),
    );

    final provider = Provider.of<AttendanceProvider>(context, listen: false);

    // 1. Gather all attendance data and find all unique dates
    Map<String, Map<String, dynamic>> allStudentRecords = {};
    Set<String> uniqueDates = {};

    for (var student in students) {
      final history = await provider.fetchStudentAttendanceHistory(
          widget.classInfo.id, student.id);
      allStudentRecords[student.id] = history;
      uniqueDates.addAll(history.keys);
    }

    // Sort dates chronologically
    List<String> sortedDates = uniqueDates.toList()..sort();

    // 2. Prepare CSV Data Matrix
    List<List<dynamic>> csvData = [];

    // Header Row
    csvData.add([
      'Student ID',
      'Student Name',
      'Total Present',
      'Total Missed',
      'Percentage',
      ...sortedDates
    ]);

    // 3. Build each Student's Row
// 3. Build each Student's Row
    int totalClassesHeld = sortedDates.length;

    for (var student in students) {
      final history = allStudentRecords[student.id] ?? {};

      int presentCount = 0;
      int excusedCount = 0;
      int explicitAbsentCount =
          0; // For when teachers manually mark them absent

      // Count what we actually have in the database
      for (var status in history.values) {
        if (status == 'present') presentCount++;
        if (status == 'excused') excusedCount++;
        if (status == 'absent') explicitAbsentCount++;
      }

      // The magic math: Missed is the total classes minus the times they were there or excused
      int totalMissed = totalClassesHeld - presentCount - excusedCount;

      String percentage = totalClassesHeld == 0
          ? "N/A"
          : "${((presentCount / totalClassesHeld) * 100).toStringAsFixed(1)}%";

      List<dynamic> row = [
        student.schoolId,
        student.name,
        presentCount,
        totalMissed,
        percentage,
      ];

      // Fill in the daily columns
      for (var date in sortedDates) {
        final status = history[date];

        if (status == 'present') {
          row.add('Present');
        } else if (status == 'excused') {
          row.add('Excused');
        } else if (status == 'absent') {
          row.add('Absent'); // Manually marked absent
        } else {
          // IMPLICIT ABSENT: No record exists for this day!
          row.add('Absent');
        }
      }

      csvData.add(row);
    }

    // 4. Convert to CSV String and then to Base64
    String csvString = const ListToCsvConverter().convert(csvData);
    final bytes = utf8.encode(csvString);
    final base64String = base64Encode(bytes);

    // 5. Trigger Web Download (Using modern package:web)
    final anchor = web.HTMLAnchorElement()
      ..href = 'data:text/csv;charset=utf-8;base64,$base64String'
      ..download =
          '${widget.classInfo.subject.replaceAll(' ', '_')}_Attendance.csv';

    anchor.click();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  Widget _buildMenu(DateTime date) {
    final colors = AppColors.of(context);
    return Material(
      elevation: 4.0,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          color: colors.cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMenuItem(colors.accentGreen, 'ATTENDED',
                () => _applyOverride(date, AttendanceOverrideStatus.attended)),
            _buildMenuItem(colors.errorRed, 'ABSENT',
                () => _applyOverride(date, AttendanceOverrideStatus.absent)),
            _buildMenuItem(colors.accentYellow, 'EXCUSED',
                () => _applyOverride(date, AttendanceOverrideStatus.excused)),
            const Divider(),
            _buildMenuItem(
                colors.primaryBlue, 'UNMARK', () => _removeOverride(date)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(Color color, String text, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
          foregroundColor: AppColors.of(context).textColor,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }

  Future<void> _fetchStudentAttendance(ClassStudent student) async {
    // OLD: Direct Firestore Query
    // NEW: Use Provider with Cache
    final provider = Provider.of<AttendanceProvider>(context, listen: false);

    // This returns instantly if cached
    final historyMap = await provider.fetchStudentAttendanceHistory(
        widget.classInfo.id, student.id);

    final Map<DateTime, AttendanceOverrideStatus> studentAttendance = {};

    historyMap.forEach((dateStr, status) {
      final date = _strToDate(dateStr);
      AttendanceOverrideStatus? overrideStatus;

      if (status == 'present') {
        overrideStatus = AttendanceOverrideStatus.attended;
      } else if (status == 'absent') {
        overrideStatus = AttendanceOverrideStatus.absent;
      } else if (status == 'excused') {
        overrideStatus = AttendanceOverrideStatus.excused;
      }

      if (overrideStatus != null) {
        studentAttendance[date] = overrideStatus;
      }
    });

    if (!mounted) return;
    setState(() {
      _allOverrides[student] = studentAttendance;
    });
  }

  String _dateToStr(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  DateTime _strToDate(String dateStr) {
    final parts = dateStr.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentsProvider = Provider.of<EnrollmentProvider>(context);
    final students = studentsProvider.classStudents;
    final loading = studentsProvider.loading;
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          _buildHeader(context),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Divider(
              color: Colors.grey.shade300,
              thickness: 1,
              height: 1,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildStudentsPanel(context, students, loading),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 3,
                  child: _buildCalendarPanel(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarPanel(BuildContext context) {
    final Map<DateTime, AttendanceOverrideStatus> attendanceForSelectedStudent =
        _selectedStudent == null
            ? <DateTime, AttendanceOverrideStatus>{}
            : _allOverrides[_selectedStudent] ?? {};
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 500,
        child: ClassCalendar(
          classInfo: widget.classInfo,
          studentAttendance: attendanceForSelectedStudent,
          onDateSelected: (date, cellContext) {
            _showOverrideMenu(cellContext, date);
          },
        ),
      ),
    );
  }

  Widget _buildAttendanceModeToggle(BuildContext context) {
    final classProvider = Provider.of<ClassDataProvider>(context);
    final updatedClass = classProvider.classes.firstWhere(
      (c) => c.id == widget.classInfo.id,
      orElse: () => widget.classInfo,
    );
    final currentMode = updatedClass.attendanceMode;

    final modes = ['auto_start', 'manual', 'auto_end'];
    final labels = ['Auto Start', 'Manual', 'Auto End'];

    return ToggleButtons(
      isSelected: modes.map((m) => m == currentMode).toList(),
      onPressed: (index) async {
        final newMode = modes[index];
        if (newMode != currentMode) {
          await classProvider.setClassAttendanceMode(
              widget.classInfo.id, newMode);

          if (newMode != 'manual') {
            await FirebaseFirestore.instance
                .collection('classes')
                .doc(widget.classInfo.id)
                .update({'isManualWindowOpen': false});
            classProvider.updateManualWindowLocally(widget.classInfo.id, false);
          }
        }
      },
      children: labels
          .map((label) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(label),
              ))
          .toList(),
    );
  }

  Future<void> _removeStudentFromClass(
      ClassStudent studentToRemove, List<ClassStudent> students) async {
    // Find enrollment document for this class and student
    final enrollmentQuery = await FirebaseFirestore.instance
        .collection('enrollment')
        .where('classId', isEqualTo: widget.classInfo.id)
        .where('studentUid', isEqualTo: studentToRemove.id)
        .limit(1)
        .get();

    if (enrollmentQuery.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student not found in this class.')),
      );
      return;
    }

    // Delete the enrollment document
    await FirebaseFirestore.instance
        .collection('enrollment')
        .doc(enrollmentQuery.docs.first.id)
        .delete();

    Provider.of<EnrollmentProvider>(context, listen: false)
        .removeFromCache(widget.classInfo.id, studentToRemove.id);
  }

  void _showRemoveStudentConfirmation(
      ClassStudent student, List<ClassStudent> studentList) {
    final AppColorScheme colors = AppColors.of(context);
    showDialog(
      barrierColor: colors.accentTeal.withValues(alpha: 0.65),
      context: context,
      builder: (BuildContext context) {
        return OptionModal(
            title: 'Remove Student',
            content:
                'Are you sure you want to remove ${student.name} from this class? This action cannot be undone.',
            buttons: [
              ModalButtonConfig(
                label: 'Cancel',
                buttonColor: colors.buttonColor,
                onPressed: () {},
              ),
              ModalButtonConfig(
                  label: 'Remove',
                  onPressed: () async {
                    await _removeStudentFromClass(student, studentList);
                    setState(() => _selectedStudent = null);
                  },
                  buttonColor: colors.errorRed),
            ]);
      },
    );
  }

  Widget _buildStudentsPanel(
      BuildContext context, List<ClassStudent> students, bool loading) {
    final AppColorScheme colors = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: LabeledInputField(
                label: 'Students:',
                hintText: 'add student',
                controller: _addStudentController,
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
              mini: true,
              onPressed: () {
                final uid = _addStudentController.text.trim();
                if (uid.isNotEmpty) {
                  _addStudentToClass(uid, students);
                }
              },
              backgroundColor: colors.accentTeal,
              child: Icon(Icons.add, color: colors.whiteColor),
            )
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final bool isSelected = _selectedStudent == student;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedStudent = null;
                          } else {
                            _selectedStudent = student;
                          }
                        });
                        if (!isSelected) {
                          // Schedule fetch after build is complete
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _fetchStudentAttendance(student);
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6.0, horizontal: 8.0),
                        margin: const EdgeInsets.symmetric(vertical: 2.0),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.of(context)
                                  .primaryBlue
                                  .withValues(alpha: 0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: ProfilePictureWidget(
                                name: student.name,
                                imageUrl: student.profilePicture,
                                textLocation: ProfileTextLocation.right,
                                profileShape: ProfileShape.circle,
                                size: 44,
                                fontSize: 16,
                                showEditBadge: false,
                              ),
                            ),
                            if (isSelected)
                              IconButton(
                                icon: Icon(Icons.close, color: colors.errorRed),
                                onPressed: () => _showRemoveStudentConfirmation(
                                    student, students),
                                tooltip: 'Remove Student',
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Download Csv',
          backgroundColor: AppColors.of(context).primaryBlue,
          onPressed: () {
            if (students.isNotEmpty) {
              _generateAndDownloadCsv(students);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No students to export.')),
              );
            }
          },
        )
      ],
    );
  }

  Future<void> _setClassActiveStatus(bool isActive) async {
    await Provider.of<ClassDataProvider>(context, listen: false)
        .setClassActiveStatus(widget.classInfo.id, isActive);
  }

  void _showSetClassStatusModal() {
    final AppColorScheme colors = AppColors.of(context);

    showDialog(
      barrierColor: colors.accentTeal.withValues(alpha: 0.65),
      context: context,
      builder: (BuildContext context) {
        return OptionModal(
          title: 'Set Status',
          content: 'Set the current status of your course.',
          buttons: [
            ModalButtonConfig(
              buttonColor: colors.accentGreen,
              label: 'Active',
              onPressed: () => _setClassActiveStatus(true),
            ),
            ModalButtonConfig(
              buttonColor: colors.errorOrange,
              label: 'Inactive',
              onPressed: () => _setClassActiveStatus(false),
            ),
            ModalButtonConfig(
              buttonColor: colors.errorRed,
              label: 'Delete',
              onPressed: () {},
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    AppColorScheme colors = AppColors.of(context);
    final time =
        '${formatTimeOfDay(widget.classInfo.startTime)} - ${formatTimeOfDay(widget.classInfo.endTime)}';
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: AppColors.of(context).classesTextColorWeb),
          onPressed: widget.onBack,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.classInfo.subject,
                style: AppTextStyles.screentitle(context)
                    .copyWith(fontSize: 32, color: colors.classesTextColorWeb),
              ),
              Text(
                time,
                style: AppTextStyles.plaintext(context),
              ),
            ],
          ),
        ),
        _buildAttendanceModeToggle(context),
        const SizedBox(width: 16),
        InkWell(
          customBorder: const CircleBorder(),
          child: FloatingActionButton(
            backgroundColor: colors.accentYellow,
            onPressed: widget.onSettingsTap,
            child: const Icon(
              Icons.settings,
              color: Colors.black,
              size: 30,
            ),
          ),
        ),
        const SizedBox(width: 6),
        InkWell(
          customBorder: const CircleBorder(),
          child: FloatingActionButton(
            backgroundColor: colors.errorRed,
            onPressed: _showSetClassStatusModal,
            child: const Icon(
              Icons.cancel,
              color: Colors.black,
              size: 30,
            ),
          ),
        ),
      ],
    );
  }
}
