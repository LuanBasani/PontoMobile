import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../screens/auth/auth_gate.dart';
import 'app_services.dart';

class PontoMobileApp extends StatelessWidget {
  const PontoMobileApp({required this.services, super.key});

  final AppServices services;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'PontoMobile',
    theme: AppTheme.light,
    debugShowCheckedModeBanner: false,
    home: AuthGate(services: services),
  );
}
