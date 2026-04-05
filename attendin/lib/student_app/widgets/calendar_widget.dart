import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:attendin/common/models/class_info.dart';
import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/theme/app_text_styles.dart';
import 'package:attendin/common/utils/app_router.dart';
import 'package:attendin/common/utils/date_time_utils.dart';
import 'package:attendin/student_app/screens/schedule_screens/class_details_screen.dart';

class CalendarWidget extends StatefulWidget {
  final List<ClassInfo> userClasses;
  final DateTime now;
  final int todayWeekday;

  const CalendarWidget({
    super.key,
    required this.userClasses,
    required this.now,
    required this.todayWeekday,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  static const double _timelineViewportHeight = 200;
  static const double _rowHeight = 50.0;
  static const double _timelineTopOffset = 24.0;
  static const double _classBlockHorizontalStart = 70.0;

  final ScrollController _timelineScrollController = ScrollController();
  String _lastAutoScrollKey = '';

  @override
  void dispose() {
    _timelineScrollController.dispose();
    super.dispose();
  }

  ({int startHour, int endHourExclusive}) _buildTimelineWindow(
      List<ClassInfo> classesForDay) {
    if (classesForDay.isEmpty) {
      final fallbackStart = (widget.now.hour - 1).clamp(0, 23);
      final fallbackEnd = (widget.now.hour + 2).clamp(1, 24);
      return (
        startHour: fallbackStart,
        endHourExclusive: fallbackEnd > fallbackStart ? fallbackEnd : 24,
      );
    }

    double earliestStart = 24;
    double latestEnd = 0;

    for (final cls in classesForDay) {
      final classStart = cls.startTime.hour + (cls.startTime.minute / 60.0);
      final classEnd = cls.endTime.hour + (cls.endTime.minute / 60.0);

      if (classStart < earliestStart) earliestStart = classStart;
      if (classEnd > latestEnd) latestEnd = classEnd;
    }

    final int startHour = (earliestStart.floor() - 1).clamp(0, 23);
    final int endHourExclusive = (latestEnd.ceil() + 1).clamp(1, 24);

    return (
      startHour: startHour,
      endHourExclusive:
          endHourExclusive > startHour ? endHourExclusive : startHour + 1,
    );
  }

  void _focusCurrentTime({
    required double currentTimeOffset,
    required int startHour,
    required int endHourExclusive,
  }) {
    final key =
        '${widget.now.year}-${widget.now.month}-${widget.now.day}|$startHour-$endHourExclusive';
    if (_lastAutoScrollKey == key) return;
    _lastAutoScrollKey = key;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final positions = _timelineScrollController.positions;
      if (positions.isEmpty) return;

      final position = positions.first;
      if (!position.hasContentDimensions) {
        WidgetsBinding.instance.addPostFrameCallback((__) {
          if (!mounted) return;
          if (_timelineScrollController.positions.isEmpty) return;

          final retryPosition = _timelineScrollController.positions.first;
          if (!retryPosition.hasContentDimensions) return;

          final retryMaxScroll = retryPosition.maxScrollExtent;
          final retryTarget =
              (currentTimeOffset - (_timelineViewportHeight / 2))
                  .clamp(0.0, retryMaxScroll);
          _timelineScrollController.jumpTo(retryTarget);
        });
        return;
      }

      final maxScroll = position.maxScrollExtent;
      final target = (currentTimeOffset - (_timelineViewportHeight / 2))
          .clamp(0.0, maxScroll);
      _timelineScrollController.jumpTo(target);
    });
  }

  String formatHour(int hour) {
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour < 12 ? 'AM' : 'PM';
    return '$displayHour $period';
  }

  String formatHourMinute(int hour, int minute) {
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final displayMinute = minute.toString().padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    return '$displayHour:$displayMinute $period';
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);

    final classesForDay = widget.userClasses
        .where((cls) => cls.daysOfWeek.contains(widget.todayWeekday))
        .toList();

    final timelineWindow = _buildTimelineWindow(classesForDay);
    final timelineStartHour = timelineWindow.startHour;
    final timelineEndHourExclusive = timelineWindow.endHourExclusive;
    final timelineHourCount = timelineEndHourExclusive - timelineStartHour;
    final timelineHeight = timelineHourCount * _rowHeight;
    final nowDecimal = widget.now.hour + widget.now.minute / 60.0;
    final bool isOutsideScheduleWindow = nowDecimal < timelineStartHour ||
        nowDecimal >= timelineEndHourExclusive;
    final currentTimeOffset =
        ((nowDecimal - timelineStartHour) * _rowHeight) + _timelineTopOffset;

    _focusCurrentTime(
      currentTimeOffset: currentTimeOffset,
      startHour: timelineStartHour,
      endHourExclusive: timelineEndHourExclusive,
    );

    return Container(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(6, (index) {
                final displayDate = widget.now
                    .subtract(Duration(days: widget.now.weekday - 1))
                    .add(Duration(days: index));
                final dayAbbr =
                    ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'][index];
                final dayNumber = displayDate.day;

                final bool hasClasses = widget.userClasses
                    .any((cls) => cls.daysOfWeek.contains(index + 1));
                final bool isCurrentDay = displayDate.day == widget.now.day &&
                    displayDate.month == widget.now.month &&
                    displayDate.year == widget.now.year;

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
                      Text(dayNumber.toString(), style: numStyle),
                      Text(dayAbbr, style: abbrStyle),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
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
                    Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        '${widget.now.day} ${getDayNameFromWeekday(widget.now.weekday)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colors.secondaryTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: _timelineViewportHeight,
                      child: SingleChildScrollView(
                        controller: _timelineScrollController,
                        physics: const ClampingScrollPhysics(),
                        child: SizedBox(
                          width: double.infinity,
                          height: timelineHeight,
                          child: Stack(
                            children: [
                              Column(
                                children:
                                    List.generate(timelineHourCount, (index) {
                                  final hour = timelineStartHour + index;
                                  return SizedBox(
                                    height: _rowHeight,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 70,
                                          child: Text(
                                            formatHour(hour),
                                            style: AppTextStyles.hourlyTime(
                                                context),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          child: Divider(
                                            color: colors.secondaryTextColor
                                                .withAlpha(50),
                                            thickness: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                              ...classesForDay.map((cls) {
                                final classEndDecimal = cls.endTime.hour +
                                    cls.endTime.minute / 60.0;
                                final classStartDecimal = cls.startTime.hour +
                                    cls.startTime.minute / 60.0;

                                final topOffset =
                                    ((classStartDecimal - timelineStartHour) *
                                            _rowHeight) +
                                        _timelineTopOffset;
                                final rawBlockHeight =
                                    (classEndDecimal - classStartDecimal) *
                                        _rowHeight;
                                final blockHeight = rawBlockHeight < _rowHeight
                                    ? _rowHeight
                                    : rawBlockHeight;
                                final bool showCompactContent =
                                    blockHeight < 82;

                                return Positioned(
                                  left: _classBlockHorizontalStart,
                                  top: topOffset,
                                  right: 0,
                                  height: blockHeight,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        customFadePageRoute(
                                          ClassDetailScreen(classInfo: cls),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 2),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: colors.secondaryBackground,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color:
                                              colors.primaryBlue.withAlpha(80),
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
                                      child: showCompactContent
                                          ? Align(
                                              alignment: Alignment.centerLeft,
                                              child: LayoutBuilder(
                                                builder:
                                                    (context, constraints) {
                                                  final timeText =
                                                      '${formatHourMinute(cls.startTime.hour, cls.startTime.minute)} - ${formatHourMinute(cls.endTime.hour, cls.endTime.minute)}';
                                                  final timePainter =
                                                      TextPainter(
                                                    text: TextSpan(
                                                      text: timeText,
                                                      style: AppTextStyles
                                                          .hourlyTime(context),
                                                    ),
                                                    maxLines: 1,
                                                    textDirection:
                                                        TextDirection.ltr,
                                                  )..layout();

                                                  final titleMaxWidth =
                                                      (constraints.maxWidth -
                                                              timePainter
                                                                  .width -
                                                              8)
                                                          .clamp(
                                                              0.0,
                                                              constraints
                                                                  .maxWidth);
                                                  return Row(
                                                    children: [
                                                      SizedBox(
                                                        width: titleMaxWidth,
                                                        child: Text(
                                                          cls.subject,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: AppTextStyles
                                                              .classTitle(
                                                                  context),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        timeText,
                                                        maxLines: 1,
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: AppTextStyles
                                                            .hourlyTime(
                                                                context),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            )
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  cls.subject,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      AppTextStyles.classTitle(
                                                          context),
                                                ),
                                                Text(
                                                  cls.location,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: AppTextStyles
                                                      .classLocation(context),
                                                ),
                                                Text(
                                                  '${formatHourMinute(cls.startTime.hour, cls.startTime.minute)} - ${formatHourMinute(cls.endTime.hour, cls.endTime.minute)}',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      AppTextStyles.hourlyTime(
                                                          context),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                );
                              }),
                              Positioned(
                                left: _classBlockHorizontalStart,
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
                    ),
                  ],
                ),
              ),
              if (classesForDay.isEmpty)
                Positioned.fill(
                  child: AbsorbPointer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: Container(
                          color: Colors.grey.withAlpha(120),
                          alignment: Alignment.center,
                          child: Text(
                            'No scheduled classes',
                            style: AppTextStyles.classTitle(context).copyWith(
                              color: colors.textColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
