import 'package:equatable/equatable.dart';
import '../../../domain/entities/article.dart';

abstract class NewsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}





class NewsOffline extends NewsState {
  final String message;
  NewsOffline(this.message);
}
class NewsLoaded extends NewsState {
  final List<Article> articles;
  final String category;
  final bool offline;

  NewsLoaded({
    required this.articles,
    required this.category,
    this.offline = false,
  });

  @override
  List<Object?> get props => [articles, category, offline];
}

class NewsError extends NewsState {
  final String message;
  final String category;

  NewsError(this.message, {required this.category});

  @override
  List<Object?> get props => [message, category];
}