import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/core/constants/app_dimensions.dart';
import 'package:slg_golds/presentation/widgets/slg_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.p24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Info Card
              Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.goldPrimary,
                    child: Icon(Icons.person, size: 32, color: AppColors.surface),
                  ),
                  const SizedBox(width: AppDimensions.p16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rajesh Kumar', // Dummy data
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppDimensions.p4),
                        Text(
                          'rajeshk123 | +91 9876543210',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.goldPrimary),
                    onPressed: () {},
                  )
                ],
              ),
              const SizedBox(height: AppDimensions.p48),
              
              // Settings Sections
              Text(
                'ACCOUNT SETTINGS',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppDimensions.p8),
              _buildSettingsTile(
                context,
                icon: Icons.shield_outlined,
                title: 'Change PIN',
                onTap: () {},
              ),
              _buildSettingsTile(
                context,
                icon: Icons.fingerprint,
                title: 'Enable Biometric Login',
                trailing: Switch(
                  value: true,
                  onChanged: (val) {},
                  activeColor: AppColors.goldPrimary,
                ),
                onTap: () {},
              ),
              _buildSettingsTile(
                context,
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () {},
              ),
              
              const SizedBox(height: AppDimensions.p32),
              
              Text(
                'SUPPORT & LEGAL',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppDimensions.p8),
              _buildSettingsTile(
                context,
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {},
              ),
              _buildSettingsTile(
                context,
                icon: Icons.description_outlined,
                title: 'Terms & Conditions',
                onTap: () {},
              ),
              _buildSettingsTile(
                context,
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () {},
              ),
              
              const SizedBox(height: AppDimensions.p48),
              
              SlgButton(
                text: 'LOGOUT',
                isSecondary: true,
                onPressed: () {
                  context.go('/auth/login');
                },
              ),
              
              const SizedBox(height: AppDimensions.p24),
              Center(
                child: Text(
                  'App Version 1.0.0',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.p48), // Bottom nav padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        Widget? trailing,
        required VoidCallback onTap,
      }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
