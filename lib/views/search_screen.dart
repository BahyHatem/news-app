import 'package:flutter/material.dart';
import '../models/article_model.dart';



class ArticleSearchScreen extends StatefulWidget {
  const ArticleSearchScreen({super.key});

  @override
  State<ArticleSearchScreen> createState() => _ArticleSearchScreenState();
}

class _ArticleSearchScreenState extends State<ArticleSearchScreen> {
  final List<Article> allArticles = [
    Article(id: '1',
  title: "Flutter 3.22 Released",
  description: "Explore the latest features in Flutter.",
  content: "Full details about the Flutter release...",
  imageUrl: "https://example.com/flutter.jpg",
  publishedAt: DateTime.now(),
  source: "Flutter Dev",
  author: "Google Team",
  url: "https://flutter.dev",
  category: "Technology",
  isBookmarked: false,),
    Article(id: '2',
    title: "Dart Language Tips",
    description: "Learn how to write cleaner and more efficient Dart code.",
    content: "In this article, we explore tips to improve Dart development.",
    imageUrl: "https://example.com/dart.jpg",
    publishedAt: DateTime.now().subtract(Duration(days: 1)),
    source: "Dart Team",
    author: "John Smith",
    url: "https://dart.dev",
    category: "Programming",
    isBookmarked: false,),
    Article(id: '3',
    title: "AI in 2025",
    description: "How artificial intelligence will shape the future.",
    content: "Experts share predictions and trends about AI in the coming years.",
    imageUrl: "https://example.com/ai.jpg",
    publishedAt: DateTime.now().subtract(Duration(days: 3)),
    source: "TechNews",
    author: "Sophia Lee",
    url: "https://technews.com/ai2025",
    category: "AI",
    isBookmarked: false,),
    Article(id: '4',
    title: "Egypt News Today",
    description: "The latest headlines from Egypt and beyond.",
    content: "Breaking news and developments in politics, economy, and more.",
    imageUrl: "https://example.com/egypt.jpg",
    publishedAt: DateTime.now().subtract(Duration(hours: 6)),
    source: "Egypt Times",
    author: "Ahmed Hassan",
    url: "https://egypttimes.com",
    category: "News",
    isBookmarked: false,),
  ];

  List<Article> filteredArticles = [];
  String searchQuery = '';
  String searchCategory = 'title'; 

  @override
  void initState() {
    super.initState();
    filteredArticles = allArticles; 
  }

  void _filterArticles() {
    setState(() {
      filteredArticles = allArticles.where((article) {
        final value = searchCategory == 'title'
            ? article.title.toLowerCase()
            : article.description.toLowerCase();

        return value.contains(searchQuery.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Articles'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            
            TextField(
              decoration: InputDecoration(
                hintText: 'Search articles...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            searchQuery = '';
                            filteredArticles = allArticles;
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                searchQuery = value;
                _filterArticles();
              },
            ),
            const SizedBox(height: 8),

           
            Row(
              children: [
                const Text('Search in:'),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: searchCategory,
                  items: ['title', 'description'].map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category[0].toUpperCase() + category.substring(1)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      searchCategory = value;
                      _filterArticles();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            
            Expanded(
              child: filteredArticles.isEmpty
                  ? const Center(child: Text('No results found.'))
                  : ListView.builder(
                      itemCount: filteredArticles.length,
                      itemBuilder: (context, index) {
                        final article = filteredArticles[index];
                        return ListTile(
                          title: Text(article.title),
                          subtitle: Text(article.description),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
