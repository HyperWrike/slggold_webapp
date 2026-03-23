import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/core/constants/app_dimensions.dart';
import 'package:slg_golds/presentation/widgets/slg_button.dart';
import 'package:slg_golds/presentation/widgets/slg_text_field.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      // Authenticate as Admin
      context.go('/admin/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Admin Portal'),
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
                const SizedBox(height: AppDimensions.p48),
                
                Icon(Icons.admin_panel_settings, size: 80, color: AppColors.goldPrimary),
                const SizedBox(height: AppDimensions.p24),
                
                Text(
                  'Admin Sign In',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: AppDimensions.p48),
                
                SlgTextField(
                  label: 'Admin Email',
                  hint: 'Enter admin email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value!.isEmpty ? 'Email is required' : null,
                ),
                const SizedBox(height: AppDimensions.p24),
                
                SlgTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: (value) => value!.isEmpty ? 'Password is required' : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: AppDimensions.p48),
                
                SlgButton(
                  text: 'SIGN IN TO ADMIN PORTAL',
                  onPressed: _onLogin,
                ),
                
                const SizedBox(height: AppDimensions.p24),
                TextButton(
                  onPressed: () {
                    context.go('/auth/login');
                  },
                  child: Text(
                    'Return to Customer Login',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
