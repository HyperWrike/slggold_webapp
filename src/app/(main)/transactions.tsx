import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, RefreshControl, ActivityIndicator, SafeAreaView } from 'react-native';
import { useQuery } from 'convex/react';
import { useAuth } from '../../context/AuthContext';
import { api } from '../../../convex/_generated/api';
import { AppColors } from '../../constants/colors';
import { Ionicons } from '@expo/vector-icons';
import { StatusBar } from 'expo-status-bar';

export default function TransactionsScreen() {
  const { sessionToken } = useAuth();
  
  const [selectedFilter, setSelectedFilter] = useState('All');
  const [refreshing, setRefreshing] = useState(false);

  // Load Transactions query
  const transactions = useQuery(api.transactions.listForUser, sessionToken ? { sessionToken } : 'skip');

  const handleRefresh = () => {
    setRefreshing(true);
    setTimeout(() => setRefreshing(false), 800);
  };

  const formatCurrency = (val: number) => {
    return '₹' + new Intl.NumberFormat('en-IN', { maximumFractionDigits: 2 }).format(val);
  };

  const formatDate = (isoString: string) => {
    const d = new Date(isoString);
    return d.toLocaleDateString('en-IN', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' });
  };

  const getMonthHeader = (isoString: string) => {
    const d = new Date(isoString);
    return d.toLocaleDateString('en-US', { month: 'long', year: 'numeric' }).toUpperCase();
  };

  const applyFilters = (list: any[]) => {
    if (!list) return [];
    
    return list.filter((t) => {
      const desc = (t.description || '').toLowerCase();
      const type = (t.type || '').toLowerCase();
      
      switch (selectedFilter) {
        case 'Gold':
          return desc.includes('gold') || type === 'credit' || t.gold_grams > 0;
        case 'Silver':
          return desc.includes('silver') || t.silver_grams > 0;
        case 'This Month': {
          const tDate = new Date(t.created_at);
          const now = new Date();
          return tDate.getMonth() === now.getMonth() && tDate.getFullYear() === now.getFullYear();
        }
        default:
          return true;
      }
    });
  };

  // Group transactions by month
  const groupTransactions = (list: any[]) => {
    const groups: { [key: string]: any[] } = {};
    list.forEach((txn) => {
      const key = getMonthHeader(txn.created_at);
      if (!groups[key]) groups[key] = [];
      groups[key].push(txn);
    });
    return groups;
  };

  const getIconName = (desc: string) => {
    const lower = desc.toLowerCase();
    if (lower.includes('gold')) return 'ribbon-outline';
    if (lower.includes('silver')) return 'ellipse-outline';
    if (lower.includes('gst')) return 'calculator-outline';
    return 'card-outline';
  };

  const filteredList = transactions ? applyFilters(transactions) : [];
  const groupedGroups = groupTransactions(filteredList);

  const filters = ['All', 'Gold', 'Silver', 'This Month'];

  return (
    <SafeAreaView style={styles.safeContainer}>
      <StatusBar style="dark" />
      
      {/* Filter bar */}
      <View style={styles.filterBar}>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.filterScroll}>
          {filters.map((filter) => {
            const isSelected = selectedFilter === filter;
            return (
              <TouchableOpacity
                key={filter}
                style={[styles.filterChip, isSelected && styles.filterChipActive]}
                onPress={() => setSelectedFilter(filter)}
                activeOpacity={0.8}
              >
                <Text style={[styles.filterText, isSelected && styles.filterTextActive]}>{filter}</Text>
              </TouchableOpacity>
            );
          })}
        </ScrollView>
      </View>

      <ScrollView
        contentContainerStyle={styles.scrollContent}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={handleRefresh} colors={[AppColors.goldPrimary]} />
        }
      >
        {transactions ? (
          filteredList.length > 0 ? (
            Object.keys(groupedGroups).map((monthKey) => (
              <View key={monthKey} style={styles.monthSection}>
                <Text style={styles.monthHeader}>{monthKey}</Text>
                
                <View style={styles.txnsContainer}>
                  {groupedGroups[monthKey].map((txn) => {
                    const isCredit = txn.type === 'credit';
                    const hasDetails = txn.net_amount !== undefined || txn.gst !== undefined || txn.gold_grams !== undefined || txn.silver_grams !== undefined;
                    
                    return (
                      <View key={txn.id} style={styles.txnCard}>
                        <View style={styles.txnTopRow}>
                          <View style={[styles.iconBox, { backgroundColor: isCredit ? 'rgba(22, 163, 74, 0.1)' : 'rgba(79, 70, 52, 0.1)' }]}>
                            <Ionicons 
                              name={getIconName(txn.description || '')} 
                              size={20} 
                              color={isCredit ? AppColors.success : AppColors.goldDark} 
                            />
                          </View>
                          
                          <View style={styles.txnMainInfo}>
                            <Text style={styles.txnDesc} numberOfLines={1}>
                              {txn.description || (isCredit ? 'Installment payment' : 'Direct purchase')}
                            </Text>
                            <Text style={styles.txnTime}>{formatDate(txn.created_at)}</Text>
                          </View>

                          <Text style={[styles.txnAmount, { color: isCredit ? AppColors.success : AppColors.textPrimary }]}>
                            {isCredit ? '+' : '-'}{formatCurrency(txn.amount)}
                          </Text>
                        </View>

                        {/* Expandable details segment */}
                        {hasDetails && (
                          <View style={styles.txnDetailsBox}>
                            <View style={styles.detailsDivider} />
                            <View style={styles.detailsRow}>
                              {txn.net_amount !== undefined && (
                                <View style={styles.detailCol}>
                                  <Text style={styles.detailLabel}>Net Amount</Text>
                                  <Text style={styles.detailVal}>{formatCurrency(txn.net_amount)}</Text>
                                </View>
                              )}
                              
                              {txn.gst !== undefined && (
                                <View style={styles.detailCol}>
                                  <Text style={styles.detailLabel}>GST (3%)</Text>
                                  <Text style={styles.detailVal}>{formatCurrency(txn.gst)}</Text>
                                </View>
                              )}

                              {txn.gold_grams > 0 && (
                                <View style={[styles.detailCol, { alignItems: 'flex-end' }]}>
                                  <Text style={styles.detailLabel}>Gold weight</Text>
                                  <Text style={[styles.detailVal, { color: AppColors.goldDark }]}>{txn.gold_grams.toFixed(3)}g</Text>
                                </View>
                              )}

                              {txn.silver_grams > 0 && (
                                <View style={[styles.detailCol, { alignItems: 'flex-end' }]}>
                                  <Text style={styles.detailLabel}>Silver weight</Text>
                                  <Text style={[styles.detailVal, { color: '#707070' }]}>{txn.silver_grams.toFixed(1)}g</Text>
                                </View>
                              )}
                            </View>
                          </View>
                        )}
                        
                        {txn.status !== 'completed' && (
                          <View style={[styles.statusBadge, { backgroundColor: txn.status === 'pending' ? 'rgba(217, 119, 6, 0.15)' : 'rgba(239, 68, 68, 0.15)' }]}>
                            <Text style={[styles.statusText, { color: txn.status === 'pending' ? '#D97706' : '#EF4444' }]}>
                              {txn.status?.toUpperCase() || 'PENDING'}
                            </Text>
                          </View>
                        )}
                      </View>
                    );
                  })}
                </View>
              </View>
            ))
          ) : (
            <View style={styles.emptyState}>
              <Ionicons name="receipt-outline" size={64} color="#C7C7CC" />
              <Text style={styles.emptyTitle}>No Transactions</Text>
              <Text style={styles.emptySubtitle}>Your transaction history will appear here.</Text>
            </View>
          )
        ) : (
          <ActivityIndicator color={AppColors.goldPrimary} size="large" style={{ marginTop: 48 }} />
        )}
        
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
  filterBar: {
    backgroundColor: '#FFFFFF',
    borderBottomWidth: 1,
    borderBottomColor: AppColors.surfaceContainerHigh,
    paddingVertical: 12,
  },
  filterScroll: {
    paddingHorizontal: 24,
    gap: 12,
  },
  filterChip: {
    paddingHorizontal: 20,
    paddingVertical: 8,
    borderRadius: 100,
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    backgroundColor: AppColors.surfaceContainerLowest,
  },
  filterChipActive: {
    backgroundColor: AppColors.goldPrimary,
    borderColor: AppColors.goldPrimary,
  },
  filterText: {
    fontSize: 14,
    fontWeight: '600',
    color: AppColors.textSecondary,
  },
  filterTextActive: {
    color: '#FFFFFF',
  },
  scrollContent: {
    padding: 24,
    paddingTop: 16,
  },
  monthSection: {
    marginBottom: 24,
  },
  monthHeader: {
    fontSize: 10,
    fontWeight: 'bold',
    color: AppColors.outline,
    letterSpacing: 2,
    marginBottom: 12,
  },
  txnsContainer: {
    gap: 16,
  },
  txnCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 20,
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    padding: 16,
  },
  txnTopRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  iconBox: {
    width: 40,
    height: 40,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
  },
  txnMainInfo: {
    flex: 1,
    marginLeft: 12,
  },
  txnDesc: {
    fontSize: 14,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
  },
  txnTime: {
    fontSize: 11,
    color: '#8E8E93',
    marginTop: 2,
  },
  txnAmount: {
    fontSize: 14,
    fontWeight: 'bold',
  },
  txnDetailsBox: {
    marginTop: 12,
  },
  detailsDivider: {
    height: 1,
    backgroundColor: AppColors.surfaceContainerHigh,
    marginBottom: 12,
  },
  detailsRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  detailCol: {
    flex: 1,
  },
  detailLabel: {
    fontSize: 10,
    color: '#8E8E93',
    marginBottom: 2,
  },
  detailVal: {
    fontSize: 12,
    fontWeight: '600',
    color: AppColors.textPrimary,
  },
  statusBadge: {
    alignSelf: 'flex-end',
    borderRadius: 4,
    paddingHorizontal: 8,
    paddingVertical: 2,
    marginTop: 12,
  },
  statusText: {
    fontSize: 9,
    fontWeight: 'bold',
  },
  emptyState: {
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 64,
    gap: 12,
  },
  emptyTitle: {
    fontSize: 22,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
  },
  emptySubtitle: {
    fontSize: 14,
    color: '#8E8E93',
  },
});
