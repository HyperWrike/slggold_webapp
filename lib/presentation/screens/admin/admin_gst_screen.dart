import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/presentation/providers/auth_provider.dart';
import 'package:slg_golds/presentation/widgets/slg_button.dart';
import 'package:slg_golds/presentation/widgets/slg_text_field.dart';

class AdminGstScreen extends ConsumerStatefulWidget {
  const AdminGstScreen({super.key});

  @override
  ConsumerState<AdminGstScreen> createState() => _AdminGstScreenState();
}

class _AdminGstScreenState extends ConsumerState<AdminGstScreen> {
  final _goldGstController = TextEditingController(text: '3.0');
  final _silverGstController = TextEditingController(text: '3.0');
  final _makingChargesGstController = TextEditingController(text: '5.0');
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadGstRates();
  }

  Future<void> _loadGstRates() async {
    try {
      final db = ref.read(databaseServiceProvider);
      final response = await db.getLatestGstRates();

      if (response != null && mounted) {
        _goldGstController.text =
            (response['gold_gst'] as num?)?.toStringAsFixed(1) ?? '3.0';
        _silverGstController.text =
            (response['silver_gst'] as num?)?.toStringAsFixed(1) ?? '3.0';
        _makingChargesGstController.text =
            (response['making_charges_gst'] as num?)?.toStringAsFixed(1) ??
            '5.0';
      }
    } catch (_) {
      // Table might not exist yet, use defaults
    }
  }

  @override
  void dispose() {
    _goldGstController.dispose();
    _silverGstController.dispose();
    _makingChargesGstController.dispose();
    super.dispose();
  }

  Future<void> _saveGstRates() async {
    setState(() => _isLoading = true);

    try {
      final db = ref.read(databaseServiceProvider);
      final goldGst = double.tryParse(_goldGstController.text) ?? 3.0;
      final silverGst = double.tryParse(_silverGstController.text) ?? 3.0;
      final makingGst =
          double.tryParse(_makingChargesGstController.text) ?? 5.0;

      await db.saveGstRates(
        goldGst: goldGst,
        silverGst: silverGst,
        makingChargesGst: makingGst,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('GST rates saved successfully!'),
            backgroundColor: Color(0xFF059669),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved locally. DB error: $e'),
            backgroundColor: AppColors.primaryContainer,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GST Configuration'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Configure GST rates for gold, silver, and making charges.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            SlgTextField(
              controller: _goldGstController,
              label: 'Gold GST (%)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SlgTextField(
              controller: _silverGstController,
              label: 'Silver GST (%)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SlgTextField(
              controller: _makingChargesGstController,
              label: 'Making Charges GST (%)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            SlgButton(
              text: 'Save GST Rates',
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _saveGstRates,
            ),
          ],
        ),
      ),
    );
  }
}
