import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:attendin/common/models/class_info.dart';

class ClassDataProvider extends ChangeNotifier {
  List<ClassInfo> classes = [];
  bool loading = false;

  // --- NEW: Location Cache Variables ---
  List<String> availableBuildingIds = [];
  bool hasFetchedBuildings = false;

  // --- NEW: Smart Fetch Method for Buildings ---
  Future<void> fetchBuildings({bool forceRefresh = false}) async {
    // If we already have them and don't need a hard refresh, stop!
    if (hasFetchedBuildings && !forceRefresh) {
      return;
    }
    print("Fetched buildings from Firebase");

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('location').get();
      availableBuildingIds = snapshot.docs.map((doc) => doc.id).toList();
      hasFetchedBuildings = true; // Mark cache as full
      notifyListeners();
    } catch (e) {
      print("Error fetching buildings: $e");
    }
  }

  Future<void> fetchClassesByIds(List<String> classIds) async {
    if (classIds.isEmpty) {
      classes = [];
      notifyListeners();
      return;
    }

    loading = true;
    notifyListeners();

    try {
      final classesSnapshot = await FirebaseFirestore.instance
          .collection('classes')
          .where(FieldPath.documentId, whereIn: classIds)
          .get();

      classes = classesSnapshot.docs.map((doc) {
        final data = doc.data();
        return ClassInfo(
          id: doc.id,
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
          attendanceWindowMinutes: data['attendanceWindowMinutes'] ?? 15,
          attendanceMode: data['attendanceMode'] ?? 'auto_start',
          isManualWindowOpen: data['isManualWindowOpen'] ?? false,
          adminId: data['adminId'] ?? '',
        );
      }).toList();
    } catch (e) {
      print("Error fetching specific classes: $e");
    }

    loading = false;
    notifyListeners();
  }

  Future<void> fetchClassesForAdmin(String adminId) async {
    loading = true;
    notifyListeners();

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('classes')
          .where('adminId', isEqualTo: adminId)
          .get();

      classes = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return ClassInfo(
          id: doc.id,
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
          attendanceWindowMinutes: data['attendanceWindowMinutes'] ?? 15,
          attendanceMode: data['attendanceMode'] ?? 'auto_start',
          isManualWindowOpen: data['isManualWindowOpen'] ?? false,
          adminId: data['adminId'] ?? '',
        );
      }).toList();
    } catch (e) {
      print("Error fetching admin classes: $e");
    }

    loading = false;
    notifyListeners();
  }

  // ADD NEW CLASS
  Future<void> addClass(ClassInfo newClass) async {
    loading = true;
    notifyListeners();

    try {
      final docRef =
          FirebaseFirestore.instance.collection('classes').doc(newClass.id);
      // Convert days set (e.g. {1, 3, 5}) to boolean flags
      final days = newClass.daysOfWeek;

      await docRef.set({
        'adminId': newClass.adminId,
        'subject': newClass.subject,
        'location': newClass.location,
        'locationId': newClass.locationId,
        'startTime': newClass.startTime.hour * 60 +
            newClass.startTime.minute, // Store as minutes from midnight
        'endTime': newClass.endTime.hour * 60 + newClass.endTime.minute,
        'is_active': true,
        // Day Flags
        'is_mon': days.contains(DateTime.monday),
        'is_tue': days.contains(DateTime.tuesday),
        'is_wed': days.contains(DateTime.wednesday),
        'is_thu': days.contains(DateTime.thursday),
        'is_fri': days.contains(DateTime.friday),
        'is_sat': days.contains(DateTime.saturday),
        'is_sun': days.contains(DateTime.sunday),
        'attendanceWindowMinutes': newClass.attendanceWindowMinutes,
        'attendanceMode': newClass.attendanceMode,
        'isManualWindowOpen': newClass.isManualWindowOpen,
      });

      // Refresh the list immediately
      await fetchClassesForAdmin(newClass.adminId);
    } catch (e) {
      print("Error adding class: $e");
    }

    loading = false;
    notifyListeners();
  }

  // UPDATE EXISTING CLASS
  Future<void> updateClass(ClassInfo updatedClass) async {
    loading = true;
    notifyListeners();

    try {
      final days = updatedClass.daysOfWeek;

      await FirebaseFirestore.instance
          .collection('classes')
          .doc(updatedClass.id)
          .update({
        'subject': updatedClass.subject,
        'location': updatedClass.location,
        'locationId': updatedClass.locationId,
        'startTime':
            updatedClass.startTime.hour * 60 + updatedClass.startTime.minute,
        'endTime': updatedClass.endTime.hour * 60 + updatedClass.endTime.minute,
        'is_mon': days.contains(DateTime.monday),
        'is_tue': days.contains(DateTime.tuesday),
        'is_wed': days.contains(DateTime.wednesday),
        'is_thu': days.contains(DateTime.thursday),
        'is_fri': days.contains(DateTime.friday),
        'is_sat': days.contains(DateTime.saturday),
        'is_sun': days.contains(DateTime.sunday),
        'attendanceWindowMinutes': updatedClass.attendanceWindowMinutes,
        'attendanceMode': updatedClass.attendanceMode,
        'isManualWindowOpen': updatedClass.isManualWindowOpen,
      });

      // Refresh list
      await fetchClassesForAdmin(updatedClass.adminId);
    } catch (e) {
      print("Error updating class: $e");
    }

    loading = false;
    notifyListeners();
  }

  Future<void> setClassActiveStatus(String classId, bool isActive) async {
    try {
      // Update Firestore
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .update({'is_active': isActive});

      // Update local cache
      final index = classes.indexWhere((c) => c.id == classId);
      if (index != -1) {
        final oldClass = classes[index];
        classes[index] = oldClass.copyWith(isActive: isActive);
        notifyListeners();
      }
    } catch (e) {
      print("Error updating class active status: $e");
    }
  }

  Future<void> setClassAttendanceMode(
      String classId, String attendanceMode) async {
    try {
      // Update Firestore
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .update({'attendanceMode': attendanceMode});

      // Update local cache
      final index = classes.indexWhere((c) => c.id == classId);
      if (index != -1) {
        final oldClass = classes[index];
        classes[index] = oldClass.copyWith(attendanceMode: attendanceMode);
        notifyListeners();
      }
    } catch (e) {
      print("Error updating class attendance mode: $e");
    }
  }

  void updateManualWindowLocally(String classId, bool isOpen) {
    final index = classes.indexWhere((c) => c.id == classId);

    if (index != -1) {
      classes[index] = classes[index].copyWith(isManualWindowOpen: isOpen);
      notifyListeners();
    }
  }

  void clearData() {
    classes = [];
    availableBuildingIds = []; // Reset location cache
    hasFetchedBuildings = false; // Reset fetch flag
    loading = false;
    notifyListeners();
  }
}
