import 'package:attendin/common/theme/app_text_styles.dart';
import 'package:attendin/common/widgets/primary_button.dart';
import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/student_app/widgets/signup_prompt.dart';
import 'package:attendin/common/widgets/labeled_input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:attendin/common/data/user_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:attendin/common/data/class_data_provider.dart';
import 'package:attendin/common/data/enrollment_data_provider.dart';

import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
    return Scaffold(
      backgroundColor: colors.primaryBackground,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 20),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.arrow_back_ios),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Hello!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colors.fieldTitleColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 30),
                  ],
                ),
                const SizedBox(height: 40),

                Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: colors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 40),

                // Email Field
                LabeledInputField(
                  label: 'Email',
                  controller: _emailController,
                  hintText: 'example@example.com',
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 20),

                // Password Field
                LabeledInputField(
                  label: 'Password',
                  controller: _passwordController,
                  hintText: '**********',
                  obscureText: true,
                ),

                // Forgot Password Button (TODO)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgotpassword');
                      // TODO: Handle forgot password
                    },
                    child: Text(
                      'Forgot Password',
                      style: TextStyle(
                        color: colors.accentTeal,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Log in Button
                Center(
                  child: PrimaryButton(
                    label: 'Log In',
                    backgroundColor: colors.buttonColor,
                    onPressed: () async {
                      final email = _emailController.text.trim();
                      final password = _passwordController.text.trim();

                      try {
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                        if (context.mounted) {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        }
                      } on FirebaseAuthException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.message ?? 'Login failed')),
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // 'or' Text
                Center(
                  child: Text(
                    'or',
                    style:
                        AppTextStyles.tagline(context).copyWith(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),

                // Finger Print Button
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: colors.fieldTitleColor.withValues(alpha: .15),
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: colors.fieldTitleColor, width: 3),
                    ),
                    child: Icon(
                      Icons.fingerprint,
                      color: colors.fieldTitleColor,
                      size: 35,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Sign Up Text
                SignUpPrompt(
                    onSignUpTap: () => Navigator.pushNamed(context, '/signup')),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
