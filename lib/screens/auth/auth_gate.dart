import 'package:flutter/material.dart';

import '../../app/app_services.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../home/app_shell.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({required this.services, super.key});

  final AppServices services;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> with WidgetsBindingObserver {
  final Set<String> _unlockedUsers = <String>{};
  final Set<String> _biometricEnabledUsers = <String>{};
  String? _activeUserId;
  bool _lockOnResume = false;
  late final Stream<AuthUser?> _authStateChanges;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authStateChanges = widget.services.auth.authStateChanges.map((user) {
      if (user?.uid != _activeUserId) {
        _unlockedUsers.clear();
        _biometricEnabledUsers.clear();
        _lockOnResume = false;
        _activeUserId = user?.uid;
      }
      return user;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      if (_activeUserId != null &&
          _biometricEnabledUsers.contains(_activeUserId) &&
          _unlockedUsers.contains(_activeUserId)) {
        _lockOnResume = true;
      }
      return;
    }

    if (state == AppLifecycleState.resumed && _lockOnResume) {
      _lockOnResume = false;
      if (_activeUserId case final uid?) _unlockedUsers.remove(uid);
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _signOut({bool disableBiometrics = false}) async {
    try {
      final uid = widget.services.auth.currentUser?.uid;
      if (uid != null && disableBiometrics) {
        try {
          await widget.services.profiles.setBiometricEnabled(uid, false);
        } catch (_) {
          // Signing out must remain available when Firestore is offline.
        }
      }
      await widget.services.auth.signOut();
    } finally {
      _unlockedUsers.clear();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: _authStateChanges,
    initialData: widget.services.auth.currentUser,
    builder: (context, authSnapshot) {
      if (authSnapshot.connectionState == ConnectionState.waiting &&
          !authSnapshot.hasData) {
        return const _LoadingScreen();
      }
      final user = authSnapshot.data;
      if (user == null) return LoginScreen(services: widget.services);

      return StreamBuilder<UserProfile?>(
        key: ValueKey<String>(user.uid),
        stream: widget.services.profiles.watchProfile(user.uid),
        builder: (context, profileSnapshot) {
          if (profileSnapshot.hasError) {
            return _AuthGateError(
              message:
                  'Não foi possível carregar seu perfil. Verifique sua conexão.',
              onSignOut: _signOut,
            );
          }
          if (profileSnapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingScreen();
          }

          final profile = profileSnapshot.data;
          if (profile == null) {
            return _AuthGateError(
              message:
                  'Não encontramos o perfil desta conta. Confira a configuração do Firestore.',
              onSignOut: _signOut,
            );
          }

          if (profile.biometricEnabled) {
            _biometricEnabledUsers.add(user.uid);
          } else {
            _biometricEnabledUsers.remove(user.uid);
          }

          if (profile.biometricEnabled && !_unlockedUsers.contains(user.uid)) {
            return _BiometricLockScreen(
              services: widget.services,
              onSignOut: () => _signOut(disableBiometrics: true),
              onUnlocked: () => setState(() => _unlockedUsers.add(user.uid)),
            );
          }
          return AppShell(
            services: widget.services,
            user: user,
            profile: profile,
            onSignOut: _signOut,
            onBiometricVerified: (uid) {
              setState(() => _unlockedUsers.add(uid));
            },
          );
        },
      );
    },
  );
}

class _BiometricLockScreen extends StatefulWidget {
  const _BiometricLockScreen({
    required this.services,
    required this.onSignOut,
    required this.onUnlocked,
  });

  final AppServices services;
  final Future<void> Function() onSignOut;
  final VoidCallback onUnlocked;

  @override
  State<_BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<_BiometricLockScreen> {
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _unlock();
    });
  }

  Future<void> _unlock() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (await widget.services.biometrics.authenticate()) {
        widget.onUnlocked();
      } else if (mounted) {
        setState(
          () => _error =
              'A biometria não foi confirmada. Tente novamente ou use sua senha.',
        );
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.fingerprint, size: 68),
                const SizedBox(height: 20),
                Text(
                  'Desbloqueie seu ponto',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Confirme sua identidade para continuar na sessão já autenticada.',
                  textAlign: TextAlign.center,
                ),
                if (_error != null) ...<Widget>[
                  const SizedBox(height: 16),
                  Text(_error!, textAlign: TextAlign.center),
                ],
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _loading ? null : _unlock,
                  icon: const Icon(Icons.fingerprint),
                  label: Text(
                    _loading ? 'Aguarde…' : 'Desbloquear com biometria',
                  ),
                ),
                TextButton(
                  onPressed: _loading ? null : widget.onSignOut,
                  child: const Text('Sair e entrar com senha'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class _AuthGateError extends StatelessWidget {
  const _AuthGateError({required this.message, required this.onSignOut});

  final String message;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onSignOut, child: const Text('Sair')),
          ],
        ),
      ),
    ),
  );
}
