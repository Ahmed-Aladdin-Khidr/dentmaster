class DataStats {
  final int patientCount;
  final int appointmentCount;
  final int imageCount;
  final int databaseSizeBytes;
  final int imageFolderSizeBytes;

  const DataStats({
    required this.patientCount,
    required this.appointmentCount,
    required this.imageCount,
    required this.databaseSizeBytes,
    required this.imageFolderSizeBytes,
  });

  int get totalSizeBytes => databaseSizeBytes + imageFolderSizeBytes;
}
