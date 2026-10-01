import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/models/user_profile.dart';

void main() {
  test('serializes and parses a user profile', () {
    final createdAt = DateTime.utc(2026, 10, 1);
    final profile = UserProfile(
      uid: 'user-1',
      name: 'Ana',
      email: 'ana@example.com',
      createdAt: createdAt,
    );

    final parsed = UserProfile.fromFirestore('user-1', <String, dynamic>{
      ...profile.toFirestore(),
      'createdAt': Timestamp.fromDate(createdAt),
    });

    expect(parsed.uid, 'user-1');
    expect(parsed.name, 'Ana');
    expect(parsed.email, 'ana@example.com');
    expect(parsed.createdAt.isAtSameMomentAs(createdAt), isTrue);
  });
}
