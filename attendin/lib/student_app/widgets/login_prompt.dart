import 'package:attendin/common/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:attendin/common/theme/app_text_styles.dart';

class LogInPrompt extends StatelessWidget {
  final VoidCallback onSignUpTap;

  const LogInPrompt({
    super.key,
    required this.onSignUpTap,
  });

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Already have an account? ",
            style: AppTextStyles.plaintext(context),
          ),
          GestureDetector(
            onTap: onSignUpTap,
            child: Text(
              'Log In',
              style: AppTextStyles.textbuton(context)
                  .copyWith(color: colors.fieldTitleColor),
            ),
          ),
        ],
      ),
    );
  }
}
