import React, { useEffect } from 'react';
import { Slot, useRouter, useSegments } from 'expo-router';
import * as SplashScreen from 'expo-splash-screen';
import { ConvexProvider } from 'convex/react';
import { convexClient } from '../services/convexClient';
import { AuthProvider, useAuth } from '../context/AuthContext';
import { NotificationService } from '../services/notificationService';
import { View, ActivityIndicator } from 'react-native';

// Keep the splash screen visible while we fetch resources
SplashScreen.preventAutoHideAsync().catch(() => {});

function RouteGatekeeper() {
  const { user, isLoading } = useAuth();
  const segments = useSegments();
  const router = useRouter();

  useEffect(() => {
    if (isLoading) return;

    // segments is an array of route path segments (e.g. ['(auth)', 'login'] or ['(main)', 'home'])
    const inAuthGroup = segments[0] === '(auth)';
    const inMainGroup = segments[0] === '(main)';
    const inAdminGroup = segments[0] === 'admin';
    const inOnboardingGroup = segments[0] === '(onboarding)';

    const isLoggedIn = user !== null;
    const role = user?.role;

    // Check path string
    const currentPath = '/' + segments.join('/');

    // If not logged in and trying to access protected screens, redirect to login
    if (!isLoggedIn) {
      // Allow onboarding screens, splash, login and pin-entry/setup
      const isPublicPath = inAuthGroup || inOnboardingGroup || currentPath === '/splash' || currentPath === '/convex-setup';
      if (!isPublicPath) {
        router.replace('/(auth)/login');
      }
    } else {
      // If logged in
      if (inAuthGroup || currentPath === '/splash') {
        // Redirect to dashboard or home
        if (role === 'admin' || role === 'manager') {
          router.replace('/admin/dashboard');
        } else {
          router.replace('/(main)/home');
        }
      } else if (inAdminGroup && role !== 'admin' && role !== 'manager') {
        // Prevent customers from accessing admin pages
        router.replace('/(main)/home');
      } else if (inMainGroup && (role === 'admin' || role === 'manager')) {
        // Redirect admin users from main tab group to admin dashboard
        router.replace('/admin/dashboard');
      }
    }
  }, [user, isLoading, segments]);

  if (isLoading) {
    return (
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#F8F9FA' }}>
        <ActivityIndicator size="large" color="#208AEF" />
      </View>
    );
  }

  return <Slot />;
}

export default function RootLayout() {
  useEffect(() => {
    // Hide splash screen on mount and init notifications
    const initApp = async () => {
      try {
        await NotificationService.initialize();
        await SplashScreen.hideAsync();
      } catch (e) {
        console.error('App init error:', e);
      }
    };
    initApp();
  }, []);

  return (
    <ConvexProvider client={convexClient}>
      <AuthProvider>
        <RouteGatekeeper />
      </AuthProvider>
    </ConvexProvider>
  );
}
