import 'package:attendin/common/theme/app_text_styles.dart';
import 'package:attendin/student_app/widgets/login_prompt.dart';
import 'package:attendin/common/widgets/primary_button.dart';
import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/widgets/labeled_input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:attendin/common/models/class_info.dart';
import 'package:attendin/common/data/class_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:attendin/common/data/user_data_provider.dart';
import 'package:attendin/common/data/enrollment_data_provider.dart';

import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
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
                          'New Account',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colors.accentTeal,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 30),
                  ],
                ),
                const SizedBox(height: 40),

                // Name Field
                LabeledInputField(
                  label: 'Full name',
                  controller: _fullNameController,
                  hintText: 'John Doe',
                  keyboardType: TextInputType.name,
                ),

                const SizedBox(height: 20),

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

                const SizedBox(height: 30),

                // Terms of Use and Privacy Policy
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'By continuing, you agree to \n',
                      style: AppTextStyles.plaintext(context),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Terms of Use',
                          style: AppTextStyles.textbuton(context).copyWith(
                              color: colors.fieldTitleColor,
                              fontSize: 14,
                              decoration: TextDecoration.underline),
                        ),
                        TextSpan(
                          text: ' and ',
                          style: AppTextStyles.plaintext(context),
                        ),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: AppTextStyles.textbuton(context).copyWith(
                              color: colors.fieldTitleColor,
                              fontSize: 14,
                              decoration: TextDecoration.underline),
                        ),
                        TextSpan(
                          text: ' .',
                          style: AppTextStyles.plaintext(context)
                              .copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Sign Up Button
                Center(
                  child: PrimaryButton(
                    label: 'Sign Up',
                    backgroundColor: colors.accentTeal,
                    onPressed: () async {
                      final fullName = _fullNameController.text;
                      final email = _emailController.text;
                      final password = _passwordController.text;
                      print(
                          'Signing up: Full Name: $fullName, Email: $email, Password: $password');
                      try {
                        // Create user in Firebase Auth
                        UserCredential userCredential = await FirebaseAuth
                            .instance
                            .createUserWithEmailAndPassword(
                                email: email, password: password);

                        // Create user document in Firestore
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userCredential.user!.uid)
                            .set({
                          'schoolId': '',
                          'name': fullName,
                          'email': email,
                          'profilePicture': '', // or default URL
                          'role': 'student',
                        });

                        if (context.mounted) {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        }
                      } on FirebaseAuthException catch (e) {
                        print('Sign up error: ${e.code} - ${e.message}');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(e.message ?? 'Sign up failed')),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 40),

                // Log In Text
                LogInPrompt(
                    onSignUpTap: () => Navigator.pushNamed(context, '/login')),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
