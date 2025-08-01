import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'views/login_screen.dart';
import 'cubits/news_cubit.dart';
import '../repositories/news_repositories.dart';
import '../services/news_service.dart';
import '../services/local_cache_service.dart';
import '../views/article_detail_screen.dart';
import '../models/article_model.dart';
import '../views/profile_screen.dart';
import '../views/profile_edit.dart';
import '../views/search_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  final prefs = await SharedPreferences.getInstance();
  final apiService = NewsAPIService(prefs: prefs);
  
final cacheService = LocalCacheService();
  final dio = Dio();

  final newsRepository = NewsRepository(
    apiService: apiService,
    prefs: prefs,
    cacheService: cacheService,
    dio: dio,
  );

  runApp(
    MyApp(newsRepository: newsRepository)
  );
}

class MyApp extends StatelessWidget {
  final NewsRepository newsRepository;
  const MyApp({Key? key, required this.newsRepository}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NewsCubit(newsRepository),
      child: MaterialApp(
        title: 'Auth Form App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
        ),
        home: LoginScreen(),
        routes: {
    '/details': (context) {
      final article = ModalRoute.of(context)!.settings.arguments as Article;
      return ArticleDetailScreen(article: article);
    },
    '/profile': (context) => ProfileScreen(),
  '/edit_profile': (context) => EditableProfileScreen(),
  '/search':(context)=> ArticleSearchScreen(),
  

  },
      ),
    );
  }
}
