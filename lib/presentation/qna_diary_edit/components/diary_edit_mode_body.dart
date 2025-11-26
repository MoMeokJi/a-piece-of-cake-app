import 'package:cake/config/size_config.dart';
import 'package:cake/presentation/free_diary_create/components/diary_text_field.dart';
import 'package:cake/presentation/qna_diary_edit/components/edit_mode_bottom_fixed_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class DiaryEditModeBody extends StatelessWidget {
  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final VoidCallback onCompleted;
  final VoidCallback unfocus;
  const DiaryEditModeBody({
    super.key,
    required this.textEditingController,
    required this.focusNode,
    required this.onCompleted,
    required this.unfocus,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: unfocus,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: getWidth(25),
                    vertical: getHeight(15),
                  ),
                  child: DiaryTextField(
                    textController: textEditingController,
                    focusNode: focusNode,
                    isKeyboardVisible: isKeyboardVisible,
                  ),
                ),
              ),
            ),

            // 수정 완료 버튼 영역
            EditModeBottomFixedBar(onCompleted: onCompleted),
          ],
        );
      },
    );
  }
}
