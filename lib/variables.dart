import 'storage.dart';
import 'api.dart';

// Gemeinsame Serveradresse und maximale Wartezeit der GET-Anfragen in Sekunden.
const String baseUrl = 'https://r7gfduecni.execute-api.us-east-1.amazonaws.com/dev';
const timeoutDuration = 10;
// Alle Seiten teilen diese Instanzen, damit Theme-Wechsel und Fehler weitergegeben werden.
final themeNotifier = ColorThemeNotifier();
final errorNotifier = ErrorNotifier();
