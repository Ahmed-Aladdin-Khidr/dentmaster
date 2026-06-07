import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../injection_container.dart';
import '../bloc/data_management_bloc.dart';
import '../bloc/data_management_event.dart';
import '../bloc/data_management_state.dart';
import '../widgets/change_password_card.dart';
import '../widgets/export_card.dart';
import '../widgets/import_card.dart';

class DataManagementPage extends StatelessWidget {
  const DataManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DataManagementBloc>()
        ..add(const DataManagementEvent.loadRequested()),
      child: const _DataManagementView(),
    );
  }
}

class _DataManagementView extends StatelessWidget {
  const _DataManagementView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DataManagementBloc, DataManagementState>(
      listener: _handleStateChange,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Data Management')),
          body: switch (state) {
            DataManagementImportSuccess() => _buildRestartPane(context),
            _ => _buildMainPane(context, state),
          },
        );
      },
    );
  }

  void _handleStateChange(BuildContext context, DataManagementState state) {
    switch (state) {
      case DataManagementImportPreview(:final current, :final incoming,
          :final zipPath):
        _showImportPreviewDialog(context, current, incoming, zipPath);
      case DataManagementExportSuccess(:final path):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup saved to $path'),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {
                context
                    .read<DataManagementBloc>()
                    .add(const DataManagementEvent.resultDismissed());
              },
            ),
            duration: const Duration(seconds: 8),
          ),
        );
      case DataManagementFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $message'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      default:
        break;
    }
  }

  Widget _buildMainPane(BuildContext context, DataManagementState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StatsPanel(state: state),
              const SizedBox(height: 16),
              const ExportCard(),
              const SizedBox(height: 12),
              const ImportCard(),
              const SizedBox(height: 12),
              const ChangePasswordCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestartPane(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, size: 72, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            'Import complete',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('The app must restart to apply the imported data.'),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => exit(0),
            icon: const Icon(Icons.restart_alt),
            label: const Text('Restart Now'),
          ),
        ],
      ),
    );
  }

  void _showImportPreviewDialog(
    BuildContext context,
    dynamic current,
    dynamic incoming,
    String zipPath,
  ) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Import'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Importing will replace ALL current data. This cannot be undone.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _previewRow('Current', current.patientCount,
                current.appointmentCount, current.imageCount),
            const SizedBox(height: 8),
            _previewRow('Backup', incoming.patientCount,
                incoming.appointmentCount, incoming.imageCount),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context
                  .read<DataManagementBloc>()
                  .add(const DataManagementEvent.resultDismissed());
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              context
                  .read<DataManagementBloc>()
                  .add(DataManagementEvent.importConfirmed(zipPath));
            },
            child: const Text('Replace & Restart'),
          ),
        ],
      ),
    );
  }

  Widget _previewRow(String label, int patients, int appts, int images) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600))),
        Text('$patients patients · $appts appointments · $images images'),
      ],
    );
  }
}

class _StatsPanel extends StatelessWidget {
  final DataManagementState state;
  const _StatsPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is DataManagementLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (state is! DataManagementReady &&
        state is! DataManagementExporting &&
        state is! DataManagementExportSuccess &&
        state is! DataManagementImporting) {
      return const SizedBox.shrink();
    }

    final stats = switch (state) {
      DataManagementReady(:final stats) => stats,
      DataManagementExporting() => null,
      DataManagementExportSuccess() => null,
      DataManagementImporting() => null,
      _ => null,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Database Summary',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (stats == null)
              const Center(child: CircularProgressIndicator())
            else
              Wrap(
                spacing: 24,
                runSpacing: 8,
                children: [
                  _statChip(context, Icons.people_outline,
                      '${stats.patientCount} patients'),
                  _statChip(context, Icons.calendar_today_outlined,
                      '${stats.appointmentCount} appointments'),
                  _statChip(context, Icons.image_outlined,
                      '${stats.imageCount} images'),
                  _statChip(context, Icons.storage_outlined,
                      _formatBytes(stats.totalSizeBytes)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(BuildContext context, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
