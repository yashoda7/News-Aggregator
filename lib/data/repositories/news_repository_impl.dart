import '../../core/network/network_info.dart';
import '../../data/datasources/news_local_data_source.dart';
import '../../data/datasources/news_remote_data_source.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/news_repository.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;
  final NewsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  NewsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<Article>> getTopHeadlines(String category) async {
    if (await networkInfo.isConnected) {
      try {
        // Get remote articles (List<ArticleModel>)
        final remoteArticles = await remoteDataSource.getTopHeadlines(category);
        
        // Convert ArticleModel to Article
        final articles = remoteArticles.map((model) => model.toEntity()).toList();
        
        // Cache the articles (local data source will handle the conversion)
        await localDataSource.cacheArticles(category, articles);
        
        return articles;
      } catch (e) {
        // If remote fetch fails, try to return cached data
        final cachedArticles = await localDataSource.getCachedArticles(category);
        if (cachedArticles != null && cachedArticles.isNotEmpty) {
          return cachedArticles;
        }
        rethrow;
      }
    } else {
      // Offline: get from cache
      final cachedArticles = await localDataSource.getCachedArticles(category);
      if (cachedArticles == null || cachedArticles.isEmpty) {
        throw Exception('No internet connection and no cached data available');
      }
      return cachedArticles;
    }
  }

  @override
  Future<List<Article>> searchNews(String query) async {
    if (await networkInfo.isConnected) {
      try {
        // Get search results from remote
        final remoteResults = await remoteDataSource.searchNews(query);
        
        // Convert ArticleModel to Article
        final articles = remoteResults.map((model) => model.toEntity()).toList();
        
        // Cache the results
        await localDataSource.cacheSearchResults(query, articles);
        
        return articles;
      } catch (e) {
        // If search fails, try to return cached results
        final cachedResults = await localDataSource.getCachedSearchResults(query);
        if (cachedResults != null && cachedResults.isNotEmpty) {
          return cachedResults;
        }
        rethrow;
      }
    } else {
      // Offline: try to get from cache
      final cachedResults = await localDataSource.getCachedSearchResults(query);
      if (cachedResults == null || cachedResults.isEmpty) {
        throw Exception('No internet connection and no cached search results');
      }
      return cachedResults;
    }
  }
}
