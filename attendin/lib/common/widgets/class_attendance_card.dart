import 'package:attendin/common/models/class_info.dart';
import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/theme/app_text_styles.dart';
import 'package:attendin/common/widgets/primary_button.dart';

import 'package:flutter/material.dart';

class ClassCard extends StatelessWidget {
  final ClassInfo? currentClass;
  final AttendanceStatus? currentAttendanceStatus;
  final VoidCallback? onMarkAttendancePressed;
  final String Function(List<int>) getDaysString;
  final String Function(TimeOfDay) formatTimeOfDay;
  final bool showAttendanceActions;
  final VoidCallback? onInfoIconPressed;
  final GlobalKey?
      markAttendanceButtonKey;

  const ClassCard({
    super.key,
    required this.currentClass,
    this.currentAttendanceStatus,
    this.onMarkAttendancePressed,
    required this.getDaysString,
    required this.formatTimeOfDay,
    this.showAttendanceActions = true,
    this.onInfoIconPressed,
    this.markAttendanceButtonKey,
  });

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: colors.primaryBlue.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (currentClass != null) ...[
            if (showAttendanceActions)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: colors.secondaryBackground,
                  borderRadius: const BorderRadius.all(Radius.circular(25)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Centered content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          currentClass!.subject,
                          style: AppTextStyles.classTitle(context),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on,
                                size: 16, color: colors.fieldTitleColor),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                currentClass!.location,
                                style: AppTextStyles.classLocation(context),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Info icon on the right
                    Positioned(
                      right: 0,
                      child: InkWell(
                        onTap: () {
                          if (currentClass != null && onInfoIconPressed != null) {
                            onInfoIconPressed!();
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(Icons.info_outline, color: colors.textColor),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  Text(
                    currentClass!.subject,
                    style: AppTextStyles.classTitle(context).copyWith(
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    currentClass!.location,
                    style: AppTextStyles.classLocation(context).copyWith(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            const SizedBox(height: 15),
          ] else if (!showAttendanceActions) ...[
            Text(
              'No class info available.',
              style: AppTextStyles.classLocation(context)
                  .copyWith(color: colors.textColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
          ],
          if (showAttendanceActions) ...[
            _buildAttendanceContent(colors),
            const SizedBox(height: 15),
          ],
          // Bottom section: Full-width date/time information
          if (currentClass != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colors.secondaryBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.access_time,
                      size: 18, color: colors.fieldTitleColor),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '${getDaysString(currentClass!.daysOfWeek)} / '
                      '${formatTimeOfDay(currentClass!.startTime)} - ${formatTimeOfDay(currentClass!.endTime)}',
                      style: AppTextStyles.hourlyTime(context),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAttendanceContent(AppColorScheme colors) {
    if (currentAttendanceStatus == null) {
      return const SizedBox.shrink();
    }

    switch (currentAttendanceStatus!) {
      case AttendanceStatus.markAttendance:
        final bool isButtonEnabled = currentClass != null;
        return SizedBox(
          height: 74.0,
          width: double.infinity,
          child: PrimaryButton(
            key:
                markAttendanceButtonKey,
            label: 'Mark Attendance',
            backgroundColor: colors.primaryBlue,
            onPressed: isButtonEnabled && onMarkAttendancePressed != null
                ? onMarkAttendancePressed
                : null,
          ),
        );
      case AttendanceStatus.marking:
        return SizedBox(
          height: 74.0,
          width: double.infinity,
          child: PrimaryButton(
            label: 'Marking Attendance...',
            backgroundColor: colors.primaryBlue,
            onPressed: null, // Disabled while marking
          ),
        );
      case AttendanceStatus.attended:
        return _buildAttendanceStatusCard(
          colors: colors,
          icon: Icons.check_circle_outline,
          message: 'Attended Class',
          color: colors.accentGreen,
        );
      case AttendanceStatus.missed:
        return _buildAttendanceStatusCard(
          colors: colors,
          icon: Icons.cancel_outlined,
          message: 'Missed Class',
          color: colors.errorRed,
        );
      case AttendanceStatus.outOfLocation:
        return _buildAttendanceStatusCard(
          colors: colors,
          icon: Icons.location_off,
          message: 'Out of Location',
          color: colors.errorOrange,
        );
    }
  }

  Widget _buildAttendanceStatusCard({
    required AppColorScheme colors,
    required IconData icon,
    required String message,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 10),
          Text(
            message,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
