import 'package:flutter/material.dart';

class AppColorScheme {
  final Color primaryBlue;
  final Color accentTeal;
  final Color secondaryBackground;
  final Color accentGreen;
  final Color accentYellow;
  final Color errorRed;
  final Color primaryBackground;
  final Color textColor;
  final Color whiteColor;
  final Color errorOrange;
  final Color secondaryTextColor;
  final Color cardColor;
  final Color buttonColor;
  final Color fieldTitleColor;
  final Color loginCardWeb;
  final Color classesTextColorWeb;
  final Color addClassesHeader;
  final Color profileTextColorWeb;

  const AppColorScheme({
    required this.primaryBlue,
    required this.accentTeal,
    required this.secondaryBackground,
    required this.accentGreen,
    required this.accentYellow,
    required this.errorRed,
    required this.primaryBackground,
    required this.textColor,
    required this.whiteColor,
    required this.errorOrange,
    required this.secondaryTextColor,
    required this.cardColor,
    required this.buttonColor,
    required this.fieldTitleColor,
    required this.loginCardWeb,
    required this.classesTextColorWeb,
    required this.addClassesHeader,
    required this.profileTextColorWeb,
  });
}

class AppColors {
  // Light mode colors
  static const AppColorScheme lightColorScheme = AppColorScheme(
    primaryBlue: Color.fromARGB(255, 8, 20, 100),
    accentTeal: Color.fromARGB(255, 22, 194, 184),
    secondaryBackground: Color.fromARGB(255, 230, 235, 251),
    accentGreen: Color.fromARGB(255, 101, 116, 58),
    accentYellow: Color.fromARGB(255, 253, 232, 76),
    errorRed: Color.fromARGB(255, 195, 65, 63),
    primaryBackground: Color.fromARGB(255, 255, 255, 255),
    textColor: Color.fromARGB(255, 7, 7, 7),
    whiteColor: Colors.white,
    errorOrange: Colors.orange,
    secondaryTextColor: Color(0xFF616161),
    cardColor: Colors.white,
    buttonColor: Color.fromARGB(255, 8, 20, 100),
    fieldTitleColor: Color.fromARGB(255, 8, 20, 100),
    loginCardWeb: Color.fromARGB(255, 8, 20, 100),
    classesTextColorWeb: Color.fromARGB(255, 22, 194, 184),
    addClassesHeader: Colors.black,
    profileTextColorWeb: Color.fromARGB(255, 195, 65, 63),
  );

  // Dark mode colors
  static const AppColorScheme darkColorScheme = AppColorScheme(
    primaryBlue: Color.fromARGB(255, 8, 20, 100),
    accentTeal: Color.fromARGB(255, 22, 194, 184),
    secondaryBackground: Colors.black,
    accentGreen: Color.fromARGB(255, 150, 170, 100),
    accentYellow: Color.fromARGB(255, 255, 240, 150),
    errorRed: Color.fromARGB(255, 255, 100, 100),
    primaryBackground: Color.fromARGB(255, 8, 20, 100),
    textColor: Color.fromARGB(255, 255, 255, 255),
    whiteColor: Color.fromARGB(255, 255, 255, 255),
    errorOrange: Colors.deepOrangeAccent,
    secondaryTextColor: Color.fromARGB(255, 255, 255, 255),
    cardColor: Color.fromARGB(255, 53, 58, 89),
    buttonColor: Color.fromARGB(255, 53, 58, 89),
    fieldTitleColor: Colors.white,
    loginCardWeb: Colors.black,
    classesTextColorWeb: Color.fromARGB(255, 255, 255, 255),
    addClassesHeader: Color.fromARGB(255, 253, 232, 76),
    profileTextColorWeb: Color.fromARGB(255, 255, 255, 255),
  );

  static AppColorScheme of(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? darkColorScheme : lightColorScheme;
  }
}

Color getAttendanceColor(int percentage, AppColorScheme colors) {
  if (percentage > 70) {
    return colors.accentGreen;
  } else if (percentage >= 50) {
    return colors.errorOrange;
  } else {
    return colors.errorRed;
  }
}
