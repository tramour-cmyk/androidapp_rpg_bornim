# Checkliste MARS

Ein Blick: was im Kampfsystem MARS steht, was fehlt, was zwischen klassischem Kampf und MARS noch zu übertragen ist (296, Chef 22.10.). Je Zeile ein Punkt, Verweis auf den Vorgang; ohne Vorgang ein Satz, was es soll. Kein Stand im Wortlaut, der steht im Vorrat. Pflege: Team Jerry, bei jedem zusammengeführten Build.

Zeichen: ✓ umgesetzt (auf `main`) · ◐ gebaut, wartet auf Test · ○ offen · – gewollt nicht

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
| Zustände (Gift, Brand, Blutung, Betäubt …) mit Rundenzähler | ✓ | ○ nur Festgehalten, Liegend, Gift; ohne Anzeige | 296.2 |
| Zustände am Gegner gezeichnet | ✓ | ○ | 296.3 |
| Kampfblende mit Text, Ladebalken | ✓ | ✓ | 24.6 |
| Ziel tauscht nach hinten: vorderer wird angegriffen, mit Nachteil | – | ✓ | 301 |
| Eröffnung (Hinterhalt, Held zuerst) | ✓ | ○ | 296.2 |
| Fliehen | ✓ | ○ | 296.2 |
| Trank, Zauber, Abwehr | ✓ | ✓ | 249 |
| Fehlschlag sichtbar (Ausweichen) | ✓ | ✓ | 249 |
| Klang je Treffer, Biss, Zauber | ✓ | ✓ | 249 |
| Siegesmusik | ✓ | ✓ | – |
| Siegerpose, letzter Schlag inszeniert | ✓ | ○ | 296.3 |
| Beute, Erfahrung, Stufenaufstieg | ✓ | ○ (Probekampf ohne Beute) | 296.2 |
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

Gegen den Code geprüft am 23.10., 12:36 (Jerry, 296.1; `main` bis B81, Zweige 333, 335–337). In keinem der beiden Systeme gibt es Schadenszahlen oder Musik bei einer Niederlage.
