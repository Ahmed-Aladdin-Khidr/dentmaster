import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Saves [bytes] to `<appSupport>/images/<appointmentId>/<imageId>.jpg`
/// and returns the absolute file path.
Future<String> saveImageToAppDirectory({
  required String appointmentId,
  required String imageId,
  required Uint8List bytes,
}) async {
  final appDir = await getApplicationSupportDirectory();
  final imageDir =
      Directory(p.join(appDir.path, 'images', appointmentId));
  await imageDir.create(recursive: true);
  final filePath = p.join(imageDir.path, '$imageId.jpg');
  await File(filePath).writeAsBytes(bytes);
  return filePath;
}

/// Resizes to max 1920 px width (aspect-ratio preserved) and re-encodes as
/// JPEG at quality 70.  Returns the original [bytes] unchanged on any error.
Future<Uint8List> compressImage(Uint8List bytes) async {
  try {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;
    img.Image resized = decoded;
    if (decoded.width > 1920) {
      resized = img.copyResize(decoded, width: 1920);
    }
    return Uint8List.fromList(img.encodeJpg(resized, quality: 70));
  } catch (_) {
    return bytes;
  }
}

/// Generates a 32-character random hex string suitable as a local database ID.
String generateLocalId() {
  final random = math.Random.secure();
  return List.generate(16, (_) => random.nextInt(256))
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();
}
