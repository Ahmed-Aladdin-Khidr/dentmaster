import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/appointment_image.dart';
import '../bloc/patient_detail/patient_detail_bloc.dart';
import '../bloc/patient_detail/patient_detail_event.dart';
import '../models/pending_image.dart';
import 'image_quality_dialog.dart';

class AppointmentForm {
  /// Shows the appointment add/edit dialog.
  /// Shares the caller's [PatientDetailBloc] into the dialog's sub-tree.
  static Future<void> show(
    BuildContext context, {
    required String patientId,
    Appointment? existingAppointment,
  }) async {
    final bloc = context.read<PatientDetailBloc>();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: _AppointmentFormDialog(
          patientId: patientId,
          existingAppointment: existingAppointment,
        ),
      ),
    );
  }
}

// ── Dialog widget ─────────────────────────────────────────────────────────

class _AppointmentFormDialog extends StatefulWidget {
  final String patientId;
  final Appointment? existingAppointment;

  const _AppointmentFormDialog({
    required this.patientId,
    this.existingAppointment,
  });

  @override
  State<_AppointmentFormDialog> createState() =>
      _AppointmentFormDialogState();
}

class _AppointmentFormDialogState extends State<_AppointmentFormDialog> {
  late final _complaintCtrl = TextEditingController();
  late final _diagnosisCtrl = TextEditingController();
  late final _treatmentCtrl = TextEditingController();
  late final _nextVisitCtrl = TextEditingController();
  late final _dateCtrl = TextEditingController();

  DateTime? _selectedDate;
  String? _dateError;
  bool _saving = false;

  // Images
  late final List<AppointmentImage> _keptImages;
  final List<String> _removedImageIds = [];
  final List<String> _removedImagePaths = [];
  final List<PendingImage> _pendingImages = [];

  bool get _isEditing => widget.existingAppointment != null;

  @override
  void initState() {
    super.initState();
    final appt = widget.existingAppointment;
    if (appt != null) {
      _complaintCtrl.text = appt.chiefComplaint ?? '';
      _diagnosisCtrl.text = appt.diagnosis ?? '';
      _treatmentCtrl.text = appt.treatmentNotes ?? '';
      _nextVisitCtrl.text = appt.nextVisitNotes ?? '';
      _selectedDate = appt.date;
      _dateCtrl.text = DateFormatter.formatDate(appt.date);
      _keptImages = List.of(appt.images);
    } else {
      _keptImages = [];
    }
  }

  @override
  void dispose() {
    _complaintCtrl.dispose();
    _diagnosisCtrl.dispose();
    _treatmentCtrl.dispose();
    _nextVisitCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  // ── Date picker ──────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
        _dateCtrl.text = DateFormatter.formatDate(picked);
        _dateError = null;
      });
    }
  }

  // ── Image picking ─────────────────────────────────────────────────────────

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'bmp', 'gif', 'webp'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    Uint8List? bytes = file.bytes;
    if (bytes == null) {
      if (file.path == null) return;
      bytes = await File(file.path!).readAsBytes();
    }

    final compressed = await compressImage(bytes);

    if (!mounted) return;
    final chosen = await ImageQualityDialog.show(
      context,
      originalBytes: bytes,
      compressedBytes: compressed,
      fileName: file.name,
    );
    if (chosen == null) return;

    setState(() => _pendingImages.add(chosen));
  }

  void _removeKeptImage(AppointmentImage image) {
    setState(() {
      _keptImages.remove(image);
      _removedImageIds.add(image.id);
      _removedImagePaths.add(image.filePath);
    });
  }

  void _removePending(PendingImage pending) {
    setState(() => _pendingImages.remove(pending));
  }

  // ── Save ─────────────────────────────────────────────────────────────────

  void _handleSave(BuildContext context) {
    if (_selectedDate == null) {
      setState(() => _dateError = 'Date is required');
      return;
    }
    setState(() => _saving = true);

    String? ne(String s) {
      final v = s.trim();
      return v.isEmpty ? null : v;
    }

    final now = DateTime.now();
    final existing = widget.existingAppointment;
    final appointmentId = existing?.id ?? generateLocalId();

    final appointment = Appointment(
      id: appointmentId,
      patientId: widget.patientId,
      date: _selectedDate!,
      chiefComplaint: ne(_complaintCtrl.text),
      diagnosis: ne(_diagnosisCtrl.text),
      treatmentNotes: ne(_treatmentCtrl.text),
      nextVisitNotes: ne(_nextVisitCtrl.text),
      images: existing?.images ?? const [],
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    if (_isEditing) {
      context.read<PatientDetailBloc>().add(PatientDetailEvent.appointmentUpdated(
        appointment,
        _pendingImages,
        _removedImageIds,
        _removedImagePaths,
      ));
    } else {
      context.read<PatientDetailBloc>().add(PatientDetailEvent.appointmentAdded(
        appointment,
        _pendingImages,
      ));
    }

    Navigator.of(context).pop();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditing ? 'Edit Appointment' : 'New Appointment',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        controller: _dateCtrl,
                        label: 'Date *',
                        readOnly: true,
                        hint: 'Tap to pick a date',
                        errorText: _dateError,
                        onTap: _pickDate,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _complaintCtrl,
                        label: 'Chief Complaint',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _diagnosisCtrl,
                        label: 'Diagnosis',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _treatmentCtrl,
                        label: 'Treatment Notes',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _nextVisitCtrl,
                        label: 'Next Visit Notes',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Images',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      _buildImagesRow(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  FilledButton(
                    onPressed: _saving ? null : () => _handleSave(context),
                    child: const Text('Save'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagesRow() {
    final hasImages =
        _keptImages.isNotEmpty || _pendingImages.isNotEmpty;

    return SizedBox(
      height: 96,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final image in _keptImages)
            _ImageChip(
              child: Image.file(
                File(image.filePath),
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image, size: 40),
              ),
              onRemove: () => _removeKeptImage(image),
            ),
          for (final pending in _pendingImages)
            _ImageChip(
              child: Image.memory(
                pending.bytes,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
              onRemove: () => _removePending(pending),
            ),
          if (!hasImages)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Text(
                  'No images yet',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
              ),
            ),
          // Add button
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add_photo_alternate_outlined,
                  color: Colors.grey, size: 32),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Thumbnail chip ────────────────────────────────────────────────────────

class _ImageChip extends StatelessWidget {
  final Widget child;
  final VoidCallback onRemove;

  const _ImageChip({required this.child, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          margin: const EdgeInsets.only(right: 8, top: 8),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: child,
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
