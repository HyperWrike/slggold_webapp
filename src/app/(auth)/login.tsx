import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, TextInput, TouchableOpacity, ScrollView, SafeAreaView, ActivityIndicator } from 'react-native';
import { useRouter } from 'expo-router';
import { useAuth } from '../../context/AuthContext';
import { BiometricService } from '../../services/biometricService';
import { AppColors } from '../../constants/colors';
import { Ionicons } from '@expo/vector-icons';
import { StatusBar } from 'expo-status-bar';

export default function LoginScreen() {
  const router = useRouter();
  const { login, error, clearError, biometricSupported, biometricEnabled } = useAuth();

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [obscurePassword, setObscurePassword] = useState(true);
  const [isLoading, setIsLoading] = useState(false);
  const [validationError, setValidationError] = useState<string | null>(null);

  // Clear errors on unmount or email/pass change
  useEffect(() => {
    clearError();
    setValidationError(null);
  }, [email, password]);

  const handleLogin = async () => {
    if (!email.trim() || !password.trim()) {
      setValidationError('Please fill in all fields');
      return;
    }

    setIsLoading(true);
    setValidationError(null);

    const success = await login(email.trim(), password);
    setIsLoading(false);

    if (success) {
      router.replace('/(auth)/pin-entry');
    }
  };

  const handleBiometricLogin = async () => {
    const success = await BiometricService.authenticate();
    if (success) {
      router.replace('/(auth)/pin-entry');
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar style="dark" />
      <ScrollView contentContainerStyle={styles.scrollContent}>
        {/* Back Button */}
        <TouchableOpacity style={styles.backButton} onPress={() => router.replace('/customer-type')}>
          <Ionicons name="arrow-back" size={24} color={AppColors.textPrimary} />
        </TouchableOpacity>

        <View style={styles.header}>
          <Text style={styles.title}>Welcome Back</Text>
          <Text style={styles.subtitle}>Login to manage your gold portfolio</Text>
        </View>

        <View style={styles.form}>
          {/* Email/Username Input */}
          <View style={styles.inputGroup}>
            <Text style={styles.label}>Email or Username</Text>
            <View style={[styles.inputContainer, (validationError || error) && styles.inputErrorBorder]}>
              <Ionicons name="mail-outline" size={20} color={AppColors.goldPrimary} style={styles.inputIcon} />
              <TextInput
                style={styles.input}
                placeholder="Enter email or username"
                keyboardType="email-address"
                autoCapitalize="none"
                value={email}
                onChangeText={setEmail}
              />
            </View>
          </View>

          {/* Password Input */}
          <View style={styles.inputGroup}>
            <Text style={styles.label}>Password</Text>
            <View style={[styles.inputContainer, (validationError || error) && styles.inputErrorBorder]}>
              <Ionicons name="lock-closed-outline" size={20} color={AppColors.goldPrimary} style={styles.inputIcon} />
              <TextInput
                style={styles.input}
                placeholder="Enter password"
                secureTextEntry={obscurePassword}
                autoCapitalize="none"
                value={password}
                onChangeText={setPassword}
              />
              <TouchableOpacity onPress={() => setObscurePassword(!obscurePassword)}>
                <Ionicons name={obscurePassword ? "eye-off-outline" : "eye-outline"} size={20} color={AppColors.textSecondary} />
              </TouchableOpacity>
            </View>
          </View>

          {/* Forgot Password Link */}
          <TouchableOpacity style={styles.forgotPasswordButton}>
            <Text style={styles.forgotPasswordText}>Forgot Password?</Text>
          </TouchableOpacity>

          {(validationError || error) && (
            <Text style={styles.errorText}>{validationError || error}</Text>
          )}

          {/* Login Button */}
          <TouchableOpacity style={styles.loginButton} activeOpacity={0.9} onPress={handleLogin} disabled={isLoading}>
            {isLoading ? (
              <ActivityIndicator color={AppColors.textWhite} />
            ) : (
              <Text style={styles.loginButtonText}>LOGIN</Text>
            )}
          </TouchableOpacity>

          {/* Biometric Button */}
          {biometricSupported && biometricEnabled && (
            <TouchableOpacity style={styles.biometricButton} onPress={handleBiometricLogin}>
              <Ionicons name="finger-print" size={48} color={AppColors.goldPrimary} />
            </TouchableOpacity>
          )}

          {/* Register Redirect Link */}
          <View style={styles.footerRow}>
            <Text style={styles.footerText}>New to SLG Golds? </Text>
            <TouchableOpacity onPress={() => router.push('/customer-type')}>
              <Text style={styles.footerLink}>Register Now</Text>
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
  backButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 24,
  },
  header: {
    marginBottom: 48,
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
  forgotPasswordButton: {
    alignSelf: 'flex-end',
  },
  forgotPasswordText: {
    fontSize: 14,
    color: AppColors.goldDark,
    fontWeight: 'bold',
  },
  loginButton: {
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
  loginButtonText: {
    color: AppColors.textWhite,
    fontSize: 16,
    fontWeight: 'bold',
    letterSpacing: 1.5,
  },
  biometricButton: {
    alignSelf: 'center',
    marginTop: 16,
  },
  footerRow: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginTop: 24,
  },
  footerText: {
    fontSize: 14,
    color: AppColors.textSecondary,
  },
  footerLink: {
    fontSize: 14,
    fontWeight: 'bold',
    color: AppColors.goldDark,
    textDecorationLine: 'underline',
  },
});
