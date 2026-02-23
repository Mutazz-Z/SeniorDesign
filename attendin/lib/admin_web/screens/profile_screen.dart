import 'package:attendin/admin_web/widgets/modal_widget.dart';
import 'package:attendin/common/data/user_data_provider.dart';
import 'package:attendin/common/services/image_service.dart';
import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/theme/app_text_styles.dart';
import 'package:attendin/common/widgets/profile_picture_widget.dart';
import 'package:attendin/common/widgets/setting_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleEditProfilePicture(BuildContext context) async {
    final imageService = ImageService();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      print('Opening image picker...');
      // Pick image
      final imageFile = await imageService.pickImage();
      if (imageFile == null) {
        // User cancelled
        print('User cancelled image selection');
        return;
      }
      print('Image selected: ${imageFile.name}');

      // TODO: Add image upload logic here

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
              'Image selected: ${imageFile.name}. Upload functionality pending backend implementation.'),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e, stackTrace) {
      print('ERROR in _handleEditProfilePicture: $e');
      print('Stack trace: $stackTrace');
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error selecting image: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);
    final userProvider = Provider.of<UserDataProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: colors.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'Profile',
                style: AppTextStyles.screentitle(context)
                    .copyWith(fontSize: 32, color: colors.profileTextColorWeb),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: ProfilePictureWidget(
                imageUrl: userProvider.profilePicture,
                name: userProvider.userName,
                email: userProvider.email,
                color: colors.profileTextColorWeb,
                profileShape: ProfileShape.roundedSquare,
                showEditBadge: true,
                onEditPressed: () => _handleEditProfilePicture(context),
                alignment: CrossAxisAlignment.start,
                size: 150,
                textLocation: ProfileTextLocation.right,
                fontSize: 24,
              ),
            ),
            const Spacer(),
            SettingTile(
              icon: Icons.logout,
              text: 'Logout',
              iconColor: colors.profileTextColorWeb,
              textColor: colors.profileTextColorWeb,
              onTap: () {
                final AppColorScheme colors = AppColors.of(context);
                showDialog(
                  barrierColor: colors.errorRed.withValues(alpha: 0.65),
                  context: context,
                  builder: (BuildContext context) {
                    return OptionModal(
                      title: 'Logout',
                      content: 'Are you sure you want to log out?',
                      buttons: [
                        ModalButtonConfig(
                          label: 'Cancel',
                          buttonColor: colors.accentTeal,
                          onPressed: () {},
                        ),
                        ModalButtonConfig(
                          label: 'Yes',
                          buttonColor: colors.primaryBlue,
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            if (context.mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/login',
                                (route) => false,
                              );
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
