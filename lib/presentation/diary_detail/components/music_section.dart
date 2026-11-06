import 'package:cake/domain/model/diary_music.dart';
import 'package:cake/ui/common_components/app_chip.dart';
import 'package:cake/ui/common_components/section_title.dart';
import 'package:cake/ui/common_components/surface_card.dart';
import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/app_dimens.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// 오늘의 음악. 유튜브 플레이어 + 곡 정보. videoId가 없으면 오류 상태.
class MusicSection extends StatelessWidget {
  final DiaryMusic music;
  final int attempt;
  final VoidCallback onRetry;

  const MusicSection({
    super.key,
    required this.music,
    required this.attempt,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionTitle(iconAsset: AppImages.iconMusic, title: '오늘의 음악'),
              Text(
                'YouTube',
                style: TextConfig.caption.copyWith(
                  color: ColorConfig.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!music.hasVideo)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      '음악을 불러오지 못했어요',
                      style: TextConfig.bodyM.copyWith(
                        color: ColorConfig.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppChip(label: '다시 시도', onTap: onRetry),
                  ],
                ),
              ),
            )
          else
            _Player(key: ValueKey('${music.youtubeVideoId}-$attempt'), music: music),
          if (music.title.isNotEmpty || music.artist.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(music.title, style: TextConfig.bodyMStrong),
            const SizedBox(height: 2),
            Text(
              music.artist,
              style: TextConfig.label.copyWith(color: ColorConfig.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _Player extends StatefulWidget {
  final DiaryMusic music;

  const _Player({super.key, required this.music});

  @override
  State<_Player> createState() => _PlayerState();
}

class _PlayerState extends State<_Player> {
  late final YoutubePlayerController _controller =
      YoutubePlayerController.fromVideoId(
        videoId: widget.music.youtubeVideoId,
        autoPlay: false,
        params: const YoutubePlayerParams(
          showControls: true,
          enableCaption: false,
          showVideoAnnotations: false,
          loop: true,
          interfaceLanguage: 'ko',
          origin: 'https://www.youtube-nocookie.com',
        ),
      );

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.music.durationLabel;
    return ClipRRect(
      borderRadius: AppRadius.circular(AppRadius.md),
      child: Stack(
        children: [
          ColoredBox(
            color: ColorConfig.bgVideoPlaceholder,
            child: YoutubePlayer(controller: _controller, aspectRatio: 16 / 9),
          ),
          if (duration != null)
            Positioned(
              right: 10,
              bottom: 10,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    duration,
                    style: TextConfig.numberS.copyWith(
                      color: ColorConfig.textOnDark,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
