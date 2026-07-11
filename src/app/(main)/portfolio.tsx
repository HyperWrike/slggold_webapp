import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, ActivityIndicator, Modal, TextInput, Alert, SafeAreaView } from 'react-native';
import { useQuery, useAction } from 'convex/react';
import { useAuth } from '../../context/AuthContext';
import { api } from '../../../convex/_generated/api';
import { AppColors } from '../../constants/colors';
import { Ionicons } from '@expo/vector-icons';
import { StatusBar } from 'expo-status-bar';

export default function PortfolioScreen() {
  const { sessionToken } = useAuth();
  
  // Queries
  const portfolio = useQuery(api.portfolio.summary, sessionToken ? { sessionToken } : 'skip');
  const enrollments = useQuery(api.enrollments.listForUserWithSchemes, sessionToken ? { sessionToken } : 'skip') as any;
  const metalPrices = useQuery(api.metalPrices.latest);

  // Actions
  const createOrder = useAction(api.payments.createOrder);
  const verifyPayment = useAction(api.payments.verifyPayment);

  // UI States
  const [expandedCardId, setExpandedCardId] = useState<string | null>(null);
  const [paymentModalVisible, setPaymentModalVisible] = useState(false);
  const [payingEnrollment, setPayingEnrollment] = useState<any>(null);
  const [isPaying, setIsPaying] = useState(false);
  const [paymentSuccess, setPaymentSuccess] = useState(false);

  const formatCurrency = (val: number) => {
    return '₹' + new Intl.NumberFormat('en-IN', { maximumFractionDigits: 0 }).format(val);
  };

  const toggleExpand = (id: string) => {
    setExpandedCardId(expandedCardId === id ? null : id);
  };

  const initiatePayment = (enrollment: any) => {
    setPayingEnrollment(enrollment);
    setPaymentSuccess(false);
    setPaymentModalVisible(true);
  };

  const handleSimulatePayment = async () => {
    if (!sessionToken || !payingEnrollment) return;
    
    setIsPaying(true);
    try {
      // 1. Create Order
      const order = await createOrder({
        sessionToken,
        enrollmentId: payingEnrollment.id as any,
        amount: payingEnrollment.monthly_amount,
      });

      // 2. Simulate payment confirmation
      const mockPayId = 'pay_mock_' + Math.random().toString(36).substring(2, 10);
      const mockSig = 'sig_mock_' + Math.random().toString(36).substring(2, 10);

      await verifyPayment({
        sessionToken,
        razorpayOrderId: order.orderId,
        razorpayPaymentId: mockPayId,
        razorpaySignature: mockSig,
      });

      setIsPaying(false);
      setPaymentSuccess(true);
      
      // Auto close after 2 seconds
      setTimeout(() => {
        setPaymentModalVisible(false);
        setPayingEnrollment(null);
        setPaymentSuccess(false);
      }, 2000);

    } catch (e) {
      setIsPaying(false);
      Alert.alert('Payment Error', e instanceof Error ? e.message : 'Could not process payment');
    }
  };

  // Calculations for Hero Summary
  const liveGoldPrice = metalPrices?.goldPricePerGram ?? 7850;
  const liveSilverPrice = metalPrices?.silverPricePerGram ?? 95;
  const totalGoldGrams = portfolio?.totalGoldGrams ?? 0;
  const totalSilverGrams = portfolio?.totalSilverGrams ?? 0;
  const totalInvested = portfolio?.totalValue ?? 0;
  const currentValuation = (totalGoldGrams * liveGoldPrice) + (totalSilverGrams * liveSilverPrice);
  const trendPercent = totalInvested > 0 ? ((currentValuation - totalInvested) / totalInvested) * 100 : 0;

  return (
    <SafeAreaView style={styles.safeContainer}>
      <StatusBar style="dark" />
      <ScrollView contentContainerStyle={styles.scrollContent}>
        
        {/* Glassmorphic Portfolio Hero Card */}
        <View style={styles.heroCard}>
          <Text style={styles.heroCategory}>TOTAL PORTFOLIO VALUE</Text>
          <Text style={styles.heroValue}>{formatCurrency(currentValuation)}</Text>
          
          <View style={styles.heroDivider} />
          
          <View style={styles.heroFooter}>
            <View style={styles.gramContainer}>
              <View style={[styles.dot, { backgroundColor: AppColors.goldPrimary }]} />
              <Text style={styles.gramText}>{totalGoldGrams.toFixed(3)}g Gold</Text>
              
              <View style={[styles.dot, { backgroundColor: '#C0C0C0', marginLeft: 16 }]} />
              <Text style={styles.gramText}>{totalSilverGrams.toFixed(1)}g Silver</Text>
            </View>

            <View style={styles.trendRow}>
              <Ionicons 
                name={trendPercent >= 0 ? "trending-up" : "trending-down"} 
                size={16} 
                color={trendPercent >= 0 ? AppColors.success : AppColors.error} 
              />
              <Text style={[styles.trendText, { color: trendPercent >= 0 ? AppColors.success : AppColors.error }]}>
                {trendPercent >= 0 ? '+' : ''}{trendPercent.toFixed(1)}%
              </Text>
            </View>
          </View>
        </View>

        {/* Section Title */}
        <Text style={styles.sectionTitle}>My Schemes</Text>

        {/* Active Schemes List */}
        <View style={styles.schemesContainer}>
          {enrollments ? (
            enrollments.length > 0 ? (
              enrollments.map((enr: any) => {
                const scheme = enr.schemes;
                const isGold = scheme?.metal_type !== 'silver';
                const isExpanded = expandedCardId === enr.id;
                const progressPercent = enr.tenure_months > 0 ? (enr.paid_months / enr.tenure_months) : 0;
                
                return (
                  <View key={enr.id} style={styles.enrCard}>
                    <TouchableOpacity 
                      style={styles.cardHeader} 
                      activeOpacity={0.8}
                      onPress={() => toggleExpand(enr.id)}
                    >
                      <View style={[styles.enrIconBox, { backgroundColor: isGold ? 'rgba(245, 200, 66, 0.15)' : 'rgba(192, 192, 192, 0.2)' }]}>
                        <Ionicons 
                          name={isGold ? "ribbon-outline" : "ellipse-outline"} 
                          size={24} 
                          color={isGold ? AppColors.goldDark : '#707070'} 
                        />
                      </View>

                      <View style={styles.cardHeaderInfo}>
                        <View style={styles.titleRow}>
                          <Text style={styles.schemeName} numberOfLines={1}>{scheme?.name || 'Savings Scheme'}</Text>
                          <View style={[styles.statusBadge, { backgroundColor: enr.status === 'active' ? 'rgba(22, 163, 74, 0.1)' : 'rgba(142, 142, 147, 0.15)' }]}>
                            <Text style={[styles.statusText, { color: enr.status === 'active' ? AppColors.success : '#8E8E93' }]}>
                              {enr.status?.toUpperCase() || 'ACTIVE'}
                            </Text>
                          </View>
                        </View>
                        <Text style={styles.schemeSummary}>
                          {formatCurrency(enr.monthly_amount)}/mo • {enr.paid_months} of {enr.tenure_months} months
                        </Text>
                      </View>

                      <Ionicons 
                        name={isExpanded ? "chevron-up" : "chevron-down"} 
                        size={20} 
                        color="#8E8E93" 
                        style={styles.expandIcon} 
                      />
                    </TouchableOpacity>

                    {/* Progress Bar */}
                    <View style={styles.progressContainer}>
                      <View style={styles.track}>
                        <View style={[styles.fill, { 
                          width: `${Math.min(progressPercent * 100, 100)}%`,
                          backgroundColor: isGold ? AppColors.goldPrimary : '#707070'
                        }]} />
                      </View>
                      <View style={styles.progressLabelRow}>
                        <Text style={styles.progressPercent}>{Math.round(progressPercent * 100)}% COMPLETED</Text>
                        <Text style={styles.progressRatio}>
                          {formatCurrency(enr.paid_amount)} / {formatCurrency(enr.monthly_amount * enr.tenure_months)}
                        </Text>
                      </View>
                    </View>

                    {/* Expanded details & Installment Actions */}
                    {isExpanded && (
                      <View style={styles.expandedContent}>
                        <View style={styles.detailsGrid}>
                          <View style={styles.detailItem}>
                            <Text style={styles.detailLabel}>ACCUMULATED</Text>
                            <Text style={styles.detailValue}>
                              {isGold ? `${enr.total_gold_grams.toFixed(3)}g Gold` : `${enr.total_silver_grams.toFixed(1)}g Silver`}
                            </Text>
                          </View>
                          <View style={styles.detailItem}>
                            <Text style={styles.detailLabel}>INVESTED</Text>
                            <Text style={styles.detailValue}>{formatCurrency(enr.paid_amount)}</Text>
                          </View>
                          <View style={styles.detailItem}>
                            <Text style={styles.detailLabel}>VALUATION</Text>
                            <Text style={styles.detailValue}>
                              {formatCurrency(isGold ? enr.total_gold_grams * liveGoldPrice : enr.total_silver_grams * liveSilverPrice)}
                            </Text>
                          </View>
                        </View>

                        {enr.status === 'active' && enr.paid_months < enr.tenure_months && (
                          <TouchableOpacity 
                            style={styles.payButton} 
                            activeOpacity={0.9}
                            onPress={() => initiatePayment(enr)}
                          >
                            <Ionicons name="card-outline" size={18} color="#FFFFFF" style={{ marginRight: 8 }} />
                            <Text style={styles.payButtonText}>PAY INSTALLMENT</Text>
                          </TouchableOpacity>
                        )}
                      </View>
                    )}
                  </View>
                );
              })
            ) : (
              <View style={styles.emptyCard}>
                <Ionicons name="wallet-outline" size={48} color="#C7C7CC" />
                <Text style={styles.emptyText}>No active schemes yet.</Text>
                <Text style={styles.emptySubtext}>Enroll in a scheme to start saving gold!</Text>
              </View>
            )
          ) : (
            <ActivityIndicator color={AppColors.goldPrimary} size="large" style={{ marginTop: 24 }} />
          )}
        </View>

        <View style={{ height: 100 }} />
      </ScrollView>

      {/* Simulated Payment Sheet Modal */}
      <Modal
        animationType="slide"
        transparent={true}
        visible={paymentModalVisible}
        onRequestClose={() => setPaymentModalVisible(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            
            {paymentSuccess ? (
              <View style={styles.successContainer}>
                <Ionicons name="checkmark-circle" size={80} color={AppColors.success} />
                <Text style={styles.successTitle}>Payment Successful!</Text>
                <Text style={styles.successText}>
                  Your installment of {payingEnrollment ? formatCurrency(payingEnrollment.monthly_amount) : ''} has been recorded.
                </Text>
              </View>
            ) : (
              <View style={styles.paymentSheet}>
                <View style={styles.modalHeader}>
                  <Text style={styles.modalTitle}>Checkout Installment</Text>
                  <TouchableOpacity onPress={() => setPaymentModalVisible(false)}>
                    <Ionicons name="close" size={24} color={AppColors.textPrimary} />
                  </TouchableOpacity>
                </View>

                {payingEnrollment && (
                  <View style={styles.paymentDetails}>
                    <Text style={styles.paymentLabel}>Scheme Name</Text>
                    <Text style={styles.paymentValue}>{payingEnrollment.schemes?.name}</Text>

                    <Text style={styles.paymentLabel}>Due Amount</Text>
                    <Text style={styles.paymentAmount}>{formatCurrency(payingEnrollment.monthly_amount)}</Text>

                    <View style={styles.demoIndicator}>
                      <Ionicons name="shield-checkmark" size={18} color={AppColors.goldDark} />
                      <Text style={styles.demoIndicatorText}>SLG Golds Secure Checkout Simulator</Text>
                    </View>

                    <TouchableOpacity 
                      style={styles.simulateButton} 
                      activeOpacity={0.9} 
                      onPress={handleSimulatePayment}
                      disabled={isPaying}
                    >
                      {isPaying ? (
                        <ActivityIndicator color="#FFFFFF" />
                      ) : (
                        <Text style={styles.simulateButtonText}>
                          SIMULATE SECURE PAYMENT
                        </Text>
                      )}
                    </TouchableOpacity>
                  </View>
                )}
              </View>
            )}
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
  scrollContent: {
    padding: 24,
  },
  heroCard: {
    borderRadius: 24,
    backgroundColor: '#FFFFFF',
    borderWidth: 1,
    borderColor: 'rgba(245, 200, 66, 0.25)',
    padding: 24,
    shadowColor: AppColors.goldPrimary,
    shadowOffset: { width: 0, height: 12 },
    shadowOpacity: 0.1,
    shadowRadius: 24,
    elevation: 4,
    marginBottom: 32,
  },
  heroCategory: {
    fontSize: 10,
    fontWeight: 'bold',
    color: AppColors.goldDark,
    letterSpacing: 1.5,
    marginBottom: 6,
  },
  heroValue: {
    fontSize: 32,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
    letterSpacing: -1,
  },
  heroDivider: {
    height: 1,
    backgroundColor: AppColors.surfaceContainerHigh,
    marginVertical: 18,
  },
  heroFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  gramContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  dot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    marginRight: 6,
  },
  gramText: {
    fontSize: 13,
    fontWeight: '600',
    color: AppColors.textSecondary,
  },
  trendRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  trendText: {
    fontSize: 14,
    fontWeight: 'bold',
  },
  sectionTitle: {
    fontSize: 22,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
    marginBottom: 20,
  },
  schemesContainer: {
    gap: 16,
  },
  enrCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 20,
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    padding: 16,
  },
  cardHeader: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  enrIconBox: {
    width: 48,
    height: 48,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
  },
  cardHeaderInfo: {
    flex: 1,
    marginLeft: 16,
  },
  titleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  schemeName: {
    fontSize: 15,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
    maxWidth: 150,
  },
  statusBadge: {
    borderRadius: 100,
    paddingHorizontal: 8,
    paddingVertical: 2,
  },
  statusText: {
    fontSize: 9,
    fontWeight: 'bold',
  },
  schemeSummary: {
    fontSize: 12,
    color: AppColors.textSecondary,
    marginTop: 2,
  },
  expandIcon: {
    marginLeft: 8,
  },
  progressContainer: {
    marginTop: 16,
  },
  track: {
    height: 6,
    borderRadius: 3,
    backgroundColor: AppColors.surfaceContainerHigh,
    overflow: 'hidden',
  },
  fill: {
    height: '100%',
  },
  progressLabelRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 6,
  },
  progressPercent: {
    fontSize: 9,
    fontWeight: 'bold',
    color: AppColors.textSecondary,
  },
  progressRatio: {
    fontSize: 10,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
  },
  expandedContent: {
    marginTop: 20,
    borderTopWidth: 1,
    borderTopColor: AppColors.surfaceContainerHigh,
    paddingTop: 16,
  },
  detailsGrid: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 20,
  },
  detailItem: {
    flex: 1,
  },
  detailLabel: {
    fontSize: 9,
    fontWeight: 'bold',
    color: '#8E8E93',
    marginBottom: 4,
  },
  detailValue: {
    fontSize: 13,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
  },
  payButton: {
    height: 48,
    borderRadius: 12,
    backgroundColor: AppColors.goldPrimary,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: AppColors.goldPrimary,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.15,
    shadowRadius: 6,
    elevation: 3,
  },
  payButtonText: {
    color: '#FFFFFF',
    fontSize: 14,
    fontWeight: 'bold',
  },
  emptyCard: {
    backgroundColor: '#FFFFFF',
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    borderRadius: 20,
    padding: 32,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
  },
  emptyText: {
    fontSize: 15,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
  },
  emptySubtext: {
    fontSize: 13,
    color: '#8E8E93',
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
    minHeight: 300,
  },
  paymentSheet: {
    padding: 24,
  },
  modalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 24,
  },
  modalTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
  },
  paymentDetails: {
    gap: 12,
  },
  paymentLabel: {
    fontSize: 12,
    fontWeight: 'bold',
    color: '#8E8E93',
    textTransform: 'uppercase',
  },
  paymentValue: {
    fontSize: 16,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
    marginBottom: 8,
  },
  paymentAmount: {
    fontSize: 32,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
    marginBottom: 16,
  },
  demoIndicator: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    backgroundColor: 'rgba(245, 200, 66, 0.1)',
    borderRadius: 8,
    padding: 12,
    marginBottom: 24,
  },
  demoIndicatorText: {
    fontSize: 13,
    fontWeight: '600',
    color: AppColors.goldDark,
  },
  simulateButton: {
    height: 56,
    borderRadius: 16,
    backgroundColor: AppColors.goldPrimary,
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: AppColors.goldPrimary,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.2,
    shadowRadius: 8,
    elevation: 4,
  },
  simulateButtonText: {
    color: '#FFFFFF',
    fontSize: 15,
    fontWeight: 'bold',
    letterSpacing: 0.5,
  },
  successContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    padding: 48,
    gap: 16,
  },
  successTitle: {
    fontSize: 22,
    fontWeight: 'bold',
    color: AppColors.success,
  },
  successText: {
    fontSize: 15,
    color: AppColors.textSecondary,
    textAlign: 'center',
    lineHeight: 20,
  },
});
