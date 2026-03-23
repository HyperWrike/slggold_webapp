import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/core/constants/app_dimensions.dart';
import 'package:slg_golds/presentation/widgets/pin_pad_widget.dart';

class PinEntryScreen extends StatefulWidget {
  const PinEntryScreen({super.key});

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  String _pin = '';
  final int _pinLength = 4; // Will be read from user profile eventually

  void _onDigitPressed(String digit) {
    if (_pin.length < _pinLength) {
      setState(() {
        _pin += digit;
      });
      
      if (_pin.length == _pinLength) {
        // Authenticate
        _authenticate();
      }
    }
  }

  void _onBackspacePressed() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _authenticate() {
    // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Authenticating...')));
    // Assume success for now
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            
            // Header Content
            Icon(
              Icons.lock_outline,
              size: 48,
              color: AppColors.goldPrimary,
            ),
            const SizedBox(height: AppDimensions.p24),
            Text(
              'Enter your PIN',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: AppDimensions.p8),
            Text(
              'To access your SLG Golds account',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppDimensions.p48),
            
            // PIN Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pinLength,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _pin.length
                        ? AppColors.goldDark
                        : AppColors.surfaceContainerHigh,
                    border: Border.all(
                      color: index < _pin.length
                          ? AppColors.goldDark
                          : AppColors.textSecondary.withAlpha(50),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            
            // Text action
            TextButton(
              onPressed: () {
                context.push('/auth/login');
              },
              child: Text(
                'Login with Password instead',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.goldDark,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.p24),
            
            // Numpad
            PinPadWidget(
              onDigitPressed: _onDigitPressed,
              onBackspacePressed: _onBackspacePressed,
              showBiometric: true, // Will be enabled if biometrics are enrolled
              onBiometricPressed: () {
                // Trigger biometric auth
                context.go('/home');
              },
            ),
            const SizedBox(height: AppDimensions.p48),
          ],
        ),
      ),
    );
  }
}
