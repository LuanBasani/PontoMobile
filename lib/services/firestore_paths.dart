class FirestorePaths {
  FirestorePaths._();

  static String userProfile(String uid) {
    _requireUid(uid);
    return 'users/$uid';
  }

  static String userRecords(String uid) {
    _requireUid(uid);
    return 'users/$uid/records';
  }

  static void _requireUid(String uid) {
    if (uid.trim().isEmpty || uid.contains('/')) {
      throw ArgumentError.value(
        uid,
        'uid',
        'A identificação do usuário é inválida.',
      );
    }
  }
}
