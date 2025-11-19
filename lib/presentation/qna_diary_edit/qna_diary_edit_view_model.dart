import 'package:cake/config/di.dart';
import 'package:cake/config/service_config.dart';
import 'package:cake/domain/enum/diary_type.dart';
import 'package:cake/domain/enum/result_state.dart';
import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/domain/repository/diary_repository.dart';
import 'package:cake/presentation/diary_calendar/diary_calendar_view_model.dart';
import 'package:cake/presentation/diary_list/diary_list_view_model.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class QnaDiaryEditViewModel with ChangeNotifier {
  final DiaryRepository _diaryRepo;

  QnaDiaryEditViewModel({required DiaryRepository diaryRepo})
    : _diaryRepo = diaryRepo;

  final TextEditingController _textController = TextEditingController();
  TextEditingController get textController => _textController;

  final FocusNode _focusNode = FocusNode();
  FocusNode get focusNode => _focusNode;

  final ImagePicker _picker = ImagePicker();

  final List<XFile> _pickedImages = [];
  List<XFile> get pickedImages => _pickedImages;

  DiaryDetail? _completedDiary;
  DiaryDetail? get completedDiary => _completedDiary;

  ResultState _resultState = ResultState.none;
  ResultState get state => _resultState;

  String? _toastMessage;
  String? get toastMessage => _toastMessage;

  bool _isEditMode = false;
  bool get isEditMode => _isEditMode;

  void initialize(String initialContent) {
    textController.text = initialContent; // 텍스트필드 초기값으로 생성된 일기 지정
  }

  Future<void> completeDiary() async {
    unfocus();
    if (_textController.text.length < ServiceConfig.minDiaryLength) {
      _toastMessage = '일기는 ${ServiceConfig.minDiaryLength}자 이상 작성해주세요';
      notifyListeners();
      return;
    } else if (_pickedImages.isEmpty) {
      _toastMessage = '1장 이상의 사진을 첨부해야합니다';
      notifyListeners();
      return;
    }

    try {
      _resultState = ResultState.loading;
      notifyListeners();

      _completedDiary = await _diaryRepo.saveDiary(
        diaryType: DiaryType.qna,
        text: _textController.text,
        images: _pickedImages,
      );
      AppLogger.log(_completedDiary.toString());

      final diaryCalendarVM = getIt<DiaryCalendarViewModel>();
      await diaryCalendarVM.initialize();
      final diaryListVM = getIt<DiaryListViewModel>();
      await diaryListVM.loadDiaryList();

      _resultState = ResultState.success;
    } catch (e) {
      _toastMessage = '일기 작성에 실패했습니다';
      _resultState = ResultState.error;
      AppLogger.error('자유 일기 작성 에러: ${e.toString()}');
    }
    notifyListeners();
  }

  void changeToEditMode() {
    _isEditMode = true;
    notifyListeners();
  }

  Future<void> getImageFromGallery() async {
    if (_pickedImages.length >= ServiceConfig.maxImageCount) {
      _toastMessage = '사진은 ${ServiceConfig.maxImageCount}장까지 첨부 가능합니다';
      notifyListeners();
      return;
    }

    final images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      await _addImages(images);
    }
  }

  Future<void> getImageFromCamera() async {
    if (_pickedImages.length >= ServiceConfig.maxImageCount) {
      _toastMessage = '사진은 ${ServiceConfig.maxImageCount}장까지 첨부 가능합니다';
      notifyListeners();
      return;
    }

    final image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      await _addImages([image]);
    }
  }

  Future<void> _addImages(List<XFile> newImages) async {
    final remainingSlots = ServiceConfig.maxImageCount - _pickedImages.length;

    if (remainingSlots <= 0) {
      _toastMessage = '사진은 ${ServiceConfig.maxImageCount}장까지 첨부 가능합니다';
      notifyListeners();
      return;
    }

    final imagesToAdd = newImages.take(remainingSlots).toList();
    _pickedImages.addAll(imagesToAdd);

    if (newImages.length > remainingSlots) {
      _toastMessage = '사진은 ${ServiceConfig.maxImageCount}장까지 첨부 가능합니다';
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

  // 토스트 메시지 초기화 메서드
  void clearToastMessage() {
    _toastMessage = null;
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
