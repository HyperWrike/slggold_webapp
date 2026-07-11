import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/core/constants/app_dimensions.dart';
import 'package:slg_golds/core/constants/app_strings.dart';
import 'package:slg_golds/presentation/widgets/slg_button.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  const RegistrationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.p32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Success Icon / Animation Placeholder
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withAlpha(20),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 80,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.p40),
              
              Text(
                'Registration Successful!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.goldDark,
                ),
              ),
              const SizedBox(height: AppDimensions.p16),
              
              Text(
                'Welcome to ${AppStrings.appName}. Your secure gold savings journey begins now.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              
              const Spacer(),
              
              SlgButton(
                text: 'LOGIN NOW',
                onPressed: () {
                  context.go('/auth/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
