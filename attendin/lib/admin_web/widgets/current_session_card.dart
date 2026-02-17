import 'package:attendin/common/models/class_info.dart';
import 'package:attendin/common/theme/app_text_styles.dart';
import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/utils/date_time_utils.dart';
import 'package:flutter/material.dart';

class CurrentSessionCard extends StatefulWidget {
  final ClassInfo? sessionInfo;
  final int presentStudents;
  final int totalStudents;
  final Duration timeLeftForAttendance;

  const CurrentSessionCard({
    super.key,
    required this.sessionInfo,
    required this.presentStudents,
    required this.totalStudents,
    required this.timeLeftForAttendance,
  });

  @override
  State<CurrentSessionCard> createState() => _CurrentSessionCardState();
}

class _CurrentSessionCardState extends State<CurrentSessionCard> {
  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);

    double attendanceProgress = 0.0;
    int attendancePercentage = 0;

    if (widget.totalStudents > 0) {
      attendanceProgress = widget.presentStudents / widget.totalStudents;
      attendancePercentage = (attendanceProgress * 100).round();
    }

    final Color progressBarColor =
        getAttendanceColor(attendancePercentage, colors);

    final String timeLeftString = formatDuration(widget.timeLeftForAttendance);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.secondaryBackground,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Session:',
            style: AppTextStyles.plaintext(context)
                .copyWith(color: colors.secondaryTextColor),
          ),
          const SizedBox(height: 8),
          if (widget.sessionInfo != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${widget.sessionInfo!.subject} - ${widget.sessionInfo!.location}',
                        style: AppTextStyles.fieldtext(context),
                      ),
                    ),
                    Text(
                      '$attendancePercentage%',
                      style: AppTextStyles.fieldtext(context),
                    ),
                  ],
                ),
                Text(
                  '${formatTimeOfDay(widget.sessionInfo!.startTime)} - '
                  '${formatTimeOfDay(widget.sessionInfo!.endTime)}',
                  style: AppTextStyles.welcomeMessage(context).copyWith(
                    color: colors.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 15),
                LinearProgressIndicator(
                  value: attendanceProgress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(progressBarColor),
                  borderRadius: BorderRadius.circular(5),
                  minHeight: 8,
                ),
                const SizedBox(height: 15),
                _buildAttendanceStatusChip(context, colors, timeLeftString),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: Text(
                'No active session currently.',
                style: AppTextStyles.fieldtext(context)
                    .copyWith(color: colors.secondaryTextColor),
                textAlign: TextAlign.start,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStatusChip(
      BuildContext context, AppColorScheme colors, String timeLeftString) {
    Color chipColor;
    Color iconColor;
    String message;
    IconData icon;

    if (widget.timeLeftForAttendance.inSeconds > 0) {
      chipColor = colors.accentGreen.withAlpha(26);
      iconColor = colors.accentGreen;
      icon = Icons.access_time;
      message = 'Time left: $timeLeftString';
    } else {
      chipColor = colors.errorRed.withAlpha(26);
      iconColor = colors.errorRed;
      icon = Icons.access_time;
      message = 'Attendance window closed';
    }

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: chipColor,
          borderRadius: BorderRadius.circular(999.0),
          border: Border.all(color: iconColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 5),
            Text(
              message,
              style: AppTextStyles.fieldtext(context).copyWith(
                color: iconColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
