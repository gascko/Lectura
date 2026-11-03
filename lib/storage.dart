import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

// Verbindet die lokal gespeicherte Theme-Auswahl mit dem ListenableBuilder in main.dart.
/// @brief Verwaltet das App-Theme und dessen Speicherung in SharedPreferences.
class ColorThemeNotifier with ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;
  /// @brief Liefert die aktuelle Theme-Auswahl für die Oberfläche.
  /// @return Helles, dunkles oder systemabhängiges Theme.
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
  /// @brief Kodiert die Theme-Auswahl für den lokalen Speicher.
  /// @param mode Zu speichernde Theme-Auswahl.
  /// @return 1 für hell, 2 für dunkel und 0 für die Systemeinstellung.
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
  /// @brief Wandelt den gespeicherten Zahlenwert in eine Theme-Auswahl um.
  /// @param themeValue Aus SharedPreferences gelesener Wert.
  /// @return Hell bei 1, dunkel bei 2, sonst die Systemeinstellung.
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
  /// @brief Lädt die Theme-Auswahl und benachrichtigt die Oberfläche.
  /// @return Future, das nach dem Laden und Benachrichtigen abgeschlossen ist.
  /// @note Ohne gespeicherten Wert wird die Systemeinstellung verwendet.
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
  /// @brief Speichert die Theme-Auswahl und benachrichtigt danach die Oberfläche.
  /// @param mode Neue Theme-Auswahl für die App.
  /// @return Future, das nach dem Speichern und Benachrichtigen abgeschlossen ist.
  Future<void> setMode(ThemeMode mode) async {
    themeMode = mode;
    final storage = await SharedPreferences.getInstance();
    await storage.setInt('themeMode', themeModeToInt(mode));
    notifyListeners();
  }
}
