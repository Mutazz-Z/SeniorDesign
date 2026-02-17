import 'package:flutter/material.dart';
import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/theme/app_text_styles.dart';
import 'package:attendin/common/widgets/primary_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LogoutConfirmationModal extends StatelessWidget {
  const LogoutConfirmationModal({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: colors.cardColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(30.0)),
          ),
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Logout',
                style: AppTextStyles.screentitle(context),
              ),
              const SizedBox(height: 10),
              Text(
                'are you sure you want to log out?',
                style: AppTextStyles.tagline(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: 'Cancel',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      backgroundColor: colors.accentTeal,
                      height: 50,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Yes, Logout',
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();

                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/welcome',
                          (route) => false,
                        );
                      },
                      backgroundColor: colors.primaryBlue,
                      height: 50,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
