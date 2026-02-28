import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String nameEn;
  final IconData icon;
  final Color color;
  final int phraseCount;

  const Category({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.icon,
    required this.color,
    required this.phraseCount,
  });

  Category copyWith({
    String? id,
    String? name,
    String? nameEn,
    IconData? icon,
    Color? color,
    int? phraseCount,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      phraseCount: phraseCount ?? this.phraseCount,
    );
  }
}
