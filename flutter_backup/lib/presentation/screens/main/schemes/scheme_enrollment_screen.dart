import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/presentation/providers/auth_provider.dart';
import 'package:slg_golds/presentation/providers/user_data_provider.dart';
import 'package:slg_golds/presentation/widgets/notification_popup.dart';
import 'package:intl/intl.dart';

class SchemeEnrollmentScreen extends ConsumerStatefulWidget {
  const SchemeEnrollmentScreen({super.key});

  @override
  ConsumerState<SchemeEnrollmentScreen> createState() =>
      _SchemeEnrollmentScreenState();
}

class _SchemeEnrollmentScreenState extends ConsumerState<SchemeEnrollmentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
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
      body: Column(
        children: [
          _buildTopAppBar(context),
          _buildTabRow(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildAvailableSchemes(), _buildMySchemes()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final userName = authState.user?.fullName ?? 'User';

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
                            color: AppColors.surfaceContainerHigh,
                            shape: BoxShape.circle,
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
                      const Text(
                        'Schemes',
                        style: TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: 24,
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
          Container(height: 1, color: AppColors.surfaceContainerHigh),
        ],
      ),
    );
  }

  Widget _buildTabRow() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.surfaceContainerHigh),
        ),
      ),
      child: Row(
        children: [
          _buildTabItem('Available Schemes', 0),
          _buildTabItem('My Schemes', 1),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index) {
    final isActive = _tabController.index == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
          setState(() {});
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: isActive
                ? const Border(
                    bottom: BorderSide(color: Colors.transparent, width: 2),
                  )
                : null,
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isActive
                        ? AppColors.primary
                        : const Color(0xFFA8A29E),
                  ),
                ),
              ),
              if (isActive)
                Positioned(
                  bottom: -1,
                  left: 24,
                  right: 24,
                  child: Container(
                    height: 2,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFF5C842), Color(0xFFC8860A)],
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

  Widget _buildFilterChips() {
    final filters = ['All', 'Gold', 'Silver', 'Combo'];

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;

          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                gradient: isSelected && filter == 'All'
                    ? const LinearGradient(
                        colors: [Color(0xFFF5C842), Color(0xFFC8860A)],
                      )
                    : null,
                color: isSelected && filter != 'All'
                    ? AppColors.primaryFixed
                    : (!isSelected ? AppColors.surfaceContainerLowest : null),
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
                        ? (filter == 'All' ? Colors.white : AppColors.primary)
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

  List<Map<String, dynamic>> _filterSchemes(
    List<Map<String, dynamic>> schemes,
  ) {
    switch (_selectedFilter) {
      case 'Gold':
        return schemes
            .where((s) => (s['metal_type'] as String? ?? 'gold') == 'gold')
            .toList();
      case 'Silver':
        return schemes
            .where((s) => (s['metal_type'] as String? ?? 'gold') == 'silver')
            .toList();
      case 'Combo':
        return schemes
            .where((s) => (s['metal_type'] as String? ?? 'gold') == 'combo')
            .toList();
      default:
        return schemes;
    }
  }

  Widget _buildAvailableSchemes() {
    final schemesAsync = ref.watch(availableSchemesProvider);

    return schemesAsync.when(
      data: (schemes) {
        final filtered = _filterSchemes(schemes);

        if (filtered.isEmpty) {
          return _buildEmptyState(
            icon: Icons.card_giftcard_outlined,
            title: 'No Schemes Available',
            message: 'New schemes will be available soon.',
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(availableSchemesProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              children: [
                _buildFilterChips(),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Featured Card (first scheme)
                      _buildFeaturedCard(filtered.first),
                      const SizedBox(height: 24),
                      // Secondary cards
                      ...filtered
                          .skip(1)
                          .map(
                            (scheme) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildSecondaryCard(scheme),
                            ),
                          ),
                    ],
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      ),
      error: (_, __) => _buildEmptyState(
        icon: Icons.error_outline,
        title: 'Failed to Load',
        message: 'Pull down to refresh and try again.',
      ),
    );
  }

  Widget _buildFeaturedCard(Map<String, dynamic> scheme) {
    final name = scheme['name'] as String? ?? 'Classic Gold Savings Plan';
    final tenure = (scheme['tenure_months'] as int?) ?? 12;
    final minAmount = (scheme['min_amount'] as num?)?.toDouble() ?? 100;
    final description =
        scheme['description'] as String? ??
        'Secure your future with systematic purchases.';
    final benefit = scheme['benefit'] as String? ?? 'SLG pays the 13th month';
    final metalType = scheme['metal_type'] as String? ?? 'gold';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
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
        children: [
          // Image placeholder area with gradient
          Stack(
            children: [
              Container(
                height: 192,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  gradient: metalType == 'gold'
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFF5C842), Color(0xFFC8860A)],
                        )
                      : metalType == 'silver'
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFD4D4D4), Color(0xFF707070)],
                        )
                      : null,
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        metalType == 'gold'
                            ? Icons.workspace_premium
                            : metalType == 'silver'
                            ? Icons.diamond_outlined
                            : Icons.auto_awesome,
                        size: 64,
                        color: Colors.white.withAlpha(77),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withAlpha(102),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // MOST POPULAR badge
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E0A3C),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text(
                    'MOST POPULAR',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.1 * 10,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(13),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        metalType.substring(0, 1).toUpperCase() +
                            metalType.substring(1),
                        style: const TextStyle(
                          fontFamily: 'DM Mono',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$tenure months',
                      style: const TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '•',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Min ₹${NumberFormat('#,##0', 'en_IN').format(minAmount)}/month',
                      style: const TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(text: description),
                      if (benefit.isNotEmpty)
                        TextSpan(
                          text: ' $benefit',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => context.push('/schemes/enroll', extra: scheme),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF5C842), Color(0xFFC8860A)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ENROLL NOW',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryCard(Map<String, dynamic> scheme) {
    final name = scheme['name'] as String? ?? 'Scheme';
    final description =
        scheme['description'] as String? ?? 'Premium savings plan.';
    final metalType = scheme['metal_type'] as String? ?? 'gold';
    final isSilver = metalType == 'silver';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withAlpha(26)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Arrival',
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryContainer,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
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
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => context.push('/schemes/enroll', extra: scheme),
                  child: const Row(
                    children: [
                      Text(
                        'View Details',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 96,
            height: 128,
            decoration: BoxDecoration(
              gradient: isSilver
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFD4D4D4), Color(0xFFA0A0A0)],
                    )
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFF5C842), Color(0xFFC8860A)],
                    ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                isSilver ? Icons.diamond_outlined : Icons.workspace_premium,
                size: 32,
                color: Colors.white.withAlpha(128),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMySchemes() {
    final authState = ref.watch(authNotifierProvider);
    final userId = authState.user?.id;

    if (userId == null) {
      return _buildEmptyState(
        icon: Icons.lock_outline,
        title: 'Login Required',
        message: 'Please login to view your enrolled schemes.',
      );
    }

    final enrollmentsAsync = ref.watch(userEnrollmentsProvider(userId));

    return enrollmentsAsync.when(
      data: (enrollments) {
        if (enrollments.isEmpty) {
          return _buildEmptyState(
            icon: Icons.account_balance_wallet_outlined,
            title: 'No Enrolled Schemes',
            message:
                'Enroll in a scheme to start your gold investment journey.',
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(userEnrollmentsProvider(userId));
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            itemCount: enrollments.length + 1,
            itemBuilder: (context, index) {
              if (index == enrollments.length) {
                return const SizedBox(height: 120);
              }

              final enrollment = enrollments[index];
              final scheme = enrollment['schemes'] as Map<String, dynamic>?;
              final schemeName = scheme?['name'] as String? ?? 'Scheme';
              final monthlyAmount =
                  (enrollment['monthly_amount'] as num?)?.toDouble() ?? 0;
              final tenureMonths = (enrollment['tenure_months'] as int?) ?? 0;
              final paidMonths = (enrollment['paid_months'] as int?) ?? 0;
              final totalGoldGrams =
                  (enrollment['total_gold_grams'] as num?)?.toDouble() ?? 0;
              final paidAmount =
                  (enrollment['paid_amount'] as num?)?.toDouble() ?? 0;
              final status = enrollment['status'] as String? ?? 'active';
              final metalType = scheme?['metal_type'] as String? ?? 'gold';
              final isGold = metalType == 'gold';
              final progress = tenureMonths > 0
                  ? paidMonths / tenureMonths
                  : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16, top: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                          colors: [
                                            Color(0xFFF5C842),
                                            Color(0xFFC8860A),
                                          ],
                                        )
                                      : null,
                                  color: isGold
                                      ? null
                                      : AppColors.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isGold
                                      ? Icons.workspace_premium
                                      : Icons.diamond_outlined,
                                  color: isGold
                                      ? Colors.white
                                      : AppColors.outline,
                                  size: 20,
                                  fill: 1,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                schemeName,
                                style: const TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: status == 'active'
                                  ? const Color(0xFFD1FAE5)
                                  : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: status == 'active'
                                    ? const Color(0xFF047857)
                                    : AppColors.error,
                                letterSpacing: 0.9,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$paidMonths/$tenureMonths months paid',
                            style: const TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontFamily: 'DM Mono',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
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
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildEnrollmentStat(
                              'Monthly',
                              '₹${NumberFormat('#,##0', 'en_IN').format(monthlyAmount)}',
                            ),
                          ),
                          Expanded(
                            child: _buildEnrollmentStat(
                              'Invested',
                              '₹${NumberFormat('#,##0', 'en_IN').format(paidAmount)}',
                            ),
                          ),
                          Expanded(
                            child: _buildEnrollmentStat(
                              '${metalType.substring(0, 1).toUpperCase()}${metalType.substring(1)} Acc.',
                              '${totalGoldGrams.toStringAsFixed(3)}g',
                              valueColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
      error: (_, __) => _buildEmptyState(
        icon: Icons.error_outline,
        title: 'Failed to Load',
        message: 'Pull down to refresh and try again.',
      ),
    );
  }

  Widget _buildEnrollmentStat(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.outlineVariant),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Cormorant Garamond',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
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
