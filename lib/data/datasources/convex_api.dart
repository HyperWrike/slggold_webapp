import 'dart:convert';

import 'package:convex_flutter/convex_flutter.dart';

import '../../core/convex_launch_state.dart';

/// Thrown when Convex was not initialized (missing or invalid [CONVEX_URL]).
class ConvexNotConfiguredException implements Exception {
  @override
  String toString() =>
      'Convex is not configured. Set CONVEX_URL when running the app.';
}

void _ensureConvexReady() {
  if (!ConvexLaunchState.isReady) {
    throw ConvexNotConfiguredException();
  }
}

/// Removes null values so Convex does not receive unsupported null args.
Map<String, dynamic> convexArgs(Map<String, dynamic> args) {
  return Map<String, dynamic>.fromEntries(
    args.entries.where((e) => e.value != null),
  );
}

Future<dynamic> convexQuery(String name, Map<String, dynamic> args) async {
  _ensureConvexReady();
  final raw = await ConvexClient.instance.query(name, convexArgs(args));
  return jsonDecode(raw);
}

Future<dynamic> convexMutation(String name, Map<String, dynamic> args) async {
  _ensureConvexReady();
  try {
    final raw = await ConvexClient.instance.mutation(
      name: name,
      args: convexArgs(args),
    );
    return jsonDecode(raw);
  } on Exception catch (e) {
    if (e.toString().contains('No result in mutation response')) {
      // Server executed mutation successfully but returned no result
      return null;
    }
    rethrow;
  }
}

Future<dynamic> convexAction(String name, Map<String, dynamic> args) async {
  _ensureConvexReady();
  final raw = await ConvexClient.instance.action(
    name: name,
    args: convexArgs(args),
  );
  return jsonDecode(raw);
}
