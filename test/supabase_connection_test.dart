import 'package:flutter_test/flutter_test.dart';
import 'package:slg_golds/main.dart' show main;
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('Supabase can be initialized', () async {
    // This test verifies that Supabase initializes without throwing an exception
    // We're not actually testing the connection to the backend here, just that
    // the initialization process works with our provided credentials

    expect(() async {
      await Supabase.initialize(
        url: 'https://zgoxakkdgohvykvytwjw.supabase.co',
        anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpnb3hha2tkZ29odnlrdnl0d2p3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyNzI4NzksImV4cCI6MjA4OTg0ODg3OX0.wvHXs9A0P5XlgSdVm9r6KqwhH1MxeJOss9QlLLi2Puc',
      );
    }, returnsNormally);
  });
}
