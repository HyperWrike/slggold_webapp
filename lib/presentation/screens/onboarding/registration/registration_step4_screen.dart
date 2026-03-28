import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/core/constants/app_dimensions.dart';
import 'package:slg_golds/presentation/providers/auth_provider.dart';
import 'package:slg_golds/presentation/providers/registration_provider.dart';
import 'package:slg_golds/presentation/widgets/slg_button.dart';
import 'package:slg_golds/presentation/widgets/slg_text_field.dart';

class RegistrationStep4Screen extends ConsumerStatefulWidget {
  const RegistrationStep4Screen({super.key});

  @override
  ConsumerState<RegistrationStep4Screen> createState() =>
      _RegistrationStep4ScreenState();
}

class _RegistrationStep4ScreenState
    extends ConsumerState<RegistrationStep4Screen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePin = true;
  bool _obscureConfirmPin = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      ref
          .read(registrationProvider.notifier)
          .updateStep4(
            username: _usernameController.text,
            pin: _pinController.text,
            password: _passwordController.text,
          );

      final regData = ref.read(registrationProvider);

      try {
        final success = await ref
            .read(authNotifierProvider.notifier)
            .register(
              fullName: regData.fullName,
              username: _usernameController.text,
              password: _passwordController.text,
              phone: regData.phone,
              aadhaar: regData.aadhaar,
              dob: regData.dob,
              gender: regData.gender,
              fatherName: regData.fatherName,
              birthPlace: regData.birthPlace,
              address: regData.address,
              nomineeName: regData.nomineeName,
              nomineeRelationship: regData.nomineeRelationship,
              pin: _pinController.text,
            );

        setState(() => _isLoading = false);

        if (success && mounted) {
          ref.read(registrationProvider.notifier).reset();
          context.go('/onboarding/success');
        } else if (mounted) {
          final error = ref.read(authNotifierProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Registration failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
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
      appBar: AppBar(
        title: const Text('Account Setup'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.p24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: List.generate(
                    4,
                    (index) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.goldPrimary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.p32),

                Text(
                  'Final Step',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: AppDimensions.p8),
                Text(
                  'Set up your username and PIN to secure your account',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppDimensions.p32),

                SlgTextField(
                  label: 'Username',
                  hint: 'Choose a unique username',
                  controller: _usernameController,
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: AppColors.goldPrimary,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username is required';
                    }
                    if (value.length < 4) {
                      return 'Must be at least 4 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.p24),

                SlgTextField(
                  label: 'Password',
                  hint: 'Create a password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.goldPrimary,
                  ),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.p20),

                SlgTextField(
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.goldPrimary,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.p24),

                SlgTextField(
                  label: 'Create PIN',
                  hint: '4 or 6 digit PIN',
                  controller: _pinController,
                  obscureText: _obscurePin,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(
                    Icons.pin_outlined,
                    color: AppColors.goldPrimary,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePin ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePin = !_obscurePin;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'PIN is required';
                    }
                    if (value.length != 4 && value.length != 6) {
                      return 'PIN must be 4 or 6 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.p20),

                SlgTextField(
                  label: 'Confirm PIN',
                  hint: 'Re-enter your PIN',
                  controller: _confirmPinController,
                  obscureText: _obscureConfirmPin,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(
                    Icons.pin_outlined,
                    color: AppColors.goldPrimary,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPin
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPin = !_obscureConfirmPin;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm PIN';
                    }
                    if (value != _pinController.text) {
                      return 'PINs do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.p48),

                Row(
                  children: [
                    Expanded(
                      child: SlgButton(
                        text: 'BACK',
                        isSecondary: true,
                        onPressed: () => context.pop(),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.p16),
                    Expanded(
                      flex: 2,
                      child: SlgButton(
                        text: 'FINISH',
                        isLoading: _isLoading,
                        onPressed: _onRegister,
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
