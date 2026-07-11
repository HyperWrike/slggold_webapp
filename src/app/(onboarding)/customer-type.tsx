import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, SafeAreaView } from 'react-native';
import { useRouter } from 'expo-router';
import { AppColors } from '../../constants/colors';
import { StatusBar } from 'expo-status-bar';

export default function CustomerTypeScreen() {
  const router = useRouter();

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar style="light" />
      <View style={styles.content}>
        {/* Header */}
        <View style={styles.header}>
          <View style={styles.logoContainer}>
            <View style={styles.logoInner}>
              <Text style={styles.logoIcon}>💎</Text>
            </View>
          </View>
          <Text style={styles.welcomeText}>Welcome to{"\n"}SLG Golds</Text>
          <Text style={styles.subtitleText}>Select your customer type to continue</Text>
        </View>

        {/* Spacer */}
        <View style={styles.spacer} />

        {/* Selection Cards */}
        <TouchableOpacity
          style={styles.card}
          activeOpacity={0.8}
          onPress={() => router.push('/register/step1')}
        >
          <View style={styles.iconContainer}>
            <Text style={styles.cardIcon}>👤</Text>
          </View>
          <View style={styles.cardTextContainer}>
            <Text style={styles.cardTitle}>New Customer</Text>
            <Text style={styles.cardSubtitle}>Join us and start your gold savings journey today.</Text>
          </View>
          <Text style={styles.arrowIcon}>➔</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.card}
          activeOpacity={0.8}
          onPress={() => router.push('/(auth)/login')}
        >
          <View style={styles.iconContainer}>
            <Text style={styles.cardIcon}>🔑</Text>
          </View>
          <View style={styles.cardTextContainer}>
            <Text style={styles.cardTitle}>Existing Customer</Text>
            <Text style={styles.cardSubtitle}>Login to access your portfolio and schemes.</Text>
          </View>
          <Text style={styles.arrowIcon}>➔</Text>
        </TouchableOpacity>

        <View style={{ height: 48 }} />
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: AppColors.deepPurple,
  },
  content: {
    flex: 1,
    paddingHorizontal: 24,
    justifyContent: 'space-between',
  },
  header: {
    alignItems: 'center',
    marginTop: 48,
  },
  logoContainer: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: AppColors.goldPrimary,
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: AppColors.goldPrimary,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 10,
    elevation: 5,
    marginBottom: 24,
  },
  logoInner: {
    width: 72,
    height: 72,
    borderRadius: 36,
    backgroundColor: AppColors.deepPurple,
    justifyContent: 'center',
    alignItems: 'center',
  },
  logoIcon: {
    fontSize: 32,
  },
  welcomeText: {
    fontSize: 28,
    fontWeight: 'bold',
    color: AppColors.goldPrimary,
    textAlign: 'center',
    lineHeight: 34,
    marginBottom: 12,
  },
  subtitleText: {
    fontSize: 16,
    color: 'rgba(255, 255, 255, 0.8)',
    textAlign: 'center',
  },
  spacer: {
    flex: 1,
  },
  card: {
    backgroundColor: 'rgba(255, 255, 255, 0.08)',
    borderRadius: 20,
    borderWidth: 1,
    borderColor: 'rgba(245, 200, 66, 0.2)',
    padding: 24,
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 20,
  },
  iconContainer: {
    width: 52,
    height: 52,
    borderRadius: 26,
    backgroundColor: 'rgba(245, 200, 66, 0.15)',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  cardIcon: {
    fontSize: 24,
  },
  cardTextContainer: {
    flex: 1,
  },
  cardTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: AppColors.goldPrimary,
    letterSpacing: 0.5,
    marginBottom: 4,
  },
  cardSubtitle: {
    fontSize: 14,
    color: 'rgba(255, 255, 255, 0.7)',
  },
  arrowIcon: {
    color: AppColors.goldPrimary,
    fontSize: 18,
    marginLeft: 8,
  },
});
