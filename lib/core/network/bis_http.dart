import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:flutter/foundation.dart';
import 'bis_config.dart';

class BisHttp {
  static Future<xml.XmlDocument> getXml(String path, Map<String, String?> q) async {
    final query = <String, String>{
      'serviceKey': BisConfig.key,
    };
    
    // null이 아니고 비어있지 않은 파라미터만 추가
    for (final entry in q.entries) {
      if (entry.value != null && entry.value!.isNotEmpty) {
        query[entry.key] = entry.value!;
      }
    }
    final uri = Uri.parse('${BisConfig.base}$path').replace(queryParameters: query);
    debugPrint('🔗 BIS GET $uri');
    
    try {
      final res = await http.get(uri).timeout(BisConfig.timeout);
      debugPrint('📡 HTTP 응답 상태: ${res.statusCode}');
      
      if (res.statusCode != 200) {
        debugPrint('❌ HTTP 오류: ${res.statusCode}');
        debugPrint('❌ 응답 본문: ${res.body}');
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }
      
      final body = utf8.decode(res.bodyBytes);
      debugPrint('📄 응답 본문 길이: ${body.length}');
      debugPrint('📄 응답 본문 (처음 500자): ${body.length > 500 ? body.substring(0, 500) + '...' : body}');
      
      final doc = xml.XmlDocument.parse(body);
      final code = _first(doc, 'resultCode');
      final msg = _first(doc, 'resultMsg');
      
      debugPrint('🔍 BIS 응답 코드: $code');
      debugPrint('🔍 BIS 응답 메시지: $msg');
      
      if (code != '00') {
        debugPrint('❌ BIS API 오류: $code - $msg');
        throw Exception('BIS $code: $msg');
      }
      
      final itemCount = items(doc).length;
      debugPrint('✅ BIS API 성공: $itemCount개 아이템 반환');
      
      return doc;
    } catch (e) {
      debugPrint('💥 BIS API 호출 실패: $e');
      rethrow;
    }
  }

  static String _first(xml.XmlDocument d, String tag) =>
      d.findAllElements(tag).isEmpty ? '' : d.findAllElements(tag).first.text.trim();

  static Iterable<xml.XmlElement> items(xml.XmlDocument d) => d.findAllElements('item');
}

// 과다 호출 방지를 위한 스로틀 함수
Future<T> throttle<T>(Duration d, Future<T> Function() f) async {
  await Future.delayed(d); 
  return await f();
}

