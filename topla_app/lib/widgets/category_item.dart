import 'package:flutter/material.dart';
import '../core/constants/constants.dart';

/// Kategoriya elementi - premium solid dizayn
class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String name;
  final Color color;
  final VoidCallback? onTap;
  final bool isSelected;

  const CategoryItem({
    super.key,
    required this.icon,
    required this.name,
    required this.color,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon container - premium solid design
          Container(
            width: AppSizes.categoryItemSize,
            height: AppSizes.categoryItemSize,
            decoration: BoxDecoration(
              // Solid ranglar
              color: isSelected ? color : color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              // Premium shadow
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: isSelected ? 0.35 : 0.15),
                  blurRadius: isSelected ? 10 : 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: AppSizes.categoryIconSize,
              color: isSelected ? Colors.white : color,
            ),
          ),

          const SizedBox(height: AppSizes.sm),

          // Name
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? color : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
