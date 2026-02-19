import 'package:attendin/common/models/class_info.dart';
import 'package:attendin/common/theme/app_text_styles.dart';
import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/utils/date_time_utils.dart';
import 'package:flutter/material.dart';

class ClassTile extends StatelessWidget {
  final ClassInfo session;
  final int attendancePercentage;
  final bool isHighlighted;

  const ClassTile({
    super.key,
    required this.session,
    required this.attendancePercentage,
    this.isHighlighted = false,
  });

  Widget _buildPercentageCircle(
      BuildContext context, int percentage, Color progressColor) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            value: percentage / 100,
            strokeWidth: 8,
            color: progressColor,
            backgroundColor: progressColor.withAlpha(51),
          ),
        ),
        Text(
          '$percentage%',
          style: AppTextStyles.plaintext(context)
              .copyWith(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);
    final Color progressColor =
        getAttendanceColor(attendancePercentage, colors);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.secondaryBackground,
        borderRadius: isHighlighted
            ? BorderRadius.circular(999.0)
            : BorderRadius.circular(10),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: colors.fieldTitleColor.withAlpha(128),
                  spreadRadius: 2,
                  blurRadius: 15,
                  offset: const Offset(0, 0),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPercentageCircle(context, attendancePercentage, progressColor),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.subject,
                  style: AppTextStyles.plaintext(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${formatTimeOfDay(session.startTime)} - '
                  '${formatTimeOfDay(session.endTime)} · '
                  '${session.location}',
                  style: AppTextStyles.welcomeMessage(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
