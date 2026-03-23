import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/core/constants/app_dimensions.dart';
import '../../../providers/metal_price_provider.dart';
import 'package:slg_golds/presentation/widgets/metal_price_card.dart';
import 'package:slg_golds/presentation/widgets/portfolio_summary_strip.dart';
import 'package:slg_golds/presentation/widgets/scheme_carousel.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metalPricesAsync = ref.watch(metalPricesProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.goldPrimary,
          onRefresh: () async {
            ref.invalidate(metalPricesProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppDimensions.p24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          'Rajesh Kumar',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const CircleAvatar(
                      backgroundColor: AppColors.goldPrimary,
                      child: Icon(Icons.person, color: AppColors.surface),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.p32),

                // Live Metal Prices
                Text(
                  'Live Metal Rates',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppDimensions.p16),
                Row(
                  children: [
                    Expanded(
                      child: metalPricesAsync.when(
                        data: (prices) => MetalPriceCard(
                          title: 'GOLD [24K]',
                          pricePerGram: prices.goldPricePerGram,
                          isGold: true,
                        ),
                        loading: () => const MetalPriceCard(
                          title: 'GOLD [24K]',
                          isGold: true,
                          isLoading: true,
                        ),
                        error: (error, _) => const MetalPriceCard(
                          title: 'GOLD [24K]',
                          isGold: true,
                          error: 'Failed',
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.p16),
                    Expanded(
                      child: metalPricesAsync.when(
                        data: (prices) => MetalPriceCard(
                          title: 'SILVER [999]',
                          pricePerGram: prices.silverPricePerGram,
                          isGold: false,
                        ),
                        loading: () => const MetalPriceCard(
                          title: 'SILVER [999]',
                          isGold: false,
                          isLoading: true,
                        ),
                        error: (error, _) => const MetalPriceCard(
                          title: 'SILVER [999]',
                          isGold: false,
                          error: 'Failed',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.p32),

                // Portfolio Summary
                Text(
                  'Your Portfolio',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppDimensions.p16),
                const PortfolioSummaryStrip(),
                const SizedBox(height: AppDimensions.p32),

                // Featured Schemes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Featured Schemes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'View All',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.goldDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.p8),
                const SchemeCarousel(),
                
                const SizedBox(height: AppDimensions.p48), // Bottom padding for shell navigator
              ],
            ),
          ),
        ),
      ),
    );
  }
}
