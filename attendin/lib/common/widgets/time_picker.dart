import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class CustomTimePicker extends StatelessWidget {
  final String label;
  final TimeOfDay initialTime;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const CustomTimePicker({
    super.key,
    required this.label,
    required this.initialTime,
    required this.onTimeChanged,
  });

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.of(context).cardColor,
              hourMinuteTextColor: AppColors.of(context).textColor,
              dialHandColor: AppColors.of(context).accentTeal,
              dialBackgroundColor: AppColors.of(context).secondaryBackground,
              entryModeIconColor: AppColors.of(context).textColor,
              helpTextStyle: AppTextStyles.plaintext(context),
              hourMinuteColor: AppColors.of(context).secondaryBackground,
              dayPeriodTextColor: AppColors.of(context).textColor,
              dayPeriodColor: AppColors.of(context).accentTeal,
              cancelButtonStyle: ButtonStyle(
                foregroundColor:
                    WidgetStatePropertyAll(AppColors.of(context).textColor),
              ),
              confirmButtonStyle: ButtonStyle(
                foregroundColor:
                    WidgetStatePropertyAll(AppColors.of(context).textColor),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onTimeChanged(picked);
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.fieldtext(context)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectTime(context),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              color: colors.secondaryBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTimeOfDay(initialTime),
                  style:
                      AppTextStyles.plaintext(context).copyWith(fontSize: 16),
                ),
                Icon(Icons.access_time, color: colors.textColor),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
