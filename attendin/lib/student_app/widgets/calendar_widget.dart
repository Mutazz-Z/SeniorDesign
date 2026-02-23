import 'package:flutter/material.dart';

import 'package:attendin/common/models/class_info.dart';
import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/theme/app_text_styles.dart';
import 'package:attendin/common/utils/date_time_utils.dart';

class CalendarWidget extends StatelessWidget {
  final List<ClassInfo> userClasses;
  final DateTime now;
  final int todayWeekday;

  const CalendarWidget({
    super.key,
    required this.userClasses,
    required this.now,
    required this.todayWeekday,
  });

  String formatHour(int hour) {
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour < 12 ? 'AM' : 'PM';
    return '$displayHour $period';
  }

  String formatHourMinute(int hour, int minute) {
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final displayMinute = minute.toString().padLeft(2, '0');
    String period;
    if (hour == 0) {
      period = 'AM';
    } else if (hour < 12) {
      period = 'AM';
    } else {
      period = 'PM';
    }
    return '$displayHour:$displayMinute $period';
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);
    
    // Calculate current time position in the timeline
    final rowHeight = 50.0;
    final nowDecimal = now.hour + now.minute / 60.0;
    final currentTimeOffset = (nowDecimal * rowHeight) + 24;

    return Container(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: [
          // Days of the week
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(6, (index) {
                final displayDate = now
                    .subtract(Duration(days: now.weekday - 1))
                    .add(Duration(days: index));
                final dayAbbr =
                    ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'][index];
                final dayNumber = displayDate.day;

                final bool hasClasses =
                    userClasses.any((cls) => cls.daysOfWeek.contains(index));
                final bool isCurrentDay = displayDate.day == now.day &&
                    displayDate.month == now.month &&
                    displayDate.year == now.year;

                Color bgColor;
                TextStyle numStyle;
                TextStyle abbrStyle;

                if (isCurrentDay) {
                  bgColor = colors.accentTeal;
                  numStyle = AppTextStyles.calendarDayNumber(context);
                  abbrStyle = AppTextStyles.calendarDayAbbreviation(context);
                } else if (hasClasses) {
                  bgColor = colors.primaryBlue;
                  numStyle = AppTextStyles.calendarDayNumber(context);
                  abbrStyle = AppTextStyles.calendarDayAbbreviation(context);
                } else {
                  bgColor = colors.cardColor;
                  numStyle = AppTextStyles.calendarDayNumberWhite(context);
                  abbrStyle =
                      AppTextStyles.calendarDayAbbreviationWhite(context);
                }

                return Container(
                  width: 55,
                  height: 80,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: bgColor == colors.primaryBackground
                          ? colors.primaryBlue.withValues(alpha: 0.1)
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayNumber.toString(),
                        style: numStyle,
                      ),
                      Text(
                        dayAbbr,
                        style: abbrStyle,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),

          // Quick Hourly View
          Container(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
            decoration: BoxDecoration(
              color: colors.cardColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Day and Date: ("6 Friday")
                Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    '${now.day} ${getDayNameFromWeekday(now.weekday)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colors.secondaryTextColor,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Timeline grid
                SizedBox(
                  height: 200,
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: SizedBox(
                      width: double.infinity,
                      height: 24 * 50,
                      child: Stack(
                        children: [
                          // Hour labels
                          Column(
                            children: List.generate(24, (index) {
                              return SizedBox(
                                height: 50,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 70,
                                      child: Text(
                                        formatHour(index),
                                        style: AppTextStyles.hourlyTime(context),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color:
                                            colors.secondaryTextColor.withAlpha(50),
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          // Class blocks
                          ...userClasses
                              .where((cls) => cls.daysOfWeek.contains(todayWeekday))
                              .map((cls) {
                            final startHour = cls.startTime.hour;
                            final startMinute = cls.startTime.minute;
                            final endHour = cls.endTime.hour;
                            final endMinute = cls.endTime.minute;
                            final rowHeight = 50.0;

                            final classEndDecimal = endHour + endMinute / 60.0;
                            final classStartDecimal =
                                startHour + startMinute / 60.0;

                            final topOffset =
                                (classStartDecimal * rowHeight) + 24;
                            final blockHeight =
                                (classEndDecimal - classStartDecimal) * rowHeight;

                            return Positioned(
                              left: 70,
                              top: topOffset,
                              right: 0,
                              height: blockHeight,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 2), // smaller margin
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: colors.secondaryBackground,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: colors.primaryBlue.withAlpha(80),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(30),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(cls.subject,
                                        style: AppTextStyles.classTitle(context)),
                                    Text(cls.location,
                                        style:
                                            AppTextStyles.classLocation(context)),
                                    Text(
                                      '${formatHourMinute(cls.startTime.hour, cls.startTime.minute)}'
                                      ' - '
                                      '${formatHourMinute(cls.endTime.hour, cls.endTime.minute)}',
                                      style: AppTextStyles.hourlyTime(context),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          // Current time indicator line
                          Positioned(
                            left: 70,
                            right: 0,
                            top: currentTimeOffset,
                            child: Container(
                              height: 2,
                              color: colors.errorRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
