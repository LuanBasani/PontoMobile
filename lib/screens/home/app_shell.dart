import 'package:flutter/material.dart';

import '../../app/app_services.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../history/history_screen.dart';
import '../profile/profile_screen.dart';
import 'home_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    required this.services,
    required this.user,
    required this.profile,
    required this.onSignOut,
    required this.onBiometricVerified,
    super.key,
  });

  final AppServices services;
  final AuthUser user;
  final UserProfile profile;
  final Future<void> Function() onSignOut;
  final ValueChanged<String> onBiometricVerified;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(services: widget.services, user: widget.user),
      HistoryScreen(services: widget.services, user: widget.user),
      ProfileScreen(
        services: widget.services,
        user: widget.user,
        profile: widget.profile,
        onSignOut: widget.onSignOut,
        onBiometricVerified: widget.onBiometricVerified,
      ),
    ];
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            selectedIcon: Icon(Icons.schedule),
            label: 'Ponto',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'Histórico'),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
