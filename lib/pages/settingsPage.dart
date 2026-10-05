import 'package:flutter/material.dart';
import '../variables.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Einstellungen", style: TextStyle(fontWeight: FontWeight.bold))),
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

class ModeRadioSwitch extends StatefulWidget {
  const ModeRadioSwitch({super.key});

  @override
  State<ModeRadioSwitch> createState() => ModeRadioSwitchState();
}

class ModeRadioSwitchState extends State<ModeRadioSwitch> {

  ThemeMode? mode = themeNotifier.mode;

  @override
  Widget build(BuildContext context) {
    return RadioGroup<ThemeMode>(
      groupValue: mode,
      onChanged: (ThemeMode? value) {
        themeNotifier.setMode(value ?? ThemeMode.system);
        setState(() {
          mode = value;
        });
      },
      child: const Column(
        children: <Widget>[
          ListTile(
            title: Text('Light'),
            leading: Radio<ThemeMode>(value: ThemeMode.light),
          ),
          ListTile(
            title: Text('Dark'),
            leading: Radio<ThemeMode>(value: ThemeMode.dark),
          ),
          ListTile(
            title: Text('System'),
            leading: Radio<ThemeMode>(value: ThemeMode.system),
          ),
        ],
      ),
    );
  }
}