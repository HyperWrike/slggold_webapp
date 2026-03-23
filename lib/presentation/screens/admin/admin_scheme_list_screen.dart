import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/core/constants/app_dimensions.dart';
import 'package:slg_golds/presentation/widgets/slg_card.dart';

class AdminSchemeListScreen extends StatelessWidget {
  const AdminSchemeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Manage Schemes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.goldPrimary,
        icon: const Icon(Icons.add, color: AppColors.surface),
        label: const Text('New Scheme', style: TextStyle(color: AppColors.surface)),
        onPressed: () {
          context.push('/admin/schemes/create');
        },
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.p24),
          itemCount: 2, // Dummy count
          itemBuilder: (context, index) {
            final title = index == 0 ? 'Gold Plus Plan' : 'Swarna Nidhi';
            final status = index == 0 ? 'Active' : 'Inactive';
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.p16),
              child: SlgCard(
                backgroundColor: AppColors.surfaceContainerLowest,
                onTap: () {
                  // View/Edit scheme details
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.stars, color: AppColors.goldDark),
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
                            index == 0 ? '11 Months • Free 12th Month' : '24 Months • Gold Benefit',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: status == 'Active' ? AppColors.success.withAlpha(20) : AppColors.error.withAlpha(20),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: status == 'Active' ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
