import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/patient.dart';

class PatientCard extends StatelessWidget {
  final Patient patient;
  const PatientCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final lastVisit = patient.appointments.isNotEmpty
        ? DateFormat('dd MMM yyyy').format(patient.appointments.first.date)
        : 'No visits yet';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        title: Text(
          patient.fullName,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(patient.phone ?? 'No phone'),
        trailing: Text(
          lastVisit,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        onTap: () => context.push('/patient/${patient.id}'),
      ),
    );
  }
}
