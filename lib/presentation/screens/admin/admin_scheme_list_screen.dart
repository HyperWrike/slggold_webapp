import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/presentation/providers/user_data_provider.dart';
import 'package:intl/intl.dart';

class AdminSchemeListScreen extends ConsumerWidget {
  const AdminSchemeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schemesAsync = ref.watch(availableSchemesProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Manage Schemes',
          style: TextStyle(
            fontFamily: 'Cormorant Garamond',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Scheme', style: TextStyle(color: Colors.white)),
        onPressed: () {
          context.push('/admin/schemes/create');
        },
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(availableSchemesProvider);
        },
        child: schemesAsync.when(
          data: (schemes) {
            if (schemes.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.card_giftcard_outlined,
                      size: 64,
                      color: AppColors.outlineVariant,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No Schemes',
                      style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Create a new scheme to get started',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: schemes.length,
              itemBuilder: (context, index) {
                final scheme = schemes[index];
                final name = scheme['name'] as String? ?? 'Scheme';
                final tenure = (scheme['tenure_months'] as int?) ?? 0;
                final monthly =
                    (scheme['monthly_amount'] as num?)?.toDouble() ?? 0;
                final metalType = scheme['metal_type'] as String? ?? 'gold';
                final isActive = scheme['is_active'] as bool? ?? true;
                final isPopular = scheme['is_popular'] as bool? ?? false;
                final benefit = scheme['benefit'] as String? ?? '';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
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
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: metalType == 'gold'
                                ? AppColors.primaryFixed
                                : AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            metalType == 'gold'
                                ? Icons.workspace_premium
                                : Icons.diamond_outlined,
                            color: metalType == 'gold'
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        fontFamily: 'DM Sans',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  if (isPopular)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryFixed,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'POPULAR',
                                        style: TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$tenure months • ₹${NumberFormat('#,##0', 'en_IN').format(monthly)}/mo',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if (benefit.isNotEmpty)
                                Text(
                                  benefit,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFD1FAE5)
                                : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isActive
                                  ? const Color(0xFF047857)
                                  : AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                const Text('Failed to load schemes'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => ref.invalidate(availableSchemesProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
