import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'bis_config.dart';

class BisHttp {
  static Future<xml.XmlDocument> getXml(
    String path,
    Map<String, String?> q,
  ) async {
    final filteredQ = <String, String>{};
    for (final entry in q.entries) {
      if (entry.value != null && entry.value!.isNotEmpty) {
        filteredQ[entry.key] = entry.value!;
      }
    }
    final qp = <String, String>{
      'serviceKey': BisConfig.key, // do not double-encode; Uri handles it
      ...filteredQ,
    };
    final uri = Uri.parse(
      '${BisConfig.base}$path',
    ).replace(queryParameters: qp);

    print('🔗 HTTP 요청: $uri');

    final res = await http.get(uri).timeout(BisConfig.timeout);

    print('📡 HTTP 응답: ${res.statusCode}');

    if (res.statusCode != 200) {
      print('❌ HTTP 에러: ${res.statusCode}');
      throw Exception('HTTP ${res.statusCode}');
    }

    final body = utf8.decode(res.bodyBytes); // keep Korean
    print('📄 응답 본문 길이: ${body.length}자');
    print(
      '📄 응답 미리보기: ${body.length > 200 ? body.substring(0, 200) + '...' : body}',
    );

    final doc = xml.XmlDocument.parse(body);
    final code = _text(doc, 'resultCode');
    final msg = _text(doc, 'resultMsg');

    print('📊 BIS 응답 코드: $code, 메시지: $msg');

    if (code != '00') {
      print('❌ BIS API 에러: $code - $msg');
      throw Exception('BIS error $code $msg');
    }

    final itemCount = doc.findAllElements('item').length;
    print('📋 파싱된 아이템 수: $itemCount');

    return doc;
  }

  static String _text(xml.XmlDocument doc, String tag) =>
      doc.findAllElements(tag).firstOrNull?.text.trim() ?? '';

  static Iterable<xml.XmlElement> items(xml.XmlDocument doc) =>
      doc.findAllElements('item');
}
