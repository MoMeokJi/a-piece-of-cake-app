import 'package:cake/config/service_config.dart';
import 'package:cake/domain/model/local_image.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// 작성 화면의 사진 첨부 상태. 최대 [ServiceConfig.maxImageCount]장.
class ImageAttachments extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  final List<LocalImage> _images = [];
  List<LocalImage> get images => List.unmodifiable(_images);

  int get count => _images.length;
  int get max => ServiceConfig.maxImageCount;
  bool get isFull => _images.length >= max;

  String? _message;
  String? get message => _message;

  Future<void> pickFromGallery() async {
    if (isFull) return _notifyFull();
    try {
      final picked = await _picker.pickMultiImage();
      _add(picked);
    } catch (e) {
      AppLogger.error('앨범 선택 실패: $e');
    }
  }

  Future<void> pickFromCamera() async {
    if (isFull) return _notifyFull();
    try {
      final picked = await _picker.pickImage(source: ImageSource.camera);
      if (picked != null) _add([picked]);
    } catch (e) {
      AppLogger.error('카메라 촬영 실패: $e');
    }
  }

  void _add(List<XFile> files) {
    if (files.isEmpty) return;
    final remaining = max - _images.length;
    _images.addAll(files.take(remaining).map((f) => LocalImage(f.path)));
    if (files.length > remaining) {
      _message = '사진은 $max장까지 첨부할 수 있어요';
    }
    notifyListeners();
  }

  void _notifyFull() {
    _message = '사진은 $max장까지 첨부할 수 있어요';
    notifyListeners();
  }

  void removeAt(int index) {
    _images.removeAt(index);
    notifyListeners();
  }

  void clearMessage() => _message = null;
}
