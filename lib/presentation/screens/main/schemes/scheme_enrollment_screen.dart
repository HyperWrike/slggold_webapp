import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/core/constants/app_dimensions.dart';
import 'package:slg_golds/presentation/widgets/slg_button.dart';
import 'package:slg_golds/presentation/widgets/slg_card.dart';

class SchemeEnrollmentScreen extends StatefulWidget {
  const SchemeEnrollmentScreen({super.key});

  @override
  State<SchemeEnrollmentScreen> createState() => _SchemeEnrollmentScreenState();
}

class _SchemeEnrollmentScreenState extends State<SchemeEnrollmentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Schemes'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.goldDark,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.goldPrimary,
          tabs: const [
            Tab(text: 'Available'),
            Tab(text: 'Enrolled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAvailableSchemes(),
          _buildEnrolledSchemes(),
        ],
      ),
    );
  }

  Widget _buildAvailableSchemes() {
    // Dummy Data
    final availableSchemes = [
      {
        'title': 'Gold Plus Plan',
        'duration': '11 Months',
        'benefit': '1 Month Free Installment',
        'description': 'Pay 11 monthly installments and get the 12th installment free as a bonus from SLG Golds.',
      },
      {
        'title': 'Swarna Nidhi',
        'duration': '24 Months',
        'benefit': 'Extra Gold Grams',
        'description': 'A long term wealth building plan with pure gold added directly to your portfolio.',
      }
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.p24),
      itemCount: availableSchemes.length,
      itemBuilder: (context, index) {
        final scheme = availableSchemes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.p16),
          child: SlgCard(
            backgroundColor: AppColors.surfaceContainerLowest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      scheme['title']!,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(20),
                        borderRadius: BorderRadius.circular(AppDimensions.r4),
                      ),
                      child: Text(
                        scheme['duration']!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.p12),
                Text(
                  scheme['description']!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.p16),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.p12),
                  decoration: BoxDecoration(
                    color: AppColors.goldPrimary.withAlpha(20),
                    borderRadius: BorderRadius.circular(AppDimensions.r8),
                    border: Border.all(color: AppColors.goldPrimary.withAlpha(50)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.stars, color: AppColors.goldDark, size: 20),
                      const SizedBox(width: AppDimensions.p8),
                      Text(
                        'Benefit: ${scheme['benefit']}',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.goldDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.p24),
                SlgButton(
                  text: 'ENROLL NOW',
                  onPressed: () {
                    context.push('/schemes/enroll');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnrolledSchemes() {
    return const Center(
      child: Text('No active enrollments for this scheme type yet.'),
    );
  }
}
