import React, { useState } from 'react';
import { View, Text, StyleSheet, TextInput, TouchableOpacity, ScrollView, SafeAreaView, ActivityIndicator } from 'react-native';
import { useRouter } from 'expo-router';
import { useRegistration } from './_layout';
import { useAuth } from '../../../context/AuthContext';
import { AppColors } from '../../../constants/colors';
import { Ionicons } from '@expo/vector-icons';
import { StatusBar } from 'expo-status-bar';

export default function RegistrationStep4() {
  const router = useRouter();
  const { data, resetData } = useRegistration();
  const { register } = useAuth();

  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [pin, setPin] = useState('');
  const [confirmPin, setConfirmPin] = useState('');

  const [obscurePassword, setObscurePassword] = useState(true);
  const [obscureConfirmPassword, setObscureConfirmPassword] = useState(true);
  const [obscurePin, setObscurePin] = useState(true);
  const [obscureConfirmPin, setObscureConfirmPin] = useState(true);

  const [isLoading, setIsLoading] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [registerError, setRegisterError] = useState<string | null>(null);

  const validate = () => {
    const tempErrors: Record<string, string> = {};
    if (!username.trim()) {
      tempErrors.username = 'Username is required';
    } else if (username.trim().length < 4) {
      tempErrors.username = 'Must be at least 4 characters';
    }

    if (!password.trim()) {
      tempErrors.password = 'Password is required';
    } else if (password.length < 6) {
      tempErrors.password = 'Must be at least 6 characters';
    }

    if (password !== confirmPassword) {
      tempErrors.confirmPassword = 'Passwords do not match';
    }

    if (!pin.trim()) {
      tempErrors.pin = 'PIN is required';
    } else if (pin.length !== 4 && pin.length !== 6) {
      tempErrors.pin = 'PIN must be 4 or 6 digits';
    }

    if (pin !== confirmPin) {
      tempErrors.confirmPin = 'PINs do not match';
    }

    setErrors(tempErrors);
    return Object.keys(tempErrors).length === 0;
  };

  const handleRegister = async () => {
    if (validate()) {
      setIsLoading(true);
      setRegisterError(null);

      // Collect all form data
      const finalProfile = {
        email: data.email,
        password: password,
        full_name: data.fullName,
        username: username,
        phone: data.phone,
        aadhaar: data.aadhaar,
        dob: data.dob,
        gender: data.gender,
        father_name: data.fatherName,
        birth_place: data.birthPlace,
        address: data.address,
        nominee_name: data.nomineeName,
        nominee_relationship: data.nomineeRelationship,
      };

      try {
        const success = await register(finalProfile, pin);
        if (success) {
          resetData(); // reset multi-step form progress
          router.replace('/success');
        } else {
          setRegisterError('Registration failed. Try again.');
        }
      } catch (e) {
        setRegisterError(e instanceof Error ? e.message : 'An error occurred');
      } finally {
        setIsLoading(false);
      }
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
                { backgroundColor: AppColors.goldPrimary },
              ]}
            />
          ))}
        </View>

        {/* Title */}
        <Text style={styles.title}>Final Step</Text>
        <Text style={styles.subtitle}>Step 4 of 4: Account Setup</Text>

        {/* Form Fields */}
        <View style={styles.form}>
          {/* Username */}
          <View style={styles.inputGroup}>
            <Text style={styles.label}>Username</Text>
            <View style={[styles.inputContainer, errors.username && styles.inputErrorBorder]}>
              <Ionicons name="person-outline" size={20} color={AppColors.goldPrimary} style={styles.inputIcon} />
              <TextInput
                style={styles.input}
                placeholder="Choose a unique username"
                autoCapitalize="none"
                value={username}
                onChangeText={(text) => {
                  setUsername(text.trim());
                  if (errors.username) setErrors((prev) => ({ ...prev, username: '' }));
                }}
              />
            </View>
            {errors.username && <Text style={styles.errorText}>{errors.username}</Text>}
          </View>

          {/* Password */}
          <View style={styles.inputGroup}>
            <Text style={styles.label}>Password</Text>
            <View style={[styles.inputContainer, errors.password && styles.inputErrorBorder]}>
              <Ionicons name="lock-closed-outline" size={20} color={AppColors.goldPrimary} style={styles.inputIcon} />
              <TextInput
                style={styles.input}
                placeholder="Create a password"
                secureTextEntry={obscurePassword}
                autoCapitalize="none"
                value={password}
                onChangeText={(text) => {
                  setPassword(text);
                  if (errors.password) setErrors((prev) => ({ ...prev, password: '' }));
                }}
              />
              <TouchableOpacity onPress={() => setObscurePassword(!obscurePassword)}>
                <Ionicons name={obscurePassword ? "eye-off-outline" : "eye-outline"} size={20} color={AppColors.textSecondary} />
              </TouchableOpacity>
            </View>
            {errors.password && <Text style={styles.errorText}>{errors.password}</Text>}
          </View>

          {/* Confirm Password */}
          <View style={styles.inputGroup}>
            <Text style={styles.label}>Confirm Password</Text>
            <View style={[styles.inputContainer, errors.confirmPassword && styles.inputErrorBorder]}>
              <Ionicons name="lock-closed-outline" size={20} color={AppColors.goldPrimary} style={styles.inputIcon} />
              <TextInput
                style={styles.input}
                placeholder="Re-enter your password"
                secureTextEntry={obscureConfirmPassword}
                autoCapitalize="none"
                value={confirmPassword}
                onChangeText={(text) => {
                  setConfirmPassword(text);
                  if (errors.confirmPassword) setErrors((prev) => ({ ...prev, confirmPassword: '' }));
                }}
              />
              <TouchableOpacity onPress={() => setObscureConfirmPassword(!obscureConfirmPassword)}>
                <Ionicons name={obscureConfirmPassword ? "eye-off-outline" : "eye-outline"} size={20} color={AppColors.textSecondary} />
              </TouchableOpacity>
            </View>
            {errors.confirmPassword && <Text style={styles.errorText}>{errors.confirmPassword}</Text>}
          </View>

          {/* PIN */}
          <View style={styles.inputGroup}>
            <Text style={styles.label}>Create PIN</Text>
            <View style={[styles.inputContainer, errors.pin && styles.inputErrorBorder]}>
              <Ionicons name="keypad-outline" size={20} color={AppColors.goldPrimary} style={styles.inputIcon} />
              <TextInput
                style={styles.input}
                placeholder="4 or 6 digit PIN"
                secureTextEntry={obscurePin}
                keyboardType="numeric"
                maxLength={6}
                value={pin}
                onChangeText={(text) => {
                  setPin(text.replace(/\D/g, ''));
                  if (errors.pin) setErrors((prev) => ({ ...prev, pin: '' }));
                }}
              />
              <TouchableOpacity onPress={() => setObscurePin(!obscurePin)}>
                <Ionicons name={obscurePin ? "eye-off-outline" : "eye-outline"} size={20} color={AppColors.textSecondary} />
              </TouchableOpacity>
            </View>
            {errors.pin && <Text style={styles.errorText}>{errors.pin}</Text>}
          </View>

          {/* Confirm PIN */}
          <View style={styles.inputGroup}>
            <Text style={styles.label}>Confirm PIN</Text>
            <View style={[styles.inputContainer, errors.confirmPin && styles.inputErrorBorder]}>
              <Ionicons name="keypad-outline" size={20} color={AppColors.goldPrimary} style={styles.inputIcon} />
              <TextInput
                style={styles.input}
                placeholder="Re-enter your PIN"
                secureTextEntry={obscureConfirmPin}
                keyboardType="numeric"
                maxLength={6}
                value={confirmPin}
                onChangeText={(text) => {
                  setConfirmPin(text.replace(/\D/g, ''));
                  if (errors.confirmPin) setErrors((prev) => ({ ...prev, confirmPin: '' }));
                }}
              />
              <TouchableOpacity onPress={() => setObscureConfirmPin(!obscureConfirmPin)}>
                <Ionicons name={obscureConfirmPin ? "eye-off-outline" : "eye-outline"} size={20} color={AppColors.textSecondary} />
              </TouchableOpacity>
            </View>
            {errors.confirmPin && <Text style={styles.errorText}>{errors.confirmPin}</Text>}
          </View>

          {registerError && <Text style={styles.errorText}>{registerError}</Text>}

          {/* Action Buttons */}
          <View style={styles.buttonRow}>
            <TouchableOpacity
              style={[styles.button, styles.backButton]}
              activeOpacity={0.8}
              onPress={() => router.back()}
              disabled={isLoading}
            >
              <Text style={styles.backButtonText}>BACK</Text>
            </TouchableOpacity>

            <TouchableOpacity
              style={[styles.button, styles.nextButton]}
              activeOpacity={0.8}
              onPress={handleRegister}
              disabled={isLoading}
            >
              {isLoading ? (
                <ActivityIndicator color={AppColors.textWhite} />
              ) : (
                <Text style={styles.nextButtonText}>FINISH</Text>
              )}
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
    fontSize: 14,
    textAlign: 'center',
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
