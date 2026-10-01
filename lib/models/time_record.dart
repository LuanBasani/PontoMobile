import 'package:cloud_firestore/cloud_firestore.dart';

enum TimeRecordType { entrada, saida }

class TimeRecord {
  const TimeRecord({
    required this.id,
    required this.type,
    required this.recordedAt,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
  });

  final String id;
  final TimeRecordType type;
  final DateTime recordedAt;
  final double latitude;
  final double longitude;
  final double distanceMeters;

  Map<String, dynamic> toFirestore() => <String, dynamic>{
    'type': type.name,
    'recordedAt': Timestamp.fromDate(recordedAt),
    'latitude': latitude,
    'longitude': longitude,
    'distanceMeters': distanceMeters,
  };

  factory TimeRecord.fromFirestore(String id, Map<String, dynamic> data) {
    final timestamp = data['recordedAt'];
    return TimeRecord(
      id: id,
      type: TimeRecordType.values.byName(data['type'] as String),
      recordedAt: timestamp is Timestamp
          ? timestamp.toDate()
          : (timestamp as DateTime),
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      distanceMeters: (data['distanceMeters'] as num).toDouble(),
    );
  }
}
