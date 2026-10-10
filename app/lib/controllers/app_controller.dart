import 'package:flutter/material.dart';

class AppController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  final Set<String> _favoriteIds = <String>{};

  ThemeMode get themeMode => _themeMode;
  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);

  bool isFavorite(String id) => _favoriteIds.contains(id);

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }

  void toggleFavorite(String id) {
    _favoriteIds.contains(id) ? _favoriteIds.remove(id) : _favoriteIds.add(id);
    notifyListeners();
  }
}
