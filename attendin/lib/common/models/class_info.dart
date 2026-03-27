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
  final String locationId; // class_location_id
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
    required this.locationId,
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
          locationId == other.locationId &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          listEquals(daysOfWeek, other.daysOfWeek) &&
          attendanceWindowMinutes == other.attendanceWindowMinutes;

  @override
  int get hashCode =>
      id.hashCode ^
      subject.hashCode ^
      location.hashCode ^
      locationId.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      daysOfWeek.hashCode ^
      attendanceWindowMinutes.hashCode;

  ClassInfo copyWith({
    String? id,
    String? subject,
    String? location,
    String? locationId,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    List<int>? daysOfWeek,
    bool? isActive,
    int? attendanceWindowMinutes,
    String? adminId,
  }) {
    return ClassInfo(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      location: location ?? this.location,
      locationId: locationId ?? this.locationId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      isActive: isActive ?? this.isActive,
      attendanceWindowMinutes:
          attendanceWindowMinutes ?? this.attendanceWindowMinutes,
      adminId: adminId ?? this.adminId,
    );
  }
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
