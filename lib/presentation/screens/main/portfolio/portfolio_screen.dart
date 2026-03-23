import 'package:flutter/material.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/core/constants/app_dimensions.dart';
import 'package:slg_golds/presentation/widgets/enrollment_card.dart';
import 'package:intl/intl.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('My Portfolio'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.p24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Card
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.p24),
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(AppDimensions.r16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.goldPrimary.withAlpha(50),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Gold Accumulated',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.surface,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.p8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '12.500',
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: AppColors.surface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.p8),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  'grams',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.surface.withAlpha(200),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.p24),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surface.withAlpha(50),
                              borderRadius: BorderRadius.circular(AppDimensions.r8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Current Value',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.surface,
                                  ),
                                ),
                                Text(
                                  formatCurrency.format(87500), // Dummy calculation
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.surface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.p32),
                    
                    Text(
                      'Active Enrollments',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppDimensions.p16),
                  ],
                ),
              ),
            ),
            
            // Enrollment List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // Dummy data
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppDimensions.p16),
                      child: EnrollmentCard(
                        schemeName: index == 0 ? 'Gold Plus Plan' : 'Swarna Nidhi',
                        monthlyAmount: 5000,
                        totalMonths: 11,
                        paidMonths: index == 0 ? 5 : 2,
                        nextDueDate: DateTime.now().add(const Duration(days: 5)),
                      ),
                    );
                  },
                  childCount: 2,
                ),
              ),
            ),
            
            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.p48), // Padding for shell
            ),
          ],
        ),
      ),
    );
  }
}
