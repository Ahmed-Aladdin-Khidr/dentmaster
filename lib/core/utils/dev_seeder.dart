import 'package:flutter/foundation.dart';
import '../../injection_container.dart';
import '../../features/patient/domain/entities/appointment.dart';
import '../../features/patient/domain/entities/patient.dart';
import '../../features/patient/domain/usecases/add_appointment.dart';
import '../../features/patient/domain/usecases/create_patient.dart';
import '../../features/patient/domain/usecases/get_all_patients.dart';
import '../usecases/usecase.dart';

Future<void> seedTestDataIfEmpty() async {
  if (!kDebugMode) return;

  final existing = await sl<GetAllPatients>()(const NoParams());
  if (existing.isNotEmpty) return;

  final createPatient = sl<CreatePatient>();
  final addAppointment = sl<AddAppointment>();
  final now = DateTime.now();

  // ── Patient 1: Ahmed Hassan — 3 appointments ────────────────────────────
  await createPatient(Patient(
    id: 'seed-p001',
    fullName: 'Ahmed Hassan',
    phone: '0100-1234567',
    email: 'ahmed.hassan@email.com',
    dateOfBirth: DateTime(1985, 3, 15),
    gender: 'Male',
    address: '12 Tahrir Square, Cairo',
    notes: 'Regular patient. Allergic to penicillin.',
    createdAt: now,
    updatedAt: now,
  ));
  await addAppointment(Appointment(
    id: 'seed-a001',
    patientId: 'seed-p001',
    date: DateTime(2024, 1, 15),
    chiefComplaint: 'Toothache in lower left molar',
    diagnosis: 'Acute pulpitis — lower left first molar',
    treatmentNotes: 'Root canal treatment performed. Temporary filling placed.',
    nextVisitNotes: 'Return in 2 weeks for permanent crown.',
    createdAt: now,
    updatedAt: now,
  ));
  await addAppointment(Appointment(
    id: 'seed-a002',
    patientId: 'seed-p001',
    date: DateTime(2024, 6, 20),
    chiefComplaint: 'Follow-up for crown placement',
    diagnosis: 'Post root canal — ready for permanent crown',
    treatmentNotes: 'Permanent porcelain crown fitted and cemented.',
    createdAt: now,
    updatedAt: now,
  ));
  await addAppointment(Appointment(
    id: 'seed-a003',
    patientId: 'seed-p001',
    date: DateTime(2025, 1, 10),
    chiefComplaint: 'Routine 6-month checkup',
    diagnosis: 'Good oral hygiene. No new cavities.',
    treatmentNotes: 'Professional cleaning and polishing.',
    nextVisitNotes: 'Next checkup in 6 months.',
    createdAt: now,
    updatedAt: now,
  ));

  // ── Patient 2: Sara Mohamed — 2 appointments ────────────────────────────
  await createPatient(Patient(
    id: 'seed-p002',
    fullName: 'Sara Mohamed',
    phone: '0111-9876543',
    email: 'sara.m@example.com',
    dateOfBirth: DateTime(1992, 7, 22),
    gender: 'Female',
    address: '5 Nile View St, Alexandria',
    notes: 'Orthodontic treatment in progress.',
    createdAt: now,
    updatedAt: now,
  ));
  await addAppointment(Appointment(
    id: 'seed-a004',
    patientId: 'seed-p002',
    date: DateTime(2024, 11, 5),
    chiefComplaint: 'Braces consultation and fitting',
    diagnosis: 'Class II malocclusion — orthodontic treatment indicated',
    treatmentNotes: 'Metal braces fitted — upper and lower arches.',
    nextVisitNotes: 'Adjustment visit in 6 weeks.',
    createdAt: now,
    updatedAt: now,
  ));
  await addAppointment(Appointment(
    id: 'seed-a005',
    patientId: 'seed-p002',
    date: DateTime(2025, 3, 12),
    chiefComplaint: 'Braces adjustment',
    diagnosis: 'Good progress — arch alignment improving',
    treatmentNotes: 'Wire changed, elastic bands adjusted.',
    nextVisitNotes: 'Next adjustment in 6 weeks.',
    createdAt: now,
    updatedAt: now,
  ));

  // ── Patient 3: Omar Khalil — 2 appointments ─────────────────────────────
  await createPatient(Patient(
    id: 'seed-p003',
    fullName: 'Omar Khalil',
    phone: '0122-5551234',
    dateOfBirth: DateTime(1978, 12, 1),
    gender: 'Male',
    address: '88 Garden City, Cairo',
    notes: 'Dental implant candidate — upper right incisor missing.',
    createdAt: now,
    updatedAt: now,
  ));
  await addAppointment(Appointment(
    id: 'seed-a006',
    patientId: 'seed-p003',
    date: DateTime(2024, 9, 18),
    chiefComplaint: 'Missing upper right incisor — wants implant',
    diagnosis: 'Missing tooth #11. Bone density sufficient for implant.',
    treatmentNotes: 'X-ray and CT scan taken. Implant plan discussed.',
    nextVisitNotes: 'Surgical appointment to be scheduled.',
    createdAt: now,
    updatedAt: now,
  ));
  await addAppointment(Appointment(
    id: 'seed-a007',
    patientId: 'seed-p003',
    date: DateTime(2025, 5, 20),
    chiefComplaint: 'Implant surgery',
    diagnosis: '3.7 mm × 11.5 mm titanium implant placed successfully',
    treatmentNotes: 'Implant placed under local anaesthesia. Healing abutment fitted.',
    nextVisitNotes: 'Osseointegration check in 3 months.',
    createdAt: now,
    updatedAt: now,
  ));

  // ── Patient 4: Nour Ibrahim — no appointments (tests empty-timeline state)
  await createPatient(Patient(
    id: 'seed-p004',
    fullName: 'Nour Ibrahim',
    phone: '0100-7779999',
    dateOfBirth: DateTime(2000, 4, 30),
    gender: 'Female',
    notes: 'New patient. First consultation.',
    createdAt: now,
    updatedAt: now,
  ));
}
