import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'cache_models.dart';

/// 로컬 캐시 데이터베이스 관리자
class CacheDatabase {
  static Database? _database;
  static const String _databaseName = 'bus_cache.db';
  static const int _databaseVersion = 1;

  /// 데이터베이스 인스턴스 가져오기
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 데이터베이스 초기화
  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 데이터베이스 생성
  static Future<void> _onCreate(Database db, int version) async {
    print('🗄️ 캐시 데이터베이스 생성 중...');

    // 정류장 정보 테이블
    await db.execute('''
      CREATE TABLE cached_stations (
        bstopid TEXT PRIMARY KEY,
        bstopnm TEXT NOT NULL,
        arsno TEXT NOT NULL,
        lat REAL NOT NULL,
        lng REAL NOT NULL,
        cached_at INTEGER NOT NULL,
        expires_at INTEGER NOT NULL
      )
    ''');

    // 도착 정보 테이블
    await db.execute('''
      CREATE TABLE cached_arrivals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        arsno TEXT NOT NULL,
        bstopid TEXT NOT NULL,
        nodenm TEXT NOT NULL,
        gpsx REAL NOT NULL,
        gpsy REAL NOT NULL,
        lineno TEXT NOT NULL,
        lineid TEXT NOT NULL,
        bstopidx INTEGER NOT NULL,
        bustype TEXT NOT NULL,
        carno1 TEXT NOT NULL,
        carno2 TEXT NOT NULL,
        min1 TEXT NOT NULL,
        min2 TEXT NOT NULL,
        station1 TEXT NOT NULL,
        station2 TEXT NOT NULL,
        lowplate1 TEXT NOT NULL,
        lowplate2 TEXT NOT NULL,
        seat1 TEXT NOT NULL,
        seat2 TEXT NOT NULL,
        cached_at INTEGER NOT NULL,
        expires_at INTEGER NOT NULL
      )
    ''');

    // 노선 정보 테이블
    await db.execute('''
      CREATE TABLE cached_routes (
        lineid TEXT PRIMARY KEY,
        lineno TEXT NOT NULL,
        route_type TEXT NOT NULL,
        start_station TEXT NOT NULL,
        end_station TEXT NOT NULL,
        cached_at INTEGER NOT NULL,
        expires_at INTEGER NOT NULL
      )
    ''');

    // 인덱스 생성
    await db.execute('CREATE INDEX idx_cached_arrivals_arsno ON cached_arrivals(arsno)');
    await db.execute('CREATE INDEX idx_cached_arrivals_expires ON cached_arrivals(expires_at)');
    await db.execute('CREATE INDEX idx_cached_stations_expires ON cached_stations(expires_at)');
    await db.execute('CREATE INDEX idx_cached_routes_expires ON cached_routes(expires_at)');

    print('✅ 캐시 데이터베이스 생성 완료');
  }

  /// 데이터베이스 업그레이드
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('🔄 캐시 데이터베이스 업그레이드: $oldVersion -> $newVersion');
    // 향후 스키마 변경 시 여기에 업그레이드 로직 추가
  }

  /// 정류장 정보 저장
  static Future<void> saveStation(CachedStation station) async {
    final db = await database;
    await db.insert(
      'cached_stations',
      station.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('💾 정류장 정보 캐시 저장: ${station.bstopnm}');
  }

  /// 정류장 정보 조회
  static Future<CachedStation?> getStation(String bstopid) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cached_stations',
      where: 'bstopid = ?',
      whereArgs: [bstopid],
    );

    if (maps.isEmpty) return null;

    final station = CachedStation.fromJson(maps.first);
    
    // 만료된 데이터인지 확인
    if (DateTime.now().isAfter(station.expiresAt)) {
      print('⏰ 만료된 정류장 정보 삭제: ${station.bstopnm}');
      await deleteStation(bstopid);
      return null;
    }

    return station;
  }

  /// 정류장 정보 삭제
  static Future<void> deleteStation(String bstopid) async {
    final db = await database;
    await db.delete(
      'cached_stations',
      where: 'bstopid = ?',
      whereArgs: [bstopid],
    );
  }

  /// 도착 정보 저장
  static Future<void> saveArrivals(List<CachedArrival> arrivals) async {
    if (arrivals.isEmpty) return;

    final db = await database;
    final batch = db.batch();

    // 기존 도착 정보 삭제 (같은 ARS번호)
    final arsno = arrivals.first.arsno;
    batch.delete(
      'cached_arrivals',
      where: 'arsno = ?',
      whereArgs: [arsno],
    );

    // 새로운 도착 정보 삽입
    for (final arrival in arrivals) {
      batch.insert('cached_arrivals', arrival.toJson());
    }

    await batch.commit();
    print('💾 도착 정보 캐시 저장: ${arrivals.length}개 (ARS: $arsno)');
  }

  /// 도착 정보 조회
  static Future<List<CachedArrival>> getArrivals(String arsno) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cached_arrivals',
      where: 'arsno = ?',
      whereArgs: [arsno],
      orderBy: 'cached_at DESC',
    );

    if (maps.isEmpty) return [];

    final arrivals = maps.map((map) => CachedArrival.fromJson(map)).toList();
    
    // 만료된 데이터 필터링
    final now = DateTime.now();
    final validArrivals = arrivals.where((arrival) => 
      now.isBefore(arrival.expiresAt)
    ).toList();

    // 만료된 데이터 삭제
    if (validArrivals.length != arrivals.length) {
      await _cleanExpiredArrivals(arsno);
    }

    return validArrivals;
  }

  /// 만료된 도착 정보 정리
  static Future<void> _cleanExpiredArrivals(String arsno) async {
    final db = await database;
    await db.delete(
      'cached_arrivals',
      where: 'arsno = ? AND expires_at < ?',
      whereArgs: [arsno, DateTime.now().millisecondsSinceEpoch],
    );
  }

  /// 노선 정보 저장
  static Future<void> saveRoute(CachedRoute route) async {
    final db = await database;
    await db.insert(
      'cached_routes',
      route.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('💾 노선 정보 캐시 저장: ${route.lineno}');
  }

  /// 노선 정보 조회
  static Future<CachedRoute?> getRoute(String lineid) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cached_routes',
      where: 'lineid = ?',
      whereArgs: [lineid],
    );

    if (maps.isEmpty) return null;

    final route = CachedRoute.fromJson(maps.first);
    
    // 만료된 데이터인지 확인
    if (DateTime.now().isAfter(route.expiresAt)) {
      print('⏰ 만료된 노선 정보 삭제: ${route.lineno}');
      await deleteRoute(lineid);
      return null;
    }

    return route;
  }

  /// 노선 정보 삭제
  static Future<void> deleteRoute(String lineid) async {
    final db = await database;
    await db.delete(
      'cached_routes',
      where: 'lineid = ?',
      whereArgs: [lineid],
    );
  }

  /// 전체 만료된 데이터 정리
  static Future<void> cleanExpiredData() async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final stationsDeleted = await db.delete(
      'cached_stations',
      where: 'expires_at < ?',
      whereArgs: [now],
    );

    final arrivalsDeleted = await db.delete(
      'cached_arrivals',
      where: 'expires_at < ?',
      whereArgs: [now],
    );

    final routesDeleted = await db.delete(
      'cached_routes',
      where: 'expires_at < ?',
      whereArgs: [now],
    );

    print('🧹 만료된 캐시 데이터 정리: 정류장 $stationsDeleted개, 도착정보 $arrivalsDeleted개, 노선 $routesDeleted개');
  }

  /// 캐시 상태 정보 조회
  static Future<CacheStatus> getCacheStatus() async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final stationCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM cached_stations'
    )) ?? 0;

    final arrivalCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM cached_arrivals'
    )) ?? 0;

    final routeCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM cached_routes'
    )) ?? 0;

    final expiredCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM cached_stations WHERE expires_at < ?',
      [now]
    )) ?? 0;

    final lastUpdate = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT MAX(cached_at) FROM cached_arrivals'
    )) ?? 0;

    return CacheStatus(
      isOnline: true, // 이 값은 외부에서 설정
      lastUpdate: DateTime.fromMillisecondsSinceEpoch(lastUpdate),
      totalCachedItems: stationCount + arrivalCount + routeCount,
      expiredItems: expiredCount,
      hasOfflineData: stationCount > 0 || arrivalCount > 0 || routeCount > 0,
    );
  }

  /// 데이터베이스 닫기
  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

