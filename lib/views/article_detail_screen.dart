import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/article_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          
          SliverAppBar(
            pinned: true,
            expandedHeight: 250.0,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
  tag: 'article-image-${article.id}',
  child: (article.imageUrl != null && article.imageUrl!.isNotEmpty)
      ? CachedNetworkImage(
          imageUrl: article.imageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 250,
          placeholder: (context, url) => Container(
            height: 250,
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            height: 250,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, size: 60),
          ),
        )
      : Container(
          height: 250,
          width: double.infinity,
          color: Colors.grey[300],
          child: const Icon(Icons.image_not_supported, size: 60),
        ),
),

            ),
          ),

          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),

                  const SizedBox(height: 8),

                  
                  Row(
                    children: [
                      Icon(Icons.person, size: 16),
                      const SizedBox(width: 4),
                      Text(article.author!),
                      const SizedBox(width: 16),
                      Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 4),
                      Text(DateFormat('yyyy-MM-dd – kk:mm').format(article.publishedAt)),
                    ],
                  ),

                  const Divider(height: 32),

                  
                  Text(
                    article.content,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 24),

                  
                  Row(
                    children: [
                      const Icon(Icons.public, size: 16),
                      const SizedBox(width: 4),
                      Text("Source: ${article.source}"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ]));}}
