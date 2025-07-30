import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'views/login_screen.dart';
import 'cubits/news_cubit.dart';
import '../repositories/news_repositories.dart';
import '../services/news_service.dart';
import '../services/local_cache_service.dart';

void main() async {
 

 
  final apiService = NewsAPIService();
  final prefs = await SharedPreferences.getInstance();

final cacheService = LocalCacheService();
  final dio = Dio();

  final newsRepository = NewsRepository(
    apiService: apiService,
    prefs: prefs,
    cacheService: cacheService,
    dio: dio,
  );

  runApp(
    BlocProvider<NewsCubit>(
      create: (context) => NewsCubit(newsRepository),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth Form App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: LoginScreen(),
    );
  }
}
