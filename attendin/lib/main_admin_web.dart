import 'package:attendin/admin_web/screens/layout.dart';
import 'package:attendin/common/data/attendance_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Auth

import 'package:attendin/admin_web/screens/login_screen.dart';
import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/theme/theme_provider.dart';
import 'package:attendin/common/data/class_data_provider.dart';
import 'package:attendin/common/data/user_data_provider.dart';
import 'package:attendin/common/data/enrollment_data_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        StreamProvider<User?>(
          create: (_) => FirebaseAuth.instance.authStateChanges(),
          initialData: null,
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserDataProvider()),
        ChangeNotifierProvider(create: (_) => ClassDataProvider()),
        ChangeNotifierProvider(create: (_) => EnrollmentProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'AttendIn',
      debugShowCheckedModeBanner: false,

      // --- Light Theme Definition ---
      theme: ThemeData(
        fontFamily: 'LeagueSpartan',
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.indigo,
        ).copyWith(
          brightness: Brightness.light,
          primary: AppColors.lightColorScheme.primaryBlue,
          secondary: AppColors.lightColorScheme.accentTeal,
          surface: AppColors.lightColorScheme.primaryBackground,
          error: AppColors.lightColorScheme.errorRed,
          onPrimary: AppColors.lightColorScheme.textColor,
          onSecondary: AppColors.lightColorScheme.textColor,
          onSurface: AppColors.lightColorScheme.textColor,
          onError: AppColors.lightColorScheme.primaryBackground,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.lightColorScheme.primaryBlue,
          foregroundColor: AppColors.lightColorScheme.textColor,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: AppColors.lightColorScheme.textColor),
          bodyMedium: TextStyle(color: AppColors.lightColorScheme.textColor),
        ),
        scaffoldBackgroundColor: AppColors.lightColorScheme.primaryBackground,
      ),

      // --- Dark Theme Definition ---
      darkTheme: ThemeData(
        fontFamily: 'LeagueSpartan',
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blueGrey,
        ).copyWith(
          brightness: Brightness.dark,
          primary: AppColors.darkColorScheme.primaryBlue,
          secondary: AppColors.darkColorScheme.accentTeal,
          surface: AppColors.darkColorScheme.primaryBackground,
          error: AppColors.darkColorScheme.errorRed,
          onPrimary: AppColors.darkColorScheme.textColor,
          onSecondary: AppColors.darkColorScheme.textColor,
          onSurface: AppColors.darkColorScheme.textColor,
          onError: AppColors.darkColorScheme.primaryBackground,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.darkColorScheme.primaryBlue,
          foregroundColor: AppColors.darkColorScheme.textColor,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: AppColors.darkColorScheme.textColor),
          bodyMedium: TextStyle(color: AppColors.darkColorScheme.textColor),
        ),
        scaffoldBackgroundColor: AppColors.darkColorScheme.primaryBackground,
      ),

      themeMode: themeProvider.themeMode,

      home: const AdminAuthWrapper(),

      routes: {
        '/login': (context) => const AdminLoginScreen(),
        '/dashboard': (context) => const LayoutScreen(),
      },
    );
  }
}

class AdminAuthWrapper extends StatefulWidget {
  const AdminAuthWrapper({super.key});

  @override
  State<AdminAuthWrapper> createState() => _AdminAuthWrapperState();
}

class _AdminAuthWrapperState extends State<AdminAuthWrapper> {
  bool _isFetching = false;

  @override
  Widget build(BuildContext context) {
    final firebaseUser = Provider.of<User?>(context);
    final userProvider = Provider.of<UserDataProvider>(context);

    // Scenario A: Logged Out
    if (firebaseUser == null) {
      return const AdminLoginScreen();
    }

    // Scenario B: Logged In but Data Stale (Browser Refresh)
    if (userProvider.uid != firebaseUser.uid && !_isFetching) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchAdminData(firebaseUser.uid);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Scenario C: Loading
    if (_isFetching) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Scenario D: Ready
    return const LayoutScreen();
  }

  Future<void> _fetchAdminData(String uid) async {
    setState(() {
      _isFetching = true;
    });

    try {
      final userProvider =
          Provider.of<UserDataProvider>(context, listen: false);
      final classProvider =
          Provider.of<ClassDataProvider>(context, listen: false);

      // 1. Fetch Admin Profile
      await userProvider.fetchUserData();

      // 2. Fetch ONLY this Admin's classes
      // (This avoids downloading 1000 classes from other professors)
      await classProvider.fetchClassesForAdmin(uid);
    } catch (e) {
      print("Admin Data Fetch Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isFetching = false;
        });
      }
    }
  }
}
