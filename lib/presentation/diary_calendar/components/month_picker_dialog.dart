import 'package:cake/config/size_config.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MonthPickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final int minYear;
  final int maxYear;
  final Function(DateTime) onDateSelected;

  const MonthPickerDialog({
    super.key,
    required this.initialDate,
    required this.minYear,
    required this.maxYear,
    required this.onDateSelected,
  });

  @override
  State<MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<MonthPickerDialog> {
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialDate.year;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return AlertDialog(
      content: SizedBox(
        width: screenSize.width * 0.8, // 화면 너비의 80%
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: selectedYear > widget.minYear
                      ? () => setState(() => selectedYear--)
                      : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  '$selectedYear년',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: selectedYear < widget.maxYear
                      ? () => setState(() => selectedYear++)
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            SizedBox(height: getHeight(15)),
            // 월 선택 그리드
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = index + 1;
                final isSelected =
                    month == widget.initialDate.month &&
                    selectedYear == widget.initialDate.year;

                return GestureDetector(
                  onTap: () {
                    final selectedDate = DateTime(selectedYear, month, 1);
                    widget.onDateSelected(selectedDate);
                    context.pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? ColorConfig.primary
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? ColorConfig.primary
                            : ColorConfig.border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$month월',
                        style: TextStyle(
                          color: isSelected
                              ? ColorConfig.white
                              : ColorConfig.gray1,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
