import 'package:flutter/material.dart';

class PatientDetailPage extends StatelessWidget {
  final String? patientId;
  const PatientDetailPage({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(patientId == null ? 'New Patient' : 'Patient Detail'),
      ),
      body: Center(
        child: Text(
          patientId == null
              ? 'Phase 7 — Add Patient (coming soon)'
              : 'Phase 5 — Patient Detail (coming soon)\nID: $patientId',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
