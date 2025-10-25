import 'package:hive/hive.dart';
import '../models/article_model.dart';

abstract class NewsLocalDataSource {
  Future<void> cacheArticles(String category, List<ArticleModel> articles);
  List<ArticleModel>? getCachedArticles(String category);
}

class NewsLocalDataSourceImpl implements NewsLocalDataSource {
  final Box box;

  NewsLocalDataSourceImpl(this.box);

  @override
  Future<void> cacheArticles(String category, List<ArticleModel> articles) async {
    await box.put(category, articles.map((e) => e.toJson()).toList());
  }

  @override
  List<ArticleModel>? getCachedArticles(String category) {
    final data = box.get(category);
    if (data != null) {
      return (data as List)
          .map((json) => ArticleModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }
    return null;
  }
}
