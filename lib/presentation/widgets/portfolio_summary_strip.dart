import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import 'package:intl/intl.dart';

class PortfolioSummaryStrip extends StatelessWidget {
  const PortfolioSummaryStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.p20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppDimensions.r16),
        border: Border.all(color: AppColors.surfaceContainerHigh),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildPortfolioItem(context, 'Total Savings', formatCurrency.format(45000), Icons.wallet),
          Container(width: 1, height: 40, color: AppColors.surfaceContainerHigh),
          _buildPortfolioItem(context, 'Gold Weight', '12.5 g', Icons.diamond_outlined),
          Container(width: 1, height: 40, color: AppColors.surfaceContainerHigh),
          _buildPortfolioItem(context, 'Active Plans', '2', Icons.list_alt),
        ],
      ),
    );
  }

  Widget _buildPortfolioItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.goldPrimary),
        const SizedBox(height: AppDimensions.p8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.p4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
