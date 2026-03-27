import 'package:attendin/common/models/class_info.dart';
import 'package:attendin/common/theme/app_text_styles.dart';
import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/utils/date_time_utils.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class CurrentSessionCard extends StatefulWidget {
  final ClassInfo? sessionInfo;
  final int presentStudents;
  final int totalStudents;
  final ValueChanged<bool>? onManualToggle;

  const CurrentSessionCard({
    super.key,
    required this.sessionInfo,
    required this.presentStudents,
    required this.totalStudents,
    this.onManualToggle,
  });

  @override
  State<CurrentSessionCard> createState() => _CurrentSessionCardState();
}

class _CurrentSessionCardState extends State<CurrentSessionCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Duration _getAutoStartTimeLeft() {
    if (widget.sessionInfo == null) return Duration.zero;
    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
      widget.sessionInfo!.startTime.hour,
      widget.sessionInfo!.startTime.minute,
    );
    final attendanceWindowEnd = start
        .add(Duration(minutes: widget.sessionInfo!.attendanceWindowMinutes));
    final timeLeft = attendanceWindowEnd.difference(now);
    return timeLeft.isNegative ? Duration.zero : timeLeft;
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);

    double attendanceProgress = 0.0;
    int attendancePercentage = 0;

    if (widget.totalStudents > 0) {
      attendanceProgress = widget.presentStudents / widget.totalStudents;
      attendancePercentage = (attendanceProgress * 100).round();
    }

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
                  // If you have a getAttendanceColor function, use it here.
                  // Defaulting to blue for the snippet.
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(colors.primaryBlue),
                  borderRadius: BorderRadius.circular(5),
                  minHeight: 8,
                ),
                const SizedBox(height: 15),

                // Routes to the correct UI based on mode
                _buildAttendanceStatus(
                    context, colors, widget.sessionInfo!.isManualWindowOpen),
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

  // --- NEW ROUTER METHOD ---
  Widget _buildAttendanceStatus(
      BuildContext context, AppColorScheme colors, bool isManualOpen) {
    final mode = widget.sessionInfo!.attendanceMode;

    if (mode == 'manual') {
      return _buildManualToggle(context, colors);
    } else {
      return _buildTimerChip(context, colors, mode);
    }
  }

  Widget _buildManualToggle(BuildContext context, AppColorScheme colors) {
    final now = DateTime.now();
    final end = DateTime(
      now.year,
      now.month,
      now.day,
      widget.sessionInfo!.endTime.hour,
      widget.sessionInfo!.endTime.minute,
    );
    final classEnded = now.isAfter(end);

    // If class ended and window is still open, close it
    if (classEnded && widget.sessionInfo!.isManualWindowOpen) {
      // Only call once per build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.onManualToggle != null) {
          widget.onManualToggle!(false);
        }
      });
    }

    if (classEnded) {
      // Show "Class ended" chip
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: colors.errorRed.withAlpha(26),
            borderRadius: BorderRadius.circular(999.0),
            border: Border.all(color: colors.errorRed, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer_off, size: 16, color: colors.errorRed),
              const SizedBox(width: 5),
              Text(
                'Class ended',
                style: AppTextStyles.fieldtext(context).copyWith(
                  color: colors.errorRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Otherwise, show the normal toggle
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.sessionInfo!.isManualWindowOpen
              ? 'Attendance is OPEN'
              : 'Attendance is CLOSED',
          style: AppTextStyles.fieldtext(context).copyWith(
            color: widget.sessionInfo!.isManualWindowOpen
                ? colors.accentGreen
                : colors.errorRed,
            fontWeight: FontWeight.bold,
          ),
        ),
        Switch(
          value: widget.sessionInfo!.isManualWindowOpen,
          activeColor: colors.accentGreen,
          inactiveThumbColor: colors.errorRed,
          onChanged: (bool newValue) {
            if (widget.onManualToggle != null) {
              widget.onManualToggle!(newValue);
            }
          },
        ),
      ],
    );
  }

// --- AUTOMATIC TIMER UI ---
  Widget _buildTimerChip(
      BuildContext context, AppColorScheme colors, String mode) {
    Color chipColor;
    Color iconColor;
    String message;
    IconData icon;

    if (mode == 'auto_start') {
      final left = _getAutoStartTimeLeft();
      if (left.inSeconds > 0) {
        chipColor = colors.accentGreen.withAlpha(26);
        iconColor = colors.accentGreen;
        message = 'Time left: ${formatDuration(left)}';
        icon = Icons.timer;
      } else {
        chipColor = colors.errorRed.withAlpha(26);
        iconColor = colors.errorRed;
        message = 'Attendance window closed';
        icon = Icons.timer_off;
      }
    } else if (mode == 'auto_end') {
      // Calculate the exact DateTime the class ends and the window opens
      final now = DateTime.now();
      final end = DateTime(
        now.year,
        now.month,
        now.day,
        widget.sessionInfo!.endTime.hour,
        widget.sessionInfo!.endTime.minute,
      );
      final openTime = end.subtract(
          Duration(minutes: widget.sessionInfo!.attendanceWindowMinutes));

      // STATE 1: Class is happening, but the window hasn't opened yet
      if (now.isBefore(openTime)) {
        // Convert back to TimeOfDay to use your existing formatting utility
        final openTimeOfDay =
            TimeOfDay(hour: openTime.hour, minute: openTime.minute);

        chipColor = colors.accentGreen.withAlpha(26);
        iconColor = colors.accentGreen;
        message = 'Opens at ${formatTimeOfDay(openTimeOfDay)}';
        icon = Icons.schedule;
      }
      // STATE 2: The window is actively open
      else if (now.isBefore(end)) {
        final left = end.difference(now);
        chipColor = colors.accentGreen.withAlpha(26);
        iconColor = colors.accentGreen;
        message = 'Time left: ${formatDuration(left)}';
        icon = Icons.timer;
      }
      // STATE 3: The class (and window) has ended
      else {
        chipColor = colors.errorRed.withAlpha(26);
        iconColor = colors.errorRed;
        message = 'Class ended';
        icon = Icons.timer_off;
      }
    } else {
      chipColor = colors.secondaryTextColor.withAlpha(26);
      iconColor = colors.secondaryTextColor;
      message = 'Unknown mode';
      icon = Icons.help_outline;
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
