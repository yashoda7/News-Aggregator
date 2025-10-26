import 'package:flutter/material.dart';
import '../../domain/entities/article.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
class ArticleCard extends StatelessWidget {
  final Article article;

  // ArticleCard({required this.article});
  
  const ArticleCard({required this.article, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        cursor: SystemMouseCursors.click,
      child: Card(
        margin: EdgeInsets.all(8),
        child: ListTile(
          leading: article.urlToImage != null
              // ? CachedNetworkImage(article.urlToImage!, width: 100, fit: BoxFit.cover)
              ?CachedNetworkImage(
  imageUrl: article.urlToImage ?? '',
  width: 100,
  fit: BoxFit.cover,
  placeholder: (context, url) => Center(child: CircularProgressIndicator(strokeWidth: 2)),
  errorWidget: (context, url, error) => Icon(Icons.broken_image),
)
              : null,
          title: Text(article.title),
          subtitle: Text(article.sourceName ?? ''),
          onTap: () async {
            if (article.url != null && await canLaunch(article.url!)) {
              await launch(article.url!);
            }
          },
        ),
      ),
    );
  }
}
