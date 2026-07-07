import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/core/constants/app_dimensions.dart';
import 'package:slg_golds/core/services/otp_service.dart';
import 'package:slg_golds/presentation/widgets/slg_button.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String email;
  const OtpVerificationScreen({super.key, required this.email});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final OtpService _otpService = OtpService();

  bool _isLoading = false;
  bool _isResending = false;
  bool _otpSent = false;
  bool _showOtpOnScreen = false;
  int _resendSeconds = 30;
  String? _error;
  String? _generatedOtp;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendOtp();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
        return true;
      }
      return false;
    });
  }

  Future<void> _sendOtp() async {
    setState(() {
      _error = null;
      _isLoading = !_otpSent ? true : _isLoading;
      _showOtpOnScreen = false;
    });

    // Generate OTP
    final otp = _otpService.generateOtp();
    _generatedOtp = otp;

    // Send via Brevo email service
    final result = await _otpService.sendOtp(widget.email, otp);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.success) {
          _otpSent = true;
          _resendSeconds = 30;
          _startResendTimer();
          _error = null;
          _showOtpOnScreen = false;
        } else {
          // SMS failed - show error and OTP on screen for testing
          _otpSent = true;
          _showOtpOnScreen = true;
          _resendSeconds = 30;
          _startResendTimer();
          _error = result.message;
        }
      });

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP sent to ${widget.email}'),
            backgroundColor: const Color(0xFF059669),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _verifyOtp() async {
    final enteredOtp = _controllers.map((c) => c.text).join();

    if (enteredOtp.length != 6) {
      setState(() => _error = 'Please enter the complete 6-digit OTP');
      return;
    }

    if (_generatedOtp == null) {
      setState(() => _error = 'Please request an OTP first');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Verify locally
    await Future.delayed(const Duration(milliseconds: 500)); // UX delay

    final isValid = _otpService.verifyOtp(enteredOtp, _generatedOtp!);

    if (isValid) {
      if (mounted) {
        setState(() => _isLoading = false);
        context.push('/onboarding/register/step3');
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Invalid OTP. Please check and try again.';
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    if (_resendSeconds > 0) return;

    setState(() {
      _isResending = true;
      _error = null;
      // Clear previous OTP inputs
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
    });

    await _sendOtp();

    if (mounted) {
      setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maskedEmail = widget.email.replaceRange(
      widget.email.indexOf('@') > 2 ? 2 : 0,
      widget.email.indexOf('@'),
      '****',
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Verify Email'),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step Indicator
              Row(
                children: List.generate(
                  4,
                  (index) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= 1
                            ? AppColors.goldPrimary
                            : AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.p32),

              const Icon(
                Icons.email_outlined,
                size: 64,
                color: AppColors.goldPrimary,
              ),
              const SizedBox(height: AppDimensions.p24),

              Text(
                'Verify Your Email',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AppDimensions.p8),
              Text(
                _otpSent
                    ? 'We sent a 6-digit code to $maskedEmail'
                    : 'Sending OTP to ${widget.email}...',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimensions.p24),

              // Show SMS failure message (no OTP displayed)
              if (_showOtpOnScreen && _generatedOtp != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withAlpha(77)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'SMS could not be sent. Please check your SMS provider configuration and try again.',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppDimensions.p24),

              // OTP Input Fields
              if (_otpSent) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 48,
                      height: 56,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(
                          fontFamily: 'DM Mono',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: AppColors.surfaceContainerLowest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.surfaceContainerHigh,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.goldPrimary,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          }
                          if (value.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                          // Auto-verify when all 6 digits entered
                          if (index == 5 && value.isNotEmpty) {
                            final allFilled = _controllers.every(
                              (c) => c.text.isNotEmpty,
                            );
                            if (allFilled) _verifyOtp();
                          }
                        },
                      ),
                    );
                  }),
                ),
              ] else ...[
                const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.goldPrimary,
                  ),
                ),
              ],
              const SizedBox(height: AppDimensions.p16),

              // Error message
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 14,
                    ),
                  ),
                ),

              const SizedBox(height: AppDimensions.p24),

              if (_otpSent)
                SlgButton(
                  text: 'VERIFY & CONTINUE',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? () {} : _verifyOtp,
                ),
              const SizedBox(height: AppDimensions.p24),

              // Resend OTP
              if (_otpSent)
                Center(
                  child: _resendSeconds > 0
                      ? Text(
                          'Resend code in ${_resendSeconds}s',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        )
                      : TextButton(
                          onPressed: _isResending ? null : _resendOtp,
                          child: _isResending
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.goldPrimary,
                                  ),
                                )
                              : const Text(
                                  'Resend OTP',
                                  style: TextStyle(
                                    color: AppColors.goldDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                ),
              const SizedBox(height: AppDimensions.p16),

              // Change email
              Center(
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: const Text(
                    'Change Email',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.p24),
            ],
          ),
        ),
      ),
    );
  }
}
