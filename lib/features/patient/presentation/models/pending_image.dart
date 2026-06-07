import 'dart:typed_data';

/// A picked-but-not-yet-saved image held in memory during the appointment form session.
class PendingImage {
  final Uint8List bytes;
  final String fileName;
  final bool isCompressed;

  const PendingImage({
    required this.bytes,
    required this.fileName,
    required this.isCompressed,
  });
}
