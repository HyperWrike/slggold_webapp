import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../data/datasources/database_service.dart';

class PaymentHandler {
  static Future<void> startPayment({
    required BuildContext context,
    required DatabaseService db,
    required Map<String, dynamic> orderData,
    required String userPhone,
    required String userEmail,
    required VoidCallback onSuccess,
    required ValueChanged<String> onFailure,
  }) async {
    final isMock = orderData['isMock'] == true;
    final amount = (orderData['amount'] as num).toDouble();
    final orderId = orderData['orderId'] as String;
    final key = orderData['key'] as String;

    if (isMock && kDebugMode) {
      // Launch premium custom simulated sandbox sheet
      if (!context.mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _MockPaymentSimulator(
          amount: amount,
          orderId: orderId,
          db: db,
          onSuccess: onSuccess,
          onFailure: onFailure,
        ),
      );
    } else {
      // Initialize Razorpay SDK
      final razorpay = Razorpay();

      void handleSuccess(PaymentSuccessResponse response) async {
        razorpay.clear();
        _showLoadingOverlay(context);

        try {
          final success = await db.verifyRazorpayPayment(
            orderId: orderId,
            paymentId: response.paymentId ?? 'pay_dummy',
            signature: response.signature ?? 'sig_dummy',
          );

          if (context.mounted) Navigator.of(context).pop(); // Close overlay

          if (success) {
            onSuccess();
          } else {
            onFailure('Payment signature verification failed on server.');
          }
        } catch (e) {
          if (context.mounted) Navigator.of(context).pop();
          onFailure('Error during payment verification: $e');
        }
      }

      void handleFailure(PaymentFailureResponse response) {
        razorpay.clear();
        onFailure(response.message ?? 'Payment cancelled or failed.');
      }

      void handleWallet(ExternalWalletResponse response) {
        razorpay.clear();
        onFailure('External wallet payments are not supported.');
      }

      razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handleSuccess);
      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handleFailure);
      razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleWallet);

      final options = {
        'key': key,
        'amount': (amount * 100).round(), // Amount in paise
        'name': 'SLG Golds',
        'description': 'Scheme Installment Payment',
        'order_id': orderId,
        'prefill': {
          'contact': userPhone.isNotEmpty ? userPhone : '9999999999',
          'email': userEmail.isNotEmpty ? userEmail : 'customer@example.com',
        },
        'theme': {
          'color': '#C8860A',
        }
      };

      try {
        razorpay.open(options);
      } catch (e) {
        razorpay.clear();
        onFailure('Failed to open Razorpay SDK: $e');
      }
    }
  }

  static void _showLoadingOverlay(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(220),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withAlpha(50)),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Verifying Payment...',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MockPaymentSimulator extends StatefulWidget {
  final double amount;
  final String orderId;
  final DatabaseService db;
  final VoidCallback onSuccess;
  final ValueChanged<String> onFailure;

  const _MockPaymentSimulator({
    required this.amount,
    required this.orderId,
    required this.db,
    required this.onSuccess,
    required this.onFailure,
  });

  @override
  State<_MockPaymentSimulator> createState() => _MockPaymentSimulatorState();
}

class _MockPaymentSimulatorState extends State<_MockPaymentSimulator> {
  bool _isProcessing = false;
  String? _statusText;
  double _goldGstRate = 3.0;

  @override
  void initState() {
    super.initState();
    _loadGst();
  }

  Future<void> _loadGst() async {
    try {
      final rates = await widget.db.getLatestGstRates();
      if (rates != null && mounted) {
        setState(() {
          _goldGstRate = (rates['gold_gst'] as num?)?.toDouble() ?? 3.0;
        });
      }
    } catch (_) {}
  }

  Future<void> _simulateSuccess() async {
    setState(() {
      _isProcessing = true;
      _statusText = 'Contacting secure server...';
    });

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() {
      _statusText = 'Verifying signature tokens...';
    });

    try {
      final success = await widget.db.verifyRazorpayPayment(
        orderId: widget.orderId,
        paymentId: 'pay_mock_' + DateTime.now().millisecondsSinceEpoch.toString(),
        signature: 'sig_mock_' + DateTime.now().millisecondsSinceEpoch.toString(),
      );

      if (!mounted) return;

      if (success) {
        setState(() {
          _statusText = 'Payment Successful!';
        });
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).pop(); // Close sheet
          widget.onSuccess();
        }
      } else {
        setState(() {
          _isProcessing = false;
          _statusText = null;
        });
        widget.onFailure('Verification failed on the mock server.');
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusText = null;
      });
      widget.onFailure('Simulation error: $e');
    }
  }

  void _simulateFailure() {
    Navigator.of(context).pop();
    widget.onFailure('Simulator: User cancelled payment.');
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);
    final netAmount = widget.amount / (1 + _goldGstRate / 100);
    final gstAmount = widget.amount - netAmount;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xE81C1917), // Sleek warm dark gray background
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x66F5C842),
              blurRadius: 40,
              offset: Offset(0, -5),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: _isProcessing
            ? Container(
                height: 380,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _statusText ?? 'Processing Transaction...',
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SLG SECURE PAY',
                            style: TextStyle(
                              fontFamily: 'Cormorant Garamond',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              letterSpacing: 1.2,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          Text(
                            'Simulated Sandbox Gateway',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary.withAlpha(100)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'TEST MODE',
                          style: TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Interactive Premium Gold Card Mockup
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFEab308), // vibrant yellow-gold
                          Color(0xFFca8a04), // darker mustard-gold
                          Color(0xFF854d0e), // deep brown-gold
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFca8a04).withAlpha(100),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'SLG GOLD CARD',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1.5,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            Icon(
                              Icons.nfc,
                              color: Colors.white.withAlpha(200),
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '••••  ••••  ••••  7777',
                          style: TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CARDHOLDER',
                                  style: TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 8,
                                    color: Colors.white.withAlpha(150),
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'VALUED CUSTOMER',
                                  style: TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'EXPIRES',
                                  style: TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 8,
                                    color: Colors.white.withAlpha(150),
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  '12/30',
                                  style: TextStyle(
                                    fontFamily: 'DM Mono',
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Billing Details Breakout
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withAlpha(15)),
                    ),
                    child: Column(
                      children: [
                        _buildRow('Base Installment', formatCurrency.format(netAmount)),
                        const SizedBox(height: 10),
                        _buildRow('GST (${_goldGstRate.toStringAsFixed(1)}%)', formatCurrency.format(gstAmount)),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(color: Colors.white12, height: 1),
                        ),
                        _buildRow(
                          'Total Amount Due',
                          formatCurrency.format(widget.amount),
                          isBold: true,
                          highlightColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Action Buttons
                  ElevatedButton(
                    onPressed: _simulateSuccess,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      'SUCCESSFUL PAYMENT (${formatCurrency.format(widget.amount)})',
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _simulateFailure,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'SIMULATE FAILED PAYMENT',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    bool isBold = false,
    Color? highlightColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: isBold ? 13 : 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.white70,
            decoration: TextDecoration.none,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'DM Mono',
            fontSize: isBold ? 14 : 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: highlightColor ?? Colors.white,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}
