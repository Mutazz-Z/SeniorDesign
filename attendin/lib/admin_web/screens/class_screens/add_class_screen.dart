import 'package:attendin/admin_web/widgets/day_selector.dart';
import 'package:attendin/common/models/class_info.dart';
import 'package:attendin/common/widgets/labeled_input_field.dart';
import 'package:attendin/common/widgets/primary_button.dart';
import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/theme/app_text_styles.dart';
import 'package:attendin/common/utils/date_time_utils.dart';
import 'package:provider/provider.dart';
import 'package:attendin/common/data/class_data_provider.dart';
import 'package:attendin/common/data/user_data_provider.dart';

import 'package:flutter/material.dart';

class AddClassScreen extends StatefulWidget {
  final ClassInfo? classInfo;
  final VoidCallback onBack;

  const AddClassScreen({
    super.key,
    this.classInfo,
    required this.onBack,
  });

  @override
  State<AddClassScreen> createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  late final TextEditingController _courseNameController;
  late final TextEditingController _courseIdController;
  late final TextEditingController _locationController;
  late final TextEditingController _attendanceWindowController;

  late Set<int> _selectedDays;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  bool get isEditing => widget.classInfo != null;

  @override
  void initState() {
    super.initState();
    _courseNameController =
        TextEditingController(text: widget.classInfo?.subject ?? '');
    _courseIdController =
        TextEditingController(text: widget.classInfo?.id ?? '');
    _locationController =
        TextEditingController(text: widget.classInfo?.location ?? '');
    _attendanceWindowController = TextEditingController(
        text: widget.classInfo?.attendanceWindowMinutes.toString() ?? '15');
    _selectedDays = widget.classInfo?.daysOfWeek.toSet() ?? {};
    _startTime =
        widget.classInfo?.startTime ?? const TimeOfDay(hour: 9, minute: 0);
    _endTime =
        widget.classInfo?.endTime ?? const TimeOfDay(hour: 10, minute: 0);
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _courseIdController.dispose();
    _locationController.dispose();
    _attendanceWindowController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context,
      {required bool isStartTime}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
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
              dayPeriodColor: AppColors.of(context).errorRed,
              cancelButtonStyle: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(AppColors.of(context).textColor),
              ),
              confirmButtonStyle: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(AppColors.of(context).textColor),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new,
                    color: colors.classesTextColorWeb),
                onPressed: widget.onBack,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? widget.classInfo!.subject : 'Add New Class',
                      style: AppTextStyles.screentitle(context).copyWith(
                          fontSize: 32, color: colors.classesTextColorWeb),
                    ),
                    if (isEditing)
                      Text(
                        'Settings',
                        style: AppTextStyles.plaintext(context),
                      ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Divider(
              color: Colors.grey.shade300,
              thickness: 1,
              height: 1,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 24.0),
              children: [
                LabeledInputField(
                    label: 'Course Name:', controller: _courseNameController),
                const SizedBox(height: 24),
                LabeledInputField(
                    label: 'Course ID:', controller: _courseIdController),
                const SizedBox(height: 24),
                LabeledInputField(
                    label: 'Location:', controller: _locationController),
                const SizedBox(height: 24),
                DaySelector(
                  initialSelectedDays: _selectedDays,
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      _selectedDays = newSelection;
                    });
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                        child: _buildTimePicker(context, isStartTime: true)),
                    const SizedBox(width: 24),
                    Expanded(
                        child: _buildTimePicker(context, isStartTime: false)),
                  ],
                ),
                const SizedBox(height: 24),
                LabeledInputField(
                  label: 'Attendance Window (minutes):',
                  controller: _attendanceWindowController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 40),
                PrimaryButton(
                  backgroundColor: colors.accentTeal,
                  label: isEditing ? 'Save Changes' : 'Create Class',
                  onPressed: () async {
                    final provider =
                        Provider.of<ClassDataProvider>(context, listen: false);
                    final userProvider =
                        Provider.of<UserDataProvider>(context, listen: false);

                    final newClass = ClassInfo(
                      id: _courseIdController
                          .text, // Firestore will auto-generate
                      subject: _courseNameController.text,
                      location: _locationController.text,
                      startTime: _startTime,
                      endTime: _endTime,
                      daysOfWeek: _selectedDays.toList(),
                      isActive: true,
                      adminId: userProvider.uid ?? '',
                      attendanceWindowMinutes:
                          int.tryParse(_attendanceWindowController.text) ?? 15,
                    );

                    await provider.addClass(newClass);
                    widget.onBack();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context, {required bool isStartTime}) {
    final colors = AppColors.of(context);
    final time = isStartTime ? _startTime : _endTime;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isStartTime ? 'Start Time:' : 'End Time:',
            style: AppTextStyles.fieldtext(context)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectTime(context, isStartTime: isStartTime),
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
                  formatTimeOfDay(time),
                  style:
                      AppTextStyles.plaintext(context).copyWith(fontSize: 16),
                ),
                Icon(Icons.edit_calendar_outlined,
                    color: colors.secondaryTextColor),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
