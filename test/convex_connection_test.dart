import 'package:flutter_test/flutter_test.dart';
import 'package:convex_flutter/convex_flutter.dart';

void main() {
  test('ConvexConfig stores deployment URL', () {
    const url = 'https://example.convex.cloud';
    final config = ConvexConfig(deploymentUrl: url, clientId: 'unit-test');
    expect(config.deploymentUrl, url);
  });
}
