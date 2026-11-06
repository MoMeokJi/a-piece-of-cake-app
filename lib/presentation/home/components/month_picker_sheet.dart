import 'package:cake/ui/common_components/app_bottom_sheet.dart';
import 'package:cake/ui/common_components/app_button.dart';
import 'package:cake/ui/style/app_dimens.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';

/// A-2-1 연·월 선택 휠 시트
class MonthPickerSheet {
  MonthPickerSheet._();

  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initial,
    required int minYear,
    required int maxYear,
  }) {
    return AppBottomSheet.show<DateTime>(
      context,
      builder: (context) => _MonthPickerBody(
        initial: initial,
        minYear: minYear,
        maxYear: maxYear,
      ),
    );
  }
}

class _MonthPickerBody extends StatefulWidget {
  final DateTime initial;
  final int minYear;
  final int maxYear;

  const _MonthPickerBody({
    required this.initial,
    required this.minYear,
    required this.maxYear,
  });

  @override
  State<_MonthPickerBody> createState() => _MonthPickerBodyState();
}

class _MonthPickerBodyState extends State<_MonthPickerBody> {
  late int _year = widget.initial.year;
  late int _month = widget.initial.month;
  late final FixedExtentScrollController _yearController =
      FixedExtentScrollController(initialItem: _year - widget.minYear);
  late final FixedExtentScrollController _monthController =
      FixedExtentScrollController(initialItem: _month - 1);

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final years = [for (var y = widget.minYear; y <= widget.maxYear; y++) y];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('날짜 이동', style: TextConfig.titleM),
        const SizedBox(height: 20),
        SizedBox(
          height: 220,
          child: Stack(
            children: [
              Center(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: ColorConfig.bgSubtle,
                    borderRadius: AppRadius.circular(AppRadius.sm),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _Wheel(
                      controller: _yearController,
                      items: [for (final y in years) '$y년'],
                      selectedIndex: _year - widget.minYear,
                      onChanged: (i) => setState(() => _year = years[i]),
                    ),
                  ),
                  Expanded(
                    child: _Wheel(
                      controller: _monthController,
                      items: [for (var m = 1; m <= 12; m++) '$m월'],
                      selectedIndex: _month - 1,
                      onChanged: (i) => setState(() => _month = i + 1),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AppButton(
          label: '이동하기',
          onPressed: () => Navigator.of(context).pop(DateTime(_year, _month, 1)),
        ),
      ],
    );
  }
}

class _Wheel extends StatelessWidget {
  final FixedExtentScrollController controller;
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _Wheel({
    required this.controller,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 44,
      physics: const FixedExtentScrollPhysics(),
      diameterRatio: 100, // 평면에 가깝게
      overAndUnderCenterOpacity: 0.45,
      onSelectedItemChanged: onChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: items.length,
        builder: (context, index) {
          final selected = index == selectedIndex;
          return Center(
            child: Text(
              items[index],
              style: selected
                  ? TextConfig.numberL
                  : TextConfig.numberM.copyWith(
                      color: ColorConfig.textTertiary,
                    ),
            ),
          );
        },
      ),
    );
  }
}
