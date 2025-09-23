import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;
  final String? returnPath;

  const WebViewScreen({
    super.key,
    required this.url,
    required this.title,
    this.returnPath,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    print('🌐 웹뷰 초기화 시작 - URL: ${widget.url}');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            print('📊 로딩 진행률: $progress%');
          },
          onPageStarted: (String url) {
            print('🚀 페이지 로딩 시작: $url');
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            print('✅ 페이지 로딩 완료: $url');
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ 웹뷰 에러 발생:');
            print('   - 설명: ${error.description}');
            print('   - 에러 코드: ${error.errorCode}');
            print('   - 에러 타입: ${error.errorType}');
            print('   - URL: ${error.url}');
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            print('🧭 네비게이션 요청:');
            print('   - URL: ${request.url}');
            print('   - isMainFrame: ${request.isMainFrame}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    print('🎯 URL 로드 요청: ${widget.url}');
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️ 웹뷰 빌드 호출:');
    print('   - URL: ${widget.url}');
    print('   - 로딩 상태: $_isLoading');
    print('   - 에러 상태: $_hasError');
    print('   - 제목: ${widget.title}');

    return Scaffold(
      backgroundColor: AppColors.ivoryBase, // 테마 배경색
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'Dongle',
            fontSize: 23,
            color: AppColors.accent,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.ivoryBase, // 테마 배경색과 통일
        elevation: 0,
        foregroundColor: AppColors.accent,
        leading: IconButton(
          onPressed: () {
            print('⬅️ 뒤로가기 버튼 클릭');
            if (widget.returnPath != null) {
              print('   - 복귀 경로: ${widget.returnPath}');
              context.go(widget.returnPath!);
            } else {
              print('   - 기본 복귀: /home');
              context.go('/home');
            }
          },
          icon: const Icon(Icons.arrow_back, color: AppColors.accent),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        ),
        actions: [
          // 새로고침 버튼
          IconButton(
            onPressed: () {
              print('🔄 새로고침 버튼 클릭');
              print('   - 현재 URL: ${widget.url}');
              print('   - 에러 상태 초기화: $_hasError -> false');
              print('   - 로딩 상태 설정: $_isLoading -> true');
              setState(() {
                _hasError = false;
                _isLoading = true;
              });
              _controller.reload();
              print('   - 웹뷰 reload() 호출 완료');
            },
            icon: const Icon(Icons.refresh, color: AppColors.accent),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
        ],
      ),
      body: SafeArea(
        child: _hasError
            ? _buildErrorView()
            : Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_isLoading)
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppColors.accent),
                          SizedBox(height: 16),
                          Text(
                            '페이지 로딩 중...',
                            style: TextStyle(
                              fontFamily: 'Dongle',
                              fontSize: 19,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              '웹페이지를 불러올 수 없습니다',
              style: TextStyle(
                fontFamily: 'Dongle',
                fontSize: 27,
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              '공공데이터포털은 보안상의 이유로\n앱 내 웹뷰에서 차단될 수 있습니다',
              style: TextStyle(
                fontFamily: 'Dongle',
                fontSize: 21,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                print('🌐 외부 브라우저 열기 버튼 클릭');
                print('   - 대상 URL: ${widget.url}');
                _launchExternalBrowser();
              },
              icon: const Icon(Icons.open_in_browser),
              label: const Text(
                '외부 브라우저에서 열기',
                style: TextStyle(fontFamily: 'Dongle', fontSize: 19),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                print('🔄 다시 시도 버튼 클릭');
                print('   - 에러 상태 초기화: $_hasError -> false');
                print('   - 로딩 상태 설정: $_isLoading -> true');
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                });
                _controller.reload();
                print('   - 웹뷰 reload() 호출 완료');
              },
              child: const Text(
                '다시 시도',
                style: TextStyle(
                  fontFamily: 'Dongle',
                  fontSize: 19,
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchExternalBrowser() async {
    print('🌐 외부 브라우저 열기 시작');
    try {
      final uri = Uri.parse(widget.url);
      print('   - URI 파싱 완료: $uri');

      print('   - canLaunchUrl 체크 중...');
      final canLaunch = await canLaunchUrl(uri);
      print('   - canLaunchUrl 결과: $canLaunch');

      if (canLaunch) {
        print('   - launchUrl 호출 중...');
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('   - ✅ 외부 브라우저 열기 성공');
      } else {
        print('   - ❌ 외부 브라우저로 열 수 없습니다: ${widget.url}');
      }
    } catch (e) {
      print('   - ❌ 외부 브라우저 열기 실패: $e');
      print('   - 에러 타입: ${e.runtimeType}');
    }
  }
}
