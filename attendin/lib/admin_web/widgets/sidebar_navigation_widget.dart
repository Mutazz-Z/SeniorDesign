import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/theme/app_text_styles.dart';
import 'package:attendin/common/widgets/profile_picture_widget.dart';
import 'package:provider/provider.dart';
import 'package:attendin/common/data/user_data_provider.dart';

import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final List<String> navigationItems;
  final ValueChanged<int> onItemSelected;
  final Color sidebarBackgroundColor;
  final double fixedWidth;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.navigationItems,
    required this.onItemSelected,
    required this.sidebarBackgroundColor,
    this.fixedWidth = 200.0,
    this.selectedTextColor,
    this.unselectedTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);
    final userProvider = Provider.of<UserDataProvider>(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: fixedWidth,
      color: sidebarBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80.0, horizontal: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfilePictureWidget(
              alignment: CrossAxisAlignment.start,
              profileShape: ProfileShape.roundedSquare,
              size: 100,
              imageUrl: userProvider.profilePicture,
              showEditBadge: false,
              name: userProvider.userName,
              email: userProvider.email,
              color: unselectedTextColor ?? colors.whiteColor,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: navigationItems.asMap().entries.map((entry) {
                  int index = entry.key;
                  String item = entry.value;
                  bool isSelected = selectedIndex == index;

                  final TextStyle baseStyle = isSelected
                      ? AppTextStyles.navigationItemSelected(context)
                      : AppTextStyles.navigationItemUnselected(context);

                  final Color finalColor = isSelected
                      ? selectedTextColor ?? baseStyle.color!
                      : unselectedTextColor ?? baseStyle.color!;

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(45, 0, 0, 15),
                    child: InkWell(
                      onTap: () => onItemSelected(index),
                      child: Text(
                        item,
                        style: baseStyle.copyWith(color: finalColor),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
