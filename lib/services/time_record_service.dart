import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/time_record.dart';
import 'firestore_paths.dart';
import 'record_input_validator.dart';

abstract interface class TimeRecordRepository {
  Stream<List<TimeRecord>> watchRecords(String uid);
  Future<void> addRecord(String uid, TimeRecord record);
}

class TimeRecordService implements TimeRecordRepository {
  TimeRecordService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<TimeRecord>> watchRecords(String uid) => _firestore
      .collection(FirestorePaths.userRecords(uid))
      .orderBy('recordedAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) {
              final data = Map<String, dynamic>.from(doc.data());
              if (data['recordedAt'] == null && doc.metadata.hasPendingWrites) {
                data['recordedAt'] = DateTime.now();
              }
              return TimeRecord.fromFirestore(doc.id, data);
            })
            .toList(growable: false),
      );

  @override
  Future<void> addRecord(String uid, TimeRecord record) async {
    final validationMessage = RecordInputValidator.validate(
      latitude: record.latitude,
      longitude: record.longitude,
      distanceMeters: record.distanceMeters,
    );
    if (validationMessage != null) {
      throw ArgumentError(validationMessage);
    }

    final data = record.toFirestore()
      ..['recordedAt'] = FieldValue.serverTimestamp();
    await _firestore
        .collection(FirestorePaths.userRecords(uid))
        .doc(record.id)
        .set(data);
  }
}
