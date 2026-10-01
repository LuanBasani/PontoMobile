import '../models/time_record.dart';

class AttendancePolicy {
  AttendancePolicy._();

  static const double allowedRadiusMeters = 100;

  static bool isWithinAllowedRadius(double distanceMeters) =>
      distanceMeters.isFinite &&
      distanceMeters >= 0 &&
      distanceMeters <= allowedRadiusMeters;
}

TimeRecordType nextRecordType(List<TimeRecord> records) {
  if (records.isEmpty) return TimeRecordType.entrada;

  final latest = records.reduce(
    (current, candidate) =>
        candidate.recordedAt.isAfter(current.recordedAt) ? candidate : current,
  );
  return latest.type == TimeRecordType.entrada
      ? TimeRecordType.saida
      : TimeRecordType.entrada;
}
