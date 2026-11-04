import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/trust_score.dart';
import '../../data/models/user.dart';

IconData categoryIcon(String category) {
  switch (category) {
    case 'Tools':
      return Icons.build;
    case 'Outdoor & Camping':
      return Icons.terrain;
    case 'Party & Events':
      return Icons.celebration;
    case 'Kitchen':
      return Icons.kitchen;
    case 'Electronics':
      return Icons.devices;
    case 'Sports':
      return Icons.sports_tennis;
    case 'Kids & Baby':
      return Icons.child_friendly;
    default:
      return Icons.inventory_2;
  }
}

Color tierColor(String tierName) {
  switch (tierName) {
    case 'Community Pillar':
      return AppColors.mossDark;
    case 'Trusted':
      return AppColors.moss;
    case 'Reliable':
      return AppColors.amber;
    default:
      return AppColors.barkLight;
  }
}

class TrustBadge extends StatelessWidget {
  final TrustScoreResult result;
  final bool compact;
  const TrustBadge({super.key, required this.result, this.compact = false});
  @override
  Widget build(BuildContext context) {
    final color = tierColor(result.tierName);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: compact ? 13 : 15, color: color),
          const SizedBox(width: 4),
          Text(
            '${result.total} · ${result.tierName}',
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  final AppUser user;
  final double radius;
  const UserAvatar({super.key, required this.user, this.radius = 20});
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.moss.withValues(alpha: 0.18),
      child: Text(
        user.initials,
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w700,
          color: AppColors.mossDark,
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String status;
  final bool isOverdue;
  const StatusChip({super.key, required this.status, this.isOverdue = false});
  @override
  Widget build(BuildContext context) {
    final label = isOverdue ? 'Overdue' : _label(status);
    final color = isOverdue ? AppColors.errorRed : _color(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  String _label(String s) {
    switch (s) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'active':
        return 'Active';
      case 'returned':
        return 'Returned';
      case 'reviewed':
        return 'Reviewed';
      case 'declined':
        return 'Declined';
      case 'cancelled':
        return 'Cancelled';
      default:
        return s;
    }
  }

  Color _color(String s) {
    switch (s) {
      case 'pending':
        return AppColors.amber;
      case 'approved':
        return AppColors.moss;
      case 'active':
        return AppColors.terracotta;
      case 'returned':
        return AppColors.mossDark;
      case 'reviewed':
        return AppColors.barkLight;
      case 'declined':
        return AppColors.errorRed;
      default:
        return AppColors.barkLight;
    }
  }
}

class CategoryTile extends StatelessWidget {
  final String category;
  final double size;
  const CategoryTile({super.key, required this.category, this.size = 56});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.creamDark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        categoryIcon(category),
        color: AppColors.terracotta,
        size: size * 0.5,
      ),
    );
  }
}
