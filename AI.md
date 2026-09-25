--
Datum: 16.09.2026
--

# Frage:
Schau dir die Datei @lib\pages\createEvaluationPage.dart an. Wenn ich die Seite im Android Emulator aufrufe, ausgehend von der Seite @lib\main.dart, sollten eigentlich zu Beginn
alle Questions und Topics geladen werden (siehe die Funktionen loadTopics() und loadQuestions()). Leider werden die topics erst geladen wenn ich mindestens einmal mit der Seite  
interagiert habe, also zum Beispiel den "weiter" button gedrückt habe und danach auf den "Zurück"-Button klicke. Die Questions werden gar nicht geladen. Ich habe geprüft ob      
überhaupt Daten vorhanden sind. Die Funktionen questionNotifier.loadQuestions und topicNotifier.loadTopics funktionieren in einem anderen Szenarion korrekt und liefern           
entsprechend Werte zurück. Suche nach möglichen Fehlern in der createEvaluationPage.dart Datei, nehme jedoch keine Änderungen vor, greife nicht auf git zu und lese nur die       
gegebenen Dateien ein. Wenn du mehr Kontext brauchst Frage danach.

# Antwort:

Diagnose: Warum Topics verzögert und Questions gar nicht laden
Der Kernfehler liegt nicht in den Loader-Funktionen selbst, sondern in zwei strukturellen Problemen in createEvaluationPage.dart, die sich zu genau deinem Symptom verdichten.
Fehler 1: Die Step-Widgets sind StatelessWidget-Instanzen, die einmalig in final steps angelegt werden → initState/build wird nicht neu ausgeführt

final steps = [
(title: 'Thema', page: TopicStep()),
(title: 'Fragen', page: QuestionSelectionStep()),
];

steps ist eine Instanzvariable des State. Die TopicStep()- und QuestionSelectionStep()-Instanzen werden beim Erstellen des State-Objekts ein einziges Mal erzeugt und danach für
die gesamte Lebensdauer der Seite wiederverwendet.

Das Problem entsteht durch die Kombination mit deinen globalen Listen:

List<String> topics = [];    // global
List<String> questions = []; // global

Die Daten landen also nicht in den State-Objekten der Sub-Widgets, sondern in globalen Variablen, die von außen gefüllt werden. Ob die UI das dann rendert, hängt davon ab, wann
der zuständige build-Call auftritt.

Fehler 2 (der eigentliche Bug für die verzögerte Frage- und Topics-Anzeige): loadQuestions hängt an newEvaluation.topic, der noch leer ist

Schau dir die Reihenfolge in initState an:

void initState() {
super.initState();
loadTopics();      // async, awaitet
loadQuestions();   // async, wird SOFORT danach synchron aufgerufen
}

initState ist nicht await-fähig. loadTopics() ist ein Future – initState ruft es aus, wartet aber nicht, und führt sofort die nächste Zeile aus, also loadQuestions().

Und loadQuestions liest:

Future<void> loadQuestions() async {
questions = await questionNotifier.loadQuestions(newEvaluation.topic);
...
}

Zum Zeitpunkt dieses Aufrufs ist newEvaluation.topic noch "" (leer), weil loadTopics seine await-Zukunft erst später auflöst und erst dann newEvaluation.topic = topics.first
setzt.

Folge:
- questionNotifier.loadQuestions("") wird mit leerem Topic aufgerufen.
- In storage.dart: storage.getStringList("") ?? List.empty() → leere Liste (kein Schlüssel "" existiert).
- questions bleibt []. take(3) → [].

Das ist exakt dein „Questions werden gar nicht geladen".

Fehler 3: setState in loadTopics/loadQuestions rendert nicht die Step-Widgets neu, weil diese bereits aufgebaut sind und die globalen Listen keinen Reactiven-Zusammenhang haben

Hier kommt der Teil, der dein verzögertes Topic-Laden erklärt:

loadTopics füllt nach await die globale topics-Liste und ruft setState(() {}). Das baut die CreateEvaluationPage neu auf. In build steht:

steps[currentStep].page,  // = TopicStep (gleiche, wiederverwendete Instanz)

Das TopicStep-Widget ist dieselbe Instanz wie beim ersten Build. Flutter vergleicht bei updateChild ob das Element-Kind zum neuen Widget kompatibel ist. Wenn das Widget-Objekt
identisch (gleiche Referenz) ist, kann Flutter die Rebuild-Logik in manchen Fällen überspringen bzw. das Kind-Element wird mit dem alten Widget-Objekt wiederverwendet – und das
TopicStep-State-Objekt bleibt bestehen. Aber der entscheidende Punkt:

TopicStep.build liest topics.map(...) direkt aus der globalen Liste. Beim allerersten build (während/sofort nach initState) ist topics noch [] (die await war noch nicht fertig) →
keine Chips. Die setState aus loadTopics baut zwar CreateEvaluationPage neu, aber ob TopicStep seinen build erneut mit der nun gefüllten Liste ausführt, hängt davon ab, dass
Flutter das Kind-Element erneut durch build schicken will – bei einer identischen Widget-Instanz in einer Liste/Stepper-Kombination passiert genau dieses „nicht neu rendern"
zuverlässig, bis eine weitere, manuelle Interaktion (Weiter → Zurück) eine setState mit geändertem currentStep triggert und damit eine neue Render-Pipeline erzwingt.

Kurz: Die UI „weiß" nicht, dass topics sich gefüllt hat, weil:
1. Die Daten sind in globalen Variablen statt im State des rendernden Widgets.
2. Der zugehörige setState wird im CreateEvaluationPageState aufgerufen, nicht im TopicStepState – aber TopicStep ist ein anderes Widget mit eigenem State, den du nie
   benachrichtigst.
3. Die TopicStep/QuestionSelectionStep-Instanzen in final steps sind wiederverwendete, identische Objekte.

Zusätzlicher Fehler 4: TopicStepState.selectedTopic = "tets" und das Fehlen von @override

class TopicStepState extends State<TopicStep> {
String selectedTopic = "tets";//topics.first;
@override
build(BuildContext context) { ... }   // <- kein Rückgabetyp!

- build fehlt der Rückgabetyp Widget (wird nur als dynamic/Wartung gewarnt, läuft aber).
- selectedTopic = "tets": Der Chip, der selected: selectedTopic == topic ist, markiert also nie einen echten Topic als gewählt, solange der Nutzer nicht tippt. Und da
  topics.first kommentiert ist, wird kein Default gesetzt.

Fehler 5: QuestionSelectionStepState liest questions im Konstruktionszeitpunkt

class QuestionSelectionStepState extends State<StatefulWidget> {
...
List<String> selectedQuestions = questions.take(3).toList(); // <- wird EINE MAL beim State-Erzeugen berechnet

Dies wird ein einziges Mal beim Erzeugen des State-Objekts ausgewertet. Wenn questions zum Zeitpunkt der State-Erzeugung noch leer ist (was es fast immer ist, weil
QuestionSelectionStep erst in steps beim Erstellen des CreateEvaluationPageState erzeugt wird – lange bevor loadQuestions aufgelöst ist), ist selectedQuestions dauerhaft [].
Selbst wenn questions später gefüllt wird, aktualisiert sich selectedQuestions nie, weil er keine final-Liste mit eigener Logik ist, sondern eine einmalige Kopie.

Zusammenfassung der Fehler (nur in createEvaluationPage.dart)

┌─────┬───────────────────────────────────────────┬─────────────────────────────────────────────────────────────────────────┬─────────────────────────────────────────────────┐
│  #  │                  Stelle                   │                                 Problem                                 │                   Auswirkung                    │
├─────┼───────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────┤
│ 1   │ initState                                 │ loadTopics() nicht awaitet, loadQuestions() startet damit, bevor        │ loadQuestions("") → leere Liste                 │
│     │                                           │ newEvaluation.topic gesetzt ist                                         │                                                 │
├─────┼───────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────┤
│ 2   │ loadQuestions                             │ hängt von newEvaluation.topic ab, der beim Start "" ist                 │ Questions laden nie                             │
├─────┼───────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────┤
│ 3   │ final steps = [ ... TopicStep(),          │ Instanzen werden nur 1× erzeugt & wiederverwendet; UI liest aus         │ Topics/Questions rendern nicht neu, bis         │
│     │ QuestionSelectionStep() ]                 │ globalen Listen, nicht aus State                                        │ manuelle setState (z. B. Weiter/Zurück)         │
├─────┼───────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────┤
│ 4   │ globale topics/questions                  │ setState im CreateEvaluationPageState benachrichtigt nicht die          │ verzögerte/fehlende Darstellung                 │
│     │                                           │ TopicStepState/QuestionSelectionStepState                               │                                                 │
├─────┼───────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────┤
│ 5   │ TopicStepState                            │ selectedTopic = "tets" statt topics.first; build ohne Rückgabetyp       │ kein korrekt vorselektierter Chip               │
│     │                                           │ Widget                                                                  │                                                 │
├─────┼───────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────┤
│ 6   │ QuestionSelectionStepState                │ selectedQuestions wird einmalig beim State-Erzeugen aus (noch leerem)   │ ausgewählte Fragen bleiben leer                 │
│     │                                           │ questions kopiert                                                       │                                                 │
└─────┴───────────────────────────────────────────┴─────────────────────────────────────────────────────────────────────────┴─────────────────────────────────────────────────┘

Warum „in einem anderen Szenario funktioniert es"

Weil dort die Loader nach einem bereits gefüllten Zustand / mit korrektem topic-Wert aufgerufen werden und/oder die setState-Aufrufe in denselben State liegen, der auch rendert.
Hier sind die Daten global, die Instanzen wiederverwendet und loadQuestions startet zu früh – die drei Fehler wirken zusammen.

Mögliche (nicht umgesetzte) Fix-Richtung, falls du danach fragst

- loadTopics in initState awaiten (initState kann das nicht, aber man kann einen Future starten und loadQuestions erst nach then/await auslösen) oder loadQuestions nach dem
  Setzen von newEvaluation.topic triggern.
- newEvaluation.topic als String? behandeln und loadQuestions erst aufrufen, wenn topic != null.
- Die globalen topics/questions in den State der jeweils rendernden Widgets verschieben (bzw. die Notifier direkt mit AnimatedBuilder/ListenableBuilder abonnieren), und steps in
  build neu aufbauen, statt sie in final zu parken.

Soll ich zu einem dieser Punkte einen konkreten Code-Patch vorschlagen, oder brauchst du noch mehr Kontext (z. B. die Init.json oder settingsPage.dart)?


- loadTopics in initState awaiten (initState kann das nicht, aber man kann einen Future starten und loadQuestions erst nach then/await auslösen) oder loadQuestions nach dem
  Setzen von newEvaluation.topic triggern.
- newEvaluation.topic als String? behandeln und loadQuestions erst aufrufen, wenn topic != null.
- Die globalen topics/questions in den State der jeweils rendernden Widgets verschieben (bzw. die Notifier direkt mit AnimatedBuilder/ListenableBuilder abonnieren), und steps in
  build neu aufbauen, statt sie in final zu parken.

Soll ich zu einem dieser Punkte einen konkreten Code-Patch vorschlagen, oder brauchst du noch mehr Kontext (z. B. die Init.json oder settingsPage.dart)?

Hinweis zu meiner Suche: Die Web-Suche lieferte keine verwertbaren Treffer, meine Aussagen zu Element.updateChild/identischen Widget-Instanzen basieren auf dem
Standard-Flutter-Rendering-Verhalten.

---
Datum: 25.09.2026
---

# Frage:

Wie kann ich in Flutter die zurück taste bzw. die zurück wisch geste umleiten auf eine eigene funktion die erstmal eine Warnung als Pop-Up Window anzeigt oder so bevor man die Seite verlässt?

# Antwort:

Ja. In aktuellem Flutter ist dafür PopScope gedacht. Damit kannst du die Zurück-Navigation zunächst blockieren, dein eigenes Dialogfenster anzeigen und erst nach Bestätigung Navigator.pop() ausführen. PopScope behandelt insbesondere die Android-System-Zurück-Geste bzw. Zurück-Taste.

Beispiel: Warnung vor dem Verlassen
class EditPage extends StatelessWidget {
const EditPage({super.key});

Future<bool> _confirmLeave(BuildContext context) async {
final result = await showDialog<bool>(
context: context,
builder: (context) => AlertDialog(
title: const Text('Seite verlassen?'),
content: const Text(
'Deine Änderungen wurden noch nicht gespeichert. '
'Möchtest du die Seite wirklich verlassen?',
),
actions: [
TextButton(
onPressed: () => Navigator.pop(context, false),
child: const Text('Abbrechen'),
),
FilledButton(
onPressed: () => Navigator.pop(context, true),
child: const Text('Verlassen'),
),
],
),
);

    return result ?? false;
}

@override
Widget build(BuildContext context) {
return PopScope(
// Zurück zunächst blockieren
canPop: false,

      onPopInvokedWithResult: (didPop, result) async {
        // Falls die Seite bereits geschlossen wurde, nichts machen
        if (didPop) return;

        final shouldLeave = await _confirmLeave(context);

        if (shouldLeave && context.mounted) {
          Navigator.of(context).pop();
        }
      },

      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bearbeiten'),
        ),
        body: const Center(
          child: Text('Meine Seite'),
        ),
      ),
    );
}
}

Was passiert hier?

Wenn der Benutzer

die Android-Zurück-Taste drückt,
die Android-Zurück-Geste verwendet,
oder anderweitig versucht, die Route zu schließen,

verhindert

canPop: false,


zunächst das Verlassen der Seite. Flutter ruft anschließend onPopInvokedWithResult mit didPop == false auf.

Dann kannst du deine eigene Funktion ausführen:

final shouldLeave = await _confirmLeave(context);


Nur wenn der Nutzer bestätigt:

if (shouldLeave && context.mounted) {
Navigator.of(context).pop();
}


wird die Seite tatsächlich geschlossen.

Noch praktischer bei ungespeicherten Änderungen

Du kannst canPop auch abhängig von deinem State setzen:

PopScope(
canPop: !hasUnsavedChanges,
onPopInvokedWithResult: (didPop, result) async {
if (didPop) return;

    final leave = await _confirmLeave(context);

    if (leave && context.mounted) {
      Navigator.pop(context);
    }
},
child: ...
)


Damit kommt die Warnung nur dann, wenn tatsächlich ungespeicherte Änderungen vorhanden sind.

Wichtig bei iOS: Die Cupertino-Swipe-Back-Geste verhält sich etwas anders. Wenn canPop: false zusammen mit CupertinoRouteTransitionMixin verwendet wird, wird laut Flutter-Dokumentation die Geste gar nicht erkannt und der Callback entsprechend nicht ausgelöst.

Falls du mir deinen aktuellen Scaffold/Page-Code schickst, kann ich dir PopScope direkt an der richtigen Stelle einbauen.