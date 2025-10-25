import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/article_model.dart';

abstract class NewsRemoteDataSource {
  Future<List<ArticleModel>> getTopHeadlines(String category);
  Future<List<ArticleModel>> searchNews(String keyword);
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final DioClient dioClient;
  final String apiKey;

  NewsRemoteDataSourceImpl({
    required this.dioClient,
    required this.apiKey,
  });

  @override
  Future<List<ArticleModel>> getTopHeadlines(String category) async {
    final response = await dioClient.get(
      '/v2/top-headlines',
      queryParameters: {
        'country': 'in',
        'category': category,
        'apiKey': apiKey,
      },
    );

    if (response.statusCode == 200) {
      final articles = (response.data['articles'] as List)
          .map((json) => ArticleModel.fromJson(json))
          .toList();
      return articles;
    } else {
      throw Exception('Failed to fetch news');
    }
  }

  @override
  Future<List<ArticleModel>> searchNews(String keyword) async {
    final response = await dioClient.get(
      '/v2/everything',
      queryParameters: {
        'q': keyword,
        'apiKey': apiKey,
      },
    );

    final articles = (response.data['articles'] as List)
        .map((json) => ArticleModel.fromJson(json))
        .toList();
    return articles;
  }
}
