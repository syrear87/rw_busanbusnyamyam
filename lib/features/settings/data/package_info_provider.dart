import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppInfo {
  final String appName;
  final String version;
  final String buildNumber;

  const AppInfo({
    required this.appName,
    required this.version,
    required this.buildNumber,
  });
}

final packageInfoProvider = FutureProvider<AppInfo>((ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  return AppInfo(
    appName: packageInfo.appName,
    version: packageInfo.version,
    buildNumber: packageInfo.buildNumber,
  );
});
