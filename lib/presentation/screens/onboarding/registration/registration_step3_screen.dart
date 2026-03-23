import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/core/constants/app_dimensions.dart';
import 'package:slg_golds/presentation/widgets/slg_button.dart';
import 'package:slg_golds/presentation/widgets/slg_text_field.dart';

class RegistrationStep3Screen extends StatefulWidget {
  const RegistrationStep3Screen({super.key});

  @override
  State<RegistrationStep3Screen> createState() => _RegistrationStep3ScreenState();
}

class _RegistrationStep3ScreenState extends State<RegistrationStep3Screen> {
  final _formKey = GlobalKey<FormState>();
  final _nomineeNameController = TextEditingController();
  final _nomineeRelationshipController = TextEditingController();

  final List<String> _relationships = ['Spouse', 'Child', 'Parent', 'Sibling', 'Other'];

  @override
  void dispose() {
    _nomineeNameController.dispose();
    _nomineeRelationshipController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_formKey.currentState!.validate() && _nomineeRelationshipController.text.isNotEmpty) {
      context.push('/onboarding/register/step4'); // Route to be defined
    } else if (_nomineeRelationshipController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a relationship')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nominee Details'),
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
                        color: index <= 2 ? AppColors.goldPrimary : AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  )),
                ),
                const SizedBox(height: AppDimensions.p32),
                
                Text(
                  'Secure your legacy',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: AppDimensions.p8),
                Text(
                  'Add a nominee for your gold savings',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppDimensions.p32),
                
                SlgTextField(
                  label: 'Nominee Full Name',
                  hint: 'Enter nominee name',
                  controller: _nomineeNameController,
                  validator: (value) => value!.isEmpty ? 'Nominee name is required' : null,
                ),
                const SizedBox(height: AppDimensions.p24),
                
                Text(
                  'RELATIONSHIP',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.p8),
                
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _relationships.map((rel) => _buildRelationshipChip(rel)).toList(),
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

  Widget _buildRelationshipChip(String relationship) {
    final isSelected = _nomineeRelationshipController.text == relationship;
    return InkWell(
      onTap: () {
        setState(() {
          _nomineeRelationshipController.text = relationship;
        });
      },
      borderRadius: BorderRadius.circular(AppDimensions.r100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.goldPrimary.withAlpha(20) : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppDimensions.r100),
          border: Border.all(
            color: isSelected ? AppColors.goldPrimary : AppColors.surfaceContainerHigh,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          relationship,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: isSelected ? AppColors.goldDark : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
