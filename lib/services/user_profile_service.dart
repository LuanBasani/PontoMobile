import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';
import 'firestore_paths.dart';

abstract interface class UserProfileRepository {
  Stream<UserProfile?> watchProfile(String uid);
  Future<void> setBiometricEnabled(String uid, bool enabled);
}

class UserProfileService implements UserProfileRepository {
  UserProfileService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<UserProfile?> watchProfile(String uid) => _firestore
      .doc(FirestorePaths.userProfile(uid))
      .snapshots()
      .map((snapshot) {
        final data = snapshot.data();
        if (data == null) return null;
        final normalized = Map<String, dynamic>.from(data);
        if (normalized['createdAt'] == null &&
            snapshot.metadata.hasPendingWrites) {
          normalized['createdAt'] = DateTime.now();
        }
        return UserProfile.fromFirestore(uid, normalized);
      });

  @override
  Future<void> setBiometricEnabled(String uid, bool enabled) => _firestore
      .doc(FirestorePaths.userProfile(uid))
      .update(<String, dynamic>{'biometricEnabled': enabled});
}
