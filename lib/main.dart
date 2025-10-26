import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:newsaggregator/presentation/theme/apptheme.dart';

import 'core/network/network_info.dart';
import 'core/network/dio_client.dart';
import 'data/datasources/news_local_data_source.dart';
import 'data/datasources/news_remote_data_source.dart';
import 'data/repositories/news_repository_impl.dart';
import 'domain/usecases/get_top_headlines.dart';
import 'domain/usecases/search_news.dart';
import 'presentation/blocs/news/news_bloc.dart';
import 'presentation/pages/home_page.dart';
import 'package:bloc/bloc.dart';
import 'package:provider/provider.dart';
import "package:newsaggregator/presentation/provider/themeprovider.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Hive
  await Hive.initFlutter();
  final newsBox = await Hive.openBox('newsCache');

  final apiKey = dotenv.env['NEWS_API_KEY'] ?? '';

  // Core
  final dioClient = DioClient();
  final connectivity = Connectivity();
  final networkInfo = NetworkInfo(connectivity);

  // Data Sources
  final remoteDataSource =
      NewsRemoteDataSourceImpl(dioClient: dioClient, apiKey: apiKey);
  final localDataSource = NewsLocalDataSourceImpl(newsBox);

  // Repository
  final repository = NewsRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    networkInfo: networkInfo,
  );

  // Use Cases
  final getTopHeadlines = GetTopHeadlines(repository);
  final searchNews = SearchNews(repository);
 

  runApp(
      MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        
      ],
      child: 
    MyApp(
    getTopHeadlines: getTopHeadlines,
    searchNews: searchNews,
    repository: repository,
  )
  ));
}

class MyApp extends StatelessWidget {
  final GetTopHeadlines getTopHeadlines;
  final SearchNews searchNews;
  final NewsRepositoryImpl repository;

  const MyApp({
    required this.getTopHeadlines,
    required this.searchNews,
    required this.repository,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NewsBloc(
        getTopHeadlines: getTopHeadlines,
        searchNews: searchNews,
        repository: repository,
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'News Aggregator',
         theme:AppTheme().lightTheme,
      darkTheme: AppTheme().darkTheme,
      themeMode: Provider.of<ThemeProvider>(context).isDarkMode
    ? ThemeMode.dark
    : ThemeMode.light,

        home: HomePage(),
      ),
    );
  }
}
