import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AvatarStack extends StatelessWidget {
  final List<AvatarData> avatars;
  final double size;
  final double overlap;
  final int maxVisible;

  const AvatarStack({
    super.key,
    required this.avatars,
    this.size = 36,
    this.overlap = 10,
    this.maxVisible = 4,
  });

  @override
  Widget build(BuildContext context) {
    final visible = avatars.take(maxVisible).toList();
    final remaining = avatars.length - maxVisible;

    return SizedBox(
      height: size,
      width: (visible.length * (size - overlap)) + overlap + (remaining > 0 ? size - overlap : 0),
      child: Stack(
        children: [
          for (int i = 0; i < visible.length; i++)
            Positioned(
              left: i * (size - overlap),
              child: _buildAvatar(visible[i]),
            ),
          if (remaining > 0)
            Positioned(
              left: visible.length * (size - overlap),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceBright,
                  border: Border.all(color: AppColors.background, width: 2),
                ),
                child: Center(
                  child: Text(
                    '+$remaining',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(AvatarData avatar) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.background, width: 2),
        gradient: LinearGradient(
          colors: [
            avatar.color ?? AppColors.primaryPurple,
            (avatar.color ?? AppColors.primaryCyan).withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: avatar.imageUrl != null
          ? ClipOval(
              child: Image.network(
                avatar.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _buildInitial(avatar),
              ),
            )
          : _buildInitial(avatar),
    );
  }

  Widget _buildInitial(AvatarData avatar) {
    return Center(
      child: Text(
        avatar.name.isNotEmpty ? avatar.name[0].toUpperCase() : '?',
        style: AppTypography.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}

class AvatarData {
  final String name;
  final String? imageUrl;
  final Color? color;

  const AvatarData({
    required this.name,
    this.imageUrl,
    this.color,
  });
}
