import 'package:flutter/material.dart';
import 'package:attendin/common/models/class_info.dart';

//This file contains mock data for a student user, but we should be using firebase currently

// User Information
const String userName = 'John Doe';
const String email = 'johndoe@mail.uc.edu';
const String profilePicture = 'https://i.imgur.com/WuXj5r2.png';

// Class Schedule
final List<ClassInfo> userClasses = [
  const ClassInfo(
    id: "physics2",
    adminId: "test",
    subject: 'Physics II',
    location: 'Braunstein 300',
    startTime: TimeOfDay(hour: 16, minute: 0),
    endTime: TimeOfDay(hour: 17, minute: 0),
    daysOfWeek: [DateTime.monday, DateTime.wednesday, DateTime.friday],
  ),
  const ClassInfo(
    id: "physics3",
    adminId: "test",
    subject: 'Physics III',
    location: 'Braunstein 400',
    startTime: TimeOfDay(hour: 12, minute: 0),
    endTime: TimeOfDay(hour: 13, minute: 0),
    daysOfWeek: [DateTime.monday, DateTime.wednesday, DateTime.friday],
  ),
  const ClassInfo(
    id: "calc1",
    adminId: "test",
    subject: 'Calculus I',
    location: 'Old Main 101',
    startTime: TimeOfDay(hour: 9, minute: 0),
    endTime: TimeOfDay(hour: 10, minute: 0),
    daysOfWeek: [DateTime.tuesday, DateTime.thursday],
  ),
];

// Mock Missed Days
final List<Map<DateTime, ClassInfo>> mockMissedDays = [
  {DateTime(2025, 6, 18): userClasses[0]}, // Physics II missed
  {DateTime(2025, 6, 10): userClasses[1]}, // Calculus I missed
  {DateTime(2025, 7, 10): userClasses[1]}, // Calculus I missed
];
