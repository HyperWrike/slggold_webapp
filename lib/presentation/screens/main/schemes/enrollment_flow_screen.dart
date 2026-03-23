import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/core/constants/app_dimensions.dart';
import 'package:slg_golds/presentation/widgets/slg_button.dart';
import 'package:slg_golds/presentation/widgets/slg_text_field.dart';
import 'package:intl/intl.dart';

class EnrollmentFlowScreen extends StatefulWidget {
  const EnrollmentFlowScreen({super.key});

  @override
  State<EnrollmentFlowScreen> createState() => _EnrollmentFlowScreenState();
}

class _EnrollmentFlowScreenState extends State<EnrollmentFlowScreen> {
  final _amountController = TextEditingController();
  double _monthlyAmount = 0.0;
  final formatCurrency = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _processEnrollment() {
    // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enrollment Successful!')));
    context.pop(); // Go back to schemes list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enroll in Scheme'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.p24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Gold Plus Plan',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppDimensions.p8),
              Text(
                '11 Months Duration • 1 Month Free Bonus',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.p32),
              
              SlgTextField(
                label: 'Monthly Installment Amount (₹)',
                hint: 'e.g., 5000',
                controller: _amountController,
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  setState(() {
                    _monthlyAmount = double.tryParse(val) ?? 0.0;
                  });
                },
              ),
              const SizedBox(height: AppDimensions.p16),
              const Text('Minimum installment amount is ₹1,000.'),
              
              const SizedBox(height: AppDimensions.p48),
              
              // Summary
              Container(
                padding: const EdgeInsets.all(AppDimensions.p20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppDimensions.r16),
                  border: Border.all(color: AppColors.surfaceContainerHigh),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Summary',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppDimensions.p16),
                    _buildSummaryRow('You Pay (11 Months)', formatCurrency.format(_monthlyAmount * 11)),
                    const SizedBox(height: AppDimensions.p12),
                    _buildSummaryRow(
                      'SLG Golds Bonus (1 Month)',
                      '+ ${formatCurrency.format(_monthlyAmount)}',
                      isHighlight: true,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppDimensions.p12),
                      child: Divider(height: 1),
                    ),
                    _buildSummaryRow('Total Value Accumulated', formatCurrency.format(_monthlyAmount * 12), isTotal: true),
                  ],
                ),
              ),
              
              const SizedBox(height: AppDimensions.p48),
              SlgButton(
                text: 'PROCEED TO PAY 1ST INSTALLMENT',
                onPressed: _monthlyAmount >= 1000 ? _processEnrollment : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isHighlight = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isHighlight ? AppColors.goldDark : (isTotal ? AppColors.textPrimary : AppColors.textSecondary),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: isHighlight ? AppColors.goldDark : AppColors.textPrimary,
            fontWeight: isTotal || isHighlight ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
