import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, ActivityIndicator, Modal, TextInput, Switch, Alert, SafeAreaView } from 'react-native';
import { useQuery, useMutation } from 'convex/react';
import { useAuth } from '../../context/AuthContext';
import { api } from '../../../convex/_generated/api';
import { AppColors } from '../../constants/colors';
import { Ionicons } from '@expo/vector-icons';
import { StatusBar } from 'expo-status-bar';

export default function AdminSchemesScreen() {
  const { sessionToken } = useAuth();
  
  // Queries
  const schemes = useQuery(api.schemes.listActive);

  // Mutations
  const createScheme = useMutation(api.schemes.create);
  const toggleStatus = useMutation(api.schemes.toggleStatus);
  const removeScheme = useMutation(api.schemes.remove);

  // Modal State
  const [createModalVisible, setCreateModalVisible] = useState(false);
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [metalType, setMetalType] = useState<'gold' | 'silver' | 'combo'>('gold');
  const [monthlyAmountStr, setMonthlyAmountStr] = useState('');
  const [minAmountStr, setMinAmountStr] = useState('');
  const [tenureMonthsStr, setTenureMonthsStr] = useState('');
  const [benefit, setBenefit] = useState('');
  const [isPopular, setIsPopular] = useState(false);
  const [isSaving, setIsSaving] = useState(false);

  const formatCurrency = (val: number) => {
    return '₹' + new Intl.NumberFormat('en-IN', { maximumFractionDigits: 0 }).format(val);
  };

  const handleCreateScheme = async () => {
    if (!name.trim() || !description.trim() || !monthlyAmountStr || !minAmountStr || !tenureMonthsStr) {
      Alert.alert('Error', 'Please fill in all required fields');
      return;
    }

    const monthlyAmount = parseFloat(monthlyAmountStr);
    const minAmount = parseFloat(minAmountStr);
    const tenureMonths = parseInt(tenureMonthsStr);

    if (isNaN(monthlyAmount) || isNaN(minAmount) || isNaN(tenureMonths)) {
      Alert.alert('Error', 'Amounts and tenure must be valid numbers');
      return;
    }

    setIsSaving(true);
    try {
      if (sessionToken) {
        await createScheme({
          sessionToken,
          name: name.trim(),
          description: description.trim(),
          metal_type: metalType,
          monthly_amount: monthlyAmount,
          min_amount: minAmount,
          tenure_months: tenureMonths,
          benefit: benefit.trim(),
          is_popular: isPopular,
        });

        setCreateModalVisible(false);
        resetForm();
        Alert.alert('Success', 'Scheme created successfully');
      }
    } catch (e) {
      Alert.alert('Error', e instanceof Error ? e.message : 'Could not create scheme');
    } finally {
      setIsSaving(false);
    }
  };

  const resetForm = () => {
    setName('');
    setDescription('');
    setMetalType('gold');
    setMonthlyAmountStr('');
    setMinAmountStr('');
    setTenureMonthsStr('');
    setBenefit('');
    setIsPopular(false);
  };

  const handleToggleActive = async (schemeId: string, currentStatus: boolean) => {
    try {
      if (sessionToken) {
        await toggleStatus({
          sessionToken,
          schemeId: schemeId as any,
          isActive: !currentStatus,
        });
      }
    } catch (e) {
      Alert.alert('Error', e instanceof Error ? e.message : 'Could not toggle scheme status');
    }
  };

  const handleDeleteScheme = (schemeId: string, schemeName: string) => {
    Alert.alert(
      'Delete Scheme',
      `Are you sure you want to delete "${schemeName}"? This cannot be undone.`,
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: async () => {
            try {
              if (sessionToken) {
                await removeScheme({
                  sessionToken,
                  schemeId: schemeId as any,
                });
                Alert.alert('Success', 'Scheme deleted successfully');
              }
            } catch (e) {
              Alert.alert('Cannot Delete', e instanceof Error ? e.message : 'Could not delete scheme');
            }
          }
        }
      ]
    );
  };

  return (
    <SafeAreaView style={styles.safeContainer}>
      <StatusBar style="dark" />
      
      {/* Header */}
      <View style={styles.header}>
        <View style={styles.headerContent}>
          <Text style={styles.headerTitle}>Manage Schemes</Text>
          <TouchableOpacity 
            style={styles.addButton} 
            onPress={() => setCreateModalVisible(true)}
            activeOpacity={0.8}
          >
            <Ionicons name="add" size={24} color="#FFFFFF" />
          </TouchableOpacity>
        </View>
      </View>

      <ScrollView contentContainerStyle={styles.scrollContent}>
        {schemes ? (
          schemes.length > 0 ? (
            schemes.map((scheme) => {
              const isGold = scheme.metal_type === 'gold';
              const isCombo = scheme.metal_type === 'combo';
              return (
                <View key={scheme._id} style={styles.schemeCard}>
                  <View style={[styles.schemeIconBox, { 
                    backgroundColor: isGold 
                      ? 'rgba(245, 200, 66, 0.15)' 
                      : isCombo 
                      ? 'rgba(74, 14, 143, 0.15)' 
                      : 'rgba(192, 192, 192, 0.2)' 
                  }]}>
                    <Ionicons 
                      name={isGold ? "ribbon-outline" : isCombo ? "sparkles-outline" : "ellipse-outline"} 
                      size={24} 
                      color={isGold ? AppColors.goldDark : isCombo ? AppColors.royalPurple : '#707070'} 
                    />
                  </View>

                  <View style={styles.schemeInfo}>
                    <View style={styles.titleRow}>
                      <Text style={styles.schemeName} numberOfLines={1}>{scheme.name}</Text>
                      {scheme.is_popular && (
                        <View style={styles.popularBadge}>
                          <Text style={styles.popularText}>POPULAR</Text>
                        </View>
                      )}
                    </View>
                    <Text style={styles.schemeDetail}>
                      {scheme.tenure_months} months • Min {formatCurrency(scheme.min_amount || 1000)}/mo
                    </Text>
                    {scheme.benefit ? (
                      <Text style={styles.schemeBenefit}>{scheme.benefit}</Text>
                    ) : null}
                  </View>

                  <View style={styles.actionsColumn}>
                    <Switch
                      value={scheme.is_active}
                      onValueChange={() => handleToggleActive(scheme._id, scheme.is_active)}
                      trackColor={{ true: 'rgba(74, 14, 143, 0.4)', false: '#E5E5EA' }}
                      thumbColor={scheme.is_active ? AppColors.royalPurple : '#FFFFFF'}
                    />
                    <TouchableOpacity 
                      style={styles.deleteButton} 
                      onPress={() => handleDeleteScheme(scheme._id, scheme.name)}
                    >
                      <Ionicons name="trash-outline" size={20} color="#EF4444" />
                    </TouchableOpacity>
                  </View>
                </View>
              );
            })
          ) : (
            <View style={styles.emptyContainer}>
              <Ionicons name="trophy-outline" size={64} color="#C7C7CC" />
              <Text style={styles.emptyTitle}>No Schemes Found</Text>
              <Text style={styles.emptySub}>Click the '+' icon to create your first savings scheme plan.</Text>
            </View>
          )
        ) : (
          <ActivityIndicator color={AppColors.royalPurple} size="large" style={{ marginTop: 48 }} />
        )}

        <View style={{ height: 100 }} />
      </ScrollView>

      {/* Creation Modal */}
      <Modal
        animationType="slide"
        transparent={true}
        visible={createModalVisible}
        onRequestClose={() => setCreateModalVisible(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>New Scheme Plan</Text>
              <TouchableOpacity onPress={() => setCreateModalVisible(false)}>
                <Ionicons name="close" size={24} color={AppColors.textPrimary} />
              </TouchableOpacity>
            </View>

            <ScrollView contentContainerStyle={styles.modalBody}>
              <Text style={styles.fieldLabel}>SCHEME NAME</Text>
              <TextInput
                style={styles.input}
                placeholder="e.g. Premium Gold Accumulator"
                value={name}
                onChangeText={setName}
              />

              <Text style={styles.fieldLabel}>DESCRIPTION</Text>
              <TextInput
                style={[styles.input, styles.textArea]}
                placeholder="Brief plan details"
                multiline
                numberOfLines={3}
                value={description}
                onChangeText={setDescription}
              />

              <Text style={styles.fieldLabel}>METAL CLASSIFICATION</Text>
              <View style={styles.chipRow}>
                {['gold', 'silver', 'combo'].map((type) => {
                  const isSelected = metalType === type;
                  return (
                    <TouchableOpacity
                      key={type}
                      style={[styles.chip, isSelected && styles.chipActive]}
                      onPress={() => setMetalType(type as any)}
                    >
                      <Text style={[styles.chipText, isSelected && styles.chipTextActive]}>
                        {type.toUpperCase()}
                      </Text>
                    </TouchableOpacity>
                  );
                })}
              </View>

              <View style={styles.formRow}>
                <View style={{ flex: 1 }}>
                  <Text style={styles.fieldLabel}>MONTHLY DUES (₹)</Text>
                  <TextInput
                    style={styles.input}
                    placeholder="5000"
                    keyboardType="numeric"
                    value={monthlyAmountStr}
                    onChangeText={setMonthlyAmountStr}
                  />
                </View>
                <View style={{ width: 16 }} />
                <View style={{ flex: 1 }}>
                  <Text style={styles.fieldLabel}>MIN. LIMIT (₹)</Text>
                  <TextInput
                    style={styles.input}
                    placeholder="1000"
                    keyboardType="numeric"
                    value={minAmountStr}
                    onChangeText={setMinAmountStr}
                  />
                </View>
              </View>

              <Text style={styles.fieldLabel}>TENURE DURATION (MONTHS)</Text>
              <TextInput
                style={styles.input}
                placeholder="11"
                keyboardType="numeric"
                value={tenureMonthsStr}
                onChangeText={setTenureMonthsStr}
              />

              <Text style={styles.fieldLabel}>BENEFIT LABEL (OPTIONAL)</Text>
              <TextInput
                style={styles.input}
                placeholder="e.g., SLG pays the 12th installment"
                value={benefit}
                onChangeText={setBenefit}
              />

              <View style={styles.popularRow}>
                <Text style={styles.popularLabel}>Mark as Popular Scheme</Text>
                <Switch
                  value={isPopular}
                  onValueChange={setIsPopular}
                  trackColor={{ true: 'rgba(74, 14, 143, 0.4)', false: '#E5E5EA' }}
                  thumbColor={isPopular ? AppColors.royalPurple : '#FFFFFF'}
                />
              </View>

              <TouchableOpacity 
                style={styles.submitButton} 
                onPress={handleCreateScheme}
                disabled={isSaving}
              >
                {isSaving ? (
                  <ActivityIndicator color="#FFFFFF" />
                ) : (
                  <Text style={styles.submitButtonText}>CREATE PLAN</Text>
                )}
              </TouchableOpacity>
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
  headerTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
  },
  addButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: AppColors.royalPurple,
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: AppColors.royalPurple,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.2,
    shadowRadius: 6,
    elevation: 3,
  },
  scrollContent: {
    padding: 24,
    gap: 16,
  },
  schemeCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FFFFFF',
    borderRadius: 20,
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    padding: 16,
  },
  schemeIconBox: {
    width: 48,
    height: 48,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
  },
  schemeInfo: {
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
    maxWidth: 130,
  },
  popularBadge: {
    backgroundColor: 'rgba(74, 14, 143, 0.1)',
    borderRadius: 4,
    paddingHorizontal: 6,
    paddingVertical: 2,
  },
  popularText: {
    fontSize: 8,
    fontWeight: 'bold',
    color: AppColors.royalPurple,
  },
  schemeDetail: {
    fontSize: 12,
    color: AppColors.textSecondary,
    marginTop: 2,
  },
  schemeBenefit: {
    fontSize: 11,
    color: AppColors.royalPurple,
    fontStyle: 'italic',
    marginTop: 4,
  },
  actionsColumn: {
    alignItems: 'center',
    gap: 12,
    marginLeft: 8,
  },
  deleteButton: {
    width: 32,
    height: 32,
    justifyContent: 'center',
    alignItems: 'center',
    borderRadius: 8,
    backgroundColor: 'rgba(239, 68, 68, 0.05)',
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
  emptySub: {
    fontSize: 13,
    color: '#8E8E93',
    textAlign: 'center',
    paddingHorizontal: 24,
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
    maxHeight: '90%',
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
    fontSize: 18,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
  },
  modalBody: {
    padding: 24,
    gap: 16,
  },
  fieldLabel: {
    fontSize: 10,
    fontWeight: 'bold',
    color: '#8E8E93',
    letterSpacing: 1,
  },
  input: {
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    borderRadius: 12,
    height: 52,
    paddingHorizontal: 16,
    fontSize: 15,
    color: AppColors.textPrimary,
    backgroundColor: AppColors.surfaceContainerLowest,
  },
  textArea: {
    height: 80,
    textAlignVertical: 'top',
    paddingVertical: 12,
  },
  chipRow: {
    flexDirection: 'row',
    gap: 12,
  },
  chip: {
    flex: 1,
    height: 44,
    borderRadius: 10,
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    backgroundColor: AppColors.surfaceContainerLowest,
    justifyContent: 'center',
    alignItems: 'center',
  },
  chipActive: {
    borderColor: AppColors.royalPurple,
    backgroundColor: 'rgba(74, 14, 143, 0.1)',
  },
  chipText: {
    fontSize: 13,
    fontWeight: 'bold',
    color: AppColors.textSecondary,
  },
  chipTextActive: {
    color: AppColors.royalPurple,
  },
  formRow: {
    flexDirection: 'row',
  },
  popularRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 8,
  },
  popularLabel: {
    fontSize: 14,
    fontWeight: '600',
    color: AppColors.textPrimary,
  },
  submitButton: {
    height: 56,
    borderRadius: 16,
    backgroundColor: AppColors.royalPurple,
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: AppColors.royalPurple,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.2,
    shadowRadius: 8,
    elevation: 4,
    marginTop: 12,
    marginBottom: 40,
  },
  submitButtonText: {
    color: '#FFFFFF',
    fontSize: 15,
    fontWeight: 'bold',
  },
});
