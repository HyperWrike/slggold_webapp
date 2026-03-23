import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/core/constants/app_dimensions.dart';
import 'package:slg_golds/presentation/widgets/slg_button.dart';
import 'package:slg_golds/presentation/widgets/slg_text_field.dart';

class RegistrationStep4Screen extends StatefulWidget {
  const RegistrationStep4Screen({super.key});

  @override
  State<RegistrationStep4Screen> createState() => _RegistrationStep4ScreenState();
}

class _RegistrationStep4ScreenState extends State<RegistrationStep4Screen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  bool _obscurePin = true;
  bool _obscureConfirmPin = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (_formKey.currentState!.validate()) {
      // Typically we would call the AuthUseCase here to register the user
      // and redirect on success. For now, navigate.
      context.go('/onboarding/success');
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
                // Step Indicator
                Row(
                  children: List.generate(4, (index) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  )),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Username is required';
                    if (value.length < 4) return 'Must be at least 4 characters';
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
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'PIN is required';
                    if (value.length != 4 && value.length != 6) {
                      return 'PIN must be 4 or 6 digits';
                    }
                    return null;
                  },
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
                ),
                const SizedBox(height: AppDimensions.p20),
                
                SlgTextField(
                  label: 'Confirm PIN',
                  hint: 'Re-enter your PIN',
                  controller: _confirmPinController,
                  obscureText: _obscureConfirmPin,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please confirm PIN';
                    if (value != _pinController.text) return 'PINs do not match';
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPin ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPin = !_obscureConfirmPin;
                      });
                    },
                  ),
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
