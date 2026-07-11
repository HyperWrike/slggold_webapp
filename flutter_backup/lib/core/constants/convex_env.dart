/// Set at build time: `--dart-define=CONVEX_URL=https://your-deployment.convex.cloud`
class ConvexEnv {
  ConvexEnv._();

  static const String deploymentUrl = String.fromEnvironment(
    'CONVEX_URL',
  );

  /// True when [deploymentUrl] looks like a real Convex deployment URL.
  /// Accepts production deployments on `https://*.convex.cloud` / `*.convex.site`
  /// and local development endpoints on `http://localhost` / `127.0.0.1`.
  static bool get isDeploymentConfigured {
    final u = deploymentUrl.trim();
    if (u.isEmpty) return false;
    final lower = u.toLowerCase();
    if (lower.contains('placeholder')) return false;

    final uri = Uri.tryParse(u);
    if (uri == null) return false;

    final host = uri.host;
    if (host.isEmpty) return false;

    final isLocalHost =
        host == 'localhost' || host == '127.0.0.1' || host == '::1';
    if (isLocalHost) {
      return uri.scheme == 'http' || uri.scheme == 'https';
    }

    return uri.scheme == 'https' &&
        (host.endsWith('.convex.cloud') || host.endsWith('.convex.site'));
  }
}
