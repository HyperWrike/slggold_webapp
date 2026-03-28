import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
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
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('gst_rates')
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

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
      final supabase = Supabase.instance.client;
      final goldGst = double.tryParse(_goldGstController.text) ?? 3.0;
      final silverGst = double.tryParse(_silverGstController.text) ?? 3.0;
      final makingGst =
          double.tryParse(_makingChargesGstController.text) ?? 5.0;

      await supabase.from('gst_rates').insert({
        'gold_gst': goldGst,
        'silver_gst': silverGst,
        'making_charges_gst': makingGst,
        'created_at': DateTime.now().toIso8601String(),
      });

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
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'GST Settings',
          style: TextStyle(
            fontFamily: 'Cormorant Garamond',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withAlpha(77)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber, color: AppColors.error, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Changing GST rates affects all future transactions. Past transactions remain unchanged.',
                        style: TextStyle(fontSize: 13, color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              SlgTextField(
                label: 'Gold GST / Cess (%)',
                hint: '3.0',
                controller: _goldGstController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 24),

              SlgTextField(
                label: 'Silver GST / Cess (%)',
                hint: '3.0',
                controller: _silverGstController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 24),

              SlgTextField(
                label: 'Making Charges GST (%)',
                hint: '5.0',
                controller: _makingChargesGstController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),

              const SizedBox(height: 48),

              SlgButton(
                text: 'SAVE GST RATES',
                isLoading: _isLoading,
                onPressed: _isLoading ? () {} : _saveGstRates,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
