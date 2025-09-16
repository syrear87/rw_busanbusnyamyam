import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'place_model.dart';
import 'route_repository.dart';
import 'busan_bis_route_repository.dart';
import 'route_model.dart';

// Repository provider
final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  return BusanBisRouteRepository();
});

// Route search provider
final routeSearchProvider = FutureProvider.family<List<BusRoute>, String>((ref, query) async {
  final repository = ref.read(routeRepositoryProvider);
  final result = await repository.searchRoutes(query);

  switch (result) {
    case Success(data: final routes):
      return routes;
    case Failure(message: final message):
      throw Exception(message);
  }
});

// Route stops provider
final routeStopsProvider = FutureProvider.family<List<RouteStop>, String>((ref, routeId) async {
  final repository = ref.read(routeRepositoryProvider);
  final result = await repository.getRouteStops(routeId);

  switch (result) {
    case Success(data: final stops):
      return stops;
    case Failure(message: final message):
      throw Exception(message);
  }
});

// Nearby stops provider
final nearbyStopsProvider = FutureProvider.family<List<BusStop>, (double, double, int)>((ref, params) async {
  final (lat, lon, radius) = params;
  final repository = ref.read(routeRepositoryProvider);
  final result = await repository.getNearbyStops(
    lat: lat,
    lon: lon,
    radiusMeters: radius,
  );

  switch (result) {
    case Success(data: final stops):
      return stops;
    case Failure(message: final message):
      throw Exception(message);
  }
});

// Stop by ARS provider
final stopByArsProvider = FutureProvider.family<BusStop?, String>((ref, arsNumber) async {
  final repository = ref.read(routeRepositoryProvider);
  final result = await repository.getStopByArsNumber(arsNumber);

  switch (result) {
    case Success(data: final stop):
      return stop;
    case Failure(message: final message):
      throw Exception(message);
  }
});

// Stop search provider
final stopSearchProvider = FutureProvider.family<List<BusStop>, String>((ref, query) async {
  final repository = ref.read(routeRepositoryProvider);
  final result = await repository.searchStops(query);

  switch (result) {
    case Success(data: final stops):
      return stops;
    case Failure(message: final message):
      throw Exception(message);
  }
});