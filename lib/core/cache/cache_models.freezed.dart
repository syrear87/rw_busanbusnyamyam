// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cache_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CachedStation _$CachedStationFromJson(Map<String, dynamic> json) {
  return _CachedStation.fromJson(json);
}

/// @nodoc
mixin _$CachedStation {
  String get bstopid => throw _privateConstructorUsedError;
  String get bstopnm => throw _privateConstructorUsedError;
  String get arsno => throw _privateConstructorUsedError;
  double get lat => throw _privateConstructorUsedError;
  double get lng => throw _privateConstructorUsedError;
  DateTime get cachedAt => throw _privateConstructorUsedError;
  DateTime get expiresAt => throw _privateConstructorUsedError;

  /// Serializes this CachedStation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CachedStation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CachedStationCopyWith<CachedStation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CachedStationCopyWith<$Res> {
  factory $CachedStationCopyWith(
    CachedStation value,
    $Res Function(CachedStation) then,
  ) = _$CachedStationCopyWithImpl<$Res, CachedStation>;
  @useResult
  $Res call({
    String bstopid,
    String bstopnm,
    String arsno,
    double lat,
    double lng,
    DateTime cachedAt,
    DateTime expiresAt,
  });
}

/// @nodoc
class _$CachedStationCopyWithImpl<$Res, $Val extends CachedStation>
    implements $CachedStationCopyWith<$Res> {
  _$CachedStationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CachedStation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bstopid = null,
    Object? bstopnm = null,
    Object? arsno = null,
    Object? lat = null,
    Object? lng = null,
    Object? cachedAt = null,
    Object? expiresAt = null,
  }) {
    return _then(
      _value.copyWith(
            bstopid: null == bstopid
                ? _value.bstopid
                : bstopid // ignore: cast_nullable_to_non_nullable
                      as String,
            bstopnm: null == bstopnm
                ? _value.bstopnm
                : bstopnm // ignore: cast_nullable_to_non_nullable
                      as String,
            arsno: null == arsno
                ? _value.arsno
                : arsno // ignore: cast_nullable_to_non_nullable
                      as String,
            lat: null == lat
                ? _value.lat
                : lat // ignore: cast_nullable_to_non_nullable
                      as double,
            lng: null == lng
                ? _value.lng
                : lng // ignore: cast_nullable_to_non_nullable
                      as double,
            cachedAt: null == cachedAt
                ? _value.cachedAt
                : cachedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            expiresAt: null == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CachedStationImplCopyWith<$Res>
    implements $CachedStationCopyWith<$Res> {
  factory _$$CachedStationImplCopyWith(
    _$CachedStationImpl value,
    $Res Function(_$CachedStationImpl) then,
  ) = __$$CachedStationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String bstopid,
    String bstopnm,
    String arsno,
    double lat,
    double lng,
    DateTime cachedAt,
    DateTime expiresAt,
  });
}

/// @nodoc
class __$$CachedStationImplCopyWithImpl<$Res>
    extends _$CachedStationCopyWithImpl<$Res, _$CachedStationImpl>
    implements _$$CachedStationImplCopyWith<$Res> {
  __$$CachedStationImplCopyWithImpl(
    _$CachedStationImpl _value,
    $Res Function(_$CachedStationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CachedStation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bstopid = null,
    Object? bstopnm = null,
    Object? arsno = null,
    Object? lat = null,
    Object? lng = null,
    Object? cachedAt = null,
    Object? expiresAt = null,
  }) {
    return _then(
      _$CachedStationImpl(
        bstopid: null == bstopid
            ? _value.bstopid
            : bstopid // ignore: cast_nullable_to_non_nullable
                  as String,
        bstopnm: null == bstopnm
            ? _value.bstopnm
            : bstopnm // ignore: cast_nullable_to_non_nullable
                  as String,
        arsno: null == arsno
            ? _value.arsno
            : arsno // ignore: cast_nullable_to_non_nullable
                  as String,
        lat: null == lat
            ? _value.lat
            : lat // ignore: cast_nullable_to_non_nullable
                  as double,
        lng: null == lng
            ? _value.lng
            : lng // ignore: cast_nullable_to_non_nullable
                  as double,
        cachedAt: null == cachedAt
            ? _value.cachedAt
            : cachedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        expiresAt: null == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CachedStationImpl implements _CachedStation {
  const _$CachedStationImpl({
    required this.bstopid,
    required this.bstopnm,
    required this.arsno,
    required this.lat,
    required this.lng,
    required this.cachedAt,
    required this.expiresAt,
  });

  factory _$CachedStationImpl.fromJson(Map<String, dynamic> json) =>
      _$$CachedStationImplFromJson(json);

  @override
  final String bstopid;
  @override
  final String bstopnm;
  @override
  final String arsno;
  @override
  final double lat;
  @override
  final double lng;
  @override
  final DateTime cachedAt;
  @override
  final DateTime expiresAt;

  @override
  String toString() {
    return 'CachedStation(bstopid: $bstopid, bstopnm: $bstopnm, arsno: $arsno, lat: $lat, lng: $lng, cachedAt: $cachedAt, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CachedStationImpl &&
            (identical(other.bstopid, bstopid) || other.bstopid == bstopid) &&
            (identical(other.bstopnm, bstopnm) || other.bstopnm == bstopnm) &&
            (identical(other.arsno, arsno) || other.arsno == arsno) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.cachedAt, cachedAt) ||
                other.cachedAt == cachedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    bstopid,
    bstopnm,
    arsno,
    lat,
    lng,
    cachedAt,
    expiresAt,
  );

  /// Create a copy of CachedStation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CachedStationImplCopyWith<_$CachedStationImpl> get copyWith =>
      __$$CachedStationImplCopyWithImpl<_$CachedStationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CachedStationImplToJson(this);
  }
}

abstract class _CachedStation implements CachedStation {
  const factory _CachedStation({
    required final String bstopid,
    required final String bstopnm,
    required final String arsno,
    required final double lat,
    required final double lng,
    required final DateTime cachedAt,
    required final DateTime expiresAt,
  }) = _$CachedStationImpl;

  factory _CachedStation.fromJson(Map<String, dynamic> json) =
      _$CachedStationImpl.fromJson;

  @override
  String get bstopid;
  @override
  String get bstopnm;
  @override
  String get arsno;
  @override
  double get lat;
  @override
  double get lng;
  @override
  DateTime get cachedAt;
  @override
  DateTime get expiresAt;

  /// Create a copy of CachedStation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CachedStationImplCopyWith<_$CachedStationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CachedArrival _$CachedArrivalFromJson(Map<String, dynamic> json) {
  return _CachedArrival.fromJson(json);
}

/// @nodoc
mixin _$CachedArrival {
  String get arsno => throw _privateConstructorUsedError;
  String get bstopid => throw _privateConstructorUsedError;
  String get nodenm => throw _privateConstructorUsedError;
  double get gpsx => throw _privateConstructorUsedError;
  double get gpsy => throw _privateConstructorUsedError;
  String get lineno => throw _privateConstructorUsedError;
  String get lineid => throw _privateConstructorUsedError;
  int get bstopidx => throw _privateConstructorUsedError;
  String get bustype => throw _privateConstructorUsedError;
  String get carno1 => throw _privateConstructorUsedError;
  String get carno2 => throw _privateConstructorUsedError;
  String get min1 => throw _privateConstructorUsedError;
  String get min2 => throw _privateConstructorUsedError;
  String get station1 => throw _privateConstructorUsedError;
  String get station2 => throw _privateConstructorUsedError;
  String get lowplate1 => throw _privateConstructorUsedError;
  String get lowplate2 => throw _privateConstructorUsedError;
  String get seat1 => throw _privateConstructorUsedError;
  String get seat2 => throw _privateConstructorUsedError;
  DateTime get cachedAt => throw _privateConstructorUsedError;
  DateTime get expiresAt => throw _privateConstructorUsedError;

  /// Serializes this CachedArrival to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CachedArrival
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CachedArrivalCopyWith<CachedArrival> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CachedArrivalCopyWith<$Res> {
  factory $CachedArrivalCopyWith(
    CachedArrival value,
    $Res Function(CachedArrival) then,
  ) = _$CachedArrivalCopyWithImpl<$Res, CachedArrival>;
  @useResult
  $Res call({
    String arsno,
    String bstopid,
    String nodenm,
    double gpsx,
    double gpsy,
    String lineno,
    String lineid,
    int bstopidx,
    String bustype,
    String carno1,
    String carno2,
    String min1,
    String min2,
    String station1,
    String station2,
    String lowplate1,
    String lowplate2,
    String seat1,
    String seat2,
    DateTime cachedAt,
    DateTime expiresAt,
  });
}

/// @nodoc
class _$CachedArrivalCopyWithImpl<$Res, $Val extends CachedArrival>
    implements $CachedArrivalCopyWith<$Res> {
  _$CachedArrivalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CachedArrival
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? arsno = null,
    Object? bstopid = null,
    Object? nodenm = null,
    Object? gpsx = null,
    Object? gpsy = null,
    Object? lineno = null,
    Object? lineid = null,
    Object? bstopidx = null,
    Object? bustype = null,
    Object? carno1 = null,
    Object? carno2 = null,
    Object? min1 = null,
    Object? min2 = null,
    Object? station1 = null,
    Object? station2 = null,
    Object? lowplate1 = null,
    Object? lowplate2 = null,
    Object? seat1 = null,
    Object? seat2 = null,
    Object? cachedAt = null,
    Object? expiresAt = null,
  }) {
    return _then(
      _value.copyWith(
            arsno: null == arsno
                ? _value.arsno
                : arsno // ignore: cast_nullable_to_non_nullable
                      as String,
            bstopid: null == bstopid
                ? _value.bstopid
                : bstopid // ignore: cast_nullable_to_non_nullable
                      as String,
            nodenm: null == nodenm
                ? _value.nodenm
                : nodenm // ignore: cast_nullable_to_non_nullable
                      as String,
            gpsx: null == gpsx
                ? _value.gpsx
                : gpsx // ignore: cast_nullable_to_non_nullable
                      as double,
            gpsy: null == gpsy
                ? _value.gpsy
                : gpsy // ignore: cast_nullable_to_non_nullable
                      as double,
            lineno: null == lineno
                ? _value.lineno
                : lineno // ignore: cast_nullable_to_non_nullable
                      as String,
            lineid: null == lineid
                ? _value.lineid
                : lineid // ignore: cast_nullable_to_non_nullable
                      as String,
            bstopidx: null == bstopidx
                ? _value.bstopidx
                : bstopidx // ignore: cast_nullable_to_non_nullable
                      as int,
            bustype: null == bustype
                ? _value.bustype
                : bustype // ignore: cast_nullable_to_non_nullable
                      as String,
            carno1: null == carno1
                ? _value.carno1
                : carno1 // ignore: cast_nullable_to_non_nullable
                      as String,
            carno2: null == carno2
                ? _value.carno2
                : carno2 // ignore: cast_nullable_to_non_nullable
                      as String,
            min1: null == min1
                ? _value.min1
                : min1 // ignore: cast_nullable_to_non_nullable
                      as String,
            min2: null == min2
                ? _value.min2
                : min2 // ignore: cast_nullable_to_non_nullable
                      as String,
            station1: null == station1
                ? _value.station1
                : station1 // ignore: cast_nullable_to_non_nullable
                      as String,
            station2: null == station2
                ? _value.station2
                : station2 // ignore: cast_nullable_to_non_nullable
                      as String,
            lowplate1: null == lowplate1
                ? _value.lowplate1
                : lowplate1 // ignore: cast_nullable_to_non_nullable
                      as String,
            lowplate2: null == lowplate2
                ? _value.lowplate2
                : lowplate2 // ignore: cast_nullable_to_non_nullable
                      as String,
            seat1: null == seat1
                ? _value.seat1
                : seat1 // ignore: cast_nullable_to_non_nullable
                      as String,
            seat2: null == seat2
                ? _value.seat2
                : seat2 // ignore: cast_nullable_to_non_nullable
                      as String,
            cachedAt: null == cachedAt
                ? _value.cachedAt
                : cachedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            expiresAt: null == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CachedArrivalImplCopyWith<$Res>
    implements $CachedArrivalCopyWith<$Res> {
  factory _$$CachedArrivalImplCopyWith(
    _$CachedArrivalImpl value,
    $Res Function(_$CachedArrivalImpl) then,
  ) = __$$CachedArrivalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String arsno,
    String bstopid,
    String nodenm,
    double gpsx,
    double gpsy,
    String lineno,
    String lineid,
    int bstopidx,
    String bustype,
    String carno1,
    String carno2,
    String min1,
    String min2,
    String station1,
    String station2,
    String lowplate1,
    String lowplate2,
    String seat1,
    String seat2,
    DateTime cachedAt,
    DateTime expiresAt,
  });
}

/// @nodoc
class __$$CachedArrivalImplCopyWithImpl<$Res>
    extends _$CachedArrivalCopyWithImpl<$Res, _$CachedArrivalImpl>
    implements _$$CachedArrivalImplCopyWith<$Res> {
  __$$CachedArrivalImplCopyWithImpl(
    _$CachedArrivalImpl _value,
    $Res Function(_$CachedArrivalImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CachedArrival
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? arsno = null,
    Object? bstopid = null,
    Object? nodenm = null,
    Object? gpsx = null,
    Object? gpsy = null,
    Object? lineno = null,
    Object? lineid = null,
    Object? bstopidx = null,
    Object? bustype = null,
    Object? carno1 = null,
    Object? carno2 = null,
    Object? min1 = null,
    Object? min2 = null,
    Object? station1 = null,
    Object? station2 = null,
    Object? lowplate1 = null,
    Object? lowplate2 = null,
    Object? seat1 = null,
    Object? seat2 = null,
    Object? cachedAt = null,
    Object? expiresAt = null,
  }) {
    return _then(
      _$CachedArrivalImpl(
        arsno: null == arsno
            ? _value.arsno
            : arsno // ignore: cast_nullable_to_non_nullable
                  as String,
        bstopid: null == bstopid
            ? _value.bstopid
            : bstopid // ignore: cast_nullable_to_non_nullable
                  as String,
        nodenm: null == nodenm
            ? _value.nodenm
            : nodenm // ignore: cast_nullable_to_non_nullable
                  as String,
        gpsx: null == gpsx
            ? _value.gpsx
            : gpsx // ignore: cast_nullable_to_non_nullable
                  as double,
        gpsy: null == gpsy
            ? _value.gpsy
            : gpsy // ignore: cast_nullable_to_non_nullable
                  as double,
        lineno: null == lineno
            ? _value.lineno
            : lineno // ignore: cast_nullable_to_non_nullable
                  as String,
        lineid: null == lineid
            ? _value.lineid
            : lineid // ignore: cast_nullable_to_non_nullable
                  as String,
        bstopidx: null == bstopidx
            ? _value.bstopidx
            : bstopidx // ignore: cast_nullable_to_non_nullable
                  as int,
        bustype: null == bustype
            ? _value.bustype
            : bustype // ignore: cast_nullable_to_non_nullable
                  as String,
        carno1: null == carno1
            ? _value.carno1
            : carno1 // ignore: cast_nullable_to_non_nullable
                  as String,
        carno2: null == carno2
            ? _value.carno2
            : carno2 // ignore: cast_nullable_to_non_nullable
                  as String,
        min1: null == min1
            ? _value.min1
            : min1 // ignore: cast_nullable_to_non_nullable
                  as String,
        min2: null == min2
            ? _value.min2
            : min2 // ignore: cast_nullable_to_non_nullable
                  as String,
        station1: null == station1
            ? _value.station1
            : station1 // ignore: cast_nullable_to_non_nullable
                  as String,
        station2: null == station2
            ? _value.station2
            : station2 // ignore: cast_nullable_to_non_nullable
                  as String,
        lowplate1: null == lowplate1
            ? _value.lowplate1
            : lowplate1 // ignore: cast_nullable_to_non_nullable
                  as String,
        lowplate2: null == lowplate2
            ? _value.lowplate2
            : lowplate2 // ignore: cast_nullable_to_non_nullable
                  as String,
        seat1: null == seat1
            ? _value.seat1
            : seat1 // ignore: cast_nullable_to_non_nullable
                  as String,
        seat2: null == seat2
            ? _value.seat2
            : seat2 // ignore: cast_nullable_to_non_nullable
                  as String,
        cachedAt: null == cachedAt
            ? _value.cachedAt
            : cachedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        expiresAt: null == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CachedArrivalImpl implements _CachedArrival {
  const _$CachedArrivalImpl({
    required this.arsno,
    required this.bstopid,
    required this.nodenm,
    required this.gpsx,
    required this.gpsy,
    required this.lineno,
    required this.lineid,
    required this.bstopidx,
    required this.bustype,
    required this.carno1,
    required this.carno2,
    required this.min1,
    required this.min2,
    required this.station1,
    required this.station2,
    required this.lowplate1,
    required this.lowplate2,
    required this.seat1,
    required this.seat2,
    required this.cachedAt,
    required this.expiresAt,
  });

  factory _$CachedArrivalImpl.fromJson(Map<String, dynamic> json) =>
      _$$CachedArrivalImplFromJson(json);

  @override
  final String arsno;
  @override
  final String bstopid;
  @override
  final String nodenm;
  @override
  final double gpsx;
  @override
  final double gpsy;
  @override
  final String lineno;
  @override
  final String lineid;
  @override
  final int bstopidx;
  @override
  final String bustype;
  @override
  final String carno1;
  @override
  final String carno2;
  @override
  final String min1;
  @override
  final String min2;
  @override
  final String station1;
  @override
  final String station2;
  @override
  final String lowplate1;
  @override
  final String lowplate2;
  @override
  final String seat1;
  @override
  final String seat2;
  @override
  final DateTime cachedAt;
  @override
  final DateTime expiresAt;

  @override
  String toString() {
    return 'CachedArrival(arsno: $arsno, bstopid: $bstopid, nodenm: $nodenm, gpsx: $gpsx, gpsy: $gpsy, lineno: $lineno, lineid: $lineid, bstopidx: $bstopidx, bustype: $bustype, carno1: $carno1, carno2: $carno2, min1: $min1, min2: $min2, station1: $station1, station2: $station2, lowplate1: $lowplate1, lowplate2: $lowplate2, seat1: $seat1, seat2: $seat2, cachedAt: $cachedAt, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CachedArrivalImpl &&
            (identical(other.arsno, arsno) || other.arsno == arsno) &&
            (identical(other.bstopid, bstopid) || other.bstopid == bstopid) &&
            (identical(other.nodenm, nodenm) || other.nodenm == nodenm) &&
            (identical(other.gpsx, gpsx) || other.gpsx == gpsx) &&
            (identical(other.gpsy, gpsy) || other.gpsy == gpsy) &&
            (identical(other.lineno, lineno) || other.lineno == lineno) &&
            (identical(other.lineid, lineid) || other.lineid == lineid) &&
            (identical(other.bstopidx, bstopidx) ||
                other.bstopidx == bstopidx) &&
            (identical(other.bustype, bustype) || other.bustype == bustype) &&
            (identical(other.carno1, carno1) || other.carno1 == carno1) &&
            (identical(other.carno2, carno2) || other.carno2 == carno2) &&
            (identical(other.min1, min1) || other.min1 == min1) &&
            (identical(other.min2, min2) || other.min2 == min2) &&
            (identical(other.station1, station1) ||
                other.station1 == station1) &&
            (identical(other.station2, station2) ||
                other.station2 == station2) &&
            (identical(other.lowplate1, lowplate1) ||
                other.lowplate1 == lowplate1) &&
            (identical(other.lowplate2, lowplate2) ||
                other.lowplate2 == lowplate2) &&
            (identical(other.seat1, seat1) || other.seat1 == seat1) &&
            (identical(other.seat2, seat2) || other.seat2 == seat2) &&
            (identical(other.cachedAt, cachedAt) ||
                other.cachedAt == cachedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    arsno,
    bstopid,
    nodenm,
    gpsx,
    gpsy,
    lineno,
    lineid,
    bstopidx,
    bustype,
    carno1,
    carno2,
    min1,
    min2,
    station1,
    station2,
    lowplate1,
    lowplate2,
    seat1,
    seat2,
    cachedAt,
    expiresAt,
  ]);

  /// Create a copy of CachedArrival
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CachedArrivalImplCopyWith<_$CachedArrivalImpl> get copyWith =>
      __$$CachedArrivalImplCopyWithImpl<_$CachedArrivalImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CachedArrivalImplToJson(this);
  }
}

abstract class _CachedArrival implements CachedArrival {
  const factory _CachedArrival({
    required final String arsno,
    required final String bstopid,
    required final String nodenm,
    required final double gpsx,
    required final double gpsy,
    required final String lineno,
    required final String lineid,
    required final int bstopidx,
    required final String bustype,
    required final String carno1,
    required final String carno2,
    required final String min1,
    required final String min2,
    required final String station1,
    required final String station2,
    required final String lowplate1,
    required final String lowplate2,
    required final String seat1,
    required final String seat2,
    required final DateTime cachedAt,
    required final DateTime expiresAt,
  }) = _$CachedArrivalImpl;

  factory _CachedArrival.fromJson(Map<String, dynamic> json) =
      _$CachedArrivalImpl.fromJson;

  @override
  String get arsno;
  @override
  String get bstopid;
  @override
  String get nodenm;
  @override
  double get gpsx;
  @override
  double get gpsy;
  @override
  String get lineno;
  @override
  String get lineid;
  @override
  int get bstopidx;
  @override
  String get bustype;
  @override
  String get carno1;
  @override
  String get carno2;
  @override
  String get min1;
  @override
  String get min2;
  @override
  String get station1;
  @override
  String get station2;
  @override
  String get lowplate1;
  @override
  String get lowplate2;
  @override
  String get seat1;
  @override
  String get seat2;
  @override
  DateTime get cachedAt;
  @override
  DateTime get expiresAt;

  /// Create a copy of CachedArrival
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CachedArrivalImplCopyWith<_$CachedArrivalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CachedRoute _$CachedRouteFromJson(Map<String, dynamic> json) {
  return _CachedRoute.fromJson(json);
}

/// @nodoc
mixin _$CachedRoute {
  String get lineid => throw _privateConstructorUsedError;
  String get lineno => throw _privateConstructorUsedError;
  String get routeType => throw _privateConstructorUsedError;
  String get startStation => throw _privateConstructorUsedError;
  String get endStation => throw _privateConstructorUsedError;
  DateTime get cachedAt => throw _privateConstructorUsedError;
  DateTime get expiresAt => throw _privateConstructorUsedError;

  /// Serializes this CachedRoute to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CachedRoute
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CachedRouteCopyWith<CachedRoute> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CachedRouteCopyWith<$Res> {
  factory $CachedRouteCopyWith(
    CachedRoute value,
    $Res Function(CachedRoute) then,
  ) = _$CachedRouteCopyWithImpl<$Res, CachedRoute>;
  @useResult
  $Res call({
    String lineid,
    String lineno,
    String routeType,
    String startStation,
    String endStation,
    DateTime cachedAt,
    DateTime expiresAt,
  });
}

/// @nodoc
class _$CachedRouteCopyWithImpl<$Res, $Val extends CachedRoute>
    implements $CachedRouteCopyWith<$Res> {
  _$CachedRouteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CachedRoute
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lineid = null,
    Object? lineno = null,
    Object? routeType = null,
    Object? startStation = null,
    Object? endStation = null,
    Object? cachedAt = null,
    Object? expiresAt = null,
  }) {
    return _then(
      _value.copyWith(
            lineid: null == lineid
                ? _value.lineid
                : lineid // ignore: cast_nullable_to_non_nullable
                      as String,
            lineno: null == lineno
                ? _value.lineno
                : lineno // ignore: cast_nullable_to_non_nullable
                      as String,
            routeType: null == routeType
                ? _value.routeType
                : routeType // ignore: cast_nullable_to_non_nullable
                      as String,
            startStation: null == startStation
                ? _value.startStation
                : startStation // ignore: cast_nullable_to_non_nullable
                      as String,
            endStation: null == endStation
                ? _value.endStation
                : endStation // ignore: cast_nullable_to_non_nullable
                      as String,
            cachedAt: null == cachedAt
                ? _value.cachedAt
                : cachedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            expiresAt: null == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CachedRouteImplCopyWith<$Res>
    implements $CachedRouteCopyWith<$Res> {
  factory _$$CachedRouteImplCopyWith(
    _$CachedRouteImpl value,
    $Res Function(_$CachedRouteImpl) then,
  ) = __$$CachedRouteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String lineid,
    String lineno,
    String routeType,
    String startStation,
    String endStation,
    DateTime cachedAt,
    DateTime expiresAt,
  });
}

/// @nodoc
class __$$CachedRouteImplCopyWithImpl<$Res>
    extends _$CachedRouteCopyWithImpl<$Res, _$CachedRouteImpl>
    implements _$$CachedRouteImplCopyWith<$Res> {
  __$$CachedRouteImplCopyWithImpl(
    _$CachedRouteImpl _value,
    $Res Function(_$CachedRouteImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CachedRoute
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lineid = null,
    Object? lineno = null,
    Object? routeType = null,
    Object? startStation = null,
    Object? endStation = null,
    Object? cachedAt = null,
    Object? expiresAt = null,
  }) {
    return _then(
      _$CachedRouteImpl(
        lineid: null == lineid
            ? _value.lineid
            : lineid // ignore: cast_nullable_to_non_nullable
                  as String,
        lineno: null == lineno
            ? _value.lineno
            : lineno // ignore: cast_nullable_to_non_nullable
                  as String,
        routeType: null == routeType
            ? _value.routeType
            : routeType // ignore: cast_nullable_to_non_nullable
                  as String,
        startStation: null == startStation
            ? _value.startStation
            : startStation // ignore: cast_nullable_to_non_nullable
                  as String,
        endStation: null == endStation
            ? _value.endStation
            : endStation // ignore: cast_nullable_to_non_nullable
                  as String,
        cachedAt: null == cachedAt
            ? _value.cachedAt
            : cachedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        expiresAt: null == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CachedRouteImpl implements _CachedRoute {
  const _$CachedRouteImpl({
    required this.lineid,
    required this.lineno,
    required this.routeType,
    required this.startStation,
    required this.endStation,
    required this.cachedAt,
    required this.expiresAt,
  });

  factory _$CachedRouteImpl.fromJson(Map<String, dynamic> json) =>
      _$$CachedRouteImplFromJson(json);

  @override
  final String lineid;
  @override
  final String lineno;
  @override
  final String routeType;
  @override
  final String startStation;
  @override
  final String endStation;
  @override
  final DateTime cachedAt;
  @override
  final DateTime expiresAt;

  @override
  String toString() {
    return 'CachedRoute(lineid: $lineid, lineno: $lineno, routeType: $routeType, startStation: $startStation, endStation: $endStation, cachedAt: $cachedAt, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CachedRouteImpl &&
            (identical(other.lineid, lineid) || other.lineid == lineid) &&
            (identical(other.lineno, lineno) || other.lineno == lineno) &&
            (identical(other.routeType, routeType) ||
                other.routeType == routeType) &&
            (identical(other.startStation, startStation) ||
                other.startStation == startStation) &&
            (identical(other.endStation, endStation) ||
                other.endStation == endStation) &&
            (identical(other.cachedAt, cachedAt) ||
                other.cachedAt == cachedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    lineid,
    lineno,
    routeType,
    startStation,
    endStation,
    cachedAt,
    expiresAt,
  );

  /// Create a copy of CachedRoute
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CachedRouteImplCopyWith<_$CachedRouteImpl> get copyWith =>
      __$$CachedRouteImplCopyWithImpl<_$CachedRouteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CachedRouteImplToJson(this);
  }
}

abstract class _CachedRoute implements CachedRoute {
  const factory _CachedRoute({
    required final String lineid,
    required final String lineno,
    required final String routeType,
    required final String startStation,
    required final String endStation,
    required final DateTime cachedAt,
    required final DateTime expiresAt,
  }) = _$CachedRouteImpl;

  factory _CachedRoute.fromJson(Map<String, dynamic> json) =
      _$CachedRouteImpl.fromJson;

  @override
  String get lineid;
  @override
  String get lineno;
  @override
  String get routeType;
  @override
  String get startStation;
  @override
  String get endStation;
  @override
  DateTime get cachedAt;
  @override
  DateTime get expiresAt;

  /// Create a copy of CachedRoute
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CachedRouteImplCopyWith<_$CachedRouteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CachePolicy _$CachePolicyFromJson(Map<String, dynamic> json) {
  return _CachePolicy.fromJson(json);
}

/// @nodoc
mixin _$CachePolicy {
  Duration get arrivalCacheExpiry => throw _privateConstructorUsedError;
  Duration get stationCacheExpiry => throw _privateConstructorUsedError;
  Duration get routeCacheExpiry => throw _privateConstructorUsedError;
  Duration get refreshInterval => throw _privateConstructorUsedError;
  bool get enableOfflineMode => throw _privateConstructorUsedError;

  /// Serializes this CachePolicy to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CachePolicy
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CachePolicyCopyWith<CachePolicy> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CachePolicyCopyWith<$Res> {
  factory $CachePolicyCopyWith(
    CachePolicy value,
    $Res Function(CachePolicy) then,
  ) = _$CachePolicyCopyWithImpl<$Res, CachePolicy>;
  @useResult
  $Res call({
    Duration arrivalCacheExpiry,
    Duration stationCacheExpiry,
    Duration routeCacheExpiry,
    Duration refreshInterval,
    bool enableOfflineMode,
  });
}

/// @nodoc
class _$CachePolicyCopyWithImpl<$Res, $Val extends CachePolicy>
    implements $CachePolicyCopyWith<$Res> {
  _$CachePolicyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CachePolicy
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? arrivalCacheExpiry = null,
    Object? stationCacheExpiry = null,
    Object? routeCacheExpiry = null,
    Object? refreshInterval = null,
    Object? enableOfflineMode = null,
  }) {
    return _then(
      _value.copyWith(
            arrivalCacheExpiry: null == arrivalCacheExpiry
                ? _value.arrivalCacheExpiry
                : arrivalCacheExpiry // ignore: cast_nullable_to_non_nullable
                      as Duration,
            stationCacheExpiry: null == stationCacheExpiry
                ? _value.stationCacheExpiry
                : stationCacheExpiry // ignore: cast_nullable_to_non_nullable
                      as Duration,
            routeCacheExpiry: null == routeCacheExpiry
                ? _value.routeCacheExpiry
                : routeCacheExpiry // ignore: cast_nullable_to_non_nullable
                      as Duration,
            refreshInterval: null == refreshInterval
                ? _value.refreshInterval
                : refreshInterval // ignore: cast_nullable_to_non_nullable
                      as Duration,
            enableOfflineMode: null == enableOfflineMode
                ? _value.enableOfflineMode
                : enableOfflineMode // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CachePolicyImplCopyWith<$Res>
    implements $CachePolicyCopyWith<$Res> {
  factory _$$CachePolicyImplCopyWith(
    _$CachePolicyImpl value,
    $Res Function(_$CachePolicyImpl) then,
  ) = __$$CachePolicyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Duration arrivalCacheExpiry,
    Duration stationCacheExpiry,
    Duration routeCacheExpiry,
    Duration refreshInterval,
    bool enableOfflineMode,
  });
}

/// @nodoc
class __$$CachePolicyImplCopyWithImpl<$Res>
    extends _$CachePolicyCopyWithImpl<$Res, _$CachePolicyImpl>
    implements _$$CachePolicyImplCopyWith<$Res> {
  __$$CachePolicyImplCopyWithImpl(
    _$CachePolicyImpl _value,
    $Res Function(_$CachePolicyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CachePolicy
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? arrivalCacheExpiry = null,
    Object? stationCacheExpiry = null,
    Object? routeCacheExpiry = null,
    Object? refreshInterval = null,
    Object? enableOfflineMode = null,
  }) {
    return _then(
      _$CachePolicyImpl(
        arrivalCacheExpiry: null == arrivalCacheExpiry
            ? _value.arrivalCacheExpiry
            : arrivalCacheExpiry // ignore: cast_nullable_to_non_nullable
                  as Duration,
        stationCacheExpiry: null == stationCacheExpiry
            ? _value.stationCacheExpiry
            : stationCacheExpiry // ignore: cast_nullable_to_non_nullable
                  as Duration,
        routeCacheExpiry: null == routeCacheExpiry
            ? _value.routeCacheExpiry
            : routeCacheExpiry // ignore: cast_nullable_to_non_nullable
                  as Duration,
        refreshInterval: null == refreshInterval
            ? _value.refreshInterval
            : refreshInterval // ignore: cast_nullable_to_non_nullable
                  as Duration,
        enableOfflineMode: null == enableOfflineMode
            ? _value.enableOfflineMode
            : enableOfflineMode // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CachePolicyImpl implements _CachePolicy {
  const _$CachePolicyImpl({
    this.arrivalCacheExpiry = const Duration(minutes: 5),
    this.stationCacheExpiry = const Duration(hours: 24),
    this.routeCacheExpiry = const Duration(hours: 12),
    this.refreshInterval = const Duration(minutes: 1),
    this.enableOfflineMode = true,
  });

  factory _$CachePolicyImpl.fromJson(Map<String, dynamic> json) =>
      _$$CachePolicyImplFromJson(json);

  @override
  @JsonKey()
  final Duration arrivalCacheExpiry;
  @override
  @JsonKey()
  final Duration stationCacheExpiry;
  @override
  @JsonKey()
  final Duration routeCacheExpiry;
  @override
  @JsonKey()
  final Duration refreshInterval;
  @override
  @JsonKey()
  final bool enableOfflineMode;

  @override
  String toString() {
    return 'CachePolicy(arrivalCacheExpiry: $arrivalCacheExpiry, stationCacheExpiry: $stationCacheExpiry, routeCacheExpiry: $routeCacheExpiry, refreshInterval: $refreshInterval, enableOfflineMode: $enableOfflineMode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CachePolicyImpl &&
            (identical(other.arrivalCacheExpiry, arrivalCacheExpiry) ||
                other.arrivalCacheExpiry == arrivalCacheExpiry) &&
            (identical(other.stationCacheExpiry, stationCacheExpiry) ||
                other.stationCacheExpiry == stationCacheExpiry) &&
            (identical(other.routeCacheExpiry, routeCacheExpiry) ||
                other.routeCacheExpiry == routeCacheExpiry) &&
            (identical(other.refreshInterval, refreshInterval) ||
                other.refreshInterval == refreshInterval) &&
            (identical(other.enableOfflineMode, enableOfflineMode) ||
                other.enableOfflineMode == enableOfflineMode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    arrivalCacheExpiry,
    stationCacheExpiry,
    routeCacheExpiry,
    refreshInterval,
    enableOfflineMode,
  );

  /// Create a copy of CachePolicy
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CachePolicyImplCopyWith<_$CachePolicyImpl> get copyWith =>
      __$$CachePolicyImplCopyWithImpl<_$CachePolicyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CachePolicyImplToJson(this);
  }
}

abstract class _CachePolicy implements CachePolicy {
  const factory _CachePolicy({
    final Duration arrivalCacheExpiry,
    final Duration stationCacheExpiry,
    final Duration routeCacheExpiry,
    final Duration refreshInterval,
    final bool enableOfflineMode,
  }) = _$CachePolicyImpl;

  factory _CachePolicy.fromJson(Map<String, dynamic> json) =
      _$CachePolicyImpl.fromJson;

  @override
  Duration get arrivalCacheExpiry;
  @override
  Duration get stationCacheExpiry;
  @override
  Duration get routeCacheExpiry;
  @override
  Duration get refreshInterval;
  @override
  bool get enableOfflineMode;

  /// Create a copy of CachePolicy
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CachePolicyImplCopyWith<_$CachePolicyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CacheStatus _$CacheStatusFromJson(Map<String, dynamic> json) {
  return _CacheStatus.fromJson(json);
}

/// @nodoc
mixin _$CacheStatus {
  bool get isOnline => throw _privateConstructorUsedError;
  DateTime get lastUpdate => throw _privateConstructorUsedError;
  int get totalCachedItems => throw _privateConstructorUsedError;
  int get expiredItems => throw _privateConstructorUsedError;
  bool get hasOfflineData => throw _privateConstructorUsedError;

  /// Serializes this CacheStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CacheStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CacheStatusCopyWith<CacheStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CacheStatusCopyWith<$Res> {
  factory $CacheStatusCopyWith(
    CacheStatus value,
    $Res Function(CacheStatus) then,
  ) = _$CacheStatusCopyWithImpl<$Res, CacheStatus>;
  @useResult
  $Res call({
    bool isOnline,
    DateTime lastUpdate,
    int totalCachedItems,
    int expiredItems,
    bool hasOfflineData,
  });
}

/// @nodoc
class _$CacheStatusCopyWithImpl<$Res, $Val extends CacheStatus>
    implements $CacheStatusCopyWith<$Res> {
  _$CacheStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CacheStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isOnline = null,
    Object? lastUpdate = null,
    Object? totalCachedItems = null,
    Object? expiredItems = null,
    Object? hasOfflineData = null,
  }) {
    return _then(
      _value.copyWith(
            isOnline: null == isOnline
                ? _value.isOnline
                : isOnline // ignore: cast_nullable_to_non_nullable
                      as bool,
            lastUpdate: null == lastUpdate
                ? _value.lastUpdate
                : lastUpdate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            totalCachedItems: null == totalCachedItems
                ? _value.totalCachedItems
                : totalCachedItems // ignore: cast_nullable_to_non_nullable
                      as int,
            expiredItems: null == expiredItems
                ? _value.expiredItems
                : expiredItems // ignore: cast_nullable_to_non_nullable
                      as int,
            hasOfflineData: null == hasOfflineData
                ? _value.hasOfflineData
                : hasOfflineData // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CacheStatusImplCopyWith<$Res>
    implements $CacheStatusCopyWith<$Res> {
  factory _$$CacheStatusImplCopyWith(
    _$CacheStatusImpl value,
    $Res Function(_$CacheStatusImpl) then,
  ) = __$$CacheStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isOnline,
    DateTime lastUpdate,
    int totalCachedItems,
    int expiredItems,
    bool hasOfflineData,
  });
}

/// @nodoc
class __$$CacheStatusImplCopyWithImpl<$Res>
    extends _$CacheStatusCopyWithImpl<$Res, _$CacheStatusImpl>
    implements _$$CacheStatusImplCopyWith<$Res> {
  __$$CacheStatusImplCopyWithImpl(
    _$CacheStatusImpl _value,
    $Res Function(_$CacheStatusImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CacheStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isOnline = null,
    Object? lastUpdate = null,
    Object? totalCachedItems = null,
    Object? expiredItems = null,
    Object? hasOfflineData = null,
  }) {
    return _then(
      _$CacheStatusImpl(
        isOnline: null == isOnline
            ? _value.isOnline
            : isOnline // ignore: cast_nullable_to_non_nullable
                  as bool,
        lastUpdate: null == lastUpdate
            ? _value.lastUpdate
            : lastUpdate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        totalCachedItems: null == totalCachedItems
            ? _value.totalCachedItems
            : totalCachedItems // ignore: cast_nullable_to_non_nullable
                  as int,
        expiredItems: null == expiredItems
            ? _value.expiredItems
            : expiredItems // ignore: cast_nullable_to_non_nullable
                  as int,
        hasOfflineData: null == hasOfflineData
            ? _value.hasOfflineData
            : hasOfflineData // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CacheStatusImpl implements _CacheStatus {
  const _$CacheStatusImpl({
    required this.isOnline,
    required this.lastUpdate,
    required this.totalCachedItems,
    required this.expiredItems,
    required this.hasOfflineData,
  });

  factory _$CacheStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$CacheStatusImplFromJson(json);

  @override
  final bool isOnline;
  @override
  final DateTime lastUpdate;
  @override
  final int totalCachedItems;
  @override
  final int expiredItems;
  @override
  final bool hasOfflineData;

  @override
  String toString() {
    return 'CacheStatus(isOnline: $isOnline, lastUpdate: $lastUpdate, totalCachedItems: $totalCachedItems, expiredItems: $expiredItems, hasOfflineData: $hasOfflineData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CacheStatusImpl &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.lastUpdate, lastUpdate) ||
                other.lastUpdate == lastUpdate) &&
            (identical(other.totalCachedItems, totalCachedItems) ||
                other.totalCachedItems == totalCachedItems) &&
            (identical(other.expiredItems, expiredItems) ||
                other.expiredItems == expiredItems) &&
            (identical(other.hasOfflineData, hasOfflineData) ||
                other.hasOfflineData == hasOfflineData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    isOnline,
    lastUpdate,
    totalCachedItems,
    expiredItems,
    hasOfflineData,
  );

  /// Create a copy of CacheStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CacheStatusImplCopyWith<_$CacheStatusImpl> get copyWith =>
      __$$CacheStatusImplCopyWithImpl<_$CacheStatusImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CacheStatusImplToJson(this);
  }
}

abstract class _CacheStatus implements CacheStatus {
  const factory _CacheStatus({
    required final bool isOnline,
    required final DateTime lastUpdate,
    required final int totalCachedItems,
    required final int expiredItems,
    required final bool hasOfflineData,
  }) = _$CacheStatusImpl;

  factory _CacheStatus.fromJson(Map<String, dynamic> json) =
      _$CacheStatusImpl.fromJson;

  @override
  bool get isOnline;
  @override
  DateTime get lastUpdate;
  @override
  int get totalCachedItems;
  @override
  int get expiredItems;
  @override
  bool get hasOfflineData;

  /// Create a copy of CacheStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CacheStatusImplCopyWith<_$CacheStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
