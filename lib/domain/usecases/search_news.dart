import '../entities/article.dart';
import '../repositories/news_repository.dart';

class SearchNews {
  final NewsRepository repository;

  SearchNews(this.repository);

  Future<List<Article>> execute(String keyword) async {
    return await repository.searchNews(keyword);
  }
}
