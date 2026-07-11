import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../providers/user_data_provider.dart';
import 'package:intl/intl.dart';

class PortfolioSummaryStrip extends ConsumerWidget {
  final String? userId;

  const PortfolioSummaryStrip({super.key, this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatCurrency = NumberFormat.simpleCurrency(
      locale: 'en_IN',
      decimalDigits: 0,
    );

    if (userId == null) {
      return Container(
        padding: const EdgeInsets.all(AppDimensions.p20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppDimensions.r16),
          border: Border.all(color: AppColors.surfaceContainerHigh),
        ),
        child: const Center(child: Text('Login to view portfolio')),
      );
    }

    final portfolioAsync = ref.watch(portfolioSummaryProvider(userId!));

    return Container(
      padding: const EdgeInsets.all(AppDimensions.p20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppDimensions.r16),
        border: Border.all(color: AppColors.surfaceContainerHigh),
      ),
      child: portfolioAsync.when(
        data: (data) {
          final totalSavings = (data['totalValue'] as num?)?.toDouble() ?? 0;
          final goldWeight = (data['totalGoldGrams'] as num?)?.toDouble() ?? 0;
          final activePlans = (data['activeEnrollments'] as int?) ?? 0;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPortfolioItem(
                context,
                'Total Savings',
                formatCurrency.format(totalSavings),
                Icons.wallet,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.surfaceContainerHigh,
              ),
              _buildPortfolioItem(
                context,
                'Gold Weight',
                '${goldWeight.toStringAsFixed(2)} g',
                Icons.diamond_outlined,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.surfaceContainerHigh,
              ),
              _buildPortfolioItem(
                context,
                'Active Plans',
                '$activePlans',
                Icons.list_alt,
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPortfolioItem(context, 'Total Savings', '--', Icons.wallet),
            Container(
              width: 1,
              height: 40,
              color: AppColors.surfaceContainerHigh,
            ),
            _buildPortfolioItem(
              context,
              'Gold Weight',
              '--',
              Icons.diamond_outlined,
            ),
            Container(
              width: 1,
              height: 40,
              color: AppColors.surfaceContainerHigh,
            ),
            _buildPortfolioItem(context, 'Active Plans', '--', Icons.list_alt),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.goldPrimary),
        const SizedBox(height: AppDimensions.p8),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppDimensions.p4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
