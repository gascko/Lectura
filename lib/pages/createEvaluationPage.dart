import 'package:flutter/material.dart';
import 'package:lectura/api.dart';
import 'package:lectura/objects.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Neue Evaluation erstellen",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      persistentFooterButtons: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {});
                },
                child: Text("Speichern"),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (formularKey.currentState!.validate()) {
                      if (questionIds.length >= numberOfQuestions) {
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
                      }
                    }
                  });
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
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
