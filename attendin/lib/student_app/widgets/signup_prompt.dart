import 'package:flutter/material.dart';
import 'package:attendin/common/theme/app_text_styles.dart';

class SignUpPrompt extends StatelessWidget {
  final VoidCallback onSignUpTap;

  const SignUpPrompt({
    super.key,
    required this.onSignUpTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Don't have an account? ",
            style: AppTextStyles.plaintext(context),
          ),
          GestureDetector(
            onTap: onSignUpTap,
            child: Text(
              'Sign Up',
              style: AppTextStyles.textbuton(context),
            ),
          ),
        ],
      ),
    );
  }
}
