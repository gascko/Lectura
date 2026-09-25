import 'package:flutter/material.dart';
import 'package:lectura/pages/createEvaluationPage.dart';
import 'package:lectura/storage.dart';
import 'variables.dart';
import 'pages/settingsPage.dart';

class AppTheme {
  static const Color seed = Color(0xFF5850DF);

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: seed,
            brightness: Brightness.light,
          ).copyWith(
            primary: seed,
            onPrimary: Colors.white,
            onTertiary: Color(0xFF2E7D32),
            onTertiaryContainer: Color(0xFFBDF4C0),
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
  runApp(
    MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeNotifier.mode,
      home: LecturaApp(),
    ),
  );
}

class LecturaApp extends StatefulWidget {
  const LecturaApp({super.key});

  @override
  State<LecturaApp> createState() => LecturaAppState();
}

class LecturaAppState extends State<LecturaApp> {
  LecturaAppState();

  List<Map<String, dynamic>> items = [
    {
      'title': 'Auswertung',
      'subtitle': 'Alle Evaluationen ansehen und analysieren',
      'page': SettingsPage(),
      'icon': Icons.bar_chart,
    },
    {
      'title': 'Neue Evaluation erstellen',
      'subtitle': 'Neue Evaluation für eine Vorlesung anlegen und speichern',
      'page': SettingsPage(),
      'icon': Icons.upload_file_outlined
    },
    {
      'title': 'Einstellungen',
      'subtitle': 'Lectura konfigurieren',
      'page': SettingsPage(),
      'icon': Icons.settings
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: EdgeInsets.all(20),
          child: const Text(
            'Evaluation',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            FilledButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(MediaQuery.of(context).size.width, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),

              onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(
                    builder: (context) => const CreateEvaluationPage(),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 30),
                  SizedBox(width: 10),
                  Text(
                    "Neue Evaluation starten",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Verwaltung",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListCard(
                    icon: items[index]['icon'],
                    title: items[index]['title'],
                    subtitle: items[index]['subtitle'],
                    page: items[index]['page'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ListCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget page;

  const ListCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: Theme.of(context).colorScheme.surfaceBright,
      child: ListTile(
        leading: Container(
          width: 42,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 22,
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }
}
