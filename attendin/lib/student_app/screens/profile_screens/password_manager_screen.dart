import 'package:flutter/material.dart';

import 'package:attendin/student_app/screens/login_screens/forgot_password_screen.dart';
import 'package:attendin/student_app/screens/login_screens/login_screen.dart';
import 'package:attendin/common/theme/app_text_styles.dart';
import 'package:attendin/common/widgets/primary_button.dart';
import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/widgets/labeled_input_field.dart';


class PasswordManagerScreen extends StatefulWidget {
  const PasswordManagerScreen({super.key});

  @override
  State<PasswordManagerScreen> createState() => _PasswordManagerScreenState();
}

class _PasswordManagerScreenState extends State<PasswordManagerScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colors.fieldTitleColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Password Manager',
          style: AppTextStyles.screentitle(context),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Current Password Field
                LabeledInputField(
                  label: 'Current Password',
                  controller: _currentPasswordController,
                  hintText: '************',
                  obscureText: true,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: colors.accentTeal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // New Password Field
                LabeledInputField(
                  label: 'New Password',
                  controller: _newPasswordController,
                  hintText: '************',
                  obscureText: true,
                ),
                const SizedBox(height: 20),

                // Confirm New Password Field
                LabeledInputField(
                  label: 'Confirm New Password',
                  controller: _confirmNewPasswordController,
                  hintText: '************',
                  obscureText: true,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                      label: 'Change Password',
                      backgroundColor: colors.accentTeal,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const LoginScreen()));
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
