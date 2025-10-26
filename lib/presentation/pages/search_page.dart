import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsaggregator/presentation/theme/apptheme.dart';
import '../blocs/news/news_bloc.dart';
import '../blocs/news/news_event.dart';
import '../blocs/news/news_state.dart';
import '../widgets/article_card.dart';
import 'dart:async';
import 'package:newsaggregator/domain/entities/article.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import "package:newsaggregator/presentation/provider/themeprovider.dart";
class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}
class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = connectivityResult != ConnectivityResult.none;
    });
  }

 void _onSearchChanged(String query) {
  if (_debounce?.isActive ?? false) _debounce!.cancel();

  _debounce = Timer(const Duration(milliseconds: 500), () {
    if (query.isEmpty) {
      context.read<NewsBloc>().add(SearchNewsEvent(''));
    } else if (query.length >= 3) {
      if (!_isOnline) {
        _showOfflineDialog();
        return;
      }
      context.read<NewsBloc>().add(SearchNewsEvent(query));
    }
  });
}
void _showOfflineDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Offline Mode'),
      content: const Text('You are currently offline. Please connect to the internet to search for news.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
@override
Widget build(BuildContext context) {
  bool lightmode=Provider.of<ThemeProvider>(context).isDarkMode ? false :true;
  return Scaffold(
    appBar: AppBar(
      title: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Search News...',
          border: InputBorder.none,
          hintStyle:  TextStyle(color: lightmode ? AppTheme().lightTheme.primaryColorLight : AppTheme().darkTheme.primaryColorDark),
          prefixIcon: Icon(Icons.search, color:  lightmode ? AppTheme().lightTheme.primaryColorLight : AppTheme().darkTheme.primaryColorDark),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon:  Icon(Icons.clear, color:lightmode ? AppTheme().lightTheme.primaryColorLight : AppTheme().darkTheme.primaryColorDark),
                  onPressed: () {
                    _controller.clear();
                    context.read<NewsBloc>().add(SearchNewsEvent(''));
                  },
                )
              : null,
        ),
        style:  TextStyle(color:  lightmode ? AppTheme().lightTheme.primaryColorLight : AppTheme().darkTheme.primaryColorDark),
        onChanged: _onSearchChanged,
      ),
    ),
    body: BlocConsumer<NewsBloc, NewsState>(
      listener: (context, state) {
        if (state is NewsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("your are Offline")),
          );
        } else if (state is NewsOffline) {
          // Show snackbar for offline state
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Your are offline..."),
              backgroundColor: lightmode ? AppTheme().lightTheme.scaffoldBackgroundColor : AppTheme().darkTheme.scaffoldBackgroundColor
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is NewsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is NewsLoaded) {
          return _buildSearchResults(state.articles);
        } else if (state is NewsError) {
          // return Center(child: Text(state.message));
          return const Center(child: Text("Your are Offline "));
        }
        return _buildInitialState();
      },
    ),
  );
}

  Widget _buildInitialState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Search for news articles',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<Article> articles) {
    if (articles.isEmpty) {
      return const Center(child: Text('No results found.'));
    }
    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) => ArticleCard(article: articles[index]),
    );
  }

  Widget _buildOfflineBanner(List<Article> articles) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.orange[100],
          child: Row(
            children: [
              const Icon(Icons.signal_wifi_off, color: Colors.orange),
              const SizedBox(width: 8),
              const Text('Showing cached results'),
              const Spacer(),
              TextButton(
                onPressed: _checkConnectivity,
                child: const Text('RETRY'),
              ),
            ],
          ),
        ),
        Expanded(child: _buildSearchResults(articles)),
      ],
    );
  }

  Widget _buildOfflineMessage(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.signal_wifi_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _checkConnectivity,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}