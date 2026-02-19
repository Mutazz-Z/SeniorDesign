import 'package:flutter/material.dart';
import 'package:attendin/common/theme/app_colors.dart';

class LoginBrandingSection extends StatelessWidget {
  const LoginBrandingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.loginCardWeb,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(100.0),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/WelcomeLogo_Dark.png',
              height: 250,
              width: 250,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}