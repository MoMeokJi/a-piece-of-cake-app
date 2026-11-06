import 'package:cake/ui/common_components/app_icon.dart';
import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/app_dimens.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 한 줄 입력창. 높이 56, 모서리 16. 포커스=블루 1, 오류=빨강 2.
/// 오른쪽에 카운터(현재/최대)와 지우기 버튼.
class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final int maxLength;
  final bool hasError;
  final String? hintText;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const AppTextField({
    super.key,
    required this.controller,
    required this.maxLength,
    this.focusNode,
    this.hasError = false,
    this.hintText,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_rebuild);
    widget.controller.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _focusNode.removeListener(_rebuild);
    widget.controller.removeListener(_rebuild);
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final length = widget.controller.text.characters.length;
    final borderColor = widget.hasError
        ? ColorConfig.textDanger
        : _focusNode.hasFocus
        ? ColorConfig.borderFocus
        : ColorConfig.borderDefault;
    final borderWidth = widget.hasError ? 2.0 : 1.0;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: ColorConfig.bgSurface,
        borderRadius: AppRadius.circular(AppRadius.lg),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      padding: const EdgeInsets.only(left: 16, right: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              style: TextConfig.input,
              cursorColor: ColorConfig.brandBlue,
              textInputAction: TextInputAction.done,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: widget.hintText,
                hintStyle: TextConfig.input.copyWith(
                  color: ColorConfig.textDisabled,
                ),
                contentPadding: EdgeInsets.zero,
                counterText: '',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$length/${widget.maxLength}',
            style: TextConfig.numberS.copyWith(
              color: widget.hasError
                  ? ColorConfig.textDanger
                  : ColorConfig.textTertiary,
            ),
          ),
          AppIconButton(
            icon: AppIcons.clear,
            iconSize: 20,
            color: ColorConfig.textDisabled,
            semanticLabel: '지우기',
            onPressed: () {
              widget.controller.clear();
              widget.onChanged?.call('');
            },
          ),
        ],
      ),
    );
  }
}

enum FieldMessageType { valid, error, hint }

/// 입력창 아래 메시지.
class FieldMessage extends StatelessWidget {
  final String message;
  final FieldMessageType type;

  const FieldMessage({super.key, required this.message, required this.type});

  @override
  Widget build(BuildContext context) {
    final color = switch (type) {
      FieldMessageType.valid => ColorConfig.textSuccess,
      FieldMessageType.error => ColorConfig.textDanger,
      FieldMessageType.hint => ColorConfig.textSecondary,
    };
    final iconAsset = switch (type) {
      FieldMessageType.valid => AppImages.fieldIconValid,
      FieldMessageType.error => AppImages.fieldIconError,
      FieldMessageType.hint => null,
    };
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          if (iconAsset != null) ...[
            SvgPicture.asset(iconAsset, width: 16, height: 16),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(message, style: TextConfig.label.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}
