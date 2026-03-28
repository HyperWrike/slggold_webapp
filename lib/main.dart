import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use HTML renderer for web (faster than CanvasKit)
  usePathUrlStrategy();

  await Supabase.initialize(
    url: 'https://zgoxakkdgohvykvytwjw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpnb3hha2tkZ29odnlrdnl0d2p3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyNzI4NzksImV4cCI6MjA4OTg0ODg3OX0.wvHXs9A0P5XlgSdVm9r6KqwhH1MxeJOss9QlLLi2Puc',
  );

  runApp(const ProviderScope(child: SlgGoldsApp()));
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
      // Use HTML renderer for web performance
      // Run with: flutter run -d chrome --web-renderer html
    );
  }
}
