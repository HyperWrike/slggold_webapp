import * as SecureStore from 'expo-secure-store';
import { Platform } from 'react-native';

const IS_WEB = Platform.OS === 'web';

export class LocalStorageService {
  // Save value
  private static async setItem(key: string, value: string): Promise<void> {
    if (IS_WEB) {
      try {
        localStorage.setItem(key, value);
      } catch (e) {
        console.error('LocalStorage write failed:', e);
      }
      return;
    }
    try {
      await SecureStore.setItemAsync(key, value);
    } catch (e) {
      console.error(`SecureStore write failed for ${key}:`, e);
    }
  }

  // Get value
  private static async getItem(key: string): Promise<string | null> {
    if (IS_WEB) {
      try {
        return localStorage.getItem(key);
      } catch (e) {
        console.error('LocalStorage read failed:', e);
        return null;
      }
    }
    try {
      return await SecureStore.getItemAsync(key);
    } catch (e) {
      console.error(`SecureStore read failed for ${key}:`, e);
      return null;
    }
  }

  // Delete value
  private static async deleteItem(key: string): Promise<void> {
    if (IS_WEB) {
      try {
        localStorage.removeItem(key);
      } catch (e) {
        console.error('LocalStorage delete failed:', e);
      }
      return;
    }
    try {
      await SecureStore.deleteItemAsync(key);
    } catch (e) {
      console.error(`SecureStore delete failed for ${key}:`, e);
    }
  }

  // Auth Token helpers
  static async saveAuthToken(token: string): Promise<void> {
    await this.setItem('auth_token', token);
  }

  static async getAuthToken(): Promise<string | null> {
    return await this.getItem('auth_token');
  }

  static async deleteAuthToken(): Promise<void> {
    await this.deleteItem('auth_token');
  }

  // Biometric preferences helpers
  static async saveBiometricEnabled(enabled: boolean): Promise<void> {
    await this.setItem('biometric_enabled', String(enabled));
  }

  static async getBiometricEnabled(): Promise<boolean> {
    const val = await this.getItem('biometric_enabled');
    return val === 'true';
  }

  // Notification helpers
  static async saveLastSeenNotifId(id: string): Promise<void> {
    await this.setItem('last_seen_notif_id', id);
  }

  static async getLastSeenNotifId(): Promise<string | null> {
    return await this.getItem('last_seen_notif_id');
  }
}
