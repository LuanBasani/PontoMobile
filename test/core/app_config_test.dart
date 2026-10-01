import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/core/constants/app_config.dart';

void main() {
  group('AppConfig', () {
    test('uses the fixed SENAI Americana coordinates', () {
      const config = AppConfig();

      expect(config.workplaceConfigured, isTrue);
      expect(config.workLatitude, -22.7538572);
      expect(config.workLongitude, -47.3513785);
    });
  });
}
