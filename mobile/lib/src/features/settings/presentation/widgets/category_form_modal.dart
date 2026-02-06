import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:simpleflow/src/common_widgets/app_button.dart';
import 'package:simpleflow/src/common_widgets/app_text_field.dart';
import 'package:simpleflow/src/core/theme/app_colors.dart';
import 'package:simpleflow/src/core/theme/app_text_styles.dart';
import 'package:simpleflow/src/data/models/models.dart';
import 'package:simpleflow/src/features/settings/presentation/category_form_provider.dart';
import 'package:simpleflow/src/features/settings/presentation/widgets/color_picker.dart';
import 'package:simpleflow/src/features/settings/presentation/widgets/icon_picker.dart';

/// Modal pour créer ou éditer une catégorie.
class CategoryFormModal extends ConsumerStatefulWidget {
  const CategoryFormModal({
    required this.categoryType, super.key,
    this.category,
  });

  final Category? category;
  final CategoryType categoryType;

  static Future<bool?> show(
    BuildContext context, {
    required CategoryType categoryType, Category? category,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoryFormModal(
        category: category,
        categoryType: categoryType,
      ),
    );
  }

  @override
  ConsumerState<CategoryFormModal> createState() => _CategoryFormModalState();
}

class _CategoryFormModalState extends ConsumerState<CategoryFormModal> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(categoryFormNotifierProvider.notifier);
      if (widget.category != null) {
        notifier.loadCategory(widget.category!);
        _nameController.text = widget.category!.name;
      } else {
        notifier.reset(type: widget.categoryType);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final notifier = ref.read(categoryFormNotifierProvider.notifier);
    final state = ref.read(categoryFormNotifierProvider);

    bool success;
    if (state.isEditing) {
      success = await notifier.update();
    } else {
      success = await notifier.create();
    }

    if (success && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoryFormNotifierProvider);
    final notifier = ref.read(categoryFormNotifierProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                state.isEditing ? 'Modifier la catégorie' : 'Nouvelle catégorie',
                style: AppTextStyles.h3(color: textColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Name field
              AppTextField(
                controller: _nameController,
                label: 'Nom',
                hint: 'Ex: Restaurant, Sport...',
                onChanged: notifier.setName,
              ),
              const SizedBox(height: 24),

              // Icon picker
              IconPicker(
                selectedIconKey: state.iconKey,
                onIconSelected: notifier.setIconKey,
                selectedColor: state.color,
              ),
              const SizedBox(height: 24),

              // Color picker
              ColorPicker(
                selectedColor: state.color,
                onColorSelected: notifier.setColor,
              ),
              const SizedBox(height: 8),

              // Error message
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    state.error!,
                    style: AppTextStyles.bodySmall(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 24),

              // Submit button
              AppButton(
                label: state.isEditing ? 'Enregistrer' : 'Créer',
                onPressed: state.isValid && !state.isSubmitting ? _submit : null,
                isLoading: state.isSubmitting,
                size: AppButtonSize.large,
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
