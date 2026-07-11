import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import 'package:intl/intl.dart';

class MetalPriceCard extends StatelessWidget {
  final String title;
  final double? pricePerGram;
  final bool isGold;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;

  const MetalPriceCard({
    super.key,
    required this.title,
    this.pricePerGram,
    required this.isGold,
    this.isLoading = false,
    this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.simpleCurrency(
      locale: 'en_IN',
      decimalDigits: 2,
    );

    return Container(
      padding: const EdgeInsets.all(AppDimensions.p16),
      decoration: BoxDecoration(
        gradient: isGold ? AppColors.goldGradient : AppColors.silverGradient,
        borderRadius: BorderRadius.circular(AppDimensions.r16),
        boxShadow: [
          BoxShadow(
            color: (isGold ? AppColors.goldPrimary : AppColors.silver)
                .withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: isGold ? AppColors.goldDark : AppColors.surface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.p8),
          if (isLoading)
            const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (error != null)
            GestureDetector(
              onTap: onRetry,
              child: Text(
                error!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.error,
                  decoration: TextDecoration.underline,
                ),
              ),
            )
          else
            Text(
              '${formatCurrency.format(pricePerGram)} /g',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: isGold ? AppColors.goldDark : AppColors.surface,
                fontWeight: FontWeight.w700,
              ),
            ),
          const SizedBox(height: AppDimensions.p4),
          Text(
            'Live Rate',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: (isGold ? AppColors.goldDark : AppColors.surface)
                  .withAlpha(180),
            ),
          ),
        ],
      ),
    );
  }
}
