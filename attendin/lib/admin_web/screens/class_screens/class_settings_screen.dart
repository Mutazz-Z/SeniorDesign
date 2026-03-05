import 'package:attendin/admin_web/widgets/day_selector.dart';
import 'package:attendin/common/models/class_info.dart';
import 'package:attendin/common/widgets/labeled_input_field.dart';
import 'package:attendin/common/widgets/primary_button.dart';
import 'package:attendin/common/widgets/time_picker.dart';
import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/theme/app_text_styles.dart';
import 'package:provider/provider.dart';
import 'package:attendin/common/data/class_data_provider.dart';

import 'package:flutter/material.dart';

class SelectedClassSettingsScreen extends StatefulWidget {
  final ClassInfo classInfo;
  final VoidCallback onBack;
  final Function(ClassInfo) onSave;

  const SelectedClassSettingsScreen({
    super.key,
    required this.classInfo,
    required this.onBack,
    required this.onSave,
  });

  @override
  State<SelectedClassSettingsScreen> createState() =>
      _SelectedClassSettingsScreenState();
}

class _SelectedClassSettingsScreenState
    extends State<SelectedClassSettingsScreen> {
  late final TextEditingController _courseNameController;
  late final TextEditingController _locationController;
  late final TextEditingController _attendanceWindowController;

  late Set<int> _selectedDays;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    _courseNameController =
        TextEditingController(text: widget.classInfo.subject);
    _locationController =
        TextEditingController(text: widget.classInfo.location);
    _attendanceWindowController = TextEditingController(
        text: widget.classInfo.attendanceWindowMinutes.toString());
    _selectedDays = widget.classInfo.daysOfWeek.toSet();
    _startTime = widget.classInfo.startTime;
    _endTime = widget.classInfo.endTime;
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _locationController.dispose();
    _attendanceWindowController.dispose();
    super.dispose();
  }

  void _updateStartTime(TimeOfDay newTime) {
    setState(() {
      _startTime = newTime;
    });
  }

  void _updateEndTime(TimeOfDay newTime) {
    setState(() {
      _endTime = newTime;
    });
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
                    color: colors.addClassesHeader),
                onPressed: widget.onBack,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.classInfo.subject,
                      style: AppTextStyles.screentitle(context).copyWith(
                          fontSize: 32, color: colors.addClassesHeader),
                    ),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Course ID:', style: AppTextStyles.fieldtext(context)),
                    const SizedBox(height: 8),
                    Text(widget.classInfo.id,
                        style: AppTextStyles.fieldtext(context)
                            .copyWith(fontStyle: FontStyle.italic)),
                  ],
                ),
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
                        child: CustomTimePicker(
                          label: 'Start Time:',
                          initialTime: _startTime,
                          onTimeChanged: _updateStartTime,
                        )),
                    const SizedBox(width: 24),
                    Expanded(
                        child: CustomTimePicker(
                          label: 'End Time:',
                          initialTime: _endTime,
                          onTimeChanged: _updateEndTime,
                        )),
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
                  backgroundColor: colors.primaryBlue,
                  label: 'Save Changes',
                  onPressed: () async {
                    final provider =
                        Provider.of<ClassDataProvider>(context, listen: false);

                    final updatedClass = ClassInfo(
                      id: widget.classInfo.id,
                      subject: _courseNameController.text,
                      location: _locationController.text,
                      startTime: _startTime,
                      endTime: _endTime,
                      daysOfWeek: _selectedDays.toList(),
                      isActive: widget.classInfo.isActive,
                      adminId: widget.classInfo.adminId,
                      attendanceWindowMinutes:
                          int.tryParse(_attendanceWindowController.text) ?? 15,
                    );

                    await provider.updateClass(updatedClass);
                    widget.onSave(updatedClass);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
