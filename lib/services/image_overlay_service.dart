import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

class ImageOverlayService {
  // Create personalized quote image using Flutter rendering
  Future<File> createPersonalizedQuote({
    required GlobalKey repaintBoundaryKey,
  }) async {
    try {
      // Get the RenderRepaintBoundary
      RenderRepaintBoundary boundary =
          repaintBoundaryKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      // Convert to image
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);

      // Convert to bytes
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/personalized_quote_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(pngBytes);

      return file;
    } catch (e) {
      throw Exception('Failed to create personalized quote: $e');
    }
  }

  // Save quote to permanent storage
  Future<Map<String, String>> saveQuoteToPermanentStorage(File tempFile) async {
    try {
      // Save to gallery (visible to user)
      await Gal.putImage(tempFile.path);

      // Also save to app directory for local tracking
      final appDir = await getApplicationDocumentsDirectory();
      final quotesDir = Directory('${appDir.path}/saved_quotes');

      if (!await quotesDir.exists()) {
        await quotesDir.create(recursive: true);
      }

      final fileName = 'quote_${DateTime.now().millisecondsSinceEpoch}.png';
      final savedFile = await tempFile.copy('${quotesDir.path}/$fileName');

      return {'gallery': 'saved_to_gallery', 'local': savedFile.path};
    } catch (e) {
      throw Exception('Failed to save quote: $e');
    }
  }
}
