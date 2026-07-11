import React, { useState } from 'react';
import { View, Text, StyleSheet, TextInput, TouchableOpacity, ScrollView, SafeAreaView } from 'react-native';
import { useRouter } from 'expo-router';
import { useRegistration } from './_layout';
import { AppColors } from '../../../constants/colors';
import { Ionicons } from '@expo/vector-icons';
import { StatusBar } from 'expo-status-bar';

export default function RegistrationStep1() {
  const router = useRouter();
  const { data, updateData } = useRegistration();

  const [fullName, setFullName] = useState(data.fullName);
  const [dob, setDob] = useState(data.dob);
  const [gender, setGender] = useState(data.gender);
  const [fatherName, setFatherName] = useState(data.fatherName);
  const [birthPlace, setBirthPlace] = useState(data.birthPlace);
  const [errors, setErrors] = useState<Record<string, string>>({});

  const validate = () => {
    const tempErrors: Record<string, string> = {};
    if (!fullName.trim()) tempErrors.fullName = 'Full Name is required';
    if (!dob.trim()) {
      tempErrors.dob = 'Date of Birth is required';
    } else if (!/^\d{4}-\d{2}-\d{2}$/.test(dob)) {
      tempErrors.dob = 'Use YYYY-MM-DD format';
    }
    if (!gender) tempErrors.gender = 'Gender is required';
    if (!fatherName.trim()) tempErrors.fatherName = 'Father/Husband name is required';
    if (!birthPlace.trim()) tempErrors.birthPlace = 'Place of birth is required';

    setErrors(tempErrors);
    return Object.keys(tempErrors).length === 0;
  };

  const handleNext = () => {
    if (validate()) {
      updateData({
        fullName,
        dob,
        gender,
        fatherName,
        birthPlace,
      });
      router.push('/register/step2');
    }
  };

  const calculateAge = (dobString: string) => {
    if (!/^\d{4}-\d{2}-\d{2}$/.test(dobString)) return '--';
    const birthDate = new Date(dobString);
    if (isNaN(birthDate.getTime())) return '--';
    const today = new Date();
    let age = today.getFullYear() - birthDate.getFullYear();
    const m = today.getMonth() - birthDate.getMonth();
    if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    return age >= 0 ? age : '--';
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
                { backgroundColor: step === 1 ? AppColors.goldPrimary : AppColors.surfaceContainerHigh },
              ]}
            />
          ))}
        </View>

        {/* Title */}
        <Text style={styles.title}>Let's get to know you</Text>
        <Text style={styles.subtitle}>Step 1 of 4: Personal Details</Text>

        {/* Form Fields */}
        <View style={styles.form}>
          {/* Full Name */}
          <View style={styles.inputGroup}>
            <Text style={styles.label}>Full Name</Text>
            <View style={[styles.inputContainer, errors.fullName && styles.inputErrorBorder]}>
              <Ionicons name="person-outline" size={20} color={AppColors.goldPrimary} style={styles.inputIcon} />
              <TextInput
                style={styles.input}
                placeholder="As per Aadhaar card"
                value={fullName}
                onChangeText={(text) => {
                  setFullName(text);
                  if (errors.fullName) setErrors((prev) => ({ ...prev, fullName: '' }));
                }}
              />
            </View>
            {errors.fullName && <Text style={styles.errorText}>{errors.fullName}</Text>}
          </View>

          {/* DOB and Age */}
          <View style={styles.row}>
            <View style={[styles.inputGroup, { flex: 2 }]}>
              <Text style={styles.label}>Date of Birth</Text>
              <View style={[styles.inputContainer, errors.dob && styles.inputErrorBorder]}>
                <Ionicons name="calendar-outline" size={20} color={AppColors.goldPrimary} style={styles.inputIcon} />
                <TextInput
                  style={styles.input}
                  placeholder="YYYY-MM-DD"
                  keyboardType="numeric"
                  maxLength={10}
                  value={dob}
                  onChangeText={(text) => {
                    // Auto dash formatting (e.g. YYYY-MM-DD)
                    let formatted = text.replace(/\D/g, '');
                    if (formatted.length > 4) {
                      formatted = formatted.substring(0, 4) + '-' + formatted.substring(4);
                    }
                    if (formatted.length > 7) {
                      formatted = formatted.substring(0, 7) + '-' + formatted.substring(7);
                    }
                    setDob(formatted.substring(0, 10));
                    if (errors.dob) setErrors((prev) => ({ ...prev, dob: '' }));
                  }}
                />
              </View>
              {errors.dob && <Text style={styles.errorText}>{errors.dob}</Text>}
            </View>

            <View style={[styles.inputGroup, { flex: 1, marginLeft: 16 }]}>
              <Text style={styles.label}>Age</Text>
              <View style={[styles.inputContainer, styles.disabledInput]}>
                <Ionicons name="gift-outline" size={20} color={AppColors.goldPrimary} style={styles.inputIcon} />
                <Text style={styles.disabledText}>{calculateAge(dob)}</Text>
              </View>
            </View>
          </View>

          {/* Gender */}
          <View style={styles.inputGroup}>
            <Text style={styles.label}>Gender</Text>
            <View style={styles.genderRow}>
              {['Male', 'Female', 'Other'].map((g) => {
                const isSelected = gender === g;
                return (
                  <TouchableOpacity
                    key={g}
                    style={[
                      styles.genderButton,
                      isSelected && styles.genderButtonActive,
                    ]}
                    activeOpacity={0.8}
                    onPress={() => {
                      setGender(g);
                      if (errors.gender) setErrors((prev) => ({ ...prev, gender: '' }));
                    }}
                  >
                    <Text
                      style={[
                        styles.genderText,
                        isSelected && styles.genderTextActive,
                      ]}
                    >
                      {g}
                    </Text>
                  </TouchableOpacity>
                );
              })}
            </View>
            {errors.gender && <Text style={styles.errorText}>{errors.gender}</Text>}
          </View>

          {/* Father's Name */}
          <View style={styles.inputGroup}>
            <Text style={styles.label}>Father's / Husband's Name</Text>
            <View style={[styles.inputContainer, errors.fatherName && styles.inputErrorBorder]}>
              <Ionicons name="people-outline" size={20} color={AppColors.goldPrimary} style={styles.inputIcon} />
              <TextInput
                style={styles.input}
                placeholder="Enter father or husband name"
                value={fatherName}
                onChangeText={(text) => {
                  setFatherName(text);
                  if (errors.fatherName) setErrors((prev) => ({ ...prev, fatherName: '' }));
                }}
              />
            </View>
            {errors.fatherName && <Text style={styles.errorText}>{errors.fatherName}</Text>}
          </View>

          {/* Place of Birth */}
          <View style={styles.inputGroup}>
            <Text style={styles.label}>Place of Birth</Text>
            <View style={[styles.inputContainer, errors.birthPlace && styles.inputErrorBorder]}>
              <Ionicons name="location-outline" size={20} color={AppColors.goldPrimary} style={styles.inputIcon} />
              <TextInput
                style={styles.input}
                placeholder="City / Town"
                value={birthPlace}
                onChangeText={(text) => {
                  setBirthPlace(text);
                  if (errors.birthPlace) setErrors((prev) => ({ ...prev, birthPlace: '' }));
                }}
              />
            </View>
            {errors.birthPlace && <Text style={styles.errorText}>{errors.birthPlace}</Text>}
          </View>

          {/* Next Button */}
          <TouchableOpacity style={styles.button} activeOpacity={0.9} onPress={handleNext}>
            <Text style={styles.buttonText}>NEXT STEP</Text>
          </TouchableOpacity>
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
  row: {
    flexDirection: 'row',
  },
  disabledInput: {
    backgroundColor: AppColors.surfaceContainerLow,
  },
  disabledText: {
    fontSize: 16,
    color: AppColors.textSecondary,
  },
  genderRow: {
    flexDirection: 'row',
    gap: 12,
  },
  genderButton: {
    flex: 1,
    height: 52,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    backgroundColor: AppColors.surfaceContainerLowest,
    justifyContent: 'center',
    alignItems: 'center',
  },
  genderButtonActive: {
    borderColor: AppColors.goldPrimary,
    backgroundColor: 'rgba(245, 200, 66, 0.1)',
  },
  genderText: {
    fontSize: 15,
    fontWeight: '600',
    color: AppColors.textSecondary,
  },
  genderTextActive: {
    color: AppColors.goldDark,
  },
  button: {
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
    marginTop: 24,
  },
  buttonText: {
    color: AppColors.textWhite,
    fontSize: 16,
    fontWeight: 'bold',
    letterSpacing: 1,
  },
});
