# Abnahme Kapitel 1: Meilenstein und Wochenziel

**Oberste Direktive (Chef 31.10., Archiv 418):** Kapitel 1 in der Godot-Fassung mit Spielsystem 2.0 fertigstellen: ohne technische Fehler, gut aussehend, nach unserer Signatur, düster, professionell und immersiv durch Klang, Musik, Kampfsystem und die Möglichkeiten des Spielers. Qualität vor Quantität und vor Eile; es gibt keinen Termin. Fertig ist, was die Abnahmeliste erfüllt. Geht jeder Kür und jedem Neuen vor.

**Meilenstein „Kapitel 1 fertig“** = jeder Punkt der Abnahmeliste unten abgehakt; danach **„marktreif“** (338): Kapitel 1 öffentlich im Play Store (Block S). Was unter die Abnahmeliste fällt, ist Muss; Kapitel 2, Berufungen, Gruppenkämpfe, Dungeons erst danach. Abhaken darf nur, wer in der Zeile als Prüfer steht; „Chef“ heißt: erst nach seinem Wort. Liest Ford beim Start (Wochenziel); sonst nur bei Anlass.

## Abnahmeliste Kapitel 1 (418; abgenommen vom Chef 01.11., 09:43, Umfang A mit zwei Zusätzen, Archiv 418)

Zahlen in Klammern = Entscheidung in `DESIGN-SPIELSYSTEM-2-0.md` („E 7“) oder Vorgang; was gilt, steht im Nachschlagewerk `DESIGN-SPIELSYSTEM-2-0-ENTWURF.md` („NW 5“ = Abschnitt 5; E 84). Gilt nur, was entschieden ist; neue Entscheidungen gehen hier ein. Alle Zahlen sind Startwerte; abhakbar mit Zahlen erst nach der Rechensimulation (444). Termine gibt es keine; Wochenziele nennen Reihenfolge und Schätzung, keine Tage je Punkt.

**T Ohne technische Fehler**
- [ ] Kein Absturz, kein Hängenbleiben, kein Ruckeln auf den Testgeräten des Chefs (Handy und Tablet, 267); Spielstände halten über Updates.
- [ ] Kollision und Sprungtest 0 in jedem Ort; kein Schweben nach Start und Kartenwechsel (24); Tippen trifft, was gezeichnet ist.
- [ ] Kerntests der Regeln 2.0 als GDScript-Tests grün; Zufallsspieler spielt Kapitel 1 im neuen Spiel durch (26).
- [ ] Jeder Fehler aus den Tests des Chefs behoben (Prüfer: Chef).

**A Aussehen und Signatur**
- [ ] Jeder Ort „Ort fertig“ nach `DESIGN-ABNAHME.md`, sinngemäß in Godot: Dorf, Räume, Flüsterwald, Tiefer Flüsterwald, Blutzahnhöhle.
- [ ] Jede Figur, jedes Haus, jedes Ding in `LISTE-UMZUG-348.md` auf „abgenommen“ (Prüfer: Chef; Diogenes misst nebenher, 373).
- [ ] Signatur nach `DESIGN-STIL.md`: schwarz-gold, Tusche, düster und lesbar; Hauptmenü, Erschaffung, Menüs, Vorspann und Zwischenbilder im selben Look (Prüfer: Chef).

**K Klang und Musik**
- [ ] Musik je Ort, Tageszeit und Kampf; Umgebung aus echten Aufnahmen je Ort.
- [ ] Schritte je Untergrund (74), Raumklang in Innenräumen und Höhle (119), Stimmen der Gegner (18); bisher „wenn Zeit ist“, jetzt Muss, weil die Direktive Klang nennt (Prüfer: Chef).

**M Kampfsystem**
- [ ] MARS und klassischer Kampf (212 A, 249) rund auf den Regeln 2.0: Kampf ohne W20 nach Stufen (E 7), jeder Angriff sichtbar, Ansage harter Schläge, Pechsträhne.
- [ ] Kampf nie langweilig, echte Wahl (`DESIGN-LEITBILD.md`); Schwierigkeitsgrade (39).
- [ ] Neue Monsterwerte für Kapitel 1 nach 2.0 auf Rechenmodell D (E 73–75, NW 7).
- [ ] Ausgleich gemessen, nicht geschätzt: Simulation „Zeit bis Stufe“ und Kapitelsimulation auf den Regeln 2.0 (444); jede Herkunft und der Wanderer schaffen die Bosse in vergleichbarem Maß; Zielwert mit dem Chef festlegen (38).

**G Spielsystem 2.0, Kern in Kapitel 1** (E 60; Umfang A, Chef 01.11., 09:43; Ruf, Alchemie als Handwerk, Abnutzung, Angeln, Jagd, Tiere beruhigen erst in späteren Wellen auf sein Wort)
- [ ] Ohne Klassen (E 1): Erschaffung mit sechs Grundwerten ab 1, 21 Punkte, jeder Wert 3 bis 8 (E 77); fünf Völker mit Bonus, Malus und Merkmal, Volk hebt bis 9, nie unter 3 (E 70, 72, 78); Herkunft freiwillig oder Wanderer, Startfertigkeiten bei 10 (E 68, 69; NW 2).
- [ ] Fertigkeiten steigen durch Tun, Wert 0–100 in vier Rängen, am Rangende Halt mit kleinem Puffer bis zur Prüfung (E 67, E 44); Kapitel 1 bis Geselle (49) mit Bewährungsproben zum Gesellen (Takt, NW 5); Prüfregel und die 37 (E 59); Hinweis beim Aufstieg, Heldenblatt zeigt nur Getanes (NW 3).
- [ ] Heldenstufe aus Erfahrung (E 16), höchstens 40 % aus Fertigkeitsaufstiegen (E 17); Kapitelgrenze weich bis zwei Stufen darüber (E 18, E 35); Erfahrungstopf je Gebiet, Wiederkehrer geben kaum Erfahrung, aber Beute (E 19, E 21).
- [ ] Lehrmeister spricht an, sobald zwei Kernfertigkeiten eines Pfads Geselle sind; Anwärter möglich, Prüfungen erst ab Kapitel 2 (E 63, E 79; Takt NW 5).
- [ ] Jede Herkunft hat in Kapitel 1 eine Handlung (Chef 01.11., 09:43): Wachsoldat, Jägerkind, Zauberlehrling, Klosterschüler, Herumtreiber im Kampf und mit Schleichen und Spähen; Kräutersammler: Kräuter sammeln und ein Rezept Heiltrank; Schmiedelehrling: Reparieren bei Borin.
- [ ] Schleichen mit Schleichtaste und Hinterhalt, Bosse wachsamer (E 55, E 47); Spähen durch Verweilen findet Fallen, Kräuter, Truhen, Wahrnehmung verstärkt (E 57, E 83), dann entschärfen; Truhen mit Dietrich, Truhen in Häusern der Leute zu (E 55, E 46); schwere Rüstung sperrt Schleichen, Metall sperrt Evokation, Illusion, Beschwörung (E 33, E 80); kein Stehlen, kein Barde (E 30, E 31).
- [ ] Kurze Erholung 2 h, Langes Ausruhen 9 h (E 26); Tragkraft mit Nimmersatt-Beutel, darüber langsamer (E 41).
- [ ] Namen nach dem Glossar, keine SRD-Begriffe im Spiel (E 24, E 25, E 27; NW 12; `regelcheck` zählt die Reste, 446).
- [ ] **Bauweise für spätere Wellen** (Chef 01.11., 09:43): Leute, Orte und Gegenstände haben beim Bau leere Datenfelder für Ruf, Rezept und Zustand; jede Zahl steht in einer Datendatei, nicht im Code (422, 444).

**W Möglichkeiten des Spielers**
- [ ] Jeder Ort, jede Hauptquest und Nebenquest, jedes Gespräch, Laden, Anschlagbrett, Tagesablauf, Hilfe aus dem alten Spiel geht in Godot mindestens so (`LISTE-UMZUG-348.md`, 348.9), außer was 2.0 ersetzt.
- [ ] Englisch durchgehend (Homer, Tom).
- [ ] Spielerfreundlich (`DESIGN-LEITBILD.md` 3): auf „Normal“ ohne Grinden schaffbar.
- [ ] **Durchgespielt:** der Chef spielt Kapitel 1 einmal ganz durch und sagt „gut“ (Prüfer: Chef).

**S Store (danach, für „marktreif“)**
- [ ] Store-Seite, Texte und Bilder (Homer, Sokrates); Impressum (Datenschutzseite online, 252); Gewerbeschein und Preis (142, 45); Repo privat (109); 12 Tester, geschlossener Test 14 Tage, Prüfung durch Google.

## Stand zum Marktstart (338.1; Perikles: montags ganz, täglich neu; als Seite: [Dashboard](https://claude.ai/artifact/5gdqbHNUUpbBUU9sBo4i7t), 339)

**Stand 01.11., 00:15: gelb. Seit 31.10. gilt deine neue oberste Direktive: kein Termin, fertig ist, was die Abnahmeliste oben erfüllt.** Die Liste liegt dir zur Abnahme vor (Chefsache 418); bis zu deinem Wort ampeln wir nach ihrem Entwurf, Block für Block. Das spielbare Godot-Spiel (Dorf und Waldkampf, 399) hast du am 31.10. gegen 20:40 mit Build 143 getestet; von deinen neun Befunden (416) ist einer abgenommen, vier sind gebaut, einer in Arbeit, drei offen (einer davon Kür). 15 neue Änderungen (Tom 7, Jerry 8) warten auf den nächsten gemeinsamen Build; höchstens 6 je Build (317), also mindestens drei Builds. Dazu 5 Punkte aus Build 143, die du noch abnimmst (Spielfassung, Innenräume, Klang, Dorf, Kampfort). Das alte Regelwerk ruht auf dein Wort („keine Energie mehr in das alte SRD-System“, 424); Spielsystem 2.0 ist als Nachschlagewerk beschrieben (Entscheidungen bis 75, Sokrates gleicht ab, 422; Diogenes liest quer, 441), gebaut wird es erst nach deinen Antworten zu den offenen Entwürfen (413a) und zum Umfang für Kapitel 1 (418). Kein Block ist rot; die meisten warten auf diese beiden Antworten.

**Heute für dich:** steht immer aktuell in der [Chefsache-Übersicht](chefsache/README.md) (Entscheiden, Billigen, Ansehen, Testen, Tun); ein Werkzeug schreibt sie bei jedem Push, keiner von Hand (275).

**0. Meilenstein Umzug** (jetzt Teil von Block W): die Umzugsliste `LISTE-UMZUG-348.md` hinkt der Spielfassung nach und wird Mo 02.11. mit Wochenziel 2 neu gezählt; ihre Zeilen zum alten Regelwerk ruhen (424).

**1. Stand je Block der Abnahmeliste** (Ampel; Termine gibt es keine, Reihenfolge und Schätzung kommen mit Wochenziel 2 am Mo 02.11.)

| Block | Ampel | warum (Vorgänge) |
|---|---|---|
| T Ohne technische Fehler | gelb | Build 143 lief bei deinem Test. Gebaut: Tasten in der Erschaffung (416.1), Platzwechsel mit Dorfbewohnern (416.2), Kampflog schließt (416.5), Aktionsknopf am Tresen (416.7); offen: Rennen „wie Hochsprung“ (416.4), Leute drehen sich zum Helden (416.8), Fußspuren (416.6, Kür). Menü System abgenommen, Testmenü bekommt Icons (425). Tests und Zufallsspieler (ein Programm, das Kapitel 1 selbst durchspielt) auf den Regeln 2.0 gibt es erst, wenn 2.0 gebaut wird. Tablet (267) bei deinem nächsten Tablettest. |
| A Aussehen und Signatur | gelb | Bei dir zum Ansehen, jeweils nur „passt“ oder was anders sein soll: Held im Kampfort wie im Dorf (Film 403; Bewegung „gut“, 23:31), Waffen in der Hand beim Gehen (Probe Stab, Axt, Bogen, 417); zu entscheiden: Aussehen der Völker (430). Innenräume wie alt (399.5) sind in Build 143. Feinschliff der Tuschelinien ruht, bis das Spiel steht (348.13b). |
| K Klang und Musik | gelb | Tierlaute (401), Blende und Herzschlag vor dem Kampf (402) sind gebaut und kommen mit dem nächsten Build. Musik je Ort und Tageszeit, Schritte je Untergrund, Raumklang: noch nicht begonnen. |
| M Kampfsystem | gelb | Die Kampfbewegungen des Helden gefallen dir (403); offen aus deinem Film: Wölfe gleiten (438), Neuformation vor dem Tod (439), Wolf stirbt ohne Animation (440), alle bei Jerry. Kampf auf den Regeln 2.0 (Stufen statt W20) beginnt nach 413a. |
| G Spielsystem 2.0 | gelb | Nachschlagewerk gilt (Entscheidungen bis 84, 01.11.); Umfang für Kapitel 1 entschieden: nur der Kern, dazu leere Datenfelder für spätere Wellen und je Herkunft eine Handlung (418, 01.11., 09:43). Rechensimulation läuft (444). Gebaut ist davon noch nichts; der Bau wird mit Wochenziel 2 am Mo 02.11. auf Tom und Jerry verteilt. |
| W Möglichkeiten des Spielers | gelb | Spielbar: Hauptmenü, Erschaffung, Spielstände, Dorf mit Schenke, Laden, Ältestem und Tempel, Anschlagbrett, Rast, Waldkampf gegen das Wolfsrudel; Laden „Verkaufen“ wird nachgebessert (416.9, Spike, der Zusatzentwickler bei Tom). Englisch durchgehend: offen. |
| S Store | gelb | Konto und App angelegt, Datenschutzseite online (252). Der Weg zum Store: Gewerbeschein, dann das Repo auf privat stellen (109), dann der Aufruf für die 12 Tester (vorbereitet, 142.3), dann 14 Tage geschlossener Test. Bei dir: Gewerbe-Neuanmeldung korrigieren und absenden (Zu tun 142). |
**2. Ausgaben**
- **Echtes Geld:** das Max-Abo in der größeren Stufe (seit 25.10.); Nutzungsguthaben 0 $, nichts nachgekauft.
- **Wochenguthaben Max:** seit Samstagabend 31.10. eine neue Woche; dein letztes Bild der Nutzung ist vom 27.10. Wie viel der neuen Woche verbraucht ist, zeigt nur ein neues Bild von dir. Es gilt deine Entscheidung vom 22.10. (287): nicht sparen, nichts nachkaufen; ab 80 % startet Ford nur Muss.
- **Wofür (gebucht seit dem letzten Stand 29.10., 01:05, nur beendete Sitzungen):** 263 $ in 20 Sitzungen. Davon auf Vorgänge gebucht 238 $, nach ihrem Besitzer: Tom 80 $, Jerry 60 $, Homer 3 $, Perikles 80 $ (davon 56 $ aus Sokrates' Chefrunde, die auf 433 und 437 gebucht ist), Diogenes 12 $, Rest 4 $. Anteil Spiel so gerechnet etwa 60 % (Ziel ab 02.11.: 70 %). Die genaue Zählung nach Rollen macht Diogenes montags.

**3. Risiken und Gegenmittel**

| Risiko | Folge | Gegenmittel (wer) |
|---|---|---|
| Bau wartet auf dich | ohne deine Antworten zu 418 (Abnahmeliste, Umfang von 2.0) und 413a (offene Entwürfe) beginnt kein Bau der neuen Regeln, Blöcke M und G stehen still; ohne 430 (Aussehen der Völker) wartet Toms Modellarbeit (431); 442 (welches Modell in welcher Sitzung) ist ebenfalls offen | 418, 413a, 430, 442 beantworten (du); bis dahin Befunde aus Build 143 und dem Film 403 (Tom, Jerry) |
| Ford-Kette am Ende | Ford, der die Teams startet, startet sich selbst neu; nach 8 Neustarts muss ihn jemand von Hand starten; jetzt 6 | Ford einmal von Hand starten, erste Nachricht „Ford“ (du, Chefsache 110) |
| Builds stauen sich | 15 neue Änderungen, höchstens 6 je Build (317): mindestens drei Builds, jeder mit deinem Test | Jerry stellt morgens ab 7 Uhr den gemeinsamen Build zusammen (Ford startet ihn); du testest in der Reihenfolge der Testbitten |
| Plan ohne Schätzung | Termine gibt es nicht mehr; ohne Schätzung siehst du nicht, wie weit Kapitel 1 ist | Mo 02.11. Wochenziel 2: Reihenfolge und Schätzung je Block (Tom, Jerry, Perikles) |
| Gewerbeschein kommt spät | die frühere Anmeldung kam nie an; ohne Schein kein Preis, kein Zahlungsprofil, kein privates Repo, kein Tester-Aufruf | Neuanmeldung (Formular GewA 1) korrigieren und absenden, nach drei Werktagen nachfragen (du, Zu tun 142); den Rest so vorbereiten, dass nur noch die Angaben fehlen (Sokrates) |
| Anschrift vor dem Zahlungsprofil | Google zeigt die Anschrift öffentlich | Wohn- oder Geschäftsanschrift (Büroservice) vor dem Zahlungsprofil entscheiden (du, Sokrates) |
| Guthaben knapp | in der letzten Woche Stillstand ab Donnerstagnacht bis Samstagabend | ab 80 % nur Muss (287); ein Bild der Nutzung von dir zeigt den Stand |
| „Gut“ hat kein Ende | ohne Termin fehlt die natürliche Grenze; seit dem Umzug 4 bis 13 Bilderrunden je Figur oder Karte | nur du urteilst, nach genau einer Fehlerprüfung, höchstens ein Blatt je Modell und Runde (373); Feinschliff kommt ans Ende |
| 12 Tester fehlen | Pflichttest kann nicht beginnen; der Aufruf geht erst nach Gewerbeschein und privatem Repo raus | Aufruf ist vorbereitet, Organisationskonto geprüft (142.3, Sokrates); hängt an deiner Neuanmeldung |

Dazu, ohne Vorgang (Perikles vergibt Nummern mit Wochenziel 2): Englisch durchgehend (Homer, Tom); Spielstände über Updates (Tom); Store-Texte und Bilder (Homer, Sokrates).

**Reihenfolge** (ohne Datum; Google: neues privates Konto braucht 14 Tage geschlossenen Test mit 12 Testern, dann Prüfung, etwa eine Woche):

| Schritt | was |
|---|---|
| erledigt | Konto angelegt (142) ✓ 23.10.; spielbare Godot-Fassung mit Dorf und Waldkampf (399) ✓, Build 143 getestet 31.10. |
| 1 | Abnahmeliste und Umfang von 2.0 (418), offene Entwürfe (413a), Völker (430): du; Gewerbe-Neuanmeldung (142): du; danach Wochenziel 2 mit Schätzung (Perikles) |
| 2 | Regeln 2.0 bauen, Blöcke T, A, K, M, G, W im neuen Spiel abhaken |
| 3 | Fehler und Glätten; Englisch, Geräte, Spielstände; Store-Seite, Impressum; Tester bereit; du spielst Kapitel 1 ganz durch |
| 4 | Chef: „gut“; geschlossener Test 14 Tage (falls nicht schon mit der alten App gelaufen), Antrag, Prüfung durch Google, Marktstart |

## Meilenstein Umzug: „Kapitel 1 auf Godot mindestens so gut wie alt“ (348.9, Chef 25.10., 12:24; seit 418 Teil von Block W der Abnahmeliste)

**Erreicht, wenn** jeder Punkt der Checkliste „abgenommen“ ist, die Kerntests aus `core` als GDScript-Tests grün sind und der Zufallsspieler Kapitel 1 im neuen Spiel durchspielt; danach ersetzt das neue Spiel nach dem Test des Chefs das alte auf `main`. **Checkliste** = Bestandsliste 348.8 samt Funktionen in `LISTE-UMZUG-348.md` (Stand-Wörter dort: –, Entwurf, gebaut, gemessen, abgenommen). Reihenfolge: zuerst das Licht (3486-sonne), dann je Bauart ein Grundmodell (Mensch, Vierbeiner, Vogel, Insekt, Spinne), daraus alle Figuren; Häuser und Dinge parallel; sonst so, wie Kapitel 1 gespielt wird. Jedes Vergleichsblatt misst Diogenes nebenher, als Hinweis an den Chef, kein Tor (373, `ROLLE-PRUEFUNG.md`).

**Stand 01.11.:** neu gezählt Mo 02.11. (oben „0. Meilenstein Umzug“). Die 15 Punkte der Gegenprobe 398 sind geschätzt (Tom 28.10., 15:37; Jerry 13:16, 16,5 Sitzungen), gerechnet wird mit der neuen Schätzung Mo 02.11.

**Tagesziele** (Perikles setzt sie täglich neu; jedes Bild geht nach einer Fehlerprüfung zum Chef, urteilen tut nur er, 373): bis 29.10. und die Termine je Block (338, 348.14) in Git, Stand vor „Perikles: 418“; sie ruhen mit der Spielfassung 399 und werden mit Wochenziel 2 auf die Abnahmeliste neu gerechnet (398).

## Wochenziel 26.10.–01.11. (Perikles, gesetzt 25.10., 02:10; Umzug Woche 1 beginnt schon 25.10.; Wochenziel 18.–24.10. in Git)

**Umzug Woche 1 steht: das Dorf Bornim läuft in Godot am Handy, ein Kampf gegen das Wolfsrudel mit den echten Regeln auch, und die Bestandsliste nennt alles, was umziehen muss; danach neue Schätzung des ganzen Umzugs.** Plan und Regeln: `LISTE-UMZUG-348.md`. Muss (M) sind nur diese Vorgänge; das alte Spiel ruht ganz (348), alles andere ist diese Woche Kür oder ruht (126). **Geprüft Mo 26.10., 07:10 (Perikles):** Inhalt bleibt; Muss-Anteil seit Samstagnacht 89 % der gebuchten Kosten (Ziel 70 %); Entwicklung 71 % (nach Vorgängen; Anteil Spiel nach Rollen zählt Diogenes am 02.11.). Geändert: die Schätzung ist jetzt Vorgang 348.14 und steht in beiden Team-Vorräten vor jeder weiteren Bilderrunde, weil ohne sie weder Wochenziel 2 noch Termine je Block gehen.

| Vorgang | Wer | fertig, wenn |
|---|---|---|
| 348.6 Grundgerüst und Dorf | Tom | APK am Handy; Vergleichsbild Dorf alt/neu an den Chef (Diogenes misst nebenher, 373) |
| 348.7 Modellregel und Wolfskampf | Jerry | Modellregel in `LISTE-UMZUG-348.md` ✓ 25.10.; APK am Handy, Vergleichsbild Kampf alt/neu an den Chef |
| 348.8 Bestandsliste | Tom, Jerry | Liste in `LISTE-UMZUG-348.md` vollständig, jede Zeile mit Quelle im Code ✓ 25.10. |
| 348.9 Modelle jetzt | Tom, Jerry, Homer, Diogenes | Grundmodelle je Bauart als Entwurf beim Chef; Homers Stimmung je Ort gebilligt; Diogenes misst jedes Vergleichsblatt (Meilenstein Umzug oben) |
| 348.14 neue Schätzung | Tom, Jerry, dann Perikles | je Punkt der Checkliste im eigenen Bereich: Sitzungen und erwartete Bilderrunden bis „gebaut“, in `LISTE-UMZUG-348.md`; ✓ 26.10. (Tom 79 S, Jerry 95 S); Termine je Block oben, Wochenziel 2 unten |
| 142 Store-Vorbereitung | Chef, Sokrates | Ausweis- und Telefonprüfung; vom Ruhen ausgenommen |

**Oberste Direktive:** seit 31.10. die neue (oben, 418); was im alten Spiel geht, muss im neuen mindestens so gehen (Block W), außer was Spielsystem 2.0 ersetzt. Neue Fehler des Chefs kommen als Muss dazu.

**Guthaben:** Max seit 25.10. in der größeren Stufe, Woche ab 0 % (25.10., 11:05). Es gilt 287 (Chef 22.10.): nicht sparen; ab 80 % Woche `lauf.py --nur-muss` (Ford), ab 95 % keine neuen Starts außer Rückläufer des Chefs, ab 100 % Stillstand bis Sa 31.10., 20:00; nichts nachkaufen.

## Wochenziel 2: 02.–08.11. (Perikles, vorab gesetzt 26.10., 17:15 nach der Schätzung 348.14; Montag 02.11. mit der Wochenzählung geprüft)

**Überholt seit 418 (31.10.):** die Tage unten widersprechen „es gibt keinen Termin“ und rechnen mit dem alten System; Perikles setzt Wochenziel 2 am 02.11. neu auf die Abnahmeliste (Umfang A seit 01.11., 09:43), mit Reihenfolge und Schätzung statt Tagen.

**Umzug fertig zum Durchspielen: jeder Punkt der Checkliste ist bis Mo 02.11. „gebaut“ (hält nur, wenn du etwa 28 Blätter am Tag ansiehst, 373) und bis Di 03.11. von Diogenes gemessen (Hinweis, keine Bedingung für deine Abnahme); die Kerntests laufen als GDScript-Tests grün, der Zufallsspieler spielt Kapitel 1 im neuen Spiel durch; dann spielst du Kapitel 1 in Godot einmal ganz durch, und deine Fehler sind Muss.** Abnahme der Punkte nach deinem Wort, Feinschliff danach. Das Guthaben ab Sa 31.10., 20:00 reicht beim jetzigen Takt bis etwa Mi 04.11.; was dann offen ist, geht nach dem Stillstand ab Sa 07.11., 20:00 weiter. Messen, GDScript-Tests und Zufallsspieler sind nicht geschätzt. Stärkstes Gegenargument: wird es der späte Termin (seit 338a „B“ Di 03.11., früh; dann hält das Wochenziel nicht), bleibt für deine Fehler aus dem Durchspielen kaum Guthaben in dieser Woche.

Die alte Pflichtliste „Block (a) Kapitel 1 rund“ (altes Spiel) ist seit 418 in der Abnahmeliste oben aufgegangen; Wortlaut in Git, Stand vor „Perikles: 418“.
