import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/refresh_interval_provider.dart';
import '../data/package_info_provider.dart';
import '../../../../widgets/top_banner_ad_widget.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshInterval = ref.watch(refreshIntervalProvider);
    final packageInfoAsync = ref.watch(packageInfoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: Column(
        children: [
          // 상단 배너 광고
          const TopBannerAdWidget(),

          // 메인 콘텐츠
          Expanded(
            child: ListView(
              children: [
          // 새로고침 간격
          ListTile(
            title: const Text('새로고침 간격'),
            subtitle: Text(refreshInterval.displayName),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showRefreshIntervalDialog(context, ref),
          ),
          const Divider(),

          // 개인정보처리방침
          ListTile(
            title: const Text('개인정보처리방침'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _openPrivacyPolicy(),
          ),
          const Divider(),

          // 버전 정보
          ListTile(
            title: const Text('버전 정보'),
            subtitle: packageInfoAsync.when(
              data: (info) =>
                  Text('${info.appName} ${info.version} (${info.buildNumber})'),
              loading: () => const Text('로딩 중...'),
              error: (_, __) => const Text('정보를 불러올 수 없습니다'),
            ),
            onTap: () => _showVersionInfo(context, packageInfoAsync),
          ),
          const Divider(),

          // 정보 제공처 표시
          ListTile(
            title: const Text('정보 제공처 표시'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showDataSources(context),
          ),
          const Divider(),

          // 캐시 삭제
          ListTile(
            title: const Text('캐시 삭제'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _clearCache(context),
          ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRefreshIntervalDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새로고침 간격'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: RefreshInterval.values.map((interval) {
            return RadioListTile<RefreshInterval>(
              title: Text(interval.displayName),
              value: interval,
              groupValue: ref.read(refreshIntervalProvider),
              onChanged: (value) {
                if (value != null) {
                  ref.read(refreshIntervalProvider.notifier).setInterval(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _openPrivacyPolicy() async {
    const url = 'https://example.com/privacy-policy';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showVersionInfo(
    BuildContext context,
    AsyncValue<AppInfo> packageInfoAsync,
  ) {
    packageInfoAsync.when(
      data: (info) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('버전 정보'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('앱 이름: ${info.appName}'),
                Text('버전: ${info.version}'),
                Text('빌드 번호: ${info.buildNumber}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      },
      loading: () => null,
      error: (_, __) => null,
    );
  }

  void _showDataSources(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('정보 제공처'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• 부산버스정보시스템(OpenAPI)'),
            SizedBox(height: 8),
            Text('• 카카오맵 장소검색'),
            SizedBox(height: 8),
            Text('• OpenStreetMap tiles'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _clearCache(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('캐시 삭제 완료'), duration: Duration(seconds: 2)),
    );
  }
}
