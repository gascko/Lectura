import 'package:flutter/material.dart';
import 'package:lectura/api.dart';
import 'package:lectura/main.dart';
import 'package:lectura/objects.dart';
import 'package:lectura/variables.dart';
import 'package:uuid/uuid.dart';
import 'evaluationPage.dart';

class CreateEvaluationPage extends StatefulWidget {
  const CreateEvaluationPage({super.key});

  @override
  State<CreateEvaluationPage> createState() => CreateEvaluationPageState();
}

class CreateEvaluationPageState extends State<CreateEvaluationPage> {
  CreateEvaluationPageState();

  int numberOfQuestions = 3;
  final formularKey = GlobalKey<FormState>();
  var uuid = Uuid();
  String name = "";
  List<String> questionIds = [];

  @override
  void initState() {
    super.initState();

    errorNotifier.addListener(() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ein Fehler ist aufgetreten."),
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LecturaApp()),
            (route) => false,
      );
    });
  }

  Future<bool?> continueDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Umfrage starten'),
          content: const Text('Möchtest du die Umfrage speichern und starten?'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Abbrechen'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Umfrage ohne zu Speichern starten'),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => EvaluationPage(
                      evaluation: Evaluation(
                        uuid.v4(),
                        name,
                        DateTime.now(),
                        questionIds,
                      ),
                    ),
                  ),
                  (route) => false,
                );
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Umfrage speichern und starten'),
              onPressed: () {
                setState(() async {
                  await createEvaluation(name, questionIds);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => EvaluationPage(
                        evaluation: Evaluation(
                          uuid.v4(),
                          name,
                          DateTime.now(),
                          questionIds,
                        ),
                      ),
                    ),
                    (route) => false,
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool?> exitDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Umfrage erstellen beenden'),
          content: const Text('Willst du die Umfrage speichern?'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Abbrechen'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Beenden ohne zu Speichern'),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LecturaApp()),
                  (route) => false,
                );
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Umfrage speichern und beenden'),
              onPressed: () async {
                if (formularKey.currentState!.validate() &&
                    questionIds.length >= numberOfQuestions) {
                  await createEvaluation(name, questionIds);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LecturaApp()),
                    (route) => false,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Alle Felder müssen ausgefüllt werden"),
                    ),
                  );
                  Navigator.pop(context, false);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Neue Evaluation erstellen",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: exitDialog,
          icon: Icon(Icons.arrow_back),
        ),
      ),
      persistentFooterButtons: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (formularKey.currentState!.validate() &&
                      questionIds.length >= numberOfQuestions) {
                    continueDialog();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Alle Felder müssen ausgefüllt werden"),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: Text("Evaluation starten"),
              ),
            ),
          ],
        ),
      ],
      body: FutureBuilder<List<Question>>(
        future: getQuestions(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: EdgeInsetsGeometry.all(20),
            child: Form(
              key: formularKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsetsGeometry.directional(bottom: 20),
                    child: Text(
                      "Umfrage benennen",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.directional(bottom: 20),
                    child: Text(
                      "Gib deiner Evaluation einen Namen, um sie später besser wiederzufinden.",
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.directional(bottom: 20),
                    child: TextFormField(
                      onChanged: (value) {
                        name = value;
                        formularKey.currentState!.validate();
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Bitte vergebe noch einen Namen für die Evaluation";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "z.B. Evaluation Vorlesung Datenbanken",
                      ),
                      maxLength: 30,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.directional(bottom: 20),
                    child: Text(
                      "Fragen auswählen",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.directional(bottom: 20),
                    child: Text(
                      "Wähle die Fragen aus, die in dieser Evaluation beantwortet werden sollen.",
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "${questionIds.length}/${numberOfQuestions} ausgewählt",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: questionIds.length < numberOfQuestions
                            ? Colors.red
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      scrollDirection: Axis.vertical,
                      itemCount: snapshot.data!.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        return Card(
                          child: CheckboxListTile(
                            isError: questionIds.length < numberOfQuestions
                                ? true
                                : false,
                            title: Text(
                              snapshot.data![index].text,
                              softWrap: true,
                            ),
                            value: questionIds.contains(
                              snapshot.data![index].id,
                            ),
                            onChanged: (value) {
                              setState(() {
                                if (questionIds.contains(
                                  snapshot.data![index].id,
                                )) {
                                  questionIds.remove(snapshot.data![index].id);
                                } else {
                                  if (questionIds.length < numberOfQuestions) {
                                    questionIds.add(snapshot.data![index].id);
                                  }
                                }
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
