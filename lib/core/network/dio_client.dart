import 'package:dio/dio.dart';

class DioClient {
  final Dio dio;

  DioClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: 'https://newsapi.org', // Make sure this is HTTPS
            headers: {
              'Accept': 'application/json',
              'User-Agent': 'newsaggregator/1.0',
            },
          ),
        );

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioError catch (e) {
      // Better handling of all DioError types
      if (e.response != null) {
        // Server responded with an error (HTTP status code)
        throw Exception(
            'Network Error: ${e.response?.statusCode} - ${e.response?.statusMessage}');
      } else if (e.type == DioErrorType.connectionTimeout ||
          e.type == DioErrorType.sendTimeout ||
          e.type == DioErrorType.receiveTimeout) {
        throw Exception('Network Error: Request timed out');
      } else if (e.type == DioErrorType.unknown) {
        throw Exception('Network Error: ${e.message ?? 'Unknown error'}');
      } else {
        throw Exception('Network Error: ${e.message}');
      }
    }
  }
}
