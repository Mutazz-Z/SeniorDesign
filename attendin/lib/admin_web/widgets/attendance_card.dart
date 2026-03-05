import 'package:attendin/common/widgets/profile_picture_widget.dart';
import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/models/class_info.dart';
import 'package:flutter/material.dart';

class AttendanceCard extends StatelessWidget {
  final List<ClassStudent> presentStudents;
  final List<ClassStudent> absentStudents;
  final Function(ClassStudent student, String newStatus) onStatusChange;

  const AttendanceCard({
    super.key,
    required this.presentStudents,
    required this.absentStudents,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);

    return Row(
      children: [
        Expanded(
          child: _buildColumn(
            context,
            title: 'Present',
            headerColor: colors.accentGreen,
            students: presentStudents,
            targetStatus: 'present',
            colors: colors,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildColumn(
            context,
            title: 'Absent',
            headerColor: colors.errorRed,
            students: absentStudents,
            targetStatus: 'absent',
            colors: colors,
          ),
        ),
      ],
    );
  }

  Widget _buildColumn(
    BuildContext context, {
    required String title,
    required Color headerColor,
    required List<ClassStudent> students,
    required String targetStatus,
    required AppColorScheme colors,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.secondaryTextColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: headerColor.withValues(alpha: 0.25),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(
              '$title (${students.length})',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: headerColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),

          // Drag Target Area
          Expanded(
            child: DragTarget<ClassStudent>(
              onWillAccept: (data) => true,
              onAccept: (student) {
                onStatusChange(student, targetStatus);
              },
              builder: (context, candidateData, rejectedData) {
                if (students.isEmpty) {
                  return Center(
                    child: Text(
                      "No students",
                      style: TextStyle(color: colors.secondaryTextColor),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: students.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final student = students[index];

                    return Draggable<ClassStudent>(
                      key: GlobalObjectKey(student.id),
                      data: student,
                      feedback: Material(
                        color: Colors.transparent,
                        child: Opacity(
                          opacity: 0.7,
                          child: SizedBox(
                            width: 250,
                            child: _buildStudentTile(context, colors, student),
                          ),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: _buildStudentTile(context, colors, student),
                      ),
                      child: _buildStudentTile(context, colors, student),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentTile(
      BuildContext context, AppColorScheme colors, ClassStudent student) {
    return Container(
      decoration: BoxDecoration(
        color: colors.secondaryBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: SizedBox(
          width: 40,
          height: 40,
          child: ProfilePictureWidget(
            name: student.name,
            imageUrl: student.profilePicture,
            showEditBadge: false,
            size: 40,
            profileShape: ProfileShape.circle,
            textLocation: ProfileTextLocation.right,
            fontSize: 14,
          ),
        ),
        title: Text(
          student.name,
          style: TextStyle(
              color: colors.textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
        dense: true,
      ),
    );
  }
}
