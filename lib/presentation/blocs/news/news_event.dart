import 'package:equatable/equatable.dart';

abstract class NewsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}


class SearchNewsEvent extends NewsEvent {
  final String keyword;
  final bool isOffline;

  SearchNewsEvent(this.keyword, {this.isOffline = false});

  @override
  List<Object?> get props => [keyword, isOffline];
}

class LoadCachedSearchEvent extends NewsEvent {
  final List<dynamic> cachedArticles;

  LoadCachedSearchEvent(this.cachedArticles);

  @override
  List<Object?> get props => [cachedArticles];
}

class RefreshNewsEvent extends NewsEvent {
  final String category;

  RefreshNewsEvent(this.category);

  @override
  List<Object?> get props => [category];
}
class FetchNewsEvent extends NewsEvent {
  final String category;
  final bool forceRefresh;

  FetchNewsEvent(this.category, {this.forceRefresh = false});

  @override
  List<Object?> get props => [category, forceRefresh];
}
