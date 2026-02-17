import 'package:flutter/material.dart';
import 'package:attendin/common/models/class_info.dart';
import 'package:intl/intl.dart';

const Map<int, String> dayAbbreviationMap = {
  1: 'Mon',
  2: 'Tue',
  3: 'Wed',
  4: 'Thu',
  5: 'Fri',
  6: 'Sat',
  7: 'Sun',
};

String getDaysString(List<int> days) {
  return days.map((e) => dayAbbreviationMap[e]).whereType<String>().join('-');
}

String formatTimeOfDay(TimeOfDay time) {
  final dt = DateTime(0, 1, 1, time.hour, time.minute);
  final format = DateFormat.jm();
  return format.format(dt);
}

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String minutes = twoDigits(duration.inMinutes.remainder(60));
  String seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$minutes:$seconds";
}

extension DateTimeExtension on DateTime {
  String get monthName {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}

int getWeekdayFromDateTime(DateTime date) {
  return date.weekday;
}

String getFormattedDate(DateTime date) {
  return DateFormat('EEEE, MMMM d, y').format(date);
}

bool isClassDay(DateTime date, ClassInfo classInfo) {
  return classInfo.daysOfWeek.contains(date.weekday);
}

bool isMissedDay(DateTime date, List<DateTime> missedDays) {
  return missedDays.any((missedDate) =>
      missedDate.year == date.year &&
      missedDate.month == date.month &&
      missedDate.day == date.day);
}
