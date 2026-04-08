import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

enum AttendanceStatus {
  markAttendance,
  marking,
  pending,
  attended,
  missed,
  outOfLocation,
}

enum AttendanceOverrideStatus {
  attended,
  absent,
  excused,
  pending,
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
  final String attendanceMode;
  final bool isManualWindowOpen;

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
    this.attendanceMode = 'auto_start',
    this.isManualWindowOpen = false,
  });

  factory ClassInfo.fromMap(Map<String, dynamic> data, String docId) {
    return ClassInfo(
      id: docId,
      adminId: data['adminId'] ?? '',
      subject: data['subject'] ?? '',
      location: data['location'] ?? '',
      locationId: data['locationId'] ?? '',
      startTime: TimeOfDay(
        hour: (data['startTime'] ?? 0) ~/ 60,
        minute: (data['startTime'] ?? 0) % 60,
      ),
      endTime: TimeOfDay(
        hour: (data['endTime'] ?? 0) ~/ 60,
        minute: (data['endTime'] ?? 0) % 60,
      ),
      daysOfWeek: [
        if (data['is_mon'] ?? false) DateTime.monday,
        if (data['is_tue'] ?? false) DateTime.tuesday,
        if (data['is_wed'] ?? false) DateTime.wednesday,
        if (data['is_thu'] ?? false) DateTime.thursday,
        if (data['is_fri'] ?? false) DateTime.friday,
        if (data['is_sat'] ?? false) DateTime.saturday,
        if (data['is_sun'] ?? false) DateTime.sunday,
      ],
      isActive: data['is_active'] ?? true,
      attendanceWindowMinutes: data['attendanceWindowMinutes'] ?? 10,
      attendanceMode: data['attendanceMode'] ?? 'auto_start',
      isManualWindowOpen: data['isManualWindowOpen'] ?? false,
    );
  }

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
          attendanceWindowMinutes == other.attendanceWindowMinutes &&
          attendanceMode == other.attendanceMode &&
          isManualWindowOpen == other.isManualWindowOpen;

  @override
  int get hashCode =>
      id.hashCode ^
      subject.hashCode ^
      location.hashCode ^
      locationId.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      daysOfWeek.hashCode ^
      attendanceWindowMinutes.hashCode ^
      attendanceMode.hashCode ^
      isManualWindowOpen.hashCode;

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
    String? attendanceMode,
    bool? isManualWindowOpen,
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
      attendanceMode: attendanceMode ?? this.attendanceMode,
      isManualWindowOpen: isManualWindowOpen ?? this.isManualWindowOpen,
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
