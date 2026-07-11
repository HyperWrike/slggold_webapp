import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/core/constants/app_dimensions.dart';
import 'package:slg_golds/presentation/providers/registration_provider.dart';
import 'package:slg_golds/presentation/widgets/slg_button.dart';
import 'package:slg_golds/presentation/widgets/slg_text_field.dart';

class RegistrationStep1Screen extends ConsumerStatefulWidget {
  const RegistrationStep1Screen({super.key});

  @override
  ConsumerState<RegistrationStep1Screen> createState() =>
      _RegistrationStep1ScreenState();
}

class _RegistrationStep1ScreenState
    extends ConsumerState<RegistrationStep1Screen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _birthPlaceController = TextEditingController();

  String? _selectedGender;
  int? _calculatedAge;

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _fatherNameController.dispose();
    _birthPlaceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.goldDark,
              onPrimary: AppColors.textWhite,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
        _calculatedAge = DateTime.now().year - picked.year;
        if (DateTime.now().month < picked.month ||
            (DateTime.now().month == picked.month &&
                DateTime.now().day < picked.day)) {
          _calculatedAge = _calculatedAge! - 1;
        }
      });
    }
  }

  void _onNext() {
    if (_formKey.currentState!.validate() && _selectedGender != null) {
      // Save data to provider
      ref
          .read(registrationProvider.notifier)
          .updateStep1(
            fullName: _nameController.text,
            dob: _dobController.text,
            gender: _selectedGender,
            fatherName: _fatherNameController.text,
            birthPlace: _birthPlaceController.text,
          );
      context.push('/onboarding/register/step2');
    } else if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your gender')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Details'),
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
                  children: List.generate(
                    4,
                    (index) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 4,
                        decoration: BoxDecoration(
                          color: index == 0
                              ? AppColors.goldPrimary
                              : AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.p32),

                Text(
                  'Let\'s get to know you',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: AppDimensions.p24),

                SlgTextField(
                  label: 'Full Name',
                  hint: 'As per Aadhaar',
                  controller: _nameController,
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: AppColors.goldPrimary,
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: AppDimensions.p20),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SlgTextField(
                        label: 'Date of Birth',
                        hint: 'YYYY-MM-DD',
                        controller: _dobController,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        prefixIcon: const Icon(
                          Icons.calendar_today,
                          color: AppColors.goldPrimary,
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                        suffixIcon: const Icon(
                          Icons.calendar_today,
                          color: AppColors.goldPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.p16),
                    Expanded(
                      flex: 1,
                      child: SlgTextField(
                        label: 'Age',
                        hint: _calculatedAge?.toString() ?? '--',
                        readOnly: true,
                        prefixIcon: const Icon(
                          Icons.cake_outlined,
                          color: AppColors.goldPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.p20),

                Text(
                  'GENDER',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.p8),
                Row(
                  children: [
                    _buildGenderButton('Male'),
                    const SizedBox(width: AppDimensions.p12),
                    _buildGenderButton('Female'),
                    const SizedBox(width: AppDimensions.p12),
                    _buildGenderButton('Other'),
                  ],
                ),
                const SizedBox(height: AppDimensions.p20),

                SlgTextField(
                  label: 'Father\'s / Husband\'s Name',
                  hint: 'Enter name',
                  controller: _fatherNameController,
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: AppColors.goldPrimary,
                  ),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppDimensions.p20),

                SlgTextField(
                  label: 'Place of Birth',
                  hint: 'City / Town',
                  controller: _birthPlaceController,
                  prefixIcon: const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.goldPrimary,
                  ),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppDimensions.p48),

                SlgButton(text: 'NEXT STEP', onPressed: _onNext),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderButton(String gender) {
    final isSelected = _selectedGender == gender;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedGender = gender;
          });
        },
        borderRadius: BorderRadius.circular(AppDimensions.r12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.goldPrimary.withAlpha(20)
                : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppDimensions.r12),
            border: Border.all(
              color: isSelected
                  ? AppColors.goldPrimary
                  : AppColors.surfaceContainerHigh,
              width: isSelected ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            gender,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: isSelected ? AppColors.goldDark : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
