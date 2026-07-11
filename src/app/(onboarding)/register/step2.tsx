import React, { useState } from 'react';
import { View, Text, StyleSheet, TextInput, TouchableOpacity, ScrollView, SafeAreaView } from 'react-native';
import { useRouter } from 'expo-router';
import { useRegistration } from './_layout';
import { AppColors } from '../../../constants/colors';
import { Ionicons } from '@expo/vector-icons';
import { StatusBar } from 'expo-status-bar';

export default function RegistrationStep2() {
  const router = useRouter();
  const { data, updateData } = useRegistration();

  const [address, setAddress] = useState(data.address);
  const [aadhaar, setAadhaar] = useState(data.aadhaar);
  const [email, setEmail] = useState(data.email);
  const [phone, setPhone] = useState(data.phone);
  const [errors, setErrors] = useState<Record<string, string>>({});

  const validate = () => {
    const tempErrors: Record<string, string> = {};
    if (!address.trim()) tempErrors.address = 'Residential Address is required';
    if (!aadhaar.trim()) {
      tempErrors.aadhaar = 'Aadhaar Number is required';
    } else if (aadhaar.trim().length !== 12) {
      tempErrors.aadhaar = 'Aadhaar must be exactly 12 digits';
    }
    if (!email.trim()) {
      tempErrors.email = 'Email Address is required';
    } else if (!/\S+@\S+\.\S+/.test(email)) {
      tempErrors.email = 'Enter a valid email address';
    }
    if (!phone.trim()) {
      tempErrors.phone = 'Mobile Number is required';
    } else if (phone.trim().length !== 10) {
      tempErrors.phone = 'Phone number must be exactly 10 digits';
    }

    setErrors(tempErrors);
    return Object.keys(tempErrors).length === 0;
  };

  const handleNext = () => {
    if (validate()) {
      updateData({
        address,
        aadhaar,
        email,
        phone,
      });
      router.push({
        pathname: '/register/verify-otp',
        params: { email },
      });
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
                { backgroundColor: step <= 2 ? AppColors.goldPrimary : AppColors.surfaceContainerHigh },
              ]}
            />
          ))}
        </View>

        {/* Title */}
        <Text style={styles.title}>How can we reach you?</Text>
        <Text style={styles.subtitle}>Step 2 of 4: Contact & ID</Text>

        {/* Form Fields */}
        <View style={styles.form}>
          {/* Residential Address */}
          <View style={styles.inputGroup}>
            <Text style={styles.label}>Residential Address</Text>
            <View style={[styles.inputContainer, styles.textAreaContainer, errors.address && styles.inputErrorBorder]}>
              <Ionicons name="home-outline" size={20} color={AppColors.goldPrimary} style={[styles.inputIcon, { marginTop: 16 }]} />
              <TextInput
                style={[styles.input, styles.textArea]}
                placeholder="Enter full address"
                multiline
                numberOfLines={3}
                value={address}
                onChangeText={(text) => {
                  setAddress(text);
                  if (errors.address) setErrors((prev) => ({ ...prev, address: '' }));
                }}
              />
            </View>
            {errors.address && <Text style={styles.errorText}>{errors.address}</Text>}
          </View>

          {/* Aadhaar Number */}
          <View style={styles.inputGroup}>
            <Text style={styles.label}>Aadhaar Number</Text>
            <View style={[styles.inputContainer, errors.aadhaar && styles.inputErrorBorder]}>
              <Ionicons name="card-outline" size={20} color={AppColors.goldPrimary} style={styles.inputIcon} />
              <TextInput
                style={styles.input}
                placeholder="12-digit Aadhaar Number"
                keyboardType="numeric"
                maxLength={12}
                value={aadhaar}
                onChangeText={(text) => {
                  setAadhaar(text.replace(/\D/g, ''));
                  if (errors.aadhaar) setErrors((prev) => ({ ...prev, aadhaar: '' }));
                }}
              />
            </View>
            {errors.aadhaar && <Text style={styles.errorText}>{errors.aadhaar}</Text>}
          </View>

          {/* Email Address */}
          <View style={styles.inputGroup}>
            <Text style={styles.label}>Email Address</Text>
            <View style={[styles.inputContainer, errors.email && styles.inputErrorBorder]}>
              <Ionicons name="mail-outline" size={20} color={AppColors.goldPrimary} style={styles.inputIcon} />
              <TextInput
                style={styles.input}
                placeholder="Enter email address"
                keyboardType="email-address"
                autoCapitalize="none"
                value={email}
                onChangeText={(text) => {
                  setEmail(text);
                  if (errors.email) setErrors((prev) => ({ ...prev, email: '' }));
                }}
              />
            </View>
            {errors.email && <Text style={styles.errorText}>{errors.email}</Text>}
          </View>

          {/* Mobile Number */}
          <View style={styles.inputGroup}>
            <Text style={styles.label}>Mobile Number</Text>
            <View style={[styles.inputContainer, errors.phone && styles.inputErrorBorder]}>
              <Text style={styles.prefixText}>+91</Text>
              <TextInput
                style={styles.input}
                placeholder="10-digit Mobile Number"
                keyboardType="phone-pad"
                maxLength={10}
                value={phone}
                onChangeText={(text) => {
                  setPhone(text.replace(/\D/g, ''));
                  if (errors.phone) setErrors((prev) => ({ ...prev, phone: '' }));
                }}
              />
            </View>
            {errors.phone && <Text style={styles.errorText}>{errors.phone}</Text>}
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
  textAreaContainer: {
    height: 100,
    alignItems: 'flex-start',
  },
  textArea: {
    height: '100%',
    textAlignVertical: 'top',
    paddingVertical: 14,
  },
  inputIcon: {
    marginRight: 12,
  },
  prefixText: {
    fontSize: 16,
    fontWeight: 'bold',
    color: AppColors.goldPrimary,
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
