import 'package:xml/xml.dart' as xml;
import 'bis_config.dart';
import 'bis_http.dart';
import 'bis_models.dart';

class BisApi {
  /// 1) 정류소정보 조회 (이름/ARS로 검색, paging)
  static Future<List<Station>> stationList({String? name, String? arsno, int page = 1, int rows = 10}) async {
    final doc = await BisHttp.getXml(BisConfig.pathStationList, {
      'bstopnm': name,
      'arsno': arsno,
      'pageNo': '$page',
      'numOfRows': '$rows',
    });
    return BisHttp.items(doc).map((e) {
      String t(String k) => e.findElements(k).isEmpty ? '' : e.findElements(k).first.text.trim();
      return Station(
        bstopid: t('bstopid'),
        bstopnm: t('bstopnm'),
        arsno:   t('arsno'),
        lat:     double.tryParse(t('gpsy')) ?? 0,
        lng:     double.tryParse(t('gpsx')) ?? 0,
      );
    }).toList();
  }

  /// 2) 정류소 도착정보 (ARS 번호)
  static Future<List<Arrival>> arrivalsByArs(String arsno) async {
    final doc = await BisHttp.getXml(BisConfig.pathArrivalsByArsNo, { 'arsno': arsno });
    return _mapArrivals(doc);
  }

  /// 3) 정류소 도착정보 (정류장ID)
  static Future<List<Arrival>> arrivalsByStopId(String bstopid) async {
    final doc = await BisHttp.getXml(BisConfig.pathArrivalsByStopId, { 'bstopid': bstopid });
    return _mapArrivals(doc);
  }

  /// 4) 노선 정류소 조회 (lineid 하나로 정류장 목록+차량 위치)
  static Future<List<RouteStop>> lineStations(String lineid) async {
    final doc = await BisHttp.getXml(BisConfig.pathLineStations, { 'lineid': lineid });
    return BisHttp.items(doc).map((e) {
      String t(String k) => e.findElements(k).isEmpty ? '' : e.findElements(k).first.text.trim();
      return RouteStop(
        bstopid: t('nodeid').isNotEmpty ? t('nodeid') : t('bstopid'),
        bstopnm: t('bstopnm'),
        arsno:   t('arsno'),
        lineno:  t('lineno'),
      );
    }).toList();
  }

  static List<Arrival> _mapArrivals(xml.XmlDocument doc) {
    return BisHttp.items(doc).map((e) {
      String t(String k) => e.findElements(k).isEmpty ? '' : e.findElements(k).first.text.trim();
      return Arrival(
        lineid:   t('lineid'),
        lineno:   t('lineno'),
        nodenm:   t('nodenm'),
        min1:     t('min1'),
        station1: t('station1'),
        min2:     t('min2'),
        station2: t('station2'),
        bustype:  t('bustype'),
      );
    }).toList();
  }

  // Legacy methods for backward compatibility
  static Future<List<Station>> fetchStations({String? name, String? arsno, int page = 1, int rows = 100}) => 
      stationList(name: name, arsno: arsno, page: page, rows: rows);
  
  static Future<List<Arrival>> fetchArrivalsByArsNo(String arsno) async {
    // 스로틀 적용으로 과다 호출 방지
    return await throttle(const Duration(milliseconds: 600), () => arrivalsByArs(arsno));
  }
}
