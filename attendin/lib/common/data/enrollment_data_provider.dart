import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:attendin/common/models/class_info.dart';

class EnrollmentProvider extends ChangeNotifier {
  List<String> studentClassIds = [];
  List<String> classStudentUids = [];
  List<String> currentClassStudentUids = [];
  List<ClassStudent> classStudents = [];
  String currentClassId = '';
  List<ClassStudent> currentClassStudents = [];
  final Map<String, List<ClassStudent>> _rosterCache = {};

  bool loading = false;

  // Fetch all class IDs for a student
  Future<void> fetchClassIdsForStudent(String studentUid) async {
    loading = true;
    notifyListeners();

    try {
      final enrollmentSnapshot = await FirebaseFirestore.instance
          .collection('enrollment')
          .where('studentUid', isEqualTo: studentUid)
          .get();

      studentClassIds = enrollmentSnapshot.docs
          .map((doc) => doc['classId'] as String)
          .toList();
    } catch (e) {
      print("Error fetching student classes: $e");
    }

    loading = false;
    notifyListeners();
  }

  Future<void> fetchStudentUidsForClass(String classId,
      {bool forceRefresh = false}) async {
    loading = true;

    if (!forceRefresh && _rosterCache.containsKey(classId)) {
      classStudents = _rosterCache[classId]!;
      loading = false;
      notifyListeners();
      print("Used cached roster for $classId");
      return;
    }

    print("Fetching roster from Firestore for classId: $classId");
    notifyListeners();

    try {
      // 1. Get the list of UIDs (Same as before)
      final enrollmentSnapshot = await FirebaseFirestore.instance
          .collection('enrollment')
          .where('classId', isEqualTo: classId)
          .get();

      classStudentUids = enrollmentSnapshot.docs
          .map((doc) => doc['studentUid'] as String)
          .toList();

      if (classStudentUids.isEmpty) {
        classStudents = [];
        _rosterCache[classId] = [];
        loading = false;
        notifyListeners();
        return;
      }

      // --- OPTIMIZATION STARTS HERE ---

      List<ClassStudent> fetchedStudents = [];

      // 2. Chunk the UIDs into groups of 10 (Firestore limit for 'whereIn')
      List<List<String>> chunks = [];
      for (var i = 0; i < classStudentUids.length; i += 10) {
        chunks.add(classStudentUids.sublist(
            i,
            i + 10 > classStudentUids.length
                ? classStudentUids.length
                : i + 10));
      }

      // 3. Fetch each chunk in parallel
      // We create a list of Futures (queries) and wait for all of them to finish
      await Future.wait(chunks.map((chunk) async {
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        for (var doc in userSnapshot.docs) {
          final data = doc.data();
          fetchedStudents.add(ClassStudent(
            id: doc.id,
            name: data['name'] ?? '',
            profilePicture: data['profilePicture'] ?? '',
            schoolId: data['schoolId'],
          ));
        }
      }));

      // --- OPTIMIZATION ENDS HERE ---

      // Update Cache and State
      _rosterCache[classId] = fetchedStudents;
      classStudents = fetchedStudents;
    } catch (e) {
      print("Error fetching roster: $e");
    }

    loading = false;
    notifyListeners();
  }

  // --- FIXED: ADD TO CACHE ---
  void addToCache(String classId, ClassStudent student) {
    // 1. Ensure the list exists in cache
    if (!_rosterCache.containsKey(classId)) {
      _rosterCache[classId] = [];
    }

    final cachedList = _rosterCache[classId]!;

    if (!cachedList.any((s) => s.id == student.id)) {
      cachedList.add(student);
    }

    if (classStudents != cachedList && classStudents.isNotEmpty) {
      if (!classStudents.any((s) => s.id == student.id)) {
        classStudents.add(student);
      }
    } else {
      classStudents = List.from(cachedList);
    }

    if (currentClassId == classId) {
      if (currentClassStudents != cachedList) {
        if (!currentClassStudents.any((s) => s.id == student.id)) {
          currentClassStudents.add(student);
        }
      } else {
        // Same list, just refresh reference for UI
        currentClassStudents = List.from(cachedList);
      }
    }

    notifyListeners();
  }

  void removeFromCache(String classId, String studentId) {
    if (_rosterCache.containsKey(classId)) {
      _rosterCache[classId]!.removeWhere((s) => s.id == studentId);

      // Update UI Lists
      classStudents = List.from(_rosterCache[classId]!);

      if (currentClassId == classId) {
        currentClassStudents = List.from(_rosterCache[classId]!);
      }

      notifyListeners();
    }
  }

  Future<void> fetchStudentUidsForCurrentClass(String classId,
      {bool forceRefresh = false}) async {
    loading = true;
    currentClassId = classId;

    // 1. Check Cache
    if (!forceRefresh && _rosterCache.containsKey(classId)) {
      currentClassStudents = _rosterCache[classId]!;
      loading = false;
      notifyListeners();
      return;
    }

    print("Fetching roster for current class: $classId");
    notifyListeners();

    try {
      // 2. Fetch UIDs from Enrollment collection
      final enrollmentSnapshot = await FirebaseFirestore.instance
          .collection('enrollment')
          .where('classId', isEqualTo: classId)
          .get();

      currentClassStudentUids = enrollmentSnapshot.docs
          .map((doc) => doc['studentUid'] as String)
          .toList();

      if (currentClassStudentUids.isEmpty) {
        currentClassStudents = [];
        _rosterCache[classId] = [];
        loading = false;
        notifyListeners();
        return;
      }

      // --- OPTIMIZATION STARTS HERE ---
      List<ClassStudent> fetchedCurrentStudents = [];

      // 3. Chunk UIDs into groups of 10
      List<List<String>> chunks = [];
      for (var i = 0; i < currentClassStudentUids.length; i += 10) {
        chunks.add(currentClassStudentUids.sublist(
            i,
            i + 10 > currentClassStudentUids.length
                ? currentClassStudentUids.length
                : i + 10));
      }

      // 4. Fetch chunks in parallel
      await Future.wait(chunks.map((chunk) async {
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        for (var doc in userSnapshot.docs) {
          final data = doc.data();
          fetchedCurrentStudents.add(ClassStudent(
            id: doc.id,
            name: data['name'] ?? '',
            profilePicture: data['profilePicture'] ?? '',
            schoolId: data['schoolId'] ?? '',
          ));
        }
      }));

      _rosterCache[classId] = fetchedCurrentStudents;
      currentClassStudents = fetchedCurrentStudents;
    } catch (e) {
      print("Error fetching roster: $e");
    }

    loading = false;
    notifyListeners();
  }

  Future<void> prefetchAllClassRosters(List<String> classIds) async {
    for (final classId in classIds) {
      await fetchStudentUidsForClass(classId);
    }
  }

  List<ClassStudent>? getStudentsForClass(String classId) {
    return _rosterCache[classId];
  }

  void clearData() {
    _rosterCache.clear();
    studentClassIds = [];
    classStudentUids = [];
    currentClassStudentUids = [];
    classStudents = [];
    currentClassStudents = [];
    notifyListeners();
  }
}
