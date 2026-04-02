import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/presentation/providers/auth_provider.dart';
import 'package:slg_golds/core/constants/app_dimensions.dart';
import 'package:slg_golds/presentation/widgets/pin_pad_widget.dart';
import 'package:slg_golds/core/services/biometric_service.dart';

class PinEntryScreen extends ConsumerStatefulWidget {
  const PinEntryScreen({super.key});

  @override
  ConsumerState<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends ConsumerState<PinEntryScreen> {
  String _pin = '';
  final int _pinLength = 4;
  bool _isAuthenticating = false;

  void _onDigitPressed(String digit) {
    if (_pin.length < _pinLength && !_isAuthenticating) {
      setState(() {
        _pin += digit;
      });

      if (_pin.length == _pinLength) {
        _authenticate();
      }
    }
  }

  void _onBackspacePressed() {
    if (_pin.isNotEmpty && !_isAuthenticating) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() => _isAuthenticating = true);

    try {
      final user = ref.read(authNotifierProvider).user;

      if (user == null) {
        if (mounted) context.go('/auth/login');
        return;
      }

      final ok = await ref
          .read(authNotifierProvider.notifier)
          .verifyPin(_pin);
      if (!ok) {
        if (mounted) {
          setState(() => _pin = '');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Incorrect PIN'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final role = user.role;

      if (mounted) {
        if (role == 'admin' || role == 'manager') {
          context.go('/admin/dashboard');
        } else {
          context.go('/portfolio');
        }
      }
    } catch (e) {
      // Default to customer portfolio on error
      if (mounted) context.go('/portfolio');
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  Future<void> _authenticateWithBiometric() async {
    if (_isAuthenticating) return;

    setState(() => _isAuthenticating = true);

    try {
      final biometric = BiometricService();
      final authenticated = await biometric.authenticate();

      if (!authenticated) {
        if (mounted) setState(() => _isAuthenticating = false);
        return;
      }

      await _authenticate();
    } catch (e) {
      if (mounted) setState(() => _isAuthenticating = false);
    }
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
            Icon(Icons.lock_outline, size: 48, color: AppColors.goldPrimary),
            const SizedBox(height: AppDimensions.p24),
            Text(
              'Enter your PIN',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: AppDimensions.p8),
            Text(
              _isAuthenticating
                  ? 'Verifying...'
                  : 'To access your SLG Golds account',
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
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppColors.goldDark),
              ),
            ),
            const SizedBox(height: AppDimensions.p24),

            // Numpad
            PinPadWidget(
              onDigitPressed: _onDigitPressed,
              onBackspacePressed: _onBackspacePressed,
              showBiometric: true,
              onBiometricPressed: _authenticateWithBiometric,
            ),
            const SizedBox(height: AppDimensions.p48),
          ],
        ),
      ),
    );
  }
}
