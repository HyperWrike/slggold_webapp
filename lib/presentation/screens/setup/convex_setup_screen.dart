import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:slg_golds/core/constants/app_colors.dart';
import 'package:slg_golds/core/convex_launch_state.dart';

/// Shown when the app is run without a valid `CONVEX_URL` (see [ConvexEnv]).
class ConvexSetupScreen extends StatelessWidget {
  const ConvexSetupScreen({super.key});

  static const _runExample =
      'flutter run -d chrome --dart-define=CONVEX_URL=https://YOUR_DEPLOYMENT.convex.cloud';

  @override
  Widget build(BuildContext context) {
    final err = ConvexLaunchState.initError;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Icon(Icons.cloud_off_outlined, size: 56, color: AppColors.primary),
              const SizedBox(height: 20),
              Text(
                'Convex backend not configured',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This app needs your Convex deployment URL. The placeholder URL '
                'is not valid and will not connect.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              if (err != null && err.isNotEmpty) ...[
                const SizedBox(height: 16),
                Material(
                  color: AppColors.error.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      err,
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 28),
              Text(
                'Steps',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              _bullet(context, '1. Create a project at https://dashboard.convex.dev'),
              _bullet(context, '2. Run npx convex dev in this repo and link the project.'),
              _bullet(
                context,
                '3. Copy the deployment URL (https://….convex.cloud) or use http://127.0.0.1:3210 for local dev.',
              ),
              _bullet(
                context,
                '4. Run the app with --dart-define=CONVEX_URL= that URL, or leave it unset while Convex dev is running locally.',
              ),
              const SizedBox(height: 24),
              Text(
                'Example',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.textSecondary.withAlpha(40)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SelectableText(
                    _runExample,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                      const ClipboardData(text: _runExample),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard')),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copy example'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bullet(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: AppColors.primary, height: 1.45)),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
