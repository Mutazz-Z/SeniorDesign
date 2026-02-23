import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/theme/app_text_styles.dart';
import 'package:attendin/common/utils/date_time_utils.dart';

import 'package:flutter/material.dart';

class DaySelector extends StatefulWidget {
  final Set<int> initialSelectedDays;
  final Function(Set<int> selectedDays) onSelectionChanged;

  const DaySelector({
    super.key,
    required this.initialSelectedDays,
    required this.onSelectionChanged,
  });

  @override
  State<DaySelector> createState() => _DaySelectorState();
}

class _DaySelectorState extends State<DaySelector> {
  late Set<int> _selectedDays;

  @override
  void initState() {
    super.initState();
    _selectedDays = Set<int>.from(widget.initialSelectedDays);
  }

  @override
  Widget build(BuildContext context) {
    AppColorScheme colors = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Days of the week:', style: AppTextStyles.fieldtext(context)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: dayAbbreviationMap.entries.map((entry) {
            final dayIndex = entry.key;
            final dayAbbreviation = entry.value;
            final isSelected = _selectedDays.contains(dayIndex);

            return FilterChip(
              label: Text(dayAbbreviation),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedDays.add(dayIndex);
                  } else {
                    _selectedDays.remove(dayIndex);
                  }
                  widget.onSelectionChanged(_selectedDays);
                });
              },
              selectedColor: colors.primaryBlue.withValues(alpha: 0.8),
              backgroundColor: colors.cardColor,
              labelStyle: TextStyle(
                color:
                    isSelected ? colors.whiteColor : colors.textColor,
              ),
              checkmarkColor: colors.whiteColor,
            );
          }).toList(),
        ),
      ],
    );
  }
}
