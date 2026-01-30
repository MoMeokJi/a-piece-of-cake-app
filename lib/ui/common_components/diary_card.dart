import 'package:cake/config/size_config.dart';
import 'package:cake/core/extensions/color_extensions.dart';
import 'package:cake/domain/model/diary.dart';
import 'package:cake/ui/common_components/custom_divider.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:cake/utils/date_converter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DiaryCard extends StatelessWidget {
  final Diary diary;
  const DiaryCard({super.key, required this.diary});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/diary-detail', extra: diary.id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: ColorConfig.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: ColorConfig.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: getWidth(25),
            vertical: getHeight(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 날짜
              Text(
                DateConverter.dateToDateString(diary.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: ColorConfig.diaryDateColor,
                  fontWeight: FontWeight.w400,
                ),
              ),

              // 일기 내용
              Padding(
                padding: EdgeInsets.symmetric(vertical: getHeight(5)),
                child: Text(
                  diary.summary,
                  style: const TextStyle(
                    fontSize: TextConfig.diaryDefaultFontSize,
                    color: ColorConfig.diarySummaryColor,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: getHeight(5)),
              CustomDivider(),
              SizedBox(height: getHeight(10)),

              Row(
                children: [
                  _colorCircle(diary.firstColorHex),
                  SizedBox(width: getWidth(8)),
                  _colorCircle(diary.secondColorHex),
                  SizedBox(width: getWidth(20)),

                  // Expanded로 남은 공간을 다 차지하게 하고 그 안에서 음악 정보를 오른쪽 정렬. 길어지면 ...처리
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.headphones,
                          size: getWidth(16),
                          color: ColorConfig.diaryMusicTextColor,
                        ),
                        SizedBox(width: getWidth(3)),
                        Flexible(
                          child: Text(
                            '${diary.musicTitle} - ${diary.musicArtist}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: ColorConfig.diaryMusicTextColor,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _colorCircle(String colorHex) {
    return Container(
      width: getWidth(16),
      height: getHeight(16),
      decoration: BoxDecoration(
        color: colorHex.toColor(),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: ColorConfig.black.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}
