import 'package:cake/config/size_config.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CommonMainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? titleText;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final bool allowPop;
  final bool centerTitle;

  const CommonMainAppBar({
    this.titleText,
    this.titleWidget,
    this.actions,
    this.allowPop = true,
    this.centerTitle = true,
    super.key,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ColorConfig.background,
      surfaceTintColor: Colors.transparent, //surface tint 투명하게

      scrolledUnderElevation: 0,

      centerTitle: centerTitle,
      leading: (allowPop)
          ? IconButton(
              icon: const Icon(Icons.chevron_left),
              color: ColorConfig.black,
              iconSize: getWidth(28),
              onPressed: () {
                FocusScope.of(context).unfocus(); // 모든 포커스 해제
                context.pop();
              },
            )
          : null,
      title: titleText != null
          ? Text(
              '$titleText',
              style: TextStyle(
                fontSize: getWidth(16),
                fontWeight: FontWeight.bold,
              ),
            )
          : titleWidget,
      actions: [if (actions != null) ...actions!],
    );
  }
}
