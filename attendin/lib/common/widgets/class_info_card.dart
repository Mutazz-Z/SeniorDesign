import 'package:attendin/common/models/class_info.dart';
import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/theme/app_text_styles.dart';
import 'package:attendin/common/utils/date_time_utils.dart';

import 'package:flutter/material.dart';

class ClassInfoCard extends StatelessWidget {
  final ClassInfo classInfo;
  final VoidCallback onTap;
  final Color? color;

  const ClassInfoCard({
    super.key,
    required this.classInfo,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          color: color ?? colors.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 2,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(15),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          classInfo.subject,
                          style: AppTextStyles.classTitle(context).copyWith(
                              fontSize: 22, color: colors.fieldTitleColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 18, color: colors.secondaryTextColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${formatTimeOfDay(classInfo.startTime)} - ${formatTimeOfDay(classInfo.endTime)}',
                          style: AppTextStyles.hourlyTime(context)
                              .copyWith(color: colors.secondaryTextColor),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 18, color: colors.secondaryTextColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          classInfo.location,
                          style: AppTextStyles.classLocation(context)
                              .copyWith(color: colors.secondaryTextColor),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 18, color: colors.secondaryTextColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          getDaysString(classInfo.daysOfWeek),
                          style: AppTextStyles.classLocation(context)
                              .copyWith(color: colors.secondaryTextColor),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
