class AuthErrorMapper {
  AuthErrorMapper._();

  static String messageFor(String code) => switch (code) {
    'invalid-email' => 'Informe um e-mail válido.',
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' => 'E-mail ou senha inválidos.',
    'user-disabled' =>
      'Esta conta está desativada. Entre em contato com o suporte.',
    'email-already-in-use' => 'Este e-mail já está cadastrado.',
    'weak-password' => 'Escolha uma senha com pelo menos 6 caracteres.',
    'operation-not-allowed' =>
      'O cadastro por e-mail ainda não está habilitado.',
    'too-many-requests' =>
      'Muitas tentativas. Aguarde um pouco e tente novamente.',
    'network-request-failed' =>
      'Sem conexão. Verifique a internet e tente novamente.',
    _ => 'Não foi possível autenticar. Tente novamente.',
  };
}
