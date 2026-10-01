import 'package:flutter/material.dart';

import '../../app/app_services.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
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
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _updatingBiometrics = false;
  bool _signingOut = false;
  String? _error;

  Future<void> _toggleBiometrics(bool enabled) async {
    setState(() {
      _updatingBiometrics = true;
      _error = null;
    });
    try {
      if (enabled) {
        if (!await widget.services.biometrics.isBiometricAvailable()) {
          throw const _ProfileActionException(
            'Configure uma biometria nas opções do dispositivo antes de ativar.',
          );
        }
        final verified = await widget.services.biometrics.authenticate();
        if (!verified) return;
        widget.onBiometricVerified(widget.user.uid);
      }
      await widget.services.profiles.setBiometricEnabled(
        widget.user.uid,
        enabled,
      );
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is _ProfileActionException
              ? error.message
              : 'Não foi possível atualizar a opção de biometria.',
        );
      }
    } finally {
      if (mounted) setState(() => _updatingBiometrics = false);
    }
  }

  Future<void> _signOut() async {
    setState(() => _signingOut = true);
    try {
      await widget.onSignOut();
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Não foi possível sair da conta. Tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: <Widget>[
        Text('Seu perfil', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: <Widget>[
                const CircleAvatar(
                  radius: 28,
                  child: Icon(Icons.person_outline, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.profile.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(widget.profile.email),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: SwitchListTile.adaptive(
            value: widget.profile.biometricEnabled,
            onChanged: _updatingBiometrics ? null : _toggleBiometrics,
            title: const Text('Desbloquear com biometria'),
            subtitle: const Text(
              'Protege localmente a sessão Firebase já autenticada neste dispositivo.',
            ),
            secondary: const Icon(Icons.fingerprint),
          ),
        ),
        if (_error != null) ...<Widget>[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: _signingOut ? null : _signOut,
          icon: _signingOut
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.logout),
          label: Text(_signingOut ? 'Saindo…' : 'Sair da conta'),
        ),
      ],
    ),
  );
}

class _ProfileActionException implements Exception {
  const _ProfileActionException(this.message);

  final String message;
}
