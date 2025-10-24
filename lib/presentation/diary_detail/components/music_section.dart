import 'package:cake/config/size_config.dart';
import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class MusicSection extends StatelessWidget {
  final DiaryDetail diary;
  const MusicSection({super.key, required this.diary});

  @override
  Widget build(BuildContext context) {
    // videoId가 비어있으면 빈 컨테이너 표시
    if (diary.youtubeVideoId.isEmpty) {
      AppLogger.log('videoId가 비어있음');
      return _buildEmptyMusicSection();
    }

    AppLogger.log('videoId: ${diary.youtubeVideoId}');

    return _buildMusicSection();
  }

  Widget _buildEmptyMusicSection() {
    return Container(
      decoration: BoxDecoration(
        color: ColorConfig.white,
        borderRadius: BorderRadius.circular(10),
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
          horizontal: getWidth(16),
          vertical: getHeight(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/icons/music_icon.png',
                  width: getWidth(24),
                  height: getHeight(24),
                ),
                SizedBox(width: getWidth(8)),
                Text(
                  '오늘의 Music',
                  style: TextStyle(
                    fontSize: getHeight(16),
                    fontWeight: FontWeight.w800,
                    color: ColorConfig.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: getHeight(12)),
            Container(
              height: getHeight(200),
              decoration: BoxDecoration(
                color: ColorConfig.gray3,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '유튜브에서 음악을 불러올 수 없어요 😢',
                  style: TextStyle(
                    fontSize: getHeight(14),
                    color: ColorConfig.gray1,
                  ),
                ),
              ),
            ),
            SizedBox(height: getHeight(12)),
            Text(
              diary.musicTitle,
              style: TextStyle(
                fontSize: getHeight(16),
                fontWeight: FontWeight.w800,
                color: ColorConfig.black,
              ),
            ),
            Text(
              diary.musicArtist,
              style: TextStyle(
                fontSize: getHeight(14),
                fontWeight: FontWeight.w400,
                color: ColorConfig.gray1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicSection() {
    return Container(
      decoration: BoxDecoration(
        color: ColorConfig.white,
        borderRadius: BorderRadius.circular(10),
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
          horizontal: getWidth(16),
          vertical: getHeight(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/icons/music_icon.png',
                  width: getWidth(24),
                  height: getHeight(24),
                ),
                SizedBox(width: getWidth(8)),
                Text(
                  '오늘의 Music',
                  style: TextStyle(
                    fontSize: getHeight(16),
                    fontWeight: FontWeight.w800,
                    color: ColorConfig.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: getHeight(12)),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: YoutubePlayer(
                controller: YoutubePlayerController.fromVideoId(
                  videoId: diary.youtubeVideoId,
                  autoPlay: true,
                  params: const YoutubePlayerParams(
                    mute: false,
                    showControls: true,
                    enableCaption: false,
                    showVideoAnnotations: true,
                    loop: true,
                    interfaceLanguage: 'ko',
                    origin: 'https://www.youtube-nocookie.com',
                  ),
                ),
                aspectRatio: 16 / 9,
              ),
            ),
            SizedBox(height: getHeight(12)),
            Text(
              diary.musicTitle,
              style: TextStyle(
                fontSize: getHeight(16),
                fontWeight: FontWeight.w800,
                color: ColorConfig.black,
              ),
            ),
            Text(
              diary.musicArtist,
              style: TextStyle(
                fontSize: getHeight(14),
                fontWeight: FontWeight.w400,
                color: ColorConfig.gray1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
