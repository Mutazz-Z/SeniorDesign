import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ImageService {
  final ImagePicker _picker = ImagePicker();

  // Pick an image from gallery
  Future<XFile?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  // Upload image to Firebase Storage and return the download URL
  Future<String?> uploadProfilePicture(XFile imageFile) async {
    try {
      print('Starting upload process...');
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('No user logged in');
        return null;
      }

      // Create a reference to the storage location
      final String fileName =
          'profile_${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      print('File name: $fileName');
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child(fileName);

      // Upload the file
      UploadTask uploadTask;
      if (kIsWeb) {
        // For web, use putData with bytes
        print('Web platform detected, reading bytes...');
        final bytes = await imageFile.readAsBytes();
        print('Bytes read: ${bytes.length} bytes');
        uploadTask = storageRef.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        // For mobile, use putFile
        print('Mobile platform detected');
        final File file = File(imageFile.path);
        uploadTask = storageRef.putFile(
          file,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      }

      print('Waiting for upload to complete...');
      // Wait for upload to complete with timeout
      final TaskSnapshot snapshot = await uploadTask.timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception(
              'Upload timeout - check your internet connection and Firebase Storage configuration');
        },
      );
      print('Upload completed!');

      // Get download URL
      print('Getting download URL...');
      final String downloadUrl = await snapshot.ref.getDownloadURL().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Failed to get download URL - timeout');
        },
      );
      print('Download URL obtained: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      print('Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  // Delete old profile picture from storage
  Future<void> deleteOldProfilePicture(String imageUrl) async {
    try {
      if (imageUrl.isEmpty || !imageUrl.contains('firebase')) {
        return;
      }
      final Reference ref = FirebaseStorage.instance.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting old image: $e');
      // Don't throw error, just log it
    }
  }
}
