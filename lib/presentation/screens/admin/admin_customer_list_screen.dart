import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/core/constants/app_dimensions.dart';

class AdminCustomerListScreen extends StatefulWidget {
  const AdminCustomerListScreen({super.key});

  @override
  State<AdminCustomerListScreen> createState() => _AdminCustomerListScreenState();
}

class _AdminCustomerListScreenState extends State<AdminCustomerListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Customers'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.separated(
          itemCount: 15,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: AppDimensions.p24, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: AppColors.goldPrimary.withAlpha(50),
                child: const Icon(Icons.person, color: AppColors.goldDark),
              ),
              title: Text('Customer ${index + 1}'),
              subtitle: Text('+91 987654321${index % 10}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                context.push('/admin/customers/customer-${index + 1}');
              },
            );
          },
        ),
      ),
    );
  }
}
