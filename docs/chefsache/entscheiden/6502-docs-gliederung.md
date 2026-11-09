# 650.2 · Notizen: was weg kann, was doppelt ist, welche Gliederung
Sokrates · 09.11., 20:04 (Vorlage 19:58, C6 berichtigt) · B Abläufe · aus 650 (Schritt 2 und 3)
Kurz: 11 Dateien nach alt/ oder kapitel2/, 6 Themen zusammenlegen, Gliederung flach lassen, Inhaltsverzeichnis neu

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/b0cb30363/docs (84 Dateien; je Datei Größe, Anlage, letzte Änderung, Verweise aus Notizen und Werkzeugen, Kopfzeilen gelesen)

**Anlass (Chef 19:55):** „Was davon kann weg? Was ist eigentlich zusammengeführt und ist nicht aktuell? Macht eine andere Gliederung Sinn? Was ist mit unseren ‚großen‘ Dateien, die wir am Samstag und Sonntag kreiert haben?“

**Stand 650:** Schritt 1 erledigt (650.1, 9 Dateien in `docs/alt/`). Offen aus 650: Schritt 2 Zusammenlegen, Schritt 3 Inhaltsverzeichnis mit Prüfwerkzeug. Acht Dateien stehen in keinem Inhaltsverzeichnis (`STORY-SPIEL`, `-ANLEITUNG`, `-MENUE`, `-WAHLEN`, `-PLAN-K1`, `-PLAN-K2`, `-RUF-K1`, `-LEHRMEISTER-K1`, `LISTE-CHECK-BUILD-TEST`).

## A · Kann weg (nach `docs/alt/`, nichts wird gelöscht)

| Datei | warum | vorher |
|---|---|---|
| `DESIGN-SPIELSYSTEM-2-0` (159 KB) | Ideensammlung vom 31.10., „nichts freigegeben“; was gilt, steht im BRS | BRS-Kopf verweist auf `alt/` |
| `DESIGN-HELDENBAU` | trägt selbst „überholt durch das BRS“ | – |
| `DESIGN-BALANCE` | Zielkurve „Stufe 20 am Ende“ widerspricht dem BRS „keine feste Höchststufe“ | Grundsatz „herausfordernd, nicht zu leicht“ steht im Leitbild; prüfen |
| `STORY-ANLEITUNG` | Kotlin-Anleitung (Build 86, klassischer Kampf); keine ihrer Marken im Godot-Code | Homer: braucht Godot eine Anleitung, neu aus dem Handbuch |
| `LISTE-DURCHSPIELBOGEN` | Vorlage der Kotlin-Zeit, 26.1 ruht | – |
| `LISTE-FIGURENKATALOG-649` | sagt selbst: nach dem Bau nach `alt/` | erst nach dem Bau von 649 |
| `LISTE-SIMULATION-444` (43 KB) | Rechnung 01./02.11., Zahlen im BRS | erst nach 481 (rechnet noch mit Abschnitt 6) |

## B · Kapitel 2 in eigenen Ordner `docs/kapitel2/` (gilt erst nach Kapitel 1)

`STORY-K2-ENTWURF` (32 KB), `STORY-PLAN-K2`, `STORY-K2-LANDKARTE` (mit SVG), `STORY-WAHLEN` („kein Bau vor dem Meilenstein“). Seit 19./20.10. unverändert.

## C · Zusammenlegen (je Thema eine Datei)

1. **BRS umbenennen:** `DESIGN-SPIELSYSTEM-2-0-ENTWURF` ist die gültige Fassung und heißt „Entwurf“. Neu `DESIGN-BRS.md`, 16 Verweise (CLAUDE.md, Werkzeuge) im selben Schritt.
2. **Fremde Inhalte:** `LISTE-CC0-MODELLE` in `LISTE-QUELLEN` (aus 650.1 schon beschlossen, offen bei mir mit 623.1). `LISTE-BESTAND` (was wir haben) und `LISTE-EFFEKTE` (wo es hinkommt) bleiben getrennt.
3. **Alt gegen neu:** `LISTE-UMZUG-348` (54 KB) und `LISTE-ABGLEICH-ALT` (35 KB) prüfen beide die alte Fassung gegen Godot. Abgleich wird die eine Liste je Ort und Figur; vom Umzug bleiben die Grundsätze (Modellregel, Messlatte), Rest nach `alt/`. Gegenprüfung vorher, weil beide Prüfer in 650.1 „Umzug bleibt“ sagten.
4. **Story-Überblick (Homer):** `STORY-PLAN`, `STORY-ROTER-FADEN`, `STORY-PLAN-K1` (Ist-Stand Kotlin, 12.10.), `STORY-K1-HANDLUNG`, `STORY-CHRONIK-TEXTE-K1`: fünf Dateien für eine Geschichte. Ziel zwei: Überblick aller Kapitel, Handlung Kapitel 1. Texte wortgetreu, nur umziehen.
5. **Spielerhandbuch (Homer):** Teile 1–3 zu einer Datei; dabei gegen das BRS halten (seit 03.11. nicht nachgezogen, BRS zweimal geändert).
6. **Spieltexte Kampf (Homer), berichtigt 20:04 nach Rückfrage des Chefs:** `STORY-SPIEL` bleibt ganz; Godot nutzt die Texte (Stichprobe im Code: „entgeht dem Zauber“, „ist gesegnet“, „Zweiter Atem“). Die Grenze „15 KB“ im Kopf ist eine eigene Lesegrenze vom 18.10., keine Technik; sie fällt. Veraltet sind nur SRD-Namen in den Texten (Zweiter Atem, Kleriker, Schurke, Rettungswurf), die das BRS ersetzt (Abschnitt „Ablösung vom SRD“), und Verweise auf Kotlin-Dateien (`Skirmish.kt`). Homer gleicht die Namen ab, Texte bleiben sonst wortgetreu.

Nicht hier, weil 745 sie schon führt: Doppelungen der Regeln (`LISTE-BAUEN-TESTEN` und `LISTE-CHECK-BUILD-TEST`, `ROLLE-PRUEFUNG` und `LISTE-PRUEFUNG`).

## D · Die Wochenend-Dateien

- **31.10./01.11. (BRS):** BRS gilt, umbenennen (C1). Sammlung 2.0 nach `alt/` (A). Simulation nach 481 nach `alt/`. Handbuch zusammenlegen (C5). Bestiarium geht im Figurenkatalog 649 auf (entschieden). `LISTE-GEGENSTAENDE` (erzeugt) und `LISTE-NETZE` bleiben. `STORY-LEHRMEISTER-K1` und `STORY-RUF-K1` bleiben, ins Inhaltsverzeichnis.
- **07./08.11.:** `LISTE-ABGLEICH-ALT` bleibt, bis jede Zeile geprüft ist (C3). `LISTE-GLOSSAR` und `LISTE-KOSTEN` (erzeugt) bleiben. `LISTE-QUELLEN` und `LISTE-EFFEKTE` bleiben. `LISTE-FIGURENKATALOG-649` kommt nach dem Bau nach `alt/`.

## E · Gliederung

- **Variante 1, Ordner nach Leser:** `spiel/` (DESIGN, STORY, Spiel-Listen), `firma/` (ROLLE, ARBEIT, Handwerk), `archiv/`, `alt/`, `kapitel2/`. Auf GitHub sähest du fünf Ordner statt 84 Dateien.
- **Variante 2, flach lassen (Vorsilben wie heute):** dazu `kapitel2/` und `alt/` (B, A). Das Inhaltsverzeichnis `docs/README.md` bekommt oben „Für den Chef“ mit etwa 8 Dateien und je Datei einen Satz „wofür, wer liest wann“. Ein Werkzeug meldet jede Datei ohne Zeile und jeden toten Link (650 Schritt 3).

**Votum Sokrates: A, B, C und E Variante 2.** Ergebnis: im Hauptordner etwa 66 statt 84 Dateien.

## Auswertung

- **Stärkstes Gegenargument zu Variante 2:** auf GitHub siehst du weiter eine lange Liste, das Inhaltsverzeichnis musst du erst öffnen. **Antwort:** Variante 1 bricht Pfade in Werkzeugen, Haken und Startbefehlen jeder Sitzung (allein die Vorräte haben 11–33 Verweise je Datei) und ist Arbeit an Abläufen, nicht am Spiel (oberste Direktive). Die Vorsilben gliedern schon. Nachholen kann man es, wenn Kapitel 1 abgenommen ist.
- **Gegen A:** eine Datei in `alt/` liest keiner mehr; steht darin noch eine gültige Regel, geht sie verloren. **Antwort:** wie bei 650.1 je Datei „vorher“ erledigen und gegenprüfen lassen.
- **Die drei großen Archive** (`VORGANGSARCHIV` 426 KB, `LISTE-VORGAENGE-ARCHIV` 132 KB, `PRUEFBERICHT-ARCHIV` 77 KB) liest kein Mensch, aber Werkzeuge durchsuchen genau diese Pfade. Votum: **noch nicht** teilen. Sie sind nicht falsch, nur groß.
- **Kosten:** A, B und C1–C3 etwa eine Sitzung Perikles plus eine von mir. C4–C6 macht Homer, wenn er ohnehin an den Texten arbeitet; kein Vorgang vor Kapitel 1.

## Folgerungen

„650.2 wie Vorschlag“: Perikles verschiebt A und B und benennt C1 um (Werkzeuge im selben Schritt), baut das Inhaltsverzeichnis mit Prüfwerkzeug (E2). Ich mache C2 und lasse C3 gegenprüfen. Homer bekommt C4–C6 als Kür.
Abweichend geht je Teil: „A ja, C3 nein, E 1“.

Antwort: „650.2 wie Vorschlag“ oder je Teil.
