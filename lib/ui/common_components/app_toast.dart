import 'dart:async';

import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/app_dimens.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum ToastTone { info, error }

/// 에러·안내 토스트. 화면 하단(하단 탭·입력 바 위)에 띄운다.
/// 3초 뒤 사라짐, 다시 시도 버튼이 있으면 5초.
class AppToast {
  AppToast._();

  static OverlayEntry? _current;
  static Timer? _timer;

  static void show(
    BuildContext context,
    String message, {
    ToastTone tone = ToastTone.info,
    String? actionLabel,
    VoidCallback? onAction,
    double bottomOffset = 16,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    dismiss();

    final bottomInset = MediaQuery.paddingOf(context).bottom;
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        left: AppSpacing.page,
        right: AppSpacing.page,
        bottom: bottomInset + bottomOffset,
        child: _ToastBody(
          message: message,
          tone: tone,
          actionLabel: actionLabel,
          onAction: onAction == null
              ? null
              : () {
                  dismiss();
                  onAction();
                },
        ),
      ),
    );
    _current = entry;
    overlay.insert(entry);
    _timer = Timer(
      Duration(seconds: actionLabel != null ? 5 : 3),
      dismiss,
    );
  }

  static void dismiss() {
    _timer?.cancel();
    _timer = null;
    _current?.remove();
    _current = null;
  }
}

class _ToastBody extends StatefulWidget {
  final String message;
  final ToastTone tone;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _ToastBody({
    required this.message,
    required this.tone,
    this.actionLabel,
    this.onAction,
  });

  @override
  State<_ToastBody> createState() => _ToastBodyState();
}

class _ToastBodyState extends State<_ToastBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.only(
              left: 16,
              right: 12,
              top: 14,
              bottom: 14,
            ),
            decoration: BoxDecoration(
              color: ColorConfig.bgToast,
              borderRadius: AppRadius.circular(AppRadius.md),
              boxShadow: AppShadows.toast,
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  widget.tone == ToastTone.error
                      ? AppImages.toastIconError
                      : AppImages.toastIconInfo,
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.message,
                    style: TextConfig.bodyS.copyWith(
                      color: ColorConfig.textOnDark,
                    ),
                  ),
                ),
                if (widget.actionLabel != null)
                  GestureDetector(
                    onTap: widget.onAction,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        widget.actionLabel!,
                        style: TextConfig.labelStrong.copyWith(
                          color: ColorConfig.brandPink,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
