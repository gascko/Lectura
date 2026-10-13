import 'package:flutter/material.dart';
import 'package:lectura/api.dart';
import 'package:lectura/main.dart';
import 'package:lectura/objects.dart';
import 'package:lectura/pages/evaluationPage.dart';
import 'package:lectura/variables.dart';

class SelectEvaluationPage extends StatefulWidget {
  const SelectEvaluationPage({super.key});

  @override
  State<SelectEvaluationPage> createState() => SelectEvaluationPageState();
}

class SelectEvaluationPageState extends State<SelectEvaluationPage> {

  List<Evaluation> targetEvaluations = [];
  bool search = false;

  @override
  void initState() {
    super.initState();

    errorNotifier.addListener(() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ein Fehler ist aufgetreten. ${errorNotifier.errorMessage}"),
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LecturaApp()),
            (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Evaluation starten",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Evaluation>>(
        future: getEvaluations(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!search) {
            targetEvaluations = snapshot.data!.toList();
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text(
                  "Vorhandene Evaluationen",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  "Wähle eine Evaluation aus, um sie zu starten.",
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Evaluationen durchsuchen",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(width: 1.5),
                    ),
                  ),
                  onChanged: (text) {
                    setState(() {
                      if (text.isNotEmpty) {
                        search = true;
                        targetEvaluations = snapshot.data!.where(
                                (evaluation) => evaluation.name.contains(text))
                            .toList();
                      }
                      else {
                        search = false;
                      }
                    });
                  },
                ),
              ),

          ...targetEvaluations.map(
                (evaluation) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Card(
                    child: ListTile(
                      trailing: const Icon(Icons.chevron_right),
                      title: Text(evaluation.name, softWrap: true),
                      onTap: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => EvaluationPage(
                              evaluation: Evaluation(
                                evaluation.id,
                                evaluation.name,
                                evaluation.creationDate,
                                evaluation.questionIds,
                              ),
                            ),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
