import React, { useState } from 'react';
import { View, Text, StyleSheet, TextInput, TouchableOpacity, ScrollView, SafeAreaView } from 'react-native';
import { useRouter } from 'expo-router';
import { useRegistration } from './_layout';
import { AppColors } from '../../../constants/colors';
import { Ionicons } from '@expo/vector-icons';
import { StatusBar } from 'expo-status-bar';

export default function RegistrationStep3() {
  const router = useRouter();
  const { data, updateData } = useRegistration();

  const [nomineeName, setNomineeName] = useState(data.nomineeName);
  const [nomineeRelationship, setNomineeRelationship] = useState(data.nomineeRelationship);
  const [errors, setErrors] = useState<Record<string, string>>({});

  const relationships = ['Spouse', 'Child', 'Parent', 'Sibling', 'Other'];

  const validate = () => {
    const tempErrors: Record<string, string> = {};
    if (!nomineeName.trim()) tempErrors.nomineeName = 'Nominee Full Name is required';
    if (!nomineeRelationship) tempErrors.nomineeRelationship = 'Select a relationship';

    setErrors(tempErrors);
    return Object.keys(tempErrors).length === 0;
  };

  const handleNext = () => {
    if (validate()) {
      updateData({
        nomineeName,
        nomineeRelationship,
      });
      router.push('/register/step4');
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar style="dark" />
      <ScrollView contentContainerStyle={styles.scrollContent}>
        {/* Step Indicator */}
        <View style={styles.indicatorContainer}>
          {[1, 2, 3, 4].map((step) => (
            <View
              key={step}
              style={[
                styles.indicatorBar,
                { backgroundColor: step <= 3 ? AppColors.goldPrimary : AppColors.surfaceContainerHigh },
              ]}
            />
          ))}
        </View>

        {/* Title */}
        <Text style={styles.title}>Secure your legacy</Text>
        <Text style={styles.subtitle}>Step 3 of 4: Add a nominee for your savings</Text>

        {/* Form Fields */}
        <View style={styles.form}>
          {/* Nominee Full Name */}
          <View style={styles.inputGroup}>
            <Text style={styles.label}>Nominee Full Name</Text>
            <View style={[styles.inputContainer, errors.nomineeName && styles.inputErrorBorder]}>
              <Ionicons name="person-outline" size={20} color={AppColors.goldPrimary} style={styles.inputIcon} />
              <TextInput
                style={styles.input}
                placeholder="Enter nominee full name"
                value={nomineeName}
                onChangeText={(text) => {
                  setNomineeName(text);
                  if (errors.nomineeName) setErrors((prev) => ({ ...prev, nomineeName: '' }));
                }}
              />
            </View>
            {errors.nomineeName && <Text style={styles.errorText}>{errors.nomineeName}</Text>}
          </View>

          {/* Relationship Selection */}
          <View style={styles.inputGroup}>
            <Text style={styles.label}>Relationship</Text>
            <View style={styles.chipGrid}>
              {relationships.map((rel) => {
                const isSelected = nomineeRelationship === rel;
                return (
                  <TouchableOpacity
                    key={rel}
                    style={[
                      styles.chip,
                      isSelected && styles.chipActive,
                    ]}
                    activeOpacity={0.8}
                    onPress={() => {
                      setNomineeRelationship(rel);
                      if (errors.nomineeRelationship) setErrors((prev) => ({ ...prev, nomineeRelationship: '' }));
                    }}
                  >
                    <Text
                      style={[
                        styles.chipText,
                        isSelected && styles.chipTextActive,
                      ]}
                    >
                      {rel}
                    </Text>
                  </TouchableOpacity>
                );
              })}
            </View>
            {errors.nomineeRelationship && <Text style={styles.errorText}>{errors.nomineeRelationship}</Text>}
          </View>

          {/* Action Buttons */}
          <View style={styles.buttonRow}>
            <TouchableOpacity
              style={[styles.button, styles.backButton]}
              activeOpacity={0.8}
              onPress={() => router.back()}
            >
              <Text style={styles.backButtonText}>BACK</Text>
            </TouchableOpacity>

            <TouchableOpacity
              style={[styles.button, styles.nextButton]}
              activeOpacity={0.8}
              onPress={handleNext}
            >
              <Text style={styles.nextButtonText}>NEXT STEP</Text>
            </TouchableOpacity>
          </View>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F8F9FA',
  },
  scrollContent: {
    padding: 24,
    paddingTop: 16,
  },
  indicatorContainer: {
    flexDirection: 'row',
    marginBottom: 32,
  },
  indicatorBar: {
    flex: 1,
    height: 4,
    marginHorizontal: 4,
    borderRadius: 2,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    color: AppColors.textSecondary,
    marginBottom: 32,
  },
  form: {
    gap: 24,
  },
  inputGroup: {
    gap: 12,
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
  inputIcon: {
    marginRight: 12,
  },
  input: {
    flex: 1,
    fontSize: 16,
    color: AppColors.textPrimary,
  },
  inputErrorBorder: {
    borderColor: AppColors.error,
  },
  errorText: {
    color: AppColors.error,
    fontSize: 12,
  },
  chipGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 12,
  },
  chip: {
    paddingHorizontal: 20,
    paddingVertical: 12,
    borderRadius: 100,
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    backgroundColor: AppColors.surfaceContainerLowest,
  },
  chipActive: {
    borderColor: AppColors.goldPrimary,
    backgroundColor: 'rgba(245, 200, 66, 0.1)',
  },
  chipText: {
    fontSize: 15,
    fontWeight: '600',
    color: AppColors.textSecondary,
  },
  chipTextActive: {
    color: AppColors.goldDark,
  },
  buttonRow: {
    flexDirection: 'row',
    gap: 16,
    marginTop: 24,
  },
  button: {
    height: 56,
    borderRadius: 16,
    justifyContent: 'center',
    alignItems: 'center',
  },
  backButton: {
    flex: 1,
    borderWidth: 1.5,
    borderColor: AppColors.goldPrimary,
    backgroundColor: 'transparent',
  },
  backButtonText: {
    color: AppColors.goldDark,
    fontSize: 16,
    fontWeight: 'bold',
  },
  nextButton: {
    flex: 2,
    backgroundColor: AppColors.goldPrimary,
    shadowColor: AppColors.goldPrimary,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.2,
    shadowRadius: 8,
    elevation: 4,
  },
  nextButtonText: {
    color: AppColors.textWhite,
    fontSize: 16,
    fontWeight: 'bold',
    letterSpacing: 1,
  },
});
