import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/services/firestore_paths.dart';

void main() {
  test('builds paths scoped to the supplied authenticated UID', () {
    expect(FirestorePaths.userProfile('user-123'), 'users/user-123');
    expect(FirestorePaths.userRecords('user-123'), 'users/user-123/records');
  });

  test('rejects empty user identifiers', () {
    expect(() => FirestorePaths.userProfile(''), throwsArgumentError);
  });
}
