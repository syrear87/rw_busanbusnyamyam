import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivoryBase, // 테마 배경색
      appBar: AppBar(
        backgroundColor: AppColors.ivoryBase,
        elevation: 0,
        title: const Text(
          '개인정보처리방침',
          style: TextStyle(
            color: AppColors.textStrong,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primarySage),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primarySage),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              const Text(
                '부산버스냠냠 개인정보처리방침',
                style: TextStyle(
                  fontFamily: 'Dongle',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textStrong,
                ),
              ),
              const SizedBox(height: 8),
              
              // 날짜
              const Text(
                '시행일: 2025-01-09 · 마지막 업데이트: 2025-09-23',
                style: TextStyle(
                  fontFamily: 'Dongle',
                  fontSize: 16,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 24),
              
              // 목차
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '목차',
                      style: TextStyle(
                        fontFamily: 'Dongle',
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textStrong,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '1. 수집 항목과 방법',
                      style: TextStyle(
                        fontFamily: 'Dongle',
                        fontSize: 17,
                        color: AppColors.textBody,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '2. 이용 목적',
                      style: TextStyle(
                        fontFamily: 'Dongle',
                        fontSize: 17,
                        color: AppColors.textBody,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '3. 제3자 제공 및 처리위탁',
                      style: TextStyle(
                        fontFamily: 'Dongle',
                        fontSize: 17,
                        color: AppColors.textBody,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '4. 보관 및 파기',
                      style: TextStyle(
                        fontFamily: 'Dongle',
                        fontSize: 17,
                        color: AppColors.textBody,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '5. 이용자 권리와 선택',
                      style: TextStyle(
                        fontFamily: 'Dongle',
                        fontSize: 17,
                        color: AppColors.textBody,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '6. 보안 조치',
                      style: TextStyle(
                        fontFamily: 'Dongle',
                        fontSize: 17,
                        color: AppColors.textBody,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '7. 문의처',
                      style: TextStyle(
                        fontFamily: 'Dongle',
                        fontSize: 17,
                        color: AppColors.textBody,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '8. 방침 변경',
                      style: TextStyle(
                        fontFamily: 'Dongle',
                        fontSize: 17,
                        color: AppColors.textBody,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // 내용
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1. 수집 항목과 방법',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '직접 수집: 해당 없음. 회원가입, 서버 동기화, 클라우드 업로드 기능을 제공하지 않습니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '자동 수집:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• 위치 정보: 정확한 버스 도착 정보 제공을 위해 사용자의 현재 위치를 수집합니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• 광고 식별자: Google AdMob을 통한 맞춤형 광고 제공을 위해 사용됩니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      '2. 이용 목적',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '• 버스 도착 정보 제공: 사용자의 위치를 기반으로 가장 가까운 정류장의 버스 도착 정보를 제공합니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• 주변 맛집·카페 정보 제공: 카카오맵 장소검색 API를 사용해 반경 기반으로 장소 정보를 제공합니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• 광고 서비스: Google AdMob을 통해 무료 앱 운영을 위한 광고를 제공합니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      '3. 제3자 제공 및 처리위탁',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '• Google AdMob: 광고 서비스 제공을 위해 광고 식별자 정보를 처리합니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• 부산버스 공공데이터: 버스 도착/노선 정보 제공을 위해 필요한 범위 내 요청 정보를 전송합니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• 카카오맵(카카오 로컬 API): 주변 장소(맛집·카페 등) 검색을 위해 검색어, 좌표 등 요청 정보를 전송합니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      '4. 보관 및 파기',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '• 위치 정보: 앱 사용 중 기능 제공을 위해서만 사용되며, 필요 기간 경과 또는 목적 달성 시 지체 없이 파기합니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• 광고 식별자: Google AdMob 정책에 따라 관리됩니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      '5. 이용자 권리와 선택',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '• 위치 권한: 설정 > 개인정보 보호 및 보안 > 위치 서비스에서 언제든지 변경할 수 있습니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• 광고 추적: 설정 > 개인정보 보호 및 보안 > 추적에서 광고 추적을 제한할 수 있습니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      '6. 보안 조치',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '• 개인정보 최소 수집 및 접근 권한 통제를 적용합니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• 네트워크 전송 시 HTTPS 암호화를 적용합니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• 로그/오류 데이터 접근 통제 및 보관 기간을 관리합니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      '7. 문의처',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '개인정보처리방침에 대한 문의사항이 있으시면 다음으로 연락해 주세요.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '이메일: syrear87@gmail.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      '8. 방침 변경',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '이 개인정보처리방침은 법령, 정책 또는 보안기술의 변경에 따라 내용의 추가, 삭제 및 수정이 있을 시에는 개정 최소 7일 전부터 앱 내 공지사항을 통해 고지할 것입니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
