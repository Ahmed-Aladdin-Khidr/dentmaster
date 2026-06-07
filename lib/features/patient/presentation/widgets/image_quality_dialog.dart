import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/pending_image.dart';

class ImageQualityDialog extends StatelessWidget {
  final Uint8List originalBytes;
  final Uint8List compressedBytes;
  final String fileName;

  const ImageQualityDialog._({
    required this.originalBytes,
    required this.compressedBytes,
    required this.fileName,
  });

  /// Shows the dialog and returns the chosen [PendingImage], or null if cancelled.
  static Future<PendingImage?> show(
    BuildContext context, {
    required Uint8List originalBytes,
    required Uint8List compressedBytes,
    required String fileName,
  }) {
    return showDialog<PendingImage>(
      context: context,
      builder: (_) => ImageQualityDialog._(
        originalBytes: originalBytes,
        compressedBytes: compressedBytes,
        fileName: fileName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compressedIsSmaller =
        compressedBytes.length < originalBytes.length;

    return AlertDialog(
      title: const Text('Choose Image Quality'),
      content: SizedBox(
        width: 560,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _QualityColumn(
                label: 'Original',
                bytes: originalBytes,
                isBetter: !compressedIsSmaller,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _QualityColumn(
                label: 'Compressed',
                bytes: compressedBytes,
                isBetter: compressedIsSmaller,
                note: compressedIsSmaller
                    ? null
                    : 'Larger than original',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (compressedIsSmaller)
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(PendingImage(
              bytes: compressedBytes,
              fileName: fileName,
              isCompressed: true,
            )),
            child: const Text('Use Compressed'),
          ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(PendingImage(
            bytes: originalBytes,
            fileName: fileName,
            isCompressed: false,
          )),
          child: const Text('Keep Original'),
        ),
      ],
    );
  }
}

// ── Private helper ──────────────────────────────────────────────────────────

class _QualityColumn extends StatelessWidget {
  final String label;
  final Uint8List bytes;
  final bool isBetter;
  final String? note;

  const _QualityColumn({
    required this.label,
    required this.bytes,
    required this.isBetter,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: isBetter ? FontWeight.bold : FontWeight.normal,
            color: isBetter ? theme.colorScheme.primary : null,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            bytes,
            height: 180,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox(
              height: 180,
              child: Center(child: Icon(Icons.broken_image, size: 48)),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _formatBytes(bytes.length),
          style: theme.textTheme.bodySmall,
        ),
        if (note != null) ...[
          const SizedBox(height: 4),
          Text(
            note!,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: Colors.orange[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  static String _formatBytes(int b) {
    if (b < 1024) return '$b B';
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(1)} KB';
    return '${(b / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
