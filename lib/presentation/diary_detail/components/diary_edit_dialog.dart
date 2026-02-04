import 'package:cake/config/size_config.dart';
import 'package:cake/presentation/diary_detail/components/diary_edit_text_field.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class DiaryEditDialog extends StatelessWidget {
  final TextEditingController textController;
  final FocusNode focusNode;
  final bool Function() isModified;
  final Future<void> Function() onComplete;

  const DiaryEditDialog({
    super.key,
    required this.textController,
    required this.focusNode,
    required this.isModified,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              backgroundColor: ColorConfig.background,
              body: Stack(
                children: [
                  SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(
                              horizontal: getWidth(25),
                              vertical: getHeight(15),
                            ),
                            child: Column(
                              children: [
                                DiaryEditTextField(
                                  textController: textController,
                                  focusNode: focusNode,
                                  isKeyboardVisible: isKeyboardVisible,
                                  hintText: '하고 싶은 말을 자유롭게 적어주세요',
                                ),
                                if (isKeyboardVisible)
                                  SizedBox(height: getHeight(60)),
                              ],
                            ),
                          ),
                        ),
                        if (!isKeyboardVisible) _buildBottomBar(context),
                      ],
                    ),
                  ),
                  if (isKeyboardVisible)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: _buildBottomBar(context),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return ListenableBuilder(
      listenable: textController,
      builder: (context, child) {
        final modified = isModified();
        return Container(
          height: getHeight(56),
          decoration: BoxDecoration(
            color: ColorConfig.background,
            border: Border(
              top: BorderSide(color: ColorConfig.gray4, width: 0.5),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: getWidth(15)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  '취소',
                  style: TextStyle(
                    fontSize: getWidth(16),
                    fontWeight: FontWeight.w600,
                    color: ColorConfig.gray3,
                  ),
                ),
              ),
              Spacer(),
              TextButton.icon(
                onPressed: modified
                    ? () async {
                        await onComplete();
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    : null,
                label: Text('수정 완료'),
                icon: Icon(Icons.check_rounded),
                iconAlignment: IconAlignment.end,
                style: TextButton.styleFrom(
                  foregroundColor: modified
                      ? ColorConfig.primary
                      : ColorConfig.gray2,
                  textStyle: TextStyle(
                    fontSize: getWidth(16),
                    fontWeight: FontWeight.w600,
                    color: modified ? ColorConfig.primary : ColorConfig.gray2,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
