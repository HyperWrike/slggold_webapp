import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/presentation/providers/auth_provider.dart';
import 'package:slg_golds/presentation/providers/user_data_provider.dart';
import 'package:slg_golds/presentation/providers/metal_price_provider.dart';
import 'package:slg_golds/presentation/widgets/notification_popup.dart';
import 'package:intl/intl.dart';

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  final Set<String> _expandedCards = {};
  final formatCurrency = NumberFormat.simpleCurrency(
    locale: 'en_IN',
    decimalDigits: 0,
  );

  void _toggleCard(String enrollmentId) {
    setState(() {
      if (_expandedCards.contains(enrollmentId)) {
        _expandedCards.remove(enrollmentId);
      } else {
        _expandedCards.add(enrollmentId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final userId = authState.user?.id;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view portfolio')),
      );
    }

    final portfolioAsync = ref.watch(portfolioSummaryProvider(userId));
    final enrollmentsAsync = ref.watch(userEnrollmentsProvider(userId));
    final transactionsAsync = ref.watch(userTransactionsProvider(userId));
    final metalPricesAsync = ref.watch(metalPricesProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(portfolioSummaryProvider(userId));
          ref.invalidate(userEnrollmentsProvider(userId));
          ref.invalidate(userTransactionsProvider(userId));
          ref.invalidate(metalPricesProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(child: _buildTopAppBar(context, authState)),
            SliverToBoxAdapter(
              child: _buildHeroHeader(
                context,
                portfolioAsync,
                metalPricesAsync,
              ),
            ),
            SliverToBoxAdapter(
              child: _buildMySchemesSection(context, enrollmentsAsync),
            ),
            SliverToBoxAdapter(
              child: _buildRecentActivitySection(context, transactionsAsync),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context, AuthState authState) {
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
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryFixedDim,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: authState.user?.fullName != null
                                ? Center(
                                    child: Text(
                                      authState.user!.fullName
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        fontFamily: 'DM Sans',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Portfolio',
                        style: TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: -0.5,
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
          Container(height: 1, color: AppColors.surfaceContainerHigh),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(
    BuildContext context,
    AsyncValue<Map<String, dynamic>> portfolioAsync,
    AsyncValue<dynamic> metalPricesAsync,
  ) {
    return Container(
      height: 240,
      decoration: const BoxDecoration(color: AppColors.surface),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  colors: [Color(0x26F5C842), Colors.transparent],
                  radius: 0.5,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  colors: [Color(0x1FC8860A), Colors.transparent],
                  radius: 0.5,
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    width: double.infinity,
                    height: 170,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xBFFFFFFF),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.primary.withAlpha(51),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0F795900),
                          blurRadius: 32,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: portfolioAsync.when(
                      data: (data) {
                        final totalGold =
                            (data['totalGoldGrams'] as num?)?.toDouble() ?? 0;
                        final totalInvested =
                            (data['totalValue'] as num?)?.toDouble() ?? 0;
                        final dbGoldPrice =
                            (data['goldPricePerGram'] as num?)?.toDouble() ?? 0;
                        return metalPricesAsync.when(
                          data: (prices) => _buildHeroContent(
                            invested: totalInvested,
                            totalGoldGrams: totalGold,
                            goldPrice: prices.goldPricePerGram > 0
                                ? prices.goldPricePerGram
                                : (dbGoldPrice > 0 ? dbGoldPrice : 7850.0),
                          ),
                          loading: () => _buildHeroContent(
                            invested: totalInvested,
                            totalGoldGrams: totalGold,
                            goldPrice: dbGoldPrice > 0 ? dbGoldPrice : 7850.0,
                          ),
                          error: (_, _) => _buildHeroContent(
                            invested: totalInvested,
                            totalGoldGrams: totalGold,
                            goldPrice: dbGoldPrice > 0 ? dbGoldPrice : 7850.0,
                          ),
                        );
                      },
                      loading: () => _buildHeroContent(
                        invested: 0,
                        totalGoldGrams: 0,
                        goldPrice: 7850.0,
                        isLoading: true,
                      ),
                      error: (_, _) => _buildHeroContent(
                        invested: 0,
                        totalGoldGrams: 0,
                        goldPrice: 7850.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroContent({
    required double invested,
    required double totalGoldGrams,
    required double goldPrice,
    bool isLoading = false,
  }) {
    if (isLoading) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      );
    }

    final currentValue = totalGoldGrams * goldPrice;
    final changePercent = invested > 0
        ? ((currentValue - invested) / invested) * 100
        : 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Portfolio Value',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.primary.withAlpha(179),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '₹${NumberFormat('#,##,##0.00', 'en_IN').format(currentValue)}',
              style: const TextStyle(
                fontFamily: 'DM Mono',
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.primary.withAlpha(26)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildGramIndicator(
                    const Color(0xFFF5C842),
                    '${totalGoldGrams.toStringAsFixed(3)}g',
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    changePercent >= 0
                        ? Icons.trending_up
                        : Icons.trending_down,
                    size: 14,
                    color: changePercent >= 0
                        ? const Color(0xFF1B5E20)
                        : AppColors.error,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${changePercent >= 0 ? '+' : ''}${changePercent.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: changePercent >= 0
                          ? const Color(0xFF1B5E20)
                          : AppColors.error,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGramIndicator(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'DM Mono',
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildMySchemesSection(
    BuildContext context,
    AsyncValue<List<Map<String, dynamic>>> enrollmentsAsync,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Text(
            'My Schemes',
            style: TextStyle(
              fontFamily: 'Cormorant Garamond',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          enrollmentsAsync.when(
            data: (enrollments) {
              if (enrollments.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withAlpha(13)),
                  ),
                  child: const Center(
                    child: Text(
                      'No active schemes yet.\nExplore schemes to get started!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }
              return Column(
                children: enrollments.map((enrollment) {
                  final id = enrollment['id']?.toString() ?? '';
                  final scheme = enrollment['schemes'] as Map<String, dynamic>?;
                  final schemeName =
                      scheme?['name'] as String? ?? 'Unknown Scheme';
                  final monthlyAmount =
                      (enrollment['monthly_amount'] as num?)?.toDouble() ?? 0;
                  final tenureMonths =
                      (enrollment['tenure_months'] as int?) ?? 0;
                  final paidMonths = (enrollment['paid_months'] as int?) ?? 0;
                  final totalGoldGrams =
                      (enrollment['total_gold_grams'] as num?)?.toDouble() ?? 0;
                  final paidAmount =
                      (enrollment['paid_amount'] as num?)?.toDouble() ?? 0;
                  final status = enrollment['status'] as String? ?? 'active';
                  final isExpanded = _expandedCards.contains(id);
                  final metalType = scheme?['metal_type'] as String? ?? 'gold';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildSchemeCard(
                      enrollmentId: id,
                      schemeName: schemeName,
                      monthlyAmount: monthlyAmount,
                      tenureMonths: tenureMonths,
                      paidMonths: paidMonths,
                      totalGoldGrams: totalGoldGrams,
                      paidAmount: paidAmount,
                      status: status,
                      isExpanded: isExpanded,
                      metalType: metalType,
                      isGold: metalType == 'gold',
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
            error: (_, __) => Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.error.withAlpha(51)),
              ),
              child: const Center(
                child: Text(
                  'Failed to load schemes.\nPull down to refresh.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeCard({
    required String enrollmentId,
    required String schemeName,
    required double monthlyAmount,
    required int tenureMonths,
    required int paidMonths,
    required double totalGoldGrams,
    required double paidAmount,
    required String status,
    required bool isExpanded,
    required String metalType,
    required bool isGold,
  }) {
    final progress = tenureMonths > 0 ? paidMonths / tenureMonths : 0.0;
    final totalPayable = monthlyAmount * tenureMonths;
    final isActive = status == 'active';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withAlpha(13)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isGold
                              ? AppColors.primaryFixed
                              : AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isGold
                              ? Icons.payments_outlined
                              : Icons.diamond_outlined,
                          color: isGold
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    schemeName,
                                    style: const TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildStatusBadge(isActive),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${formatCurrency.format(monthlyAmount).replaceAll('₹', '')}/month • $paidMonths of $tenureMonths months',
                              style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _toggleCard(enrollmentId),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: isExpanded
                          ? AppColors.primaryContainer
                          : const Color(0xFFA8A29E),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Container(
                    height: 6,
                    width: double.infinity,
                    color: AppColors.surfaceContainerHigh,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isGold
                                ? [
                                    const Color(0xFFF5C842),
                                    const Color(0xFFC8860A),
                                  ]
                                : [
                                    const Color(0xFFA8A29E),
                                    const Color(0xFF707070),
                                  ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}% COMPLETED',
                      style: TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isGold
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '₹${formatCurrency.format(paidAmount).replaceAll('₹', '')} / ₹${formatCurrency.format(totalPayable).replaceAll('₹', '')}',
                      style: const TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (isExpanded) ...[
            // Stats Row
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow.withAlpha(128),
                border: const Border(
                  top: BorderSide(color: AppColors.surfaceContainerHigh),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${metalType.toUpperCase()} ACC.',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary.withAlpha(153),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${totalGoldGrams.toStringAsFixed(3)}g',
                          style: const TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CURRENT VALUE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary.withAlpha(153),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${formatCurrency.format(paidAmount).replaceAll('₹', '')}',
                          style: const TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'INVESTED',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary.withAlpha(153),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${formatCurrency.format(paidAmount).replaceAll('₹', '')}',
                          style: const TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Payment Timeline
            _buildPaymentTimeline(paidMonths, tenureMonths),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF059669) : AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: isActive ? const Color(0xFF047857) : AppColors.error,
              letterSpacing: 0.9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTimeline(int paidMonths, int tenureMonths) {
    final months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];

    final displayCount = tenureMonths.clamp(0, 12);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.surfaceContainerHigh)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PAYMENT TIMELINE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary.withAlpha(153),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(displayCount, (index) {
              final isPaid = index < paidMonths;
              final isLast = index == displayCount - 1;
              return _buildTimelineDot(
                months[index % 12],
                isPaid: isPaid,
                isPending: !isPaid && !isLast,
                isStar: isLast && isPaid,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineDot(
    String label, {
    bool isPaid = false,
    bool isPending = false,
    bool isStar = false,
  }) {
    return Column(
      children: [
        if (isStar)
          const Icon(Icons.star, size: 12, color: AppColors.primary)
        else
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPaid ? AppColors.primary : const Color(0xFFA8A29E),
              boxShadow: isPaid
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(102),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),
        const SizedBox(height: 4),
        Opacity(
          opacity: isPending ? 0.3 : 1.0,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection(
    BuildContext context,
    AsyncValue<List<Map<String, dynamic>>> transactionsAsync,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/transactions'),
                child: const Text(
                  'VIEW HISTORY',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          transactionsAsync.when(
            data: (transactions) {
              if (transactions.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow.withAlpha(77),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'No transactions yet',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }

              final recentTxns = transactions.take(5).toList();
              return Column(
                children: recentTxns.map((txn) {
                  final amount = (txn['amount'] as num?)?.toDouble() ?? 0;
                  final status = txn['status'] as String? ?? 'completed';
                  final type = txn['type'] as String? ?? 'credit';
                  final createdAt = txn['created_at'] as String?;
                  final dateStr = createdAt != null
                      ? DateFormat(
                          'dd MMM yyyy • hh:mm a',
                        ).format(DateTime.parse(createdAt)).toUpperCase()
                      : '';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildTransactionItem(
                      icon: type == 'credit'
                          ? Icons.add_shopping_cart
                          : Icons.account_balance_wallet_outlined,
                      title: type == 'credit'
                          ? 'Gold Installment'
                          : 'Direct Purchase',
                      date: dateStr,
                      amount:
                          '₹${NumberFormat('#,##0.00', 'en_IN').format(amount)}',
                      status: status == 'completed' ? 'Success' : status,
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
            error: (_, __) => Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow.withAlpha(77),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'Failed to load transactions',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required String title,
    required String date,
    required String amount,
    required String status,
  }) {
    final isSuccess =
        status.toLowerCase() == 'success' ||
        status.toLowerCase() == 'completed';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withAlpha(77),
        borderRadius: BorderRadius.circular(16),
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
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 16),
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
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: const TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 10,
                      color: AppColors.textSecondary,
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
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                status.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSuccess ? const Color(0xFF059669) : AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
