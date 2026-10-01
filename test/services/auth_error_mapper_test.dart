import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/services/auth_error_mapper.dart';

void main() {
  test('maps invalid credentials to a safe user-facing message', () {
    expect(
      AuthErrorMapper.messageFor('invalid-credential'),
      'E-mail ou senha inválidos.',
    );
  });

  test('maps registration errors to friendly messages', () {
    expect(
      AuthErrorMapper.messageFor('email-already-in-use'),
      'Este e-mail já está cadastrado.',
    );
    expect(
      AuthErrorMapper.messageFor('weak-password'),
      'Escolha uma senha com pelo menos 6 caracteres.',
    );
  });

  test('hides unknown technical details', () {
    expect(
      AuthErrorMapper.messageFor('some-internal-error'),
      'Não foi possível autenticar. Tente novamente.',
    );
  });
}
