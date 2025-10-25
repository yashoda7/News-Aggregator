import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_local_data_source.dart';
import '../datasources/news_remote_data_source.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;
  final NewsLocalDataSource localDataSource;
  final Connectivity connectivity;

  NewsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
  });

  @override
  Future<List<Article>> getTopHeadlines(String category) async {
    final connection = await connectivity.checkConnectivity();

    if (connection != ConnectivityResult.none) {
      // fetch from API
      final remoteArticles = await remoteDataSource.getTopHeadlines(category);
      // cache locally
      await localDataSource.cacheArticles(category, remoteArticles);
      // convert to entity
      return remoteArticles.map((e) => e.toEntity()).toList();
    } else {
      // fetch from cache
      final cached = localDataSource.getCachedArticles(category);
      if (cached != null && cached.isNotEmpty) {
        return cached.map((e) => e.toEntity()).toList();
      } else {
        throw Exception('No Internet and No Cached Data');
      }
    }
  }

  @override
  Future<List<Article>> searchNews(String keyword) async {
    final connection = await connectivity.checkConnectivity();
    if (connection != ConnectivityResult.none) {
      final articles = await remoteDataSource.searchNews(keyword);
      return articles.map((e) => e.toEntity()).toList();
    } else {
      throw Exception('No Internet Connection');
    }
  }
}
