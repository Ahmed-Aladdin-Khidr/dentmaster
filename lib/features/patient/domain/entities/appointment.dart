import 'package:equatable/equatable.dart';
import 'appointment_image.dart';

class Appointment extends Equatable {
  final String id;
  final String patientId;
  final DateTime date;
  final String? chiefComplaint;
  final String? diagnosis;
  final String? treatmentNotes;
  final String? nextVisitNotes;
  final List<AppointmentImage> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Appointment({
    required this.id,
    required this.patientId,
    required this.date,
    this.chiefComplaint,
    this.diagnosis,
    this.treatmentNotes,
    this.nextVisitNotes,
    this.images = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        patientId,
        date,
        chiefComplaint,
        diagnosis,
        treatmentNotes,
        nextVisitNotes,
        images,
        createdAt,
        updatedAt,
      ];
}
