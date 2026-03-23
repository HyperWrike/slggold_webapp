import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/core/constants/app_dimensions.dart';
import 'package:slg_golds/presentation/widgets/slg_button.dart';
import 'package:slg_golds/presentation/widgets/slg_text_field.dart';

class AdminGstScreen extends StatefulWidget {
  const AdminGstScreen({super.key});

  @override
  State<AdminGstScreen> createState() => _AdminGstScreenState();
}

class _AdminGstScreenState extends State<AdminGstScreen> {
  final _goldGstController = TextEditingController(text: '3.0');
  final _silverGstController = TextEditingController(text: '3.0');
  final _makingChargesGstController = TextEditingController(text: '5.0');

  @override
  void dispose() {
    _goldGstController.dispose();
    _silverGstController.dispose();
    _makingChargesGstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('GST Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.p24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.p16),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppDimensions.r8),
                  border: Border.all(color: AppColors.error),
                ),
                child: const Text('Warning: Changing GST rates will affect all future transactions and metal purchases. Past transactions remain unaffected.'),
              ),
              const SizedBox(height: AppDimensions.p32),
              
              SlgTextField(
                label: 'Gold GST / Cess (%)',
                hint: 'e.g., 3.0',
                controller: _goldGstController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: AppDimensions.p24),
              SlgTextField(
                label: 'Silver GST / Cess (%)',
                hint: 'e.g., 3.0',
                controller: _silverGstController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: AppDimensions.p24),
              SlgTextField(
                label: 'Making Charges GST (%)',
                hint: 'e.g., 5.0',
                controller: _makingChargesGstController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              
              const SizedBox(height: AppDimensions.p48),
              SlgButton(
                text: 'UPDATE GST RATES',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('GST Rates updated successfully!')));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
