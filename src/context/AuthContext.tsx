import React, { createContext, useContext, useState, useEffect } from 'react';
import * as Crypto from 'expo-crypto';
import { LocalStorageService } from '../services/localStorage';
import { BiometricService } from '../services/biometricService';
import { convexClient } from '../services/convexClient';
import { api } from '../../convex/_generated/api';

export interface User {
  id: string;
  full_name: string;
  username?: string;
  email?: string;
  phone?: string;
  role: 'customer' | 'admin' | 'manager';
  is_verified?: boolean;
  hasPinSetup: boolean;
  pin_hash?: string;
}

interface AuthContextType {
  user: User | null;
  sessionToken: string | null;
  isLoading: boolean;
  error: string | null;
  biometricSupported: boolean;
  biometricEnabled: boolean;
  login: (email: string, password: string) => Promise<boolean>;
  register: (profileData: Record<string, any>, pin: string) => Promise<boolean>;
  logout: () => Promise<void>;
  verifyPin: (pin: string) => Promise<boolean>;
  enableBiometric: (enabled: boolean) => Promise<void>;
  clearError: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

const hashPin = async (pin: string): Promise<string> => {
  return await Crypto.digestStringAsync(
    Crypto.CryptoDigestAlgorithm.SHA256,
    pin
  );
};

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [sessionToken, setSessionToken] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const [biometricSupported, setBiometricSupported] = useState<boolean>(false);
  const [biometricEnabled, setBiometricEnabled] = useState<boolean>(false);

  // Initialize and check status
  useEffect(() => {
    const initializeAuth = async () => {
      try {
        // Check biometric availability
        const isBioAvailable = await BiometricService.isBiometricAvailable();
        setBiometricSupported(isBioAvailable);

        if (isBioAvailable) {
          const bioEnabled = await LocalStorageService.getBiometricEnabled();
          setBiometricEnabled(bioEnabled);
        }

        // Check if token exists and is valid
        const token = await LocalStorageService.getAuthToken();
        if (token) {
          setSessionToken(token);
          // Fetch current user from Convex
          const profile = await convexClient.query(api.auth.getCurrentUser, {
            sessionToken: token,
          });
          if (profile) {
            setUser({
              id: profile.id,
              full_name: profile.full_name,
              username: profile.username,
              email: profile.email,
              phone: profile.phone,
              role: profile.role as 'customer' | 'admin' | 'manager',
              is_verified: profile.is_verified,
              hasPinSetup: !!profile.pin_hash,
              pin_hash: profile.pin_hash,
            });
          } else {
            // Token expired or invalid, clear it
            await LocalStorageService.deleteAuthToken();
            setSessionToken(null);
          }
        }
      } catch (e) {
        console.error('Failed to initialize auth state:', e);
      } finally {
        setIsLoading(false);
      }
    };

    initializeAuth();
  }, []);

  const login = async (email: string, password: string): Promise<boolean> => {
    setIsLoading(true);
    setError(null);
    try {
      const res = await convexClient.action(api.authActions.login, {
        email,
        password,
      });

      if (res && res.token && res.profile) {
        await LocalStorageService.saveAuthToken(res.token);
        setSessionToken(res.token);
        const profile = res.profile as any;
        setUser({
          id: profile.id,
          full_name: profile.full_name,
          username: profile.username,
          email: profile.email,
          phone: profile.phone,
          role: profile.role,
          is_verified: profile.is_verified,
          hasPinSetup: !!profile.pin_hash,
          pin_hash: profile.pin_hash,
        });
        return true;
      }
      throw new Error('Invalid login response');
    } catch (e) {
      const errMsg = e instanceof Error ? e.message : String(e);
      setError(errMsg);
      return false;
    } finally {
      setIsLoading(false);
    }
  };

  const register = async (profileData: Record<string, any>, pin: string): Promise<boolean> => {
    setIsLoading(true);
    setError(null);
    try {
      const pin_hash = await hashPin(pin);
      const res = await convexClient.action(api.authActions.register, {
        email: profileData.email,
        password: profileData.password,
        full_name: profileData.full_name,
        username: profileData.username,
        phone: profileData.phone,
        aadhaar: profileData.aadhaar,
        dob: profileData.dob,
        gender: profileData.gender,
        father_name: profileData.father_name,
        birth_place: profileData.birth_place,
        address: profileData.address,
        nominee_name: profileData.nominee_name,
        nominee_relationship: profileData.nominee_relationship,
        pin_hash,
        pin_length: pin.length.toString(),
      });

      if (res && res.token && res.profile) {
        await LocalStorageService.saveAuthToken(res.token);
        setSessionToken(res.token);
        const profile = res.profile as any;
        setUser({
          id: profile.id,
          full_name: profile.full_name,
          username: profile.username,
          email: profile.email,
          phone: profile.phone,
          role: profile.role,
          is_verified: profile.is_verified,
          hasPinSetup: !!profile.pin_hash,
          pin_hash: profile.pin_hash,
        });
        return true;
      }
      throw new Error('Invalid registration response');
    } catch (e) {
      const errMsg = e instanceof Error ? e.message : String(e);
      setError(errMsg);
      return false;
    } finally {
      setIsLoading(false);
    }
  };

  const logout = async (): Promise<void> => {
    setIsLoading(true);
    try {
      const token = await LocalStorageService.getAuthToken();
      if (token) {
        await convexClient.mutation(api.auth.logout, { sessionToken: token });
      }
    } catch (e) {
      console.error('Error logging out from backend:', e);
    } finally {
      await LocalStorageService.deleteAuthToken();
      setSessionToken(null);
      setUser(null);
      setIsLoading(false);
    }
  };

  const verifyPin = async (pin: string): Promise<boolean> => {
    try {
      const pin_hash = await hashPin(pin);
      
      // If we already have the hash in memory, compare locally
      if (user && user.pin_hash) {
        return user.pin_hash === pin_hash;
      }

      // Fallback: fetch profile from backend
      const token = await LocalStorageService.getAuthToken();
      if (!token) return false;

      const profile = await convexClient.query(api.auth.getCurrentUser, {
        sessionToken: token,
      });
      if (profile && profile.pin_hash) {
        return profile.pin_hash === pin_hash;
      }
      return false;
    } catch (e) {
      console.error('PIN verification failed:', e);
      return false;
    }
  };

  const enableBiometric = async (enabled: boolean): Promise<void> => {
    try {
      await LocalStorageService.saveBiometricEnabled(enabled);
      setBiometricEnabled(enabled);
    } catch (e) {
      console.error('Error saving biometric preference:', e);
    }
  };

  const clearError = () => setError(null);

  return (
    <AuthContext.Provider
      value={{
        user,
        sessionToken,
        isLoading,
        error,
        biometricSupported,
        biometricEnabled,
        login,
        register,
        logout,
        verifyPin,
        enableBiometric,
        clearError,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};
