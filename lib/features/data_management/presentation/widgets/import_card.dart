import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/data_management_bloc.dart';
import '../bloc/data_management_event.dart';
import '../bloc/data_management_state.dart';

class ImportCard extends StatelessWidget {
  const ImportCard({super.key});

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
                Icon(Icons.download_for_offline,
                    color: Theme.of(context).colorScheme.secondary),
                const SizedBox(width: 12),
                Text('Import Data',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Restore from a previously exported ZIP backup. '
              'Current data will be replaced.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            BlocBuilder<DataManagementBloc, DataManagementState>(
              builder: (context, state) {
                final isImporting = state is DataManagementImporting;
                return FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  onPressed:
                      isImporting ? null : () => _pickAndPreview(context),
                  icon: isImporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.folder_open),
                  label: Text(isImporting ? 'Importing…' : 'Select Backup ZIP'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndPreview(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select backup ZIP',
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (result == null || result.files.single.path == null) return;
    if (!context.mounted) return;
    context
        .read<DataManagementBloc>()
        .add(DataManagementEvent.importFileSelected(
            result.files.single.path!));
  }
}
