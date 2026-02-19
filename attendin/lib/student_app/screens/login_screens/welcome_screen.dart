import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/theme/app_text_styles.dart';
import 'package:attendin/common/widgets/primary_button.dart';
import 'package:attendin/common/theme/theme_provider.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);
    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);

    // Determine if the app is currently in dark mode based on ThemeProvider's themeMode
    final bool isDarkMode;
    if (themeProvider.themeMode == ThemeMode.system) {
      isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    } else {
      isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    }

    final String logoPath = isDarkMode
        ? 'assets/WelcomeLogo_Dark.png'
        : 'assets/WelcomeLogo_Light.png';

    return Scaffold(
      backgroundColor: colors.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 45.0),
          child: Column(
            children: [
              const Spacer(flex: 2),

              SizedBox(
                height: 230,
                child: Image.asset(logoPath),
              ),

              const Spacer(flex: 1),

              // Tagline & Buttons
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 35),
                    child: Text(
                      'Your digital attendance companion. Mark your presence with confidence.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.tagline(context),
                    ),
                  ),
                  PrimaryButton(
                    label: 'Log In',
                    backgroundColor: colors.buttonColor,
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Sign Up',
                    backgroundColor: colors.accentTeal,
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
