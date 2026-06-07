import 'package:equatable/equatable.dart';

class AppointmentImage extends Equatable {
  final String id;
  final String appointmentId;
  final String filePath;
  final String fileName;
  final int fileSizeBytes;
  final bool isCompressed;
  final DateTime addedAt;

  const AppointmentImage({
    required this.id,
    required this.appointmentId,
    required this.filePath,
    required this.fileName,
    required this.fileSizeBytes,
    required this.isCompressed,
    required this.addedAt,
  });

  @override
  List<Object?> get props => [
        id,
        appointmentId,
        filePath,
        fileName,
        fileSizeBytes,
        isCompressed,
        addedAt,
      ];
}
