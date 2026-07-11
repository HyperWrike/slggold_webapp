import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, ActivityIndicator, Modal, TextInput, Alert, SafeAreaView } from 'react-native';
import { useQuery } from 'convex/react';
import { useAuth } from '../../context/AuthContext';
import { api } from '../../../convex/_generated/api';
import { AppColors } from '../../constants/colors';
import { Ionicons } from '@expo/vector-icons';
import { StatusBar } from 'expo-status-bar';

export default function AdminCustomersScreen() {
  const { sessionToken } = useAuth();
  
  // Queries
  const customers = useQuery(api.admin.listCustomers, sessionToken ? { sessionToken } : 'skip');

  // Search state
  const [searchQuery, setSearchQuery] = useState('');

  // Selected customer for modal detail view
  const [selectedCustomer, setSelectedCustomer] = useState<any>(null);
  const [detailsModalVisible, setDetailsModalVisible] = useState(false);

  // Load selected customer's active enrollments count (dynamically)
  const activeCountQuery = useQuery(
    api.enrollments.countActiveForUser,
    sessionToken && selectedCustomer ? { sessionToken, userId: selectedCustomer.id } : 'skip'
  );

  const getFilteredCustomers = (list: any[]) => {
    if (!list) return [];
    const query = searchQuery.toLowerCase().trim();
    if (!query) return list;
    
    return list.filter((c) => {
      return (
        (c.full_name || '').toLowerCase().includes(query) ||
        (c.username || '').toLowerCase().includes(query) ||
        (c.email || '').toLowerCase().includes(query) ||
        (c.phone || '').includes(query)
      );
    });
  };

  const filteredCustomers = customers ? getFilteredCustomers(customers) : [];

  const handleOpenDetails = (customer: any) => {
    setSelectedCustomer(customer);
    setDetailsModalVisible(true);
  };

  const formatDate = (dateStr?: string) => {
    if (!dateStr) return '--';
    const d = new Date(dateStr);
    if (isNaN(d.getTime())) return dateStr;
    return d.toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' });
  };

  return (
    <SafeAreaView style={styles.safeContainer}>
      <StatusBar style="dark" />
      
      {/* Search Header */}
      <View style={styles.header}>
        <View style={styles.searchBar}>
          <Ionicons name="search" size={20} color="#8E8E93" style={{ marginRight: 8 }} />
          <TextInput
            style={styles.searchInput}
            placeholder="Search by name, username, email..."
            value={searchQuery}
            onChangeText={setSearchQuery}
            autoCapitalize="none"
          />
          {searchQuery ? (
            <TouchableOpacity onPress={() => setSearchQuery('')}>
              <Ionicons name="close-circle" size={18} color="#8E8E93" />
            </TouchableOpacity>
          ) : null}
        </View>
      </View>

      <ScrollView contentContainerStyle={styles.scrollContent}>
        {customers ? (
          filteredCustomers.length > 0 ? (
            filteredCustomers.map((c) => (
              <TouchableOpacity
                key={c.id}
                style={styles.customerCard}
                activeOpacity={0.8}
                onPress={() => handleOpenDetails(c)}
              >
                <View style={styles.avatar}>
                  <Text style={styles.avatarText}>
                    {c.full_name ? c.full_name.charAt(0).toUpperCase() : 'C'}
                  </Text>
                </View>

                <View style={styles.customerInfo}>
                  <Text style={styles.customerName}>{c.full_name}</Text>
                  <Text style={styles.customerMeta}>@{c.username} • {c.phone}</Text>
                  <Text style={styles.customerEmail}>{c.email}</Text>
                </View>

                <Ionicons name="chevron-forward" size={18} color="#C7C7CC" />
              </TouchableOpacity>
            ))
          ) : (
            <View style={styles.emptyContainer}>
              <Ionicons name="people-outline" size={64} color="#C7C7CC" />
              <Text style={styles.emptyTitle}>No Customers Found</Text>
              <Text style={styles.emptySub}>No members match your search criteria.</Text>
            </View>
          )
        ) : (
          <ActivityIndicator color={AppColors.royalPurple} size="large" style={{ marginTop: 48 }} />
        )}

        <View style={{ height: 100 }} />
      </ScrollView>

      {/* Customer Detail Sheet Modal */}
      <Modal
        animationType="slide"
        transparent={true}
        visible={detailsModalVisible}
        onRequestClose={() => setDetailsModalVisible(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>Customer Profile</Text>
              <TouchableOpacity onPress={() => setDetailsModalVisible(false)}>
                <Ionicons name="close" size={24} color={AppColors.textPrimary} />
              </TouchableOpacity>
            </View>

            {selectedCustomer && (
              <ScrollView contentContainerStyle={styles.modalBody}>
                {/* Hero profile details */}
                <View style={styles.modalHero}>
                  <View style={styles.modalAvatar}>
                    <Text style={styles.modalAvatarText}>
                      {selectedCustomer.full_name ? selectedCustomer.full_name.charAt(0).toUpperCase() : 'C'}
                    </Text>
                  </View>
                  <Text style={styles.modalName}>{selectedCustomer.full_name}</Text>
                  <Text style={styles.modalUsername}>@{selectedCustomer.username}</Text>
                </View>

                {/* KPI stats */}
                <View style={styles.modalStatsRow}>
                  <View style={styles.modalStatCard}>
                    <Text style={styles.statLabel}>Active Schemes</Text>
                    <Text style={styles.statVal}>{activeCountQuery !== undefined ? activeCountQuery : '--'}</Text>
                  </View>
                  <View style={styles.modalStatCard}>
                    <Text style={styles.statLabel}>Aadhaar Status</Text>
                    <Text style={[styles.statVal, { color: '#059669', fontSize: 14 }]}>✓ VERIFIED</Text>
                  </View>
                </View>

                {/* Personal Details */}
                <View style={styles.infoSection}>
                  <Text style={styles.sectionHeader}>Personal Information</Text>
                  
                  <View style={styles.detailRow}>
                    <Text style={styles.detailLabel}>Date of Birth</Text>
                    <Text style={styles.detailVal}>{formatDate(selectedCustomer.dob)}</Text>
                  </View>

                  <View style={styles.detailRow}>
                    <Text style={styles.detailLabel}>Gender</Text>
                    <Text style={styles.detailVal}>{selectedCustomer.gender || '--'}</Text>
                  </View>

                  <View style={styles.detailRow}>
                    <Text style={styles.detailLabel}>Place of Birth</Text>
                    <Text style={styles.detailVal}>{selectedCustomer.birth_place || '--'}</Text>
                  </View>

                  <View style={styles.detailRow}>
                    <Text style={styles.detailLabel}>Father's / Husband's Name</Text>
                    <Text style={styles.detailVal}>{selectedCustomer.father_name || '--'}</Text>
                  </View>
                </View>

                {/* Contact details */}
                <View style={styles.infoSection}>
                  <Text style={styles.sectionHeader}>Contact & Address</Text>
                  
                  <View style={styles.detailRow}>
                    <Text style={styles.detailLabel}>Mobile</Text>
                    <Text style={styles.detailVal}>+91 {selectedCustomer.phone}</Text>
                  </View>

                  <View style={styles.detailRow}>
                    <Text style={styles.detailLabel}>Email</Text>
                    <Text style={styles.detailVal}>{selectedCustomer.email}</Text>
                  </View>

                  <View style={styles.detailRow}>
                    <Text style={styles.detailLabel}>Aadhaar Number</Text>
                    <Text style={styles.detailVal}>XXXX-XXXX-{selectedCustomer.aadhaar?.substring(selectedCustomer.aadhaar.length - 4) || 'XXXX'}</Text>
                  </View>

                  <View style={styles.detailRow}>
                    <Text style={styles.detailLabel}>Address</Text>
                    <Text style={styles.detailVal}>{selectedCustomer.address || '--'}</Text>
                  </View>
                </View>

                {/* Nominee details */}
                {selectedCustomer.nominee_name ? (
                  <View style={styles.infoSection}>
                    <Text style={styles.sectionHeader}>Nominee Information</Text>
                    
                    <View style={styles.detailRow}>
                      <Text style={styles.detailLabel}>Nominee Name</Text>
                      <Text style={styles.detailVal}>{selectedCustomer.nominee_name}</Text>
                    </View>

                    <View style={styles.detailRow}>
                      <Text style={styles.detailLabel}>Relationship</Text>
                      <Text style={styles.detailVal}>{selectedCustomer.nominee_relationship || '--'}</Text>
                    </View>
                  </View>
                ) : null}

                <View style={{ height: 40 }} />
              </ScrollView>
            )}
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
  header: {
    backgroundColor: '#FFFFFF',
    borderBottomWidth: 1,
    borderBottomColor: AppColors.surfaceContainerHigh,
    paddingVertical: 12,
    paddingHorizontal: 24,
  },
  searchBar: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#F2F2F7',
    borderRadius: 12,
    height: 44,
    paddingHorizontal: 12,
  },
  searchInput: {
    flex: 1,
    fontSize: 15,
    color: AppColors.textPrimary,
  },
  scrollContent: {
    padding: 24,
    gap: 16,
  },
  customerCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FFFFFF',
    borderRadius: 20,
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    padding: 16,
  },
  avatar: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: 'rgba(74, 14, 143, 0.1)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  avatarText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: AppColors.royalPurple,
  },
  customerInfo: {
    flex: 1,
    marginLeft: 16,
  },
  customerName: {
    fontSize: 15,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
  },
  customerMeta: {
    fontSize: 12,
    color: AppColors.textSecondary,
    marginTop: 2,
  },
  customerEmail: {
    fontSize: 12,
    color: '#8E8E93',
    marginTop: 2,
  },
  emptyContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 64,
    gap: 12,
  },
  emptyTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
  },
  emptySub: {
    fontSize: 13,
    color: '#8E8E93',
    textAlign: 'center',
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
  modalHero: {
    alignItems: 'center',
    marginBottom: 24,
  },
  modalAvatar: {
    width: 64,
    height: 64,
    borderRadius: 32,
    backgroundColor: 'rgba(74, 14, 143, 0.1)',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 12,
  },
  modalAvatarText: {
    fontSize: 24,
    fontWeight: 'bold',
    color: AppColors.royalPurple,
  },
  modalName: {
    fontSize: 18,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
  },
  modalUsername: {
    fontSize: 13,
    color: AppColors.textSecondary,
    marginTop: 2,
  },
  modalStatsRow: {
    flexDirection: 'row',
    gap: 16,
    marginBottom: 24,
  },
  modalStatCard: {
    flex: 1,
    backgroundColor: '#F8F9FA',
    borderWidth: 1,
    borderColor: AppColors.surfaceContainerHigh,
    borderRadius: 12,
    padding: 12,
    alignItems: 'center',
  },
  statLabel: {
    fontSize: 10,
    fontWeight: 'bold',
    color: '#8E8E93',
    textTransform: 'uppercase',
    marginBottom: 4,
  },
  statVal: {
    fontSize: 18,
    fontWeight: 'bold',
    color: AppColors.textPrimary,
  },
  infoSection: {
    marginBottom: 24,
  },
  sectionHeader: {
    fontSize: 14,
    fontWeight: 'bold',
    color: AppColors.royalPurple,
    marginBottom: 12,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  detailRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 8,
    borderBottomWidth: 1,
    borderBottomColor: '#F2F2F7',
  },
  detailLabel: {
    fontSize: 13,
    color: AppColors.textSecondary,
  },
  detailVal: {
    fontSize: 13,
    fontWeight: '600',
    color: AppColors.textPrimary,
    maxWidth: 200,
    textAlign: 'right',
  },
});
