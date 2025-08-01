import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import 'package:news_app/main.dart';
import 'package:news_app/repositories/news_repositories.dart';
import 'package:news_app/services/news_service.dart';
import 'package:news_app/services/local_cache_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late NewsRepository newsRepository;

  setUpAll(() async {
    prefs = await SharedPreferences.getInstance();
    final apiService = NewsAPIService(prefs: prefs);

    newsRepository = NewsRepository(
      apiService: apiService,
      prefs: prefs,
      dio: Dio(),
      cacheService: LocalCacheService(),
    );
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(newsRepository: newsRepository));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
