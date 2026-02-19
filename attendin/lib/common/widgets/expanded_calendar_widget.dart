import 'package:attendin/common/models/class_info.dart';
import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/theme/app_text_styles.dart';
import 'package:attendin/common/utils/date_time_utils.dart';

import 'package:flutter/material.dart';

class ClassCalendar extends StatefulWidget {
  final ClassInfo classInfo;
  final List<DateTime>? missedDays;
  final List<DateTime>? presentDays;
  final List<DateTime>? excusedDays;
  final Map<DateTime, AttendanceOverrideStatus>? studentAttendance;
  final void Function(DateTime, BuildContext)? onDateSelected;

  const ClassCalendar({
    super.key,
    required this.classInfo,
    this.missedDays,
    this.presentDays,
    this.excusedDays,
    this.studentAttendance,
    this.onDateSelected,
  });

  @override
  State<ClassCalendar> createState() => _ClassCalendarState();
}

class _ClassCalendarState extends State<ClassCalendar> {
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);

    final DateTime firstDayOfMonth =
        DateTime(_focusedDay.year, _focusedDay.month, 1);
    final int firstDayWeekday = firstDayOfMonth.weekday;
    final int daysInMonth =
        DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    final int leadingEmptyCells = firstDayWeekday - 1;

    List<DateTime?> calendarDates = [];
    for (int i = 0; i < leadingEmptyCells; i++) {
      calendarDates.add(null);
    }
    for (int day = 1; day <= daysInMonth; day++) {
      calendarDates.add(DateTime(_focusedDay.year, _focusedDay.month, day));
    }
    while (calendarDates.length % 7 != 0) {
      calendarDates.add(null);
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left, color: colors.fieldTitleColor),
              onPressed: () {
                setState(() {
                  _focusedDay =
                      DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
                });
              },
            ),
            Text(
              '${_focusedDay.monthName.toUpperCase()} ${_focusedDay.year}',
              style: AppTextStyles.plaintext(context)
                  .copyWith(color: colors.fieldTitleColor, fontSize: 20),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right, color: colors.fieldTitleColor),
              onPressed: () {
                setState(() {
                  _focusedDay =
                      DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
                });
              },
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(day,
                            style: AppTextStyles.button(context).copyWith(
                                color: colors.fieldTitleColor, fontSize: 14)),
                      ),
                    ))
                .toList(),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final double cellWidth = constraints.maxWidth / 7;
            final double cellHeight = cellWidth;
            List<Widget> calendarRows = [];
            final DateTime today = DateTime.now();

            for (int i = 0; i < calendarDates.length; i += 7) {
              List<Widget> weekWidgets = [];
              for (int j = 0; j < 7; j++) {
                final int overallIndex = i + j;
                final DateTime? dateForCell = calendarDates[overallIndex];

                if (dateForCell == null) {
                  weekWidgets
                      .add(SizedBox(width: cellWidth, height: cellHeight));
                } else {
                  Color cellColor;
                  Color textColor;
                  final overrideStatus = widget.studentAttendance?[dateForCell];

                  if (overrideStatus != null) {
                    switch (overrideStatus) {
                      case AttendanceOverrideStatus.attended:
                        cellColor = colors.accentGreen;
                        textColor = colors.whiteColor;
                        break;
                      case AttendanceOverrideStatus.absent:
                        cellColor = colors.errorRed;
                        textColor = colors.whiteColor;
                        break;
                      case AttendanceOverrideStatus.excused:
                        cellColor = colors.accentYellow;
                        textColor = colors.textColor;
                        break;
                    }
                  } else if (widget.presentDays != null &&
                      widget.presentDays!
                          .any((d) => isSameDay(d, dateForCell))) {
                    cellColor = colors.accentGreen;
                    textColor = colors.whiteColor;
                  } else if (widget.excusedDays != null &&
                      widget.excusedDays!
                          .any((d) => isSameDay(d, dateForCell))) {
                    cellColor = colors.accentYellow;
                    textColor = colors.textColor;
                  } else if (widget.missedDays != null &&
                      widget.missedDays!
                          .any((d) => isSameDay(d, dateForCell))) {
                    cellColor = colors.errorRed;
                    textColor = colors.whiteColor;
                  } else if (isSameDay(dateForCell, today)) {
                    cellColor = colors.accentTeal;
                    textColor = colors.whiteColor;
                  } else if (isClassDay(dateForCell, widget.classInfo)) {
                    cellColor = colors.primaryBlue;
                    textColor = colors.whiteColor;
                  } else {
                    cellColor = colors.secondaryBackground.withOpacity(0.3);
                    textColor = colors.fieldTitleColor;
                  }

                  weekWidgets.add(
                    Builder(
                      builder: (BuildContext cellContext) {
                        return GestureDetector(
                          onTap: widget.onDateSelected != null
                              ? () => widget.onDateSelected!(
                                  dateForCell, cellContext)
                              : null,
                          behavior: widget.onDateSelected != null
                              ? HitTestBehavior.opaque
                              : HitTestBehavior.translucent,
                          child: Container(
                            width: cellWidth,
                            height: cellHeight,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: cellColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              dateForCell.day.toString(),
                              style: AppTextStyles.plaintext(context)
                                  .copyWith(color: textColor, fontSize: 16),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              }
              calendarRows.add(
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: weekWidgets,
                  ),
                ),
              );
            }
            return Column(children: calendarRows);
          },
        ),
      ],
    );
  }
}

bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
