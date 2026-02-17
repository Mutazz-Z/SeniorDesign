import 'package:attendin/admin_web/screens/class_screens/add_class_screen.dart';
import 'package:attendin/admin_web/screens/class_screens/class_settings_screen.dart';
import 'package:attendin/admin_web/screens/class_screens/selected_class_screen.dart';
import 'package:attendin/common/models/class_info.dart';
import 'package:attendin/common/widgets/class_info_card.dart';
import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/theme/app_text_styles.dart';
import 'package:provider/provider.dart';
import 'package:attendin/common/data/user_data_provider.dart';
import 'package:attendin/common/data/class_data_provider.dart';
import 'package:attendin/common/data/enrollment_data_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum ClassesView { list, details, settings, add }

class ClassesScreen extends StatelessWidget {
  final ClassesView currentView;
  final dynamic selectedItem;

  final Function(dynamic) onClassSelected;
  final VoidCallback onNavigateToSettings;
  final VoidCallback onBack;
  final Function(ClassInfo) onSave;
  final VoidCallback onAddClass;

  const ClassesScreen({
    super.key,
    required this.currentView,
    this.selectedItem,
    required this.onClassSelected,
    required this.onNavigateToSettings,
    required this.onBack,
    required this.onSave,
    required this.onAddClass,
  });

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);

    final userProvider = Provider.of<UserDataProvider>(context);
    final classProvider = Provider.of<ClassDataProvider>(context);

    final List<ClassInfo> adminClasses = classProvider.classes
        .where((cls) => cls.adminId == userProvider.uid)
        .toList();

    final List<ClassInfo> activeClasses =
        adminClasses.where((cls) => cls.isActive).toList();
    final List<ClassInfo> inactiveClasses =
        adminClasses.where((cls) => !cls.isActive).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: colors.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: switch (currentView) {
          ClassesView.list =>
            _buildClassList(context, activeClasses, inactiveClasses),
          ClassesView.details => _buildClassDetails(context),
          ClassesView.settings => _buildClassSettings(),
          ClassesView.add => _buildAddClassScreen(),
        },
      ),
    );
  }

  Widget _buildClassDetails(BuildContext context) {
    final classInfo = selectedItem as ClassInfo;
    return ClassDetailsPanel(
      classInfo: classInfo,
      onBack: onBack,
      onSettingsTap: onNavigateToSettings,
    );
  }

  Widget _buildClassSettings() {
    final classInfo = selectedItem as ClassInfo;

    return SelectedClassSettingsScreen(
      classInfo: classInfo,
      onBack: onBack,
      onSave: onSave,
    );
  }

  Widget _buildAddClassScreen() {
    return AddClassScreen(
      onBack: onBack,
    );
  }

  Widget _buildClassList(BuildContext context, List<ClassInfo> activeClasses,
      List<ClassInfo> inactiveClasses) {
    final AppColorScheme colors = AppColors.of(context);
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(32.0),
          children: [
            Text(
              'Classes',
              style: AppTextStyles.screentitle(context)
                  .copyWith(fontSize: 32, color: colors.classesTextColorWeb),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'Active:',
              classList: activeClasses,
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'Inactive:',
              classList: inactiveClasses,
            ),
          ],
        ),
        Positioned(
          top: 24,
          right: 24,
          child: FloatingActionButton(
            onPressed: onAddClass,
            backgroundColor: colors.accentTeal,
            shape: const CircleBorder(),
            child: Icon(Icons.add, color: colors.whiteColor, size: 32),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context,
      {required String title, required List<ClassInfo> classList}) {
    final AppColorScheme colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.classTitle(context).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: colors.classesTextColorWeb),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(color: Colors.grey.shade300, thickness: 1),
        ),
        LayoutBuilder(builder: (context, constraints) {
          const int crossAxisCount = 2;
          const double spacing = 16.0;
          final double itemWidth =
              (constraints.maxWidth - (spacing * (crossAxisCount - 1))) /
                  crossAxisCount;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: classList.map((classInfoToShow) {
              return SizedBox(
                width: itemWidth,
                child: ClassInfoCard(
                  color: colors.secondaryBackground,
                  classInfo: classInfoToShow,
                  onTap: () => onClassSelected(classInfoToShow),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}

class ClassDetailsPanel extends StatefulWidget {
  final ClassInfo classInfo;
  final VoidCallback onBack;
  final VoidCallback onSettingsTap;

  const ClassDetailsPanel({
    super.key,
    required this.classInfo,
    required this.onBack,
    required this.onSettingsTap,
  });

  @override
  State<ClassDetailsPanel> createState() => _ClassDetailsPanelState();
}

class _ClassDetailsPanelState extends State<ClassDetailsPanel> {
  bool loading = true;
  List<ClassStudent> students = [];
  String? lastClassId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void didUpdateWidget(ClassDetailsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.classInfo.id != lastClassId) {
      lastClassId = widget.classInfo.id;
      // Trigger fetch when class changes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadData();
      });
    }
  }

  void _loadData() {
    // This will now hit the cache first!
    Provider.of<EnrollmentProvider>(context, listen: false)
        .fetchStudentUidsForClass(widget.classInfo.id);

    loading = false;
  }

  @override
  Widget build(BuildContext context) {
    final enrollmentProvider = Provider.of<EnrollmentProvider>(context);
    if (enrollmentProvider.loading || loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SelectedClassScreen(
      classInfo: widget.classInfo,
      students: enrollmentProvider
          .classStudents, // Pass the list of student user data
      onBack: widget.onBack,
      onSettingsTap: widget.onSettingsTap,
    );
  }
}
