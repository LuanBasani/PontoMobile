import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/services/record_input_validator.dart';

void main() {
  test('accepts valid coordinates and an allowed distance', () {
    expect(
      RecordInputValidator.validate(
        latitude: -23.5,
        longitude: -46.6,
        distanceMeters: 100,
      ),
      isNull,
    );
  });

  test('rejects invalid coordinates and distances over the work radius', () {
    expect(
      RecordInputValidator.validate(
        latitude: 91,
        longitude: -46.6,
        distanceMeters: 10,
      ),
      isNotNull,
    );
    expect(
      RecordInputValidator.validate(
        latitude: -23.5,
        longitude: -46.6,
        distanceMeters: 100.01,
      ),
      isNotNull,
    );
  });
}
