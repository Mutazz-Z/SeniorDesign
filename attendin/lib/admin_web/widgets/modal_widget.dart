import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/theme/app_text_styles.dart';
import 'package:attendin/common/widgets/primary_button.dart';

import 'package:flutter/material.dart';

class ModalButtonConfig {
  final String label;
  final VoidCallback onPressed;
  final Color? buttonColor;

  const ModalButtonConfig({
    required this.label,
    required this.onPressed,
    this.buttonColor,
  });
}

class OptionModal extends StatelessWidget {
  final String title;
  final String content;
  final List<ModalButtonConfig> buttons;

  const OptionModal({
    super.key,
    required this.title,
    required this.content,
    this.buttons = const [],
  });

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);

    return AlertDialog(
      title: Text(
        title,
        style: AppTextStyles.screentitle(context),
      ),
      content: Text(
        content,
        style: AppTextStyles.plaintext(context),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: buttons.map((buttonConfig) {
            return Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: PrimaryButton(
                  label: buttonConfig.label,
                  backgroundColor:
                      buttonConfig.buttonColor ?? colors.primaryBlue,
                  onPressed: () {
                    buttonConfig.onPressed();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      backgroundColor: colors.cardColor,
      surfaceTintColor: colors.accentYellow,
    );
  }
}
