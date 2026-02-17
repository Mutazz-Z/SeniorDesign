import 'package:attendin/student_app/screens/profile_screens/password_manager_screen.dart';
import 'package:flutter/material.dart';

import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/theme/app_text_styles.dart';
import 'package:attendin/common/widgets/setting_tile.dart';
import 'package:attendin/student_app/widgets/theme_mode_dropdown.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.secondaryBackground,
      appBar: AppBar(
        backgroundColor: colors.secondaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colors.fieldTitleColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Settings',
          style: AppTextStyles.screentitle(context)
              .copyWith(color: colors.fieldTitleColor),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Theme Mode Setting
            const SettingTile(
              icon: Icons.lightbulb_outline,
              text: 'Theme Mode',
              trailingWidget: ThemeModeDropdown(),
            ),

            // Password Manager Setting
            SettingTile(
              icon: Icons.vpn_key_outlined,
              text: 'Password Manager',
              trailingWidget: Icon(
                Icons.arrow_forward_ios,
                color: colors.secondaryTextColor,
                size: 20,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PasswordManagerScreen()),
                );
              },
            ),
            // Delete Account Setting
            SettingTile(
              icon: Icons.person_remove_outlined,
              text: 'Delete Account',
              trailingWidget: Icon(
                Icons.arrow_forward_ios,
                color: colors.secondaryTextColor,
                size: 20,
              ),
              // onTap: () {
              // },
            ),
          ],
        ),
      ),
    );
  }
}
