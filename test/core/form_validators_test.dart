import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/core/form_validators.dart';

void main() {
  group('FormValidators', () {
    test('requires a non-empty name', () {
      expect(FormValidators.name('  '), isNotNull);
      expect(FormValidators.name('Ana'), isNull);
    });

    test('validates email format', () {
      expect(FormValidators.email('ana@example.com'), isNull);
      expect(FormValidators.email('ana@'), isNotNull);
    });

    test('requires a password with at least six characters', () {
      expect(FormValidators.password('12345'), isNotNull);
      expect(FormValidators.password('123456'), isNull);
    });

    test('requires matching passwords', () {
      expect(FormValidators.confirmPassword('123456', '654321'), isNotNull);
      expect(FormValidators.confirmPassword('123456', '123456'), isNull);
    });
  });
}
