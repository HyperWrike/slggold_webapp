import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, ActivityIndicator, RefreshControl, SafeAreaView } from 'react-native';
import { useQuery } from 'convex/react';
import { useAuth } from '../../context/AuthContext';
import { api } from '../../../convex/_generated/api';
import { AppColors } from '../../constants/colors';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { StatusBar } from 'expo-status-bar';

export default function AdminDashboardScreen() {
  const router = useRouter();
  const { sessionToken, logout } = useAuth();
  const [refreshing, setRefreshing] = useState(false);

  // Queries
  const stats = useQuery(api.admin.stats, sessionToken ? { sessionToken } : 'skip');
  const recentTransactions = useQuery(api.transactions.listAllForAdmin, sessionToken ? { sessionToken, limit: 10 } : 'skip');

  const handleRefresh = () => {
    setRefreshing(true);
    setTimeout(() => setRefreshing(false), 800);
  };

  const formatCurrency = (val: number) => {
    return '₹' + new Intl.NumberFormat('en-IN', { maximumFractionDigits: 0 }).format(val);
  };

  const formatDate = (isoString: string) => {
    const d = new Date(isoString);
    return d.toLocaleDateString('en-IN', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' });
  };

  const handleSignOut = async () => {
    await logout();
    router.replace('/(auth)/login');
  };

  return (
    <SafeAreaView style={styles.safeContainer}>
      <StatusBar style="dark" />
      
      {/* Admin header */}
      <View style={styles.header}>
        <View style={styles.headerContent}>
          <View>
            <Text style={styles.headerCategory}>EXECUTIVE GATEWAY</Text>
            <Text style={styles.headerTitle}>Admin Dashboard</Text>
          </View>
          
          <TouchableOpacity onPress={handleSignOut} style={styles.logoutButton}>
            <Ionicons name="log-out-outline" size={22} color="#EF4444" />
          </TouchableOpacity>
        </View>
      </View>

      <ScrollView
        contentContainerStyle={styles.scrollContent}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={handleRefresh} colors={[AppColors.royalPurple]} />
        }
      >
        {/* KPI Grid */}
        {stats ? (
          <View style={styles.kpiGrid}>
            <View style={styles.kpiRow}>
              {/* Total Members */}
              <View style={[styles.kpiCard, { borderBottomColor: '#2563EB' }]}>
                <View style={[styles.kpiIconBox, { backgroundColor: 'rgba(37, 99, 235, 0.1)' }]}>
                  <Ionicons name="people" size={22} color="#2563EB" />
                </View>
                <Text style={styles.kpiLabel}>Total Members</Text>
                <Text style={styles.kpiValue}>
                  {new Intl.NumberFormat('en-IN').format(stats.totalCustomers)}
                </Text>
              </View>

              {/* Total AUM */}
              <View style={[styles.kpiCard, { borderBottomColor: AppColors.royalPurple }]}>
                <View style={[styles.kpiIconBox, { backgroundColor: 'rgba(74, 14, 143, 0.1)' }]}>
                  <Ionicons name="wallet" size={22} color={AppColors.royalPurple} />
                </View>
                <Text style={styles.kpiLabel}>Total AUM</Text>
                <Text style={styles.kpiValue}>{formatCurrency(stats.totalAUM)}</Text>
              </View>
            </View>

            <View style={styles.kpiRow}>
              {/* Today's Collections */}
              <View style={[styles.kpiCard, { borderBottomColor: '#059669' }]}>
                <View style={[styles.kpiIconBox, { backgroundColor: 'rgba(5, 150, 105, 0.1)' }]}>
                  <Ionicons name="cash" size={22} color="#059669" />
                </View>
                <Text style={styles.kpiLabel}>Today's Collection</Text>
                <Text style={styles.kpiValue}>{formatCurrency(stats.todayCollection)}</Text>
              </View>

              {/* Active Schemes */}
              <View style={[styles.kpiCard, { borderBottomColor: '#D97706' }]}>
                <View style={[styles.kpiIconBox, { backgroundColor: 'rgba(217, 119, 6, 0.1)' }]}>
                  <Ionicons name="grid" size={22} color="#D97706" />
                </View>
                <Text style={styles.kpiLabel}>Active Schemes</Text>
                <Text style={styles.kpiValue}>{stats.activeSchemes}</Text>
              </View>
            </View>
          </View>
        ) : (
          <ActivityIndicator color={AppColors.royalPurple} size="large" style={{ marginVertical: 32 }} />
        )}

        {/* Recent Transactions Section */}
        <Text style={styles.sectionTitle}>Recent Global Transactions</Text>
        
        <View style={styles.txnContainer}>
          {recentTransactions ? (
            recentTransactions.length > 0 ? (
              recentTransactions.map((txn) => {
                const isCredit = txn.type === 'credit';
                return (
                  <View key={txn._id} style={styles.txnCard}>
                    <View style={[styles.txnIconBox, { backgroundColor: isCredit ? 'rgba(22, 163, 74, 0.1)' : 'rgba(239, 68, 68, 0.1)' }]}>
                      <Ionicons 
                        name={isCredit ? "arrow-down" : "arrow-up"} 
                        size={18} 
                        color={isCredit ? AppColors.success : AppColors.error} 
                      />
                    </View>

                    <View style={styles.txnInfo}>
                      <Text style={styles.txnUser} numberOfLines={1}>{txn.user_name || 'System Transaction'}</Text>
                      <Text style={styles.txnSub}>{txn.user_username ? `@${txn.user_username} • ` : ''}{formatDate(txn.created_at)}</Text>
                    </View>

                    <Text style={[styles.txnAmount, { color: isCredit ? AppColors.success : AppColors.textPrimary }]}>
                      {isCredit ? '+' : '-'}{formatCurrency(txn.amount)}
                    </Text>
                  </View>
                );
              })
            ) : (
              <Text style={styles.emptyText}>No recent transactions found.</Text>
            )
          ) : (
            <ActivityIndicator color={AppColors.royalPurple} style={{ padding: 24 }} />
          )}
        </View>

        <View style={{ height: 100 }} />
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeContainer: {
    flex: 1,
    backgroundColor: '#F8F9FA',
  },
  header: {
    backgroundColor: '#FFFFFF',
    borderBottomWidth: 1,
    borderBottomColor: AppColors.surfaceContainerHigh,
    paddingTop: 12,
  },
  headerContent: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 24,
    height: 64,
  },
  headerCategory: {
    fontSize: 9,
    fontWeight: 'bold',
    color: '#8E8E93',
    letterSpacing: 1.5,
    marginBottom: 4,
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
  },
  logoutButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'rgba(239, 68, 68, 0.05)',
  },
  scrollContent: {
    padding: 24,
  },
  kpiGrid: {
    gap: 16,
    marginBottom: 32,
  },
  kpiRow: {
    flexDirection: 'row',
    gap: 16,
  },
  kpiCard: {
    flex: 1,
    backgroundColor: '#FFFFFF',
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    borderRadius: 16,
    padding: 16,
    borderBottomWidth: 4,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.03,
    shadowRadius: 4,
    elevation: 1,
  },
  kpiIconBox: {
    width: 36,
    height: 36,
    borderRadius: 10,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 12,
  },
  kpiLabel: {
    fontSize: 11,
    fontWeight: 'bold',
    color: '#8E8E93',
    marginBottom: 4,
    textTransform: 'uppercase',
  },
  kpiValue: {
    fontSize: 20,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
    marginBottom: 16,
  },
  txnContainer: {
    backgroundColor: '#FFFFFF',
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    borderRadius: 20,
    padding: 8,
  },
  txnCard: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 12,
    borderBottomWidth: 1,
    borderBottomColor: AppColors.surfaceContainerHigh,
  },
  txnIconBox: {
    width: 36,
    height: 36,
    borderRadius: 10,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },
  txnInfo: {
    flex: 1,
  },
  txnUser: {
    fontSize: 14,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
  },
  txnSub: {
    fontSize: 11,
    color: '#8E8E93',
    marginTop: 2,
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
});
