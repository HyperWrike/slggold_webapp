import 'package:flutter/material.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/core/constants/app_dimensions.dart';
import 'package:slg_golds/presentation/widgets/slg_button.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.p24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Generate Reports',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppDimensions.p8),
              Text(
                'Select a report type to download as CSV or PDF.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.p32),
              
              _buildReportCard(
                context,
                title: 'Daily Collection Report',
                description: 'Summary of all transactions collected today.',
                icon: Icons.calendar_today,
                onTap: () {},
              ),
              const SizedBox(height: AppDimensions.p16),
              
              _buildReportCard(
                context,
                title: 'Scheme Enrollment Report',
                description: 'List of all active scheme enrollments and their progress.',
                icon: Icons.list_alt,
                onTap: () {},
              ),
              const SizedBox(height: AppDimensions.p16),
              
              _buildReportCard(
                context,
                title: 'Customer Ledger PDF',
                description: 'Detailed statement of account for a specific customer. Contains GST breakdown.',
                icon: Icons.picture_as_pdf,
                onTap: () {},
              ),
              const SizedBox(height: AppDimensions.p16),
              
              _buildReportCard(
                context,
                title: 'GST Liability Report',
                description: 'Monthly summary of GST collected for tax filing compliance.',
                icon: Icons.receipt_long,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, {required String title, required String description, required IconData icon, required VoidCallback onTap}) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.p16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppDimensions.r12),
        border: Border.all(color: AppColors.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.goldPrimary, size: 28),
              const SizedBox(width: AppDimensions.p16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.p12),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.p16),
          SlgButton(
            text: 'DOWNLOAD',
            onPressed: onTap,
            isSecondary: true,
          ),
        ],
      ),
    );
  }
}
