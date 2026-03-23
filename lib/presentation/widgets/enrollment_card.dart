import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import 'slg_card.dart';
import 'package:intl/intl.dart';

class EnrollmentCard extends StatelessWidget {
  final String schemeName;
  final double monthlyAmount;
  final int totalMonths;
  final int paidMonths;
  final DateTime nextDueDate;

  const EnrollmentCard({
    super.key,
    required this.schemeName,
    required this.monthlyAmount,
    required this.totalMonths,
    required this.paidMonths,
    required this.nextDueDate,
  });

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);
    final formatDate = DateFormat('dd MMM yyyy');
    
    final progress = paidMonths / totalMonths;

    return SlgCard(
      backgroundColor: AppColors.surfaceContainerLowest,
      onTap: () {
        // Navigate to enrollment detail/payment
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                schemeName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppDimensions.r4),
                ),
                child: Text(
                  'Active',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.goldDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.p16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoCol(context, 'Monthly Installment', formatCurrency.format(monthlyAmount)),
              _buildInfoCol(context, 'Total Accumulated', formatCurrency.format(monthlyAmount * paidMonths)),
            ],
          ),
          const SizedBox(height: AppDimensions.p16),
          
          // Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '$paidMonths/$totalMonths Months',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.p8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          
          const SizedBox(height: AppDimensions.p16),
          const Divider(height: 1),
          const SizedBox(height: AppDimensions.p16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_month, size: 16, color: AppColors.error),
                  const SizedBox(width: AppDimensions.p8),
                  Text(
                    'Next Due: ${formatDate.format(nextDueDate)}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                'PAY NOW',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.goldDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCol(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.p4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
