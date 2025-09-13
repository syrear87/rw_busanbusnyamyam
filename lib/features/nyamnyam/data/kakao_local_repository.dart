import 'dart:convert';
import 'package:dio/dio.dart';
import 'place_model.dart';
import 'place_repository.dart';

class KakaoLocalRepository implements PlaceRepository {
  final String baseUrl; // e.g., https://<worker>.workers.dev/nyam
  final Dio _dio = Dio();
  
  KakaoLocalRepository(this.baseUrl);
  
  @override
  Future<List<Place>> search({
    required double lat, 
    required double lng, 
    required int radiusM, 
    required String category,
  }) async {
    // TODO: implement later with HTTP to Worker:
    // GET baseUrl?category_group_code=FD6|CE7&x=<lng>&y=<lat>&radius=<m>&sort=distance&size=15
    throw UnimplementedError('KakaoLocalRepository not implemented yet');
  }
}

