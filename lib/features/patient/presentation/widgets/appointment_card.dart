import 'package:flutter/material.dart';
import '../../domain/entities/appointment.dart';
import '../../../../core/utils/date_formatter.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onDelete;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 6),
                Text(
                  DateFormatter.formatDate(appointment.date),
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  tooltip: 'Edit appointment',
                  onPressed: null, // Phase 6
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: Colors.red),
                  tooltip: 'Delete appointment',
                  onPressed: onDelete,
                ),
              ],
            ),
            if (appointment.chiefComplaint != null) ...[
              const SizedBox(height: 6),
              Text(
                'Complaint: ${appointment.chiefComplaint}',
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (appointment.diagnosis != null) ...[
              const SizedBox(height: 4),
              Text(
                'Diagnosis: ${appointment.diagnosis}',
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (appointment.treatmentNotes != null) ...[
              const SizedBox(height: 4),
              Text(
                'Treatment: ${appointment.treatmentNotes}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (appointment.nextVisitNotes != null) ...[
              const SizedBox(height: 4),
              Text(
                'Next visit: ${appointment.nextVisitNotes}',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontStyle: FontStyle.italic),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (appointment.images.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.photo_library_outlined,
                      size: 14, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${appointment.images.length} image(s)',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.primary),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
