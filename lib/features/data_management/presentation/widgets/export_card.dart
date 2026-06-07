import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/data_management_bloc.dart';
import '../bloc/data_management_event.dart';
import '../bloc/data_management_state.dart';

class ExportCard extends StatelessWidget {
  const ExportCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.upload_file,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text('Export Data',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Save a full backup of your database and images as a ZIP file.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            BlocBuilder<DataManagementBloc, DataManagementState>(
              builder: (context, state) {
                final isExporting = state is DataManagementExporting;
                return FilledButton.icon(
                  onPressed: isExporting ? null : () => _pickAndExport(context),
                  icon: isExporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_alt),
                  label: Text(isExporting ? 'Exporting…' : 'Export to ZIP'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndExport(BuildContext context) async {
    final timestamp = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save backup',
      fileName: 'dentmaster_backup_$timestamp.zip',
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (result == null || !context.mounted) return;
    context
        .read<DataManagementBloc>()
        .add(DataManagementEvent.exportRequested(result));
  }
}
