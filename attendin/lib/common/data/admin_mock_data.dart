import 'package:attendin/common/models/class_info.dart';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';

// Mock Admin Information
const String userName = 'Samantha Green';
const String email = 'samanthagreen@mail.uc.edu';
const String profilePicture = 'https://i.imgur.com/SMuqQpD.png';

class MockStudent {
  final String name;
  final String? imageUrl;

  MockStudent({
    required this.name,
    this.imageUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MockStudent &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode => name.hashCode ^ imageUrl.hashCode;
}

class MockClassSession {
  final ClassInfo classInfo;
  final List<MockStudent> assignedStudents;
  final int averageAttendancePercentage;

  MockClassSession({
    required this.classInfo,
    required this.assignedStudents,
    required this.averageAttendancePercentage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MockClassSession &&
          runtimeType == other.runtimeType &&
          classInfo == other.classInfo &&
          (const DeepCollectionEquality()
              .equals(assignedStudents, other.assignedStudents)) &&
          averageAttendancePercentage == other.averageAttendancePercentage;

  @override
  int get hashCode =>
      classInfo.hashCode ^
      const DeepCollectionEquality().hash(assignedStudents) ^
      averageAttendancePercentage.hashCode;
}

class MockDashboardData {
  static List<MockStudent> allStudents = [
    MockStudent(name: 'Alice Smith'),
    MockStudent(
      name: 'Bob Johnson',
      imageUrl: 'https://i.imgur.com/lZco4NT.png',
    ),
    MockStudent(name: 'Charlie Brown'),
    MockStudent(
      name: 'Diana Prince',
      imageUrl: 'https://i.imgur.com/Ibfrc1x.png',
    ),
    MockStudent(name: 'Eve Adams'),
    MockStudent(name: 'Frank White'),
    MockStudent(name: 'Grace Hopper'),
    MockStudent(name: 'Harry Potter'),
    MockStudent(name: 'Ivy League'),
    MockStudent(name: 'Jack Black'),
  ];

  static List<MockClassSession> allRecurringAdminClassSessions() {
    return [
      MockClassSession(
          classInfo: const ClassInfo(
            id: "physics2",
            adminId: "",
            subject: 'Physics II - Section 1',
            location: 'Braunstein 300',
            startTime: TimeOfDay(hour: 21, minute: 30),
            endTime: TimeOfDay(hour: 23, minute: 02),
            daysOfWeek: [
              DateTime.monday,
              DateTime.wednesday,
              DateTime.friday,
              DateTime.sunday
            ],
            attendanceWindowMinutes: 10,
          ),
          assignedStudents: [
            allStudents[0], // Alice
            allStudents[1], // Bob
            allStudents[2], // Charlie
            allStudents[3], // Diana
            allStudents[4], // Eve
          ],
          averageAttendancePercentage: 50),
      MockClassSession(
          classInfo: const ClassInfo(
            id: "physics2",
            adminId: "",
            subject: 'Physics II - Section 2',
            location: 'Braunstein 300',
            startTime: TimeOfDay(hour: 11, minute: 46),
            endTime: TimeOfDay(hour: 14, minute: 3),
            daysOfWeek: [DateTime.tuesday, DateTime.thursday],
            attendanceWindowMinutes: 5,
          ),
          assignedStudents: [
            allStudents[5], // Frank
            allStudents[6], // Grace
            allStudents[7], // Harry
            allStudents[8], // Ivy
            allStudents[9], // Jack
          ],
          averageAttendancePercentage: 40),
      MockClassSession(
          classInfo: const ClassInfo(
              id: "chem1",
              adminId: "",
              subject: 'Chemistry - Section 1',
              location: 'Swift 433',
              startTime: TimeOfDay(hour: 14, minute: 0),
              endTime: TimeOfDay(hour: 15, minute: 0),
              daysOfWeek: [DateTime.monday, DateTime.wednesday],
              attendanceWindowMinutes: 10),
          assignedStudents: [
            allStudents[0], // Alice
            allStudents[5], // Frank
            allStudents[7], // Harry
          ],
          averageAttendancePercentage: 23),
    ];
  }

  // --- INACTIVE CLASSES ---
  static List<ClassInfo> allInactiveAdminClasses() {
    return [
      const ClassInfo(
        id: "calc1",
        adminId: "",
        subject: 'Calculus I',
        location: 'French Hall 212',
        startTime: TimeOfDay(hour: 9, minute: 30),
        endTime: TimeOfDay(hour: 10, minute: 45),
        daysOfWeek: [DateTime.tuesday, DateTime.thursday],
      ),
      const ClassInfo(
        id: "comp1",
        adminId: "",
        subject: 'English Composition',
        location: 'Langsam Library 501',
        startTime: TimeOfDay(hour: 11, minute: 15),
        endTime: TimeOfDay(hour: 12, minute: 5),
        daysOfWeek: [DateTime.monday, DateTime.wednesday, DateTime.friday],
      ),
      const ClassInfo(
        id: "art",
        adminId: "",
        subject: 'Art History 101',
        location: 'DAAP 5401',
        startTime: TimeOfDay(hour: 14, minute: 0),
        endTime: TimeOfDay(hour: 15, minute: 15),
        daysOfWeek: [DateTime.tuesday, DateTime.thursday],
      ),
      const ClassInfo(
        id: "psych",
        adminId: "",
        subject: 'Intro to Psychology',
        location: 'TBD',
        startTime: TimeOfDay(hour: 13, minute: 0),
        endTime: TimeOfDay(hour: 14, minute: 0),
        daysOfWeek: [],
      ),
    ];
  }

  static MockClassSession? getCurrentClassSession() {
    final DateTime now = DateTime.now();
    final int currentWeekday = now.weekday;
    final int currentTimeMinutes = now.hour * 60 + now.minute;

    for (var session in allRecurringAdminClassSessions()) {
      final classInfo = session.classInfo;

      if (classInfo.daysOfWeek.contains(currentWeekday)) {
        final int sessionStartMinutes =
            classInfo.startTime.hour * 60 + classInfo.startTime.minute;
        final int sessionEndMinutes =
            classInfo.endTime.hour * 60 + classInfo.endTime.minute;

        if (currentTimeMinutes >= sessionStartMinutes &&
            currentTimeMinutes < sessionEndMinutes) {
          return session;
        }
      }
    }
    return null;
  }
}
