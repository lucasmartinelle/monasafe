import 'package:flutter/material.dart';

import 'package:monasafe/src/common_widgets/common_widgets.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/core/theme/theme_helper.dart';

/// Layout commun pour les pages de questions (devise + choix oui/non).
class QuestionPageLayout extends StatefulWidget {
  const QuestionPageLayout({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.onNext,
    required this.buttonLabel,
    this.isLoading = false,
    this.showButton = true,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback onNext;
  final String buttonLabel;
  final bool isLoading;
  final bool showButton;

  @override
  State<QuestionPageLayout> createState() => _QuestionPageLayoutState();
}

class _QuestionPageLayoutState extends State<QuestionPageLayout>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              IconContainer(
                icon: widget.icon,
                color: AppColors.primary,
                size: IconContainerSize.extraLarge,
                shape: IconContainerShape.circle,
              ),
              const SizedBox(height: 24),
              Text(
                widget.title,
                style: AppTextStyles.h2(
                  color: context.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.subtitle,
                style: AppTextStyles.bodySmall(
                  color: context.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              widget.child,
              const Spacer(),
              AnimatedOpacity(
                opacity: widget.showButton ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: AnimatedSlide(
                  offset: widget.showButton
                      ? Offset.zero
                      : const Offset(0, 0.3),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: AppButton(
                    label: widget.buttonLabel,
                    fullWidth: true,
                    icon: widget.isLoading ? null : Icons.arrow_forward,
                    iconPosition: IconPosition.right,
                    isLoading: widget.isLoading,
                    onPressed: widget.showButton ? widget.onNext : null,
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
