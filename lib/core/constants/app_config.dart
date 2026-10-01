class AppConfig {
  const AppConfig();

  static const double workplaceLatitude = -22.7538572;
  static const double workplaceLongitude = -47.3513785;

  double? get workLatitude => workplaceLatitude;
  double? get workLongitude => workplaceLongitude;

  bool get workplaceConfigured => true;
}
