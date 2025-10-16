import 'package:cake/domain/enum/result_state.dart';
import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/domain/repository/diary_repository.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FreeDiaryCreateViewModel with ChangeNotifier {
  final DiaryRepository _diaryRepo;

  FreeDiaryCreateViewModel({required DiaryRepository diaryRepo})
    : _diaryRepo = diaryRepo;

  final TextEditingController _textController = TextEditingController();
  TextEditingController get textController => _textController;

  final FocusNode _focusNode = FocusNode();
  FocusNode get focusNode => _focusNode;

  final int _maxImgLength = 4;
  int get maxImgLength => _maxImgLength;

  final ImagePicker _picker = ImagePicker();

  final List<XFile> _pickedImages = [];
  List<XFile> get pickedImages => _pickedImages;

  DiaryDetail? _completedDiary;
  DiaryDetail? get completedDiary => _completedDiary;

  ResultState _resultState = ResultState.none;
  ResultState get state => _resultState;

  Future<void> writeFreeDiary() async {
    unfocus();
    if (_textController.text.isEmpty) {
      AppLogger.log('일기는 30자 이상 작성해주세요');
      return;
    } else if (_pickedImages.isEmpty) {
      AppLogger.log('1장 이상의 사진을 첨부해야합니다');
      return;
    }
    try {
      _resultState = ResultState.loading;
      notifyListeners();

      _completedDiary = await _diaryRepo.completeDiary(
        text: _textController.text,
        images: _pickedImages,
      );

      _resultState = ResultState.success;
    } catch (e) {
      _resultState = ResultState.error;
      AppLogger.error('자유 일기 작성 에러: ${e.toString()}');
    }
    notifyListeners();
  }

  Future<void> getImageFromGallery() async {
    if (_pickedImages.length >= _maxImgLength) {
      AppLogger.log('사진은 $_maxImgLength징까지 첨부 가능합니다');
      return;
    }

    final images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      await _addImages(images);
    }
  }

  Future<void> getImageFromCamera() async {
    if (_pickedImages.length >= _maxImgLength) {
      AppLogger.log('사진은 $_maxImgLength징까지 첨부 가능합니다');
      return;
    }

    final image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      await _addImages([image]);
    }
  }

  Future<void> _addImages(List<XFile> newImages) async {
    final remainingSlots = _maxImgLength - _pickedImages.length;

    if (remainingSlots <= 0) {
      AppLogger.log('사진은 $_maxImgLength징까지 첨부 가능합니다');
      return;
    }

    final imagesToAdd = newImages.take(remainingSlots).toList();
    _pickedImages.addAll(imagesToAdd);

    if (newImages.length > remainingSlots) {
      AppLogger.log('사진은 $_maxImgLength징까지 첨부 가능합니다');
    }

    notifyListeners();
  }

  void removeImage(int index) {
    _pickedImages.removeAt(index);
    notifyListeners();
  }

  void unfocus() {
    _focusNode.unfocus();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
