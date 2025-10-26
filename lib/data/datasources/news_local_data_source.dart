import 'package:hive/hive.dart';
import '../../domain/entities/article.dart';
import '../models/article_model.dart';

abstract class NewsLocalDataSource {
  Future<void> cacheArticles(String category, List<Article> articles);
  Future<List<Article>?> getCachedArticles(String category);
  Future<void> cacheSearchResults(String query, List<Article> articles);
  Future<List<Article>?> getCachedSearchResults(String query);
}

class NewsLocalDataSourceImpl implements NewsLocalDataSource {
  final Box box;

  NewsLocalDataSourceImpl(this.box);

  @override
  Future<void> cacheArticles(String category, List<Article> articles) async {
    // Convert Article to ArticleModel for storage
    final models = articles.map((article) => ArticleModel.fromEntity(article)).toList();
    await box.put('category_$category', models.map((e) => e.toJson()).toList());
  }

  @override
  Future<List<Article>?> getCachedArticles(String category) async {
    final data = box.get('category_$category');
    if (data != null) {
      // Convert stored JSON back to ArticleModel and then to Article
      final models = (data as List)
          .map((json) => ArticleModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      return models.map((model) => model.toEntity()).toList();
    }
    return null;
  }

  @override
  Future<void> cacheSearchResults(String query, List<Article> articles) async {
    final models = articles.map((article) => ArticleModel.fromEntity(article)).toList();
    await box.put('search_$query', models.map((e) => e.toJson()).toList());
  }

  @override
  Future<List<Article>?> getCachedSearchResults(String query) async {
    final data = box.get('search_$query');
    if (data != null) {
      final models = (data as List)
          .map((json) => ArticleModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      return models.map((model) => model.toEntity()).toList();
    }
    return null;
  }
}
