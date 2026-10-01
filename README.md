# Lectura 📖

Lectura ist eine einfache App zum Auswerten von Vorlesungen

## Abhängigkeiten

````shell
flutter pub add shared_preferences flutter_launcher_icons flutter_soloud uuid intl flutter_rating
````

## Mockup

Die Mockupversionen können in [Mockup DrawIO](./Process.drawio) nachverfolgt werden

## KI

Zur Erstellung der Mockups und vereinzelten Code passagen wurde generative KI benutzt.
Die genaue Nutzung, inklusive der genutzten Prompts kann in der [KI-History](AI.md) nachverfolgt werden.

## Storyboard

MVP Version: **1**

```mermaid
kanban
    columnStarten[App starten]
        starten1[Evaluation starten **1**]
        starten2[Auswertungen alter Evaluationen aufrufen **1**]
        starten3[Neue Evaluation erstellen **1**]
        starten4[Einstellungen öffnen **1**]

    columnAuswaehlen[Evaluation auswählen]
        auswaehlen1[Vorhandene Evaluationen aus JSON-Datei anzeigen **1**]
        auswaehlen2[Vorhandene Evaluationen durchsuchen **1**]
        auswaehlen3[Vorhandene Evaluationen aus der Cloud anzeigen **2**]

    columnErstellen[Evaluation erstellen]
        erstellen1[Name für Evaluation festlegen **1**]
        erstellen2[Fragenpool aus JSON-Datei laden **1**]
        erstellen3[Aus Fragenpool 3 Fragen auswählen **1**]
        erstellen4[Evaluation starten **1**]
        erstellen5[Evaluation in Cloud speichern **2**]
        erstellen6[Fragenpool aus Cloud laden **2**]

    columnDurchfuehren[Evaluation durchführen]
        durchfuehren1[Alle Fragen nacheinander durchgehen **1**]
        durchfuehren2[Bewertung anhand von 5 Smileys und zur nächsten Frage springen **1**]
        durchfuehren3[Aktuellen Stand in Progressbar anzeigen **1**]
        durchfuehren4[Warnung, wenn Umfrage verlassen wird **1**]
        durchfuehren5[Dialogfenster, wenn Umfrage verlassen wird **1**]
        durchfuehren6[Kurzer Wartescreen, wenn alle Fragen für eine Umfrage beendet sind **1**]

    columnAuswerten[Evaluation auswerten]
        auswerten1[Gesamtbewertung **1**]
        auswerten2[Einzelauswertung für jede Frage **1**]
        auswerten3[Export für diese Auswertung in CSV und PDF **2**]
        auswerten4[Export für alle Auswertungen in CSV und PDF **2**]
        auswerten5[Auswertung in Cloud speichern **2**]

    columnNachverfolgen[Auswertungen nachverfolgen]
        nachverfolgen1[Alle gespeicherten Auswertungen aus Cloud laden **2**]
        nachverfolgen2[Export für alle Auswertungen in CSV und PDF **2**]
        nachverfolgen3[Import von Auswertungen als CSV oder JSON **2**]

    columnAnpassen[App anpassen]
        anpassen1[Dark-/Lightmodus setzen und speichern in SP **1**]
```