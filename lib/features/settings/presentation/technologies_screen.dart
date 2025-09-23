import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class TechnologiesScreen extends StatelessWidget {
  const TechnologiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivoryBase, // 테마 배경색
      appBar: AppBar(
        backgroundColor: AppColors.ivoryBase,
        elevation: 0,
        title: const Text(
          '사용 기술',
          style: TextStyle(
            color: AppColors.textStrong,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primarySage),
          onPressed: () => context.go('/settings'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 프레임워크
              _buildTechSection(
                icon: Icons.build,
                iconColor: Colors.blue,
                title: '프레임워크',
                items: [
                  _buildTechItem('Flutter 3.24+', Colors.blue),
                  _buildTechItem('Dart 3.9+', Colors.blue),
                ],
              ),
              const SizedBox(height: 16),
              
              // 상태 관리
              _buildTechSection(
                icon: Icons.settings,
                iconColor: Colors.green,
                title: '상태 관리',
                items: [
                  _buildTechItem('hooks_riverpod 2.5.1', Colors.green),
                ],
              ),
              const SizedBox(height: 16),
              
              // 네트워킹
              _buildTechSection(
                icon: Icons.wifi,
                iconColor: Colors.purple,
                title: '네트워킹',
                items: [
                  _buildTechItem('dio 5.7.0', Colors.purple),
                  _buildTechItem('http 1.5.0', Colors.purple),
                  _buildTechItem('xml 6.6.1', Colors.purple),
                ],
              ),
              const SizedBox(height: 16),
              
              // 내비게이션
              _buildTechSection(
                icon: Icons.navigation,
                iconColor: Colors.indigo,
                title: '내비게이션',
                items: [
                  _buildTechItem('go_router 14.2.7', Colors.indigo),
                ],
              ),
              const SizedBox(height: 16),
              
              // 지도 및 위치
              _buildTechSection(
                icon: Icons.map,
                iconColor: Colors.orange,
                title: '지도 및 위치',
                items: [
                  _buildTechItem('google_maps_flutter 2.13.1', Colors.orange),
                  _buildTechItem('flutter_map 7.0.2', Colors.orange),
                  _buildTechItem('geolocator 12.0.0', Colors.orange),
                  _buildTechItem('permission_handler 11.3.1', Colors.orange),
                ],
              ),
              const SizedBox(height: 16),
              
              // UI/UX
              _buildTechSection(
                icon: Icons.palette,
                iconColor: Colors.pink,
                title: 'UI/UX',
                items: [
                  _buildTechItem('Material Design 3', Colors.pink),
                  _buildTechItem('Dongle 폰트', Colors.pink),
                ],
              ),
              const SizedBox(height: 16),
              
              // 기능 라이브러리
              _buildTechSection(
                icon: Icons.extension,
                iconColor: Colors.red,
                title: '기능 라이브러리',
                items: [
                  _buildTechItem('url_launcher 6.2.5 (링크 열기)', Colors.red),
                  _buildTechItem('webview_flutter 4.7.0 (웹뷰)', Colors.red),
                  _buildTechItem('package_info_plus 8.0.2 (앱 정보)', Colors.red),
                  _buildTechItem('share_plus 10.0.2 (공유 기능)', Colors.red),
                  _buildTechItem('shared_preferences 2.2.3 (로컬 저장)', Colors.red),
                ],
              ),
              const SizedBox(height: 16),
              
              // 광고
              _buildTechSection(
                icon: Icons.ads_click,
                iconColor: Colors.amber,
                title: '광고',
                items: [
                  _buildTechItem('google_mobile_ads 5.1.0', Colors.amber),
                ],
              ),
              const SizedBox(height: 16),
              
              // 데이터 소스
              _buildTechSection(
                icon: Icons.data_usage,
                iconColor: Colors.brown,
                title: '데이터 소스',
                items: [
                  _buildTechItem('부산버스정보시스템 OpenAPI', Colors.brown),
                  _buildTechItem('카카오맵 장소검색 API', Colors.brown),
                  _buildTechItem('OpenStreetMap tiles', Colors.brown),
                ],
              ),
              const SizedBox(height: 16),
              
              // 개발 도구
              _buildTechSection(
                icon: Icons.build_circle,
                iconColor: Colors.teal,
                title: '개발 도구',
                items: [
                  _buildTechItem('flutter_launcher_icons 0.13.1', Colors.teal),
                  _buildTechItem('flutter_native_splash 2.3.10', Colors.teal),
                  _buildTechItem('flutter_lints 5.0.0', Colors.teal),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTechSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Dongle',
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textStrong,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildTechItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Dongle',
                fontSize: 17,
                color: AppColors.textBody,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
