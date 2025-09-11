import 'bis_http.dart';
import 'bis_models.dart';

class BisApi {
  // 1) station search
  static Future<List<Station>> fetchStations({
    String? name,
    String? arsno,
    int page = 1,
    int rows = 100,
  }) async {
    final doc = await BisHttp.getXml('/stopInfo', {
      'pageNo': '$page',
      'numOfRows': '$rows',
      'bstopnm': name,
      'arsno': arsno,
    });
    return BisHttp.items(doc).map((e) {
      String t(String k) => e.getElement(k)?.text.trim() ?? '';
      final lng = double.tryParse(t('gpsx')) ?? 0;
      final lat = double.tryParse(t('gpsy')) ?? 0;
      return Station(
        bstopid: t('bstopid'),
        bstopnm: t('bstopnm'),
        arsno: t('arsno'),
        lat: lat,
        lng: lng,
      );
    }).toList();
  }

  // 2) arrivals by stopId
  static Future<List<Arrival>> fetchArrivalsByStopId(String bstopid) async {
    final doc = await BisHttp.getXml('/arrivalInfo', {'bstopid': bstopid});
    return BisHttp.items(doc).map((e) {
      String t(String k) => e.getElement(k)?.text.trim() ?? '';
      return Arrival(
        lineid: t('lineid'),
        lineno: t('lineno'),
        predict1: t('min1').isNotEmpty ? t('min1') : t('arrive1'),
        predict2: t('min2').isNotEmpty ? t('min2') : t('arrive2'),
      );
    }).toList();
  }

  // 3) arrivals by ARS
  static Future<List<Arrival>> fetchArrivalsByArsNo(String arsno) async {
    print('🌐 BIS API 요청: /arrivalInfo?arsno=$arsno');

    final doc = await BisHttp.getXml('/arrivalInfo', {'arsno': arsno});
    final items = BisHttp.items(doc);

    print('📋 XML 응답 파싱: ${items.length}개 아이템');

    final arrivals = items.map((e) {
      String t(String k) => e.getElement(k)?.text.trim() ?? '';

      final lineid = t('lineid');
      final lineno = t('lineno');
      final min1 = t('min1');
      final arrive1 = t('arrive1');
      final min2 = t('min2');
      final arrive2 = t('arrive2');

      final predict1 = min1.isNotEmpty ? min1 : arrive1;
      final predict2 = min2.isNotEmpty ? min2 : arrive2;

      print('  📍 노선: $lineno (ID: $lineid)');
      print(
        '      min1: "$min1", arrive1: "$arrive1" -> predict1: "$predict1"',
      );
      print(
        '      min2: "$min2", arrive2: "$arrive2" -> predict2: "$predict2"',
      );

      return Arrival(
        lineid: lineid,
        lineno: lineno,
        predict1: predict1,
        predict2: predict2,
      );
    }).toList();

    print('🎯 최종 결과: ${arrivals.length}개 도착정보');
    return arrivals;
  }

  // 4) route info
  static Future<RouteInfo?> fetchRouteInfo({
    required String lineid,
    String? lineno,
  }) async {
    final doc = await BisHttp.getXml('/getLineInfo', {
      'lineid': lineid,
      'lineno': lineno,
    });
    final it = BisHttp.items(doc).firstOrNull;
    if (it == null) return null;
    String t(String k) => it.getElement(k)?.text.trim() ?? '';
    return RouteInfo(lineid: t('lineid'), lineno: t('lineno'));
  }

  // 5) route stops
  static Future<List<RouteStop>> fetchRouteStops(String lineid) async {
    final doc = await BisHttp.getXml('/getLineStations', {'lineid': lineid});
    return BisHttp.items(doc).map((e) {
      String t(String k) => e.getElement(k)?.text.trim() ?? '';
      return RouteStop(
        bstopid: t('bstopid'),
        bstopnm: t('bstopnm'),
        arsno: t('arsno'),
      );
    }).toList();
  }

  // 6) arrivals for a route at a stop
  static Future<List<Arrival>> fetchRouteArrivals({
    required String lineid,
    required String bstopid,
  }) async {
    final doc = await BisHttp.getXml('/getArrivalsByLineStop', {
      'lineid': lineid,
      'bstopid': bstopid,
    });
    return BisHttp.items(doc).map((e) {
      String t(String k) => e.getElement(k)?.text.trim() ?? '';
      return Arrival(
        lineid: t('lineid'),
        lineno: t('lineno'),
        predict1: t('min1').isNotEmpty ? t('min1') : t('arrive1'),
        predict2: t('min2').isNotEmpty ? t('min2') : t('arrive2'),
      );
    }).toList();
  }
}
