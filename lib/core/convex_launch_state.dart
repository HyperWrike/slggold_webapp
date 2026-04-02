/// Set in [main] after a successful [ConvexClient.initialize], or false when
/// no valid deployment URL was provided (app shows [ConvexSetupScreen]).
class ConvexLaunchState {
  ConvexLaunchState._();

  static bool isReady = false;

  /// Last init error message for the setup screen (optional).
  static String? initError;
}
