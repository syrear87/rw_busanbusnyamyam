import 'package:flutter/material.dart';

class AppColors {
  // === 기본 색상 팔레트 ===
  // 배경 색상
  static const ivoryBase = Color(0xFFFFF8E6); // 스크린 배경색
  static const ivorySurface = Color(0xFFFFFBF2); // 리스트/카드 배경색
  static const ivoryOverlay = Color(0xFFFFFEF8); // 모달/시트 배경색
  
  // 메인 색상
  static const primarySage = Color(0xFF6B8F71); // 메인 버튼/포커스 색상
  static const primarySageHover = Color(0xFF5F7F65); // 버튼 호버 상태
  static const primaryContainer = Color(0xFFA7C4A0); // 하이라이트 배경
  static const onPrimary = Color(0xFFFFFFFF); // 버튼 텍스트 색상
  
  // 구분선/테두리 색상
  static const borderSage = Color(0xFF9FB3A3); // 보더/구분선 색상
  static const divider = Color(0xFFE6ECE4); // Divider 색상
  
  // 텍스트 색상
  static const textStrong = Color(0xFF1F2A24); // 강조 텍스트
  static const textBody = Color(0xFF2C3A32); // 본문 텍스트
  static const textMuted = Color(0xFF6D7B72); // 보조 텍스트
  
  // 상태 색상
  static const success = Color(0xFF43936C); // 성공 상태
  static const warning = Color(0xFFF59E0B); // 경고 상태
  static const error = Color(0xFFDC2626); // 에러 상태
  
  // === 기존 호환성을 위한 별칭 ===
  static const background = ivoryBase;
  static const accent = primarySage;
  static const text = textBody;
  static const card = ivorySurface;
}
