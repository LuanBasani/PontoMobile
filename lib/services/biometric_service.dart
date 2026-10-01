import 'package:local_auth/local_auth.dart';

abstract interface class BiometricAuthenticator {
  Future<bool> isBiometricAvailable();
  Future<bool> authenticate();
}

class BiometricService implements BiometricAuthenticator {
  BiometricService({LocalAuthentication? authentication})
    : _authentication = authentication ?? LocalAuthentication();

  final LocalAuthentication _authentication;

  @override
  Future<bool> isBiometricAvailable() async {
    try {
      if (!await _authentication.isDeviceSupported() ||
          !await _authentication.canCheckBiometrics) {
        return false;
      }
      return (await _authentication.getAvailableBiometrics()).isNotEmpty;
    } on LocalAuthException {
      return false;
    } on Exception {
      return false;
    }
  }

  @override
  Future<bool> authenticate() async {
    if (!await isBiometricAvailable()) {
      throw const BiometricException(
        'Não há biometria configurada neste dispositivo.',
      );
    }

    try {
      return await _authentication.authenticate(
        localizedReason: 'Confirme sua identidade para acessar o PontoMobile.',
        biometricOnly: true,
      );
    } on LocalAuthException catch (error) {
      if (error.code == LocalAuthExceptionCode.userCanceled) return false;
      throw const BiometricException(
        'Não foi possível validar a biometria. Use sua senha para continuar.',
      );
    } on Exception {
      throw const BiometricException(
        'A biometria está indisponível. Use sua senha para continuar.',
      );
    }
  }
}

class BiometricException implements Exception {
  const BiometricException(this.message);

  final String message;

  @override
  String toString() => message;
}
