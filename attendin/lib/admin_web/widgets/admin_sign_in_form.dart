import 'package:attendin/admin_web/widgets/labeled_checkbox.dart';
import 'package:attendin/common/widgets/labeled_input_field.dart';
import 'package:attendin/common/widgets/primary_button.dart';
import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class AdminSignInForm extends StatefulWidget {
  final Future<void> Function(String email, String password) onLoginPressed;
  final VoidCallback onForgotPasswordPressed;

  const AdminSignInForm({
    super.key,
    required this.onLoginPressed,
    required this.onForgotPasswordPressed,
  });

  @override
  State<AdminSignInForm> createState() => _AdminSignInFormState();
}

class _AdminSignInFormState extends State<AdminSignInForm> {
  bool _keepMeLoggedIn = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 460,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sign In',
                style: AppTextStyles.screentitle(context),
              ),
              const SizedBox(height: 10),
              Text(
                'Enter your email and password to sign in!',
                style: AppTextStyles.welcomeMessage(context),
              ),
              const SizedBox(height: 40),
              LabeledInputField(
                label: 'Email',
                hintText: 'example@example.com',
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
              ),
              const SizedBox(height: 20),
              LabeledInputField(
                label: 'Password',
                hintText: '*********',
                obscureText: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 15),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 113,
                runSpacing: 10.0,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LabeledCheckbox(
                        label: 'Keep me logged in',
                        value: _keepMeLoggedIn,
                        onChanged: (bool? newValue) {
                          setState(() {
                            _keepMeLoggedIn = newValue ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: widget.onForgotPasswordPressed,
                    child: Text(
                      'Forgot password?',
                      style: AppTextStyles.textbuton(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Center(
                child: PrimaryButton(
                  label: 'Log In',
                  width: double.infinity,
                  backgroundColor: colors.buttonColor,
                  onPressed: () {
                    widget.onLoginPressed(
                      _emailController.text.trim(),
                      _passwordController.text,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
