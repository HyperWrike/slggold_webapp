import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/core/constants/app_dimensions.dart';
import 'package:slg_golds/presentation/widgets/slg_card.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);
    
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            onPressed: () {
              context.go('/admin/login');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.p24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Overview',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppDimensions.p16),
              
              // Top Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: 'Total Customers',
                      value: '1,245',
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.p16),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: 'Active Schemes',
                      value: '12',
                      icon: Icons.list_alt,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.p16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: 'Today Collection',
                      value: formatCurrency.format(450000),
                      icon: Icons.money,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.p16),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: 'Gold Reserve Weight',
                      value: '4.5 KG',
                      icon: Icons.diamond,
                      color: AppColors.goldPrimary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.p48),
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppDimensions.p16),
              
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppDimensions.p16,
                crossAxisSpacing: AppDimensions.p16,
                childAspectRatio: 1.5,
                children: [
                  _buildActionCard(
                    context,
                    title: 'Add Scheme',
                    icon: Icons.add_card,
                    onTap: () {
                      context.push('/admin/schemes/create');
                    },
                  ),
                  _buildActionCard(
                    context,
                    title: 'Collect Payment',
                    icon: Icons.payment,
                    onTap: () {},
                  ),
                  _buildActionCard(
                    context,
                    title: 'Update GST Rate',
                    icon: Icons.percent,
                    onTap: () {
                      context.go('/admin/gst');
                    },
                  ),
                  _buildActionCard(
                    context,
                    title: 'Generate Reports',
                    icon: Icons.download,
                    onTap: () {
                      context.go('/admin/reports');
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.p48), // Bottom nav padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return SlgCard(
      backgroundColor: color.withAlpha(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppDimensions.p16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.p4),
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.r16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppDimensions.r16),
          border: Border.all(color: AppColors.surfaceContainerHigh),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.goldPrimary, size: 32),
            const SizedBox(height: AppDimensions.p12),
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
