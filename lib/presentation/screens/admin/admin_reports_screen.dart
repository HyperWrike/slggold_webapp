import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/presentation/providers/auth_provider.dart';
import 'package:slg_golds/presentation/providers/user_data_provider.dart';
import 'package:intl/intl.dart';

class AdminReportsScreen extends ConsumerStatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  ConsumerState<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends ConsumerState<AdminReportsScreen> {
  String _selectedPeriod = 'This Month';
  Map<String, dynamic> _reportData = {};
  List<Map<String, dynamic>> _schemePerformance = [];
  List<Map<String, dynamic>> _weeklyCollections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    setState(() => _isLoading = true);
    try {
      final db = ref.read(databaseServiceProvider);
      final stats = await ref.read(adminStatsProvider.future);

      // Load all transactions
      final txns = await db.getAllTransactions(limit: 500);
      final customers = await db.getAllCustomers();
      final schemes = await db.getAvailableSchemes();

      // Calculate total collections
      double totalCollections = 0;
      double totalGst = 0;
      for (final txn in txns) {
        totalCollections += (txn['amount'] as num?)?.toDouble() ?? 0;
        totalGst += (txn['gst'] as num?)?.toDouble() ?? 0;
      }

      // Load enrollments for scheme performance
      final enrollments = await db.getAllEnrollmentsForReports();

      // Build scheme performance data
      List<Map<String, dynamic>> schemePerf = [];
      for (final scheme in schemes) {
        final schemeId = scheme['id']?.toString() ?? '';
        final schemeName = scheme['name'] as String? ?? '';
        final relatedEnrollments = enrollments
            .where((e) => e['scheme_id']?.toString() == schemeId)
            .toList();

        int activeCount = 0;
        double totalRevenue = 0;
        double totalTenure = 0;
        for (final e in relatedEnrollments) {
          if (e['status'] == 'active') activeCount++;
          totalRevenue += (e['paid_amount'] as num?)?.toDouble() ?? 0;
          totalTenure += (e['paid_months'] as int?)?.toDouble() ?? 0;
        }

        final avgTenure = relatedEnrollments.isNotEmpty
            ? totalTenure / relatedEnrollments.length
            : 0.0;

        schemePerf.add({
          'name': schemeName,
          'activeEnrolled': activeCount,
          'avgTenure': avgTenure,
          'revenue': totalRevenue,
        });
      }

      // Build weekly collections (last 5 weeks)
      List<Map<String, dynamic>> weekly = [];
      final now = DateTime.now();
      for (int i = 4; i >= 0; i--) {
        final weekStart = now.subtract(
          Duration(days: now.weekday - 1 + (i * 7)),
        );
        final weekEnd = weekStart.add(const Duration(days: 7));
        double weekAmount = 0;
        for (final txn in txns) {
          final createdAt = txn['created_at'] as String?;
          if (createdAt != null) {
            final date = DateTime.parse(createdAt);
            if (date.isAfter(weekStart) && date.isBefore(weekEnd)) {
              weekAmount += (txn['amount'] as num?)?.toDouble() ?? 0;
            }
          }
        }
        weekly.add({'label': 'Wk ${5 - i}', 'amount': weekAmount});
      }

      // Gold weight estimate (at ~7850/gram)
      double totalGoldWeight = 0;
      for (final e in enrollments) {
        totalGoldWeight += (e['total_gold_grams'] as num?)?.toDouble() ?? 0;
      }

      if (mounted) {
        setState(() {
          _reportData = {
            'totalCollections': totalCollections,
            'totalCustomers': customers.length,
            'totalGst': totalGst,
            'totalGoldWeight': totalGoldWeight,
            ...stats,
          };
          _schemePerformance = schemePerf;
          _weeklyCollections = weekly;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.simpleCurrency(
      locale: 'en_IN',
      decimalDigits: 0,
    );

    final totalCollections =
        (_reportData['totalCollections'] as num?)?.toDouble() ?? 0;
    final totalCustomers = (_reportData['totalCustomers'] as int?) ?? 0;
    final totalGst = (_reportData['totalGst'] as num?)?.toDouble() ?? 0;
    final totalGoldWeight =
        (_reportData['totalGoldWeight'] as num?)?.toDouble() ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadReportData,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  children: [
                    _buildTopAppBar(),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Performance Reports',
                                    style: TextStyle(
                                      fontFamily: 'Cormorant Garamond',
                                      fontSize: 36,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Detailed analysis of collections, schemes, and tax liabilities.',
                                    style: TextStyle(
                                      color: const Color(0xFF5E5E5F),
                                    ),
                                  ),
                                ],
                              ),
                              OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Export feature coming soon',
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.download, size: 16),
                                label: const Text('Export Report'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF1E3A5F),
                                  side: const BorderSide(
                                    color: Color(0xFF1E3A5F),
                                    width: 2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Date Range Chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children:
                                  [
                                        'This Month',
                                        'Last Month',
                                        'Last Quarter',
                                        'Financial Year',
                                      ]
                                      .map(
                                        (p) => Padding(
                                          padding: const EdgeInsets.only(
                                            right: 12,
                                          ),
                                          child: _buildPeriodChip(p),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // KPI Bento Grid
                          _buildKpiGrid(
                            totalCollections,
                            totalCustomers,
                            totalGst,
                            totalGoldWeight,
                            formatCurrency,
                          ),
                          const SizedBox(height: 24),

                          // Charts Row
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth > 600;
                              if (isWide) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: _buildCollectionTrends(
                                        formatCurrency,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      flex: 1,
                                      child: _buildGstBreakdown(
                                        totalCollections,
                                        formatCurrency,
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return Column(
                                children: [
                                  _buildCollectionTrends(formatCurrency),
                                  const SizedBox(height: 16),
                                  _buildGstBreakdown(
                                    totalCollections,
                                    formatCurrency,
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // Scheme Performance Table
                          _buildSchemeTable(formatCurrency),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SLG Golds',
                style: TextStyle(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E3A5F),
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryFixed,
                  border: Border.all(
                    color: AppColors.outlineVariant.withAlpha(51),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'A',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = period),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1E3A5F)
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(100),
          border: isSelected
              ? null
              : Border.all(color: AppColors.outlineVariant.withAlpha(77)),
        ),
        child: Text(
          period,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildKpiGrid(
    double totalCollections,
    int totalCustomers,
    double totalGst,
    double totalGoldWeight,
    NumberFormat formatCurrency,
  ) {
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: MediaQuery.of(context).size.width > 600 ? 1.5 : 1.3,
      children: [
        _buildKpiCard(
          label: 'Total Collections',
          value: formatCurrency.format(totalCollections),
          icon: Icons.payments,
          color: AppColors.primary,
        ),
        _buildKpiCard(
          label: 'New Enrolments',
          value: '$totalCustomers',
          icon: Icons.person_add,
          color: AppColors.primary,
        ),
        _buildKpiCard(
          label: 'GST Collected',
          value: formatCurrency.format(totalGst),
          icon: Icons.receipt_long,
          color: AppColors.primary,
        ),
        _buildKpiCard(
          label: 'Gold Weight Equivalent',
          value: '${(totalGoldWeight / 1000).toStringAsFixed(3)} KG',
          icon: Icons.diamond,
          isGoldGradient: true,
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String label,
    required String value,
    required IconData icon,
    Color? color,
    bool isGoldGradient = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isGoldGradient
            ? const LinearGradient(
                colors: [Color(0xFFF5C842), Color(0xFFC8860A)],
              )
            : null,
        color: isGoldGradient ? null : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0F795900),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isGoldGradient
                        ? Colors.white70
                        : const Color(0xFFA8A29E),
                    letterSpacing: 0.1 * 10,
                  ),
                ),
              ),
              Icon(
                icon,
                color: isGoldGradient
                    ? Colors.white70
                    : (color ?? AppColors.primary),
                size: 20,
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isGoldGradient ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionTrends(NumberFormat formatCurrency) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Collection Trends',
                style: TextStyle(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  _buildLegendDot(const Color(0xFFD4A017), 'Revenue'),
                  const SizedBox(width: 12),
                  _buildLegendDot(
                    AppColors.surfaceContainerHighest,
                    'Previous',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Bar Chart
          SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _weeklyCollections.map((week) {
                final amount = (week['amount'] as num?)?.toDouble() ?? 0;
                final maxAmount = _weeklyCollections.fold<double>(0, (max, w) {
                  final wAmount = (w['amount'] as num?)?.toDouble() ?? 0;
                  return wAmount > max ? wAmount : max;
                });
                final heightFactor = maxAmount > 0
                    ? (amount / maxAmount).clamp(0.05, 1.0)
                    : 0.1;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: FractionallySizedBox(
                            heightFactor: heightFactor,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primaryFixed,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          week['label'] as String? ?? '',
                          style: const TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 10,
                            color: Color(0xFFA8A29E),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFFA8A29E)),
        ),
      ],
    );
  }

  Widget _buildGstBreakdown(
    double totalCollections,
    NumberFormat formatCurrency,
  ) {
    final cgst = totalCollections * 0.015;
    final sgst = totalCollections * 0.015;
    final igst = totalCollections * 0.03;
    final totalLiability = cgst + sgst;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'GST Breakdown',
            style: TextStyle(
              fontFamily: 'Cormorant Garamond',
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          _buildGstRow('CGST (1.5%)', 'Intra-state Tax', cgst, formatCurrency),
          _buildGstRow('SGST (1.5%)', 'State Levy', sgst, formatCurrency),
          _buildGstRow('IGST (3.0%)', 'Inter-state Tax', 0, formatCurrency),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Liability',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1 * 12,
                  ),
                ),
                Text(
                  formatCurrency.format(totalLiability),
                  style: const TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGstRow(
    String label,
    String sub,
    double amount,
    NumberFormat fmt,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                sub,
                style: const TextStyle(fontSize: 12, color: Color(0xFFA8A29E)),
              ),
            ],
          ),
          Text(
            fmt.format(amount),
            style: const TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeTable(NumberFormat formatCurrency) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Scheme Performance',
                  style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${_schemePerformance.length} schemes',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Table Header
          Container(
            color: AppColors.surfaceContainerLow,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'SCHEME NAME',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFA8A29E),
                      letterSpacing: 0.1 * 10,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'ACTIVE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFA8A29E),
                      letterSpacing: 0.1 * 10,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'AVG TENURE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFA8A29E),
                      letterSpacing: 0.1 * 10,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'REVENUE',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFA8A29E),
                      letterSpacing: 0.1 * 10,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table Rows
          ..._schemePerformance.map(
            (scheme) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.surfaceContainerHigh),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      scheme['name'] as String? ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${scheme['activeEnrolled']} Users',
                      style: const TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${(scheme['avgTenure'] as num).toStringAsFixed(1)} Months',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      formatCurrency.format(scheme['revenue']),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontFamily: 'DM Mono',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_schemePerformance.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No scheme data yet',
                  style: TextStyle(color: Color(0xFFA8A29E)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
