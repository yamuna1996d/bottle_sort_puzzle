import 'package:flutter_test/flutter_test.dart';
import 'package:bottle_sort_puzzle/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App smoke test', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BottleSortApp()));
    expect(find.byType(ProviderScope), findsOneWidget);
  });
}
