import '../entities/article.dart';

abstract class NewsRepository {
  Future<List<Article>> getTopHeadlines(String category,{bool forceRefresh = false});
  Future<List<Article>> searchNews(String keyword);
}
