import 'package:cake/config/api_config.dart';
import 'package:cake/ui/common_components/app_bottom_sheet.dart';
import 'package:cake/ui/common_components/app_button.dart';
import 'package:cake/ui/common_components/app_checkbox.dart';
import 'package:cake/ui/common_components/app_icon.dart';
import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/app_dimens.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:cake/utils/external_links.dart';
import 'package:flutter/material.dart';

class TermsResult {
  final bool notificationOptIn;
  const TermsResult({required this.notificationOptIn});
}

/// A-8 약관 동의 바텀시트. 필수 두 개에 동의해야 버튼이 켜진다.
class TermsSheet {
  TermsSheet._();

  static Future<TermsResult?> show(BuildContext context) {
    return AppBottomSheet.show<TermsResult>(
      context,
      builder: (context) => const _TermsBody(),
    );
  }
}

class _TermsBody extends StatefulWidget {
  const _TermsBody();

  @override
  State<_TermsBody> createState() => _TermsBodyState();
}

class _TermsBodyState extends State<_TermsBody> {
  bool _service = false;
  bool _privacy = false;
  bool _notification = false;

  bool get _all => _service && _privacy && _notification;
  bool get _required => _service && _privacy;

  void _toggleAll(bool value) => setState(() {
    _service = value;
    _privacy = value;
    _notification = value;
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('조각케이크 이용을 위해\n약관에 동의해 주세요', style: TextConfig.titleL),
        const SizedBox(height: 20),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _toggleAll(!_all),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: ColorConfig.bgSubtle,
              borderRadius: AppRadius.circular(AppRadius.lg),
            ),
            child: Row(
              children: [
                AppCheckbox(checked: _all, onChanged: _toggleAll),
                const SizedBox(width: 12),
                Text('전체 동의하기', style: TextConfig.bodyLStrong),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        _TermsItem(
          checked: _service,
          onChanged: (v) => setState(() => _service = v),
          prefix: '[필수]',
          prefixColor: ColorConfig.textAccent,
          label: '서비스 이용약관',
          onView: () => ExternalLinks.open(ApiConfig.serviceTermUrl),
        ),
        _TermsItem(
          checked: _privacy,
          onChanged: (v) => setState(() => _privacy = v),
          prefix: '[필수]',
          prefixColor: ColorConfig.textAccent,
          label: '개인정보 수집 및 이용',
          onView: () => ExternalLinks.open(ApiConfig.privacyPolicyUrl),
        ),
        _TermsItem(
          checked: _notification,
          onChanged: (v) => setState(() => _notification = v),
          prefix: '[선택]',
          prefixColor: ColorConfig.textTertiary,
          label: '기록 알림 받기',
        ),
        const SizedBox(height: 20),
        AppButton(
          label: '동의하고 시작하기',
          enabled: _required,
          onPressed: () => Navigator.of(
            context,
          ).pop(TermsResult(notificationOptIn: _notification)),
        ),
      ],
    );
  }
}

class _TermsItem extends StatelessWidget {
  final bool checked;
  final ValueChanged<bool> onChanged;
  final String prefix;
  final Color prefixColor;
  final String label;
  final VoidCallback? onView;

  const _TermsItem({
    required this.checked,
    required this.onChanged,
    required this.prefix,
    required this.prefixColor,
    required this.label,
    this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(!checked),
              child: Row(
                children: [
                  AppCheckbox(checked: checked, onChanged: onChanged, size: 20),
                  const SizedBox(width: 12),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: prefix,
                          style: TextConfig.bodyM.copyWith(color: prefixColor),
                        ),
                        TextSpan(text: ' $label', style: TextConfig.bodyM),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (onView != null)
            AppIconButton(
              icon: AppIcons.chevronRight,
              iconSize: 18,
              color: ColorConfig.textSecondary,
              semanticLabel: '$label 보기',
              onPressed: onView,
            )
          else
            const SizedBox(width: 44),
        ],
      ),
    );
  }
}
