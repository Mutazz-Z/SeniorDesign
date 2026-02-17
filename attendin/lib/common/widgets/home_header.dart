import 'package:attendin/common/widgets/profile_picture_widget.dart';
import 'package:flutter/material.dart';

import 'package:attendin/common/theme/app_text_styles.dart';

class HomeScreenHeader extends StatelessWidget {
  final String userName;
  final String? profilePicture;

  const HomeScreenHeader(
      {super.key, required this.userName, required this.profilePicture});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProfilePictureWidget(
          profileShape: ProfileShape.circle,
          size: 50,
          imageUrl: profilePicture,
          showEditBadge: false,
          name: userName,
          showName: false,
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, Welcome Back',
              style: AppTextStyles.welcomeMessage(context),
            ),
            Text(
              userName,
              style: AppTextStyles.userName(context),
            ),
          ],
        ),
      ],
    );
  }
}
