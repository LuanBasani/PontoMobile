import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ponto_mobile/app/app_services.dart';
import 'package:ponto_mobile/core/constants/app_config.dart';
import 'package:ponto_mobile/models/time_record.dart';
import 'package:ponto_mobile/models/user_profile.dart';
import 'package:ponto_mobile/screens/auth/auth_gate.dart';
import 'package:ponto_mobile/screens/auth/login_screen.dart';
import 'package:ponto_mobile/screens/auth/register_screen.dart';
import 'package:ponto_mobile/services/auth_service.dart';
import 'package:ponto_mobile/services/biometric_service.dart';
import 'package:ponto_mobile/services/location_service.dart';
import 'package:ponto_mobile/services/time_record_service.dart';
import 'package:ponto_mobile/services/user_profile_service.dart';

void main() {
  testWidgets('auth gate shows login when no user is signed in', (
    tester,
  ) async {
    final services = _FakeServices();

    await tester.pumpWidget(MaterialApp(home: AuthGate(services: services)));
    await tester.pumpAndSettle();

    expect(find.text('Bem-vindo de volta'), findsOneWidget);
  });

  testWidgets('auth gate requests biometrics for an enabled profile', (
    tester,
  ) async {
    final services = _FakeServices();
    final user = AuthUser(uid: 'user-1', email: 'ana@example.com');
    (services.auth as _FakeAuth).user = user;
    (services.profiles as _FakeProfiles).profile = UserProfile(
      uid: user.uid,
      name: 'Ana',
      email: user.email,
      createdAt: DateTime(2026),
      biometricEnabled: true,
    );

    await tester.pumpWidget(MaterialApp(home: AuthGate(services: services)));
    await tester.pumpAndSettle();

    expect((services.biometrics as _FakeBiometrics).authenticateCalls, 1);
    expect(find.text('Próximo registro'), findsOneWidget);
  });

  testWidgets('regular logout preserves the biometric preference', (
    tester,
  ) async {
    final services = _FakeServices();
    final user = AuthUser(uid: 'user-1', email: 'ana@example.com');
    (services.auth as _FakeAuth).user = user;
    (services.profiles as _FakeProfiles).profile = UserProfile(
      uid: user.uid,
      name: 'Ana',
      email: user.email,
      createdAt: DateTime(2026),
      biometricEnabled: true,
    );

    await tester.pumpWidget(MaterialApp(home: AuthGate(services: services)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sair da conta'));
    await tester.pumpAndSettle();

    expect((services.profiles as _FakeProfiles).biometricUpdates, isEmpty);
  });

  testWidgets('login rejects empty fields without calling Firebase', (
    tester,
  ) async {
    final services = _FakeServices();

    await tester.pumpWidget(MaterialApp(home: LoginScreen(services: services)));
    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.pump();

    expect(find.text('Informe um e-mail válido.'), findsOneWidget);
    expect(find.text('Informe sua senha.'), findsOneWidget);
    expect((services.auth as _FakeAuth).signInCalls, 0);
  });

  testWidgets('registration rejects mismatched passwords', (tester) async {
    final services = _FakeServices();

    await tester.pumpWidget(
      MaterialApp(home: RegisterScreen(services: services)),
    );
    await tester.enterText(find.byKey(const Key('register-name')), 'Ana');
    await tester.enterText(
      find.byKey(const Key('register-email')),
      'ana@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('register-password')),
      '123456',
    );
    await tester.enterText(
      find.byKey(const Key('register-confirm-password')),
      '654321',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Criar conta'));
    await tester.pump();

    expect(find.text('As senhas não coincidem.'), findsOneWidget);
    expect((services.auth as _FakeAuth).registerCalls, 0);
  });
}

class _FakeServices implements AppServices {
  @override
  final config = AppConfig();

  @override
  final auth = _FakeAuth();

  @override
  final profiles = _FakeProfiles();

  @override
  final biometrics = _FakeBiometrics();

  @override
  final locations = _FakeLocations();

  @override
  final records = _FakeRecords();
}

class _FakeAuth implements AuthRepository {
  int signInCalls = 0;
  int registerCalls = 0;
  AuthUser? user;

  @override
  Stream<AuthUser?> get authStateChanges => Stream<AuthUser?>.value(user);

  @override
  AuthUser? get currentUser => user;

  @override
  Future<AuthUser> signIn({required String email, required String password}) {
    signInCalls++;
    return Future<AuthUser>.error(StateError('not expected'));
  }

  @override
  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
  }) {
    registerCalls++;
    return Future<AuthUser>.error(StateError('not expected'));
  }

  @override
  Future<void> signOut() async {}
}

class _FakeProfiles implements UserProfileRepository {
  UserProfile? profile;
  final List<bool> biometricUpdates = <bool>[];

  @override
  Stream<UserProfile?> watchProfile(String uid) =>
      Stream<UserProfile?>.value(profile);

  @override
  Future<void> setBiometricEnabled(String uid, bool enabled) async {
    biometricUpdates.add(enabled);
  }
}

class _FakeBiometrics implements BiometricAuthenticator {
  int authenticateCalls = 0;

  @override
  Future<bool> authenticate() async {
    authenticateCalls++;
    return true;
  }

  @override
  Future<bool> isBiometricAvailable() async => false;
}

class _FakeLocations implements LocationReader {
  @override
  double distanceToWorkplace(Position position) => 0;

  @override
  Future<Position> getCurrentPosition() =>
      Future<Position>.error(StateError('not expected'));
}

class _FakeRecords implements TimeRecordRepository {
  @override
  Future<void> addRecord(String uid, TimeRecord record) async {}

  @override
  Stream<List<TimeRecord>> watchRecords(String uid) =>
      Stream<List<TimeRecord>>.value(const <TimeRecord>[]);
}
