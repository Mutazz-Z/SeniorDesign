import 'package:attendin/admin_web/widgets/admin_sign_in_form.dart';
import 'package:attendin/admin_web/widgets/log_in_brand_animation.dart';
import 'package:attendin/admin_web/widgets/modal_widget.dart';
import 'package:attendin/common/data/user_data_provider.dart';
import 'package:attendin/common/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:attendin/common/data/class_data_provider.dart';
import 'package:attendin/common/data/enrollment_data_provider.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> handleAdminAuth(
      String email, String password, BuildContext context) async {
    final adminProvider = Provider.of<UserDataProvider>(context, listen: false);
    final classProvider =
        Provider.of<ClassDataProvider>(context, listen: false);
    // final enrollmentProvider =
    //     Provider.of<EnrollmentProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await adminProvider.fetchUserData();
      await classProvider.fetchClassesForAdmin(adminProvider.uid);
      // final activeClassIds = classProvider.classes
      //     .where((c) => c.isActive)
      //     .map((c) => c.id)
      //     .toList();

      // if (activeClassIds.isNotEmpty) {
      //   await enrollmentProvider.prefetchAllClassRosters(activeClassIds);
      // }
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/dashboard');
    } on FirebaseAuthException catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(e.message ?? 'Login failed')),
      );
    }
  }

  // Forgot Password Modal
  void _showContactAdminModal() {
    final AppColorScheme colors = AppColors.of(context);

    showDialog(
      barrierColor: colors.primaryBlue.withValues(alpha: 0.65),
      context: context,
      builder: (BuildContext context) {
        return OptionModal(
          title: 'Forgot Password',
          content: 'Please contact your administrator to reset your password.',
          buttons: [
            ModalButtonConfig(
              label: 'OK',
              onPressed: () {},
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);

    return Scaffold(
      body: Row(
        children: [
          // Left Section (Sign In Form)
          Expanded(
            flex: 1,
            child: Container(
              color: colors.primaryBackground,
              child: Center(
                child: AdminSignInForm(
                  onLoginPressed: (email, password) async {
                    await handleAdminAuth(email, password, context);
                  },
                  onForgotPasswordPressed: _showContactAdminModal,
                ),
              ),
            ),
          ),

          // Right Section (Logo and App Name)
          Expanded(
            flex: 1,
            child: SlideTransition(
              position: _slideAnimation,
              child: const LoginBrandingSection(),
            ),
          ),
        ],
      ),
    );
  }
}
