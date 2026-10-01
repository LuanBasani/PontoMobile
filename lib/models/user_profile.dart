import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
    this.biometricEnabled = false,
  });

  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;
  final bool biometricEnabled;

  Map<String, dynamic> toFirestore() => <String, dynamic>{
    'name': name,
    'email': email,
    'createdAt': Timestamp.fromDate(createdAt),
    'biometricEnabled': biometricEnabled,
  };

  factory UserProfile.fromFirestore(String uid, Map<String, dynamic> data) {
    final createdAt = data['createdAt'];
    return UserProfile(
      uid: uid,
      name: data['name'] as String,
      email: data['email'] as String,
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : (createdAt as DateTime),
      biometricEnabled: data['biometricEnabled'] as bool? ?? false,
    );
  }
}
