import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Switch, ActivityIndicator, Modal, TextInput, Alert, SafeAreaView } from 'react-native';
import { useQuery, useMutation } from 'convex/react';
import { useAuth } from '../../context/AuthContext';
import { api } from '../../../convex/_generated/api';
import { AppColors } from '../../constants/colors';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { StatusBar } from 'expo-status-bar';

export default function ProfileScreen() {
  const router = useRouter();
  const { user, logout, sessionToken, enableBiometric, biometricEnabled, biometricSupported } = useAuth();

  // Queries
  const profileDetails = useQuery(api.auth.getCurrentUser, sessionToken ? { sessionToken } : 'skip');

  // Mutations
  const updatePhone = useMutation(api.users.updatePhone);
  const changePasswordMutation = useMutation(api.users.changePassword);
  const changePinMutation = useMutation(api.users.changePin);

  // States
  const [notificationsEnabled, setNotificationsEnabled] = useState(true);
  const [supportModalVisible, setSupportModalVisible] = useState(false);
  
  // Phone Dialog State
  const [phoneModalVisible, setPhoneModalVisible] = useState(false);
  const [newPhone, setNewPhone] = useState('');
  const [isUpdatingPhone, setIsUpdatingPhone] = useState(false);

  // Password Dialog State
  const [passwordModalVisible, setPasswordModalVisible] = useState(false);
  const [oldPassword, setOldPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [isChangingPassword, setIsChangingPassword] = useState(false);

  // PIN Dialog State
  const [pinModalVisible, setPinModalVisible] = useState(false);
  const [newPin, setNewPin] = useState('');
  const [confirmPin, setConfirmPin] = useState('');
  const [isChangingPin, setIsChangingPin] = useState(false);

  const handleSignOut = async () => {
    Alert.alert(
      'Sign Out',
      'Are you sure you want to sign out?',
      [
        { text: 'Cancel', style: 'cancel' },
        { 
          text: 'Sign Out', 
          style: 'destructive',
          onPress: async () => {
            await logout();
            router.replace('/(auth)/login');
          }
        }
      ]
    );
  };

  const handleUpdatePhone = async () => {
    if (newPhone.trim().length !== 10) {
      Alert.alert('Invalid Number', 'Please enter a 10-digit mobile number');
      return;
    }
    setIsUpdatingPhone(true);
    try {
      if (sessionToken) {
        await updatePhone({ sessionToken, phone: newPhone.trim() });
        setPhoneModalVisible(false);
        setNewPhone('');
        Alert.alert('Success', 'Mobile number updated successfully');
      }
    } catch (e) {
      Alert.alert('Error', e instanceof Error ? e.message : 'Could not update phone number');
    } finally {
      setIsUpdatingPhone(false);
    }
  };

  const handleChangePassword = async () => {
    if (newPassword !== confirmPassword) {
      Alert.alert('Error', 'New passwords do not match');
      return;
    }
    if (newPassword.length < 6) {
      Alert.alert('Error', 'Password must be at least 6 characters');
      return;
    }
    setIsChangingPassword(true);
    try {
      if (sessionToken) {
        await changePasswordMutation({
          sessionToken,
          oldPassword,
          newPassword,
        });
        setPasswordModalVisible(false);
        setOldPassword('');
        setNewPassword('');
        setConfirmPassword('');
        Alert.alert('Success', 'Password changed successfully');
      }
    } catch (e) {
      Alert.alert('Error', e instanceof Error ? e.message : 'Could not change password');
    } finally {
      setIsChangingPassword(false);
    }
  };

  const handleChangePin = async () => {
    if (newPin !== confirmPin) {
      Alert.alert('Error', 'PINs do not match');
      return;
    }
    if (newPin.length !== 4 && newPin.length !== 6) {
      Alert.alert('Error', 'PIN must be 4 or 6 digits');
      return;
    }
    setIsChangingPin(true);
    try {
      if (sessionToken) {
        await changePinMutation({
          sessionToken,
          newPin,
        });
        setPinModalVisible(false);
        setNewPin('');
        setConfirmPin('');
        Alert.alert('Success', 'Security PIN changed successfully');
      }
    } catch (e) {
      Alert.alert('Error', e instanceof Error ? e.message : 'Could not change PIN');
    } finally {
      setIsChangingPin(false);
    }
  };

  const maskString = (str: string, keepFirst: number, keepLast: number) => {
    if (!str) return '--';
    if (str.length <= keepFirst + keepLast) return str;
    const maskedLength = str.length - keepFirst - keepLast;
    return str.substring(0, keepFirst) + 'X'.repeat(maskedLength) + str.substring(str.length - keepLast);
  };

  const formatDate = (dateStr?: string) => {
    if (!dateStr) return '--';
    const d = new Date(dateStr);
    if (isNaN(d.getTime())) return dateStr;
    return d.toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' });
  };

  const calculateAge = (dobString?: string) => {
    if (!dobString) return '';
    const birthDate = new Date(dobString);
    if (isNaN(birthDate.getTime())) return '';
    const today = new Date();
    let age = today.getFullYear() - birthDate.getFullYear();
    const m = today.getMonth() - birthDate.getMonth();
    if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    return `${age} yrs`;
  };

  if (!profileDetails) {
    return (
      <SafeAreaView style={styles.safeContainer}>
        <ActivityIndicator color={AppColors.goldPrimary} size="large" style={{ marginTop: 48 }} />
      </SafeAreaView>
    );
  }

  const memberYear = profileDetails.created_at ? new Date(profileDetails.created_at).getFullYear() : 2026;

  return (
    <SafeAreaView style={styles.safeContainer}>
      <StatusBar style="dark" />
      <ScrollView contentContainerStyle={styles.scrollContent}>
        
        {/* Profile Hero Section */}
        <View style={styles.heroContainer}>
          <View style={styles.avatarBorder}>
            <View style={styles.avatar}>
              <Text style={styles.avatarText}>
                {profileDetails.full_name ? profileDetails.full_name.charAt(0).toUpperCase() : 'U'}
              </Text>
            </View>
          </View>
          
          <Text style={styles.userName}>{profileDetails.full_name}</Text>
          <Text style={styles.userUsername}>@{profileDetails.username}</Text>
          
          <View style={styles.membershipRow}>
            <Text style={styles.membershipText}>Member since {memberYear}</Text>
            <View style={styles.verifiedBadge}>
              <Ionicons name="checkmark-circle" size={14} color="#047857" style={{ marginRight: 4 }} />
              <Text style={styles.verifiedText}>Verified</Text>
            </View>
          </View>
        </View>

        {/* Section: Personal Info */}
        <View style={styles.card}>
          <View style={styles.cardHeader}>
            <Ionicons name="person-outline" size={20} color={AppColors.goldPrimary} />
            <Text style={styles.cardTitle}>Personal Info</Text>
          </View>
          
          <View style={styles.infoRow}>
            <Text style={styles.infoLabel}>Full Name</Text>
            <Text style={styles.infoValue}>{profileDetails.full_name}</Text>
          </View>
          
          <View style={styles.infoRow}>
            <Text style={styles.infoLabel}>Date of Birth</Text>
            <Text style={styles.infoValue}>
              {formatDate(profileDetails.dob)} {calculateAge(profileDetails.dob) ? `(${calculateAge(profileDetails.dob)})` : ''}
            </Text>
          </View>
          
          <View style={styles.infoRow}>
            <Text style={styles.infoLabel}>Gender</Text>
            <Text style={styles.infoValue}>{profileDetails.gender || '--'}</Text>
          </View>

          <View style={styles.infoRow}>
            <Text style={styles.infoLabel}>Place of Birth</Text>
            <Text style={styles.infoValue}>{profileDetails.birth_place || '--'}</Text>
          </View>

          <View style={styles.infoRow}>
            <Text style={styles.infoLabel}>Father's/Husband's Name</Text>
            <Text style={styles.infoValue}>{profileDetails.father_name || '--'}</Text>
          </View>
        </View>

        {/* Section: Contact & Identity */}
        <View style={styles.card}>
          <View style={styles.cardHeader}>
            <Ionicons name="mail-outline" size={20} color={AppColors.goldPrimary} />
            <Text style={styles.cardTitle}>Contact & Identity</Text>
          </View>
          
          <View style={styles.infoRowWithAction}>
            <View>
              <Text style={styles.infoLabel}>Phone</Text>
              <Text style={styles.infoValue}>{maskString(profileDetails.phone || '', 2, 4)}</Text>
            </View>
            <TouchableOpacity style={styles.inlineAction} onPress={() => setPhoneModalVisible(true)}>
              <Text style={styles.inlineActionText}>CHANGE</Text>
            </TouchableOpacity>
          </View>

          <View style={styles.infoRow}>
            <Text style={styles.infoLabel}>Email</Text>
            <Text style={styles.infoValue}>{profileDetails.email}</Text>
          </View>

          <View style={styles.infoRow}>
            <Text style={styles.infoLabel}>Address</Text>
            <Text style={styles.infoValue}>{profileDetails.address || '--'}</Text>
          </View>

          <View style={styles.aadhaarBox}>
            <Ionicons name="card-outline" size={20} color={AppColors.textSecondary} />
            <View style={styles.aadhaarTextCol}>
              <Text style={styles.aadhaarLabel}>AADHAAR NUMBER</Text>
              <Text style={styles.aadhaarVal}>{maskString(profileDetails.aadhaar || '', 0, 4)} 🔒</Text>
            </View>
            <Ionicons name="shield-checkmark" size={20} color="#059669" />
          </View>
        </View>

        {/* Section: Nominee */}
        {profileDetails.nominee_name && (
          <View style={styles.card}>
            <View style={styles.cardHeader}>
              <Ionicons name="people-outline" size={20} color={AppColors.goldPrimary} />
              <Text style={styles.cardTitle}>Nominee</Text>
            </View>
            <View style={styles.nomineeDetails}>
              <Ionicons name="person-circle-outline" size={32} color={AppColors.goldPrimary} />
              <View>
                <Text style={styles.nomineeName}>{profileDetails.nominee_name}</Text>
                <Text style={styles.nomineeRel}>
                  {profileDetails.nominee_relationship} • 100% Share
                </Text>
              </View>
            </View>
          </View>
        )}

        {/* Section: Settings */}
        <Text style={styles.sectionHeader}>Settings</Text>
        <View style={styles.settingsCard}>
          {/* Change PIN */}
          <TouchableOpacity style={styles.settingItem} onPress={() => setPinModalVisible(true)}>
            <View style={styles.settingIconBox}>
              <Ionicons name="keypad-outline" size={20} color={AppColors.textSecondary} />
            </View>
            <Text style={styles.settingText}>Change PIN</Text>
            <Ionicons name="chevron-forward" size={18} color="#C7C7CC" />
          </TouchableOpacity>

          <View style={styles.settingDivider} />

          {/* Change Password */}
          <TouchableOpacity style={styles.settingItem} onPress={() => setPasswordModalVisible(true)}>
            <View style={styles.settingIconBox}>
              <Ionicons name="lock-closed-outline" size={20} color={AppColors.textSecondary} />
            </View>
            <Text style={styles.settingText}>Change Password</Text>
            <Ionicons name="chevron-forward" size={18} color="#C7C7CC" />
          </TouchableOpacity>

          <View style={styles.settingDivider} />

          {/* Biometric Toggle */}
          {biometricSupported && (
            <>
              <View style={styles.settingItem}>
                <View style={styles.settingIconBox}>
                  <Ionicons name="finger-print-outline" size={20} color={AppColors.textSecondary} />
                </View>
                <Text style={styles.settingText}>Biometric Login</Text>
                <Switch 
                  value={biometricEnabled} 
                  onValueChange={enableBiometric} 
                  trackColor={{ true: 'rgba(245, 200, 66, 0.4)', false: '#E5E5EA' }}
                  thumbColor={biometricEnabled ? AppColors.goldPrimary : '#FFFFFF'}
                />
              </View>
              <View style={styles.settingDivider} />
            </>
          )}

          {/* Notifications */}
          <View style={styles.settingItem}>
            <View style={styles.settingIconBox}>
              <Ionicons name="notifications-outline" size={20} color={AppColors.textSecondary} />
            </View>
            <Text style={styles.settingText}>Notifications</Text>
            <Switch 
              value={notificationsEnabled} 
              onValueChange={setNotificationsEnabled}
              trackColor={{ true: 'rgba(245, 200, 66, 0.4)', false: '#E5E5EA' }}
              thumbColor={notificationsEnabled ? AppColors.goldPrimary : '#FFFFFF'}
            />
          </View>

          <View style={styles.settingDivider} />

          {/* Support */}
          <TouchableOpacity style={styles.settingItem} onPress={() => setSupportModalVisible(true)}>
            <View style={styles.settingIconBox}>
              <Ionicons name="help-circle-outline" size={20} color={AppColors.textSecondary} />
            </View>
            <Text style={styles.settingText}>Support & FAQ</Text>
            <Ionicons name="chevron-forward" size={18} color="#C7C7CC" />
          </TouchableOpacity>
        </View>

        {/* Sign Out Button */}
        <TouchableOpacity style={styles.signOutButton} onPress={handleSignOut} activeOpacity={0.9}>
          <Ionicons name="log-out-outline" size={20} color="#EF4444" style={{ marginRight: 8 }} />
          <Text style={styles.signOutText}>SIGN OUT</Text>
        </TouchableOpacity>

        <View style={{ height: 120 }} />
      </ScrollView>

      {/* Phone Number Modal */}
      <Modal animationType="slide" transparent={true} visible={phoneModalVisible} onRequestClose={() => setPhoneModalVisible(false)}>
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>Change Phone Number</Text>
              <TouchableOpacity onPress={() => setPhoneModalVisible(false)}>
                <Ionicons name="close" size={24} color={AppColors.textPrimary} />
              </TouchableOpacity>
            </View>
            <View style={styles.modalBody}>
              <Text style={styles.dialogLabel}>NEW MOBILE NUMBER</Text>
              <View style={styles.dialogInputContainer}>
                <Text style={styles.phonePrefix}>+91</Text>
                <TextInput
                  style={styles.dialogInput}
                  placeholder="10-digit number"
                  keyboardType="numeric"
                  maxLength={10}
                  value={newPhone}
                  onChangeText={(t) => setNewPhone(t.replace(/\D/g, ''))}
                />
              </View>
              <TouchableOpacity style={styles.dialogButton} onPress={handleUpdatePhone} disabled={isUpdatingPhone}>
                {isUpdatingPhone ? <ActivityIndicator color="#FFFFFF" /> : <Text style={styles.dialogButtonText}>UPDATE PHONE</Text>}
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>

      {/* Security PIN Modal */}
      <Modal animationType="slide" transparent={true} visible={pinModalVisible} onRequestClose={() => setPinModalVisible(false)}>
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>Update Security PIN</Text>
              <TouchableOpacity onPress={() => setPinModalVisible(false)}>
                <Ionicons name="close" size={24} color={AppColors.textPrimary} />
              </TouchableOpacity>
            </View>
            <View style={styles.modalBody}>
              <Text style={styles.dialogLabel}>NEW PIN (4 or 6 DIGITS)</Text>
              <TextInput
                style={styles.dialogBorderInput}
                placeholder="Enter new PIN"
                keyboardType="numeric"
                secureTextEntry
                maxLength={6}
                value={newPin}
                onChangeText={(t) => setNewPin(t.replace(/\D/g, ''))}
              />
              
              <Text style={[styles.dialogLabel, { marginTop: 16 }]}>CONFIRM NEW PIN</Text>
              <TextInput
                style={styles.dialogBorderInput}
                placeholder="Re-enter new PIN"
                keyboardType="numeric"
                secureTextEntry
                maxLength={6}
                value={confirmPin}
                onChangeText={(t) => setConfirmPin(t.replace(/\D/g, ''))}
              />

              <TouchableOpacity style={styles.dialogButton} onPress={handleChangePin} disabled={isChangingPin}>
                {isChangingPin ? <ActivityIndicator color="#FFFFFF" /> : <Text style={styles.dialogButtonText}>UPDATE PIN</Text>}
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>

      {/* Password Modal */}
      <Modal animationType="slide" transparent={true} visible={passwordModalVisible} onRequestClose={() => setPasswordModalVisible(false)}>
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>Change Account Password</Text>
              <TouchableOpacity onPress={() => setPasswordModalVisible(false)}>
                <Ionicons name="close" size={24} color={AppColors.textPrimary} />
              </TouchableOpacity>
            </View>
            <ScrollView contentContainerStyle={styles.modalBody}>
              <Text style={styles.dialogLabel}>CURRENT PASSWORD</Text>
              <TextInput
                style={styles.dialogBorderInput}
                placeholder="Enter current password"
                secureTextEntry
                value={oldPassword}
                onChangeText={setOldPassword}
              />
              
              <Text style={[styles.dialogLabel, { marginTop: 16 }]}>NEW PASSWORD</Text>
              <TextInput
                style={styles.dialogBorderInput}
                placeholder="At least 6 characters"
                secureTextEntry
                value={newPassword}
                onChangeText={setNewPassword}
              />

              <Text style={[styles.dialogLabel, { marginTop: 16 }]}>CONFIRM NEW PASSWORD</Text>
              <TextInput
                style={styles.dialogBorderInput}
                placeholder="Confirm new password"
                secureTextEntry
                value={confirmPassword}
                onChangeText={setConfirmPassword}
              />

              <TouchableOpacity style={styles.dialogButton} onPress={handleChangePassword} disabled={isChangingPassword}>
                {isChangingPassword ? <ActivityIndicator color="#FFFFFF" /> : <Text style={styles.dialogButtonText}>UPDATE PASSWORD</Text>}
              </TouchableOpacity>
            </ScrollView>
          </View>
        </View>
      </Modal>

      {/* Support Dialog Modal */}
      <Modal animationType="slide" transparent={true} visible={supportModalVisible} onRequestClose={() => setSupportModalVisible(false)}>
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>Customer Support</Text>
              <TouchableOpacity onPress={() => setSupportModalVisible(false)}>
                <Ionicons name="close" size={24} color={AppColors.textPrimary} />
              </TouchableOpacity>
            </View>
            <View style={[styles.modalBody, { gap: 16, paddingBottom: 40 }]}>
              <Text style={styles.supportIntro}>
                Need assistance with your gold schemes or withdrawals? Reach our relationship managers:
              </Text>
              
              <TouchableOpacity style={styles.supportOption}>
                <Ionicons name="mail" size={20} color={AppColors.goldPrimary} />
                <Text style={styles.supportText}>support@slggolds.com</Text>
              </TouchableOpacity>

              <TouchableOpacity style={styles.supportOption}>
                <Ionicons name="call" size={20} color={AppColors.goldPrimary} />
                <Text style={styles.supportText}>+91 1800 200 4567 (Toll Free)</Text>
              </TouchableOpacity>

              <View style={styles.supportFaq}>
                <Text style={styles.faqTitle}>Frequently Asked Questions</Text>
                <Text style={styles.faqText}>• Bonus month details: SLG Golds offers a full 13th installment bonus on complete 12-month savings cycles.</Text>
                <Text style={styles.faqText}>• Gold purity: All accumulated gold credits are 24-Karat with certified assay standards.</Text>
              </View>
            </View>
          </View>
        </View>
      </Modal>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeContainer: {
    flex: 1,
    backgroundColor: '#F8F9FA',
  },
  scrollContent: {
    padding: 24,
  },
  heroContainer: {
    alignItems: 'center',
    paddingVertical: 32,
    backgroundColor: 'rgba(245, 200, 66, 0.05)',
    borderRadius: 24,
    borderWidth: 1,
    borderColor: 'rgba(245, 200, 66, 0.1)',
    marginBottom: 24,
  },
  avatarBorder: {
    width: 86,
    height: 86,
    borderRadius: 43,
    borderWidth: 2,
    borderColor: AppColors.goldPrimary,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 16,
  },
  avatar: {
    width: 76,
    height: 76,
    borderRadius: 38,
    backgroundColor: AppColors.surfaceContainerHigh,
    justifyContent: 'center',
    alignItems: 'center',
  },
  avatarText: {
    fontSize: 28,
    fontWeight: 'bold',
    color: AppColors.primary,
  },
  userName: {
    fontSize: 20,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
    marginBottom: 4,
  },
  userUsername: {
    fontSize: 14,
    color: AppColors.textSecondary,
    marginBottom: 12,
  },
  membershipRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  membershipText: {
    fontSize: 12,
    color: '#8E8E93',
  },
  verifiedBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#ECFDF5',
    borderWidth: 1,
    borderColor: '#D1FAE5',
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 100,
  },
  verifiedText: {
    fontSize: 10,
    fontWeight: 'bold',
    color: '#047857',
  },
  card: {
    backgroundColor: '#FFFFFF',
    borderRadius: 20,
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    padding: 24,
    marginBottom: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.03,
    shadowRadius: 4,
    elevation: 1,
  },
  cardHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginBottom: 20,
  },
  cardTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: AppColors.primary,
  },
  infoRow: {
    marginBottom: 16,
  },
  infoRowWithAction: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  infoLabel: {
    fontSize: 10,
    fontWeight: 'bold',
    color: '#8E8E93',
    textTransform: 'uppercase',
    marginBottom: 4,
  },
  infoValue: {
    fontSize: 14,
    color: AppColors.textPrimary,
    fontWeight: '600',
  },
  inlineAction: {
    borderWidth: 1,
    borderColor: AppColors.goldPrimary,
    borderRadius: 100,
    paddingHorizontal: 12,
    paddingVertical: 4,
  },
  inlineActionText: {
    fontSize: 10,
    fontWeight: 'bold',
    color: AppColors.goldDark,
  },
  aadhaarBox: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: AppColors.surfaceContainerLowest,
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    borderRadius: 12,
    padding: 12,
    marginTop: 8,
  },
  aadhaarTextCol: {
    flex: 1,
    marginLeft: 12,
  },
  aadhaarLabel: {
    fontSize: 9,
    fontWeight: 'bold',
    color: '#8E8E93',
  },
  aadhaarVal: {
    fontSize: 14,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
    marginTop: 2,
  },
  nomineeDetails: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  nomineeName: {
    fontSize: 14,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
  },
  nomineeRel: {
    fontSize: 12,
    color: AppColors.textSecondary,
    marginTop: 2,
  },
  sectionHeader: {
    fontSize: 18,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
    marginTop: 16,
    marginBottom: 16,
  },
  settingsCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 20,
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    overflow: 'hidden',
    marginBottom: 24,
  },
  settingItem: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
  },
  settingIconBox: {
    width: 40,
    height: 40,
    borderRadius: 10,
    backgroundColor: AppColors.surfaceContainerLow,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  settingText: {
    flex: 1,
    fontSize: 14,
    fontWeight: '600',
    color: AppColors.textPrimary,
  },
  settingDivider: {
    height: 1,
    backgroundColor: AppColors.surfaceContainerHigh,
    marginHorizontal: 16,
  },
  signOutButton: {
    height: 56,
    borderRadius: 16,
    borderWidth: 1.5,
    borderColor: '#EF4444',
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: 12,
  },
  signOutText: {
    color: '#EF4444',
    fontSize: 14,
    fontWeight: 'bold',
    letterSpacing: 1,
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.4)',
    justifyContent: 'flex-end',
  },
  modalContent: {
    backgroundColor: '#FFFFFF',
    borderTopLeftRadius: 24,
    borderTopRightRadius: 24,
    maxHeight: '90%',
  },
  modalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 24,
    borderBottomWidth: 1,
    borderBottomColor: AppColors.surfaceContainerHigh,
  },
  modalTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
  },
  modalBody: {
    padding: 24,
  },
  dialogLabel: {
    fontSize: 10,
    fontWeight: 'bold',
    color: '#8E8E93',
    marginBottom: 8,
  },
  dialogInputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    borderRadius: 12,
    height: 56,
    paddingHorizontal: 16,
    marginBottom: 24,
    backgroundColor: AppColors.surfaceContainerLowest,
  },
  phonePrefix: {
    fontSize: 16,
    fontWeight: 'bold',
    color: AppColors.goldPrimary,
    marginRight: 8,
  },
  dialogInput: {
    flex: 1,
    fontSize: 16,
    color: AppColors.textPrimary,
  },
  dialogBorderInput: {
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    borderRadius: 12,
    height: 56,
    paddingHorizontal: 16,
    fontSize: 16,
    color: AppColors.textPrimary,
    marginBottom: 24,
    backgroundColor: AppColors.surfaceContainerLowest,
  },
  dialogButton: {
    height: 56,
    borderRadius: 16,
    backgroundColor: AppColors.goldPrimary,
    justifyContent: 'center',
    alignItems: 'center',
  },
  dialogButtonText: {
    color: '#FFFFFF',
    fontSize: 14,
    fontWeight: 'bold',
  },
  supportIntro: {
    fontSize: 14,
    color: AppColors.textSecondary,
    lineHeight: 20,
    marginBottom: 8,
  },
  supportOption: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    borderRadius: 12,
    padding: 16,
    backgroundColor: AppColors.surfaceContainerLowest,
  },
  supportText: {
    fontSize: 14,
    fontWeight: '600',
    color: AppColors.textPrimary,
  },
  supportFaq: {
    backgroundColor: AppColors.surfaceContainerLowest,
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    borderRadius: 12,
    padding: 16,
    marginTop: 8,
  },
  faqTitle: {
    fontSize: 13,
    fontWeight: 'bold',
    color: AppColors.primary,
    marginBottom: 8,
  },
  faqText: {
    fontSize: 12,
    color: AppColors.textSecondary,
    lineHeight: 18,
    marginBottom: 6,
  },
});
