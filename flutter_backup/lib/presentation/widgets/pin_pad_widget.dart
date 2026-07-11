import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

class PinPadWidget extends StatelessWidget {
  final Function(String) onDigitPressed;
  final VoidCallback onBackspacePressed;
  final VoidCallback? onBiometricPressed;
  final bool showBiometric;

  const PinPadWidget({
    super.key,
    required this.onDigitPressed,
    required this.onBackspacePressed,
    this.onBiometricPressed,
    this.showBiometric = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(context, ['1', '2', '3']),
        const SizedBox(height: AppDimensions.p24),
        _buildRow(context, ['4', '5', '6']),
        const SizedBox(height: AppDimensions.p24),
        _buildRow(context, ['7', '8', '9']),
        const SizedBox(height: AppDimensions.p24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              context,
              icon: showBiometric ? Icons.fingerprint : null,
              onPressed: showBiometric ? onBiometricPressed : null,
            ),
            _buildDigitButton(context, '0'),
            _buildActionButton(
              context,
              icon: Icons.backspace_outlined,
              onPressed: onBackspacePressed,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((digit) => _buildDigitButton(context, digit)).toList(),
    );
  }

  Widget _buildDigitButton(BuildContext context, String digit) {
    return _PinButton(
      child: Text(
        digit,
        style: Theme.of(context).textTheme.displaySmall?.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      onPressed: () => onDigitPressed(digit),
    );
  }

  Widget _buildActionButton(BuildContext context, {IconData? icon, VoidCallback? onPressed}) {
    if (icon == null) return const SizedBox(width: 72, height: 72);
    
    return _PinButton(
      onPressed: onPressed ?? () {},
      child: Icon(
        icon,
        size: 32,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _PinButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;

  const _PinButton({required this.child, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceContainerLowest,
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
