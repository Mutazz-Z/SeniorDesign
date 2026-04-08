import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:attendin/common/theme/app_colors.dart';
import 'package:attendin/common/theme/app_text_styles.dart';

// Your existing enums
enum ProfileShape { circle, roundedSquare }

enum ProfileTextLocation { bottom, right }

class ProfilePictureWidget extends StatefulWidget {
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

  @override
  State<ProfilePictureWidget> createState() => _ProfilePictureWidgetState();
}

class _ProfilePictureWidgetState extends State<ProfilePictureWidget> {
  Uint8List? _decodedBytes;
  String? _lastImageUrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAndDecodeImage();
  }

  @override
  void didUpdateWidget(covariant ProfilePictureWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _checkAndDecodeImage();
    }
  }

  void _checkAndDecodeImage() {
    if (widget.imageUrl != _lastImageUrl) {
      _lastImageUrl = widget.imageUrl;
      if (widget.imageUrl != null &&
          widget.imageUrl!.startsWith('data:image')) {
        final base64String = widget.imageUrl!.split(',').last;
        _decodedBytes = base64Decode(base64String);
      } else {
        _decodedBytes = null;
      }
    }
  }

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

  Widget _buildProfileImage() {
    final bool hasImage =
        widget.imageUrl != null && widget.imageUrl!.isNotEmpty;

    if (hasImage) {
      ImageProvider imageProvider;
      if (_decodedBytes != null) {
        imageProvider = MemoryImage(_decodedBytes!); // Uses the cached bytes!
      } else {
        imageProvider = NetworkImage(widget.imageUrl!);
      }

      if (widget.profileShape == ProfileShape.circle) {
        return CircleAvatar(
            radius: widget.size / 2, backgroundImage: imageProvider);
      } else {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        );
      }
    } else {
      final initials = _getInitials(widget.name);
      final backgroundColor = _getColorForName(widget.name);
      final textColor = _getTextColor(backgroundColor);

      final childWidget = initials.isNotEmpty
          ? Transform.translate(
              offset: const Offset(0, 2),
              child: Text(initials,
                  style: TextStyle(
                      color: textColor,
                      fontSize: widget.size * 0.4,
                      fontWeight: FontWeight.bold,
                      height: 1.0)))
          : Icon(Icons.person, color: textColor, size: widget.size * 0.6);

      if (widget.profileShape == ProfileShape.circle) {
        return CircleAvatar(
            radius: widget.size / 2,
            backgroundColor: backgroundColor,
            child: childWidget);
      } else {
        return Container(
          width: widget.size,
          height: widget.size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20.0)),
          child: childWidget,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = AppColors.of(context);

    final Widget profileImageWithBadge = Stack(
      alignment: Alignment.bottomRight,
      children: [
        _buildProfileImage(),
        if (widget.showEditBadge)
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: widget.onEditPressed,
              child: Container(
                decoration: BoxDecoration(
                  color: colors.cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: widget.color ?? colors.fieldTitleColor, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(Icons.edit,
                      color: widget.color ?? colors.fieldTitleColor, size: 24),
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
        if (widget.showName == true)
          Text(widget.name ?? '',
              style: AppTextStyles.userName(context).copyWith(
                  color: widget.color ?? colors.fieldTitleColor,
                  fontSize: widget.fontSize),
              maxLines: null,
              overflow: TextOverflow.visible),
        if (widget.email != null)
          Padding(
            padding: EdgeInsets.only(top: widget.showName == true ? 5.0 : 0.0),
            child: Text(widget.email!,
                style: AppTextStyles.plaintext(context).copyWith(
                    color: widget.color?.withOpacity(0.5) ??
                        colors.fieldTitleColor.withOpacity(0.5)),
                maxLines: null,
                overflow: TextOverflow.visible),
          ),
      ],
    );

    if (widget.textLocation == ProfileTextLocation.right) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          profileImageWithBadge,
          if (widget.showName == true || widget.email != null)
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: textContent)),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: widget.alignment,
        children: [
          profileImageWithBadge,
          if (widget.showName == true || widget.email != null)
            Padding(
                padding: const EdgeInsets.only(top: 20.0), child: textContent),
        ],
      );
    }
  }
}
