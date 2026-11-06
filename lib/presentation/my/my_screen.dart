import 'package:cake/config/api_config.dart';
import 'package:cake/presentation/my/my_view_model.dart';
import 'package:cake/ui/common_components/app_bottom_sheet.dart';
import 'package:cake/ui/common_components/app_chip.dart';
import 'package:cake/ui/common_components/app_icon.dart';
import 'package:cake/ui/common_components/app_toast.dart';
import 'package:cake/ui/common_components/list_row.dart';
import 'package:cake/ui/common_components/surface_card.dart';
import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/app_dimens.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:cake/utils/external_links.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, MyViewModel viewModel) async {
    final ok = await ConfirmSheet.show(
      context,
      title: '로그아웃할까요?',
      description: '다시 로그인하면 일기를 그대로 볼 수 있어요.',
      primaryLabel: '로그아웃',
      secondaryLabel: '취소',
    );
    if (ok) await viewModel.logout();
  }

  Future<void> _confirmWithdraw(BuildContext context, MyViewModel viewModel) async {
    final ok = await ConfirmSheet.show(
      context,
      title: '정말 탈퇴할까요?',
      description: '모든 일기가 삭제되고 되돌릴 수 없어요.',
      primaryLabel: '탈퇴하기',
      secondaryLabel: '취소',
      tone: ConfirmTone.danger,
    );
    if (ok) await viewModel.withdraw();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MyViewModel>();
    final profile = viewModel.profile;
    final stats = viewModel.stats;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final toast = viewModel.toastMessage;
      if (toast != null) {
        viewModel.clearToast();
        AppToast.show(context, toast, tone: ToastTone.error, bottomOffset: 96);
      }
      if (viewModel.signedOut) context.go('/login');
    });

    return Stack(
      children: [
        Container(
          color: ColorConfig.bgPage,
          child: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.page, 12, AppSpacing.page, 24),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text('마이', style: TextConfig.titleL),
                ),
                SurfaceCard(
                  gradient: AppGradients.cardTint,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              color: ColorConfig.bgSurface,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _initial(profile?.nickname),
                              style: TextConfig.titleM.copyWith(
                                color: ColorConfig.textAccent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile?.nickname ?? '',
                                  style: TextConfig.numberL.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  profile?.provider == null
                                      ? '로그인 중'
                                      : '${profile!.provider!.displayName} 계정으로 로그인 중',
                                  style: TextConfig.label.copyWith(
                                    color: ColorConfig.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          AppChip(
                            label: '닉네임 변경',
                            icon: const AppIcon(AppIcons.pen, size: 16),
                            onTap: () async {
                              final result = await context.push<String>(
                                '/nickname-edit',
                                extra: profile?.nickname ?? '',
                              );
                              if (result != null) viewModel.applyNickname(result);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: ColorConfig.bgSurface.withValues(alpha: 0.75),
                          borderRadius: AppRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          children: [
                            _Stat(value: '${stats?.totalCount ?? 0}', label: '모은 조각'),
                            _Stat(value: '${stats?.monthCount ?? 0}', label: '이번 달'),
                            _Stat(value: '${stats?.streakDays ?? 0}일', label: '연속 기록'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ListRowGroup(
                  heading: '알림',
                  rows: [
                    ListRow(
                      label: '기록 알림 · 공감 알림',
                      type: ListRowType.static_,
                      trailing: Switch.adaptive(
                        value: profile?.notificationEnabled ?? false,
                        activeTrackColor: ColorConfig.brandBlue,
                        onChanged: profile == null || viewModel.notificationUpdating
                            ? null
                            : viewModel.setNotificationEnabled,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListRowGroup(
                  heading: '정보',
                  rows: [
                    ListRow(
                      label: '서비스 이용약관',
                      onTap: () => ExternalLinks.open(ApiConfig.serviceTermUrl),
                    ),
                    ListRow(
                      label: '개인정보 처리방침',
                      onTap: () => ExternalLinks.open(ApiConfig.privacyPolicyUrl),
                    ),
                    ListRow(
                      label: '버전 정보',
                      type: ListRowType.static_,
                      value: viewModel.version,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListRowGroup(
                  heading: '계정',
                  rows: [
                    ListRow(
                      label: '로그아웃',
                      type: ListRowType.static_,
                      onTap: () => _confirmLogout(context, viewModel),
                    ),
                    ListRow(
                      label: '회원 탈퇴',
                      type: ListRowType.danger,
                      onTap: () => _confirmWithdraw(context, viewModel),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (viewModel.isBusy)
          const ColoredBox(
            color: ColorConfig.bgDim,
            child: Center(
              child: CircularProgressIndicator(color: ColorConfig.brandBlue),
            ),
          ),
      ],
    );
  }

  String _initial(String? nickname) {
    if (nickname == null || nickname.isEmpty) return '';
    return nickname.characters.first;
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextConfig.numberL.copyWith(color: ColorConfig.textAccent),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextConfig.caption.copyWith(color: ColorConfig.textSecondary),
          ),
        ],
      ),
    );
  }
}
