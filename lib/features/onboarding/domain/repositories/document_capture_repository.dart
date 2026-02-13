import 'package:image_picker/image_picker.dart';

abstract class DocumentCaptureRepository {
  Future<String?> captureDocument(ImageSource source);
}