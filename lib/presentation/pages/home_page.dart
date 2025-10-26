import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/news/news_bloc.dart';
import '../blocs/news/news_event.dart';
import '../blocs/news/news_state.dart';
import '../widgets/article_card.dart';
import 'search_page.dart';
import 'package:newsaggregator/domain/entities/article.dart';
class HomePage extends StatefulWidget {
   HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
   final categories=["business","sports","health","technology"];
}
class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, List<Article>> _cachedArticles = {};
  final Map<String, bool> _isLoading = {};
  int _currentTabIndex = 0;
 

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.categories.length,
      vsync: this,
    )..addListener(_handleTabChange);

    // Initialize state for each category
    for (var category in widget.categories) {
      _cachedArticles[category] = [];
      _isLoading[category] = false;
    }

    // Load initial data
    _loadNewsForCategory(widget.categories[0]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
      final currentCategory = widget.categories[_currentTabIndex];
      if (_cachedArticles[currentCategory]?.isEmpty ?? true) {
        _loadNewsForCategory(currentCategory);
      }
    }
  }

  void _loadNewsForCategory(String category, {bool forceRefresh = false}) {
  if (_isLoading[category] == true) return;

  setState(() {
    _isLoading[category] = true;
    if (forceRefresh) {
      _cachedArticles[category] = []; // Clear old articles on refresh
    }
  });

  context.read<NewsBloc>().add(FetchNewsEvent(category, forceRefresh: forceRefresh));
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: const Text('News Aggregator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) =>  SearchPage()),
              );
              // Refresh current tab after returning from search
              _loadNewsForCategory(widget.categories[_currentTabIndex]);
            },
          ),
        ],
        bottom: TabBar(
          labelColor:const Color.fromARGB(255, 34, 30, 28),
          controller: _tabController,
          isScrollable: true,
          tabs: widget.categories.map((category) => 
              Tab(text: category.toUpperCase(),)
          ).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: widget.categories.map((category) {
          return BlocConsumer<NewsBloc, NewsState>(
            listener: (context, state) {
              if (state is NewsLoaded && state.category == category) {
                setState(() {
                  _cachedArticles[category] = state.articles;
                  _isLoading[category] = false;
                });
              } else if (state is NewsError && state.category == category) {
                setState(() {
                  _isLoading[category] = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              final articles = _cachedArticles[category] ?? [];
              final isLoading = _isLoading[category] ?? false;

              if (isLoading && articles.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (articles.isEmpty) {
                return const Center(child: Text('No articles found.'));
              }

              return RefreshIndicator(
                onRefresh: () async {
                  // _loadNewsForCategory(category);
                     _loadNewsForCategory(category, forceRefresh: true);
                },
                child: ListView.builder(
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    return ArticleCard(article: articles[index]);
                  },
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}