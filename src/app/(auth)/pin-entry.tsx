import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, SafeAreaView, ActivityIndicator } from 'react-native';
import { useRouter } from 'expo-router';
import { useAuth } from '../../context/AuthContext';
import { BiometricService } from '../../services/biometricService';
import { AppColors } from '../../constants/colors';
import { Ionicons } from '@expo/vector-icons';
import { StatusBar } from 'expo-status-bar';

export default function PinEntryScreen() {
  const router = useRouter();
  const { user, verifyPin, logout, biometricSupported, biometricEnabled } = useAuth();

  const [pin, setPin] = useState('');
  const [isVerifying, setIsVerifying] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const pinLength = 4;

  useEffect(() => {
    if (!user) {
      router.replace('/(auth)/login');
    }
  }, [user]);

  // Handle auto biometric prompt on mount if enabled
  useEffect(() => {
    if (biometricSupported && biometricEnabled) {
      handleBiometricAuth();
    }
  }, [biometricSupported, biometricEnabled]);

  const handleDigitPress = (digit: string) => {
    if (pin.length < pinLength && !isVerifying) {
      const nextPin = pin + digit;
      setPin(nextPin);
      setError(null);

      if (nextPin.length === pinLength) {
        authenticate(nextPin);
      }
    }
  };

  const handleBackspace = () => {
    if (pin.length > 0 && !isVerifying) {
      setPin(pin.slice(0, -1));
    }
  };

  const authenticate = async (enteredPin: string) => {
    setIsVerifying(true);
    const ok = await verifyPin(enteredPin);
    setIsVerifying(false);

    if (ok) {
      if (user?.role === 'admin' || user?.role === 'manager') {
        router.replace('/admin/dashboard');
      } else {
        router.replace('/(main)/home');
      }
    } else {
      setPin('');
      setError('Incorrect PIN. Please try again.');
    }
  };

  const handleBiometricAuth = async () => {
    const success = await BiometricService.authenticate();
    if (success) {
      if (user?.role === 'admin' || user?.role === 'manager') {
        router.replace('/admin/dashboard');
      } else {
        router.replace('/(main)/home');
      }
    }
  };

  const handleLogout = async () => {
    await logout();
    router.replace('/(auth)/login');
  };

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar style="dark" />
      <View style={styles.content}>
        <View style={styles.spacer} />

        {/* Header */}
        <Ionicons name="lock-closed" size={48} color={AppColors.goldPrimary} style={styles.lockIcon} />
        <Text style={styles.title}>Enter your PIN</Text>
        <Text style={styles.subtitle}>
          {isVerifying ? 'Verifying PIN...' : 'To access your SLG Golds account'}
        </Text>

        <View style={{ height: 32 }} />

        {/* PIN Indicators */}
        <View style={styles.pinIndicatorContainer}>
          {Array(pinLength).fill(0).map((_, index) => {
            const filled = index < pin.length;
            return (
              <View
                key={index}
                style={[
                  styles.pinDot,
                  filled && styles.pinDotFilled,
                  error && styles.pinDotError
                ]}
              />
            );
          })}
        </View>

        {error && <Text style={styles.errorText}>{error}</Text>}

        <View style={styles.spacer} />

        {/* Password Option */}
        <TouchableOpacity style={styles.passwordOptionButton} onPress={handleLogout}>
          <Text style={styles.passwordOptionText}>Login with password instead</Text>
        </TouchableOpacity>

        {/* Custom Numpad */}
        <View style={styles.numpad}>
          {/* Row 1 */}
          <View style={styles.numpadRow}>
            {['1', '2', '3'].map((digit) => (
              <TouchableOpacity key={digit} style={styles.numpadButton} onPress={() => handleDigitPress(digit)}>
                <Text style={styles.numpadButtonText}>{digit}</Text>
              </TouchableOpacity>
            ))}
          </View>
          {/* Row 2 */}
          <View style={styles.numpadRow}>
            {['4', '5', '6'].map((digit) => (
              <TouchableOpacity key={digit} style={styles.numpadButton} onPress={() => handleDigitPress(digit)}>
                <Text style={styles.numpadButtonText}>{digit}</Text>
              </TouchableOpacity>
            ))}
          </View>
          {/* Row 3 */}
          <View style={styles.numpadRow}>
            {['7', '8', '9'].map((digit) => (
              <TouchableOpacity key={digit} style={styles.numpadButton} onPress={() => handleDigitPress(digit)}>
                <Text style={styles.numpadButtonText}>{digit}</Text>
              </TouchableOpacity>
            ))}
          </View>
          {/* Row 4 */}
          <View style={styles.numpadRow}>
            {/* Biometric Column */}
            {biometricSupported && biometricEnabled ? (
              <TouchableOpacity style={styles.numpadButton} onPress={handleBiometricAuth}>
                <Ionicons name="finger-print" size={28} color={AppColors.goldPrimary} />
              </TouchableOpacity>
            ) : (
              <View style={styles.numpadButton} />
            )}

            <TouchableOpacity style={styles.numpadButton} onPress={() => handleDigitPress('0')}>
              <Text style={styles.numpadButtonText}>0</Text>
            </TouchableOpacity>

            <TouchableOpacity style={styles.numpadButton} onPress={handleBackspace}>
              <Ionicons name="backspace-outline" size={28} color={AppColors.textPrimary} />
            </TouchableOpacity>
          </View>
        </View>

        <View style={{ height: 48 }} />
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F8F9FA',
  },
  content: {
    flex: 1,
    alignItems: 'center',
    paddingHorizontal: 32,
  },
  spacer: {
    flex: 1,
  },
  lockIcon: {
    marginBottom: 24,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
    textAlign: 'center',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    color: AppColors.textSecondary,
    textAlign: 'center',
  },
  pinIndicatorContainer: {
    flexDirection: 'row',
    gap: 20,
    justifyContent: 'center',
    marginVertical: 16,
  },
  pinDot: {
    width: 20,
    height: 20,
    borderRadius: 10,
    borderWidth: 2,
    borderColor: 'rgba(79, 70, 52, 0.2)',
    backgroundColor: 'transparent',
  },
  pinDotFilled: {
    backgroundColor: AppColors.goldDark,
    borderColor: AppColors.goldDark,
  },
  pinDotError: {
    borderColor: AppColors.error,
  },
  errorText: {
    color: AppColors.error,
    fontSize: 14,
    marginTop: 16,
    textAlign: 'center',
  },
  passwordOptionButton: {
    marginBottom: 32,
  },
  passwordOptionText: {
    color: AppColors.goldDark,
    fontSize: 16,
    fontWeight: 'bold',
  },
  numpad: {
    width: '100%',
    gap: 16,
  },
  numpadRow: {
    flexDirection: 'row',
    justifyContent: 'space-evenly',
  },
  numpadButton: {
    width: 72,
    height: 72,
    borderRadius: 36,
    backgroundColor: AppColors.surfaceContainerLowest,
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },
  numpadButtonText: {
    fontSize: 26,
    fontWeight: '600',
    color: AppColors.textPrimary,
  },
});
