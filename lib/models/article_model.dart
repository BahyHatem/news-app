class Article {
  final String id;
  final String title;
  final String description;
  final String content;
  final String? imageUrl;
  final DateTime publishedAt;
  final String source;
  final String? author;
  final String url;
  final String category;
  bool isBookmarked;

  Article({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    this.imageUrl,
    required this.publishedAt,
    required this.source,
    this.author,
    required this.url,
    required this.category,
    this.isBookmarked = false,
  });

  
  factory Article.fromJson(Map<String, dynamic> json) {
    try {
      return Article(
        id: _parseId(json),
        title: json['title']?.toString() ?? 'No title available',
        description: json['description']?.toString() ?? '',
        content: json['content']?.toString() ?? '',
        imageUrl: json['urlToImage']?.toString() ?? json['imageUrl']?.toString(),
        publishedAt: _parseDateTime(json['publishedAt']),
        source: _parseSource(json['source']),
        author: json['author']?.toString(),
        url: json['url']?.toString() ?? '',
        category: json['category']?.toString() ?? 'general',
        isBookmarked: json['isBookmarked'] as bool? ?? false,
      );
    } catch (e) {
      throw FormatException('Failed to parse Article: $e');
    }
  }

  
  static String _parseId(Map<String, dynamic> json) {
    return json['id']?.toString() ??
        json['url']?.toString() ??
        DateTime.now().millisecondsSinceEpoch.toString();
  }

  
  static DateTime _parseDateTime(dynamic dateString) {
    if (dateString == null) return DateTime.now();
    try {
      return DateTime.parse(dateString.toString());
    } catch (e) {
      return DateTime.now();
    }
  }

 
  static String _parseSource(dynamic source) {
    if (source == null) return 'Unknown';
    if (source is String) return source;
    if (source is Map) return source['name']?.toString() ?? 'Unknown';
    return 'Unknown';
  }

  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'imageUrl': imageUrl,
      'publishedAt': publishedAt.toIso8601String(),
      'source': source,
      'author': author,
      'url': url,
      'category': category,
      'isBookmarked': isBookmarked,
    };
  }

  
  Article copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? imageUrl,
    DateTime? publishedAt,
    String? source,
    String? author,
    String? url,
    String? category,
    bool? isBookmarked,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      publishedAt: publishedAt ?? this.publishedAt,
      source: source ?? this.source,
      author: author ?? this.author,
      url: url ?? this.url,
      category: category ?? this.category,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  
  @override
  String toString() {
    return '''
Article {
  id: $id,
  title: $title,
  description: ${description.length > 50 ? '${description.substring(0, 50)}...' : description},
  content: ${content.length > 50 ? '${content.substring(0, 50)}...' : content},
  imageUrl: ${imageUrl ?? 'N/A'},
  publishedAt: ${publishedAt.toIso8601String()},
  source: $source,
  author: ${author ?? 'Unknown'},
  url: $url,
  category: $category,
  isBookmarked: $isBookmarked
}''';
  }

  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Article &&
        other.id == id &&
        other.url == url;
  }

  @override
  int get hashCode => id.hashCode ^ url.hashCode;
}