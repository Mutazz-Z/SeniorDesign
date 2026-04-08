import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';
import 'dart:typed_data';

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

  Future<void> pickAndSaveProfilePictureBase64() async {
    try {
      final ImagePicker picker = ImagePicker();

      // 1. Open Gallery and FORCE heavy compression
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 250, // Crucial: Keeps the string small!
        maxHeight: 250, // Crucial: Keeps the string small!
        imageQuality: 60,
      );

      if (image == null) return;

      loading = true;
      notifyListeners();

      // 2. Read the compressed image as bytes
      Uint8List imageBytes = await image.readAsBytes();

      // 3. Convert the bytes into a Base64 text string
      String base64String = base64Encode(imageBytes);

      // 4. Format it as a "Data URI" so HTML/Flutter knows it's an image
      String dataUrl = 'data:image/jpeg;base64,$base64String';

      // 5. Save the giant text string to your FREE Firestore database!
      await updateProfilePicture(dataUrl);
    } catch (e) {
      print('Error during Base64 image save: $e');
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
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
