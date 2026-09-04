import 'package:flutter/material.dart';

class evaluationSettingsPage extends StatelessWidget {
  const evaluationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Einstellungen", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25))),
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text("Erscheinungsbild", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const Center(child: ModeRadioSwitch()),
              ],
            )
        )
    );
  }
}