import 'dart:io';
import 'package:share_plus/share_plus.dart';

class ShareService {
  // Share quote image
  Future<void> shareQuote(File imageFile, {String? text}) async {
    try {
      await Share.shareXFiles(
        [XFile(imageFile.path)],
        text: text ?? 'Check out this personalized quote!',
      );
    } catch (e) {
      throw Exception('Failed to share quote: $e');
    }
  }

  // Share text only
  Future<void> shareText(String text) async {
    try {
      await Share.share(text);
    } catch (e) {
      throw Exception('Failed to share text: $e');
    }
  }
}
