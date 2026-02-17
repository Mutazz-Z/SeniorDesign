import 'package:flutter/material.dart';
import 'package:attendin/common/theme/app_text_styles.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final double height;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    required this.backgroundColor,
    this.height = 50,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    if (width != null) {
      return SizedBox(
        height: height,
        width: width,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.button(context),
          ),
        ),
      );
    } else {
      return SizedBox(
        height: height,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 250,
          ),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              label,
              style: AppTextStyles.button(context),
            ),
          ),
        ),
      );
    }
  }
}
