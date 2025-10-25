import 'package:dio/dio.dart';

class DioClient {
  final Dio dio;

  DioClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: 'https://newsapi.org',
            connectTimeout: Duration(milliseconds: 5000),
            receiveTimeout: Duration(milliseconds: 5000),
          ),
        );

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioError catch (e) {
      throw Exception('Network Error: ${e.message}');
    }
  }
}
