import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/core/constants/app_dimensions.dart';
import 'package:slg_golds/presentation/widgets/slg_button.dart';
import 'package:slg_golds/presentation/widgets/slg_text_field.dart';

class RegistrationStep2Screen extends StatefulWidget {
  const RegistrationStep2Screen({super.key});

  @override
  State<RegistrationStep2Screen> createState() => _RegistrationStep2ScreenState();
}

class _RegistrationStep2ScreenState extends State<RegistrationStep2Screen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _aadhaarController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_formKey.currentState!.validate()) {
      context.push('/onboarding/register/step3'); // Route to be defined
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact & ID'),
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
                        color: index <= 1 ? AppColors.goldPrimary : AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  )),
                ),
                const SizedBox(height: AppDimensions.p32),
                
                Text(
                  'How can we reach you?',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: AppDimensions.p24),
                
                SlgTextField(
                  label: 'Residential Address',
                  hint: 'Enter full address',
                  controller: _addressController,
                  validator: (value) => value!.isEmpty ? 'Address is required' : null,
                ),
                const SizedBox(height: AppDimensions.p20),
                
                SlgTextField(
                  label: 'Aadhaar Number',
                  hint: '12-digit Aadhaar Number',
                  controller: _aadhaarController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Aadhaar is required';
                    if (value.length != 12) return 'Aadhaar must be 12 digits';
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.p20),
                
                SlgTextField(
                  label: 'Mobile Number',
                  hint: '10-digit Mobile Number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('+91', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Phone number is required';
                    if (value.length != 10) return 'Must be 10 digits';
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
                        text: 'NEXT STEP',
                        onPressed: _onNext,
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
