import 'package:attendin/common/widgets/profile_picture_widget.dart';
import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/theme/app_text_styles.dart';
import 'package:attendin/common/services/image_service.dart';
import 'package:attendin/student_app/widgets/custom_bottom_nav_bar.dart';
import 'package:attendin/common/widgets/setting_tile.dart';
import 'package:attendin/student_app/widgets/logout_confirmation_modal.dart';
import 'package:attendin/student_app/screens/profile_screens/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:attendin/common/data/user_data_provider.dart';
import 'dart:convert';

import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 0;

  void _handleBottomNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showLogoutConfirmation(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);

    showModalBottomSheet(
      context: context,
      barrierColor: colors.primaryBlue.withValues(alpha: .75),
      backgroundColor: colors.cardColor,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const LogoutConfirmationModal();
      },
    );
  }

// ... inside _ProfileScreenState ...

  void _editProfilePicture() async {
    final imageService = ImageService();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Grab the provider without listening so we can call methods on it
    final userData = Provider.of<UserDataProvider>(context, listen: false);

    try {
      print('Opening image picker...');

      // 1. Pick the image from the gallery
      final imageFile = await imageService.pickImage();

      if (imageFile == null) {
        print('User cancelled image selection');
        return;
      }
      print('Image selected: ${imageFile.name}');

      // 2. Read the file as bytes
      final bytes = await imageFile.readAsBytes();

      // 3. Convert to Base64 using the format your ProfilePictureWidget expects
      // We are forcing it to look like a standard data URI
      final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      // 4. Update the provider to trigger an instant UI rebuild
      userData.updateProfilePicture(base64String);

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Profile picture updated!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e, stackTrace) {
      print('ERROR in _editProfilePicture: $e');
      print('Stack trace: $stackTrace');
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error selecting image: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserDataProvider>(
        context); //Might want to not reload every time

    if (userData.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final AppColorScheme colors = AppColors.of(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colors.secondaryBackground,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 60, bottom: 30),
                child: Column(
                  children: [
                    Text('My Profile',
                        style: AppTextStyles.screentitle(context)),
                    const SizedBox(height: 30),
                    ProfilePictureWidget(
                      profileShape: ProfileShape.circle,
                      imageUrl: userData.profilePicture,
                      showEditBadge: true,
                      onEditPressed: _editProfilePicture,
                      textLocation: ProfileTextLocation.bottom,
                      name: userData.userName,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SettingTile(
                icon: Icons.settings,
                text: 'Settings',
                trailingWidget: Icon(
                  Icons.arrow_forward_ios,
                  color: colors.secondaryTextColor,
                  size: 20,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsScreen()),
                  );
                },
              ),
              SettingTile(
                icon: Icons.logout,
                text: 'Logout',
                trailingWidget: Icon(
                  Icons.arrow_forward_ios,
                  color: colors.secondaryTextColor,
                  size: 20,
                ),
                onTap: () {
                  _showLogoutConfirmation(context);
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onTabTapped: _handleBottomNavItemTapped,
        ),
      ),
    );
  }
}
