import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/theme/theme_provider.dart';
import 'package:attendin/student_app/screens/profile_screens/profile_screen.dart';
import 'package:attendin/student_app/screens/schedule_screens/schedule_screen.dart';
import 'package:attendin/student_app/screens/login_screens/welcome_screen.dart';
import 'package:attendin/student_app/screens/login_screens/login_screen.dart';
import 'package:attendin/student_app/screens/login_screens/signup_screen.dart';
import 'package:attendin/student_app/screens/login_screens/forgot_password_screen.dart';
import 'package:attendin/student_app/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:attendin/common/data/user_data_provider.dart';
import 'package:attendin/common/data/enrollment_data_provider.dart';
import 'package:attendin/common/data/class_data_provider.dart';
import 'package:attendin/common/data/attendance_data_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
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
        ChangeNotifierProvider(create: (_) => EnrollmentProvider()),
        ChangeNotifierProvider(create: (_) => ClassDataProvider()),
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

      home: const AuthWrapper(),

      initialRoute: '/welcome',

      routes: {
        '/welcome': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/forgotpassword': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/schedule': (context) => const ScheduleScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isFetching = false;

  @override
  Widget build(BuildContext context) {
    // 1. Get the Source of Truth (Firebase)
    final firebaseUser = Provider.of<User?>(context);

    // 2. Get the Cached Data (Provider)
    final userProvider = Provider.of<UserDataProvider>(context);

    // Scenario A: No User (Logged Out)
    if (firebaseUser == null) {
      return const WelcomeScreen();
    }

    if (userProvider.uid != firebaseUser.uid && !_isFetching) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchInitialData(firebaseUser.uid);
      });

      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Scenario C: Fetching in progress
    if (_isFetching) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Scenario D: All Good (User matches Data)
    return const HomeScreen();
  }

  Future<void> _fetchInitialData(String newUid) async {
    setState(() {
      _isFetching = true;
    });

    try {
      final userProvider =
          Provider.of<UserDataProvider>(context, listen: false);
      final enrollmentProvider =
          Provider.of<EnrollmentProvider>(context, listen: false);
      final classProvider =
          Provider.of<ClassDataProvider>(context, listen: false);

      userProvider.clearData();
      enrollmentProvider.clearData();
      classProvider.clearData();

      // 2. Fetch new data
      await userProvider.fetchUserData();
      await enrollmentProvider.fetchClassIdsForStudent(newUid);
      await classProvider.fetchClassesByIds(enrollmentProvider.studentClassIds);
    } catch (e) {
      print("Error fetching initial data: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isFetching = false;
        });
      }
    }
  }
}
