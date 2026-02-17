import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/theme/app_text_styles.dart';

import 'package:flutter/material.dart';

extension ColorUtils on Color {
  Color withValues({double? alpha}) {
    if (alpha != null) {
      return withAlpha((alpha * 255).round().clamp(0, 255));
    }
    return this;
  }
}

enum ProfileShape {
  circle,
  roundedSquare,
}

enum ProfileTextLocation {
  bottom,
  right,
}

class ProfilePictureWidget extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback? onEditPressed;
  final bool showEditBadge;
  final String? name;
  final String? email;
  final ProfileShape profileShape;
  final Color? color;
  final CrossAxisAlignment alignment;
  final double size;
  final ProfileTextLocation textLocation;
  final double fontSize;
  final bool? showName;

  const ProfilePictureWidget({
    super.key,
    this.imageUrl,
    required this.showEditBadge,
    this.onEditPressed,
    this.name,
    this.email,
    this.profileShape = ProfileShape.circle,
    this.color,
    this.alignment = CrossAxisAlignment.center,
    this.size = 125,
    this.textLocation = ProfileTextLocation.bottom,
    this.fontSize = 28,
    this.showName = true,
  });

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '';
    List<String> nameParts = name.trim().split(RegExp(r'\s+'));
    if (nameParts.length > 1) {
      return nameParts.first[0].toUpperCase() + nameParts.last[0].toUpperCase();
    } else if (nameParts.isNotEmpty) {
      return nameParts.first[0].toUpperCase();
    }
    return '';
  }

  Color _getColorForName(String? name) {
    if (name == null || name.isEmpty) return Colors.grey;
    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final finalHash = hash & 0xFFFFFFFF;
    final int hue = finalHash % 360;
    return HSLColor.fromAHSL(1.0, hue.toDouble(), 0.4, 0.5).toColor();
  }

  Color _getTextColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);

    final Widget profileImageWithBadge = Stack(
      alignment: Alignment.bottomRight,
      children: [
        _buildProfileImage(),
        if (showEditBadge)
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: onEditPressed,
              child: Container(
                decoration: BoxDecoration(
                  color: colors.cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color ?? colors.fieldTitleColor,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.edit,
                    color: color ?? colors.fieldTitleColor,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    final Widget textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showName == true)
          Text(
            name!,
            style: AppTextStyles.userName(context).copyWith(
                color: color ?? colors.fieldTitleColor, fontSize: fontSize),
            maxLines: null,
            overflow: TextOverflow.visible,
          ),
        if (email != null)
          Padding(
            padding: EdgeInsets.only(top: showName == true ? 5.0 : 0.0),
            child: Text(
              email!,
              style: AppTextStyles.plaintext(context).copyWith(
                color: color?.withValues(alpha: 0.5) ??
                    colors.fieldTitleColor.withValues(alpha: 0.5),
              ),
              maxLines: null,
              overflow: TextOverflow.visible,
            ),
          ),
      ],
    );

    if (textLocation == ProfileTextLocation.right) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          profileImageWithBadge,
          if (showName == true || email != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: textContent,
              ),
            ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: alignment,
        children: [
          profileImageWithBadge,
          if (showName == true || email != null)
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: textContent,
            ),
        ],
      );
    }
  }

  /// main profile image
  Widget _buildProfileImage() {
    final bool hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    if (hasImage) {
      if (profileShape == ProfileShape.circle) {
        return CircleAvatar(
          radius: size / 2,
          backgroundImage: NetworkImage(imageUrl!),
          onBackgroundImageError: (exception, stackTrace) {
          },
        );
      } else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Image.network(
            imageUrl!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(width: size, height: size, color: Colors.grey);
            },
          ),
        );
      }
    } else {
      final initials = _getInitials(name);
      final backgroundColor = _getColorForName(name);
      final textColor = _getTextColor(backgroundColor);
      final initialsWidget = Center(
        child: Text(
          initials,
          style: TextStyle(
            color: textColor,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      // Display a person icon if there are no initials to show
      final placeholderWidget = Center(
        child: Icon(
          Icons.person,
          color: textColor,
          size: size * 0.6,
        ),
      );

      final childWidget =
          initials.isNotEmpty ? initialsWidget : placeholderWidget;

      if (profileShape == ProfileShape.circle) {
        return CircleAvatar(
          radius: size / 2,
          backgroundColor: backgroundColor,
          child: childWidget,
        );
      } else {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: childWidget,
        );
      }
    }
  }
}
