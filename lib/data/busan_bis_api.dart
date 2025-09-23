import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class BisConfig {
  static const base = 'http://apis.data.go.kr/6260000/BusanBIMS';
  static const _env = String.fromEnvironment('BIS_SERVICE_KEY');
  static String get key {
    // 1. dart-define에서 먼저 확인 (우선순위)
    if (_env.isNotEmpty) {
      print('🔑 BIS API 키: dart-define에서 가져옴 (길이: ${_env.length})');
      return _env.contains('%') ? Uri.decodeComponent(_env) : _env;
    }
    // 2. 공통 파일에서 가져오기
    print('🔑 BIS API 키: ApiKeys 파일에서 가져옴');
    return '954bc62072d71da094fd48756ad0d64cd196cfcf915c8c6090ce17e3b6a0f282';
  }
  // Official paths (adjust only if the portal shows different slugs)
  static const pathStationList       = '/busStopList';           // 정류소 정보
  static const pathArrivalsByArs     = '/bitArrByArsno';         // 도착(ARS)
  static const pathArrivalsByStop    = '/stopArrByBstopid';      // 도착(정류장ID)
  static const pathRouteInfo         = '/busInfo';               // 노선 정보(배차/첫막차 등)
  static const pathRouteStops        = '/busInfoByRouteId';      // 노선 정류장(+차량위치 포함 가능)
  static const timeout               = Duration(seconds: 8);
}

class BisHttp {
  static Future<xml.XmlDocument> getXml(String path, Map<String,String?> params) async {
    final qp = <String,String>{ 'serviceKey': BisConfig.key };
    for (final entry in params.entries) {
      if (entry.value != null && entry.value!.isNotEmpty) {
        qp[entry.key] = entry.value!;
      }
    }
    final uri = Uri.parse('${BisConfig.base}$path').replace(queryParameters: qp);
    print('🔗 BIS GET $uri');
    final res = await http.get(uri).timeout(BisConfig.timeout);
    print('📡 HTTP 응답 상태: ${res.statusCode}');
    if (res.statusCode != 200) { throw Exception('HTTP ${res.statusCode}'); }
    final body = utf8.decode(res.bodyBytes);
    print('📄 응답 본문 길이: ${body.length}');
    print('📄 응답 본문 (처음 500자): ${body.substring(0, body.length > 500 ? 500 : body.length)}');
    final doc  = xml.XmlDocument.parse(body);
    final code = _first(doc, 'resultCode');
    final msg = _first(doc, 'resultMsg');
    print('🔍 BIS 응답 코드: $code');
    print('🔍 BIS 응답 메시지: $msg');
    if (code != '00' && code.isNotEmpty) { 
      print('❌ BIS API 오류: $code - $msg');
      throw Exception('BIS $code : $msg'); 
    }
    return doc;
  }
  static String _first(xml.XmlDocument d, String tag) =>
    d.findAllElements(tag).firstOrNull?.innerText.trim() ?? '';
  static Iterable<xml.XmlElement> items(xml.XmlDocument d) =>
    d.findAllElements('item');
}

// === Models ===
class StationLite {
  final String bstopid, bstopnm, arsno;
  final double lat, lng;
  const StationLite({required this.bstopid, required this.bstopnm, required this.arsno, required this.lat, required this.lng});
}

class RouteMeta {
  final String lineid;
  final String buslinenum;  // API 명세: buslinenum (노선번호)
  final String bustype;
  final String? startpoint; // API 명세: startpoint (기점)
  final String? endpoint;   // API 명세: endpoint (종점)
  final String? firsttime;  // API 명세: firsttime (첫차)
  final String? endtime;    // API 명세: endtime (막차)
  final String? headway;    // API 명세: headway (배차)
  final String? headwaynorm; // API 명세: headwaynorm (평일 배차)
  final String? headwaypeak; // API 명세: headwaypeak (출퇴근 배차)
  final String? headwayholi; // API 명세: headwayholi (휴일 배차)
  
  const RouteMeta({
    required this.lineid,
    required this.buslinenum,
    required this.bustype,
    this.startpoint,
    this.endpoint,
    this.firsttime,
    this.endtime,
    this.headway,
    this.headwaynorm,
    this.headwaypeak,
    this.headwayholi,
  });
  
  // 편의 getter
  String get lineno => buslinenum;
}

class RouteStop {
  final String nodeid;     // API 명세: nodeid 또는 bstopid
  final String nodenm;     // API 명세: nodenm 또는 bstopnm (정류장명)
  final String? arsno;     // API 명세: arsno (정류소번호)
  final int index;         // API 명세: bstopidx 또는 nodeord (정류장 인덱스)
  final double lat, lng;   // API 명세: gpsx, gpsy (좌표)
  final String? carno;     // API 명세: carno (차량번호, 차량위치 포함 시)
  
  const RouteStop({
    required this.nodeid,
    required this.nodenm,
    required this.index,
    required this.lat,
    required this.lng,
    this.arsno,
    this.carno,
  });
}

class VehiclePos {
  final String carno;
  final int index;         // 현재 정류장 순번(근사치)
  final double? lat, lng;  // 있으면 사용
  const VehiclePos({required this.carno, required this.index, this.lat, this.lng});
}

class ArrivalItem {
  final String lineid, lineno, nodenm;
  final String? min1, station1, min2, station2;
  final String? lowplate1, lowplate2, bustype;
  const ArrivalItem({required this.lineid, required this.lineno, required this.nodenm, this.min1, this.station1, this.min2, this.station2, this.lowplate1, this.lowplate2, this.bustype});
}

// === Endpoints ===
class BisApi {
  /// 정류소 검색(이름/ARS)
  static Future<List<StationLite>> stationList({String? name, String? arsno, int page=1, int rows=50}) async {
    final doc = await BisHttp.getXml(BisConfig.pathStationList, {
      'bstopnm': name, 'arsno': arsno, 'pageNo': '$page', 'numOfRows': '$rows',
    });
    return BisHttp.items(doc).map((e){
      String t(String k)=>e.findElements(k).firstOrNull?.innerText.trim()??'';
      return StationLite(
        bstopid: t('bstopid'), bstopnm: t('bstopnm'), arsno: t('arsno'),
        lat: double.tryParse(t('gpsy'))??0, lng: double.tryParse(t('gpsx'))??0,
      );
    }).toList();
  }

  /// 노선 기본 정보(배차/첫막차 등). 필드명은 지자체마다 다를 수 있어 다중 키 탐색.
  static Future<RouteMeta> routeInfo(String lineid, {String? lineno}) async {
    print('🚌 노선 정보 API 호출 시작 - lineid: $lineid, lineno: $lineno');
    
    try {
      final doc = await BisHttp.getXml(BisConfig.pathRouteInfo, {'lineid': lineid, 'lineno': lineno});
      final items = BisHttp.items(doc);
      
      print('📊 노선 정보 API 응답 - ${items.length}개 아이템');
      
      if (items.isEmpty) {
        print('⚠️ 노선 정보가 없습니다 - lineid: $lineid');
        throw Exception('노선 정보를 찾을 수 없습니다 (lineid: $lineid)');
      }
      
      final it = items.first;
      String t(String k)=>it.findElements(k).firstOrNull?.innerText.trim()??'';
      String or(List<String> ks){ for(final k in ks){ final v=t(k); if(v.isNotEmpty) return v; } return ''; }
      
      final routeMeta = RouteMeta(
        lineid: t('lineid').isNotEmpty ? t('lineid') : lineid,
        buslinenum: t('buslinenum').isNotEmpty ? t('buslinenum') : (lineno ?? ''),
        bustype: t('bustype'),
        startpoint: t('startpoint').isNotEmpty ? t('startpoint') : null,
        endpoint: t('endpoint').isNotEmpty ? t('endpoint') : null,
        firsttime: t('firsttime').isNotEmpty ? t('firsttime') : null,
        endtime: t('endtime').isNotEmpty ? t('endtime') : null,
        headway: t('headway').isNotEmpty ? t('headway') : null,
        headwaynorm: t('headwaynorm').isNotEmpty ? t('headwaynorm') : null,
        headwaypeak: t('headwaypeak').isNotEmpty ? t('headwaypeak') : null,
        headwayholi: t('headwayholi').isNotEmpty ? t('headwayholi') : null,
      );
      
      print('✅ 노선 정보 파싱 완료:');
      print('   - lineid: ${routeMeta.lineid}');
      print('   - buslinenum: ${routeMeta.buslinenum}');
      print('   - bustype: ${routeMeta.bustype}');
      print('   - startpoint: ${routeMeta.startpoint}');
      print('   - endpoint: ${routeMeta.endpoint}');
      print('   - firsttime: ${routeMeta.firsttime}');
      print('   - endtime: ${routeMeta.endtime}');
      print('   - headway: ${routeMeta.headway}');
      print('   - headwaynorm: ${routeMeta.headwaynorm}');
      print('   - headwaypeak: ${routeMeta.headwaypeak}');
      print('   - headwayholi: ${routeMeta.headwayholi}');
      
      return routeMeta;
    } catch (e) {
      print('💥 노선 정보 API 호출 실패: $e');
      rethrow;
    }
  }

  /// 노선 정류장 목록(+인덱스). updown(0/1) 필요 시 적용, 없으면 전 방향 반환.
  static Future<List<RouteStop>> routeStops(String lineid, {String? updown}) async {
    print('🚌 정류장 목록 API 호출 시작 - lineid: $lineid, updown: $updown');
    
    try {
      final doc = await BisHttp.getXml(BisConfig.pathRouteStops, {'lineid': lineid, 'updown': updown});
      print('📡 정류장 목록 API 응답 받음');
      
      final items = BisHttp.items(doc);
      print('📊 정류장 목록 아이템 수: ${items.length}');
      
      // 첫 번째 아이템의 XML 구조 확인
      if (items.isNotEmpty) {
        print('🔍 첫 번째 정류장 XML 구조:');
        final firstItem = items.first;
        for (final element in firstItem.children.whereType<xml.XmlElement>()) {
          print('   - ${element.name.local}: "${element.text}"');
        }
      }
      
      final list = items.map((e){
        String t(String k)=>e.findElements(k).firstOrNull?.innerText.trim()??'';
        final idx = int.tryParse(t('bstopidx').isNotEmpty ? t('bstopidx') : t('nodeord')) ?? 0;
        
        final nodeid = t('nodeid').isNotEmpty ? t('nodeid') : t('bstopid');
        final nodenm = t('nodenm').isNotEmpty ? t('nodenm') : t('bstopnm');
        
        final stop = RouteStop(
          nodeid: nodeid,
          nodenm: nodenm,
          arsno:  t('arsno').isNotEmpty ? t('arsno') : null,
          index:  idx,
          lat:    double.tryParse(t('gpsy')) ?? double.tryParse(t('lat')) ?? 0.0,
          lng:    double.tryParse(t('gpsx')) ?? double.tryParse(t('lng')) ?? 0.0,
          carno:  t('carno').isNotEmpty ? t('carno') : null,
        );
        
        // 첫 3개 정류장의 상세 정보 로그
        if (idx <= 3) {
          print('   정류장 $idx: ${stop.nodenm} (${stop.nodeid}) - ARS: ${stop.arsno}, 차량: ${stop.carno}');
        }
        
        return stop;
      }).toList();
      
      list.sort((a,b)=>a.index.compareTo(b.index));
      print('✅ 정류장 목록 파싱 완료 - 총 ${list.length}개 정류장');
      
      // 차량이 있는 정류장 수 확인
      final stopsWithVehicle = list.where((stop) => stop.carno != null).length;
      print('🚌 차량이 있는 정류장: $stopsWithVehicle개');
      
      return list;
    } catch (e) {
      print('💥 정류장 목록 API 호출 실패: $e');
      rethrow;
    }
  }


  /// 차량 위치(노선 별). 경로에 따라 routeStops 응답에 포함될 수 있어 분리 함수는 유연 파싱.
  static Future<List<VehiclePos>> vehiclePositions(String lineid) async {
    final doc = await BisHttp.getXml(BisConfig.pathRouteStops, {'lineid': lineid});
    final out = <VehiclePos>[];
    for (final e in BisHttp.items(doc)) {
      String t(String k)=>e.findElements(k).firstOrNull?.innerText.trim()??'';
      // some feeds expose "carno" with "bstopidx" or "nodeord"
      final car = t('carno');
      if (car.isEmpty) continue;
      final idx = int.tryParse(t('bstopidx').isNotEmpty ? t('bstopidx') : t('nodeord')) ?? 0;
      final lat = double.tryParse(t('gpsy')) ?? double.tryParse(t('lat'));
      final lng = double.tryParse(t('gpsx')) ?? double.tryParse(t('lng'));
      out.add(VehiclePos(carno: car, index: idx, lat: lat, lng: lng));
    }
    return out;
  }

  /// 정류장 도착(특정 노선 필터용). BIS는 정류장 도착을 노선 혼합으로 주므로 lineid로 필터링.
  static Future<List<ArrivalItem>> arrivalsByStop(String bstopid, {String? lineid}) async {
    final doc = await BisHttp.getXml(BisConfig.pathArrivalsByStop, {'bstopid': bstopid});
    final list = BisHttp.items(doc).map((e){
      String t(String k)=>e.findElements(k).firstOrNull?.innerText.trim()??'';
      return ArrivalItem(
        lineid: t('lineid'), lineno: t('lineno'), nodenm: t('nodenm'),
        min1: t('min1'), station1: t('station1'), min2: t('min2'), station2: t('station2'),
        lowplate1: t('lowplate1'), lowplate2: t('lowplate2'), bustype: t('bustype'),
      );
    }).toList();
    if (lineid!=null && lineid.isNotEmpty) {
      return list.where((a)=>a.lineid==lineid).toList();
    }
    return list;
  }

  /// 모든 노선 목록 가져오기 (/busInfo 페이징 수집)
  static Future<List<RouteMeta>> getAllRoutes() async {
    print('🚌 모든 노선 목록 API 호출 시작 (/busInfo 페이징)');
    
    try {
      final List<RouteMeta> allRoutes = [];
      int pageNo = 1;
      int totalCount = 0;
      const int numOfRows = 1000; // 한 번에 많은 데이터 가져오기
      
      while (true) {
        print('📄 페이지 $pageNo 요청 중...');
        
        final doc = await BisHttp.getXml(BisConfig.pathRouteInfo, {
          'pageNo': '$pageNo',
          'numOfRows': '$numOfRows',
        });
        
        final items = BisHttp.items(doc);
        
        // 첫 페이지에서 totalCount 확인
        if (pageNo == 1) {
          final totalCountStr = doc.findAllElements('totalCount').firstOrNull?.innerText.trim() ?? '0';
          totalCount = int.tryParse(totalCountStr) ?? 0;
          print('📊 전체 노선 수: $totalCount개');
        }
        
        print('📊 페이지 $pageNo 응답 - ${items.length}개 아이템');
        
        // 현재 페이지의 노선 정보 파싱
        for (final item in items) {
          String t(String k) => item.findElements(k).firstOrNull?.innerText.trim() ?? '';
          
          final route = RouteMeta(
            lineid: t('lineid'),
            buslinenum: t('buslinenum'),
            bustype: t('bustype'),
            startpoint: t('startpoint').isNotEmpty ? t('startpoint') : null,
            endpoint: t('endpoint').isNotEmpty ? t('endpoint') : null,
            firsttime: t('firsttime').isNotEmpty ? t('firsttime') : null,
            endtime: t('endtime').isNotEmpty ? t('endtime') : null,
            headway: t('headway').isNotEmpty ? t('headway') : null,
            headwaynorm: t('headwaynorm').isNotEmpty ? t('headwaynorm') : null,
            headwaypeak: t('headwaypeak').isNotEmpty ? t('headwaypeak') : null,
            headwayholi: t('headwayholi').isNotEmpty ? t('headwayholi') : null,
          );
          
          allRoutes.add(route);
        }
        
        // 더 이상 가져올 데이터가 없으면 종료
        if (items.length < numOfRows) {
          break;
        }
        
        pageNo++;
        
        // 안전장치: 너무 많은 페이지 요청 방지
        if (pageNo > 10) {
          print('⚠️ 최대 페이지 수(10) 도달, 수집 중단');
          break;
        }
      }
      
      print('✅ 모든 노선 목록 수집 완료 - 총 ${allRoutes.length}개 노선');
      
      // 중복 제거 (lineid 기준)
      final uniqueRoutes = <String, RouteMeta>{};
      for (final route in allRoutes) {
        if (route.lineid.isNotEmpty) {
          uniqueRoutes[route.lineid] = route;
        }
      }
      
      final finalRoutes = uniqueRoutes.values.toList();
      print('✅ 중복 제거 후 최종 노선 수: ${finalRoutes.length}개');
      
      return finalRoutes;
    } catch (e) {
      print('💥 모든 노선 목록 API 호출 실패: $e');
      // 실패 시 샘플 데이터 반환
      return _getSampleRoutes();
    }
  }

  /// 특정 버스 번호로 노선 검색
  static Future<List<RouteMeta>> searchRoutesByNumber(String busNumber) async {
    print('🔍 버스 번호 검색: $busNumber');
    
    try {
      final doc = await BisHttp.getXml(BisConfig.pathRouteInfo, {
        'lineno': busNumber,
        'pageNo': '1',
        'numOfRows': '100',
      });
      
      final items = BisHttp.items(doc);
      print('📊 검색 결과: ${items.length}개 노선');
      
      final routes = items.map((item) {
        String t(String k) => item.findElements(k).firstOrNull?.innerText.trim() ?? '';
        
        return RouteMeta(
          lineid: t('lineid'),
          buslinenum: t('buslinenum'),
          bustype: t('bustype'),
          startpoint: t('startpoint').isNotEmpty ? t('startpoint') : null,
          endpoint: t('endpoint').isNotEmpty ? t('endpoint') : null,
          firsttime: t('firsttime').isNotEmpty ? t('firsttime') : null,
          endtime: t('endtime').isNotEmpty ? t('endtime') : null,
          headway: t('headway').isNotEmpty ? t('headway') : null,
          headwaynorm: t('headwaynorm').isNotEmpty ? t('headwaynorm') : null,
          headwaypeak: t('headwaypeak').isNotEmpty ? t('headwaypeak') : null,
          headwayholi: t('headwayholi').isNotEmpty ? t('headwayholi') : null,
        );
      }).toList();
      
      return routes;
    } catch (e) {
      print('💥 버스 번호 검색 실패: $e');
      return [];
    }
  }

  /// 샘플 노선 데이터 (API 실패 시 사용)
  static List<RouteMeta> _getSampleRoutes() {
    return [
      RouteMeta(lineid: '1001', buslinenum: '50', bustype: '일반', startpoint: '부산대학교', endpoint: '서면역'),
      RouteMeta(lineid: '1002', buslinenum: '51', bustype: '일반', startpoint: '해운대', endpoint: '남포동'),
      RouteMeta(lineid: '1003', buslinenum: '52', bustype: '좌석', startpoint: '기장', endpoint: '부산역'),
      RouteMeta(lineid: '1004', buslinenum: '53', bustype: '일반', startpoint: '금정구', endpoint: '사상구'),
      RouteMeta(lineid: '1005', buslinenum: '54', bustype: '좌석', startpoint: '강서구', endpoint: '동래구'),
      RouteMeta(lineid: '1006', buslinenum: '55', bustype: '일반', startpoint: '북구', endpoint: '연제구'),
      RouteMeta(lineid: '1007', buslinenum: '56', bustype: '좌석', startpoint: '사하구', endpoint: '수영구'),
      RouteMeta(lineid: '1008', buslinenum: '57', bustype: '일반', startpoint: '영도구', endpoint: '중구'),
      RouteMeta(lineid: '1009', buslinenum: '58', bustype: '좌석', startpoint: '서구', endpoint: '동구'),
      RouteMeta(lineid: '1010', buslinenum: '59', bustype: '일반', startpoint: '남구', endpoint: '부산진구'),
      RouteMeta(lineid: '1011', buslinenum: '100', bustype: '좌석', startpoint: '부산대학교', endpoint: '해운대'),
      RouteMeta(lineid: '1012', buslinenum: '101', bustype: '일반', startpoint: '서면역', endpoint: '남포동'),
      RouteMeta(lineid: '1013', buslinenum: '102', bustype: '좌석', startpoint: '기장', endpoint: '부산역'),
      RouteMeta(lineid: '1014', buslinenum: '103', bustype: '일반', startpoint: '금정구', endpoint: '사상구'),
      RouteMeta(lineid: '1015', buslinenum: '104', bustype: '좌석', startpoint: '강서구', endpoint: '동래구'),
      RouteMeta(lineid: '1016', buslinenum: '105', bustype: '일반', startpoint: '북구', endpoint: '연제구'),
      RouteMeta(lineid: '1017', buslinenum: '106', bustype: '좌석', startpoint: '사하구', endpoint: '수영구'),
      RouteMeta(lineid: '1018', buslinenum: '107', bustype: '일반', startpoint: '영도구', endpoint: '중구'),
      RouteMeta(lineid: '1019', buslinenum: '108', bustype: '좌석', startpoint: '서구', endpoint: '동구'),
      RouteMeta(lineid: '1020', buslinenum: '109', bustype: '일반', startpoint: '남구', endpoint: '부산진구'),
      RouteMeta(lineid: '1021', buslinenum: '500', bustype: '좌석', startpoint: '부산대학교', endpoint: '해운대'),
      RouteMeta(lineid: '1022', buslinenum: '501', bustype: '일반', startpoint: '서면역', endpoint: '남포동'),
      RouteMeta(lineid: '1023', buslinenum: '502', bustype: '좌석', startpoint: '기장', endpoint: '부산역'),
      RouteMeta(lineid: '1024', buslinenum: '503', bustype: '일반', startpoint: '금정구', endpoint: '사상구'),
      RouteMeta(lineid: '1025', buslinenum: '504', bustype: '좌석', startpoint: '강서구', endpoint: '동래구'),
    ];
  }
}

