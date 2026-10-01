import '../core/constants/app_config.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../services/location_service.dart';
import '../services/time_record_service.dart';
import '../services/user_profile_service.dart';

abstract interface class AppServices {
  AppConfig get config;
  AuthRepository get auth;
  UserProfileRepository get profiles;
  BiometricAuthenticator get biometrics;
  LocationReader get locations;
  TimeRecordRepository get records;
}

class FirebaseAppServices implements AppServices {
  FirebaseAppServices({
    required this.config,
    required this.auth,
    required this.profiles,
    required this.biometrics,
    required this.locations,
    required this.records,
  });

  factory FirebaseAppServices.create(AppConfig config) => FirebaseAppServices(
    config: config,
    auth: AuthService(),
    profiles: UserProfileService(),
    biometrics: BiometricService(),
    locations: LocationService(config: config),
    records: TimeRecordService(),
  );

  @override
  final AppConfig config;
  @override
  final AuthRepository auth;
  @override
  final UserProfileRepository profiles;
  @override
  final BiometricAuthenticator biometrics;
  @override
  final LocationReader locations;
  @override
  final TimeRecordRepository records;
}
