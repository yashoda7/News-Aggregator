import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/article.dart';

part 'article_model.g.dart';

@JsonSerializable()
class ArticleModel {
  final Map<String, dynamic>? source;
  final String? author;
  final String title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;

  ArticleModel({
    this.source,
    this.author,
    required this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) =>
      _$ArticleModelFromJson(json);

  Map<String, dynamic> toJson() => _$ArticleModelToJson(this);
   factory ArticleModel.fromEntity(Article article) => ArticleModel(
        title: article.title,
        description: article.description,
        url: article.url,
        urlToImage: article.urlToImage,
      );

  Article toEntity() => Article(
        author: author,
        title: title,
        description: description,
        url: url,
        urlToImage: urlToImage,
        publishedAt: publishedAt != null ? DateTime.tryParse(publishedAt!) : null,
        content: content,
        sourceName: source?['name'] as String?,
      );
}
