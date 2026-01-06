import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/refresh_interval_provider.dart';
import '../data/package_info_provider.dart';
import '../data/font_size_provider.dart';
import '../../../../widgets/top_banner_ad_widget.dart';
import '../../../../core/theme/app_colors.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfoAsync = ref.watch(packageInfoProvider);

    return Scaffold(
      backgroundColor: AppColors.ivoryBase, // 테마 배경색
      body: SafeArea(
        child: Column(
          children: [
            // 상단 배너 광고
            const TopBannerAdWidget(),

            // 메인 콘텐츠
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 폰트 설정 섹션
                  _buildFontSettingsSection(context, ref),

                  const SizedBox(height: 16),

                  // 앱 정보 섹션
                  _buildAppInfoSection(context, packageInfoAsync),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoSection(
    BuildContext context,
    AsyncValue<AppInfo> packageInfoAsync,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.accent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '앱 정보',
              style: TextStyle(
                fontFamily: 'Dongle',
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: AppColors.textStrong,
              ),
            ),
          ),
          Divider(height: 1, color: AppColors.divider),

          // 개인정보처리방침
          _buildInfoTile(
            icon: Icons.info_outline,
            title: '개인정보처리방침',
            subtitle: '개인정보 수집 및 이용에 대한 안내',
            onTap: () => context.go(
              '/webview',
              extra: {
                'url':
                    'https://syrear87.github.io/busanbusnyamyam-privacy-Policy/',
                'title': '개인정보처리방침',
                'returnPath': '/settings',
              },
            ),
          ),

          Divider(height: 1, color: AppColors.divider),

          // 광고 포함 앱
          _buildInfoTile(
            icon: Icons.ads_click,
            title: '광고 포함 앱',
            subtitle: '이 앱은 Google AdMob을 통해 광고를 제공합니다.',
            onTap: null,
          ),

          Divider(height: 1, color: AppColors.divider),

          // 앱 버전
          _buildInfoTile(
            icon: Icons.info_outline,
            title: '앱 버전',
            subtitle: packageInfoAsync.when(
              data: (info) => '버전 ${info.version} - 최신 버전입니다.',
              loading: () => '로딩 중...',
              error: (_, __) => '정보를 불러올 수 없습니다',
            ),
            onTap: null,
          ),

          Divider(height: 1, color: AppColors.divider),

          // 사용 기술
          _buildInfoTile(
            icon: Icons.code,
            title: '사용 기술',
            subtitle: '별도 페이지에서 사용한 기술을 보여줍니다.',
            onTap: () => context.go('/technologies'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primarySage),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Dongle',
          fontWeight: FontWeight.w500,
          fontSize: 19,
          color: AppColors.textBody,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontFamily: 'Dongle',
          color: AppColors.textMuted,
          fontSize: 15,
        ),
      ),
      trailing: onTap != null
          ? const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textMuted,
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildFontSettingsSection(BuildContext context, WidgetRef ref) {
    final currentOption = ref.watch(fontSizeProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.accent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '화면 설정',
              style: TextStyle(
                fontFamily: 'Dongle',
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: AppColors.textStrong,
              ),
            ),
          ),
          Divider(height: 1, color: AppColors.divider),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '글자 크기',
                  style: TextStyle(
                    fontFamily: 'Dongle',
                    fontSize: 19,
                    color: AppColors.textBody,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildFontSizeOption(
                      context: context,
                      ref: ref,
                      option: FontSizeOption.defaultSize,
                      isSelected: currentOption == FontSizeOption.defaultSize,
                    ),
                    const SizedBox(width: 12),
                    _buildFontSizeOption(
                      context: context,
                      ref: ref,
                      option: FontSizeOption.plus3,
                      isSelected: currentOption == FontSizeOption.plus3,
                    ),
                    const SizedBox(width: 12),
                    _buildFontSizeOption(
                      context: context,
                      ref: ref,
                      option: FontSizeOption.plus5,
                      isSelected: currentOption == FontSizeOption.plus5,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '앱 전체의 글자 크기가 조절됩니다.',
                  style: TextStyle(
                    fontFamily: 'Dongle',
                    fontSize: 15,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFontSizeOption({
    required BuildContext context,
    required WidgetRef ref,
    required FontSizeOption option,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(fontSizeProvider.notifier).setFontSize(option);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primarySage : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primarySage : AppColors.divider,
            ),
          ),
          child: Center(
            child: Text(
              option.label,
              style: TextStyle(
                fontFamily: 'Dongle',
                fontSize: 19,
                color: isSelected ? Colors.white : AppColors.textBody,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
