class FormValidators {
  FormValidators._();

  static String? name(String? value) =>
      value == null || value.trim().isEmpty ? 'Informe seu nome.' : null;

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    final valid = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
    return valid ? null : 'Informe um e-mail válido.';
  }

  static String? password(String? value) => (value?.length ?? 0) < 6
      ? 'A senha deve ter pelo menos 6 caracteres.'
      : null;

  static String? confirmPassword(String? value, String password) =>
      value == password ? null : 'As senhas não coincidem.';
}
