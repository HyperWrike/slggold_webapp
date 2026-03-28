import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/presentation/providers/auth_provider.dart';
import 'package:slg_golds/presentation/providers/user_data_provider.dart';
import 'package:slg_golds/data/datasources/database_service.dart';
import 'package:intl/intl.dart';

class NotificationPopup extends ConsumerWidget {
  const NotificationPopup({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationPopup(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final userId = authState.user?.id;

    if (userId == null) {
      return _buildLoginRequired(context);
    }

    final notificationsAsync = ref.watch(userNotificationsProvider(userId));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                notificationsAsync.when(
                  data: (notifications) {
                    final unreadCount = notifications
                        .where((n) => n['is_read'] != true)
                        .length;
                    if (unreadCount == 0) return const SizedBox.shrink();
                    return Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            '$unreadCount New',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            final db = ref.read(databaseServiceProvider);
                            await db.markAllNotificationsAsRead(userId);
                            ref.invalidate(userNotificationsProvider(userId));
                          },
                          child: const Text(
                            'Mark all read',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.surfaceContainerHigh),

          // Notification list
          Flexible(
            child: notificationsAsync.when(
              data: (notifications) {
                if (notifications.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    indent: 76,
                    color: AppColors.surfaceContainerLow,
                  ),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _buildNotificationTile(
                      context,
                      ref,
                      notification,
                      userId,
                    );
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
              error: (error, _) => _buildEmptyState(),
            ),
          ),

          // Bottom safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  Widget _buildLoginRequired(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(48),
            child: Column(
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: AppColors.outlineVariant,
                ),
                SizedBox(height: 16),
                Text(
                  'Login Required',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Please login to view notifications',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 48,
            color: AppColors.outlineVariant,
          ),
          SizedBox(height: 16),
          Text(
            'No Notifications',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'You\'re all caught up!',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> notification,
    String userId,
  ) {
    final title = notification['title'] as String? ?? '';
    final message = notification['message'] as String? ?? '';
    final iconName = notification['icon'] as String? ?? 'notifications';
    final type = notification['type'] as String? ?? 'info';
    final isRead = notification['is_read'] as bool? ?? false;
    final createdAt = notification['created_at'] as String?;
    final notificationId = notification['id']?.toString() ?? '';

    final timeStr = createdAt != null
        ? _formatTimeAgo(DateTime.parse(createdAt))
        : '';

    final iconData = _getIconData(iconName);
    final iconColor = _getTypeColor(type);

    return GestureDetector(
      onTap: () async {
        if (!isRead && notificationId.isNotEmpty) {
          final db = ref.read(databaseServiceProvider);
          await db.markNotificationAsRead(notificationId);
          ref.invalidate(userNotificationsProvider(userId));
        }
      },
      child: Container(
        color: !isRead ? AppColors.primaryFixed.withAlpha(26) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: !isRead
                      ? iconColor.withAlpha(26)
                      : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  iconData,
                  color: !isRead ? iconColor : AppColors.textSecondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 14,
                              fontWeight: !isRead
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeStr,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'savings':
        return Icons.savings;
      case 'trending_up':
        return Icons.trending_up;
      case 'workspace_premium':
        return Icons.workspace_premium;
      case 'verified':
        return Icons.verified;
      case 'local_offer':
        return Icons.local_offer;
      case 'star':
        return Icons.star;
      case 'payments':
        return Icons.payments;
      case 'diamond':
        return Icons.diamond;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      default:
        return Icons.notifications;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'payment':
        return const Color(0xFF059669);
      case 'alert':
        return const Color(0xFFF59E0B);
      case 'promo':
        return AppColors.secondary;
      case 'system':
        return Colors.blue;
      default:
        return AppColors.primary;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM dd').format(dateTime);
  }
}
