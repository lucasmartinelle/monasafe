import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:simpleflow/src/core/theme/app_colors.dart';
import 'package:simpleflow/src/core/theme/app_text_styles.dart';
import 'package:simpleflow/src/core/utils/icon_mapper.dart';

/// Sélecteur d'icône pour les catégories.
class IconPicker extends StatelessWidget {
  const IconPicker({
    required this.selectedIconKey, required this.onIconSelected, required this.selectedColor, super.key,
  });

  final String selectedIconKey;
  final ValueChanged<String> onIconSelected;
  final int selectedColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final icons = IconMapper.allIcons;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'Icône',
            style: AppTextStyles.labelMedium(color: textColor),
          ),
        ),
        SizedBox(
          height: 56,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: icons.length,
            itemBuilder: (context, index) {
              final entry = icons.entries.elementAt(index);
              final isSelected = entry.key == selectedIconKey;

              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 0 : 8,
                  right: index == icons.length - 1 ? 0 : 0,
                ),
                child: _IconItem(
                  iconKey: entry.key,
                  icon: entry.value,
                  isSelected: isSelected,
                  selectedColor: selectedColor,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onIconSelected(entry.key);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _IconItem extends StatelessWidget {
  const _IconItem({
    required this.iconKey,
    required this.icon,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  final String iconKey;
  final IconData icon;
  final bool isSelected;
  final int selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final unselectedIconColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected
              ? Color(selectedColor).withValues(alpha: 0.15)
              : unselectedBg,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: Color(selectedColor),
                  width: 2,
                )
              : null,
        ),
        child: Icon(
          icon,
          color: isSelected ? Color(selectedColor) : unselectedIconColor,
          size: 24,
        ),
      ),
    );
  }
}
