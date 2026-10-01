import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/models/time_record.dart';

void main() {
  test('serializes and parses a time record', () {
    final recordedAt = DateTime.utc(2026, 10, 1, 12);
    final record = TimeRecord(
      id: 'record-1',
      type: TimeRecordType.entrada,
      recordedAt: recordedAt,
      latitude: -23.5,
      longitude: -46.6,
      distanceMeters: 42,
    );

    final data = record.toFirestore();
    final parsed = TimeRecord.fromFirestore('record-1', <String, dynamic>{
      ...data,
      'recordedAt': Timestamp.fromDate(recordedAt),
    });

    expect(parsed.id, 'record-1');
    expect(parsed.type, TimeRecordType.entrada);
    expect(parsed.recordedAt.isAtSameMomentAs(recordedAt), isTrue);
    expect(parsed.latitude, -23.5);
    expect(parsed.longitude, -46.6);
    expect(parsed.distanceMeters, 42);
  });
}
