import 'package:cake/ui/common_components/app_icon.dart';
import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 상단 바. 뒤로가기 + 가운데 제목(+부제) + 오른쪽 trailing(44×44 슬롯).
/// 상태바 영역은 포함하지 않는다. SafeArea 안에서 쓴다.
class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final bool showBack;
  final Widget? trailing;
  final Color backgroundColor;

  const TopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.showBack = true,
    this.trailing,
    this.backgroundColor = Colors.transparent,
  });

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          if (showBack)
            AppIconButton(
              icon: AppIcons.back,
              semanticLabel: '뒤로가기',
              onPressed: () {
                FocusScope.of(context).unfocus();
                if (onBack != null) {
                  onBack!();
                } else if (context.canPop()) {
                  context.pop();
                }
              },
            )
          else
            const SizedBox(width: 44),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextConfig.titleS,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextConfig.caption.copyWith(
                      color: ColorConfig.textSecondary,
                    ),
                    maxLines: 1,
                  ),
              ],
            ),
          ),
          SizedBox(width: 44, height: 44, child: trailing),
        ],
      ),
    );
  }
}
