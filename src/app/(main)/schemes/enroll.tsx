import React, { useState } from 'react';
import { View, Text, StyleSheet, TextInput, TouchableOpacity, ScrollView, Modal, ActivityIndicator, Alert, SafeAreaView } from 'react-native';
import { useQuery, useMutation, useAction } from 'convex/react';
import { useAuth } from '../../../context/AuthContext';
import { api } from '../../../../convex/_generated/api';
import { AppColors } from '../../../constants/colors';
import { Ionicons } from '@expo/vector-icons';
import { useRouter, useLocalSearchParams } from 'expo-router';
import { StatusBar } from 'expo-status-bar';

export default function EnrollSchemeScreen() {
  const router = useRouter();
  const { schemeId } = useLocalSearchParams<{ schemeId: string }>();
  const { sessionToken } = useAuth();

  // Queries
  const scheme = useQuery(api.schemes.get, schemeId ? { id: schemeId as any } : 'skip');

  // Mutations/Actions
  const createEnrollment = useMutation(api.enrollments.create);
  const createOrder = useAction(api.payments.createOrder);
  const verifyPayment = useAction(api.payments.verifyPayment);

  // Form State
  const [amountStr, setAmountStr] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [paymentModalVisible, setPaymentModalVisible] = useState(false);
  const [paymentSuccess, setPaymentSuccess] = useState(false);
  const [orderData, setOrderData] = useState<any>(null);
  const [createdEnrollmentId, setCreatedEnrollmentId] = useState<string | null>(null);

  const monthlyAmount = parseFloat(amountStr) || 0;
  const minAmount = scheme?.min_amount || 1000;
  const tenure = scheme?.tenure_months || 11;

  const formatCurrency = (val: number) => {
    return '₹' + new Intl.NumberFormat('en-IN', { maximumFractionDigits: 0 }).format(val);
  };

  const handleEnroll = async () => {
    if (!sessionToken || !scheme) return;
    if (monthlyAmount < minAmount) {
      Alert.alert('Invalid Amount', `Minimum installment for this scheme is ${formatCurrency(minAmount)}`);
      return;
    }

    setIsLoading(true);
    try {
      // 1. Create the enrollment
      const res = await createEnrollment({
        sessionToken,
        schemeId: scheme._id,
        monthlyAmount,
        tenureMonths: tenure,
      });

      if (!res.ok || !res.id) {
        throw new Error('Could not create enrollment record');
      }

      const enrId = res.id;
      setCreatedEnrollmentId(enrId);

      // 2. Create payment order
      const order = await createOrder({
        sessionToken,
        enrollmentId: enrId as any,
        amount: monthlyAmount,
      });

      setOrderData(order);
      setIsLoading(false);
      setPaymentModalVisible(true);

    } catch (e) {
      setIsLoading(false);
      Alert.alert('Enrollment Error', e instanceof Error ? e.message : 'Something went wrong');
    }
  };

  const handleSimulatePayment = async () => {
    if (!sessionToken || !orderData || !createdEnrollmentId) return;

    setIsLoading(true);
    try {
      const mockPayId = 'pay_mock_' + Math.random().toString(36).substring(2, 10);
      const mockSig = 'sig_mock_' + Math.random().toString(36).substring(2, 10);

      // 3. Verify simulated payment
      await verifyPayment({
        sessionToken,
        razorpayOrderId: orderData.orderId,
        razorpayPaymentId: mockPayId,
        razorpaySignature: mockSig,
      });

      setIsLoading(false);
      setPaymentSuccess(true);

      // Auto close and go back to portfolio/schemes tab
      setTimeout(() => {
        setPaymentModalVisible(false);
        router.replace('/(main)/portfolio');
      }, 2000);

    } catch (e) {
      setIsLoading(false);
      Alert.alert('Payment Error', e instanceof Error ? e.message : 'Verification failed');
    }
  };

  if (!scheme) {
    return (
      <SafeAreaView style={styles.safeContainer}>
        <ActivityIndicator color={AppColors.goldPrimary} size="large" style={{ marginTop: 48 }} />
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.safeContainer}>
      <StatusBar style="dark" />
      <ScrollView contentContainerStyle={styles.scrollContent}>
        
        {/* Back header */}
        <TouchableOpacity style={styles.backButton} onPress={() => router.back()}>
          <Ionicons name="arrow-back" size={24} color={AppColors.textPrimary} />
          <Text style={styles.backText}>Enroll in Scheme</Text>
        </TouchableOpacity>

        <Text style={styles.schemeName}>{scheme.name}</Text>
        <Text style={styles.schemeMeta}>{scheme.tenure_months} Months Duration • {scheme.benefit || 'SLG pays the 13th month'}</Text>

        <View style={styles.form}>
          <Text style={styles.label}>Monthly Installment Amount (₹)</Text>
          <View style={styles.inputContainer}>
            <Text style={styles.currencyPrefix}>₹</Text>
            <TextInput
              style={styles.input}
              placeholder={`Min ${minAmount}`}
              keyboardType="numeric"
              value={amountStr}
              onChangeText={setAmountStr}
            />
          </View>
          <Text style={styles.helperText}>Minimum contribution amount is {formatCurrency(minAmount)}</Text>

          {/* Payment summary section */}
          <View style={styles.summaryCard}>
            <Text style={styles.summaryTitle}>Payment Summary</Text>
            
            <View style={styles.summaryRow}>
              <Text style={styles.summaryLabel}>You Pay ({scheme.tenure_months} Months)</Text>
              <Text style={styles.summaryVal}>{formatCurrency(monthlyAmount * tenure)}</Text>
            </View>

            <View style={styles.summaryRow}>
              <Text style={[styles.summaryLabel, { color: AppColors.goldDark }]}>Gold Bonus (13th Month)</Text>
              <Text style={[styles.summaryVal, { color: AppColors.goldDark, fontWeight: 'bold' }]}>
                + {formatCurrency(monthlyAmount)}
              </Text>
            </View>

            <View style={styles.summaryDivider} />

            <View style={styles.summaryRow}>
              <Text style={[styles.summaryLabel, { fontWeight: 'bold', color: AppColors.textPrimary }]}>
                Total Value Accumulated
              </Text>
              <Text style={[styles.summaryVal, { fontWeight: 'bold', color: AppColors.textPrimary, fontSize: 16 }]}>
                {formatCurrency(monthlyAmount * (tenure + 1))}
              </Text>
            </View>
          </View>

          {/* Action button */}
          <TouchableOpacity 
            style={[styles.payButton, monthlyAmount < minAmount && styles.payButtonDisabled]} 
            activeOpacity={0.9}
            onPress={handleEnroll}
            disabled={monthlyAmount < minAmount || isLoading}
          >
            {isLoading ? (
              <ActivityIndicator color="#FFFFFF" />
            ) : (
              <Text style={styles.payButtonText}>PROCEED TO PAY 1ST INSTALLMENT</Text>
            )}
          </TouchableOpacity>
        </View>
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
                <Text style={styles.successTitle}>Enrolled Successfully!</Text>
                <Text style={styles.successText}>
                  Your first installment of {formatCurrency(monthlyAmount)} is verified. Enrolled in {scheme.name}.
                </Text>
              </View>
            ) : (
              <View style={styles.paymentSheet}>
                <View style={styles.modalHeader}>
                  <Text style={styles.modalTitle}>Checkout Securely</Text>
                  <TouchableOpacity onPress={() => setPaymentModalVisible(false)}>
                    <Ionicons name="close" size={24} color={AppColors.textPrimary} />
                  </TouchableOpacity>
                </View>

                {orderData && (
                  <View style={styles.paymentDetails}>
                    <Text style={styles.paymentLabel}>Secure Order Reference</Text>
                    <Text style={styles.paymentValue}>{orderData.orderId}</Text>

                    <Text style={styles.paymentLabel}>Due Amount</Text>
                    <Text style={styles.paymentAmount}>{formatCurrency(monthlyAmount)}</Text>

                    <View style={styles.demoIndicator}>
                      <Ionicons name="shield-checkmark" size={18} color={AppColors.goldDark} />
                      <Text style={styles.demoIndicatorText}>Simulating Payment Gateway Checkout</Text>
                    </View>

                    <TouchableOpacity 
                      style={styles.simulateButton} 
                      activeOpacity={0.9} 
                      onPress={handleSimulatePayment}
                      disabled={isLoading}
                    >
                      {isLoading ? (
                        <ActivityIndicator color="#FFFFFF" />
                      ) : (
                        <Text style={styles.simulateButtonText}>
                          VERIFY & COMPLETE PAYMENT
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
  backButton: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 24,
    gap: 12,
  },
  backText: {
    fontSize: 16,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
  },
  schemeName: {
    fontSize: 26,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
    marginBottom: 6,
  },
  schemeMeta: {
    fontSize: 14,
    color: AppColors.textSecondary,
    marginBottom: 32,
  },
  form: {
    gap: 20,
  },
  label: {
    fontSize: 12,
    fontWeight: 'bold',
    color: AppColors.textSecondary,
    textTransform: 'uppercase',
  },
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: AppColors.surfaceContainerLowest,
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    borderRadius: 12,
    height: 56,
    paddingHorizontal: 16,
  },
  currencyPrefix: {
    fontSize: 18,
    fontWeight: 'bold',
    color: AppColors.goldPrimary,
    marginRight: 8,
  },
  input: {
    flex: 1,
    fontSize: 18,
    color: AppColors.textPrimary,
    fontWeight: '600',
  },
  helperText: {
    fontSize: 12,
    color: '#8E8E93',
  },
  summaryCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 20,
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    padding: 20,
    marginTop: 12,
  },
  summaryTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
    marginBottom: 16,
  },
  summaryRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginVertical: 6,
  },
  summaryLabel: {
    fontSize: 13,
    color: AppColors.textSecondary,
  },
  summaryVal: {
    fontSize: 14,
    color: AppColors.textPrimary,
  },
  summaryDivider: {
    height: 1,
    backgroundColor: AppColors.surfaceContainerHigh,
    marginVertical: 12,
  },
  payButton: {
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
    marginTop: 12,
  },
  payButtonDisabled: {
    backgroundColor: '#C7C7CC',
    shadowOpacity: 0,
    elevation: 0,
  },
  payButtonText: {
    color: '#FFFFFF',
    fontSize: 14,
    fontWeight: 'bold',
    letterSpacing: 0.5,
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
