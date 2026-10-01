import 'package:flutter/material.dart';

import '../../app/app_services.dart';
import '../../models/time_record.dart';
import '../../services/auth_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({required this.services, required this.user, super.key});

  final AppServices services;
  final AuthUser user;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: StreamBuilder<List<TimeRecord>>(
      stream: services.records.watchRecords(user.uid),
      builder: (context, snapshot) {
        final records = snapshot.data ?? const <TimeRecord>[];
        return CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              title: const Text('Histórico de pontos'),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
            if (snapshot.hasError)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _HistoryMessage(
                  icon: Icons.cloud_off_outlined,
                  message:
                      'Não foi possível carregar seu histórico. Verifique a conexão.',
                ),
              )
            else if (snapshot.connectionState == ConnectionState.waiting &&
                records.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (records.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _HistoryMessage(
                  icon: Icons.event_note_outlined,
                  message: 'Seus registros aparecerão aqui.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: SliverList.separated(
                  itemCount: records.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) =>
                      _HistoryRecordCard(record: records[index]),
                ),
              ),
          ],
        );
      },
    ),
  );
}

class _HistoryRecordCard extends StatelessWidget {
  const _HistoryRecordCard({required this.record});

  final TimeRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localTime = record.recordedAt.toLocal();
    final date = MaterialLocalizations.of(context).formatFullDate(localTime);
    final time = TimeOfDay.fromDateTime(localTime).format(context);
    final isEntry = record.type == TimeRecordType.entrada;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(isEntry ? Icons.login : Icons.logout),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        isEntry ? 'Entrada' : 'Saída',
                        style: theme.textTheme.titleMedium,
                      ),
                      Text('$date · $time', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Text('${record.distanceMeters.toStringAsFixed(0)} m'),
              ],
            ),
            const Divider(height: 24),
            Text(
              'Localização: ${record.latitude.toStringAsFixed(5)}, ${record.longitude.toStringAsFixed(5)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryMessage extends StatelessWidget {
  const _HistoryMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 48),
          const SizedBox(height: 14),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
