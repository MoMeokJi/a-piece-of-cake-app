import 'package:cake/ui/common_components/app_icon.dart';
import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';

enum ListRowType { link, value, static_, danger }

/// 마이페이지 설정 행. 높이 48. [trailing]을 주면 type의 기본 trailing 대신 쓴다.
class ListRow extends StatelessWidget {
  final String label;
  final ListRowType type;
  final String? value;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ListRow({
    super.key,
    required this.label,
    this.type = ListRowType.link,
    this.value,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final showChevron = type == ListRowType.link || type == ListRowType.value;
    final showValue = type == ListRowType.value || type == ListRowType.static_;
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 48,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextConfig.bodyM.copyWith(
                    color: type == ListRowType.danger
                        ? ColorConfig.textDanger
                        : ColorConfig.textPrimary,
                  ),
                ),
              ),
              if (trailing != null)
                trailing!
              else ...[
                if (showValue && value != null)
                  Text(
                    value!,
                    style: TextConfig.bodyS.copyWith(
                      color: ColorConfig.textSecondary,
                    ),
                  ),
                if (showValue && showChevron) const SizedBox(width: 4),
                if (showChevron)
                  const AppIcon(
                    AppIcons.chevronRight,
                    size: 18,
                    color: ColorConfig.textSecondary,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 흰 카드 안에 ListRow를 쌓고 사이에 얇은 구분선을 둔다.
class ListRowGroup extends StatelessWidget {
  final String? heading;
  final List<Widget> rows;

  const ListRowGroup({super.key, this.heading, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (heading != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              heading!,
              style: TextConfig.label.copyWith(
                color: ColorConfig.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: ColorConfig.bgSurface,
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: ColorConfig.borderSubtle,
                    ),
                  rows[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
