
import 'package:image_picker/image_picker.dart';
import '../../domain/repositories/document_capture_repository.dart';

class DocumentCaptureRepositoryImpl implements DocumentCaptureRepository {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<String?> captureDocument(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1920,
    );

    return image?.path;
  }
}