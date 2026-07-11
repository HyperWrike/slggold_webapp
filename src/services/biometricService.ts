import * as LocalAuthentication from 'expo-local-authentication';
import { Platform } from 'react-native';

export class BiometricService {
  static async isBiometricAvailable(): Promise<boolean> {
    if (Platform.OS === 'web') return false;
    try {
      const hasHardware = await LocalAuthentication.hasHardwareAsync();
      const isEnrolled = await LocalAuthentication.isEnrolledAsync();
      return hasHardware && isEnrolled;
    } catch (e) {
      console.error('Error checking biometric availability:', e);
      return false;
    }
  }

  static async authenticate(reason: string = 'Please authenticate to access SLG Golds'): Promise<boolean> {
    if (Platform.OS === 'web') return false;
    const isAvailable = await this.isBiometricAvailable();
    if (!isAvailable) return false;

    try {
      const result = await LocalAuthentication.authenticateAsync({
        promptMessage: reason,
        fallbackLabel: 'Enter PIN',
        disableDeviceFallback: false,
      });
      return result.success;
    } catch (e) {
      console.error('Error authenticating with biometrics:', e);
      return false;
    }
  }
}
