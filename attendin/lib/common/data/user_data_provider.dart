import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDataProvider extends ChangeNotifier {
  String uid = '';
  String schoolId = '';
  String userName = '';
  String profilePicture = '';
  String role = '';
  String email = '';
  bool loading = false;

  Future<void> fetchUserData() async {
    loading = true;
    notifyListeners();

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      loading = false;
      notifyListeners();
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    uid = userDoc.id;
    schoolId = userDoc['schoolId'] ?? '';
    userName = userDoc['name'] ?? '';
    profilePicture = userDoc['profilePicture'] ?? '';
    email = userDoc['email'] ?? '';
    role = userDoc['role'] ?? '';

    loading = false;
    notifyListeners();
  }

  void clearData() {
    uid = '';
    schoolId = '';
    userName = '';
    profilePicture = '';
    role = '';
    email = '';
    loading = false;
    notifyListeners();
  }
}
