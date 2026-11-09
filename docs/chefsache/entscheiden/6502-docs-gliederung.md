# 650.2 · Was von den Notizen kann weg, was legen wir zusammen, und bleibt die Gliederung flach?
Sokrates · 09.11., 20:38 (Vorlage 19:58; C6 berichtigt 20:04; Funde Diogenes Lauf 120 berichtigt 20:24; Aufbau nach 364 20:38) · B Abläufe · aus 650 (Schritt 2 und 3)
Kurz: 14 Dateien nach alt/ oder kapitel2/, 6 Themen zusammenlegen, Gliederung flach lassen, Inhaltsverzeichnis neu

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/b0cb30363/docs (84 Dateien; je Datei Größe, Anlage, letzte Änderung, Verweise aus Notizen und Werkzeugen, Kopfzeilen gelesen; Gegenprüfung Diogenes Lauf 120)

**Frage (Chef 19:55):** „Was davon kann weg? Was ist eigentlich zusammengeführt und ist nicht aktuell? Macht eine andere Gliederung Sinn? Was ist mit unseren ‚großen‘ Dateien, die wir am Samstag und Sonntag kreiert haben?“

**Votum:** „650.2 wie Vorschlag“ = A (8 Dateien nach `alt/`), B (Kapitel 2 in `kapitel2/`), C (6 Themen zusammenlegen) und E Variante 2 (flach lassen, Inhaltsverzeichnis neu mit Prüfwerkzeug). Im Hauptordner danach etwa 63 statt 84 Dateien.

**Berührt:** 650, 650.1, 745 (Doppelungen der Regeln), 649 (Figurenkatalog), 481 (Simulation), 623.1 (Quellen)

**Begründung:** Was gilt, steht heute neben Überholtem, und neun Dateien stehen in keinem Inhaltsverzeichnis; wer liest, weiß nicht, was gilt. Eine neue Ordnerstruktur kostet dagegen Arbeit an Werkzeugen statt am Spiel.

## Sachverhalt

**Stand 650:** Schritt 1 erledigt (650.1, heute 11 Dateien in `docs/alt/`). Ohne Inhaltsverzeichnis: `STORY-SPIEL`, `-ANLEITUNG`, `-MENUE`, `-WAHLEN`, `-PLAN-K1`, `-PLAN-K2`, `-RUF-K1`, `-LEHRMEISTER-K1`, `LISTE-CHECK-BUILD-TEST`.

<details><summary>A · Kann weg (nach <code>docs/alt/</code>, nichts wird gelöscht), 8 Dateien</summary>

| Datei | warum | vorher |
|---|---|---|
| `DESIGN-SPIELSYSTEM-2-0` (159 KB) | Ideensammlung vom 31.10., „nichts freigegeben“; was gilt, steht im BRS | BRS-Kopf verweist auf `alt/` |
| `DESIGN-HELDENBAU` | trägt selbst „überholt durch das BRS“ | – |
| `DESIGN-BALANCE` | Zielkurve „Stufe 20 am Ende“ widerspricht dem BRS „keine feste Höchststufe“ | Grundsatz „herausfordernd, nicht zu leicht“ steht im Leitbild; prüfen |
| `STORY-ANLEITUNG` | Kotlin-Anleitung (Build 86, klassischer Kampf); keine ihrer Marken im Godot-Code | Homer: braucht Godot eine Anleitung, neu aus dem Handbuch |
| `LISTE-DURCHSPIELBOGEN` | Vorlage der Kotlin-Zeit, 26.1 ruht | – |
| `LISTE-FIGURENKATALOG-649` | sagt selbst: nach dem Bau nach `alt/` | erst nach dem Bau von 649 |
| `LISTE-SIMULATION-444` (43 KB) | Rechnung 01./02.11., Zahlen im BRS | erst nach 481 (rechnet noch mit Abschnitt 6) |
| `LISTE-BESTIARIUM` | geht im Figurenkatalog 649 auf (entschieden) | erst nach 649 und 481: `tools/sim444/sim.py` und `werte.json` lesen es noch |
</details>

<details><summary>B · Kapitel 2 in eigenen Ordner <code>docs/kapitel2/</code>, 6 Dateien</summary>

`STORY-K2-ENTWURF` (32 KB), `STORY-PLAN-K2`, `STORY-K2-LANDKARTE` (mit `STORY-K2-LANDKARTE.svg` und `STORY-K2-KARTE.svg`), `STORY-WAHLEN` („kein Bau vor dem Meilenstein“). Seit 19./20.10. unverändert; gilt erst nach Kapitel 1.
</details>

<details><summary>C · Zusammenlegen, je Thema eine Datei (7 Dateien weniger)</summary>

1. **BRS umbenennen:** `DESIGN-SPIELSYSTEM-2-0-ENTWURF` ist die gültige Fassung und heißt „Entwurf“. Neu `DESIGN-BRS.md`; 17 Dateien außerhalb der Archive nennen den Namen (CLAUDE.md, 12 Notizen, `tools/regelcheck.py`, `tools/sim444/`, Kommentar in `godot/regeln/brs_kampf.gd`), alle im selben Schritt; `regelcheck.py` liest den Pfad, ohne Nachziehen bricht die Prüfung. Den Godot-Kommentar zieht Jerry nach.
2. **Fremde Inhalte:** `LISTE-CC0-MODELLE` in `LISTE-QUELLEN` (aus 650.1 beschlossen, offen bei mir mit 623.1). `LISTE-BESTAND` (was wir haben) und `LISTE-EFFEKTE` (wo es hinkommt) bleiben getrennt.
3. **Alt gegen neu:** `LISTE-UMZUG-348` (54 KB) und `LISTE-ABGLEICH-ALT` (35 KB) prüfen beide die alte Fassung gegen Godot. Abgleich wird die eine Liste je Ort und Figur; vom Umzug bleiben die Grundsätze (Modellregel, Messlatte), Rest nach `alt/`. Gegenprüfung vorher, weil beide Prüfer in 650.1 „Umzug bleibt“ sagten.
4. **Story-Überblick (Homer):** `STORY-PLAN`, `STORY-ROTER-FADEN`, `STORY-PLAN-K1` (Ist-Stand Kotlin, 12.10.), `STORY-K1-HANDLUNG`, `STORY-CHRONIK-TEXTE-K1`: fünf Dateien für eine Geschichte. Ziel zwei: Überblick aller Kapitel, Handlung Kapitel 1. Texte wortgetreu, nur umziehen.
5. **Spielerhandbuch (Homer):** Teile 1–3 zu einer Datei; dabei gegen das BRS halten (seit 03.11. nicht nachgezogen, BRS zweimal geändert).
6. **Spieltexte Kampf und Menü (Homer):** `STORY-SPIEL` bleibt ganz; Godot nutzt die Texte (Stichprobe: „entgeht dem Zauber“, „ist gesegnet“, „Zweiter Atem“). Die Grenze „15 KB“ im Kopf ist eine Lesegrenze vom 18.10., keine Technik; sie fällt. Veraltet sind nur SRD-Namen (Zweiter Atem, Kleriker, Schurke, Rettungswurf) und Verweise auf Kotlin-Dateien; Homer gleicht die Namen ab. Ebenso `STORY-MENUE` (im Kopf noch `MenuScreen.kt`): bleibt, ins Inhaltsverzeichnis, Kopf auf Godot.

Nicht hier, weil 745 sie führt: `LISTE-BAUEN-TESTEN` und `LISTE-CHECK-BUILD-TEST`, `ROLLE-PRUEFUNG` und `LISTE-PRUEFUNG`.
</details>

**D · Die Wochenend-Dateien:** vom 31.10./01.11. gilt das BRS (umbenennen, C1); Sammlung 2.0 nach `alt/`; Simulation und Bestiarium nach `alt/` erst nach 481 und 649; Handbuch zusammenlegen (C5); `LISTE-GEGENSTAENDE`, `LISTE-NETZE`, `STORY-LEHRMEISTER-K1`, `STORY-RUF-K1` bleiben (die beiden letzten ins Inhaltsverzeichnis). Vom 07./08.11. bleiben `LISTE-ABGLEICH-ALT` (bis jede Zeile geprüft ist), `LISTE-GLOSSAR`, `LISTE-KOSTEN`, `LISTE-QUELLEN`, `LISTE-EFFEKTE`.

**E · Gliederung, zwei Möglichkeiten:**
- **Variante 1, Ordner nach Leser:** `spiel/` (DESIGN, STORY, Spiel-Listen), `firma/` (ROLLE, ARBEIT, Handwerk), `archiv/`, `alt/`, `kapitel2/`. Auf GitHub fünf Ordner statt 84 Dateien.
- **Variante 2, flach lassen (Vorsilben wie heute):** dazu `kapitel2/` und `alt/`. `docs/README.md` bekommt oben „Für den Chef“ mit etwa 8 Dateien und je Datei einen Satz „wofür, wer liest wann“. Ein Werkzeug meldet jede Datei ohne Zeile und jeden toten Link.

## Auswertung

- **Stärkstes Gegenargument zu Variante 2:** auf GitHub siehst du weiter eine lange Liste, das Inhaltsverzeichnis musst du erst öffnen. **Antwort:** Variante 1 bricht Pfade in Werkzeugen, Haken und Startbefehlen (allein `LISTE-VORGAENGE` steht in 18 Werkzeugdateien) und ist Arbeit an Abläufen, nicht am Spiel. Die Vorsilben gliedern schon. Nachholen kann man es, wenn Kapitel 1 abgenommen ist.
- **Gegen A:** eine Datei in `alt/` liest keiner mehr; steht darin noch eine gültige Regel, geht sie verloren. **Antwort:** je Datei „vorher“ erledigen und gegenprüfen lassen, wie bei 650.1.
- **Die drei großen Archive** (`VORGANGSARCHIV` 426 KB, `LISTE-VORGAENGE-ARCHIV` 132 KB, `PRUEFBERICHT-ARCHIV` 77 KB) liest kein Mensch, aber Werkzeuge durchsuchen genau diese Pfade: **noch nicht** teilen.
- **Kosten:** A, B und C1–C3 etwa eine Sitzung Perikles plus eine von mir; C4–C6 macht Homer, wenn er ohnehin an den Texten arbeitet.

## Folgerungen

„650.2 wie Vorschlag“: Perikles verschiebt A und B, benennt C1 um (Werkzeuge im selben Schritt) und baut das Inhaltsverzeichnis mit Prüfwerkzeug (E2). Ich mache C2 und lasse C3 gegenprüfen. C4–C6 trage ich für Homer in `LISTE-IDEEN.md` ein, kein Vorgang vor Kapitel 1. Abweichend geht je Teil, etwa „A ja, C3 nein, E 1“.

Antwort: „650.2 wie Vorschlag“ oder je Teil.
