import 'package:flutter/material.dart';
import 'package:horizontal_stepper_flutter/horizontal_stepper_flutter.dart';
import 'package:lectura/objects.dart';
import '../variables.dart';

int currentStep = 0;
Evaluation newEvaluation = Evaluation();

class CreateEvaluationPage extends StatefulWidget {
  const CreateEvaluationPage({super.key});

  @override
  State<CreateEvaluationPage> createState() => CreateEvaluationPageState();
}

class CreateEvaluationPageState extends State<CreateEvaluationPage> {
  CreateEvaluationPageState();

  var steps = [
    (title: 'Thema', page: TopicStep()),
    (title: 'Fragen', page: QuestionSelectionStep()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Neue Evaluation",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            if (currentStep > 0)
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (currentStep > 0) {
                        currentStep -= 1;
                      }
                    });
                  },
                  child: Text("Zurück"),
                ),
              ),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (currentStep < steps.length - 1) {
                      currentStep += 1;
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: Text("Weiter"),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CreationStepper(
              steps: steps.map((element) => element.title).toList(),
              currentStep: currentStep + 1,
            ),
            SizedBox(height: 30),
            Text(
              steps[currentStep].title,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Expanded(child: steps[currentStep].page),
          ],
        ),
      ),
    );
  }
}

class CreationStepper extends StatelessWidget {
  final List<String> steps;
  final int currentStep;

  const CreationStepper({
    required this.steps,
    required this.currentStep,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterHorizontalStepper(
      steps: steps,
      radius: 45,
      thickness: 3,
      currentStep: currentStep,
      inActiveStepColor: Theme.of(context).colorScheme.surfaceBright,
      currentStepColor: Theme.of(context).colorScheme.primary,
      completeStepColor: Theme.of(context).colorScheme.onTertiary,
      child: [
        for (int i = 1; i < steps.length + 1; i++)
          Text("$i", style: TextStyle(color: Colors.black)),
      ],
    );
  }
}

class TopicStep extends StatefulWidget {
  const TopicStep({super.key});

  @override
  State<TopicStep> createState() => TopicStepState();
}

class TopicStepState extends State<TopicStep> {
  String selectedTopic = "";
  late Future<List<String>> topicsFuture;

  @override
  void initState() {
    super.initState();

    topicsFuture = topicNotifier.loadTopics().then((topics) {
      if (topics.isNotEmpty) {
        selectedTopic = topics.first;
        newEvaluation.topic = topics.first;
      }
      return topics;
    });
  }

  @override
  build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: topicsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        return Wrap(
          spacing: 20.0,
          runSpacing: 20,
          children: List<Widget>.generate(snapshot.data!.length, (int index) {
            return ChoiceChip(
              label: Text(snapshot.data![index]),
              selectedColor: Theme.of(context).colorScheme.primary,
              showCheckmark: false,
              padding: EdgeInsets.all(15),
              selected: selectedTopic == snapshot.data![index],
              labelStyle: TextStyle(
                color: selectedTopic == snapshot.data![index]
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.primary,
              ),
              onSelected: (bool selected) {
                setState(() {
                  selectedTopic = snapshot.data![index];
                  newEvaluation.topic = selectedTopic;
                });
              },
            );
          }).toList(),
        );
      },
    );
  }
}

class QuestionSelectionStep extends StatefulWidget {
  const QuestionSelectionStep({super.key});

  @override
  QuestionSelectionStepState createState() => QuestionSelectionStepState();
}

class QuestionSelectionStepState extends State<StatefulWidget> {
  bool randomQuestions = true;
  late Future<List<String>> questionsFuture;

  @override
  void initState() {
    super.initState();

    questionsFuture = questionNotifier.loadQuestions(newEvaluation.topic).then((
      questions,
    ) {
      return questions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: questionsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            RadioGroup<bool>(
              groupValue: randomQuestions,
              onChanged: (bool? value) {
                setState(() {
                  randomQuestions = value!;
                });
              },
              child: const Column(
                children: <Widget>[
                  RadioListTile<bool>(
                    title: Text('Zufällige Fragen aus dem Pool'),
                    value: true,
                  ),
                  RadioListTile<bool>(
                    title: Text("Fragen auswählen"),
                    value: false,
                  ),
                ],
              ),
            ),
            if (!randomQuestions)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "${newEvaluation.questions.length}/${numberOfQuestions} ausgewählt",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            if (!randomQuestions)
              Expanded(
              child: ListView.separated(
                scrollDirection: Axis.vertical,
                itemCount: snapshot.data!.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  return ChoiceChip(
                    label: Text(snapshot.data![index]),
                    selected: newEvaluation.questions.contains(
                      snapshot.data![index],
                    ),
                    onSelected: (bool selected) {
                      setState(() {
                        if (newEvaluation.questions.contains(
                          snapshot.data![index],
                        )) {
                          newEvaluation.questions.remove(snapshot.data![index]);
                        } else {
                          if (newEvaluation.questions.length <
                              numberOfQuestions) {
                            newEvaluation.questions.add(snapshot.data![index]);
                          }
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
