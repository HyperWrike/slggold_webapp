import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/core/constants/app_dimensions.dart';
import 'package:slg_golds/presentation/widgets/slg_button.dart';
import 'package:slg_golds/presentation/widgets/slg_text_field.dart';
import 'package:slg_golds/presentation/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import '../../../widgets/payment_handler.dart';

class EnrollmentFlowScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? scheme;

  const EnrollmentFlowScreen({super.key, this.scheme});

  @override
  ConsumerState<EnrollmentFlowScreen> createState() =>
      _EnrollmentFlowScreenState();
}

class _EnrollmentFlowScreenState extends ConsumerState<EnrollmentFlowScreen> {
  final _amountController = TextEditingController();
  double _monthlyAmount = 0.0;
  bool _isLoading = false;
  final formatCurrency = NumberFormat.simpleCurrency(
    locale: 'en_IN',
    decimalDigits: 0,
  );

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _processEnrollment() async {
    if (_monthlyAmount < 1000) return;

    final authState = ref.read(authNotifierProvider);
    final userId = authState.user?.id;

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login to enroll')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final db = ref.read(databaseServiceProvider);
      final enrollmentId = await db.createEnrollment(
        userId: userId,
        schemeId: widget.scheme?['id'] ?? '',
        monthlyAmount: _monthlyAmount,
        tenureMonths: widget.scheme?['tenure_months'] as int? ?? 11,
      );

      // Create Razorpay order on backend
      final orderData = await db.createRazorpayOrder(
        enrollmentId: enrollmentId,
        amount: _monthlyAmount,
      );

      if (!mounted) return;

      // Start the checkout process (launches SDK overlay or mock simulator sheet)
      await PaymentHandler.startPayment(
        context: context,
        db: db,
        orderData: orderData,
        userPhone: authState.user?.phone ?? '',
        userEmail: '${authState.user?.username ?? "customer"}@example.com',
        onSuccess: () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Enrollment & First Installment Successful!'),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop();
          }
        },
        onFailure: (errorMsg) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Payment failed: $errorMsg'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Enrollment failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = widget.scheme ?? {};
    final tenureMonths = scheme['tenure_months'] as int? ?? 11;
    final minAmount = scheme['min_amount'] as num? ?? 1000;

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
                scheme['name'] as String? ?? 'Gold Scheme',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppDimensions.p8),
              Text(
                '$tenureMonths Months Duration • ${scheme['benefit'] as String? ?? "Special benefits"}',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
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
              Text('Minimum installment amount is ₹${minAmount.toInt()}.'),

              const SizedBox(height: AppDimensions.p48),

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
                    _buildSummaryRow(
                      'You Pay ($tenureMonths Months)',
                      formatCurrency.format(_monthlyAmount * tenureMonths),
                    ),
                    const SizedBox(height: AppDimensions.p12),
                    _buildSummaryRow(
                      'Gold Bonus',
                      '+ ${formatCurrency.format(_monthlyAmount * (_monthlyAmount > 0 ? 1 : 0))}',
                      isHighlight: true,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.p12,
                      ),
                      child: Divider(height: 1),
                    ),
                    _buildSummaryRow(
                      'Total Value Accumulated',
                      formatCurrency.format(
                        _monthlyAmount * (tenureMonths + 1),
                      ),
                      isTotal: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.p48),
              SlgButton(
                text: _isLoading
                    ? 'Processing...'
                    : 'PROCEED TO PAY 1ST INSTALLMENT',
                onPressed: _monthlyAmount >= minAmount.toInt() && !_isLoading
                    ? _processEnrollment
                    : null,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isHighlight = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isHighlight
                ? AppColors.goldDark
                : (isTotal ? AppColors.textPrimary : AppColors.textSecondary),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: isHighlight ? AppColors.goldDark : AppColors.textPrimary,
            fontWeight: isTotal || isHighlight
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
