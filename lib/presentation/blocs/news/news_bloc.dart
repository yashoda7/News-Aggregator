import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../domain/usecases/get_top_headlines.dart';
import '../../../domain/usecases/search_news.dart';
import '../../../data/repositories/news_repository_impl.dart';
import 'news_event.dart';
import 'news_state.dart';
import 'package:newsaggregator/data/models/article_model.dart';
import '../../../domain/entities/article.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final GetTopHeadlines getTopHeadlines;
  final SearchNews searchNews;
  final NewsRepositoryImpl repository;

  int _currentPage = 1;
  bool _isFetching = false;
  String? _currentCategory;
  List<Article> _allArticles = [];

  bool get isFetching => _isFetching;

  NewsBloc({
    required this.getTopHeadlines,
    required this.searchNews,
    required this.repository,
  }) : super(NewsInitial()) {
    on<FetchNewsEvent>(_onFetchNews);
    on<SearchNewsEvent>(_onSearchNews);
  }

Future<void> _onFetchNews(FetchNewsEvent event, Emitter<NewsState> emit) async {
  if (_isFetching) return;
  _isFetching = true;

  emit(NewsLoading());

  try {
    final isConnected = await repository.networkInfo.isConnected;
    
    if (!isConnected) {
      final cachedModels = await repository.localDataSource.getCachedArticles(event.category);
      if (cachedModels != null && cachedModels.isNotEmpty) {
        emit(NewsLoaded(
          articles: cachedModels,
          category: event.category,
          offline: true,
        ));
      } else {
        emit(NewsError(
          'You are offline and no cached data is available.',
          category: event.category,
        ));
      }
      return;
    }

    final articles = await getTopHeadlines.execute(event.category,forceRefresh:event.forceRefresh);

    if (articles.isEmpty) {
      emit(NewsError('No articles found.', category: event.category));
    } else {
      await repository.localDataSource.cacheArticles(event.category, articles);
      emit(NewsLoaded(articles: articles, category: event.category));
    }
  } catch (e) {
    emit(NewsError('An error occurred: $e', category: event.category));
  } finally {
    _isFetching = false;
  }
}

  Future<void> _onSearchNews(SearchNewsEvent event, Emitter<NewsState> emit) async {
  if (event.keyword.isEmpty) {
    emit(NewsInitial());
    return;
  }

  emit(NewsLoading());

  try {
    final isConnected = await repository.networkInfo.isConnected;
    
    if (!isConnected) {
      final cachedResults = await repository.localDataSource.getCachedSearchResults(event.keyword);
      if (cachedResults != null && cachedResults.isNotEmpty) {
        emit(NewsLoaded(
          articles: cachedResults,
          category: 'search',
          offline: true,
        ));
      } else {
        emit(NewsOffline('No cached results available for "${event.keyword}" while offline.'));
      }
      return;
    }

    final articles = await searchNews.execute(event.keyword);
    
    if (articles.isNotEmpty) {
      await repository.localDataSource.cacheSearchResults(event.keyword, articles);
      emit(NewsLoaded(articles: articles, category: 'search'));
    } else {
      emit(NewsError('No results found for "${event.keyword}"', category: 'search'));
    }
  } catch (e) {
    emit(NewsError('Failed to search: $e', category: 'search'));

  }
}
}