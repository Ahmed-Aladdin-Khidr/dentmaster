import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/patient.dart';
import '../bloc/patient_detail/patient_detail_bloc.dart';
import '../bloc/patient_detail/patient_detail_event.dart';
import '../bloc/patient_detail/patient_detail_state.dart';
import '../widgets/appointment_card.dart';
import '../widgets/appointment_form.dart';

class PatientDetailPage extends StatelessWidget {
  final String? patientId;
  const PatientDetailPage({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    if (patientId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('New Patient')),
        body: const Center(
          child: Text(
            'Phase 7 — Add Patient (coming soon)',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return BlocProvider(
      create: (_) => sl<PatientDetailBloc>()
        ..add(patientId != null
            ? PatientDetailEvent.loaded(patientId!)
            : const PatientDetailEvent.createStarted()),
      child: _PatientDetailView(patientId: patientId),
    );
  }
}

// ---------------------------------------------------------------------------

class _PatientDetailView extends StatelessWidget {
  final String? patientId;
  const _PatientDetailView({required this.patientId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PatientDetailBloc, PatientDetailState>(
      listener: (context, state) {
        if (state is PatientDetailViewMode && patientId == null) {
          // New patient just created — replace create route with detail route.
          context.replace('/patient/${state.patient.id}');
        } else if (state is PatientDetailDeleted) {
          context.pop();
        } else if (state is PatientDetailFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isEditing = state is PatientDetailEditMode;

        return PopScope(
          canPop: !isEditing,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final discard = await ConfirmDialog.show(
              context,
              title: 'Discard changes?',
              message: 'Your unsaved changes will be lost.',
            );
            if (discard && context.mounted) context.pop();
          },
          child: Scaffold(
            appBar: AppBar(
              title: switch (state) {
                PatientDetailCreateMode() => const Text('New Patient'),
                PatientDetailViewMode(:final patient) => Text(patient.fullName),
                PatientDetailEditMode(:final patient) =>
                  Text('Editing: ${patient.fullName}'),
                _ => const Text('Patient Detail'),
              },
            ),
            body: switch (state) {
              PatientDetailInitial() ||
              PatientDetailLoading() =>
                const Center(child: CircularProgressIndicator()),
              PatientDetailCreateMode() => _buildCreatePane(context),
              PatientDetailViewMode(:final patient) =>
                _buildTwoPane(context, patient, isEditing: false),
              PatientDetailEditMode(:final patient) =>
                _buildTwoPane(context, patient, isEditing: true),
              PatientDetailSaving() =>
                const Center(child: CircularProgressIndicator()),
              PatientDetailDeleted() => const SizedBox.shrink(),
              PatientDetailFailure(:final message) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(message),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => context
                            .read<PatientDetailBloc>()
                            .add(patientId != null
                                ? PatientDetailEvent.loaded(patientId!)
                                : const PatientDetailEvent.createStarted()),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
            },
          ),
        );
      },
    );
  }

  Widget _buildCreatePane(BuildContext context) {
    final blankPatient = Patient(
      id: generateLocalId(),
      fullName: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: _PatientInfoPanel(
            patient: blankPatient,
            isEditing: true,
            saveButtonLabel: 'Create Patient',
            onEditTap: () {},
            onSaveTap: (newPatient) => context
                .read<PatientDetailBloc>()
                .add(PatientDetailEvent.created(newPatient)),
            onCancelTap: () => context.pop(),
            onDeleteTap: () {},
          ),
        ),
      ),
    );
  }

  Widget _buildTwoPane(
    BuildContext context,
    Patient patient, {
    required bool isEditing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _PatientInfoPanel(
            patient: patient,
            isEditing: isEditing,
            onEditTap: () => context
                .read<PatientDetailBloc>()
                .add(const PatientDetailEvent.editStarted()),
            onSaveTap: (updated) => context
                .read<PatientDetailBloc>()
                .add(PatientDetailEvent.saved(updated)),
            onCancelTap: () => context
                .read<PatientDetailBloc>()
                .add(const PatientDetailEvent.editCancelled()),
            onDeleteTap: () async {
              final confirm = await ConfirmDialog.show(
                context,
                title: 'Delete Patient',
                message:
                    'Delete ${patient.fullName}? All appointments will be permanently removed.',
              );
              if (confirm && context.mounted) {
                context
                    .read<PatientDetailBloc>()
                    .add(const PatientDetailEvent.deleteRequested());
              }
            },
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 3,
          child: _AppointmentTimelinePanel(patient: patient),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _PatientInfoPanel extends StatefulWidget {
  final Patient patient;
  final bool isEditing;
  final String saveButtonLabel;
  final VoidCallback onEditTap;
  final void Function(Patient updated) onSaveTap;
  final VoidCallback onCancelTap;
  final VoidCallback onDeleteTap;

  const _PatientInfoPanel({
    required this.patient,
    required this.isEditing,
    this.saveButtonLabel = 'Save',
    required this.onEditTap,
    required this.onSaveTap,
    required this.onCancelTap,
    required this.onDeleteTap,
  });

  @override
  State<_PatientInfoPanel> createState() => _PatientInfoPanelState();
}

class _PatientInfoPanelState extends State<_PatientInfoPanel> {
  late final _nameCtrl = TextEditingController();
  late final _phoneCtrl = TextEditingController();
  late final _emailCtrl = TextEditingController();
  late final _dobCtrl = TextEditingController();
  late final _genderCtrl = TextEditingController();
  late final _addressCtrl = TextEditingController();
  late final _notesCtrl = TextEditingController();
  DateTime? _selectedDob;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    _populate(widget.patient);
  }

  @override
  void didUpdateWidget(_PatientInfoPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-populate when patient data changes or when entering edit mode.
    if (oldWidget.patient != widget.patient ||
        oldWidget.isEditing != widget.isEditing) {
      _populate(widget.patient);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _dobCtrl.dispose();
    _genderCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _populate(Patient patient) {
    _nameCtrl.text = patient.fullName;
    _phoneCtrl.text = patient.phone ?? '';
    _emailCtrl.text = patient.email ?? '';
    _selectedDob = patient.dateOfBirth;
    _dobCtrl.text = DateFormatter.formatOrDash(patient.dateOfBirth)
        .replaceAll('—', '');
    _genderCtrl.text = patient.gender ?? '';
    _addressCtrl.text = patient.address ?? '';
    _notesCtrl.text = patient.notes ?? '';
  }

  Future<void> _pickDob(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _dobCtrl.text = DateFormatter.formatDate(picked);
      });
    }
  }

  void _handleSave() {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _nameError = 'Full name is required');
      return;
    }
    setState(() => _nameError = null);
    String? nullIfEmpty(String s) {
      final v = s.trim();
      return v.isEmpty ? null : v;
    }
    widget.onSaveTap(Patient(
      id: widget.patient.id,
      fullName: _nameCtrl.text.trim(),
      phone: nullIfEmpty(_phoneCtrl.text),
      email: nullIfEmpty(_emailCtrl.text),
      dateOfBirth: _selectedDob,
      gender: nullIfEmpty(_genderCtrl.text),
      address: nullIfEmpty(_addressCtrl.text),
      notes: nullIfEmpty(_notesCtrl.text),
      createdAt: widget.patient.createdAt,
      updatedAt: DateTime.now(),
      appointments: widget.patient.appointments,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return widget.isEditing
        ? _buildEditMode(context)
        : _buildViewMode(context);
  }

  Widget _buildViewMode(BuildContext context) {
    final theme = Theme.of(context);
    final p = widget.patient;
    final initials = p.fullName
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  initials,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.fullName,
                        style: theme.textTheme.headlineSmall),
                    if (p.phone != null)
                      Text(p.phone!,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 8),
          _InfoRow('Email', p.email ?? '—'),
          _InfoRow('Date of Birth', DateFormatter.formatOrDash(p.dateOfBirth)),
          _InfoRow('Gender', p.gender ?? '—'),
          _InfoRow('Address', p.address ?? '—'),
          if (p.notes != null) ...[
            const SizedBox(height: 12),
            Text('Notes', style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(p.notes!, style: theme.textTheme.bodyMedium),
          ],
          const SizedBox(height: 28),
          Row(
            children: [
              FilledButton.icon(
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit'),
                onPressed: widget.onEditTap,
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: Colors.red),
                label: const Text('Delete',
                    style: TextStyle(color: Colors.red)),
                onPressed: widget.onDeleteTap,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditMode(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Edit Patient',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          AppTextField(
            controller: _nameCtrl,
            label: 'Full Name *',
            errorText: _nameError,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _phoneCtrl,
            label: 'Phone',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _emailCtrl,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _dobCtrl,
            label: 'Date of Birth',
            readOnly: true,
            onTap: () => _pickDob(context),
            hint: 'Tap to select',
          ),
          const SizedBox(height: 12),
          AppTextField(controller: _genderCtrl, label: 'Gender'),
          const SizedBox(height: 12),
          AppTextField(controller: _addressCtrl, label: 'Address'),
          const SizedBox(height: 12),
          AppTextField(
            controller: _notesCtrl,
            label: 'Notes',
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              FilledButton.icon(
                icon: const Icon(Icons.save, size: 18),
                label: Text(widget.saveButtonLabel),
                onPressed: _handleSave,
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: widget.onCancelTap,
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _AppointmentTimelinePanel extends StatelessWidget {
  final Patient patient;
  const _AppointmentTimelinePanel({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: patient.appointments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today,
                          size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'No appointments recorded yet.\nTap + Add Appointment to begin.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: patient.appointments.length,
                  itemBuilder: (_, i) {
                    final appt = patient.appointments[i];
                    return AppointmentCard(
                      appointment: appt,
                      onEdit: () => AppointmentForm.show(
                        context,
                        patientId: patient.id,
                        existingAppointment: appt,
                      ),
                      onDelete: () =>
                          _confirmDeleteAppointment(context, appt),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Appointment'),
              onPressed: () =>
                  AppointmentForm.show(context, patientId: patient.id),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDeleteAppointment(
      BuildContext context, Appointment appt) async {
    final confirm = await ConfirmDialog.show(
      context,
      title: 'Delete Appointment',
      message:
          'Delete the appointment on ${DateFormatter.formatDate(appt.date)}? '
          'This cannot be undone.',
    );
    if (confirm && context.mounted) {
      context
          .read<PatientDetailBloc>()
          .add(PatientDetailEvent.appointmentDeleted(appt.id));
    }
  }
}

// ---------------------------------------------------------------------------

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
