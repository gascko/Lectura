import 'package:flutter/material.dart';
import 'variables.dart';
import 'package:flutter/services.dart';
import 'pages/settingsPage.dart';

class AppTheme {
  /// Definition of primary color (Ascend colors will get auto generated)
  static const Color seed = Color(0xFF2DB0EA);

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.light,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await themeNotifier.loadMode();
  runApp(const Lectura());
}

class Lectura extends StatelessWidget {
  const Lectura({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    ]);
    return AnimatedBuilder(
        animation: themeNotifier,
        builder: (context, _) {
          return MaterialApp(
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: themeNotifier.mode,
              home: lecturaAppState(context));
        });
  }
}

Widget lecturaAppState(BuildContext context) {
  final List<Map<String, dynamic>> items = const [
    {
      'title': 'Einstellungen',
      'page': settingsPage(),
    },
  ];
  return Scaffold(
    appBar: AppBar(title: const Text('Lectura')),
    body: ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Card(
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text(items[index]['title']),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => items[index]['page'],
                    ),
                  );
                },
              ),
        );
      }
    )
  );
}