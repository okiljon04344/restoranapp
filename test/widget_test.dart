import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_universal_app/app/app.dart';

void main() {
  testWidgets('App initializes cleanly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RestaurantUniversalApp(),
      ),
    );
    expect(find.byType(RestaurantUniversalApp), findsOneWidget);
  });
}
