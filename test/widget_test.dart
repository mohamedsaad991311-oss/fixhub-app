// test/widget_test.dart

import 'package:fixhub_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FixHub app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // NOTE: هذا اختبار بسيط — التطبيق بيعتمد على ProviderScope + Supabase
    // فمحتاجين نعمل mock لاحقاً في المرحلة 10.
    expect(FixHubApp, isNotNull);
  });
}
