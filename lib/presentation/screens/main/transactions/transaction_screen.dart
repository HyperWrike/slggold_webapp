import 'package:flutter/material.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/core/constants/app_dimensions.dart';
import 'package:slg_golds/presentation/widgets/transaction_card.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  int _selectedFilter = 0; // 0: All, 1: Credits, 2: Debits

  final List<Map<String, dynamic>> _allTransactions = [
    {
      'title': 'Installment - Gold Plus',
      'date': '12 Oct 2023, 10:30 AM',
      'amount': 5000.0,
      'isCredit': true,
      'status': 'Completed'
    },
    {
      'title': 'Account Setup Fee',
      'date': '01 Oct 2023, 09:15 AM',
      'amount': 500.0,
      'isCredit': false,
      'status': 'Completed'
    },
    {
      'title': 'Installment - Swarna Nidhi',
      'date': '25 Sep 2023, 02:45 PM',
      'amount': 2500.0,
      'isCredit': true,
      'status': 'Pending'
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> displayedTransactions;
    if (_selectedFilter == 1) {
      displayedTransactions = _allTransactions.where((t) => t['isCredit'] == true).toList();
    } else if (_selectedFilter == 2) {
      displayedTransactions = _allTransactions.where((t) => t['isCredit'] == false).toList();
    } else {
      displayedTransactions = _allTransactions;
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: AppColors.goldPrimary),
            onPressed: () {
              // Download statement
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Filter Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p24, vertical: AppDimensions.p16),
              child: Row(
                children: [
                  _buildFilterTab(0, 'All'),
                  const SizedBox(width: AppDimensions.p12),
                  _buildFilterTab(1, 'In'),
                  const SizedBox(width: AppDimensions.p12),
                  _buildFilterTab(2, 'Out'),
                ],
              ),
            ),
            
            // Transaction List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p24),
                itemCount: displayedTransactions.length,
                itemBuilder: (context, index) {
                  final t = displayedTransactions[index];
                  return TransactionCard(
                    title: t['title'],
                    date: t['date'],
                    amount: t['amount'],
                    isCredit: t['isCredit'],
                    status: t['status'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(int index, String label) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.goldPrimary : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppDimensions.r100),
          border: Border.all(
            color: isSelected ? AppColors.goldPrimary : AppColors.surfaceContainerHigh,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isSelected ? AppColors.surface : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
