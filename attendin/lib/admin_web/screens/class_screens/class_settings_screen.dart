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
  late final TextEditingController _roomNumberController;
  late final TextEditingController _attendanceWindowController;

  late Set<int> _selectedDays;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  String? _selectedBuildingId;
  List<String> _availableBuildingIds = [];
  bool _isLoadingLocations = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _courseNameController =
        TextEditingController(text: widget.classInfo.subject);
    _attendanceWindowController = TextEditingController(
        text: widget.classInfo.attendanceWindowMinutes.toString());
    _selectedDays = widget.classInfo.daysOfWeek.toSet();
    _startTime = widget.classInfo.startTime;
    _endTime = widget.classInfo.endTime;
    _selectedBuildingId = widget.classInfo.locationId.isNotEmpty
        ? widget.classInfo.locationId
        : null;

    String buildingName = _formatBuildingName(_selectedBuildingId ?? "");
    String roomNum =
        widget.classInfo.location.replaceAll(buildingName, '').trim();
    _roomNumberController = TextEditingController(text: roomNum);

    // --- NEW: Safely call the provider after the first frame loads ---
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLocations();
    });
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _roomNumberController.dispose();
    _attendanceWindowController.dispose();
    super.dispose();
  }

  // --- NEW: Dynamic Firebase Fetch ---
// --- UPDATED: Uses the Provider Cache ---
  Future<void> _fetchLocations() async {
    try {
      final provider = Provider.of<ClassDataProvider>(context, listen: false);

      // 1. Tell the provider to fetch.
      // It will skip the database entirely if it already has the data!
      await provider.fetchBuildings();

      if (!mounted) return;

      setState(() {
        // 2. Grab the clean, cached list from the provider
        _availableBuildingIds = List.from(provider.availableBuildingIds);

        // 3. Safety check: ensure our current building is in the list so the dropdown doesn't crash
        if (_selectedBuildingId != null &&
            !_availableBuildingIds.contains(_selectedBuildingId)) {
          _availableBuildingIds.add(_selectedBuildingId!);
        }

        _isLoadingLocations = false;
      });
    } catch (e) {
      if (mounted) {
        _showError("Failed to load buildings.");
        setState(() => _isLoadingLocations = false);
      }
    }
  }

  // --- HELPER: Formats 'old_chem' into 'Old Chem' for the UI ---
  String _formatBuildingName(String rawId) {
    if (rawId.isEmpty) return "";
    return rawId.split('_').map((word) {
      if (word.isEmpty) return "";
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }

  void _updateStartTime(TimeOfDay newTime) {
    setState(() => _startTime = newTime);
  }

  void _updateEndTime(TimeOfDay newTime) {
    setState(() => _endTime = newTime);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.of(context).errorRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final classProvider = Provider.of<ClassDataProvider>(context);
    final updatedClass = classProvider.classes.firstWhere(
      (c) => c.id == widget.classInfo.id,
      orElse: () => widget.classInfo,
    );
    final isManualMode = updatedClass.attendanceMode == 'manual';
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
                    Text('Settings', style: AppTextStyles.plaintext(context)),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child:
                Divider(color: Colors.grey.shade300, thickness: 1, height: 1),
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

                // --- DYNAMIC LOCATION SELECTOR ---
// --- UPGRADED DYNAMIC LOCATION SELECTOR ---
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
                                  height:
                                      50, // Matches the height of the dropdown
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
                                            strokeWidth: 2)),
                                  ),
                                )
                              : DropdownMenu<String>(
                                  initialSelection: _selectedBuildingId,
                                  hintText: "Search building...",
                                  menuHeight: 250,
                                  enableFilter: true,
                                  requestFocusOnTap: true,
                                  expandedInsets: EdgeInsets.zero,

                                  // 1. STYLE THE TYPED TEXT
                                  textStyle: AppTextStyles.fieldtext(context),

                                  // 2. STYLE THE POPUP MENU (Fixes the "All White" issue)
                                  menuStyle: MenuStyle(
                                    backgroundColor: WidgetStatePropertyAll(colors
                                        .cardColor), // Or secondaryBackground
                                    elevation: const WidgetStatePropertyAll(8),
                                    shape: WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),

                                  // 3. STYLE THE INPUT BOX
                                  inputDecorationTheme: InputDecorationTheme(
                                    filled: true,
                                    fillColor: colors.secondaryBackground,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    hintStyle: TextStyle(
                                        color: Colors.grey
                                            .shade500), // Fixes white hint text
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
                                      // 4. STYLE THE LIST ITEMS
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
                    setState(() => _selectedDays = newSelection);
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
                AttendanceModeToggle(
                  classInfo: widget.classInfo,
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

                // --- SAVE BUTTON ---
                _isSaving
                    ? const Center(child: CircularProgressIndicator())
                    : PrimaryButton(
                        backgroundColor: colors.primaryBlue,
                        label: 'Save Changes',
                        onPressed: () async {
                          if (_courseNameController.text.trim().isEmpty) {
                            _showError("Course name cannot be empty.");
                            return;
                          }
                          if (_selectedBuildingId == null) {
                            _showError("Please select a building.");
                            return;
                          }
                          if (_selectedDays.isEmpty) {
                            _showError("Please select at least one day.");
                            return;
                          }

                          setState(() => _isSaving = true);

                          try {
                            final provider = Provider.of<ClassDataProvider>(
                                context,
                                listen: false);
                            final latestClass = provider.classes.firstWhere(
                              (c) => c.id == widget.classInfo.id,
                              orElse: () => widget.classInfo,
                            );

                            // Combine the formatted building name and room number for the UI string
                            final buildingName =
                                _formatBuildingName(_selectedBuildingId!);
                            final roomNum = _roomNumberController.text.trim();
                            final fullLocationString = roomNum.isNotEmpty
                                ? "$buildingName $roomNum"
                                : buildingName;

                            final updatedClass = ClassInfo(
                              id: widget.classInfo.id,
                              subject: _courseNameController.text.trim(),
                              location: fullLocationString, // e.g., "Swift 500"
                              locationId: _selectedBuildingId!, // e.g., "swift"
                              startTime: _startTime,
                              endTime: _endTime,
                              daysOfWeek: _selectedDays.toList(),
                              isActive: widget.classInfo.isActive,
                              adminId: widget.classInfo.adminId,
                              attendanceWindowMinutes: int.tryParse(
                                      _attendanceWindowController.text) ??
                                  15,
                                attendanceMode: latestClass.attendanceMode,
                                isManualWindowOpen:
                                  latestClass.isManualWindowOpen,
                            );

                            await provider.updateClass(updatedClass);

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text("Class updated successfully!"),
                                    backgroundColor: Colors.green),
                              );
                              widget.onSave(updatedClass);
                            }
                          } catch (e) {
                            _showError("Failed to save class: $e");
                          } finally {
                            if (mounted) {
                              setState(() => _isSaving = false);
                            }
                          }
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
