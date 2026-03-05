import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

enum AttendanceStatus {
  markAttendance,
  marking,
  attended,
  missed,
  outOfLocation,
}

enum AttendanceOverrideStatus {
  attended,
  absent,
  excused,
}

class ClassInfo {
  final String id; // class_section
  final String adminId; // admin_uid
  final String subject; // class_name
  final String location; // class_location
  final TimeOfDay startTime; // class_start_time_in_minutes
  final TimeOfDay endTime; // class_end_time_in_minutes
  final List<int> daysOfWeek; // class_days_of_week
  final bool isActive; // is_class_active
  final int attendanceWindowMinutes; // attendance_window_minutes

  const ClassInfo({
    required this.id,
    required this.adminId,
    required this.subject,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.daysOfWeek,
    this.isActive = true,
    this.attendanceWindowMinutes = 10,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassInfo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          subject == other.subject &&
          location == other.location &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          listEquals(daysOfWeek, other.daysOfWeek) &&
          attendanceWindowMinutes == other.attendanceWindowMinutes;

  @override
  int get hashCode =>
      id.hashCode ^
      subject.hashCode ^
      location.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      daysOfWeek.hashCode ^
      attendanceWindowMinutes.hashCode;
}

class ClassStudent {
  final String id;
  final String name;
  final String profilePicture;
  final String? schoolId;

  ClassStudent(
      {required this.id,
      required this.name,
      required this.profilePicture,
      this.schoolId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassStudent &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
