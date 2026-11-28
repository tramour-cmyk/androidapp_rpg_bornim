# Chroniken von Bornim / Chronicles of Bornim

Ein düsteres Rollenspiel mit eigener Geschichte und taktischem Kampf in einer 3D-Welt, die du drehen und zoomen kannst. Von Anfang an fürs Handy gebaut, erzählt in Kapiteln rund um das Dorf Bornim (ab 16), auf Deutsch und Englisch. Den Anfang macht „Der Blutzahn-Stamm“.

- **Du wirst, was du tust.** Keine Klasse zu Beginn: Was du benutzt, wird besser; am Ende jedes Rangs wartet eine Prüfung. Die Regeln sind unser eigenes Bornimer Rollenspielsystem (BRS).
- **Jeder Kampf ist eine Entscheidung.** Der Gegner zeigt, was er vorhat: Der Wolf duckt sich zum Sprung, der Hauptmann holt aus. Du antwortest mit Angriff oder Abwehr, und im Moment des Schlags weichst du selbst aus, parierst oder hebst den Schild.
- **Eine Welt voller Details.** Das Gras wiegt sich im Wind, Hühner und Kaninchen laufen vor dir davon, und jedes Tier hört man erst, wenn man näher kommt. Nachts reicht der Blick nur so weit wie das Licht, Nebel liegt über der Wildnis, und die Monster siehst du kommen.
- **Fair.** Keine Werbung, keine Beutekisten, keine Wartezeiten; grinden darf man, muss man nie.

**Download:** [bornim.apk (neueste Version)](https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/latest/download/bornim.apk) · [Leitbild](docs/DESIGN-LEITBILD.md) · [Änderungshistorie](CHANGELOG.md) · [Notizen](docs/README.md) · [Ideen](docs/LISTE-IDEEN.md) · [Stil](docs/DESIGN-STIL.md) · [Entwicklung](docs/DESIGN-ABNAHME.md) · [Regeln (BRS)](docs/DESIGN-BRS.md) · [Projektplan](docs/PROJEKTPLAN.md)

## Features

**Geschichte**

- **Kapitel 1: Der Blutzahn-Stamm** – Dorf Bornim, Flüsterwald, Blutzahnhöhle, Krogg der Grobian, Hauptmann Grak, die Rettung von Schwester Lyra und ein Cliffhanger um den „Grauen Propheten“
- **Aufträge am Aushang** neben der Hauptgeschichte; die Chronik „Bisher geschehen“ hält fest, was war; schwarze Blenden mit kurzem Erzähltext zwischen Orten und vor Kämpfen

**Welt**

- **Tag und Nacht**: dunkle Nächte, Fackelschein um den Helden, erleuchtete Fenster. Nachts kommen die Untoten in den Wald
- **Nebel über der Wildnis**: man sieht nur, was der Held sieht; das Land deckt sich beim Gehen auf
- **Klang und Musik**: Geräusche aus echten Aufnahmen, düstere orchestrale Musik; man hört, was in der Nähe ist
- **Sichtbare Monster** streifen durch Wald und Höhle. Wer von hinten angreift, schlägt zuerst; wer sich erwischen lässt, gerät in einen Hinterhalt
- **Rast und Vorrat**: Kräuter sammeln, Fleisch am Lagerfeuer braten, Tränke bei Kräuterfrau Morwen, ein Zimmer im Gasthaus; wer zu tief in den Met schaut, kämpft schlechter

**Held**

- **Keine Klasse**: sechs Grundwerte, fünf Völker (Mensch, Elf, Zwerg, Hügelvolk, Orkblütiger) und eine Herkunft wie Wachsoldat oder Jägerkind, oder keine (Wanderer)
- **37 Fertigkeiten**: was du im Kampf gebrauchst, wird besser; am Ende jedes Rangs wartet eine Prüfung
- **Heldenstufe** durch Erfahrung aus Kämpfen und Fertigkeiten; jedes Kapitel setzt eine Grenze

**Kampf**

- **MARS**, unser Kampfsystem: Meisterschaft, Absicht, Reaktion, Stellung. Du siehst, was der Gegner vorhat, und antwortest darauf
- **Aufstellung in Reihen**; Abwehr durch Ausweichen, Parieren oder Schild; Zauber der Evokation, der Heil- und der Schutzmagie
- **Monster mit Schwächen und eigenen Fähigkeiten**, Rudel mit Anführer, Bossgegner; Gift, Brand und Blutung
- **Kampforte in 3D**: Gefallene stürzen, wie es die Wucht will; Blut einstellbar

**Beute**

- **Ausrüstung mit Güte und Seltenheit**: sechs Seltenheitsstufen, je Kapitel gedeckelt; ein Laden mit wechselndem Sortiment

**Bedienung**

- **Für Touch gebaut**: Ziehen lenkt den Helden, Tippen läuft zum Ziel und spricht, öffnet oder liest
- Vier Spielstände, Sprachwechsel jederzeit im Spiel

## Aufbau

| Ordner | Inhalt |
|---|---|
| `godot/` | das Spiel in Godot 4: Regeln nach BRS (`regeln/`), Kampf und Kampforte (`kampf/`), Welt, Oberfläche, Daten; Tests unter `godot/tests/` |
| `tools/` | Werkzeuge: Modelle bauen (Blender), Karten, Gegenstände, Klang, Regelsimulation (`tools/sim444/`), Prüfungen |
| `docs/` | Notizen: Leitbild, Stil, Regeln, Geschichte, Abläufe (Inhalt in `docs/README.md`) |
| `core/`, `app/`, `tools/preview/` | alte Fassung in Kotlin, wird entfernt |

## Bauen

```bash
tools/t logik                                  # Kerntest: der Godot-Logiksatz (godot/tests/logik.txt)
(cd godot && godot --headless --import --path .)   # Godot-Projekt einlesen
```

Der GitHub-Actions-Workflow `.github/workflows/godot.yml` baut Modelle und Karten, prüft alle Tests und baut die APK; er stellt sie als Artefakt bereit.

## Lizenzen

© BornWire TCS 2026

Geschichte, Orte, Figuren und Grafiken sind eigene Werke. Schriften: Alegreya (SIL Open Font License 1.1, siehe `godot/kampf/schrift/OFL-Alegreya.txt`) und Fondamento (SIL Open Font License 1.1, siehe `godot/daten/OFL-Fondamento.txt`). Klänge: freie Aufnahmen (CC0); Musik: freie Stücke (CC0); Quelle und Urheber je Datei in `tools/klang/QUELLEN.md`.
