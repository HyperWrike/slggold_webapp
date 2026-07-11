import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/core/constants/app_dimensions.dart';
import 'package:slg_golds/presentation/widgets/slg_button.dart';
import 'package:slg_golds/presentation/widgets/slg_card.dart';

class AdminCustomerDetailScreen extends StatelessWidget {
  final String customerId;
  const AdminCustomerDetailScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Customer Details'),
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
              const CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.goldPrimary,
                child: Icon(Icons.person, size: 48, color: AppColors.surface),
              ),
              const SizedBox(height: AppDimensions.p16),
              Text(
                'John Doe ($customerId)',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                '+91 9876543210',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.p32),
              
              SlgCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Active Enrollments', style: Theme.of(context).textTheme.titleMedium),
                    const Divider(height: 32),
                    const Text('Gold Plus Plan • 5/11 Paid'),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.p16),
              SlgButton(
                text: 'RECORD PAYMENT',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
