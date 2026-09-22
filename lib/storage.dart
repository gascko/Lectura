import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class QuestionNotifier with ChangeNotifier {
  List<String> questions = List.empty();
  List <String> get question => questions;

  Future<List<String>> loadQuestions(String topic) async {
    final storage = await SharedPreferences.getInstance();
    List<String> storageTopics = storage.getStringList(topic) ?? List.empty();
    questions = storageTopics;
    notifyListeners();
    return questions;
  }
}

void initStorage() async {
  final storage = await SharedPreferences.getInstance();
  final isFirstStart = storage.getBool('isFirstStart') ?? true;

  if (isFirstStart) {
    String jsonString = await rootBundle.loadString('assets/Init.json');
    final Map<String, dynamic> data = jsonDecode(jsonString);

    await storage.setStringList('topics', data.keys.toList());

    for (var entry in data.entries) {
      List<String> questions = List<String>.from(entry.value);
      storage.setStringList(entry.key, questions);
    }

    //await storage.setBool("isFirstStart", false);
  }
}

class TopicsNotifier with ChangeNotifier {
  List<String> topics = List.empty();
  List<String> get topic => topics;

  Future<List<String>> loadTopics() async {
    final storage = await SharedPreferences.getInstance();
    List<String> storageTopics = storage.getStringList('topics') ?? List.empty();
    topics = storageTopics;
    notifyListeners();
    return topics;
  }
}

class ColorThemeNotifier with ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;
  ThemeMode get mode => themeMode;

  /// Converts [themeMode mode] into [int themeValue]
  ///
  /// Value [1] = [light]
  ///
  /// Value [2] = [dark]
  ///
  /// Value [0] = [system]
  ///
  /// Returns [int themeValue]
  int themeModeToInt(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 1;
      case ThemeMode.dark:
        return 2;
      case ThemeMode.system:
        return 0;
    }
  }

  /// Converts [int themeValue] into [themeMode mode]
  ///
  /// Value [1] = [light]
  ///
  /// Value [2] = [dark]
  ///
  /// Value [0] = [system]
  ///
  /// Returns [themeMode mode]
  ThemeMode intToThemeMode(int themeValue) {
    switch (themeValue) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Loads themeMode from shared preferences
  ///
  /// Uses [notifyLister themeNotifier]
  ///
  /// Returns [void]
  Future<void> loadMode() async {
    final storage = await SharedPreferences.getInstance();
    int storageMode = storage.getInt('themeMode') ?? 0;
    themeMode = intToThemeMode(storageMode);
    notifyListeners();
  }

  /// Sets themeMode in shared preferences
  ///
  /// Uses [notifyLister themeNotifier]
  ///
  /// Returns [void]
  Future<void> setMode(ThemeMode mode) async {
    themeMode = mode;
    final storage = await SharedPreferences.getInstance();
    await storage.setInt('themeMode', themeModeToInt(mode));
    notifyListeners();
  }
}