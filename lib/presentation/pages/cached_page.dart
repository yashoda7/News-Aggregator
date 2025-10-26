import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class CachedPage extends StatelessWidget {
  final String category;

  const CachedPage({required this.category, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('newsCache');
    final cached = box.get(category) as List<dynamic>? ?? <dynamic>[];
    final articles = cached.cast<Map>().map((m) => m.cast<String, dynamic>()).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Cached — ${category.toUpperCase()}'),
      ),
      body: articles.isEmpty
          ? Center(child: Text('No cached articles for $category'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: articles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final a = articles[index];
                return ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  tileColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.04),
                  title: Text(a['title'] ?? 'No title'),
                  subtitle: Text(a['source'] ?? ''),
                  onTap: () async {
                    final url = a['url'] as String?;
                    if (url != null && await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot open link')));
                    }
                  },
                );
              },
            ),
    );
  }
}
