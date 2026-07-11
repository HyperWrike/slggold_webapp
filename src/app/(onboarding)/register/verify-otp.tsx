import React, { useState, useEffect, useRef } from 'react';
import { View, Text, StyleSheet, TextInput, TouchableOpacity, ScrollView, SafeAreaView, ActivityIndicator } from 'react-native';
import { useRouter, useLocalSearchParams } from 'expo-router';
import { useRegistration } from './_layout';
import { AppColors } from '../../../constants/colors';
import { OtpService } from '../../../services/otpService';
import { Ionicons } from '@expo/vector-icons';
import { StatusBar } from 'expo-status-bar';

export default function VerifyOtpScreen() {
  const router = useRouter();
  const { email } = useLocalSearchParams<{ email: string }>();
  const { data } = useRegistration();

  const [otpCode, setOtpCode] = useState<string[]>(Array(6).fill(''));
  const [generatedOtp, setGeneratedOtp] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [isResending, setIsResending] = useState(false);
  const [otpSent, setOtpSent] = useState(false);
  const [showOtpOnScreen, setShowOtpOnScreen] = useState(false);
  const [resendSeconds, setResendSeconds] = useState(30);
  const [error, setError] = useState<string | null>(null);

  const inputs = useRef<Array<TextInput | null>>([]);

  const targetEmail = email || data.email || '';

  // Mask email for display (e.g. te***@example.com)
  const getMaskedEmail = (e: string) => {
    const parts = e.split('@');
    if (parts.length !== 2) return e;
    const name = parts[0];
    const domain = parts[1];
    const maskedName = name.length > 2 
      ? name.substring(0, 2) + '*'.repeat(name.length - 2) 
      : name + '*';
    return `${maskedName}@${domain}`;
  };

  useEffect(() => {
    sendOtp();
  }, []);

  useEffect(() => {
    let timer: NodeJS.Timeout;
    if (otpSent && resendSeconds > 0) {
      timer = setTimeout(() => {
        setResendSeconds((prev) => prev - 1);
      }, 1000);
    }
    return () => clearTimeout(timer);
  }, [otpSent, resendSeconds]);

  const sendOtp = async () => {
    setError(null);
    setIsLoading(!otpSent); // only show full loading overlay on first send
    setShowOtpOnScreen(false);

    const otp = OtpService.generateOtp();
    setGeneratedOtp(otp);

    // Call email action
    const res = await OtpService.sendOtp(targetEmail, otp);
    setIsLoading(false);

    setOtpSent(true);
    setResendSeconds(30);

    if (res.success) {
      setError(null);
      if (res.mock) {
        setShowOtpOnScreen(true);
        setError('Dev mode: Showing mock OTP code for registration simulation.');
      }
    } else {
      // Email sending failed (common on local dev without configured API keys)
      // Display OTP on screen so developer/user can continue testing
      setShowOtpOnScreen(true);
      setError('Email could not be delivered. Showing code for demonstration.');
      console.log(`Demo OTP Code: ${otp}`);
    }
  };

  const handleVerify = async () => {
    const enteredOtp = otpCode.join('');

    if (enteredOtp.length !== 6) {
      setError('Please enter the complete 6-digit OTP');
      return;
    }

    if (!generatedOtp) {
      setError('Please request an OTP first');
      return;
    }

    setIsLoading(true);
    setError(null);

    // Simulating UX verification delay
    setTimeout(() => {
      setIsLoading(false);
      const isValid = OtpService.verifyOtp(enteredOtp, generatedOtp);
      if (isValid) {
        // Verification success -> proceed to step 3
        router.push('/register/step3');
      } else {
        setError('Invalid OTP. Please check and try again.');
      }
    }, 500);
  };

  const handleResend = async () => {
    if (resendSeconds > 0 || isResending) return;
    setIsResending(true);
    setOtpCode(Array(6).fill(''));
    await sendOtp();
    setIsResending(false);
    inputs.current[0]?.focus();
  };

  const handleOtpChange = (text: string, index: number) => {
    const cleanText = text.replace(/[^0-9]/g, '');
    const newCode = [...otpCode];
    newCode[index] = cleanText;
    setOtpCode(newCode);

    // Auto focus next field
    if (cleanText !== '' && index < 5) {
      inputs.current[index + 1]?.focus();
    }
    // Auto focus previous field on delete
    if (cleanText === '' && index > 0) {
      inputs.current[index - 1]?.focus();
    }

    // Auto submit if all fields are filled
    if (index === 5 && cleanText !== '') {
      const allFilled = newCode.every((digit) => digit !== '');
      if (allFilled) {
        // Need to run inside a settimeout or state lifecycle to prevent batching conflicts
        setTimeout(() => {
          setIsLoading(true);
          const entered = newCode.join('');
          if (generatedOtp && OtpService.verifyOtp(entered, generatedOtp)) {
            setIsLoading(false);
            router.push('/register/step3');
          } else {
            setIsLoading(false);
            setError('Invalid OTP. Please check and try again.');
          }
        }, 300);
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
                { backgroundColor: step <= 2 ? AppColors.goldPrimary : AppColors.surfaceContainerHigh },
              ]}
            />
          ))}
        </View>

        {/* Header Icon */}
        <View style={styles.headerIconContainer}>
          <Ionicons name="mail-open-outline" size={64} color={AppColors.goldPrimary} />
        </View>

        {/* Title */}
        <Text style={styles.title}>Verify Your Email</Text>
        <Text style={styles.subtitle}>
          {otpSent 
            ? `We sent a 6-digit code to ${getMaskedEmail(targetEmail)}` 
            : `Sending OTP to ${targetEmail}...`}
        </Text>

        {/* Demo Mode / Error Banner */}
        {showOtpOnScreen && generatedOtp && (
          <View style={styles.demoBanner}>
            <Ionicons name="information-circle-outline" size={20} color="#E25C5C" />
            <View style={styles.demoTextContainer}>
              <Text style={styles.demoTitle}>Brevo email delivery failed</Text>
              <Text style={styles.demoText}>
                Use developer code: <Text style={styles.demoCode}>{generatedOtp}</Text>
              </Text>
            </View>
          </View>
        )}

        {/* Inputs */}
        <View style={styles.form}>
          {otpSent ? (
            <View style={styles.otpInputContainer}>
              {otpCode.map((digit, index) => (
                <TextInput
                  key={index}
                  ref={(ref) => { inputs.current[index] = ref; }}
                  style={[styles.otpBox, error && styles.otpBoxError]}
                  keyboardType="numeric"
                  maxLength={1}
                  value={digit}
                  onChangeText={(text) => handleOtpChange(text, index)}
                  onKeyPress={({ nativeEvent }) => {
                    // Handle backspace empty delete focus
                    if (nativeEvent.key === 'Backspace' && otpCode[index] === '' && index > 0) {
                      inputs.current[index - 1]?.focus();
                    }
                  }}
                />
              ))}
            </View>
          ) : (
            <ActivityIndicator size="large" color={AppColors.goldPrimary} style={{ marginVertical: 16 }} />
          )}

          {error && !showOtpOnScreen && <Text style={styles.errorText}>{error}</Text>}

          {otpSent && (
            <TouchableOpacity style={styles.button} activeOpacity={0.9} onPress={handleVerify} disabled={isLoading}>
              {isLoading ? (
                <ActivityIndicator color={AppColors.textWhite} />
              ) : (
                <Text style={styles.buttonText}>VERIFY & CONTINUE</Text>
              )}
            </TouchableOpacity>
          )}

          {/* Resend info */}
          {otpSent && (
            <View style={styles.resendContainer}>
              {resendSeconds > 0 ? (
                <Text style={styles.resendText}>Resend code in {resendSeconds}s</Text>
              ) : (
                <TouchableOpacity onPress={handleResend} disabled={isResending}>
                  <Text style={styles.resendLink}>
                    {isResending ? 'Resending...' : 'Resend OTP'}
                  </Text>
                </TouchableOpacity>
              )}
            </View>
          )}

          <TouchableOpacity style={styles.changeEmailButton} onPress={() => router.back()}>
            <Text style={styles.changeEmailText}>Change Email</Text>
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
    marginBottom: 48,
  },
  indicatorBar: {
    flex: 1,
    height: 4,
    marginHorizontal: 4,
    borderRadius: 2,
  },
  headerIconContainer: {
    alignItems: 'center',
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
    marginBottom: 32,
    lineHeight: 22,
  },
  demoBanner: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(226, 92, 92, 0.1)',
    borderWidth: 1,
    borderColor: 'rgba(226, 92, 92, 0.3)',
    borderRadius: 12,
    padding: 16,
    marginBottom: 32,
  },
  demoTextContainer: {
    marginLeft: 12,
    flex: 1,
  },
  demoTitle: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#D32F2F',
    marginBottom: 2,
  },
  demoText: {
    fontSize: 13,
    color: '#D32F2F',
  },
  demoCode: {
    fontWeight: 'bold',
    fontSize: 15,
    textDecorationLine: 'underline',
  },
  form: {
    gap: 24,
  },
  otpInputContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    flexWrap: 'nowrap',
    gap: 8,
  },
  otpBox: {
    flex: 1,
    height: 56,
    backgroundColor: AppColors.surfaceContainerLowest,
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    borderRadius: 12,
    fontSize: 22,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
    textAlign: 'center',
  },
  otpBoxError: {
    borderColor: AppColors.error,
  },
  errorText: {
    color: AppColors.error,
    fontSize: 14,
    textAlign: 'center',
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
  },
  buttonText: {
    color: AppColors.textWhite,
    fontSize: 16,
    fontWeight: 'bold',
    letterSpacing: 1,
  },
  resendContainer: {
    alignItems: 'center',
  },
  resendText: {
    fontSize: 14,
    color: AppColors.textSecondary,
  },
  resendLink: {
    fontSize: 15,
    fontWeight: 'bold',
    color: AppColors.goldDark,
  },
  changeEmailButton: {
    alignItems: 'center',
    marginTop: 8,
  },
  changeEmailText: {
    fontSize: 14,
    color: AppColors.textSecondary,
    textDecorationLine: 'underline',
  },
});
