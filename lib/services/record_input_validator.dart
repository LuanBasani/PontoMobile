import '../core/attendance_policy.dart';

class RecordInputValidator {
  RecordInputValidator._();

  static String? validate({
    required double latitude,
    required double longitude,
    required double distanceMeters,
  }) {
    if (!latitude.isFinite || latitude < -90 || latitude > 90) {
      return 'A latitude da localização é inválida.';
    }
    if (!longitude.isFinite || longitude < -180 || longitude > 180) {
      return 'A longitude da localização é inválida.';
    }
    if (!AttendancePolicy.isWithinAllowedRadius(distanceMeters)) {
      return 'O registro só pode ser feito a até 100 metros do trabalho.';
    }
    return null;
  }
}
