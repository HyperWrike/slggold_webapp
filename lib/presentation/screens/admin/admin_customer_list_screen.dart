import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/presentation/providers/user_data_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class AdminCustomerListScreen extends ConsumerStatefulWidget {
  const AdminCustomerListScreen({super.key});

  @override
  ConsumerState<AdminCustomerListScreen> createState() =>
      _AdminCustomerListScreenState();
}

class _AdminCustomerListScreenState
    extends ConsumerState<AdminCustomerListScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  Map<String, dynamic>? _selectedCustomer;
  List<Map<String, dynamic>> _customerEnrollments = [];
  double _customerPortfolioValue = 0;
  double _customerGoldGrams = 0;

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(allCustomersProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        children: [
          _buildTopAppBar(),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                ref.invalidate(allCustomersProvider);
                if (_selectedCustomer != null) {
                  await _loadCustomerDetails(
                    _selectedCustomer!['id'] as String,
                  );
                }
              },
              child: customersAsync.when(
                data: (customers) {
                  final filtered = _applyFilters(customers);

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 380,
                          child: _buildCustomerList(filtered),
                        ),
                        Expanded(
                          child: _selectedCustomer != null
                              ? _buildDetailPanel(_selectedCustomer!)
                              : _buildEmptyDetail(),
                        ),
                      ],
                    );
                  }

                  return _selectedCustomer != null
                      ? _buildDetailPanel(_selectedCustomer!)
                      : _buildCustomerList(filtered);
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
                error: (_, __) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      const Text('Failed to load customers'),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(allCustomersProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
                      if (_selectedCustomer != null)
                        IconButton(
                          onPressed: () =>
                              setState(() => _selectedCustomer = null),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFF1E3A5F),
                          ),
                          splashRadius: 24,
                        ),
                      const Text(
                        'Customers',
                        style: TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E3A5F),
                        ),
                      ),
                    ],
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
            Container(height: 1, color: const Color(0xFFF1F5F9)),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _applyFilters(
    List<Map<String, dynamic>> customers,
  ) {
    var result = customers;

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((c) {
        final name = (c['full_name'] as String? ?? '').toLowerCase();
        final phone = (c['phone'] as String? ?? '').toLowerCase();
        final username = (c['username'] as String? ?? '').toLowerCase();
        return name.contains(query) ||
            phone.contains(query) ||
            username.contains(query);
      }).toList();
    }

    if (_selectedFilter == 'Pending KYC') {
      result = result.where((c) => c['is_verified'] != true).toList();
    }

    return result;
  }

  Widget _buildCustomerList(List<Map<String, dynamic>> customers) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: const InputDecoration(
                hintText: 'Search by name, phone or username...',
                hintStyle: TextStyle(color: Color(0xFFA8A29E)),
                prefixIcon: Icon(Icons.search, color: Color(0xFFA8A29E)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Active', 'No Schemes', 'Pending KYC']
                  .map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _buildFilterChip(f),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Recent Customers',
            style: TextStyle(
              fontFamily: 'Cormorant Garamond',
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),

          if (customers.isEmpty)
            Container(
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 48,
                      color: AppColors.outlineVariant,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No Customers Yet',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Customers will appear after registration',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ...customers.map(
            (customer) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCustomerTile(customer),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerTile(Map<String, dynamic> customer) {
    final name = customer['full_name'] as String? ?? '';
    final phone = customer['phone'] as String? ?? '';
    final username = customer['username'] as String? ?? '';
    final isSelected = _selectedCustomer?['id'] == customer['id'];

    final initials = name.isNotEmpty
        ? name
              .split(' ')
              .take(2)
              .map((n) => n.isNotEmpty ? n[0] : '')
              .join()
              .toUpperCase()
        : '?';

    return GestureDetector(
      onTap: () {
        setState(() => _selectedCustomer = customer);
        _loadCustomerDetails(customer['id'] as String);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.outlineVariant.withAlpha(26),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name.isNotEmpty ? name : username,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      FutureBuilder<int>(
                        future: _getEnrollmentCount(customer['id'] as String),
                        builder: (context, snap) {
                          final count = snap.data ?? 0;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              gradient: count > 0
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFFF5C842),
                                        Color(0xFFC8860A),
                                      ],
                                    )
                                  : null,
                              color: count > 0 ? null : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              '$count Schemes',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: count > 0
                                    ? Colors.white
                                    : const Color(0xFF64748B),
                                letterSpacing: 0.1 * 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${username.isNotEmpty ? username : name.toLowerCase().replaceAll(' ', '_')} • ${phone.isNotEmpty ? '+91 $phone' : 'No phone'}',
                    style: const TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 12,
                      color: Color(0xFFA8A29E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: isSelected ? AppColors.primary : const Color(0xFFD4D5D9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDetail() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 64, color: AppColors.outlineVariant),
          SizedBox(height: 16),
          Text(
            'Select a Customer',
            style: TextStyle(
              fontFamily: 'Cormorant Garamond',
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap a customer to view their details',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailPanel(Map<String, dynamic> customer) {
    final name = customer['full_name'] as String? ?? '';
    final phone = customer['phone'] as String? ?? '';
    final username = customer['username'] as String? ?? '';
    final aadhaar = customer['aadhaar'] as String? ?? '';
    final nomineeName = customer['nominee_name'] as String? ?? '';
    final nomineeRelation = customer['nominee_relationship'] as String? ?? '';
    final createdAt = customer['created_at'] as String?;
    final isVerified = customer['is_verified'] as bool? ?? false;

    final memberDate = createdAt != null
        ? DateFormat('MMM yyyy').format(DateTime.parse(createdAt))
        : '';

    final initials = name.isNotEmpty
        ? name
              .split(' ')
              .take(2)
              .map((n) => n.isNotEmpty ? n[0] : '')
              .join()
              .toUpperCase()
        : '?';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Profile Header
          Container(
            height: 128,
            color: const Color(0xFFF1F5F9),
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 32,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.isNotEmpty ? name : username,
                            style: const TextStyle(
                              fontFamily: 'Cormorant Garamond',
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${isVerified ? 'Verified' : 'Unverified'} Customer${memberDate.isNotEmpty ? ' since $memberDate' : ''}',
                            style: const TextStyle(color: Color(0xFFA8A29E)),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        _buildActionButton(Icons.call, AppColors.primaryFixed),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          Icons.share,
                          const Color(0xFFF1F5F9),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Portfolio Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF5C842), Color(0xFFC8860A)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Portfolio Value',
                            style: TextStyle(
                              color: Colors.white.withAlpha(204),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.1 * 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${NumberFormat('#,##,##0', 'en_IN').format(_customerPortfolioValue)}',
                            style: const TextStyle(
                              fontFamily: 'DM Mono',
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(51),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Accumulated Gold',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withAlpha(230),
                              ),
                            ),
                            Text(
                              '${_customerGoldGrams.toStringAsFixed(2)}g',
                              style: const TextStyle(
                                fontFamily: 'DM Mono',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Info Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.person,
                        title: 'Personal Details',
                        items: [
                          if (aadhaar.isNotEmpty)
                            _buildInfoRow(
                              'Aadhaar',
                              '**** **** ${aadhaar.length >= 4 ? aadhaar.substring(aadhaar.length - 4) : ''}',
                            ),
                          _buildInfoRow(
                            'Phone',
                            phone.isNotEmpty ? '+91 $phone' : '--',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.family_restroom,
                        title: 'Nominee',
                        items: [
                          _buildInfoRow(
                            'Name',
                            nomineeName.isNotEmpty ? nomineeName : 'Not set',
                          ),
                          if (nomineeRelation.isNotEmpty)
                            _buildInfoRow('Relation', nomineeRelation),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Enrolled Schemes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Enrolled Schemes',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${_customerEnrollments.length} active',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                ..._customerEnrollments.map((enrollment) {
                  final scheme = enrollment['schemes'] as Map<String, dynamic>?;
                  final schemeName = scheme?['name'] as String? ?? 'Scheme';
                  final monthly =
                      (enrollment['monthly_amount'] as num?)?.toDouble() ?? 0;
                  final status = enrollment['status'] as String? ?? 'active';
                  final isActive = status == 'active';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.outlineVariant.withAlpha(77),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primaryFixed.withAlpha(51)
                                  : const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.payments,
                              color: isActive
                                  ? AppColors.primary
                                  : const Color(0xFFA8A29E),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  schemeName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'EMI: ₹${NumberFormat('#,##0', 'en_IN').format(monthly)}/mo',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFA8A29E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primaryFixed
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isActive
                                    ? AppColors.primary
                                    : const Color(0xFFA8A29E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                if (_customerEnrollments.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow.withAlpha(128),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        'No active schemes',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // Action Buttons
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildPrimaryButton('View Transactions', () {
                      context.go('/admin/reports');
                    }),
                    _buildSecondaryButton('Contact Customer', () {}),
                    _buildDangerButton('Suspend Account', () {}),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFFA8A29E),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color bgColor) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.primary, size: 20),
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF5C842), Color(0xFFC8860A)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(51),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildDangerButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.error.withAlpha(77)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.error,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Future<int> _getEnrollmentCount(String userId) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('enrollments')
          .select('id')
          .eq('user_id', userId)
          .eq('status', 'active');
      return (response as List).length;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _loadCustomerDetails(String userId) async {
    try {
      final supabase = Supabase.instance.client;

      // Load enrollments with scheme data
      final enrollmentsResponse = await supabase
          .from('enrollments')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final enrollments = List<Map<String, dynamic>>.from(enrollmentsResponse);

      // Load schemes
      final schemesResponse = await supabase.from('schemes').select();
      final schemes = List<Map<String, dynamic>>.from(schemesResponse);
      final schemeMap = <String, Map<String, dynamic>>{};
      for (final s in schemes) {
        final id = s['id']?.toString();
        if (id != null) schemeMap[id] = s;
      }

      // Attach schemes to enrollments
      for (final e in enrollments) {
        final sid = e['scheme_id']?.toString();
        if (sid != null && schemeMap.containsKey(sid)) {
          e['schemes'] = schemeMap[sid];
        }
      }

      // Calculate portfolio
      double totalValue = 0;
      double totalGold = 0;
      for (final e in enrollments) {
        totalValue += (e['paid_amount'] as num?)?.toDouble() ?? 0;
        totalGold += (e['total_gold_grams'] as num?)?.toDouble() ?? 0;
      }

      if (mounted) {
        setState(() {
          _customerEnrollments = enrollments;
          _customerPortfolioValue = totalValue;
          _customerGoldGrams = totalGold;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error loading customer details: $e');
    }
  }
}
