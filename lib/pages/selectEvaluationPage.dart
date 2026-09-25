import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lectura/api.dart';
import 'package:lectura/objects.dart';
import 'package:lectura/pages/evaluationPage.dart';

class SelectEvaluationPage extends StatefulWidget {
  const SelectEvaluationPage({super.key});

  @override
  State<SelectEvaluationPage> createState() => SelectEvaluationPageState();
}

class SelectEvaluationPageState extends State<SelectEvaluationPage> {
  List<Evaluation> displayedEvaluations = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Evaluation starten",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
      ),
      body: FutureBuilder<List<Evaluation>>(
        future: getEvaluations(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (displayedEvaluations.isEmpty) {
            displayedEvaluations = snapshot.data!;
          }
          return Padding(
            padding: EdgeInsetsGeometry.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.directional(bottom: 5),
                  child: Text(
                    "Vorhandene Evaluationen",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsGeometry.directional(bottom: 20),
                  child: Text(
                    "Wähle eine Evaluation aus, um sie zu starten.",
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsGeometry.directional(bottom: 20),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Evaluationen durchsuchen",
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          width: 1.5,
                        ),
                      ),
                    ),
                    onChanged: (text) {
                      setState(() {
                        if (text.isNotEmpty) {
                          displayedEvaluations = snapshot.data!
                              .where(
                                (evaluation) => evaluation.name.contains(text),
                              )
                              .toList();
                        } else {
                          displayedEvaluations = snapshot.data!;
                        }
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    scrollDirection: Axis.vertical,
                    itemCount: displayedEvaluations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          trailing: Icon(Icons.chevron_right),
                          title: Text(
                            displayedEvaluations[index].name,
                            softWrap: true,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EvaluationPage(
                                  evaluation: Evaluation(
                                    displayedEvaluations[index].id,
                                    displayedEvaluations[index].name,
                                    displayedEvaluations[index].creationDate,
                                    displayedEvaluations[index].questionIds,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
