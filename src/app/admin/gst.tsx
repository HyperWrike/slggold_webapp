import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, ActivityIndicator, TextInput, Alert, SafeAreaView } from 'react-native';
import { useQuery, useMutation } from 'convex/react';
import { useAuth } from '../../context/AuthContext';
import { api } from '../../../convex/_generated/api';
import { AppColors } from '../../constants/colors';
import { Ionicons } from '@expo/vector-icons';
import { StatusBar } from 'expo-status-bar';

export default function AdminGstScreen() {
  const { sessionToken } = useAuth();

  // Queries
  const gstDetails = useQuery(api.gst.latest, sessionToken ? { sessionToken } : 'skip');

  // Mutations
  const saveGst = useMutation(api.gst.save);

  // Form State
  const [goldGst, setGoldGst] = useState('3.0');
  const [silverGst, setSilverGst] = useState('3.0');
  const [makingChargesGst, setMakingChargesGst] = useState('5.0');
  const [isSaving, setIsSaving] = useState(false);

  // Sync state when details load
  useEffect(() => {
    if (gstDetails) {
      setGoldGst(gstDetails.gold_gst?.toFixed(1) || '3.0');
      setSilverGst(gstDetails.silver_gst?.toFixed(1) || '3.0');
      setMakingChargesGst(gstDetails.making_charges_gst?.toFixed(1) || '5.0');
    }
  }, [gstDetails]);

  const handleSaveGst = async () => {
    const goldVal = parseFloat(goldGst);
    const silverVal = parseFloat(silverGst);
    const makingVal = parseFloat(makingChargesGst);

    if (isNaN(goldVal) || isNaN(silverVal) || isNaN(makingVal)) {
      Alert.alert('Error', 'GST rates must be valid numbers');
      return;
    }

    setIsSaving(true);
    try {
      if (sessionToken) {
        await saveGst({
          sessionToken,
          gold_gst: goldVal,
          silver_gst: silverVal,
          making_charges_gst: makingVal,
        });
        Alert.alert('Success', 'GST rates updated successfully');
      }
    } catch (e) {
      Alert.alert('Error', e instanceof Error ? e.message : 'Could not save GST rates');
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <SafeAreaView style={styles.safeContainer}>
      <StatusBar style="dark" />
      <ScrollView contentContainerStyle={styles.scrollContent}>
        
        {/* Intro Banner */}
        <View style={styles.banner}>
          <Ionicons name="calculator-outline" size={32} color={AppColors.royalPurple} />
          <Text style={styles.bannerText}>
            Configure GST rates for gold, silver, and making charges. Changes apply instantly to new investments.
          </Text>
        </View>

        {gstDetails === undefined ? (
          <ActivityIndicator color={AppColors.royalPurple} size="large" style={{ marginTop: 24 }} />
        ) : (
          <View style={styles.form}>
            {/* Gold GST */}
            <View style={styles.inputGroup}>
              <Text style={styles.label}>Gold GST (%)</Text>
              <View style={styles.inputContainer}>
                <TextInput
                  style={styles.input}
                  keyboardType="numeric"
                  value={goldGst}
                  onChangeText={setGoldGst}
                />
                <Text style={styles.suffixText}>%</Text>
              </View>
            </View>

            {/* Silver GST */}
            <View style={styles.inputGroup}>
              <Text style={styles.label}>Silver GST (%)</Text>
              <View style={styles.inputContainer}>
                <TextInput
                  style={styles.input}
                  keyboardType="numeric"
                  value={silverGst}
                  onChangeText={setSilverGst}
                />
                <Text style={styles.suffixText}>%</Text>
              </View>
            </View>

            {/* Making Charges GST */}
            <View style={styles.inputGroup}>
              <Text style={styles.label}>Making Charges GST (%)</Text>
              <View style={styles.inputContainer}>
                <TextInput
                  style={styles.input}
                  keyboardType="numeric"
                  value={makingChargesGst}
                  onChangeText={setMakingChargesGst}
                />
                <Text style={styles.suffixText}>%</Text>
              </View>
            </View>

            {/* Save Button */}
            <TouchableOpacity 
              style={styles.saveButton} 
              activeOpacity={0.9} 
              onPress={handleSaveGst}
              disabled={isSaving}
            >
              {isSaving ? (
                <ActivityIndicator color="#FFFFFF" />
              ) : (
                <Text style={styles.saveButtonText}>SAVE GST RATES</Text>
              )}
            </TouchableOpacity>
          </View>
        )}

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
  banner: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 16,
    backgroundColor: '#FFFFFF',
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    borderRadius: 16,
    padding: 16,
    marginBottom: 32,
  },
  bannerText: {
    flex: 1,
    fontSize: 13,
    color: AppColors.textSecondary,
    lineHeight: 18,
  },
  form: {
    gap: 20,
  },
  inputGroup: {
    gap: 8,
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
    backgroundColor: '#FFFFFF',
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    borderRadius: 12,
    height: 56,
    paddingHorizontal: 16,
  },
  input: {
    flex: 1,
    fontSize: 16,
    color: AppColors.textPrimary,
    fontWeight: '600',
  },
  suffixText: {
    fontSize: 16,
    fontWeight: 'bold',
    color: AppColors.royalPurple,
  },
  saveButton: {
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
    marginTop: 24,
  },
  saveButtonText: {
    color: '#FFFFFF',
    fontSize: 15,
    fontWeight: 'bold',
    letterSpacing: 1,
  },
});
