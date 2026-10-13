import 'storage.dart';
import 'api.dart';

const String baseUrl = 'https://r7gfduecni.execute-api.us-east-1.amazonaws.com/dev';
const timeoutDuration = 10;
final themeNotifier = ColorThemeNotifier();
final errorNotifier = ErrorNotifier();