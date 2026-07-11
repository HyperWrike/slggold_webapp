import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import 'slg_card.dart';

class SchemeCarousel extends StatelessWidget {
  const SchemeCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy schemes
    final schemes = [
      {'title': 'Gold Plus Plan', 'duration': '11 Months', 'benefit': '1 Month Free'},
      {'title': 'Swarna Nidhi', 'duration': '24 Months', 'benefit': 'Bonus Grams'},
    ];

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: schemes.length,
        itemBuilder: (context, index) {
          final scheme = schemes[index];
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: AppDimensions.p16),
            child: SlgCard(
              backgroundColor: AppColors.surfaceContainerLowest,
              onTap: () {},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.stars, color: AppColors.goldPrimary),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withAlpha(20),
                          borderRadius: BorderRadius.circular(AppDimensions.r4),
                        ),
                        child: Text(
                          scheme['benefit']!,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    scheme['title']!,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppDimensions.p4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: AppDimensions.p4),
                      Text(
                        scheme['duration']!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
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
  }
}
