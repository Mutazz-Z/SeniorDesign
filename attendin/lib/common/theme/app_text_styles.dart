import 'package:flutter/material.dart';
import 'package:attendin/common/theme/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle button(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);
    return TextStyle(
      fontFamily: 'LeagueSpartan',
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: colors.whiteColor,
    );
  }

  static TextStyle tagline(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);
    return TextStyle(
      fontFamily: "LeagueSpartan",
      fontSize: 14,
      color: colors.textColor,
      fontWeight: FontWeight.w300,
    );
  }

  static TextStyle plaintext(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);
    return TextStyle(
      fontFamily: "LeagueSpartan",
      fontSize: 14,
      color: colors.textColor,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle textbuton(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);
    return TextStyle(
      fontFamily: "LeagueSpartan",
      fontSize: 16,
      color: colors.accentTeal,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle fieldtext(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);
    return TextStyle(
      fontFamily: "LeagueSpartan",
      fontSize: 20,
      color: colors.fieldTitleColor,
      fontWeight: FontWeight.normal,
    );
  }

  static TextStyle welcomeMessage(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);
    return TextStyle(
      fontSize: 14,
      color: colors.secondaryTextColor,
    );
  }

  static TextStyle userName(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: colors.fieldTitleColor,
    );
  }

  static TextStyle calendarDayNumber(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);
    return TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.normal,
      color: colors.whiteColor,
    );
  }

  static TextStyle calendarDayAbbreviation(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);
    return TextStyle(
      fontSize: 16,
      color: colors.whiteColor,
    );
  }

  static TextStyle calendarDayNumberWhite(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);
    return TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.normal,
      color: colors.textColor,
    );
  }

  static TextStyle calendarDayAbbreviationWhite(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);
    return TextStyle(
      fontSize: 16,
      color: colors.textColor,
    );
  }

  static TextStyle hourlyTime(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);
    return TextStyle(
      fontSize: 14,
      color: colors.secondaryTextColor,
    );
  }

  static TextStyle classTitle(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: colors.fieldTitleColor,
    );
  }

  static TextStyle classLocation(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);
    return TextStyle(
      fontSize: 14,
      color: colors.fieldTitleColor,
    );
  }

  static TextStyle screentitle(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);
    return TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: colors.fieldTitleColor,
    );
  }

  static TextStyle navigationItemUnselected(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.normal,
      color: colors.whiteColor.withValues(alpha: 0.5),
    );
  }

  static TextStyle navigationItemSelected(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: colors.whiteColor,
    );
  }
}
