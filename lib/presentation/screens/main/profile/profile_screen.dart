import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/presentation/providers/auth_provider.dart';
import 'package:slg_golds/presentation/providers/user_data_provider.dart';
import 'package:slg_golds/core/services/biometric_service.dart';
import 'package:slg_golds/presentation/widgets/notification_popup.dart';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _biometricEnabled = false;
  bool _notificationsEnabled = true;
  final BiometricService _biometricService = BiometricService();

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final available = await _biometricService.isBiometricAvailable();
    if (mounted) {
      setState(() => _biometricEnabled = available);
    }
  }

  String _hashPin(String pin) {
    var bytes = utf8.encode(pin);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final userId = user?.id;

    final profileAsync = userId != null
        ? ref.watch(userDataProvider(userId))
        : null;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          _buildTopAppBar(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildProfileHero(context, user, profileAsync),
                  const SizedBox(height: 16),
                  _buildDetailsSection(context, profileAsync),
                  _buildSettingsSection(context),
                  _buildSignOutButton(context, ref),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context) {
    return Container(
      color: const Color(0xFFFAFAFA),
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Profile',
                        style: TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => NotificationPopup.show(context),
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.primary,
                    ),
                    splashRadius: 24,
                  ),
                ],
              ),
            ),
          ),
          Container(height: 1, color: AppColors.surfaceContainerHigh),
        ],
      ),
    );
  }

  Widget _buildProfileHero(
    BuildContext context,
    dynamic user,
    AsyncValue<Map<String, dynamic>?>? profileAsync,
  ) {
    final fullName = user?.fullName ?? 'User';
    final username = user?.username ?? '';
    String memberDate = 'Jan 2025';

    if (profileAsync != null) {
      profileAsync.whenData((data) {
        if (data != null && data['created_at'] != null) {
          final created = DateTime.parse(data['created_at'] as String);
          memberDate = DateFormat('MMM yyyy').format(created);
        }
      });
    }

    return Container(
      height: 220,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF3E8FF), AppColors.surface],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar with gold border
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF5C842), Color(0xFFC8860A)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    color: AppColors.surfaceContainerHigh,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Center(
                      child: Text(
                        fullName.isNotEmpty
                            ? fullName.substring(0, 1).toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(26),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(2),
                  child: const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: Color(0xFF059669),
                    fill: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Name and username
          Text(
            fullName.split(' ').first,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '@${username.isNotEmpty ? username : fullName.toLowerCase().replaceAll(' ', '_')}',
            style: const TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Member since $memberDate',
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0x994F4634),
                  letterSpacing: 0.1 * 10,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: const Color(0xFFD1FAE5)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '✓ Verified',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF047857),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(
    BuildContext context,
    AsyncValue<Map<String, dynamic>?>? profileAsync,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: profileAsync != null
          ? profileAsync.when(
              data: (data) {
                if (data == null) return const SizedBox.shrink();

                final fullName = data['full_name'] as String? ?? '';
                final dob = data['dob'] as String?;
                final gender = data['gender'] as String? ?? '';
                final birthPlace = data['birth_place'] as String? ?? '';
                final fatherName = data['father_name'] as String? ?? '';
                final phone = data['phone'] as String? ?? '';
                final address = data['address'] as String? ?? '';
                final aadhaar = data['aadhaar'] as String? ?? '';
                final nomineeName = data['nominee_name'] as String? ?? '';
                final nomineeRelationship =
                    data['nominee_relationship'] as String? ?? '';

                // Calculate age
                String age = '';
                String formattedDob = '';
                if (dob != null && dob.isNotEmpty) {
                  try {
                    final dobDate = DateTime.parse(dob);
                    final now = DateTime.now();
                    age = '${now.year - dobDate.year}';
                    formattedDob = DateFormat('dd MMM yyyy').format(dobDate);
                  } catch (_) {}
                }

                // Mask phone
                String maskedPhone = phone;
                if (phone.length > 5) {
                  maskedPhone =
                      '+91 ${phone.substring(0, 2)}XXXXX${phone.substring(phone.length - 4)}';
                }

                // Mask aadhaar
                String maskedAadhaar = '';
                if (aadhaar.length >= 4) {
                  maskedAadhaar =
                      'XXXX-XXXX-${aadhaar.substring(aadhaar.length - 4)}';
                }

                return Column(
                  children: [
                    // Personal Info Card
                    _buildInfoCard(
                      title: 'Personal Info',
                      icon: Icons.person_outline,
                      children: [
                        _buildInfoRow('Full Name', fullName),
                        _buildInfoRow('Date of Birth', formattedDob),
                        _buildInfoRow(
                          'Age / Gender',
                          age.isNotEmpty ? '$age / $gender' : gender,
                        ),
                        _buildInfoRow('Place of Birth', birthPlace),
                        const Divider(
                          height: 24,
                          color: AppColors.surfaceContainerLow,
                        ),
                        _buildInfoRow('Father\'s Name', fatherName),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Contact & Identity Card
                    _buildInfoCard(
                      title: 'Contact & Identity',
                      icon: Icons.contact_mail_outlined,
                      children: [
                        _buildContactRow(
                          label: 'Phone',
                          value: maskedPhone,
                          action: 'CHANGE',
                          onAction: () => _showChangePhoneDialog(context, ref),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Address', address),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.fingerprint,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'AADHAAR NUMBER',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textSecondary,
                                        letterSpacing: 0.1 * 10,
                                      ),
                                    ),
                                    Text(
                                      '$maskedAadhaar 🔒',
                                      style: const TextStyle(
                                        fontFamily: 'DM Mono',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.verified_user,
                                color: Color(0xFF059669),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Nominee Card
                    if (nomineeName.isNotEmpty)
                      _buildInfoCard(
                        title: 'Nominee',
                        icon: Icons.family_restroom,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryFixed,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    nomineeName.isNotEmpty
                                        ? nomineeName
                                              .split(' ')
                                              .take(2)
                                              .map(
                                                (n) => n.isNotEmpty ? n[0] : '',
                                              )
                                              .join()
                                              .toUpperCase()
                                        : '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nomineeName,
                                    style: const TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    nomineeRelationship.isNotEmpty
                                        ? '$nomineeRelationship • 100% Share'
                                        : '100% Share',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0A795900),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.1 * 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value.isNotEmpty ? value : '--',
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow({
    required String label,
    required String value,
    required String action,
    required VoidCallback onAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.1 * 10,
              ),
            ),
            Text(
              value.isNotEmpty ? value : '--',
              style: const TextStyle(
                fontFamily: 'DM Mono',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: onAction,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.outlineVariant),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              action,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Text(
            'Settings',
            style: TextStyle(
              fontFamily: 'Cormorant Garamond',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x0A795900),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSettingsItem(
                  icon: Icons.lock_reset,
                  title: 'Change PIN',
                  isToggle: false,
                  onTap: () => _showChangePinDialog(context, ref),
                ),
                _buildDivider(),
                _buildSettingsItem(
                  icon: Icons.password_outlined,
                  title: 'Change Password',
                  isToggle: false,
                  onTap: () => _showChangePasswordDialog(context, ref),
                ),
                _buildDivider(),
                _buildSettingsItem(
                  icon: Icons.face,
                  title: 'Biometric Login',
                  isToggle: true,
                  toggleValue: _biometricEnabled,
                  onToggle: (val) async {
                    if (val) {
                      final authenticated = await _biometricService
                          .authenticate();
                      if (authenticated && mounted) {
                        setState(() => _biometricEnabled = true);
                      }
                    } else {
                      setState(() => _biometricEnabled = false);
                    }
                  },
                ),
                _buildDivider(),
                _buildSettingsItem(
                  icon: Icons.notifications_active_outlined,
                  title: 'Notifications',
                  isToggle: true,
                  toggleValue: _notificationsEnabled,
                  onToggle: (val) {
                    setState(() => _notificationsEnabled = val);
                  },
                ),
                _buildDivider(),
                _buildSettingsItem(
                  icon: Icons.contact_support_outlined,
                  title: 'Support & FAQ',
                  isToggle: false,
                  onTap: () => _showSupportDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: AppColors.surfaceContainerLow),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required bool isToggle,
    bool toggleValue = false,
    ValueChanged<bool>? onToggle,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isToggle ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: AppColors.textSecondary, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              isToggle
                  ? _buildToggle(toggleValue, onToggle)
                  : const Icon(
                      Icons.chevron_right,
                      color: Color(0x664F4634),
                      size: 20,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggle(bool value, ValueChanged<bool>? onChanged) {
    return GestureDetector(
      onTap: () => onChanged?.call(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 24,
        decoration: BoxDecoration(
          color: value
              ? AppColors.primaryContainer
              : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD4D5D9)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: GestureDetector(
        onTap: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Sign Out'),
              content: const Text('Are you sure you want to sign out?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
          );

          if (confirmed == true && context.mounted) {
            await ref.read(authNotifierProvider.notifier).logout();
            if (context.mounted) {
              context.go('/auth/login');
            }
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.error),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: AppColors.error, size: 20),
              SizedBox(width: 8),
              Text(
                'Sign Out',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Dialogs

  void _showChangePinDialog(BuildContext context, WidgetRef ref) {
    final currentPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Change PIN',
          style: TextStyle(
            fontFamily: 'Cormorant Garamond',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPinController,
              obscureText: true,
              maxLength: 4,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Current PIN',
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPinController,
              obscureText: true,
              maxLength: 4,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'New PIN',
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPinController,
              obscureText: true,
              maxLength: 4,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Confirm New PIN',
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final currentPin = currentPinController.text;
              final newPin = newPinController.text;
              final confirmPin = confirmPinController.text;

              if (currentPin.length != 4 ||
                  newPin.length != 4 ||
                  confirmPin.length != 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PIN must be 4 digits'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              if (newPin != confirmPin) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('New PINs do not match'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              // Verify current PIN
              final isValid = await ref
                  .read(authNotifierProvider.notifier)
                  .verifyPin(currentPin);
              if (!isValid) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Current PIN is incorrect'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
                return;
              }

              // Update PIN in Supabase
              final userId = ref.read(authNotifierProvider).user?.id;
              if (userId != null) {
                try {
                  final supabase = ref.read(supabaseProvider);
                  await supabase
                      .from('profiles')
                      .update({'pin_hash': _hashPin(newPin)})
                      .eq('id', userId);

                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('PIN changed successfully'),
                        backgroundColor: Color(0xFF059669),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to change PIN: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Change PIN'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Change Password',
          style: TextStyle(
            fontFamily: 'Cormorant Garamond',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current Password'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final currentPassword = currentPasswordController.text;
              final newPassword = newPasswordController.text;
              final confirmPassword = confirmPasswordController.text;

              if (newPassword.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password must be at least 6 characters'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              if (newPassword != confirmPassword) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('New passwords do not match'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              try {
                final supabase = ref.read(supabaseProvider);

                // Re-authenticate with current password
                final user = supabase.auth.currentUser;
                if (user?.email != null) {
                  try {
                    await supabase.auth.signInWithPassword(
                      email: user!.email!,
                      password: currentPassword,
                    );
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Current password is incorrect'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                    return;
                  }

                  // Update password
                  await supabase.auth.updateUser(
                    UserAttributes(password: newPassword),
                  );

                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password changed successfully'),
                        backgroundColor: Color(0xFF059669),
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to change password: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  void _showChangePhoneDialog(BuildContext context, WidgetRef ref) {
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Change Phone Number',
          style: TextStyle(
            fontFamily: 'Cormorant Garamond',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'New Phone Number',
            hintText: 'Enter 10 digit number',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final phone = phoneController.text.trim();
              if (phone.length != 10) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid 10 digit phone number'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              final userId = ref.read(authNotifierProvider).user?.id;
              if (userId != null) {
                try {
                  final supabase = ref.read(supabaseProvider);
                  await supabase
                      .from('profiles')
                      .update({'phone': phone})
                      .eq('id', userId);

                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ref.invalidate(userDataProvider(userId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Phone number updated'),
                        backgroundColor: Color(0xFF059669),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Support & FAQ',
          style: TextStyle(
            fontFamily: 'Cormorant Garamond',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contact Us', style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(height: 8),
            Text('📧 support@slggolds.com'),
            Text('📞 +91 1800-XXX-XXXX'),
            Text('💬 WhatsApp: +91 XXXXXXXXXX'),
            SizedBox(height: 16),
            Text('FAQ', style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(height: 8),
            Text(
              '• How to enroll in a scheme?\n'
              '  Go to Schemes → Select a plan → Enroll Now\n\n'
              '• When do I receive gold?\n'
              '  Gold is credited after each payment\n\n'
              '• Can I withdraw early?\n'
              '  Contact support for early withdrawal options',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
