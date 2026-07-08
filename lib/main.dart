import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:convex_flutter/convex_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'core/constants/convex_env.dart';
import 'core/convex_launch_state.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'data/datasources/convex_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    usePathUrlStrategy();
  }

  ConvexLaunchState.initError = null;
  ConvexLaunchState.isReady = false;

  if (ConvexEnv.isDeploymentConfigured) {
    try {
      await ConvexClient.initialize(
        ConvexConfig(
          deploymentUrl: ConvexEnv.deploymentUrl.trim(),
          clientId: 'slg-golds-flutter',
          healthCheckQuery: 'health:ping',
        ),
      );
      ConvexLaunchState.isReady = true;
    } catch (e, st) {
      debugPrint('ConvexClient.initialize failed: $e\n$st');
      ConvexLaunchState.initError = e.toString();
      ConvexLaunchState.isReady = false;
    }
  } else {
    debugPrint(
      'CONVEX_URL missing or invalid. Set --dart-define=CONVEX_URL=http://127.0.0.1:3210 for local Convex dev or use your https://<deployment>.convex.cloud URL.',
    );
  }

  // Initialize notifications service
  try {
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('NotificationService initialization failed: $e');
  }

  // Initialize Sentry error tracking
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://exampleKey@o0.ingest.sentry.io/0'; // Placeholder DSN
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(const ProviderScope(child: SlgGoldsApp())),
  );
}

class SlgGoldsApp extends StatelessWidget {
  const SlgGoldsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SLG Golds',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
