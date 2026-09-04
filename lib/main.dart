import 'package:flutter/material.dart';
import 'variables.dart';
import 'package:flutter/services.dart';
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
        home: lecturaApp(),
      )
  );
}

class lecturaApp extends StatelessWidget {
  const lecturaApp({super.key});

  final List<Map<String, dynamic>> items = const [
    {'title': 'Fragen & Themen', 'page': settingsPage(), 'icon': Icons.edit},
    {'title': 'Ergebnisse', 'page': settingsPage(), 'icon': Icons.bar_chart},
    {'title': 'Import & Export', 'page': settingsPage(), 'icon': Icons.share},
    {'title': 'Einstellungen', 'page': settingsPage(), 'icon': Icons.settings},
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
                minimumSize: Size(MediaQuery
                    .of(context)
                    .size
                    .width, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),

              onPressed: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) => settingsPage(),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 30),
                  SizedBox(width: 10),
                  Text("Neue Evaluation starten",
                      style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
            SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Letzte Evaluation",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            CourseCard(),
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
                    text: items[index]['title'],
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
  final String text;
  final Widget page;

  const ListCard({
    super.key,
    required this.icon,
    required this.text,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: Theme
          .of(context)
          .colorScheme
          .surfaceBright,
      child: ListTile(
        leading: Container(
          width: 42,
          height: 50,
          decoration: BoxDecoration(
            color: Theme
                .of(context)
                .colorScheme
                .surfaceContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Theme
                .of(context)
                .colorScheme
                .primary,
            size: 22,
          ),
        ),
        title: Text(text),
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

class CourseCard extends StatelessWidget {
  const CourseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme
          .of(context)
          .colorScheme
          .surfaceBright,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => settingsPage()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .surfaceContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.bar_chart,
                  color: Theme
                      .of(context)
                      .colorScheme
                      .primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Software Engineering',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 14),
                        const SizedBox(width: 4),
                        Text('03.06.2024', style: TextStyle(fontSize: 12)),

                        const SizedBox(width: 10),

                        Icon(Icons.people_outline, size: 14),
                        const SizedBox(width: 4),
                        Text('27 Antworten', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme
                            .of(
                          context,
                        )
                            .colorScheme
                            .onTertiaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Abgeschlossen',
                        style: TextStyle(
                          color: Theme
                              .of(context)
                              .colorScheme
                              .onTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}
