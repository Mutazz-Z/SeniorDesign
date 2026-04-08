import 'package:attendin/common/data/class_data_provider.dart';
import 'package:attendin/common/models/class_info.dart';
import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/theme/app_text_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AttendanceModeToggle extends StatefulWidget {
  final ClassInfo? classInfo;
  final String? initialMode;
  final ValueChanged<String>? onModeChanged;
  final bool showLabel;

  const AttendanceModeToggle({
    super.key,
    this.classInfo,
    this.initialMode,
    this.onModeChanged,
    this.showLabel = false,
  }) : assert(
          classInfo != null || (initialMode != null && onModeChanged != null),
          'Provide classInfo for provider mode, or initialMode + onModeChanged for local mode.',
        );

  @override
  State<AttendanceModeToggle> createState() => _AttendanceModeToggleState();
}

class _AttendanceModeToggleState extends State<AttendanceModeToggle> {
  int _localIndex = 0;

  final List<String> modes = ['auto_start', 'auto_end', 'auto_full', 'manual'];

  final List<String> labels = [
    'Start of Class',
    'End of Class',
    'Start & End',
    'Manual'
  ];

  final double _itemWidth = 110.0;
  final double _height = 45.0;
  final double _padding = 4.0;
  final double _outerRadius = 10.0;
  final double _innerRadius = 8.0;
  final Duration _animDuration = const Duration(milliseconds: 250);

  @override
  void initState() {
    super.initState();
    final initialMode =
        widget.classInfo?.attendanceMode ?? widget.initialMode ?? 'auto_start';
    final initialIndex = modes.indexOf(initialMode);
    _localIndex = initialIndex == -1 ? 0 : initialIndex;
  }

  String _getModeExplanation(int index) {
    switch (index) {
      case 0:
        return 'Automatically opens an attendance window for a set number of minutes at the start of class.';
      case 1:
        return 'Automatically opens an attendance window for a set number of minutes at the end of class.';
      case 2:
        return 'Opens an attendance window at both the start and end of class to verify students are present the entire time.';
      case 3:
        return 'Allows you to manually toggle the attendance window open or closed at any time during the class.';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final selectedChipColor = colors.primaryBlue;
    final selectedTextColor = getReadableTextColor(selectedChipColor);
    final unselectedTextColor = colors.textColor.withValues(alpha: 0.85);
    final trackColor = colors.secondaryBackground;
    final infoBg = colors.cardColor;
    final infoBorder = colors.accentTeal.withValues(alpha: 0.35);
    final infoIconColor = colors.accentTeal;
    final infoTextColor = colors.secondaryTextColor;

    final classProvider = widget.classInfo == null
        ? null
        : Provider.of<ClassDataProvider>(context);

    if (widget.classInfo != null && classProvider != null) {
      final updatedClass = classProvider.classes.firstWhere(
        (c) => c.id == widget.classInfo!.id,
        orElse: () => widget.classInfo!,
      );

      // Sync the visual highlight with the database state if it changes externally
      final providerMode = updatedClass.attendanceMode;
      final providerIndex = modes.indexOf(providerMode);
      if (providerIndex != -1 && providerIndex != _localIndex) {
        _localIndex = providerIndex;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel) ...[
          Text(
            'Attendance Mode:',
            style: AppTextStyles.fieldtext(context),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 2,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Container(
                  height: _height,
                  // --- FIXED: Added + 2.0 to account for the left and right borders ---
                  width: (_itemWidth * modes.length) + 2.0, 
                  decoration: BoxDecoration(
                    color: trackColor,
                    borderRadius: BorderRadius.circular(_outerRadius),
                    border: Border.all(
                      width: 1.0, // Explicitly declaring the 1px width
                      color: colors.textColor.withValues(alpha: 0.12),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(_outerRadius),
                    child: Stack(
                      children: [
                        // The moving highlight block
                        AnimatedPositioned(
                          duration: _animDuration,
                          curve: Curves.fastOutSlowIn,
                          top: _padding,
                          bottom: _padding,
                          left: (_localIndex * _itemWidth) + _padding,
                          width: _itemWidth - (_padding * 2),
                          child: Container(
                            decoration: BoxDecoration(
                              color: selectedChipColor,
                              borderRadius: BorderRadius.circular(_innerRadius),
                            ),
                          ),
                        ),

                        // The static row of text labels
                        Positioned.fill(
                          child: Row(
                            children: List.generate(modes.length, (index) {
                              final isSelected = index == _localIndex;
                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _handleTap(index, classProvider),
                                child: SizedBox(
                                  width: _itemWidth,
                                  child: Center(
                                    child: AnimatedDefaultTextStyle(
                                      duration: _animDuration,
                                      style: TextStyle(
                                        color: isSelected
                                            ? selectedTextColor
                                            : unselectedTextColor,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 13,
                                      ),
                                      textAlign: TextAlign.center,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        child: Text(labels[index], maxLines: 2),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: AnimatedSwitcher(
                duration: _animDuration,
                child: Container(
                  key: ValueKey<int>(_localIndex),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: infoBg,
                    borderRadius: BorderRadius.circular(_outerRadius),
                    border: Border.all(
                      color: infoBorder,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info,
                        color: infoIconColor,
                        size: 20.0,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getModeExplanation(_localIndex),
                          style: TextStyle(
                            fontSize: 12,
                            color: infoTextColor,
                            height: 1.3,
                          ),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleTap(int index, ClassDataProvider? classProvider) {
    if (index == _localIndex) return;

    setState(() {
      _localIndex = index;
    });

    final newMode = modes[index];
    if (widget.classInfo != null && classProvider != null) {
      classProvider.setClassAttendanceMode(widget.classInfo!.id, newMode);

      if (newMode != 'manual') {
        FirebaseFirestore.instance
            .collection('classes')
            .doc(widget.classInfo!.id)
            .update({'isManualWindowOpen': false});
        classProvider.updateManualWindowLocally(widget.classInfo!.id, false);
      }
      return;
    }

    widget.onModeChanged?.call(newMode);
  }
}