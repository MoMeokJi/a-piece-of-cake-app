import 'package:cake/domain/enum/social_provider.dart';
import 'package:cake/ui/common_components/app_spinner.dart';
import 'package:cake/ui/style/app_dimens.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Apple(검정) / Google(흰 바탕 + 테두리). 로고는 공식 브랜드 리소스.
class SocialLoginButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SocialLoginButton({
    super.key,
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
  });

  bool get _isApple => provider == SocialProvider.apple;

  @override
  Widget build(BuildContext context) {
    final foreground = _isApple
        ? ColorConfig.textOnDark
        : ColorConfig.textPrimary;
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: Material(
        color: _isApple ? ColorConfig.actionDark : ColorConfig.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circular(AppRadius.md),
          side: _isApple
              ? BorderSide.none
              : const BorderSide(color: ColorConfig.borderDefault),
        ),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: AppRadius.circular(AppRadius.md),
          child: Center(
            child: isLoading
                ? AppSpinner(color: foreground)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        _isApple
                            ? 'assets/icons/brand/apple.svg'
                            : 'assets/icons/brand/google.svg',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${provider.displayName}로 계속하기',
                        style: TextConfig.bodyL.copyWith(color: foreground),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
