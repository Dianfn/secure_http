import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:secure_http/main.dart';

void main() {
  testWidgets('error validasi hilang saat input diperbaiki', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Secure Login'), findsOneWidget);

    final emailField = find.byType(TextFormField).at(0);
    final passwordField = find.byType(TextFormField).at(1);

    await tester.enterText(emailField, 'dasda');
    await tester.enterText(passwordField, 'dsa');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Format email tidak valid.'), findsOneWidget);
    expect(find.text('Password minimal 6 karakter.'), findsOneWidget);

    final emailTextField = tester.widget<TextField>(
      find.byType(TextField).at(0),
    );
    expect(emailTextField.focusNode!.hasFocus, isTrue);

    await tester.enterText(emailField, 'user@example.com');
    await tester.pumpAndSettle();
    expect(find.text('Format email tidak valid.'), findsNothing);

    await tester.enterText(passwordField, 'secret123');
    await tester.pumpAndSettle();
    expect(find.text('Password minimal 6 karakter.'), findsNothing);

    expect(
      tester.widget<TextFormField>(emailField).controller!.text,
      'user@example.com',
    );
  });
}
