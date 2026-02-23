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

  Future<void> updateProfilePicture(String newProfilePictureUrl) async {
    try {
      print('Updating profile picture in Firestore...');
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      // Update Firestore with timeout
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'profilePicture': newProfilePictureUrl}).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Firestore update timeout');
        },
      );

      print('Firestore updated successfully');
      // Update local state
      profilePicture = newProfilePictureUrl;
      notifyListeners();
      print('Local state updated');
    } catch (e) {
      print('Error updating profile picture: $e');
      print('Error type: ${e.runtimeType}');
      rethrow;
    }
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
