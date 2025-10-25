import '../entities/article.dart';
import '../repositories/news_repository.dart';

class GetTopHeadlines {
  final NewsRepository repository;

  GetTopHeadlines(this.repository);

  Future<List<Article>> execute(String category) async {
    return await repository.getTopHeadlines(category);
  }
}
