import 'package:attendin/admin_web/widgets/day_selector.dart';
import 'package:attendin/admin_web/widgets/attendance_methods.dart';
import 'package:attendin/common/models/class_info.dart';
import 'package:attendin/common/widgets/labeled_input_field.dart';
import 'package:attendin/common/widgets/primary_button.dart';
import 'package:attendin/common/widgets/time_picker.dart';
import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/theme/app_text_styles.dart';
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
  late final TextEditingController _roomNumberController;
  late final TextEditingController _attendanceWindowController;

  late Set<int> _selectedDays;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late String _selectedAttendanceMode;

  String? _selectedBuildingId;
  List<String> _availableBuildingIds = [];
  bool _isLoadingLocations = true;

  bool get isEditing => widget.classInfo != null;

  @override
  void initState() {
    super.initState();
    _courseNameController =
        TextEditingController(text: widget.classInfo?.subject ?? '');
    _courseIdController =
        TextEditingController(text: widget.classInfo?.id ?? '');

    _selectedBuildingId = (widget.classInfo?.locationId.isNotEmpty ?? false)
        ? widget.classInfo!.locationId
        : null;
    final buildingName = _formatBuildingName(_selectedBuildingId ?? '');
    final roomNum =
        (widget.classInfo?.location ?? '').replaceAll(buildingName, '').trim();
    _roomNumberController = TextEditingController(text: roomNum);

    _attendanceWindowController = TextEditingController(
        text: widget.classInfo?.attendanceWindowMinutes.toString() ?? '15');
    _selectedDays = widget.classInfo?.daysOfWeek.toSet() ?? {};
    _startTime =
        widget.classInfo?.startTime ?? const TimeOfDay(hour: 9, minute: 0);
    _endTime =
        widget.classInfo?.endTime ?? const TimeOfDay(hour: 10, minute: 0);
    _selectedAttendanceMode = widget.classInfo?.attendanceMode ?? 'auto_start';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLocations();
    });
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _courseIdController.dispose();
    _roomNumberController.dispose();
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

  Future<void> _fetchLocations() async {
    try {
      final provider = Provider.of<ClassDataProvider>(context, listen: false);
      await provider.fetchBuildings();

      if (!mounted) return;

      setState(() {
        _availableBuildingIds = List.from(provider.availableBuildingIds);
        if (_selectedBuildingId != null &&
            !_availableBuildingIds.contains(_selectedBuildingId)) {
          _availableBuildingIds.add(_selectedBuildingId!);
        }
        _isLoadingLocations = false;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to load buildings.'),
          backgroundColor: AppColors.of(context).errorRed,
        ),
      );
      setState(() => _isLoadingLocations = false);
    }
  }

  String _formatBuildingName(String rawId) {
    if (rawId.isEmpty) return '';
    return rawId.split('_').map((word) {
      if (word.isEmpty) return '';
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isManualMode = _selectedAttendanceMode == 'manual';
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Building:',
                              style: AppTextStyles.fieldtext(context)),
                          const SizedBox(height: 8),
                          _isLoadingLocations
                              ? Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: colors.secondaryBackground,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: const Center(
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  ),
                                )
                              : DropdownMenu<String>(
                                  initialSelection: _selectedBuildingId,
                                  hintText: 'Search building...',
                                  menuHeight: 250,
                                  enableFilter: true,
                                  requestFocusOnTap: true,
                                  expandedInsets: EdgeInsets.zero,
                                  textStyle: AppTextStyles.fieldtext(context),
                                  menuStyle: MenuStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                        colors.cardColor),
                                    elevation: const WidgetStatePropertyAll(8),
                                    shape: WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  inputDecorationTheme: InputDecorationTheme(
                                    filled: true,
                                    fillColor: colors.secondaryBackground,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    hintStyle:
                                        TextStyle(color: Colors.grey.shade500),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                  ),
                                  onSelected: (value) {
                                    FocusScope.of(context).unfocus();
                                    setState(() {
                                      _selectedBuildingId = value;
                                    });
                                  },
                                  dropdownMenuEntries:
                                      _availableBuildingIds.map((id) {
                                    return DropdownMenuEntry<String>(
                                      value: id,
                                      label: _formatBuildingName(id),
                                      style: MenuItemButton.styleFrom(
                                        foregroundColor:
                                            AppTextStyles.fieldtext(context)
                                                .color,
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: LabeledInputField(
                        label: 'Room #:',
                        controller: _roomNumberController,
                      ),
                    ),
                  ],
                ),
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
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: CustomTimePicker(
                        label: 'End Time:',
                        initialTime: _endTime,
                        onTimeChanged: _updateEndTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                AttendanceModeToggle(
                  initialMode: _selectedAttendanceMode,
                  onModeChanged: (mode) {
                    setState(() {
                      _selectedAttendanceMode = mode;
                    });
                  },
                  showLabel: true,
                ),
                const SizedBox(height: 24),
                LabeledInputField(
                  label: 'Attendance Window (minutes):',
                  controller: _attendanceWindowController,
                  keyboardType: TextInputType.number,
                  enabled: !isManualMode,
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

                    if (_selectedBuildingId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Please select a building.'),
                          backgroundColor: AppColors.of(context).errorRed,
                        ),
                      );
                      return;
                    }

                    final buildingName =
                        _formatBuildingName(_selectedBuildingId!);
                    final roomNum = _roomNumberController.text.trim();
                    final fullLocationString = roomNum.isNotEmpty
                        ? '$buildingName $roomNum'
                        : buildingName;

                    final newClass = ClassInfo(
                      id: _courseIdController
                          .text, // Firestore will auto-generate
                      subject: _courseNameController.text,
                      location: fullLocationString,
                      locationId: _selectedBuildingId!,
                      startTime: _startTime,
                      endTime: _endTime,
                      daysOfWeek: _selectedDays.toList(),
                      isActive: true,
                      adminId: userProvider.uid,
                      attendanceWindowMinutes:
                          int.tryParse(_attendanceWindowController.text) ?? 15,
                      attendanceMode: _selectedAttendanceMode,
                      isManualWindowOpen: false,
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
}
