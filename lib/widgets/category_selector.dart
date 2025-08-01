
import 'package:flutter/material.dart';
import '../models/category_model.dart';

class CategorySelector extends StatelessWidget {
  final Category selected;
  final ValueChanged<Category> onCategorySelected;

  const CategorySelector({
    Key? key,
    required this.selected,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = Category.defaultCategories(); 
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.id == selected.id;
          return GestureDetector(
            onTap: () => onCategorySelected(category),
            child: Chip(
              avatar: Icon(category.icon, color: isSelected ? Colors.white : Colors.black),
              label: Text(category.displayName),
              backgroundColor: isSelected ? category.color : Colors.grey[200],
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
      ),
    );
  }
}
