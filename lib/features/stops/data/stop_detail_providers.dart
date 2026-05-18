import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;
import '../../../../core/config/api_keys.dart';
import 'stop_detail_models.dart';
import 'stop_model.dart';
import 'stops_provider.dart';
import 'bus_arrival_model.dart';
import 'bus_arrival_provider.dart';

// GoRouter state에서 StopMeta를 추출하는 provider
final stopDetailArgsProvider = Provider<StopMeta>((ref) {
  // GoRouter의 현재 상태를 가져오기 위해 다른 방법 사용
  // 실제로는 화면에서 직접 처리하도록 변경
  return StopMeta(
    bstopid: '',
    bstopnm: '알 수 없는 정류장',
    arsno: '',
    lat: 0.0,
    lng: 0.0,
  );
});

// 즐겨찾기 정류장 관리
class FavoriteStopsNotifier extends StateNotifier<Set<String>> {
  FavoriteStopsNotifier() : super({}) {
    _loadFavorites();
  }

  static const String _key = 'fav_stops';

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_key) ?? [];
    state = favorites.toSet();
  }

  Future<void> toggleFavorite(String bstopid) async {
    final prefs = await SharedPreferences.getInstance();
    final newFavorites = Set<String>.from(state);

    if (newFavorites.contains(bstopid)) {
      newFavorites.remove(bstopid);
    } else {
      newFavorites.add(bstopid);
    }

    state = newFavorites;
    await prefs.setStringList(_key, newFavorites.toList());
  }

  bool isFavorite(String bstopid) => state.contains(bstopid);
}

final favoriteStopsProvider =
    StateNotifierProvider<FavoriteStopsNotifier, Set<String>>(
      (ref) => FavoriteStopsNotifier(),
    );

// 도착 정보 정렬 방식
final arrivalSortProvider = StateProvider<ArrivalSort>(
  (ref) => ArrivalSort.imminent,
);

// BIS API 클라이언트
class BisApiClient {
  static const String _baseUrl = 'http://apis.data.go.kr/6260000/BusanBIMS';
  static const String _env = String.fromEnvironment('BIS_SERVICE_KEY');
  static final Map<String, DateTime> _lastCallTimes = {}; // API 호출 제한을 위한 캐시

  static String get _serviceKey {
    if (_env.isNotEmpty) {
      return _env.contains('%') ? Uri.decodeComponent(_env) : _env;
    }
    return ApiKeys.bisServiceKey;
  }

  static Future<List<ArrivalItem>> fetchArrivalsByStopId(String bstopid) async {
    try {
      // API 호출 제한 (5초 내 중복 호출 방지)
      final now = DateTime.now();
      final lastCall = _lastCallTimes[bstopid];
      if (lastCall != null && now.difference(lastCall).inSeconds < 5) {
        print('🚌 API 호출 제한: ${bstopid} (${now.difference(lastCall).inSeconds}초 전 호출됨)');
        return [];
      }
      _lastCallTimes[bstopid] = now;
      
      print('🚌 BIS API 호출 시작 (bstopid: $bstopid)');
      final uri = Uri.parse('$_baseUrl/stopArrByBstopid').replace(
        queryParameters: {
          'serviceKey': _serviceKey,
          'bstopid': bstopid,
          'numOfRows': '50',
        },
      );

      print('🚌 API URL: $uri');
      final response = await http.get(uri);
      print('🚌 API 응답 상태: ${response.statusCode}');

      if (response.statusCode == 200) {
        final arrivals = _parseArrivalsXml(response.body);
        print('🚌 파싱된 도착 정보: ${arrivals.length}개');
        return arrivals;
      }
      print('🚌 API 응답 실패: ${response.statusCode}');
      return [];
    } catch (e) {
      print('🚌 BIS API 호출 실패 (bstopid): $e');
      return [];
    }
  }

  static Future<List<ArrivalItem>> fetchArrivalsByArsno(String arsno) async {
    try {
      // API 호출 제한 (5초 내 중복 호출 방지)
      final now = DateTime.now();
      final lastCall = _lastCallTimes[arsno];
      if (lastCall != null && now.difference(lastCall).inSeconds < 5) {
        print('🚌 API 호출 제한: ${arsno} (${now.difference(lastCall).inSeconds}초 전 호출됨)');
        return [];
      }
      _lastCallTimes[arsno] = now;
      
      print('🚌 BIS API 호출 시작 (arsno: $arsno)');
      final uri = Uri.parse('$_baseUrl/bitArrByArsno').replace(
        queryParameters: {
          'serviceKey': _serviceKey,
          'arsno': arsno,
          'numOfRows': '50',
        },
      );

      print('🚌 API URL: $uri');
      final response = await http.get(uri);
      print('🚌 API 응답 상태: ${response.statusCode}');

      if (response.statusCode == 200) {
        final arrivals = _parseArrivalsXml(response.body);
        print('🚌 파싱된 도착 정보: ${arrivals.length}개');
        return arrivals;
      }
      print('🚌 API 응답 실패: ${response.statusCode}');
      return [];
    } catch (e) {
      print('🚌 BIS API 호출 실패 (arsno): $e');
      return [];
    }
  }

  static List<ArrivalItem> _parseArrivalsXml(String xmlString) {
    try {
      print('🚌 XML 파싱 시작 (길이: ${xmlString.length})');
      final document = xml.XmlDocument.parse(xmlString);
      final items = document.findAllElements('item');
      print('🚌 XML에서 찾은 item 개수: ${items.length}');

      final arrivals = items.map((item) {
        String getText(String tagName) {
          final elements = item.findElements(tagName);
          return elements.isEmpty ? '' : elements.first.innerText.trim();
        }

        final arrival = ArrivalItem(
          lineid: getText('lineid'),
          lineno: getText('lineno'),
          nodenm: getText('nodenm'),
          min1: getText('min1'),
          station1: getText('station1'),
          min2: getText('min2'),
          station2: getText('station2'),
          bustype: getText('bustype').isEmpty ? null : getText('bustype'),
          lowplate1: getText('lowplate1').isEmpty ? null : getText('lowplate1'),
        );

        print('🚌 파싱된 버스: ${arrival.lineno} (${arrival.min1}분)');
        return arrival;
      }).toList();

      print('🚌 XML 파싱 완료: ${arrivals.length}개 버스');
      return arrivals;
    } catch (e) {
      print('🚌 XML 파싱 실패: $e');
      print(
        '🚌 XML 내용 (처음 500자): ${xmlString.substring(0, xmlString.length > 500 ? 500 : xmlString.length)}',
      );
      return [];
    }
  }
}

// 정류장 도착 정보 provider
final stopArrivalsProvider = FutureProvider.family<List<ArrivalItem>, StopMeta>(
  (ref, stopMeta) async {
    // 먼저 bstopid로 시도
    List<ArrivalItem> arrivals = await BisApiClient.fetchArrivalsByStopId(
      stopMeta.bstopid,
    );

    // 결과가 없고 arsno가 있으면 arsno로 재시도
    if (arrivals.isEmpty && stopMeta.arsno.isNotEmpty) {
      print('🚌 bstopid로 결과 없음, arsno로 재시도: ${stopMeta.arsno}');
      arrivals = await BisApiClient.fetchArrivalsByArsno(stopMeta.arsno);
    }

    return arrivals;
  },
);

// 자동 새로고침 ticker (15초 간격으로 설정 - 성능 최적화)
final autoRefreshTickerProvider = StreamProvider.autoDispose<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 15), (_) => DateTime.now());
});

// 정류장 상세페이지에서 정류장 탭의 데이터를 가져오는 provider
final stopDetailFromTabsProvider = Provider.family<({Stop s, int m})?, String>((
  ref,
  bstopid,
) {
  // 정류장 탭의 nearbyStopsListProvider에서 해당 정류장 찾기
  final nearbyStops = ref.watch(nearbyStopsListProvider);
  try {
    return nearbyStops.firstWhere((item) => item.s.id == bstopid);
  } catch (e) {
    return null;
  }
});

// 정류장 상세페이지에서 정류장 탭의 버스 도착 정보를 가져오는 provider
final stopDetailBusArrivalsFromTabsProvider =
    Provider.family<AsyncValue<List<BusArrival>>?, String>((ref, bstopid) {
      // 정류장 탭에서 해당 정류장 찾기
      final nearbyStops = ref.watch(nearbyStopsListProvider);
      try {
        final stopData = nearbyStops.firstWhere((item) => item.s.id == bstopid);
        // 해당 정류장의 ARS 번호로 버스 도착 정보 가져오기
        if (stopData.s.arsno.isNotEmpty) {
          return ref.watch(busArrivalProvider(stopData.s.arsno));
        }
        return null;
      } catch (e) {
        return null;
      }
    });

// 버스 타입별 색상 매핑
class BusColorMapper {
  static Color getRouteColor(String lineno, String? bustype) {
    // 버스 타입에 따른 색상 매핑
    if (bustype != null) {
      if (bustype.contains('좌석') || bustype.contains('급행')) {
        return const Color(0xFFBA68C8); // 좌석/급행
      }
      if (bustype.contains('마을')) {
        return const Color(0xFF81C784); // 마을
      }
      if (bustype.contains('심야')) {
        return const Color(0xFFFF8A65); // 심야
      }
      if (bustype.contains('일반')) {
        return const Color(0xFF64B5F6); // 일반
      }
    }

    // bustype이 없을 때 lineno로 판단
    if (RegExp(r'^\d{4}$').hasMatch(lineno)) {
      return const Color(0xFFBA68C8); // 4자리 숫자 → 좌석/급행
    }
    if (RegExp(r'[가-힣]').hasMatch(lineno)) {
      return const Color(0xFF81C784); // 한글 포함 → 마을
    }

    return const Color(0xFF64B5F6); // 기본값 → 일반
  }
}
