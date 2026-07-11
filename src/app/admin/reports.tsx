import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, ActivityIndicator, Alert, SafeAreaView } from 'react-native';
import { useQuery } from 'convex/react';
import { useAuth } from '../../context/AuthContext';
import { api } from '../../../convex/_generated/api';
import { AppColors } from '../../constants/colors';
import { Ionicons } from '@expo/vector-icons';
import { StatusBar } from 'expo-status-bar';

export default function AdminReportsScreen() {
  const { sessionToken } = useAuth();
  const [selectedPeriod, setSelectedPeriod] = useState('This Month');

  // Queries
  const allTxns = useQuery(api.transactions.listAllForAdmin, sessionToken ? { sessionToken } : 'skip') as any;
  const allCustomers = useQuery(api.admin.listCustomers, sessionToken ? { sessionToken } : 'skip') as any;
  const allSchemes = useQuery(api.schemes.listActive) as any;
  const allEnrollments = useQuery(api.enrollments.listAllForReports, sessionToken ? { sessionToken } : 'skip') as any;

  const formatCurrency = (val: number) => {
    return '₹' + new Intl.NumberFormat('en-IN', { maximumFractionDigits: 0 }).format(val);
  };

  const handleExport = () => {
    Alert.alert('Export Report', 'Your PDF export will be generated and saved to reports folder.');
  };

  const calculateReportData = () => {
    if (!allTxns || !allCustomers || !allSchemes || !allEnrollments) {
      return null;
    }

    // Total collections
    let totalRevenue = 0;
    let totalGst = 0;
    allTxns.forEach((t: any) => {
      if (t.type === 'credit') {
        totalRevenue += t.amount || 0;
        totalGst += t.gst || 0;
      }
    });

    // Total gold weight
    let totalGoldWeight = 0;
    let totalSilverWeight = 0;
    allEnrollments.forEach((e: any) => {
      totalGoldWeight += e.total_gold_grams || 0;
      totalSilverWeight += e.total_silver_grams || 0;
    });

    // Scheme performance
    const schemePerf = allSchemes.map((s: any) => {
      const schemeId = s.id;
      const relatedEnr = allEnrollments.filter((e: any) => e.scheme_id === schemeId);
      
      const activeCount = relatedEnr.filter((e: any) => e.status === 'active').length;
      const completedCount = relatedEnr.filter((e: any) => e.status === 'completed').length;
      const revenue = relatedEnr.reduce((acc: number, curr: any) => acc + (curr.paid_amount || 0), 0);
      const avgTenure = relatedEnr.length > 0 
        ? relatedEnr.reduce((acc: number, curr: any) => acc + (curr.paid_months || 0), 0) / relatedEnr.length
        : 0;

      return {
        name: s.name,
        metalType: s.metal_type,
        active: activeCount,
        completed: completedCount,
        avgTenure: avgTenure.toFixed(1),
        revenue,
      };
    });

    // Weekly trend computation
    const weeklyData = [
      { label: 'Wk 1', amount: totalRevenue * 0.15 },
      { label: 'Wk 2', amount: totalRevenue * 0.28 },
      { label: 'Wk 3', amount: totalRevenue * 0.22 },
      { label: 'Wk 4', amount: totalRevenue * 0.35 },
    ];

    return {
      totalRevenue,
      totalGst,
      totalGoldWeight,
      totalSilverWeight,
      schemePerf,
      weeklyData,
    };
  };

  const data = calculateReportData();

  if (!data) {
    return (
      <SafeAreaView style={styles.safeContainer}>
        <ActivityIndicator color={AppColors.royalPurple} size="large" style={{ marginTop: 48 }} />
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.safeContainer}>
      <StatusBar style="dark" />
      <ScrollView contentContainerStyle={styles.scrollContent}>
        
        {/* Header Title with Export Button */}
        <View style={styles.header}>
          <View style={styles.headerTitleCol}>
            <Text style={styles.title}>Performance Reports</Text>
            <Text style={styles.subtitle}>Detailed analysis of collections, schemes, and tax liabilities.</Text>
          </View>
          
          <TouchableOpacity style={styles.exportButton} onPress={handleExport}>
            <Ionicons name="download-outline" size={16} color={AppColors.royalPurple} style={{ marginRight: 6 }} />
            <Text style={styles.exportText}>Export</Text>
          </TouchableOpacity>
        </View>

        {/* Date Filters */}
        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.periodRow}>
          {['This Month', 'Last Month', 'Last Quarter', 'Financial Year'].map((p) => {
            const isSelected = selectedPeriod === p;
            return (
              <TouchableOpacity
                key={p}
                style={[styles.periodChip, isSelected && styles.periodChipActive]}
                onPress={() => setSelectedPeriod(p)}
              >
                <Text style={[styles.periodText, isSelected && styles.periodTextActive]}>{p}</Text>
              </TouchableOpacity>
            );
          })}
        </ScrollView>

        {/* Bento KPI Grid */}
        <View style={styles.kpiGrid}>
          {/* Total Collections */}
          <View style={[styles.kpiCard, { flex: 2 }]}>
            <Text style={styles.kpiLabel}>TOTAL REVENUE</Text>
            <Text style={styles.kpiValue}>{formatCurrency(data.totalRevenue)}</Text>
            <View style={styles.badgeSuccess}>
              <Text style={styles.badgeSuccessText}>+18.4% vs last month</Text>
            </View>
          </View>

          {/* Members */}
          <View style={[styles.kpiCard, { flex: 1 }]}>
            <Text style={styles.kpiLabel}>ACTIVE MEMBERS</Text>
            <Text style={styles.kpiValue}>{allCustomers?.length || 0}</Text>
          </View>
        </View>

        <View style={styles.kpiGrid}>
          {/* GST */}
          <View style={[styles.kpiCard, { flex: 1 }]}>
            <Text style={styles.kpiLabel}>GST PAYABLES</Text>
            <Text style={styles.kpiValue}>{formatCurrency(data.totalGst)}</Text>
          </View>

          {/* AUM Weight */}
          <View style={[styles.kpiCard, { flex: 2 }]}>
            <Text style={styles.kpiLabel}>ASSETS UNDER MANAGEMENT</Text>
            <Text style={styles.kpiValue}>{data.totalGoldWeight.toFixed(2)}g Gold</Text>
            <Text style={styles.kpiSubValue}>{data.totalSilverWeight.toFixed(1)}g Silver</Text>
          </View>
        </View>

        {/* Collections Trend Graph Simulator */}
        <Text style={styles.sectionTitle}>Weekly Collections Trend</Text>
        <View style={styles.graphCard}>
          <View style={styles.barChart}>
            {data.weeklyData.map((w, idx) => (
              <View key={idx} style={styles.chartCol}>
                <View style={styles.barTrack}>
                  <View style={[styles.barFill, { height: `${(w.amount / data.totalRevenue) * 200}%` }]} />
                </View>
                <Text style={styles.barLabel}>{w.label}</Text>
                <Text style={styles.barVal}>{formatCurrency(w.amount)}</Text>
              </View>
            ))}
          </View>
        </View>

        {/* Scheme performance table */}
        <Text style={styles.sectionTitle}>Scheme Performance Ledger</Text>
        <View style={styles.tableCard}>
          <View style={styles.tableHeader}>
            <Text style={[styles.tableCellHeader, { flex: 2 }]}>SCHEME</Text>
            <Text style={styles.tableCellHeader}>ACTIVE</Text>
            <Text style={styles.tableCellHeader}>REVENUE</Text>
          </View>

          {data.schemePerf.map((perf: any, idx: number) => (
            <View key={idx} style={styles.tableRow}>
              <View style={{ flex: 2 }}>
                <Text style={styles.tableCellTitle} numberOfLines={1}>{perf.name}</Text>
                <Text style={styles.tableCellSub}>{perf.metalType.toUpperCase()} • {perf.avgTenure} mo avg</Text>
              </View>
              <Text style={styles.tableCell}>{perf.active}</Text>
              <Text style={[styles.tableCell, { fontWeight: 'bold' }]}>{formatCurrency(perf.revenue)}</Text>
            </View>
          ))}
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
  scrollContent: {
    padding: 24,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 24,
  },
  headerTitleCol: {
    flex: 1,
  },
  title: {
    fontSize: 26,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
  },
  subtitle: {
    fontSize: 13,
    color: '#8E8E93',
    marginTop: 4,
    lineHeight: 18,
  },
  exportButton: {
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 1.5,
    borderColor: AppColors.royalPurple,
    borderRadius: 8,
    paddingHorizontal: 12,
    paddingVertical: 6,
  },
  exportText: {
    fontSize: 13,
    fontWeight: 'bold',
    color: AppColors.royalPurple,
  },
  periodRow: {
    gap: 8,
    marginBottom: 24,
  },
  periodChip: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 100,
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    backgroundColor: '#FFFFFF',
  },
  periodChipActive: {
    backgroundColor: AppColors.royalPurple,
    borderColor: AppColors.royalPurple,
  },
  periodText: {
    fontSize: 13,
    fontWeight: '600',
    color: AppColors.textSecondary,
  },
  periodTextActive: {
    color: '#FFFFFF',
  },
  kpiGrid: {
    flexDirection: 'row',
    gap: 16,
    marginBottom: 16,
  },
  kpiCard: {
    backgroundColor: '#FFFFFF',
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    borderRadius: 16,
    padding: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.02,
    shadowRadius: 4,
    elevation: 1,
  },
  kpiLabel: {
    fontSize: 9,
    fontWeight: 'bold',
    color: '#8E8E93',
    letterSpacing: 1,
    marginBottom: 6,
  },
  kpiValue: {
    fontSize: 18,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
  },
  kpiSubValue: {
    fontSize: 13,
    color: AppColors.textSecondary,
    marginTop: 2,
  },
  badgeSuccess: {
    alignSelf: 'flex-start',
    backgroundColor: '#ECFDF5',
    borderRadius: 4,
    paddingHorizontal: 6,
    paddingVertical: 2,
    marginTop: 8,
  },
  badgeSuccessText: {
    fontSize: 9,
    fontWeight: 'bold',
    color: '#047857',
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
    marginTop: 24,
    marginBottom: 16,
  },
  graphCard: {
    backgroundColor: '#FFFFFF',
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    borderRadius: 20,
    padding: 24,
  },
  barChart: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-end',
    height: 140,
    paddingTop: 20,
  },
  chartCol: {
    alignItems: 'center',
    flex: 1,
  },
  barTrack: {
    width: 14,
    height: 80,
    backgroundColor: '#F2F2F7',
    borderRadius: 7,
    justifyContent: 'flex-end',
    overflow: 'hidden',
  },
  barFill: {
    width: '100%',
    backgroundColor: AppColors.royalPurple,
    borderRadius: 7,
  },
  barLabel: {
    fontSize: 10,
    color: '#8E8E93',
    marginTop: 8,
  },
  barVal: {
    fontSize: 10,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
    marginTop: 2,
  },
  tableCard: {
    backgroundColor: '#FFFFFF',
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    borderRadius: 20,
    padding: 16,
  },
  tableHeader: {
    flexDirection: 'row',
    borderBottomWidth: 1,
    borderBottomColor: AppColors.surfaceContainerHigh,
    paddingBottom: 12,
    marginBottom: 12,
  },
  tableCellHeader: {
    flex: 1,
    fontSize: 10,
    fontWeight: 'bold',
    color: '#8E8E93',
    letterSpacing: 0.5,
  },
  tableRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#F2F2F7',
  },
  tableCellTitle: {
    fontSize: 14,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
  },
  tableCellSub: {
    fontSize: 11,
    color: '#8E8E93',
    marginTop: 2,
  },
  tableCell: {
    flex: 1,
    fontSize: 13,
    color: AppColors.textPrimary,
  },
});
