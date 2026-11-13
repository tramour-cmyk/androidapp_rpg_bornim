# Checkliste MARS

Ein Blick: was im Kampfsystem MARS steht, was fehlt, was zwischen klassischem Kampf und MARS noch zu übertragen ist (296, Chef 22.10.). Je Zeile ein Punkt, Verweis auf den Vorgang; ohne Vorgang ein Satz, was es soll. Kein Stand im Wortlaut, der steht im Vorrat. Pflege: Team Jerry, bei jedem zusammengeführten Build.

Zeichen: ✓ umgesetzt (auf `main`) · ◐ gebaut, wartet auf Test · ○ offen · – gewollt nicht

## Checkliste

Vor jeder Arbeit an `godot/kampf/` und `godot/regeln/` (823, aus 745 A2; der Haken zeigt sie beim ersten Commit dort).
1. Balance, Spielgefühl und Aussehen entscheidet der Chef; neue Zahlen erst über die Simulation 444 (`tools/sim444`), dann Vorlage an den Chef (`LISTE-UMZUG-BRS.md` Grundsatz 3).
2. Zahlen nur in `tools/sim444/werte.json`, nie als Konstante im Code (649a); vor dem Test nach `godot/daten/` kopieren.
3. Ein Kampfweg: nur der Weg nach dem BRS in `mars.gd`; keine Würfel und kein Maß der alten Trefferpunkte (Grundsatz 2).
4. Messung vor Bau: die Ursache in Vorschau oder Test nachstellen, nie zweimal mit Vermutung bauen (334); Vergleich alt gegen neu mit `tests/sim444_870.gd` und gleicher Zahl Kämpfe, bei Unterschieden unter 10 Punkten mindestens 500 je Zelle (870.6a: 100 täuschten).
5. Ändert sich, wie oft gewürfelt wird, verschiebt sich der Zufall: erst prüfen, ob nur das den Unterschied macht (870.6a, Rudel).
6. Die alte Fassung lesen (`core/…/Battle.kt`), im Commit „Alt: …, übernommen: …, besser: …“ (647).
7. Spieltexte nur von Homer, Namen nach `DESIGN-BRS.md` 12.
8. Vor dem Commit Kerntests (`./gradlew -p core test`, Exit-Code) und die berührten Kampftests (`godot --headless -s res://tests/<datei>.gd`).

## Was MARS kann

| Bereich | Punkt | MARS | Vorgang |
|---|---|---|---|
| Aufstellung | Reihen, Positionswechsel | ✓ | 249 |
| Aufstellung | Springer tauscht mit dem Übersprungenen | ✓ | 285 |
| Bewegung | Gleiten statt Springen, Hieb | ✓ | 249 |
| Bewegung | Schlagdauer in Sekunden (Hieb 0,8 s, Stich 0,6 s), Treffer und Klang am Aufschlag | ✓ | 321.1 |
| Bewegung | vordere Gegnerreihe geht mit Schritten zum Hieb und zurück | ◐ | 337 |
| Gegner | Graks schwerer Hieb: 0,9 s, Axt hält im Aufschlag | ✓ | 320 |
| Abwehr | perfekter Ring: Schurke sticht in den Rücken (verdeckt hinter dem Gegner, 336a), Zeile und Schaden | ◐ | 336 |
| Bildschirm | Knopfzeilen dicht, Rahmen unten geschlossen | ✓ | 335 |
| Bewegung | hinterer Held geht auf der Seite des Ziels vor und zurück | ✓ | 249 |
| Gegner | Absicht im Voraus angesagt, beim ersten Mal als Eingebung erklärt | ✓ | 210 |
| Gegner | Angriffsbild passt zur Absicht (Stich sticht) | ✓ | 249 |
| Gegner | jeder Wolf eines Rudels eigenes Fell | ✓ | 249 |
| Abwehr | Ring zum Antippen (gut, perfekt) | ✓ | 219 |
| Bildschirm | Anordnung, Kampfbericht, Zugleiste | ✓ | 211 |
| Bedienung | „Schnell“: Kampf auswürfeln, Verlusttafel | ✓ | 249 |
| Bedienung | Testzeile (Bewegung, Variante, Bild) | ✓ | 249 |
| Bedienung | Testzeile mit eindeutiger Kennung je Animation, auch klassisch | ✓ | 333 |
| Bedienung | Wechsel „halber Zug“, Züge im Kästchen | – (ruht) | 289 |

## Klassisch ↔ MARS

| Punkt | klassisch | MARS | Vorgang |
|---|---|---|---|
| Sterbebilder der Gegner | ✓ eigene Bilder in Varianten; Puppen und Wölfe bleiben liegen | ✓ eigene Bilder (eine Variante), dann ausgeblendet | 205 |
| Todesschrei der Gegner | ✓ | ○ | 296.3 |
| Gegner flieht vor heiligem Licht oder zerfällt | ✓ | ○ | 296.3 |
| Sturz zu Boden, Aufstehen | ✓ | ✓ | 295 |
| Zoom, Blut, Erschütterung, Zaubereffekte | ✓ | ✓ | 249 |
| Zustände (Gift, Brand, Blutung, Betäubt …) mit Rundenzähler | ✓ | ✓ Godot (`zustaende.gd`); Erklärung beim Tippen ◐ | 296.2, 536 |
| Zustände am Gegner gezeichnet | ✓ | ◐ als Schild über dem Gegner (Aussehen beim Chef) | 296.3, 563 |
| Kampfblende mit Text, Ladebalken | ✓ | ✓ | 24.6 |
| Ziel tauscht nach hinten: vorderer wird angegriffen, mit Nachteil | – | ✓ | 301 |
| Eröffnung (Hinterhalt, Held zuerst) | ✓ | ✓ Godot, dazu Einschüchtern zu Beginn | 296.2, 534 |
| Fliehen | ✓ | ✓ Godot (Knopf „Flucht“, nie vor einem Boss) | 296.2 |
| Trank, Zauber, Abwehr | ✓ | ✓ | 249 |
| Fehlschlag sichtbar (Ausweichen) | ✓ | ✓ | 249 |
| Klang je Treffer, Biss, Zauber | ✓ | ✓ | 249 |
| Siegesmusik | ✓ | ✓ | – |
| Siegerpose, letzter Schlag inszeniert | ✓ | ○ | 296.3 |
| Beute, Erfahrung, Stufenaufstieg | ✓ | ✓ Godot (`lohn.gd`); Lohn nach Monsterstufe ○ | 296.2, 628 |
| Eigene Ausrüstung des Helden (Waffe, Schild oder Fackel, Tränke) | ✓ | ○ fest: zwei Heiltränke, Armbrust, Schwert | 296.2 |
| Wählbar im Spiel: Schalter MARS oder klassisch | – | ○ nur Probekampf im Systemmenü | 296.2, 212 |
| Fackel: Stoß mit Feuerschaden, Tiere verscheuchen | ○ | ○ | 344.2 |
| Testknopf „sofort gewinnen oder verlieren“ | ✓ | ✓ | 272 |
| Söldner kämpft mit | – (Held allein) | ✓ | – |

## Offen

Alle offenen Punkte haben einen Vorgang (Chef 23.10., 18:25 und 18:27, Vorgangsarchiv 341.1a, 344):
- **296.2, Muss zum Marktstart, ab Sa 24.10., 21 Uhr:** Beute und Erfahrung, Fliehen, Eröffnung, Zustände mit Anzeige, eigene Ausrüstung, Schalter.
- **296.3, Kür danach:** Todesschrei, Flucht vor heiligem Licht oder Zerfallen, Zustände am Gegner gezeichnet, Siegerpose.
- **344.2, Kür ab Sa 24.10., 21 Uhr:** Fackel im Kampf (beide Systeme).

Nachgezogen von Sokrates 23.10., 18:29 (Build 83 auf `main`: 320, 333, 335).

Gegen den Code geprüft am 23.10., 12:36 (Jerry, 296.1; `main` bis B81, Zweige 333, 335–337); Spalte MARS für Godot nachgezogen 08.11., 12:1x (Jerry, `main` bis `7b590c3da`; Todesschrei, Siegerpose weiter ○, eigene Ausrüstung ruht mit 534). In keinem der beiden Systeme gibt es Schadenszahlen oder Musik bei einer Niederlage.
