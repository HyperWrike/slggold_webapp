import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/core/constants/app_dimensions.dart';
import 'package:slg_golds/presentation/widgets/slg_button.dart';
import 'package:slg_golds/presentation/widgets/slg_text_field.dart';

class AdminCreateSchemeScreen extends StatefulWidget {
  const AdminCreateSchemeScreen({super.key});

  @override
  State<AdminCreateSchemeScreen> createState() => _AdminCreateSchemeScreenState();
}

class _AdminCreateSchemeScreenState extends State<AdminCreateSchemeScreen> {
  final _titleController = TextEditingController();
  final _monthsController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _monthsController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Create New Scheme'),
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
              SlgTextField(
                label: 'Scheme Name',
                hint: 'e.g., Gold Plus Plan',
                controller: _titleController,
              ),
              const SizedBox(height: AppDimensions.p24),
              SlgTextField(
                label: 'Duration (Months)',
                hint: 'e.g., 11',
                controller: _monthsController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppDimensions.p24),
              SlgTextField(
                label: 'Description',
                hint: 'Enter scheme details...',
                controller: _descController,
                maxLines: 4,
              ),
              const SizedBox(height: AppDimensions.p48),
              SlgButton(
                text: 'SAVE SCHEME',
                onPressed: () {
                  context.pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
