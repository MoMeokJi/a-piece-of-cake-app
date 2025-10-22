import 'package:cake/config/size_config.dart';
import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class MusicSection extends StatefulWidget {
  final DiaryDetail diary;
  const MusicSection({super.key, required this.diary});

  @override
  State<MusicSection> createState() => _MusicSectionState();
}

class _MusicSectionState extends State<MusicSection> {
  late YoutubePlayerController _controller;

  String _extractYoutubeId(String url) {
    final uri = Uri.parse(url);

    if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'] ?? '';
    }

    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
    }

    return '';
  }

  @override
  void initState() {
    super.initState();
    final videoId = _extractYoutubeId(widget.diary.youtubeUrl);

    AppLogger.log('비디오 ID: $videoId');
    AppLogger.log('원본 URL: ${widget.diary.youtubeUrl}');

    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
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
    );
  }

  @override
  Widget build(BuildContext context) {
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
                controller: _controller,
                aspectRatio: 16 / 9,
              ),
            ),
            SizedBox(height: getHeight(12)),
            Text(
              widget.diary.musicTitle,
              style: TextStyle(
                fontSize: getHeight(16),
                fontWeight: FontWeight.w800,
                color: ColorConfig.black,
              ),
            ),
            Text(
              widget.diary.musicArtist,
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
