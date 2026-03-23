import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

class SlgButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;

  const SlgButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      decoration: BoxDecoration(
        gradient: isSecondary || onPressed == null ? null : AppColors.goldGradient,
        color: onPressed == null 
               ? AppColors.surfaceContainerHigh 
               : (isSecondary ? AppColors.surfaceContainerLowest : null),
        borderRadius: BorderRadius.circular(AppDimensions.r16),
        border: isSecondary ? Border.all(color: AppColors.goldPrimary, width: 1.5) : null,
        boxShadow: onPressed == null || isSecondary ? [] : [
          BoxShadow(
            color: AppColors.goldPrimary.withAlpha(60),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.r16),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.textWhite,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        text.toUpperCase(),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: onPressed == null
                              ? AppColors.textSecondary.withAlpha(128)
                              : (isSecondary ? AppColors.goldDark : AppColors.textWhite),
                          letterSpacing: 2.0,
                        ),
                      ),
                      if (icon != null) ...[
                        const SizedBox(width: AppDimensions.p8),
                        Icon(
                          icon,
                          size: 20,
                          color: isSecondary ? AppColors.goldDark : AppColors.textWhite,
                        ),
                      ]
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
