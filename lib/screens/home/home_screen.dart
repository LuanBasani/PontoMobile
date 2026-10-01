import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../app/app_services.dart';
import '../../core/attendance_policy.dart';
import '../../models/time_record.dart';
import '../../services/auth_service.dart';
import '../../services/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.services, required this.user, super.key});

  final AppServices services;
  final AuthUser user;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Stream<List<TimeRecord>> _recordsStream;
  Position? _position;
  String? _locationError;
  bool _locating = false;
  bool _recording = false;

  @override
  void initState() {
    super.initState();
    _recordsStream = widget.services.records.watchRecords(widget.user.uid);
    _refreshLocation();
  }

  Future<void> _refreshLocation() async {
    if (!widget.services.config.workplaceConfigured) {
      setState(() {
        _position = null;
        _locationError = 'Configure as coordenadas do trabalho para registrar.';
      });
      return;
    }
    setState(() {
      _locating = true;
      _locationError = null;
    });
    try {
      final position = await widget.services.locations.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _position = position;
        _locationError = null;
      });
    } on LocationServiceException catch (error) {
      if (mounted) setState(() => _locationError = error.message);
    } catch (_) {
      if (mounted) {
        setState(() {
          _locationError =
              'Não foi possível obter sua localização. Verifique o GPS e tente novamente.';
        });
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _register(TimeRecordType type) async {
    setState(() => _recording = true);
    try {
      final position = await widget.services.locations.getCurrentPosition();
      final distance = widget.services.locations.distanceToWorkplace(position);
      if (!AttendancePolicy.isWithinAllowedRadius(distance)) {
        throw const LocationServiceException(
          'Você está fora do limite de 100 metros do local de trabalho.',
        );
      }
      final now = DateTime.now();
      final record = TimeRecord(
        id: '${now.microsecondsSinceEpoch}',
        type: type,
        recordedAt: now,
        latitude: position.latitude,
        longitude: position.longitude,
        distanceMeters: distance,
      );
      await widget.services.records.addRecord(widget.user.uid, record);
      if (mounted) {
        setState(() => _position = position);
        _showMessage('Registro de ${type.name} realizado com sucesso.');
      }
    } on LocationServiceException catch (error) {
      if (mounted) _showMessage(error.message, isError: true);
    } on FirebaseException {
      if (mounted) {
        _showMessage(
          'Não foi possível salvar seu registro. Verifique a conexão e tente novamente.',
          isError: true,
        );
      }
    } catch (_) {
      if (mounted) {
        _showMessage(
          'O registro não foi concluído. Tente novamente.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _recording = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: StreamBuilder<List<TimeRecord>>(
      stream: _recordsStream,
      builder: (context, snapshot) {
        final records = snapshot.data ?? const <TimeRecord>[];
        final nextType = nextRecordType(records);
        final distance = _position == null
            ? null
            : widget.services.locations.distanceToWorkplace(_position!);
        final canRecord =
            distance != null &&
            AttendancePolicy.isWithinAllowedRadius(distance) &&
            snapshot.connectionState != ConnectionState.waiting &&
            !snapshot.hasError &&
            !_recording;

        return RefreshIndicator(
          onRefresh: _refreshLocation,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: <Widget>[
              Text(
                'Olá, ${widget.user.displayName?.trim().isNotEmpty == true ? widget.user.displayName : widget.user.email.split('@').first}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Sua jornada, registrada com segurança.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              _LocationCard(
                loading: _locating,
                error: _locationError,
                distanceMeters: distance,
                accuracyMeters: _position?.accuracy,
                onRefresh: _refreshLocation,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'Próximo registro',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        nextType == TimeRecordType.entrada
                            ? 'Entrada'
                            : 'Saída',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: canRecord ? () => _register(nextType) : null,
                        icon: _recording
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.fingerprint),
                        label: Text(
                          _recording
                              ? 'Registrando…'
                              : 'Registrar ${nextType.name}',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (snapshot.hasError) ...<Widget>[
                const SizedBox(height: 16),
                const _InlineMessage(
                  icon: Icons.cloud_off_outlined,
                  message:
                      'Não foi possível carregar os registros. Verifique sua conexão.',
                ),
              ],
              const SizedBox(height: 20),
              Text(
                'Registro mais recente',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              if (records.isEmpty)
                const _InlineMessage(
                  icon: Icons.event_note_outlined,
                  message: 'Nenhum ponto registrado ainda.',
                )
              else
                _RecordTile(record: records.first),
            ],
          ),
        );
      },
    ),
  );
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.loading,
    required this.error,
    required this.distanceMeters,
    required this.accuracyMeters,
    required this.onRefresh,
  });

  final bool loading;
  final String? error;
  final double? distanceMeters;
  final double? accuracyMeters;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final withinRadius =
        distanceMeters != null &&
        AttendancePolicy.isWithinAllowedRadius(distanceMeters!);
    final color = withinRadius ? colorScheme.primary : colorScheme.error;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              foregroundColor: color,
              child: Icon(withinRadius ? Icons.near_me : Icons.location_on),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Localização',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  if (loading)
                    const Text('Verificando sua localização…')
                  else if (error != null)
                    Text(error!)
                  else if (distanceMeters != null) ...<Widget>[
                    Text(
                      withinRadius
                          ? 'Você está dentro da área de registro.'
                          : 'Você está fora da área de registro.',
                    ),
                    Text(
                      '${distanceMeters!.toStringAsFixed(0)} m do trabalho · precisão ±${accuracyMeters?.toStringAsFixed(0) ?? '—'} m',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              tooltip: 'Atualizar localização',
              onPressed: loading ? null : onRefresh,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: <Widget>[
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    ),
  );
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record});

  final TimeRecord record;

  @override
  Widget build(BuildContext context) {
    final localTime = record.recordedAt.toLocal();
    final date = MaterialLocalizations.of(context).formatMediumDate(localTime);
    final time = TimeOfDay.fromDateTime(localTime).format(context);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            record.type == TimeRecordType.entrada ? Icons.login : Icons.logout,
          ),
        ),
        title: Text(
          record.type == TimeRecordType.entrada ? 'Entrada' : 'Saída',
        ),
        subtitle: Text(
          '$date · $time · ${record.distanceMeters.toStringAsFixed(0)} m',
        ),
      ),
    );
  }
}
