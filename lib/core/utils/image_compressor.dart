import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageCompressor {
  /// Compresses an image to target size in KB
  /// [quality] 0-100, lower = smaller file
  static Future<String> compress(
    String imagePath, {
    int quality = 70,
    int maxWidth = 1024,
    int maxHeight = 1024,
  }) async {
    final dir = await getTemporaryDirectory();
    final ext = path.extension(imagePath);
    final fileName = '${path.basenameWithoutExtension(imagePath)}_compressed$ext';
    final targetPath = '${dir.path}/$fileName';

    final result = await FlutterImageCompress.compressAndGetFile(
      imagePath,
      targetPath,
      quality: quality,
      minWidth: maxWidth,
      minHeight: maxHeight,
      format: CompressFormat.jpeg,
    );

    if (result == null) return imagePath; // fallback to original
    
    // Log compression result
    final original = File(imagePath).lengthSync();
    final compressed = File(result.path).lengthSync();
    print('📦 Compressed: ${_toKb(original)}KB → ${_toKb(compressed)}KB');

    return result.path;
  }

  static String _toKb(int bytes) => (bytes / 1024).toStringAsFixed(1);
}