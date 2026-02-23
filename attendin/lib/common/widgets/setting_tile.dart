import 'package:flutter/material.dart';
import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/theme/app_text_styles.dart';

class SettingTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? trailingWidget;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? textColor;

  const SettingTile({
    super.key,
    required this.icon,
    required this.text,
    this.trailingWidget,
    this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 15.0),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    (iconColor ?? colors.fieldTitleColor).withValues(alpha: .2),
              ),
              child: Icon(
                icon,
                color: iconColor ?? colors.fieldTitleColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.classTitle(context).copyWith(
                  fontSize: 18,
                  color: textColor ?? colors.textColor,
                ),
              ),
            ),
            if (trailingWidget != null) trailingWidget!,
          ],
        ),
      ),
    );
  }
}
