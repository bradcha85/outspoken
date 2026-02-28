import 'package:flutter/material.dart';
import '../models/phrase.dart';
import '../models/category.dart';
import '../data/phrases_data.dart';
import '../data/categories_data.dart';

class PhraseProvider extends ChangeNotifier {
  List<Phrase> _phrases = allPhrases;
  List<Category> _categories = defaultCategories;
  Phrase? _currentPhrase;
  String _searchQuery = '';
  String _selectedCategoryId = '';

  List<Phrase> get phrases => _filteredPhrases;
  List<Category> get categories => _categories;
  Phrase? get currentPhrase => _currentPhrase;
  String get searchQuery => _searchQuery;
  String get selectedCategoryId => _selectedCategoryId;

  List<Phrase> get _filteredPhrases {
    var result = _phrases;
    if (_selectedCategoryId.isNotEmpty) {
      result = result.where((p) => p.categoryId == _selectedCategoryId).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((p) =>
        p.english.toLowerCase().contains(q) ||
        p.korean.toLowerCase().contains(q),
      ).toList();
    }
    return result;
  }

  List<Phrase> getPhrasesByCategory(String categoryId) {
    return _phrases.where((p) => p.categoryId == categoryId).toList();
  }

  Phrase? getPhraseById(String id) {
    try {
      return _phrases.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  void setCurrentPhrase(Phrase phrase) {
    _currentPhrase = phrase;
    notifyListeners();
  }

  void filterByCategory(String categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void searchPhrases(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilter() {
    _selectedCategoryId = '';
    _searchQuery = '';
    notifyListeners();
  }

  // 오늘의 표현 (랜덤)
  Phrase get todayPhrase {
    final today = DateTime.now().day;
    return _phrases[today % _phrases.length];
  }
}
