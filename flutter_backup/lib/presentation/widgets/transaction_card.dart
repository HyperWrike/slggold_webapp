import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import 'package:intl/intl.dart';

class TransactionCard extends StatelessWidget {
  final String title;
  final String date; // E.g. '12 Oct 2023'
  final double amount;
  final bool isCredit;
  final String status;

  const TransactionCard({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    required this.isCredit,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);

    Color statusColor;
    if (status.toLowerCase() == 'completed' || status.toLowerCase() == 'success') {
      statusColor = AppColors.success;
    } else if (status.toLowerCase() == 'pending') {
      statusColor = Colors.orange;
    } else {
      statusColor = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.p16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.surfaceContainerHighest, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCredit ? AppColors.success.withAlpha(20) : AppColors.error.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: isCredit ? AppColors.success : AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimensions.p16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppDimensions.p4),
                Text(
                  date,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : '-'}${formatCurrency.format(amount)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isCredit ? AppColors.success : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.p4),
              Text(
                status,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
