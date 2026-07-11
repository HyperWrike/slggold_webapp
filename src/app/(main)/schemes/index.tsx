import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, ActivityIndicator, SafeAreaView } from 'react-native';
import { useQuery } from 'convex/react';
import { useAuth } from '../../../context/AuthContext';
import { api } from '../../../../convex/_generated/api';
import { AppColors } from '../../../constants/colors';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { StatusBar } from 'expo-status-bar';

export default function SchemesScreen() {
  const router = useRouter();
  const { sessionToken } = useAuth();
  
  const [activeTab, setActiveTab] = useState<'available' | 'my'>('available');
  const [selectedFilter, setSelectedFilter] = useState('All');

  // Queries
  const availableSchemes = useQuery(api.schemes.listActive);
  const myEnrollments = useQuery(api.enrollments.listForUserWithSchemes, sessionToken ? { sessionToken } : 'skip') as any;

  const formatCurrency = (val: number) => {
    return '₹' + new Intl.NumberFormat('en-IN', { maximumFractionDigits: 0 }).format(val);
  };

  const getFilteredSchemes = (list: any[]) => {
    if (!list) return [];
    return list.filter((s) => {
      const metalType = (s.metal_type || 'gold').toLowerCase();
      switch (selectedFilter) {
        case 'Gold': return metalType === 'gold';
        case 'Silver': return metalType === 'silver';
        case 'Combo': return metalType === 'combo';
        default: return true;
      }
    });
  };

  const filteredSchemes = availableSchemes ? getFilteredSchemes(availableSchemes) : [];

  return (
    <SafeAreaView style={styles.safeContainer}>
      <StatusBar style="dark" />
      
      {/* Top Tabs */}
      <View style={styles.tabRow}>
        <TouchableOpacity 
          style={[styles.tabItem, activeTab === 'available' && styles.tabItemActive]}
          onPress={() => setActiveTab('available')}
          activeOpacity={0.8}
        >
          <Text style={[styles.tabText, activeTab === 'available' && styles.tabTextActive]}>
            Available Schemes
          </Text>
          {activeTab === 'available' && <View style={styles.tabIndicator} />}
        </TouchableOpacity>

        <TouchableOpacity 
          style={[styles.tabItem, activeTab === 'my' && styles.tabItemActive]}
          onPress={() => setActiveTab('my')}
          activeOpacity={0.8}
        >
          <Text style={[styles.tabText, activeTab === 'my' && styles.tabTextActive]}>
            My Schemes
          </Text>
          {activeTab === 'my' && <View style={styles.tabIndicator} />}
        </TouchableOpacity>
      </View>

      <ScrollView contentContainerStyle={styles.scrollContent}>
        {activeTab === 'available' ? (
          // Available Schemes View
          <View style={styles.viewContainer}>
            {/* Filters */}
            <View style={styles.filtersContainer}>
              {['All', 'Gold', 'Silver', 'Combo'].map((f) => {
                const isSelected = selectedFilter === f;
                return (
                  <TouchableOpacity
                    key={f}
                    style={[styles.filterChip, isSelected && styles.filterChipActive]}
                    onPress={() => setSelectedFilter(f)}
                    activeOpacity={0.8}
                  >
                    <Text style={[styles.filterText, isSelected && styles.filterTextActive]}>{f}</Text>
                  </TouchableOpacity>
                );
              })}
            </View>

            {availableSchemes ? (
              filteredSchemes.length > 0 ? (
                filteredSchemes.map((scheme: any, index: number) => {
                  const isGold = scheme.metal_type === 'gold';
                  const isCombo = scheme.metal_type === 'combo';
                  
                  return (
                    <View key={scheme.id} style={styles.schemeCard}>
                      {/* Card Header Illustration/Gradient Area */}
                      <View style={[styles.cardHeaderArea, { 
                        backgroundColor: isGold 
                          ? AppColors.goldPrimary 
                          : isCombo 
                          ? '#4A0E8F' 
                          : '#C0C0C0' 
                      }]}>
                        {index === 0 && (
                          <View style={styles.popularBadge}>
                            <Text style={styles.popularBadgeText}>MOST POPULAR</Text>
                          </View>
                        )}
                        <Ionicons 
                          name={isGold ? "ribbon" : isCombo ? "sparkles" : "ellipse"} 
                          size={48} 
                          color="rgba(255, 255, 255, 0.4)" 
                        />
                      </View>

                      {/* Content */}
                      <View style={styles.cardContent}>
                        <Text style={styles.schemeName}>{scheme.name}</Text>
                        
                        <View style={styles.tagRow}>
                          <View style={styles.tag}>
                            <Text style={styles.tagText}>{scheme.metal_type.toUpperCase()}</Text>
                          </View>
                          <Text style={styles.bullet}>•</Text>
                          <Text style={styles.tagLabel}>{scheme.tenure_months} months</Text>
                          <Text style={styles.bullet}>•</Text>
                          <Text style={styles.tagLabel}>Min {formatCurrency(scheme.min_amount || 1000)}/mo</Text>
                        </View>

                        <Text style={styles.schemeDescription}>{scheme.description}</Text>

                        {scheme.benefit && (
                          <Text style={styles.benefitText}>
                            🎁 Benefit: <Text style={{ fontWeight: 'bold', color: AppColors.goldDark }}>{scheme.benefit}</Text>
                          </Text>
                        )}

                        <TouchableOpacity 
                          style={styles.enrollButton}
                          onPress={() => router.push({
                            pathname: '/(main)/schemes/enroll',
                            params: { schemeId: scheme.id }
                          })}
                        >
                          <Text style={styles.enrollButtonText}>ENROLL NOW</Text>
                          <Ionicons name="arrow-forward" size={16} color="#FFFFFF" style={{ marginLeft: 8 }} />
                        </TouchableOpacity>
                      </View>
                    </View>
                  );
                })
              ) : (
                <View style={styles.emptyContainer}>
                  <Ionicons name="gift-outline" size={48} color="#C7C7CC" />
                  <Text style={styles.emptyTitle}>No Schemes Found</Text>
                  <Text style={styles.emptyText}>New schemes will be available soon.</Text>
                </View>
              )
            ) : (
              <ActivityIndicator color={AppColors.goldPrimary} size="large" style={{ marginTop: 48 }} />
            )}
          </View>
        ) : (
          // My Schemes View
          <View style={styles.viewContainer}>
            {myEnrollments ? (
              myEnrollments.length > 0 ? (
                myEnrollments.map((enr: any) => {
                  const scheme = enr.schemes;
                  const isGold = scheme?.metal_type !== 'silver';
                  const progressPercent = enr.tenure_months > 0 ? (enr.paid_months / enr.tenure_months) : 0;
                  
                  return (
                    <View key={enr.id} style={styles.enrCard}>
                      <View style={styles.enrHeader}>
                        <View style={[styles.enrIconBox, { backgroundColor: isGold ? 'rgba(245, 200, 66, 0.15)' : 'rgba(192, 192, 192, 0.2)' }]}>
                          <Ionicons 
                            name={isGold ? "ribbon-outline" : "ellipse-outline"} 
                            size={22} 
                            color={isGold ? AppColors.goldDark : '#707070'} 
                          />
                        </View>
                        
                        <View style={styles.enrInfo}>
                          <Text style={styles.enrName} numberOfLines={1}>{scheme?.name || 'Savings Plan'}</Text>
                          <Text style={styles.enrSummary}>
                            {formatCurrency(enr.monthly_amount)}/mo • {enr.paid_months} of {enr.tenure_months} months
                          </Text>
                        </View>

                        <View style={[styles.statusBadge, { backgroundColor: enr.status === 'completed' ? 'rgba(22, 163, 74, 0.1)' : 'rgba(245, 200, 66, 0.1)' }]}>
                          <Text style={[styles.statusText, { color: enr.status === 'completed' ? AppColors.success : AppColors.goldDark }]}>
                            {enr.status?.toUpperCase() || 'ACTIVE'}
                          </Text>
                        </View>
                      </View>

                      {/* Progress bar */}
                      <View style={styles.progressContainer}>
                        <View style={styles.track}>
                          <View style={[styles.fill, { 
                            width: `${Math.min(progressPercent * 100, 100)}%`,
                            backgroundColor: isGold ? AppColors.goldPrimary : '#707070'
                          }]} />
                        </View>
                        <View style={styles.progressTextRow}>
                          <Text style={styles.progressPercent}>{Math.round(progressPercent * 100)}% COMPLETED</Text>
                          <Text style={styles.progressVal}>
                            {isGold ? `${enr.total_gold_grams.toFixed(3)}g Accumulated` : `${enr.total_silver_grams.toFixed(1)}g Accumulated`}
                          </Text>
                        </View>
                      </View>
                    </View>
                  );
                })
              ) : (
                <View style={styles.emptyContainer}>
                  <Ionicons name="card-outline" size={48} color="#C7C7CC" />
                  <Text style={styles.emptyTitle}>No Enrolled Schemes</Text>
                  <Text style={styles.emptyText}>You haven't enrolled in any gold savings plans yet.</Text>
                </View>
              )
            ) : (
              <ActivityIndicator color={AppColors.goldPrimary} size="large" style={{ marginTop: 48 }} />
            )}
          </View>
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
  tabRow: {
    flexDirection: 'row',
    backgroundColor: '#FFFFFF',
    borderBottomWidth: 1,
    borderBottomColor: AppColors.surfaceContainerHigh,
  },
  tabItem: {
    flex: 1,
    paddingVertical: 18,
    alignItems: 'center',
    position: 'relative',
  },
  tabItemActive: {},
  tabIndicator: {
    position: 'absolute',
    bottom: 0,
    left: 32,
    right: 32,
    height: 3,
    backgroundColor: AppColors.goldPrimary,
    borderTopLeftRadius: 3,
    borderTopRightRadius: 3,
  },
  tabText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#8E8E93',
  },
  tabTextActive: {
    color: AppColors.goldDark,
  },
  scrollContent: {
    padding: 24,
  },
  viewContainer: {
    gap: 20,
  },
  filtersContainer: {
    flexDirection: 'row',
    gap: 8,
    marginBottom: 8,
  },
  filterChip: {
    paddingHorizontal: 16,
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
    fontSize: 13,
    fontWeight: '600',
    color: AppColors.textSecondary,
  },
  filterTextActive: {
    color: '#FFFFFF',
  },
  schemeCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 20,
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    overflow: 'hidden',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },
  cardHeaderArea: {
    height: 120,
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative',
  },
  popularBadge: {
    position: 'absolute',
    top: 16,
    left: 16,
    backgroundColor: '#1E0A3C',
    borderRadius: 100,
    paddingHorizontal: 12,
    paddingVertical: 4,
  },
  popularBadgeText: {
    fontSize: 9,
    fontWeight: 'bold',
    color: '#FFFFFF',
  },
  cardContent: {
    padding: 20,
  },
  schemeName: {
    fontSize: 20,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
    marginBottom: 8,
  },
  tagRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginBottom: 16,
  },
  tag: {
    backgroundColor: 'rgba(245, 200, 66, 0.12)',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 4,
  },
  tagText: {
    fontSize: 11,
    fontWeight: 'bold',
    color: AppColors.goldDark,
  },
  tagLabel: {
    fontSize: 12,
    color: AppColors.textSecondary,
    fontWeight: '500',
  },
  bullet: {
    color: '#8E8E93',
  },
  schemeDescription: {
    fontSize: 14,
    color: AppColors.textSecondary,
    lineHeight: 20,
    marginBottom: 16,
  },
  benefitText: {
    fontSize: 13,
    color: AppColors.textSecondary,
    marginBottom: 20,
  },
  enrollButton: {
    height: 52,
    borderRadius: 12,
    backgroundColor: AppColors.goldPrimary,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
  },
  enrollButtonText: {
    color: '#FFFFFF',
    fontSize: 14,
    fontWeight: 'bold',
    letterSpacing: 0.5,
  },
  emptyContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 64,
    gap: 12,
  },
  emptyTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
  },
  emptyText: {
    fontSize: 14,
    color: '#8E8E93',
    textAlign: 'center',
  },
  enrCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 20,
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    padding: 16,
  },
  enrHeader: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  enrIconBox: {
    width: 44,
    height: 44,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
  },
  enrInfo: {
    flex: 1,
    marginLeft: 12,
  },
  enrName: {
    fontSize: 15,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
  },
  enrSummary: {
    fontSize: 12,
    color: AppColors.textSecondary,
    marginTop: 2,
  },
  statusBadge: {
    borderRadius: 100,
    paddingHorizontal: 10,
    paddingVertical: 4,
  },
  statusText: {
    fontSize: 9,
    fontWeight: 'bold',
  },
  progressContainer: {
    marginTop: 16,
  },
  track: {
    height: 5,
    borderRadius: 3,
    backgroundColor: AppColors.surfaceContainerHigh,
    overflow: 'hidden',
  },
  fill: {
    height: '100%',
  },
  progressTextRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 6,
  },
  progressPercent: {
    fontSize: 9,
    fontWeight: 'bold',
    color: '#8E8E93',
  },
  progressVal: {
    fontSize: 10,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
  },
});
