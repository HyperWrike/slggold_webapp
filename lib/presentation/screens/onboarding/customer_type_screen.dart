import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/core/constants/app_strings.dart';
import 'package:slg_golds/core/constants/app_dimensions.dart';

class CustomerTypeScreen extends StatelessWidget {
  const CustomerTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepPurple,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.p24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimensions.p48),
              // Header
              Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.goldGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.goldPrimary.withAlpha(40),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.diamond, size: 40, color: AppColors.deepPurple),
                  ),
                  const SizedBox(height: AppDimensions.p24),
                  Text(
                    'Welcome to\n${AppStrings.appName}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.goldPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.p12),
                  Text(
                    'Select your customer type to continue',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textWhite.withAlpha(200),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Selection Cards
              _buildSelectionCard(
                context: context,
                title: AppStrings.newCustomer,
                subtitle: 'Join us and start your gold savings journey today.',
                icon: Icons.person_add_alt_1,
                onTap: () => context.push('/onboarding/register'),
              ),
              const SizedBox(height: AppDimensions.p20),
              _buildSelectionCard(
                context: context,
                title: AppStrings.existingCustomer,
                subtitle: 'Login to access your portfolio and schemes.',
                icon: Icons.login,
                onTap: () => context.push('/auth/login'),
              ),
              const SizedBox(height: AppDimensions.p48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surfaceContainerLowest.withAlpha(10),
      borderRadius: BorderRadius.circular(AppDimensions.r20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.r20),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.p24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.r20),
            border: Border.all(
              color: AppColors.goldPrimary.withAlpha(50),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.p12),
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.goldPrimary, size: 28),
              ),
              const SizedBox(width: AppDimensions.p20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.goldPrimary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.p4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textWhite.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.p12),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.goldPrimary.withAlpha(150),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
