import 'package:flutter/material.dart';
import 'package:horizontal_stepper_flutter/horizontal_stepper_flutter.dart';
import '../variables.dart';

int currentStep = 0;

class CreateEvaluationPage extends StatefulWidget {
  const CreateEvaluationPage({super.key});

  @override
  State<CreateEvaluationPage> createState() => CreateEvaluationPageState();
}

class CreateEvaluationPageState extends State<CreateEvaluationPage> {
  CreateEvaluationPageState();

  final steps = [
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
                child: Text("Weiter"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
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
            steps[currentStep].page,
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
  int? _value = 1;

  @override
  build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: topicNotifier.loadTopics(),
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
              selected: _value == index,
              labelStyle: TextStyle(
                color: _value == index
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.primary,
              ),
              onSelected: (bool selected) {
                setState(() {
                  _value = selected ? index : null;
                });
              },
            );
          }).toList(),
        );
      },
    );
  }
}

class QuestionSelectionStep extends StatelessWidget {
  const QuestionSelectionStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [Text("Step 2")]);
  }
}