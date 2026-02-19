import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceProvider extends ChangeNotifier {
  List<String> presentStudentIds = [];
  List<String> absentStudentIds = [];
  int presentCount = 0;
  int totalCount = 0;
  bool loading = true;

  final Map<String, Map<String, String>> _studentHistoryCache = {};

  void clearData() {
    presentStudentIds = [];
    absentStudentIds = [];
    _studentHistoryCache.clear();
    presentCount = 0;
    totalCount = 0;
    loading = false;
    notifyListeners();
  }

  // Fetch attendance for a given class and date
  Future<void> fetchAttendance(String classId, String date) async {
    loading = true;
    notifyListeners();

    final querySnapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .where('classId', isEqualTo: classId)
        .where('date', isEqualTo: date)
        .get();

    presentStudentIds = [];
    absentStudentIds = [];

    for (var doc in querySnapshot.docs) {
      final status = doc['status'] ?? '';
      final studentUid = doc['studentUid'] ?? '';
      if (status == 'present') {
        presentStudentIds.add(studentUid);
      } else if (status == 'absent') {
        absentStudentIds.add(studentUid);
      }
    }
    presentCount = presentStudentIds.length;
    totalCount = presentCount + absentStudentIds.length;

    loading = false;
    notifyListeners();
  }

  Future<Map<String, String>> fetchStudentAttendanceHistory(
      String classId, String studentId) async {
    final cacheKey = "${classId}_${studentId}";

    // 1. Check Cache
    if (_studentHistoryCache.containsKey(cacheKey)) {
      print(
          "Used cached history for studentId: $studentId in classId: $classId");
      return _studentHistoryCache[cacheKey]!;
    }

    // 2. Fetch from Firestore (Last 30 days)
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 30));
    final end = now.add(const Duration(days: 1));

    // Simple date formatting to match Firestore strings
    String dateToStr(DateTime d) =>
        "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

    final startStr = dateToStr(start);
    final endStr = dateToStr(end);

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('attendance')
          .where('classId', isEqualTo: classId)
          .where('studentUid', isEqualTo: studentId)
          .where('date', isGreaterThanOrEqualTo: startStr)
          .where('date', isLessThanOrEqualTo: endStr)
          .get();

      final Map<String, String> history = {};
      for (var doc in querySnapshot.docs) {
        history[doc['date']] = doc['status'];
      }

      // 3. Store in Cache
      _studentHistoryCache[cacheKey] = history;
      return history;
    } catch (e) {
      print("Error fetching history: $e");
      return {};
    }
  }

  // NEW: Update Cache Manually (to keep UI in sync without refetching)
  void updateHistoryCache(
      String classId, String studentId, String date, String? status) {
    final cacheKey = "${classId}_${studentId}";

    // Only update if we have a cache entry for this student
    if (_studentHistoryCache.containsKey(cacheKey)) {
      if (status == null) {
        _studentHistoryCache[cacheKey]!.remove(date);
      } else {
        _studentHistoryCache[cacheKey]![date] = status;
      }
      // We don't necessarily need to notifyListeners here as the UI
      // usually handles the local state update for immediate feedback,
      // but it ensures data consistency.
    }
  }

  Future<void> markPresent(
      String classId, String studentUid, String date) async {
    final String recordId = "${classId}_${studentUid}_$date";

    await FirebaseFirestore.instance
        .collection('attendance')
        .doc(recordId)
        .set({
      'classId': classId,
      'studentUid': studentUid,
      'date': date,
      'status': 'present',
    });
    updateHistoryCache(classId, studentUid, date, 'present');
    notifyListeners();
  }

  Future<void> markAbsent(
      String classId, String studentUid, String date) async {
    final String recordId = "${classId}_${studentUid}_$date";

    await FirebaseFirestore.instance
        .collection('attendance')
        .doc(recordId)
        .set({
      'classId': classId,
      'studentUid': studentUid,
      'date': date,
      'status': 'absent',
    });
    updateHistoryCache(classId, studentUid, date, 'absent');
    notifyListeners();
  }

  Future<String?> checkStudentStatus(
      String classId, String studentUid, String date) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('attendance')
          .where('classId', isEqualTo: classId)
          .where('studentUid', isEqualTo: studentUid)
          .where('date', isEqualTo: date)
          .limit(1) // Stop searching after finding 1 match
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first['status']
            as String?; // Returns "present", "absent", etc.
      }
    } catch (e) {
      print("Error checking student status: $e");
    }
    return null; // No record found (User hasn't marked attendance yet)
  }

  Stream<QuerySnapshot> attendanceStream(String classId, String date) {
    return FirebaseFirestore.instance
        .collection('attendance')
        .where('classId', isEqualTo: classId)
        .where('date', isEqualTo: date)
        .snapshots();
  }
}
