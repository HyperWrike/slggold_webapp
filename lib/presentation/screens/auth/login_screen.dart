import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/core/constants/app_dimensions.dart';
import 'package:slg_golds/core/constants/app_strings.dart';
import 'package:slg_golds/presentation/providers/auth_provider.dart';
import 'package:slg_golds/presentation/widgets/slg_button.dart';
import 'package:slg_golds/presentation/widgets/slg_text_field.dart';
import '../../../core/services/biometric_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isBiometricAvailable = false;
  final BiometricService _biometricService = BiometricService();

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final isAvailable = await _biometricService.isBiometricAvailable();
    if (mounted) {
      setState(() {
        _isBiometricAvailable = isAvailable;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final success = await ref
          .read(authNotifierProvider.notifier)
          .login(_usernameController.text, _passwordController.text);

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          context.go('/auth/pin-entry');
        } else {
          final error = ref.read(authNotifierProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Login failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.p24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppDimensions.p24),

                // Header
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: AppDimensions.p8),
                Text(
                  'Login to manage your gold portfolio',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppDimensions.p48),

                // Form Fields
                SlgTextField(
                  label: 'Email or Username',
                  hint: 'admin@slggolds.com',
                  controller: _usernameController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value!.isEmpty ? 'Email or username is required' : null,
                ),
                const SizedBox(height: AppDimensions.p24),

                SlgTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: (value) =>
                      value!.isEmpty ? 'Password is required' : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Forgot password flow
                    },
                    child: Text(
                      'Forgot Password?',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.goldDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.p32),

                SlgButton(
                  text: 'LOGIN',
                  isLoading: _isLoading,
                  onPressed: _onLogin,
                ),
                if (_isBiometricAvailable) ...[
                  const SizedBox(height: AppDimensions.p16),
                  Center(
                    child: IconButton(
                      iconSize: 48,
                      icon: const Icon(
                        Icons.fingerprint,
                        color: AppColors.goldPrimary,
                      ),
                      onPressed: () async {
                        final success = await _biometricService.authenticate();
                        if (success && mounted) {
                          context.go('/auth/pin-entry');
                        }
                      },
                    ),
                  ),
                ],
                const SizedBox(height: AppDimensions.p24),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'New to ${AppStrings.appName}?',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        context.push('/onboarding/register');
                      },
                      child: Text(
                        'Register Now',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.goldDark,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
