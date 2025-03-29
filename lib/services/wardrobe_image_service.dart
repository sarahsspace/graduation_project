import 'dart:io';
import 'package:image_picker/image_picker.dart';

class WardrobeImageService {
  final ImagePicker _picker = ImagePicker();

  /// Capture images using the camera until the limit is reached
  Future<List<File>> captureImages(int currentCount, int maxImages) async {
    List<File> images = [];
    while (currentCount + images.length < maxImages) {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        images.add(File(photo.path));
      } else {
        // User cancelled the camera
        break;
      }
    }
    return images;
  }

  /// Pick multiple images from the gallery with a limit
  Future<List<File>> pickImagesFromGallery(int currentCount, int maxImages) async {
    final List<XFile>? files = await _picker.pickMultiImage();
    if (files != null) {
      int availableSlots = maxImages - currentCount;
      List<XFile> selectedFiles = files.take(availableSlots).toList();
      return selectedFiles.map((xfile) => File(xfile.path)).toList();
    }
    return [];
  }
}
