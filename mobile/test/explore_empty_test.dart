import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:borrow_dont_buy/state/app_state.dart';
import 'package:borrow_dont_buy/core/theme/app_theme.dart';
import 'package:borrow_dont_buy/ui/features/explore/explore_screen.dart';

void main() {
  testWidgets('Explore shows empty state for impossible query', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>(
        create: (_) => AppState(),
        child: MaterialApp(theme: buildAppTheme(), home: const ExploreScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'zzzznope12345');
    await tester.pumpAndSettle();
    expect(find.textContaining('Nothing matches'), findsOneWidget);
  });
}
