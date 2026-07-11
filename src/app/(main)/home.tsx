import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, RefreshControl, Dimensions, Modal, ActivityIndicator, SafeAreaView, Platform } from 'react-native';
import { useQuery, useMutation } from 'convex/react';
import { useAuth } from '../../context/AuthContext';
import { api } from '../../../convex/_generated/api';
import { AppColors } from '../../constants/colors';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { StatusBar } from 'expo-status-bar';

const { width } = Dimensions.get('window');

export default function HomeScreen() {
  const router = useRouter();
  const { user, sessionToken } = useAuth();
  const [refreshing, setRefreshing] = useState(false);
  const [notifModalVisible, setNotifModalVisible] = useState(false);

  // Queries
  const metalPrices = useQuery(api.metalPrices.latest);
  const portfolio = useQuery(api.portfolio.summary, sessionToken ? { sessionToken } : 'skip');
  const enrollments = useQuery(api.enrollments.listForUserWithSchemes, sessionToken ? { sessionToken } : 'skip');
  const transactions = useQuery(api.transactions.listForUser, sessionToken ? { sessionToken } : 'skip') as any;
  const schemes = useQuery(api.schemes.listActive) as any;
  const unreadNotifs = useQuery(api.notifications.listUnread, sessionToken ? { sessionToken } : 'skip');
  const allNotifs = useQuery(api.notifications.listForUser, sessionToken ? { sessionToken } : 'skip') as any;

  // Mutations
  const markAllRead = useMutation(api.notifications.markAllRead);

  const getGreeting = () => {
    const hour = new Date().getHours();
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  };

  const handleRefresh = async () => {
    setRefreshing(true);
    // Convex queries are auto-updated in real-time, but we add a brief delay for UX satisfaction
    setTimeout(() => {
      setRefreshing(false);
    }, 800);
  };

  const handleMarkAllRead = async () => {
    if (sessionToken) {
      try {
        await markAllRead({ sessionToken });
      } catch (e) {
        console.error('Error marking notifications as read:', e);
      }
    }
  };

  const formatCurrency = (val: number) => {
    return '₹' + new Intl.NumberFormat('en-IN', { maximumFractionDigits: 2 }).format(val);
  };

  const formatDate = (isoString: string) => {
    const d = new Date(isoString);
    return d.toLocaleDateString('en-IN', { day: 'numeric', month: 'short' });
  };

  return (
    <SafeAreaView style={styles.safeContainer}>
      <StatusBar style="dark" />
      
      {/* Header bar */}
      <View style={styles.appBar}>
        <View style={styles.appBarContent}>
          <TouchableOpacity onPress={() => router.push('/(main)/profile')} style={styles.avatarButton}>
            <View style={styles.avatar}>
              <Text style={styles.avatarText}>
                {user?.full_name ? user.full_name.charAt(0).toUpperCase() : 'U'}
              </Text>
            </View>
            <Text style={styles.greetingText}>
              {getGreeting()}, {user?.full_name ? user.full_name.split(' ')[0] : 'User'} 👋
            </Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={() => setNotifModalVisible(true)} style={styles.notifButton}>
            <Ionicons name="notifications-outline" size={24} color="#8E8E93" />
            {unreadNotifs && unreadNotifs.length > 0 && (
              <View style={styles.notifBadge}>
                <Text style={styles.notifBadgeText}>{unreadNotifs.length}</Text>
              </View>
            )}
          </TouchableOpacity>
        </View>
      </View>

      <ScrollView
        contentContainerStyle={styles.scrollContent}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={handleRefresh} colors={[AppColors.goldPrimary]} />
        }
      >
        {/* Section 1: Live Prices */}
        <View style={styles.sectionHeader}>
          <View>
            <Text style={styles.sectionCategory}>MARKET PULSE</Text>
            <Text style={styles.sectionTitle}>Live Prices</Text>
          </View>
          <View style={styles.badgeContainer}>
            <View style={styles.badgeDot} />
            <Text style={styles.badgeText}>Live Rate</Text>
          </View>
        </View>

        <View style={styles.metalPricesRow}>
          {/* Gold Card */}
          <TouchableOpacity 
            style={[styles.metalCard, styles.goldCard]} 
            activeOpacity={0.9}
            onPress={() => router.push('/(main)/portfolio')}
          >
            <View style={styles.metalCardHeader}>
              <Text style={styles.metalLabel}>🥇 GOLD 24K</Text>
              <View style={styles.percentBadge}>
                <Text style={styles.percentText}>+0.8%</Text>
              </View>
            </View>
            {metalPrices ? (
              <Text style={styles.pricePerGram}>{formatCurrency(metalPrices.goldPricePerGram)}</Text>
            ) : (
              <ActivityIndicator color="#FFFFFF" size="small" style={{ marginVertical: 4 }} />
            )}
            <Text style={styles.perGramText}>per gram</Text>
            <View style={styles.divider} />
            <Text style={styles.ozPrice}>
              {metalPrices ? formatCurrency(metalPrices.goldPricePerGram * 31.1035) : '--'}
            </Text>
            <Text style={styles.ozText}>/ troy oz</Text>
          </TouchableOpacity>

          {/* Silver Card */}
          <TouchableOpacity 
            style={[styles.metalCard, styles.silverCard]} 
            activeOpacity={0.9}
            onPress={() => router.push('/(main)/portfolio')}
          >
            <View style={styles.metalCardHeader}>
              <Text style={styles.metalLabel}>⬜ SILVER</Text>
              <View style={[styles.percentBadge, { backgroundColor: 'rgba(255, 255, 255, 0.25)' }]}>
                <Text style={styles.percentText}>-0.3%</Text>
              </View>
            </View>
            {metalPrices ? (
              <Text style={styles.pricePerGram}>{formatCurrency(metalPrices.silverPricePerGram)}</Text>
            ) : (
              <ActivityIndicator color="#FFFFFF" size="small" style={{ marginVertical: 4 }} />
            )}
            <Text style={styles.perGramText}>per gram</Text>
            <View style={styles.divider} />
            <Text style={styles.ozPrice}>
              {metalPrices ? formatCurrency(metalPrices.silverPricePerGram * 31.1035) : '--'}
            </Text>
            <Text style={styles.ozText}>/ troy oz</Text>
          </TouchableOpacity>
        </View>

        {/* Section 2: Portfolio Glance */}
        <View style={[styles.sectionHeader, { marginTop: 32 }]}>
          <Text style={styles.sectionTitle}>Portfolio Glance</Text>
        </View>

        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.glanceRow}>
          {/* Gold Balance */}
          <View style={styles.glanceChip}>
            <Text style={styles.glanceIcon}>🥇</Text>
            <View>
              <Text style={styles.glanceValue}>
                {portfolio ? portfolio.totalGoldGrams.toFixed(2) + 'g' : '0.00g'}
              </Text>
              <Text style={styles.glanceLabel}>Total Gold</Text>
            </View>
          </View>

          {/* Silver Balance */}
          <View style={styles.glanceChip}>
            <Text style={styles.glanceIcon}>⬜</Text>
            <View>
              <Text style={styles.glanceValue}>
                {portfolio ? portfolio.totalSilverGrams.toFixed(1) + 'g' : '0.0g'}
              </Text>
              <Text style={styles.glanceLabel}>Total Slvr</Text>
            </View>
          </View>

          {/* Active Schemes */}
          <View style={styles.glanceChip}>
            <Ionicons name="calendar-outline" size={20} color={AppColors.goldDark} style={{ marginRight: 8 }} />
            <View>
              <Text style={styles.glanceValue}>
                {portfolio ? portfolio.activeEnrollments : '0'}
              </Text>
              <Text style={styles.glanceLabel}>Active Plans</Text>
            </View>
          </View>
        </ScrollView>

        {/* Section 3: Savings Schemes */}
        <View style={[styles.sectionHeader, { marginTop: 32 }]}>
          <Text style={styles.sectionTitle}>Savings Schemes</Text>
          <TouchableOpacity onPress={() => router.push('/(main)/schemes')}>
            <Text style={styles.seeAllLink}>See All →</Text>
          </TouchableOpacity>
        </View>

        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.schemesRow}>
          {schemes && schemes.length > 0 ? (
            schemes.slice(0, 3).map((scheme: any, idx: number) => (
              <TouchableOpacity
                key={scheme.id}
                style={[styles.schemeCard, { borderLeftColor: scheme.metal_type === 'gold' ? AppColors.goldDark : '#A8A29E' }]}
                activeOpacity={0.8}
                onPress={() => router.push('/(main)/schemes')}
              >
                {idx === 0 && (
                  <View style={styles.popularBadge}>
                    <Text style={styles.popularBadgeText}>POPULAR</Text>
                  </View>
                )}
                <Text style={styles.schemeName} numberOfLines={1}>{scheme.name}</Text>
                <View style={styles.schemeDetails}>
                  <Text style={styles.schemePrice}>{formatCurrency(scheme.monthly_amount)}/mo</Text>
                  <Text style={styles.schemeTenure}>{scheme.tenure_months} months</Text>
                </View>
                <Text style={styles.schemeDesc} numberOfLines={2}>
                  {scheme.description || 'Secure your future with gold.'}
                </Text>
              </TouchableOpacity>
            ))
          ) : (
            <ActivityIndicator color={AppColors.goldPrimary} style={{ padding: 24 }} />
          )}
        </ScrollView>

        {/* Section 4: Recent Activity */}
        <View style={[styles.sectionHeader, { marginTop: 32 }]}>
          <Text style={styles.sectionTitle}>Recent Activity</Text>
        </View>

        <View style={styles.activityContainer}>
          {transactions && transactions.length > 0 ? (
            transactions.slice(0, 3).map((txn: any) => {
              const isCredit = txn.type === 'credit';
              return (
                <View key={txn.id} style={styles.txnItem}>
                  <View style={[styles.txnIconContainer, { backgroundColor: isCredit ? 'rgba(22, 163, 74, 0.1)' : 'rgba(186, 26, 26, 0.1)' }]}>
                    <Ionicons 
                      name={isCredit ? "arrow-down" : "arrow-up"} 
                      size={20} 
                      color={isCredit ? AppColors.success : AppColors.error} 
                    />
                  </View>
                  <View style={styles.txnDetails}>
                    <Text style={styles.txnDesc}>{txn.description || (isCredit ? 'Deposit' : 'Withdrawal')}</Text>
                    <Text style={styles.txnDate}>{formatDate(txn.created_at)}</Text>
                  </View>
                  <Text style={[styles.txnAmount, { color: isCredit ? AppColors.success : AppColors.textPrimary }]}>
                    {isCredit ? '+' : '-'}{formatCurrency(txn.amount)}
                  </Text>
                </View>
              );
            })
          ) : (
            <Text style={styles.emptyText}>No recent activity found.</Text>
          )}
        </View>

        <View style={{ height: 100 }} />
      </ScrollView>

      {/* Notifications Modal */}
      <Modal
        animationType="slide"
        transparent={true}
        visible={notifModalVisible}
        onRequestClose={() => setNotifModalVisible(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>Notifications</Text>
              <View style={{ flexDirection: 'row', gap: 12 }}>
                {unreadNotifs && unreadNotifs.length > 0 && (
                  <TouchableOpacity onPress={handleMarkAllRead}>
                    <Text style={styles.markReadText}>Mark all read</Text>
                  </TouchableOpacity>
                )}
                <TouchableOpacity onPress={() => setNotifModalVisible(false)}>
                  <Ionicons name="close" size={24} color={AppColors.textPrimary} />
                </TouchableOpacity>
              </View>
            </View>

            <ScrollView contentContainerStyle={styles.notifScrollContent}>
              {allNotifs && allNotifs.length > 0 ? (
                allNotifs.map((notif: any) => (
                  <View key={notif.id} style={[styles.notifItem, !notif.is_read && styles.notifUnreadItem]}>
                    <View style={styles.notifHeaderRow}>
                      <Text style={styles.notifTitle}>{notif.title}</Text>
                      {!notif.is_read && <View style={styles.notifDot} />}
                    </View>
                    <Text style={styles.notifBody}>{notif.message}</Text>
                    <Text style={styles.notifTime}>{formatDate(notif.created_at)}</Text>
                  </View>
                ))
              ) : (
                <View style={styles.emptyNotifContainer}>
                  <Ionicons name="notifications-off-outline" size={48} color="#C7C7CC" />
                  <Text style={styles.emptyNotifText}>No notifications yet</Text>
                </View>
              )}
            </ScrollView>
          </View>
        </View>
      </Modal>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeContainer: {
    flex: 1,
    backgroundColor: '#F8F9FA',
  },
  appBar: {
    backgroundColor: '#FFFFFF',
    borderBottomWidth: 1,
    borderBottomColor: AppColors.surfaceContainerHigh,
    paddingTop: Platform.OS === 'ios' ? 0 : 12,
  },
  appBarContent: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 24,
    height: 64,
  },
  avatarButton: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  avatar: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: AppColors.surfaceContainer,
    borderWidth: 1,
    borderColor: 'rgba(129, 118, 98, 0.2)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  avatarText: {
    fontSize: 16,
    fontWeight: 'bold',
    color: AppColors.primary,
  },
  greetingText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: AppColors.primary,
  },
  notifButton: {
    width: 40,
    height: 40,
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative',
  },
  notifBadge: {
    position: 'absolute',
    top: 4,
    right: 4,
    backgroundColor: AppColors.error,
    borderRadius: 8,
    width: 16,
    height: 16,
    justifyContent: 'center',
    alignItems: 'center',
  },
  notifBadgeText: {
    color: '#FFFFFF',
    fontSize: 9,
    fontWeight: 'bold',
  },
  scrollContent: {
    paddingHorizontal: 24,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-end',
    marginTop: 24,
    marginBottom: 16,
  },
  sectionCategory: {
    fontSize: 10,
    fontWeight: 'bold',
    color: AppColors.outline,
    letterSpacing: 1.5,
    marginBottom: 4,
  },
  sectionTitle: {
    fontSize: 22,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
  },
  badgeContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: AppColors.surfaceContainerHigh,
    borderRadius: 100,
    paddingHorizontal: 12,
    paddingVertical: 4,
  },
  badgeDot: {
    width: 6,
    height: 6,
    borderRadius: 3,
    backgroundColor: AppColors.primaryContainer,
    marginRight: 6,
  },
  badgeText: {
    fontSize: 10,
    fontWeight: 'bold',
    color: AppColors.textSecondary,
  },
  metalPricesRow: {
    flexDirection: 'row',
    gap: 16,
  },
  metalCard: {
    flex: 1,
    borderRadius: 20,
    padding: 16,
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.15,
    shadowRadius: 16,
    elevation: 6,
  },
  goldCard: {
    backgroundColor: AppColors.goldPrimary,
    shadowColor: AppColors.goldPrimary,
  },
  silverCard: {
    backgroundColor: AppColors.silverPrimary,
    shadowColor: AppColors.silverPrimary,
  },
  metalCardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  metalLabel: {
    fontSize: 10,
    fontWeight: 'bold',
    color: '#FFFFFF',
    letterSpacing: 1,
  },
  percentBadge: {
    backgroundColor: 'rgba(255, 255, 255, 0.3)',
    borderRadius: 4,
    paddingHorizontal: 6,
    paddingVertical: 2,
  },
  percentText: {
    color: '#FFFFFF',
    fontSize: 10,
    fontWeight: 'bold',
  },
  pricePerGram: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#FFFFFF',
  },
  perGramText: {
    fontSize: 10,
    color: 'rgba(255, 255, 255, 0.8)',
    marginBottom: 12,
  },
  divider: {
    height: 1,
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    marginBottom: 12,
  },
  ozPrice: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#FFFFFF',
  },
  ozText: {
    fontSize: 9,
    color: 'rgba(255, 255, 255, 0.7)',
  },
  glanceRow: {
    gap: 12,
    paddingBottom: 8,
  },
  glanceChip: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FFFFFF',
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    borderRadius: 12,
    paddingHorizontal: 16,
    paddingVertical: 12,
    minWidth: 128,
  },
  glanceIcon: {
    fontSize: 20,
    marginRight: 8,
  },
  glanceValue: {
    fontSize: 14,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
  },
  glanceLabel: {
    fontSize: 10,
    color: '#8E8E93',
  },
  seeAllLink: {
    fontSize: 12,
    fontWeight: 'bold',
    color: AppColors.goldDark,
  },
  schemesRow: {
    gap: 16,
    paddingBottom: 8,
  },
  schemeCard: {
    width: 250,
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    borderLeftWidth: 4,
    padding: 20,
    position: 'relative',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },
  popularBadge: {
    position: 'absolute',
    top: 12,
    right: 12,
    backgroundColor: AppColors.primaryFixed,
    borderRadius: 4,
    paddingHorizontal: 8,
    paddingVertical: 2,
  },
  popularBadgeText: {
    fontSize: 8,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
  },
  schemeName: {
    fontSize: 16,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
    marginBottom: 8,
    width: 160,
  },
  schemeDetails: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  schemePrice: {
    fontSize: 14,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
  },
  schemeTenure: {
    fontSize: 12,
    color: AppColors.textSecondary,
  },
  schemeDesc: {
    fontSize: 12,
    color: '#8E8E93',
    lineHeight: 16,
  },
  activityContainer: {
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    paddingHorizontal: 16,
    paddingTop: 8,
    paddingBottom: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },
  txnItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: AppColors.surfaceContainerHigh,
  },
  txnIconContainer: {
    width: 36,
    height: 36,
    borderRadius: 18,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },
  txnDetails: {
    flex: 1,
  },
  txnDesc: {
    fontSize: 14,
    fontWeight: '600',
    color: AppColors.textPrimary,
  },
  txnDate: {
    fontSize: 12,
    color: '#8E8E93',
  },
  txnAmount: {
    fontSize: 14,
    fontWeight: 'bold',
  },
  emptyText: {
    textAlign: 'center',
    color: '#8E8E93',
    paddingVertical: 24,
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.4)',
    justifyContent: 'flex-end',
  },
  modalContent: {
    backgroundColor: '#FFFFFF',
    borderTopLeftRadius: 24,
    borderTopRightRadius: 24,
    maxHeight: '80%',
    minHeight: '40%',
  },
  modalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 24,
    borderBottomWidth: 1,
    borderBottomColor: AppColors.surfaceContainerHigh,
  },
  modalTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
  },
  markReadText: {
    color: AppColors.goldDark,
    fontWeight: 'bold',
    fontSize: 14,
  },
  notifScrollContent: {
    padding: 24,
    gap: 16,
  },
  notifItem: {
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    borderRadius: 16,
    padding: 16,
    backgroundColor: '#FFFFFF',
  },
  notifUnreadItem: {
    borderColor: 'rgba(245, 200, 66, 0.3)',
    backgroundColor: 'rgba(245, 200, 66, 0.03)',
  },
  notifHeaderRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 4,
  },
  notifTitle: {
    fontSize: 15,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
  },
  notifDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: AppColors.goldPrimary,
  },
  notifBody: {
    fontSize: 13,
    color: AppColors.textSecondary,
    marginBottom: 8,
    lineHeight: 18,
  },
  notifTime: {
    fontSize: 11,
    color: '#8E8E93',
  },
  emptyNotifContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 48,
    gap: 12,
  },
  emptyNotifText: {
    fontSize: 15,
    color: '#8E8E93',
  },
});
