# Abnahme Kapitel 1: Meilenstein und Wochenziel

**Oberste Direktive (Chef 31.10., Archiv 418):** Kapitel 1 in der Godot-Fassung mit Spielsystem 2.0 fertigstellen: ohne technische Fehler, gut aussehend, nach unserer Signatur, düster, professionell und immersiv durch Klang, Musik, Kampfsystem und die Möglichkeiten des Spielers. Qualität vor Quantität und vor Eile; es gibt keinen Termin. Fertig ist, was die Abnahmeliste erfüllt. Geht jeder Kür und jedem Neuen vor.

**Meilenstein „Kapitel 1 fertig“** = jeder Punkt der Abnahmeliste unten abgehakt; danach **„marktreif“** (338): Kapitel 1 öffentlich im Play Store (Block S). Was unter die Abnahmeliste fällt, ist Muss; Kapitel 2, Berufungen, Gruppenkämpfe, Dungeons erst danach. Abhaken darf nur, wer in der Zeile als Prüfer steht; „Chef“ heißt: erst nach seinem Wort. Liest Ford beim Start (Wochenziel); sonst nur bei Anlass.

## Abnahmeliste Kapitel 1 (418; Entwurf Perikles 31.10., Chef nimmt ab: Chefsache 418)

Zahlen in Klammern = Entscheidung in `DESIGN-SPIELSYSTEM-2-0.md` („E 7“) oder Vorgang. Gilt nur, was entschieden ist; offene Fragen dort (413a) gehen hier ein, sobald entschieden.

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
- [ ] Ausgleich: jeder Werdegang schafft die Bosse in vergleichbarem Maß; Zielwert mit dem Chef festlegen (38, bisher je Klasse).

**G Spielsystem 2.0, Kern in Kapitel 1** (E 60)
- [ ] Ohne Klassen (E 1): Erschaffung mit sechs Grundwerten ab 1, 18 Punkte, jeder Wert 3 bis 8 (E 6, E 64); Werdegänge als Starthilfe (E 28, E 29, E 45).
- [ ] Fertigkeiten steigen durch Benutzung (E 2) mit Niveau je Kapitel begrenzt (E 20), am Limit hart mit Puffer (E 44); Prüfregel und Liste (E 59).
- [ ] Heldenstufe aus Erfahrung (E 16), höchstens 40 % aus Fertigkeiten (E 17); weiche Kapitelgrenze (E 18, E 35); Erfahrungstopf je Gebiet, Wiederkehrer geben kaum Erfahrung, aber Beute (E 19, E 21).
- [ ] Wege sichtbar, Berufungen erst ab Kapitel 2 (E 51, E 52); Heldenblatt zeigt nur Getanes (E 65).
- [ ] Schleichen mit Schleichtaste und Hinterhalt, Bosse wachsamer (E 55, E 47); Fallen und Truhen mit Dietrich, Truhen in Häusern der Leute zu (E 55, E 46); schwere Rüstung sperrt Schleichen (E 33); kein Stehlen, kein Barde (E 30, E 31).
- [ ] Kurze Erholung 2 h, Langes Ausruhen 9 h (E 26); Tragkraft mit Nimmersatt-Beutel, darüber langsamer (E 41).
- [ ] Namen nach dem Glossar, keine SRD-Begriffe im Spiel (E 24, E 25, E 27).

**W Möglichkeiten des Spielers**
- [ ] Jeder Ort, jede Hauptquest und Nebenquest, jedes Gespräch, Laden, Anschlagbrett, Tagesablauf, Hilfe aus dem alten Spiel geht in Godot mindestens so (`LISTE-UMZUG-348.md`, 348.9), außer was 2.0 ersetzt.
- [ ] Englisch durchgehend (Homer, Tom).
- [ ] Spielerfreundlich (`DESIGN-LEITBILD.md` 3): auf „Normal“ ohne Grinden schaffbar.
- [ ] **Durchgespielt:** der Chef spielt Kapitel 1 einmal ganz durch und sagt „gut“ (Prüfer: Chef).

**S Store (danach, für „marktreif“)**
- [ ] Store-Seite, Texte und Bilder (Homer, Sokrates); Impressum (Datenschutzseite online, 252); Gewerbeschein und Preis (142, 45); Repo privat (109); 12 Tester, geschlossener Test 14 Tage, Prüfung durch Google.

## Stand zum Marktstart (338.1; Perikles: montags ganz, täglich neu; als Seite: [Dashboard](https://claude.ai/artifact/5gdqbHNUUpbBUU9sBo4i7t), 339)

**Stand 29.10., 01:05: gelb; seit gestern 12:34 gilt dein Vorrang „erst ein spielbares Godot-Spiel am Handy“ (399), die Umzugstermine ruhen mit dem Feinschliff.** Das spielbare Spiel steht: Dorf und Waldkampf laufen in einem Spiel, seit 28.10., 16:45 auf `main` (dein „399a ja“); du hast die Builds 130, 132, 133 und 139 getestet. Darin: Hauptmenü, Erschaffung, Spielstände, Leiste mit Uhr, Menü mit Held, Tasche, Ausrüstung und System, Laden, Anschlagbrett, Rast, Ausdauer, Fackel; Schenke, Laden, Ältester und Tempel sind betretbar; der Weg in den Wald führt in den Kampf (MARS) gegen einen Wolf mit ein bis zwei Jungwölfen, danach zurück mit Erfahrung, Gold und Beute. Deine Fehler aus Build 139 (u. a. schräger Joystick) sind gebaut; Build 141 hast du am 28.10. gegen 22 Uhr zurückgezogen: der nächste Build kommt erst mit den gekauften Figuren für Held und Leute (376.1) und Innenräumen wie im alten Spiel (399.5). Dafür liegen außerdem fertig: Tierlaute, Keuchen, Knurren mit Text, Kampfblende, Testmodus im Kampfort, Rand oben für die Kamera. Tom baut gerade Köpfe, Haut und Robe; die Innenräume liegen dir zum fünften Mal als Bilder vor. **Jerry steht seit 00:27:** für den Helden mit echten Hieben im Kampf (heute gleitet er ohne Hieb, 403) und Graks Nachbesserung braucht er die gekauften Dateien aus deinem zweiten Repository `bornim-kaufmodelle`; seine Sitzung durfte es nicht einbinden. Bei Tom ging es um 00:47 wieder, bei Jerry um 01:12 erneut nicht. **Du musst den Satz aus Chefsache „Zu tun“ 403 in Jerrys Sitzung „Jerry – 402 Herzschlag, 401 Kaninchen“ schreiben.** Das Wochenguthaben steht nach Rechnung bei etwa 94 %: ab etwa 2 Uhr startet Ford nur noch, was du zurückgegeben hast, ab etwa 6:45 Stillstand bis Sa 31.10., 20:00.

**Heute für dich:** steht immer aktuell in der [Chefsache-Übersicht](chefsache/README.md) (Entscheiden, Billigen, Ansehen, Testen, Tun); ein Werkzeug schreibt sie bei jedem Push, keiner von Hand (275).

**0. Meilenstein Umzug:** laut Liste 15 von 80 Punkten gebaut, 21 Entwurf, 44 nicht begonnen, keiner gemessen oder abgenommen (je Zeile der Umzugsliste `LISTE-UMZUG-348.md`; gleich gezählt gestern früh 6 gebaut von 64, dazu kamen 15 Grundsätze, die beim Gegenlesen am 28.10. fehlten (398), und die Grafikstufen im Systemmenü). Neu gebaut sind vor allem Funktionen ohne Bild (Laden, Rast, Tränke, Regeln, Talente, Pechsträhne, Beute, Spielstand, Schrift). Die Liste hinkt der Spielfassung nach: Hauptmenü, Erschaffung, Menü, Grundrisse und der Kampf aus dem Wald stehen dort noch auf „–“ oder „Entwurf“; nachgetragen wird mit der neuen Schätzung Mo 02.11. (für die zweite Umzugswoche). Block (D) Dorf und (K) Kampf im Wald bleiben rot, Termine unten unter „Meilenstein Umzug“ gelten nicht mehr, bis neu geschätzt ist.

**1. Stand gegen den Plan**

Was unten steht, ist im alten Spiel fertig und zieht als Vorgabe mit um. Termine je Block stehen unter „Meilenstein Umzug“.

| Block | Ampel | warum (Vorgänge) | fertig bis |
|---|---|---|---|
| (a) Kapitel 1 rund | gelb | Absturz (346), Ruckeln (358) und die Fehler aus deinem Durchspielen (350–352) sind auf `main`, im tiefen Wald das Hängenbleiben auch; die Sicht unter den Baumkronen (353) hast du entschieden, sie ruht mit dem alten Spiel und gilt im neuen; Stufe 1 leichter und Ansage harter Schläge (354) sind mit Build 88 auf `main`; die übrige Balance (38) misst Jerry erst im neuen Kampf, der Schwierigkeitsgrad (39) hängt daran; Tablet (267) wartet auf deinen Test. Berichtigtes Englisch ist mit Build 89 auf `main`. Das alte Spiel ist seit 27.10., 22:17 zu: nach Build 90 (Geräteangaben im Systemmenü, 388, über den Play Store) kommt keine Änderung mehr. | nach Umzug |
| (b) Erster Eindruck | gelb | Logo und Hauptmenü sind fertig (251, 292.3). Figuren und Intro-/Outro-Bilder im neuen Look entstehen jetzt im Umzug; Vorgabe ist Build 11 der Godot-Probe mit dicker Tusche. Seit 27.10., 21:41 bekommen alle Menschen gekaufte Köpfe mit eigener Formung, dazu ein Editor für den Spieler (376.1); den Zugang hast du am 28.10., 08:35 gegeben. | nach Umzug |
| (c) Ein Aussehen | grün | Das Spielermenü im Stil des Hauptmenüs ist mit Build 83 auf `main` (326). | erledigt im alten Spiel |
| (d) Klassischer Kampf rund | gelb | Graks Hieb (320) und sichtbarer Angriff (337) sind auf `main`; Ansage harter Schläge ist mit Build 88 auf `main` (354). | nach Umzug |
| (e) MARS als Alternative | gelb | Angriff und Ring sind auf `main` (336, 337); die fünf spielnötigen MARS-Punkte fielen in Build 89 durch (Absturz) und werden im neuen Spiel gebaut; Jerrys Godot-Kampf ist MARS (348.7); den Waldkampf gegen das Rudel spielst du seit Build 132 am Handy (399.2); die Zauberbahn hast du am 28.10. abgenommen (348.7b). | nach Umzug |
| (f) Store | gelb | Konto geprüft, App angelegt, der alte Stand läuft im internen Test (142.1, 25.10.); Datenschutzseite ist online (252); seit 27.10., 19:51 suchen wir die Tester öffentlich auf dem eingefrorenen Stand und prüfen zugleich ein Organisationskonto, das den Pflichttest ersparen würde (142.3). Offen bei dir: Gewerbeschein melden (tun/142), Repo vor dem Tester-Aufruf privat (109). Preis (45) wartet auf den Gewerbeschein, bis 30.11. | läuft neben dem Umzug |

**2. Ausgaben**
- **Echtes Geld:** das Max-Abo, seit 25.10., etwa 11 Uhr in der größeren Stufe; Nutzungsguthaben 0 $, Monat bisher 303,02 $ (dein Bild 25.10., 10:24). Neueren Stand gibt es nicht.
- **Wochenguthaben Max:** dein letztes Bild 27.10., 09:47: 51 %. Beim Takt von 1,09 % je Stunde jetzt etwa 94 %, 95 % gegen 2 Uhr, 100 % gegen 6:45, dann Stillstand bis Sa 31.10., 20:00. Das Konto meldet seit 28.10., 05:53 die Warnstufe; Ford startet nur Muss. Es gilt deine Entscheidung vom 22.10.: nicht sparen, nichts nachkaufen; ab 95 % nur, was du zurückgegeben hast. Ein neues Bild der Nutzung zeigt, ob die Rechnung stimmt.
- **Wofür (gebucht seit 28.10., 08:15, nur beendete Sitzungen, `KOSTEN-GEBUCHT.tsv` mit den Sitzungstiteln):** 664 $ in 39 Sitzungen. Tom 304 $ (15 Sitzungen), Jerry 193 $ (9), Sokrates 132 $ (5: Chefrunden und deine Tests über den ganzen Tag), Perikles 19 $ (6), Ford 9 $, Diogenes 5 $, Homer 2 $. Anteil Spiel etwa 75 % (Ziel 60 %, ab 02.11. 70 %). Die laufenden Sitzungen von Tom und Jerry sind noch nicht gebucht; drei beendete vom 28.10. haben keine Kostenangabe (ob schätzen: Chefsache „Zu entscheiden“ 404). **Letzte Woche** (18.–24.10., Zählung Diogenes): 1814 $, Spiel 57 %.

**3. Risiken und Gegenmittel**

| Risiko | Folge | Gegenmittel (wer) |
|---|---|---|
| Teams warten auf dich | Jerry steht seit 00:27 ohne die gekauften Dateien (403); bei dir liegen drei Bildblätter (Grak, Menü Ausrüstung, Innenräume) und eine Hörprobe, zu tun: Ausrüstung kaufen und laden (348.12h), Gewerbeschein (142); jede Stunde Warten fehlt vor dem Stillstand gegen 6:45 | Punkte ohne Bilderrunde zwischen deinen Blättern (390; Perikles); den Satz aus 403 in Jerrys Sitzung schreiben (du; Jerrys neuer Versuch scheiterte um 01:12) |
| Plan überholt | die Termine rechnen mit eigenen Modellen und ohne die Spielfassung (399); was gekauft ist, kann Sitzungen sparen, jede Kaufprobe kostet welche | Termine ruhen; neu schätzen Mo 02.11. mit dem Wochenziel 2 (Tom, Jerry, Perikles), dabei die Liste auf den Stand der Spielfassung bringen |
| Gewerbeschein kommt spät | Preis und Zahlungsprofil im Store fehlen; Konto und Datenschutzseite stehen schon | beim Amt nachfragen (du); alles so vorbereiten, dass nur noch die Angaben fehlen (Sokrates) |
| Anschrift vor dem Zahlungsprofil | Google zeigt die Anschrift öffentlich | Wohn- oder Geschäftsanschrift (Büroservice) vor dem Zahlungsprofil entscheiden (du, Sokrates) |
| Guthaben knapp | am 23./24.10. fielen 21 Läufe aus, weil Woche und Nutzungsguthaben leer waren; mit dem Umzug eher mehr Verbrauch | Betriebsanteil senken: Tagesbericht ersetzt (23.10.); seit 24.10. kürzere Antworten und kleinerer Start der Teams (347; Perikles, Messung Sokrates); Credits mit Monatslimit nur auf dein Wort |
| „Gut“ hat kein Ende | ohne Termin fehlt die natürliche Grenze; seit dem Umzug 4 bis 13 Bilderrunden je Figur oder Karte | nur du urteilst, nach genau einer Fehlerprüfung, höchstens ein Blatt je Modell und Runde (373); Feinschliff kommt ans Ende; die Schätzung 348.14 nennt Runden je Punkt, damit du siehst, wo sie fressen (Perikles) |
| MARS wird nicht rund | (e) fehlt | nach dem Umzug Stand messen; reicht es nicht, entscheidest du: Marktstart nur mit klassischem Kampf oder MARS als Testfunktion gekennzeichnet |
| 12 Tester fehlen | Pflichttest kann nicht beginnen | seit 27.10. öffentlich suchen, Organisationskonto prüfen (142.3); vor dem Aufruf Repo privat (109, du; Sokrates) |

Dazu, ohne Vorgang (Perikles vergibt Nummern mit der neuen Schätzung nach Woche 1): Englisch durchgehend (Homer, Tom); Spielstände über Updates (Tom); Handys und Tablets (Tom, mit 267); Store-Texte und Bilder (Homer, Sokrates); 12 Tester finden (Chef, Sokrates).

**Reihenfolge** (ohne Datum; Google: neues privates Konto braucht 14 Tage geschlossenen Test mit 12 Testern, dann Prüfung, etwa eine Woche):

| Schritt | was |
|---|---|
| erledigt | Chef spielt Kapitel 1 durch (26) ✓ 24.10.; Konto angelegt (142) ✓ 23.10.; (c) ✓ |
| 1 | Umzug Woche 1 (`LISTE-UMZUG-348.md`): Tom Grundgerüst und Dorf (348.6), Jerry Modellregel und Wolfskampf (348.7), beide Bestandsliste (348.8); danach Plan mit Schätzung (Perikles) |
| 2 | Umzug des heutigen Spiels; (a), (b), (d), (e) im neuen Code fertig |
| 3 | Fehler und Glätten; Englisch, Geräte, Spielstände; Store-Seite, Datenschutz, Impressum; Tester bereit |
| 4 | Chef: „gut“; geschlossener Test 14 Tage (falls nicht schon mit der alten App gelaufen), Antrag, Prüfung durch Google, Marktstart |

## Meilenstein Umzug: „Kapitel 1 auf Godot mindestens so gut wie alt“ (348.9, Chef 25.10., 12:24; seit 418 Teil von Block W der Abnahmeliste)

**Erreicht, wenn** jeder Punkt der Checkliste „abgenommen“ ist, die Kerntests aus `core` als GDScript-Tests grün sind und der Zufallsspieler Kapitel 1 im neuen Spiel durchspielt; danach ersetzt das neue Spiel nach dem Test des Chefs das alte auf `main`. **Checkliste** = Bestandsliste 348.8 samt Funktionen in `LISTE-UMZUG-348.md` (Stand-Wörter dort: –, Entwurf, gebaut, gemessen, abgenommen). Reihenfolge: zuerst das Licht (3486-sonne), dann je Bauart ein Grundmodell (Mensch, Vierbeiner, Vogel, Insekt, Spinne), daraus alle Figuren; Häuser und Dinge parallel; sonst so, wie Kapitel 1 gespielt wird. Jedes Vergleichsblatt misst Diogenes nebenher, als Hinweis an den Chef, kein Tor (373, `ROLLE-PRUEFUNG.md`).

**Stand 29.10., 01:05:** steht oben unter „0. Meilenstein Umzug“ (Zählung je Zeile der Spalte „Modell“). Die 15 Punkte der Gegenprobe 398 sind geschätzt (Tom 28.10., 15:37; Jerry 13:16, 16,5 Sitzungen), gerechnet wird mit der neuen Schätzung Mo 02.11.

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

**Umzug fertig zum Durchspielen: jeder Punkt der Checkliste ist bis Mo 02.11. „gebaut“ (hält nur, wenn du etwa 28 Blätter am Tag ansiehst, 373) und bis Di 03.11. von Diogenes gemessen (Hinweis, keine Bedingung für deine Abnahme); die Kerntests laufen als GDScript-Tests grün, der Zufallsspieler spielt Kapitel 1 im neuen Spiel durch; dann spielst du Kapitel 1 in Godot einmal ganz durch, und deine Fehler sind Muss.** Abnahme der Punkte nach deinem Wort, Feinschliff danach. Das Guthaben ab Sa 31.10., 20:00 reicht beim jetzigen Takt bis etwa Mi 04.11.; was dann offen ist, geht nach dem Stillstand ab Sa 07.11., 20:00 weiter. Messen, GDScript-Tests und Zufallsspieler sind nicht geschätzt. Stärkstes Gegenargument: wird es der späte Termin (seit 338a „B“ Di 03.11., früh; dann hält das Wochenziel nicht), bleibt für deine Fehler aus dem Durchspielen kaum Guthaben in dieser Woche.

Die alte Pflichtliste „Block (a) Kapitel 1 rund“ (altes Spiel) ist seit 418 in der Abnahmeliste oben aufgegangen; Wortlaut in Git, Stand vor „Perikles: 418“.
