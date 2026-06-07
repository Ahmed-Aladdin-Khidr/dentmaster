import 'package:equatable/equatable.dart';
import 'appointment.dart';

class Patient extends Equatable {
  final String id;
  final String fullName;
  final String? phone;
  final String? email;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Appointment> appointments;

  const Patient({
    required this.id,
    required this.fullName,
    this.phone,
    this.email,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.appointments = const [],
  });

  @override
  List<Object?> get props => [
        id,
        fullName,
        phone,
        email,
        dateOfBirth,
        gender,
        address,
        notes,
        createdAt,
        updatedAt,
        appointments,
      ];
}
