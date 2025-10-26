import '../entities/article.dart';
import '../repositories/news_repository.dart';

class SearchNews {
  final NewsRepository repository;

  SearchNews(this.repository);

  Future<List<Article>> execute(String keyword) async {
    // return await repository.searchNews(keyword);
    final remoteResults = await repository.searchNews(keyword);
  // final articles = remoteResults.map((e) => e.toEntity()).toList();
  
  // Cache results if remote fetch succeeded
  // await localDataSource.cacheSearchResults(keyword, remoteResults);
  return remoteResults;
  }
}
