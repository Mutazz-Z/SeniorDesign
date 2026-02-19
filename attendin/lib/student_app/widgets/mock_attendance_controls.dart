import 'package:flutter/material.dart';

import 'package:attendin/common/models/class_info.dart';
import 'package:attendin/common/theme/app_text_styles.dart';

class MockAttendanceControls extends StatelessWidget {
  final Function(AttendanceStatus) onStatusChanged;
  final VoidCallback onToggleLocation;
  final bool mockUserInLocation;
  final VoidCallback onNoClass;
  final VoidCallback onMarkAttendanceSet;

  const MockAttendanceControls({
    super.key,
    required this.onStatusChanged,
    required this.onToggleLocation,
    required this.mockUserInLocation,
    required this.onNoClass,
    required this.onMarkAttendanceSet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mock Attendance States',
          style: AppTextStyles.userName(context),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            ElevatedButton(
              onPressed: () => onMarkAttendanceSet(),
              child: const Text('Mark Attendance'),
            ),
            ElevatedButton(
              onPressed: () => onStatusChanged(AttendanceStatus.attended),
              child: const Text('Attended'),
            ),
            ElevatedButton(
              onPressed: () => onStatusChanged(AttendanceStatus.missed),
              child: const Text('Missed'),
            ),
            ElevatedButton(
              onPressed: () => onStatusChanged(AttendanceStatus.outOfLocation),
              child: const Text('Out of Location'),
            ),
            ElevatedButton(
              onPressed: onToggleLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    mockUserInLocation ? Colors.lightGreen : Colors.redAccent,
              ),
              child: Text(
                  'Toggle Location (${mockUserInLocation ? 'In' : 'Out'})'),
            ),
            ElevatedButton(
              onPressed: onNoClass,
              child: const Text('No Class'),
            ),
          ],
        ),
      ],
    );
  }
}
