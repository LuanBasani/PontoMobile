import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/core/attendance_policy.dart';
import 'package:ponto_mobile/models/time_record.dart';

void main() {
  group('AttendancePolicy', () {
    test('allows a distance of exactly 100 meters', () {
      expect(AttendancePolicy.isWithinAllowedRadius(100), isTrue);
    });

    test('blocks a distance greater than 100 meters', () {
      expect(AttendancePolicy.isWithinAllowedRadius(100.01), isFalse);
    });

    test('blocks negative and non-finite distances', () {
      expect(AttendancePolicy.isWithinAllowedRadius(-1), isFalse);
      expect(AttendancePolicy.isWithinAllowedRadius(double.infinity), isFalse);
      expect(AttendancePolicy.isWithinAllowedRadius(double.nan), isFalse);
    });
  });

  group('nextRecordType', () {
    test('starts with entrada when there are no records', () {
      expect(nextRecordType(const []), TimeRecordType.entrada);
    });

    test('alternates from the newest record', () {
      final latest = TimeRecord(
        id: '1',
        type: TimeRecordType.entrada,
        recordedAt: DateTime(2026),
        latitude: 0,
        longitude: 0,
        distanceMeters: 12,
      );

      expect(nextRecordType([latest]), TimeRecordType.saida);
    });
  });
}
