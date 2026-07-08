import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/presentation/providers/auth_provider.dart';
import 'package:slg_golds/presentation/providers/user_data_provider.dart';
import 'package:intl/intl.dart';

class TransactionScreen extends ConsumerStatefulWidget {
  const TransactionScreen({super.key});

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final userId = authState.user?.id;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view transactions')),
      );
    }

    final transactionsAsync = ref.watch(userTransactionsProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          _buildTopAppBar(context),
          _buildFilterChips(),
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                final filtered = _applyFilter(transactions);

                if (filtered.isEmpty) {
                  return _buildEmptyState();
                }

                final grouped = _groupByMonth(filtered);

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ref.invalidate(userTransactionsProvider(userId));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    itemCount: grouped.length,
                    itemBuilder: (context, sectionIndex) {
                      final monthKey = grouped.keys.elementAt(sectionIndex);
                      final monthTxns = grouped[monthKey]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (sectionIndex == 0) const SizedBox(height: 16),
                          _buildMonthHeader(monthKey),
                          const SizedBox(height: 8),
                          ...monthTxns.map(
                            (txn) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildTransactionCard(txn),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
              error: (_, __) => _buildEmptyState(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context) {
    return Container(
      color: const Color(0xFFFAFAFA),
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Transactions',
                    style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: Filter/sort options
                    },
                    icon: const Icon(
                      Icons.filter_list,
                      color: AppColors.primary,
                    ),
                    splashRadius: 24,
                  ),
                ],
              ),
            ),
          ),
          Container(height: 1, color: AppColors.surfaceContainerHigh),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Gold', 'Silver', 'This Month', 'Custom Date'];

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;

          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(100),
                border: isSelected
                    ? null
                    : Border.all(color: AppColors.outlineVariant.withAlpha(51)),
              ),
              child: Center(
                child: Text(
                  filter,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? AppColors.onPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _applyFilter(
    List<Map<String, dynamic>> transactions,
  ) {
    switch (_selectedFilter) {
      case 'Gold':
        return transactions.where((t) {
          final desc = (t['description'] as String? ?? '').toLowerCase();
          final type = (t['type'] as String? ?? '').toLowerCase();
          return desc.contains('gold') || type == 'credit';
        }).toList();
      case 'Silver':
        return transactions.where((t) {
          final desc = (t['description'] as String? ?? '').toLowerCase();
          return desc.contains('silver');
        }).toList();
      case 'This Month':
        final now = DateTime.now();
        return transactions.where((t) {
          final dateStr = t['created_at'] as String?;
          if (dateStr == null) return false;
          final date = DateTime.parse(dateStr);
          return date.year == now.year && date.month == now.month;
        }).toList();
      default:
        return transactions;
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupByMonth(
    List<Map<String, dynamic>> transactions,
  ) {
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final txn in transactions) {
      final dateStr = txn['created_at'] as String?;
      if (dateStr == null) continue;

      final date = DateTime.parse(dateStr);
      final key = DateFormat('MMMM yyyy').format(date).toUpperCase();

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(txn);
    }

    return grouped;
  }

  Widget _buildMonthHeader(String month) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        month,
        style: const TextStyle(
          fontFamily: 'DM Mono',
          fontSize: 10,
          color: AppColors.outline,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> txn) {
    final amount = (txn['amount'] as num?)?.toDouble() ?? 0;
    final type = txn['type'] as String? ?? 'credit';
    final status = txn['status'] as String? ?? 'completed';
    final description =
        txn['description'] as String? ??
        (type == 'credit' ? 'Scheme Payment' : 'Direct Purchase');
    final createdAt = txn['created_at'] as String?;
    final dateStr = createdAt != null
        ? DateFormat('MMM dd hh:mm a').format(DateTime.parse(createdAt))
        : '';
    final netAmount = (txn['net_amount'] as num?)?.toDouble();
    final gst = (txn['gst'] as num?)?.toDouble();
    final goldWeight = txn['gold_grams'] ?? txn['gold_weight'];
    final silverWeight = txn['silver_grams'] ?? txn['silver_weight'];
    final isCredit = type == 'credit';
    final isGold =
        description.toLowerCase().contains('gold') || goldWeight != null;

    final hasDetails =
        netAmount != null ||
        gst != null ||
        goldWeight != null ||
        silverWeight != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0A795900),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: isGold
                          ? const LinearGradient(
                              colors: [Color(0xFFF5C842), Color(0xFFC8860A)],
                            )
                          : null,
                      color: isGold
                          ? null
                          : (isCredit
                                ? AppColors.primaryFixed.withAlpha(77)
                                : AppColors.surfaceContainerHigh),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getTransactionIcon(description, type),
                      color: isGold ? Colors.white : AppColors.outline,
                      size: 20,
                      fill: 1,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        description,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        dateStr.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                '${isCredit ? '+' : '-'}₹${NumberFormat('#,##0.00', 'en_IN').format(amount)}',
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isCredit
                      ? AppColors.primaryContainer
                      : AppColors.error,
                ),
              ),
            ],
          ),
          if (hasDetails) ...[
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.only(top: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.surfaceContainerHigh),
                  ),
                ),
                child: Column(
                  children: [
                    if (netAmount != null && gst != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDetailItem(
                            'Net Amount',
                            '₹${NumberFormat('#,##0.00', 'en_IN').format(netAmount)}',
                          ),
                          _buildDetailItem(
                            'GST (${(netAmount > 0 ? (gst / netAmount * 100) : 3.0).toStringAsFixed(0)}%)',
                            '₹${NumberFormat('#,##0.00', 'en_IN').format(gst)}',
                            alignEnd: true,
                          ),
                        ],
                      ),
                    if ((goldWeight != null || silverWeight != null) &&
                        netAmount != null)
                      const SizedBox(height: 12),
                    if (goldWeight != null || silverWeight != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDetailItem(
                            goldWeight != null
                                ? 'Gold Weight'
                                : 'Silver Weight',
                            '${(goldWeight ?? silverWeight)}g',
                            valueColor: AppColors.primary,
                          ),
                          _buildDetailItem(
                            'Gross',
                            '₹${NumberFormat('#,##0.00', 'en_IN').format(amount)}',
                            alignEnd: true,
                          ),
                        ],
                      ),
                    if (goldWeight != null && netAmount == null)
                      _buildDetailItem(
                        'Gold Weight',
                        '${goldWeight}g',
                        valueColor: AppColors.primary,
                      ),
                    if (silverWeight != null &&
                        netAmount == null &&
                        goldWeight == null)
                      _buildDetailItem(
                        'Silver Weight',
                        '${silverWeight}g',
                        valueColor: AppColors.textSecondary,
                      ),
                  ],
                ),
              ),
            ),
          ],
          if (status != 'completed')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: status == 'pending'
                        ? const Color(0xFFFFF3E0)
                        : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: status == 'pending'
                          ? const Color(0xFFE65100)
                          : AppColors.error,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    String label,
    String value, {
    Color? valueColor,
    bool alignEnd = false,
  }) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.outline,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'DM Mono',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  IconData _getTransactionIcon(String description, String type) {
    final desc = description.toLowerCase();
    if (desc.contains('gold') || desc.contains('plan')) {
      return Icons.workspace_premium;
    }
    if (desc.contains('silver') || desc.contains('sip')) {
      return Icons.toll;
    }
    if (desc.contains('wallet') || desc.contains('top')) {
      return Icons.account_balance_wallet;
    }
    if (desc.contains('bond') || desc.contains('sovereign')) {
      return Icons.monetization_on;
    }
    if (type == 'credit') {
      return Icons.savings;
    }
    return Icons.shopping_bag;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppColors.outlineVariant,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Transactions',
            style: TextStyle(
              fontFamily: 'Cormorant Garamond',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your transaction history will appear here.',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
