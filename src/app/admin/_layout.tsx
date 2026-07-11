import React, { useEffect } from 'react';
import { Tabs, useRouter } from 'expo-router';
import { AppColors } from '../../constants/colors';
import { useAuth } from '../../context/AuthContext';
import { Ionicons } from '@expo/vector-icons';
import { Platform } from 'react-native';

export default function AdminLayout() {
  const { user } = useAuth();
  const router = useRouter();

  // Route protection inside admin layout as secondary defense
  useEffect(() => {
    if (user && user.role !== 'admin' && user.role !== 'manager') {
      router.replace('/(main)/home');
    }
  }, [user]);

  return (
    <Tabs
      screenOptions={{
        tabBarActiveTintColor: AppColors.royalPurple,
        tabBarInactiveTintColor: '#8E8E93',
        tabBarStyle: {
          backgroundColor: '#FFFFFF',
          borderTopWidth: 1,
          borderTopColor: AppColors.surfaceContainerHigh,
          height: Platform.OS === 'ios' ? 88 : 64,
          paddingBottom: Platform.OS === 'ios' ? 28 : 10,
          paddingTop: 10,
        },
        tabBarLabelStyle: {
          fontSize: 12,
          fontWeight: '600',
        },
        headerStyle: {
          backgroundColor: '#FFFFFF',
          shadowColor: '#000',
          shadowOffset: { width: 0, height: 1 },
          shadowOpacity: 0.05,
          shadowRadius: 2,
          elevation: 1,
        },
        headerTitleStyle: {
          fontWeight: 'bold',
          color: AppColors.textPrimary,
          fontSize: 18,
        },
        headerTintColor: AppColors.royalPurple,
      }}
    >
      <Tabs.Screen
        name="dashboard"
        options={{
          title: 'Admin Dashboard',
          tabBarLabel: 'Dashboard',
          tabBarIcon: ({ color, focused }) => (
            <Ionicons name={focused ? 'analytics' : 'analytics-outline'} size={24} color={color} />
          ),
        }}
      />
      <Tabs.Screen
        name="schemes"
        options={{
          title: 'Manage Schemes',
          tabBarLabel: 'Schemes',
          tabBarIcon: ({ color, focused }) => (
            <Ionicons name={focused ? 'trophy' : 'trophy-outline'} size={24} color={color} />
          ),
          headerShown: false,
        }}
      />
      <Tabs.Screen
        name="customers"
        options={{
          title: 'Customer Tracker',
          tabBarLabel: 'Customers',
          tabBarIcon: ({ color, focused }) => (
            <Ionicons name={focused ? 'people' : 'people-outline'} size={24} color={color} />
          ),
          headerShown: false,
        }}
      />
      <Tabs.Screen
        name="gst"
        options={{
          title: 'GST Settings',
          tabBarLabel: 'GST',
          tabBarIcon: ({ color, focused }) => (
            <Ionicons name={focused ? 'calculator' : 'calculator-outline'} size={24} color={color} />
          ),
        }}
      />
      <Tabs.Screen
        name="reports"
        options={{
          title: 'Reports & Analytics',
          tabBarLabel: 'Reports',
          tabBarIcon: ({ color, focused }) => (
            <Ionicons name={focused ? 'document-text' : 'document-text-outline'} size={24} color={color} />
          ),
        }}
      />
    </Tabs>
  );
}
