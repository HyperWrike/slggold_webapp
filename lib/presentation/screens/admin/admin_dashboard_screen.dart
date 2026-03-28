import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/data/datasources/database_service.dart';
import 'package:slg_golds/presentation/providers/user_data_provider.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _recentTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load admin stats
      final statsAsync = await ref.read(adminStatsProvider.future);

      // Load recent transactions with user names via database service
      final db = ref.read(databaseServiceProvider);
      final txns = await db.getAllTransactions(limit: 10);

      // Compute highest and lowest from transactions
      double highest = 0;
      double lowest = double.infinity;
      for (final txn in txns) {
        final amount = (txn['amount'] as num?)?.toDouble() ?? 0;
        if (amount > highest) highest = amount;
        if (amount > 0 && amount < lowest) lowest = amount;
      }
      if (lowest == double.infinity) lowest = 0;

      // Add computed stats to the map
      final stats = Map<String, dynamic>.from(statsAsync);
      stats['highestAmount'] = highest;
      stats['lowestAmount'] = lowest;

      if (mounted) {
        setState(() {
          _stats = stats;
          _recentTransactions = txns;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.simpleCurrency(
      locale: 'en_IN',
      decimalDigits: 0,
    );

    final totalCustomers = (_stats['totalCustomers'] as int?) ?? 0;
    final activeSchemes = (_stats['activeSchemes'] as int?) ?? 0;
    final todayCollection =
        (_stats['todayCollection'] as num?)?.toDouble() ?? 0;
    final totalAUM = (_stats['totalAUM'] as num?)?.toDouble() ?? 0;
    final todayTxnCount = (_stats['todayTxnCount'] as int?) ?? 0;
    final highestAmount = (_stats['highestAmount'] as num?)?.toDouble() ?? 0;
    final lowestAmount = (_stats['lowestAmount'] as num?)?.toDouble() ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // TopAppBar
            SliverToBoxAdapter(child: _buildTopAppBar()),

            // Welcome Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Executive Dashboard',
                      style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Real-time oversight of the SLG Gold Ecosystem',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        color: const Color(0xFFA8A29E),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // KPI Grid
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(48),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildKpiCard(
                                  icon: Icons.group,
                                  iconColor: Colors.blue,
                                  iconBgColor: Colors.blue.withAlpha(26),
                                  label: 'Total Members',
                                  value: NumberFormat(
                                    '#,##0',
                                    'en_IN',
                                  ).format(totalCustomers),
                                  badge: '+12%',
                                  badgeColor: Colors.blue,
                                  bottomColor: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildKpiCard(
                                  icon: Icons.account_balance_wallet,
                                  iconColor: AppColors.primary,
                                  iconBgColor: AppColors.primaryFixed.withAlpha(
                                    77,
                                  ),
                                  label: 'Total AUM',
                                  value: totalAUM > 0
                                      ? formatCurrency.format(totalAUM)
                                      : '₹0',
                                  badge: 'STABLE',
                                  badgeColor: AppColors.primary,
                                  bottomGradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFF5C842),
                                      Color(0xFFC8860A),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildKpiCard(
                                  icon: Icons.payments,
                                  iconColor: const Color(0xFF059669),
                                  iconBgColor: const Color(
                                    0xFF059669,
                                  ).withAlpha(26),
                                  label: "Today's Collections",
                                  value: formatCurrency.format(todayCollection),
                                  badge: 'LIVE',
                                  badgeColor: const Color(0xFF059669),
                                  bottomColor: const Color(0xFF059669),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildKpiCard(
                                  icon: Icons.grid_view,
                                  iconColor: const Color(0xFF9333EA),
                                  iconBgColor: const Color(
                                    0xFF9333EA,
                                  ).withAlpha(26),
                                  label: 'Active Schemes',
                                  value: '$activeSchemes',
                                  badge: 'ALL OK',
                                  badgeColor: const Color(0xFF9333EA),
                                  bottomColor: const Color(0xFF9333EA),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),

            // Flash Stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Flash Stats',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFA8A29E),
                        letterSpacing: 0.1 * 12,
                      ),
                    ),
                    _buildFlashStat(
                      dotColor: const Color(0xFF059669),
                      label: 'Highest',
                      value: highestAmount > 0
                          ? formatCurrency.format(highestAmount)
                          : '₹0',
                    ),
                    _buildFlashStat(
                      dotColor: const Color(0xFFE11D48),
                      label: 'Lowest',
                      value: lowestAmount > 0
                          ? formatCurrency.format(lowestAmount)
                          : '₹0',
                    ),
                    _buildFlashStat(
                      dotColor: Colors.blue,
                      label: 'Today Txns',
                      value: '$todayTxnCount',
                    ),
                  ],
                ),
              ),
            ),

            // Recent Transactions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/admin/reports'),
                      child: const Text(
                        'View All Ledger',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Transaction List
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Container(
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
                  child: _recentTransactions.isNotEmpty
                      ? Column(
                          children: _recentTransactions
                              .take(8)
                              .map((txn) => _buildTransactionTile(txn))
                              .toList(),
                        )
                      : _buildDefaultTransactions(),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          // Drawer or menu
                        },
                        icon: const Icon(Icons.menu, color: Color(0xFF1E3A5F)),
                        splashRadius: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'SLG Golds',
                        style: TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E3A5F),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text(
                            'ADMIN_SECURE',
                            style: TextStyle(
                              fontFamily: 'DM Mono',
                              fontSize: 10,
                              color: Color(0xFFA8A29E),
                            ),
                          ),
                          Text(
                            'Master Vault',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryFixedDim,
                            width: 2,
                          ),
                          color: AppColors.primaryFixed,
                        ),
                        child: const Center(
                          child: Text(
                            'A',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(height: 1, color: const Color(0xFFF1F5F9)),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String value,
    required String badge,
    required Color badgeColor,
    Color? bottomColor,
    Gradient? bottomGradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  Text(
                    badge,
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: badgeColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFA8A29E),
                  letterSpacing: 0.1 * 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: bottomColor,
                gradient: bottomGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashStat({
    required Color dotColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0xFFF8FAFC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(Map<String, dynamic> txn) {
    final amount = (txn['amount'] as num?)?.toDouble() ?? 0;
    final createdAt = txn['created_at'] as String?;
    final timeStr = createdAt != null
        ? DateFormat('hh:mm a').format(DateTime.parse(createdAt))
        : '';
    final description = txn['description'] as String? ?? 'Payment';

    // Get user name from the data we attached via database service
    String userName = txn['user_name'] as String? ?? '';

    // Fallback: try joined profile data
    if (userName.isEmpty) {
      final profile = txn['profiles'] as Map<String, dynamic>?;
      userName = profile?['full_name'] as String? ?? '';
    }

    // Fallback: use username
    if (userName.isEmpty) {
      userName = txn['user_username'] as String? ?? 'Customer';
    }

    final initials = userName.isNotEmpty
        ? userName
              .split(' ')
              .take(2)
              .map((n) => n.isNotEmpty ? n[0] : '')
              .join()
              .toUpperCase()
        : 'C';

    return InkWell(
      onTap: () => context.go('/admin/customers'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFA8A29E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+${NumberFormat('#,##0', 'en_IN').format(amount)}',
                  style: const TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF059669),
                  ),
                ),
                Text(
                  timeStr,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFA8A29E),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultTransactions() {
    final defaults = [
      {
        'name': 'Arjun Rao',
        'initials': 'AR',
        'desc': 'Gold Savings Plan (A-12)',
        'amount': 5000,
        'time': '10:42 AM',
      },
      {
        'name': 'Priya Sharma',
        'initials': 'PS',
        'desc': 'Jewelry Accumulation',
        'amount': 12000,
        'time': '09:15 AM',
      },
      {
        'name': 'Vikram Singh',
        'initials': 'VS',
        'desc': 'Instant Gold Buy',
        'amount': 2500,
        'time': 'Yesterday',
      },
      {
        'name': 'Meera Kulkarni',
        'initials': 'MK',
        'desc': 'SIP Installment',
        'amount': 1000,
        'time': 'Yesterday',
      },
      {
        'name': 'Suresh Iyer',
        'initials': 'SI',
        'desc': 'Special Festival Offer',
        'amount': 4000,
        'time': 'Yesterday',
      },
    ];

    return Column(
      children: defaults.map((d) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        d['initials'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d['name'] as String,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        d['desc'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFA8A29E),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+₹${NumberFormat('#,##0', 'en_IN').format(d['amount'])}',
                    style: const TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF059669),
                    ),
                  ),
                  Text(
                    d['time'] as String,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFFA8A29E),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
