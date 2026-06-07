import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/appointment_image.dart';
import '../bloc/patient_detail/patient_detail_bloc.dart';
import '../bloc/patient_detail/patient_detail_event.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onDelete,
    required this.onEdit,
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
                  onPressed: onEdit,
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
              const SizedBox(height: 10),
              _ImageStrip(images: appointment.images),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Thumbnail strip ──────────────────────────────────────────────────────────

class _ImageStrip extends StatelessWidget {
  final List<AppointmentImage> images;
  const _ImageStrip({required this.images});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) => _Thumbnail(image: images[i]),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final AppointmentImage image;
  const _Thumbnail({required this.image});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => _openViewer(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.file(
              File(image.filePath),
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 64,
                height: 64,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, size: 28),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => _confirmDelete(context),
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _openViewer(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.file(
                File(image.filePath),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image,
                      size: 64, color: Colors.white54),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final bloc = context.read<PatientDetailBloc>();
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Image',
      message: 'Remove this image? It cannot be undone.',
    );
    if (confirmed) {
      bloc.add(PatientDetailEvent.imageDeleted(image.id, image.filePath));
    }
  }
}
