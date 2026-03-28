import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/data/datasources/database_service.dart';
import 'package:slg_golds/presentation/providers/auth_provider.dart';
import 'package:slg_golds/presentation/providers/user_data_provider.dart';
import 'package:intl/intl.dart';

class AdminCreateSchemeScreen extends ConsumerStatefulWidget {
  const AdminCreateSchemeScreen({super.key});

  @override
  ConsumerState<AdminCreateSchemeScreen> createState() =>
      _AdminCreateSchemeScreenState();
}

class _AdminCreateSchemeScreenState
    extends ConsumerState<AdminCreateSchemeScreen> {
  final _nameController = TextEditingController();
  final _minAmountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _benefitController = TextEditingController();
  String _selectedMetal = 'gold';
  int _selectedTenure = 12;
  bool _isPopular = false;
  bool _isLoading = false;
  int _enrollmentCounts = 0;

  @override
  void initState() {
    super.initState();
    _loadEnrollmentCounts();
  }

  Future<void> _loadEnrollmentCounts() async {
    // Count total active enrollments across all schemes
    try {
      final db = DatabaseService(ref.read(supabaseProvider));
      final schemes = await db.getAvailableSchemes();
      int total = 0;
      for (final s in schemes) {
        final id = s['id']?.toString() ?? '';
        if (id.isNotEmpty) {
          total += await db.getEnrollmentCountForScheme(id);
        }
      }
      if (mounted) setState(() => _enrollmentCounts = total);
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _minAmountController.dispose();
    _descriptionController.dispose();
    _benefitController.dispose();
    super.dispose();
  }

  Future<void> _createScheme() async {
    if (_nameController.text.isEmpty || _minAmountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in required fields'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final db = ref.read(databaseServiceProvider);
      await db.createScheme(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        metalType: _selectedMetal,
        monthlyAmount: double.tryParse(_minAmountController.text) ?? 500,
        minAmount: double.tryParse(_minAmountController.text) ?? 100,
        tenureMonths: _selectedTenure,
        benefit: _benefitController.text.trim(),
        isPopular: _isPopular,
      );

      ref.invalidate(availableSchemesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Scheme created successfully!'),
            backgroundColor: Color(0xFF059669),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final schemesAsync = ref.watch(availableSchemesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // TopAppBar
          SliverToBoxAdapter(child: _buildTopAppBar()),

          // Active Schemes Grid
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: _buildActiveSchemes(schemesAsync),
            ),
          ),

          // Create Scheme Form
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
              child: _buildCreateForm(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
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
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF1E3A5F),
                        ),
                        splashRadius: 24,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Schemes',
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
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.filter_list,
                          color: Color(0xFFA8A29E),
                        ),
                        splashRadius: 24,
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.outlineVariant.withAlpha(51),
                          ),
                          color: AppColors.primaryFixed,
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
                ],
              ),
            ),
            Container(height: 1, color: const Color(0xFFF1F5F9)),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSchemes(
    AsyncValue<List<Map<String, dynamic>>> schemesAsync,
  ) {
    return schemesAsync.when(
      data: (schemes) {
        final activeSchemes = schemes
            .where((s) => s['is_active'] == true)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tab row
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.surfaceContainerHigh),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 16),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.primaryContainer,
                          width: 2,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E3A5F),
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                  Text(
                    '${activeSchemes.length} schemes',
                    style: const TextStyle(
                      color: Color(0xFFA8A29E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Scheme Cards Grid
            ...activeSchemes.map(
              (scheme) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildSchemeCard(scheme),
              ),
            ),

            // Add New Scheme Card
            _buildAddSchemeCard(),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      ),
      error: (_, __) => const Text('Failed to load schemes'),
    );
  }

  Widget _buildSchemeCard(Map<String, dynamic> scheme) {
    final name = scheme['name'] as String? ?? 'Scheme';
    final description = scheme['description'] as String? ?? '';
    final minAmount = (scheme['min_amount'] as num?)?.toDouble() ?? 0;
    final tenure = (scheme['tenure_months'] as int?) ?? 0;
    final isActive = scheme['is_active'] as bool? ?? true;
    final metalType = scheme['metal_type'] as String? ?? 'gold';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withAlpha(26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFFEE2E2),
                  ),
                ),
                child: Text(
                  isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isActive ? const Color(0xFF047857) : AppColors.error,
                    letterSpacing: 0.1 * 10,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _toggleSchemeStatus(
                  scheme['id']?.toString() ?? '',
                  !isActive,
                ),
                icon: const Icon(Icons.more_vert, color: Color(0xFFA8A29E)),
                splashRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Cormorant Garamond',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description.isNotEmpty ? description : 'No description',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Min Amount',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFA8A29E),
                          letterSpacing: 0.1 * 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${NumberFormat('#,##0', 'en_IN').format(minAmount)}',
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
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Duration',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFA8A29E),
                          letterSpacing: 0.1 * 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$tenure mo',
                        style: const TextStyle(
                          fontFamily: 'DM Mono',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.group, size: 16, color: Color(0xFFA8A29E)),
              const SizedBox(width: 8),
              Text(
                '$_enrollmentCounts active enrollments',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFA8A29E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddSchemeCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withAlpha(128),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withAlpha(77),
          style: BorderStyle.solid,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_circle,
              color: Color(0xFFA8A29E),
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'New Scheme Draft',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFFA8A29E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ready for configuration',
            style: TextStyle(
              fontSize: 10,
              color: const Color(0xFFA8A29E),
              letterSpacing: 0.1 * 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateForm() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create New Scheme',
            style: TextStyle(
              fontFamily: 'Cormorant Garamond',
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 32),

          // Scheme Name
          _buildLabel('Scheme Name'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _nameController,
            hint: 'e.g. Premium Bullion Plus',
          ),
          const SizedBox(height: 24),

          // Metal Type
          _buildLabel('Metal Type'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildMetalButton('gold', 'Gold')),
              const SizedBox(width: 12),
              Expanded(child: _buildMetalButton('silver', 'Silver')),
            ],
          ),
          const SizedBox(height: 24),

          // Min Amount & Duration
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Min Amount (₹)'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _minAmountController,
                      hint: '500',
                      isNumber: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Duration (Months)'),
                    const SizedBox(height: 8),
                    _buildTenureDropdown(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Description
          _buildLabel('Description'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _descriptionController,
            hint: 'Describe the purpose of this scheme...',
            maxLines: 3,
          ),
          const SizedBox(height: 24),

          // Bonus Structure
          _buildLabel('Bonus Structure'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _benefitController,
            hint: 'e.g. 50% discount on last installment',
          ),
          const SizedBox(height: 24),

          // Popular Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mark as Most Popular',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _isPopular = !_isPopular),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _isPopular
                        ? AppColors.primaryContainer
                        : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: _isPopular
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFD4D5D9)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _createScheme,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A5F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'CREATE SCHEME',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1 * 14,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: const Color(0xFFA8A29E),
        letterSpacing: 0.1 * 12,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildMetalButton(String type, String label) {
    final isSelected = _selectedMetal == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedMetal = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1E3A5F)
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? null
              : Border.all(color: AppColors.outlineVariant.withAlpha(51)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected)
              const Icon(Icons.check_circle, size: 16, color: Colors.white),
            if (isSelected) const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFFA8A29E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTenureDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedTenure,
          isExpanded: true,
          items: [6, 12, 18, 24, 36].map((months) {
            return DropdownMenuItem(
              value: months,
              child: Text('$months Months'),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedTenure = value);
            }
          },
        ),
      ),
    );
  }

  Future<void> _toggleSchemeStatus(String schemeId, bool newStatus) async {
    if (schemeId.isEmpty) return;

    try {
      final db = ref.read(databaseServiceProvider);
      await db.toggleSchemeStatus(schemeId, newStatus);
      ref.invalidate(availableSchemesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scheme ${newStatus ? 'activated' : 'deactivated'}'),
            backgroundColor: const Color(0xFF059669),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
