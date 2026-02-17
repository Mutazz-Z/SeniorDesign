import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/theme/app_text_styles.dart';
import 'package:attendin/common/theme/theme_provider.dart';

class ThemeModeDropdown extends StatelessWidget {
  const ThemeModeDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeOption selectedThemeOption =
        ThemeProvider.mapThemeModeToThemeOption(themeProvider.themeMode);

    return Theme(
      data: Theme.of(context).copyWith(
        dropdownMenuTheme: DropdownMenuThemeData(
          menuStyle: MenuStyle(
            backgroundColor: WidgetStateProperty.all(colors.primaryBackground),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
        ),
      ),
      child: DropdownButton<ThemeOption>(
        value: selectedThemeOption,
        icon: Icon(Icons.arrow_drop_down, color: colors.secondaryTextColor),
        underline: const SizedBox(),
        onChanged: (ThemeOption? newValue) {
          if (newValue != null) {
            themeProvider.setThemeMode(
                ThemeProvider.mapThemeOptionToThemeMode(newValue));
          }
        },
        items: ThemeOption.values.map((ThemeOption option) {
          String optionText = option.toString().split('.').last;
          optionText = optionText[0].toUpperCase() + optionText.substring(1);

          return DropdownMenuItem<ThemeOption>(
            value: option,
            child: Text(
              optionText,
              style: AppTextStyles.tagline(context),
            ),
          );
        }).toList(),
      ),
    );
  }
}
