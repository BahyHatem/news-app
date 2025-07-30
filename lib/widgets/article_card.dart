import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../models/article_model.dart';
import '../cubits/news_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NewsCard extends StatelessWidget {
  final Article article;

  const NewsCard({super.key, required this.article});

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(article.publishedAt);
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} hrs ago";
    return DateFormat.yMMMd().format(article.publishedAt);
  }

  String estimateReadingTime(String text) {
    final words = text.split(' ').length;
    final minutes = (words / 200).ceil();
    return "$minutes min read";
  }

  @override
  Widget build(BuildContext context) {
    final isBookmarked = context.watch<NewsCubit>().isBookmarked(article.id);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/details', arguments: article),
      onLongPress: () => _showContextMenu(context),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article Image with Hero
           

Hero(
  tag: 'article-image-${article.id}',
  child: ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: CachedNetworkImage(
      imageUrl: article.imageUrl ?? '',
      fit: BoxFit.cover,
      width: double.infinity,
      height: 180,
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image, size: 50),
      ),
    ),
  ),
),


            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title (max 2 lines)
                  Text(
                    article.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Source and time
                  Row(
                    children: [
                      Text(article.source, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(width: 10),
                      Text("• $timeAgo", style: const TextStyle(color: Colors.grey)),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Short Description
                  Text(
                    article.description ?? '',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),

                  const SizedBox(height: 12),

                  // Bottom actions: Category chip + reading time + bookmark + share
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left side: category + reading time
                      Row(
                        children: [
                          Chip(
                            label: Text(article.category),
                            backgroundColor: Colors.blue.shade50,
                          ),
                          const SizedBox(width: 8),
                          Text(estimateReadingTime(article.content)),
                        ],
                      ),

                      // Right side: bookmark + share
                      Row(
                        children: [
                          IconButton(
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                              child: Icon(
                               (article.isBookmarked ?? false)? Icons.bookmark : Icons.bookmark_border,
                                key: ValueKey(isBookmarked),
                                color: Colors.blue,
                              ),
                            ),
                            onPressed: () {
                              context.read<NewsCubit>().toggleBookmark(article);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.share),
                            onPressed: () => Share.share(article.url),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.open_in_new),
            title: const Text('Open Article'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/details', arguments: article);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark),
            title: const Text('Toggle Bookmark'),
            onTap: () {
              Navigator.pop(context);
              context.read<NewsCubit>().toggleBookmark(article);
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title:  Text('See More in "${article.category}"'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/category', arguments: article.category);
            },
          ),
        ],
      ),
    );
  }
}
