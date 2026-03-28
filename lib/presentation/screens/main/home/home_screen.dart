import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/presentation/providers/metal_price_provider.dart';
import 'package:slg_golds/presentation/providers/auth_provider.dart';
import 'package:slg_golds/presentation/providers/user_data_provider.dart';
import 'package:slg_golds/presentation/widgets/notification_popup.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final metalPricesAsync = ref.watch(metalPricesProvider);
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    final portfolioAsync = user != null
        ? ref.watch(portfolioSummaryProvider(user.id))
        : null;
    final enrollmentsAsync = user != null
        ? ref.watch(userEnrollmentsProvider(user.id))
        : null;
    final transactionsAsync = user != null
        ? ref.watch(userTransactionsProvider(user.id))
        : null;
    final schemesAsync = ref.watch(availableSchemesProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(metalPricesProvider);
          if (user != null) {
            ref.invalidate(portfolioSummaryProvider(user.id));
            ref.invalidate(userEnrollmentsProvider(user.id));
            ref.invalidate(userTransactionsProvider(user.id));
          }
          ref.invalidate(availableSchemesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            children: [
              _buildTopAppBar(context, user?.fullName ?? 'User'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Section 1: LIVE METAL PRICES
                    _buildLivePricesSection(context, metalPricesAsync),

                    const SizedBox(height: 40),

                    // Section 2: PORTFOLIO GLANCE
                    _buildPortfolioGlanceSection(
                      context,
                      portfolioAsync,
                      enrollmentsAsync,
                    ),

                    const SizedBox(height: 40),

                    // Section 3: SAVINGS SCHEMES
                    _buildSchemesSection(context, schemesAsync),

                    const SizedBox(height: 40),

                    // Section 4: RECENT ACTIVITY
                    _buildRecentActivitySection(context, transactionsAsync),

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

  Widget _buildTopAppBar(BuildContext context, String userName) {
    final greeting = _getGreeting();
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
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/profile'),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.outlineVariant.withAlpha(51),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Center(
                              child: Text(
                                userName.isNotEmpty
                                    ? userName.substring(0, 1).toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$greeting, ${userName.split(' ').first} 👋',
                        style: const TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => NotificationPopup.show(context),
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFFA8A29E),
                    ),
                    splashRadius: 24,
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 1,
            color: AppColors.surfaceContainerHigh,
            constraints: const BoxConstraints(maxWidth: 512),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildLivePricesSection(
    BuildContext context,
    AsyncValue<dynamic> metalPricesAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Market Pulse',
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 10,
                    color: AppColors.outline,
                    letterSpacing: 0.1 * 10,
                  ),
                ),
                const Text(
                  'Live Prices',
                  style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Updated ${DateFormat('h:mm a').format(DateTime.now())}',
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: metalPricesAsync.when(
                data: (prices) => _buildMetalCard(
                  isGold: true,
                  label: '🥇 GOLD 24K',
                  pricePerGram: prices.goldPricePerGram,
                  pricePerOz: prices.goldPricePerGram * 31.1035,
                  changePercent: '+0.82%',
                  isPositive: true,
                ),
                loading: () => _buildMetalCard(
                  isGold: true,
                  label: '🥇 GOLD 24K',
                  pricePerGram: null,
                  pricePerOz: null,
                  changePercent: '--',
                  isPositive: true,
                  isLoading: true,
                ),
                error: (_, __) => _buildMetalCard(
                  isGold: true,
                  label: '🥇 GOLD 24K',
                  pricePerGram: 7850.0,
                  pricePerOz: 7850.0 * 31.1035,
                  changePercent: '--',
                  isPositive: true,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: metalPricesAsync.when(
                data: (prices) => _buildMetalCard(
                  isGold: false,
                  label: '⬜ SILVER',
                  pricePerGram: prices.silverPricePerGram,
                  pricePerOz: prices.silverPricePerGram * 31.1035,
                  changePercent: '-0.3%',
                  isPositive: false,
                ),
                loading: () => _buildMetalCard(
                  isGold: false,
                  label: '⬜ SILVER',
                  pricePerGram: null,
                  pricePerOz: null,
                  changePercent: '--',
                  isPositive: false,
                  isLoading: true,
                ),
                error: (_, __) => _buildMetalCard(
                  isGold: false,
                  label: '⬜ SILVER',
                  pricePerGram: 95.0,
                  pricePerOz: 95.0 * 31.1035,
                  changePercent: '--',
                  isPositive: false,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetalCard({
    required bool isGold,
    required String label,
    required double? pricePerGram,
    required double? pricePerOz,
    required String changePercent,
    required bool isPositive,
    bool isLoading = false,
  }) {
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isGold
                ? [const Color(0xFFF5C842), const Color(0xFFC8860A)]
                : [const Color(0xFFC0C0C0), const Color(0xFF707070)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color:
                  (isGold ? const Color(0xFFF5C842) : const Color(0xFFC0C0C0))
                      .withAlpha(77),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.2 * 10,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isPositive
                                  ? Colors.white.withAlpha(51)
                                  : Colors.black.withAlpha(26),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              changePercent,
                              style: TextStyle(
                                fontFamily: 'DM Mono',
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        pricePerGram != null
                            ? '₹${NumberFormat('#,##0.00', 'en_IN').format(pricePerGram)}'
                            : '--',
                        style: const TextStyle(
                          fontFamily: 'DM Mono',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'per gram',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  // Bottom section
                  Container(
                    padding: const EdgeInsets.only(top: 16),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.white24)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pricePerOz != null
                              ? '₹ ${NumberFormat('#,##0', 'en_IN').format(pricePerOz)}'
                              : '--',
                          style: const TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          '/ troy oz',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 9,
                            color: Colors.white60,
                            letterSpacing: 0.1 * 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPortfolioGlanceSection(
    BuildContext context,
    AsyncValue<Map<String, dynamic>>? portfolioAsync,
    AsyncValue<List<Map<String, dynamic>>>? enrollmentsAsync,
  ) {
    double totalGold = 0;
    double totalSilver = 0;
    String nextPaymentDate = '--';

    if (portfolioAsync != null) {
      portfolioAsync.whenData((data) {
        totalGold = (data['totalGoldGrams'] as num?)?.toDouble() ?? 0;
      });
    }

    if (enrollmentsAsync != null) {
      enrollmentsAsync.whenData((enrollments) {
        for (final e in enrollments) {
          final scheme = e['schemes'] as Map<String, dynamic>?;
          final metalType = scheme?['metal_type'] as String? ?? 'gold';
          final grams = (e['total_gold_grams'] as num?)?.toDouble() ?? 0;
          if (metalType == 'silver') {
            totalSilver += grams;
          } else {
            totalGold += grams;
          }

          // Calculate next payment date
          final tenureMonths = (e['tenure_months'] as int?) ?? 0;
          final paidMonths = (e['paid_months'] as int?) ?? 0;
          if (paidMonths < tenureMonths) {
            final createdAt = e['created_at'] as String?;
            if (createdAt != null) {
              final created = DateTime.parse(createdAt);
              final nextMonth = created.add(
                Duration(days: 30 * (paidMonths + 1)),
              );
              nextPaymentDate = DateFormat('MMM d').format(nextMonth);
            }
          }
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Portfolio Glance',
          style: TextStyle(
            fontFamily: 'Cormorant Garamond',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildGlanceChip(
                icon: '🥇',
                value: '${totalGold.toStringAsFixed(2)}g',
                label: 'Total Gold',
              ),
              const SizedBox(width: 12),
              _buildGlanceChip(
                icon: '⬜',
                value: '${totalSilver.toStringAsFixed(1)}g',
                label: 'Total Slvr',
              ),
              const SizedBox(width: 12),
              _buildGlanceChip(
                iconWidget: const Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: AppColors.primary,
                ),
                value: nextPaymentDate,
                label: 'Next Payment',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGlanceChip({
    String? icon,
    Widget? iconWidget,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      constraints: const BoxConstraints(minWidth: 120),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.outlineVariant.withAlpha(51)),
        borderRadius: BorderRadius.circular(12),
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
          iconWidget ?? Text(icon ?? '', style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 10,
                  color: Color(0xFFA8A29E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSchemesSection(
    BuildContext context,
    AsyncValue<List<Map<String, dynamic>>> schemesAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Text(
              'Savings Schemes',
              style: TextStyle(
                fontFamily: 'Cormorant Garamond',
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => context.go('/schemes'),
              child: const Text(
                'See All →',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: schemesAsync.when(
            data: (schemes) {
              if (schemes.isEmpty) {
                return _buildDefaultSchemeCards();
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: schemes.length,
                itemBuilder: (context, index) {
                  final scheme = schemes[index];
                  final name = scheme['name'] as String? ?? 'Scheme';
                  final monthlyAmount =
                      (scheme['monthly_amount'] as num?)?.toDouble() ?? 500;
                  final tenure = (scheme['tenure_months'] as int?) ?? 12;
                  final description = scheme['description'] as String? ?? '';
                  final metalType = scheme['metal_type'] as String? ?? 'gold';
                  final isGold = metalType == 'gold';

                  return _buildSchemeCard(
                    name: name,
                    monthlyAmount: monthlyAmount,
                    tenure: tenure,
                    description: description,
                    isGold: isGold,
                    isFirst: index == 0,
                    onTap: () => context.go('/schemes'),
                  );
                },
              );
            },
            loading: () => _buildDefaultSchemeCards(),
            error: (_, __) => _buildDefaultSchemeCards(),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultSchemeCards() {
    return ListView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      children: [
        _buildSchemeCard(
          name: 'Classic Gold Savings',
          monthlyAmount: 500,
          tenure: 12,
          description: '"SLG pays the 13th month"',
          isGold: true,
          isFirst: true,
          onTap: () => context.go('/schemes'),
        ),
        _buildSchemeCard(
          name: 'Silver Bullion Plan',
          monthlyAmount: 1200,
          tenure: 24,
          description: '',
          isGold: false,
          isFirst: false,
          onTap: () => context.go('/schemes'),
        ),
      ],
    );
  }

  Widget _buildSchemeCard({
    required String name,
    required double monthlyAmount,
    required int tenure,
    required String description,
    required bool isGold,
    required bool isFirst,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 268,
        height: 180,
        margin: const EdgeInsets.only(right: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(
              color: isGold ? const Color(0xFFC8860A) : const Color(0xFFA8A29E),
              width: 4,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (isFirst)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'MOST POPULAR',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.1 * 8,
                    ),
                  ),
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '₹${NumberFormat('#,##0', 'en_IN').format(monthlyAmount)}',
                          style: const TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Text(
                          ' / mo',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFFA8A29E),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 1,
                          height: 16,
                          color: AppColors.outlineVariant.withAlpha(77),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$tenure Months',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFA8A29E),
                          ),
                        ),
                      ],
                    ),
                    if (description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          description,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isGold
                        ? const LinearGradient(
                            colors: [Color(0xFFF5C842), Color(0xFFC8860A)],
                          )
                        : null,
                    color: isGold ? null : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isFirst ? 'Start Investing' : 'View Plan',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isGold
                              ? Colors.white
                              : const Color(0xFFA8A29E),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: isGold ? Colors.white : const Color(0xFFA8A29E),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection(
    BuildContext context,
    AsyncValue<List<Map<String, dynamic>>>? transactionsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontFamily: 'Cormorant Garamond',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => context.go('/transactions'),
              child: const Text(
                'View All →',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        transactionsAsync != null
            ? transactionsAsync.when(
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return _buildDefaultTransactions();
                  }
                  final recent = transactions.take(3).toList();
                  return Column(
                    children: recent.map((txn) {
                      final amount = (txn['amount'] as num?)?.toDouble() ?? 0;
                      final type = txn['type'] as String? ?? 'credit';
                      final createdAt = txn['created_at'] as String?;
                      final dateStr = createdAt != null
                          ? DateFormat(
                              'MMM dd, yyyy • hh:mm a',
                            ).format(DateTime.parse(createdAt))
                          : '';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildTransactionRow(
                          icon: type == 'credit'
                              ? Icons.savings_outlined
                              : Icons.shopping_bag_outlined,
                          iconColor: type == 'credit'
                              ? AppColors.primary
                              : AppColors.secondary,
                          iconBgColor: type == 'credit'
                              ? AppColors.primaryFixed.withAlpha(77)
                              : AppColors.secondaryFixed.withAlpha(77),
                          title: type == 'credit'
                              ? 'Scheme Payment'
                              : 'Direct Purchase',
                          subtitle: dateStr,
                          amount:
                              '- ₹${NumberFormat('#,##0.00', 'en_IN').format(amount)}',
                          amountColor: AppColors.primary,
                          extra: 'Gold Credit',
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => _buildDefaultTransactions(),
                error: (_, __) => _buildDefaultTransactions(),
              )
            : _buildDefaultTransactions(),
      ],
    );
  }

  Widget _buildDefaultTransactions() {
    return Column(
      children: [
        _buildTransactionRow(
          icon: Icons.savings_outlined,
          iconColor: AppColors.primary,
          iconBgColor: AppColors.primaryFixed.withAlpha(77),
          title: 'Scheme Payment',
          subtitle: 'Mar 24, 2024 • 10:45 AM',
          amount: '- ₹500.00',
          amountColor: AppColors.primary,
          extra: 'Gold Credit: 0.067g',
        ),
        const SizedBox(height: 12),
        _buildTransactionRow(
          icon: Icons.shopping_bag_outlined,
          iconColor: AppColors.secondary,
          iconBgColor: AppColors.secondaryFixed.withAlpha(77),
          title: 'Direct Purchase',
          subtitle: 'Mar 20, 2024 • 04:12 PM',
          amount: '- ₹2,500.00',
          amountColor: AppColors.textPrimary,
          extra: 'Silver Credit: 28.2g',
        ),
        const SizedBox(height: 12),
        _buildTransactionRow(
          icon: Icons.trending_up,
          iconColor: AppColors.primaryContainer,
          iconBgColor: AppColors.primaryContainer.withAlpha(51),
          title: 'Market Gain Adj.',
          subtitle: 'Mar 18, 2024 • 09:00 AM',
          amount: '₹124.80',
          amountColor: const Color(0xFF2E7D32),
          extra: 'Value Rebase',
        ),
      ],
    );
  }

  Widget _buildTransactionRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String amount,
    required Color amountColor,
    required String extra,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10,
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
                amount,
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                ),
              ),
              Text(
                extra,
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 9,
                  color: Color(0xFFA8A29E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
