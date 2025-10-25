import '../entities/article.dart';

abstract class NewsRepository {
  Future<List<Article>> getTopHeadlines(String category);
  Future<List<Article>> searchNews(String keyword);
}
