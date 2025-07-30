import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

@immutable
class Category {
  final String id;
  final String name;
  final String displayName;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final int? articleCount;

   Category({
    required this.id,
    required this.name,
    required this.displayName,
    required this.icon,
    required this.color,
    this.isSelected = false,
    this.articleCount,
  });

  
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['displayName'] as String? ?? json['name'] as String,
      icon: IconData(
        json['iconCodePoint'] as int,
        fontFamily: json['iconFontFamily'] as String? ?? 'MaterialIcons',
      ),
      color: Color(json['color'] as int),
      isSelected: json['isSelected'] as bool? ?? false,
      articleCount: json['articleCount'] as int?,
    );
  }

  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'color': color.value,
      'isSelected': isSelected,
      'articleCount': articleCount,
    };
  }

  
  Category copyWith({
    String? id,
    String? name,
    String? displayName,
    IconData? icon,
    Color? color,
    bool? isSelected,
    int? articleCount,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isSelected: isSelected ?? this.isSelected,
      articleCount: articleCount ?? this.articleCount,
    );
  }

  
  static List<Category> defaultCategories() {
    return [
      Category(
        id: 'general',
        name: 'general',
        displayName: 'General',
        icon: Icons.public,
        color: Colors.blue,
      ),
      Category(
        id: 'business',
        name: 'business',
        displayName: 'Business',
        icon: Icons.business,
        color: Colors.green,
      ),
      Category(
        id: 'technology',
        name: 'technology',
        displayName: 'Technology',
        icon: Icons.code,
        color: Colors.purple,
      ),
      Category(
        id: 'health',
        name: 'health',
        displayName: 'Health',
        icon: Icons.health_and_safety,
        color: Colors.red,
      ),
      Category(
        id: 'science',
        name: 'science',
        displayName: 'Science',
        icon: Icons.science,
        color: Colors.orange,
      ),
      Category(
        id: 'sports',
        name: 'sports',
        displayName: 'Sports',
        icon: Icons.sports_soccer,
        color: Colors.amber,
      ),
      Category(
        id: 'entertainment',
        name: 'entertainment',
        displayName: 'Entertainment',
        icon: Icons.movie,
        color: Colors.pink,
      ),
    ];
  }

  static List<Category> toggleCategorySelection(
    List<Category> categories,
    String categoryId,
  ) {
    return categories.map((category) {
      if (category.id == categoryId) {
        return category.copyWith(isSelected: !category.isSelected);
      }
      return category;
    }).toList();
  }

  
  static List<Category> selectedCategories(List<Category> categories) {
    return categories.where((category) => category.isSelected).toList();
  }

  
  @override
  String toString() {
    return 'Category(id: $id, name: $name, isSelected: $isSelected, articleCount: $articleCount)';
  }

  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}