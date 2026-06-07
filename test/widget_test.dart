import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whistles_in_the_mist/main.dart';

void main() {
  testWidgets('shows onboarding for first-time users', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(ProviderScope(child: MyApp(preferences: prefs)));
    await tester.pumpAndSettle();

    expect(find.text('Open Signal Box'), findsOneWidget);
  });
}
