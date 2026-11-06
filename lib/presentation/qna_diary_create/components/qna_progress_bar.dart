import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';

class QnaProgressBar extends StatelessWidget {
  final double progress;
  final String label;

  const QnaProgressBar({super.key, required this.progress, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: SizedBox(
              height: 4,
              child: Stack(
                children: [
                  const ColoredBox(
                    color: ColorConfig.bgSegment,
                    child: SizedBox.expand(),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0, 1),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: AppGradients.brand,
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextConfig.numberS.copyWith(color: ColorConfig.textAccent),
        ),
      ],
    );
  }
}
