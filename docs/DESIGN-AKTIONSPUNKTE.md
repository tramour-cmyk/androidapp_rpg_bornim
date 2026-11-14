# Aktionspunkte im Kampf: Gespräch Chef und Sokrates

Arbeitsstand des Gesprächs ab 13.11., 23:35, damit der Chef es nachlesen kann (Chef 14.11., 00:07: „Du musst das alles nachhalten, was wir hier erarbeiten, damit ich genau das, so wie wir es hier haben, nachlesen kann. Das muss alles in der Datei jetzt kommen … Eine eigene MD … Wo alles drin ist. Und das muss jetzt nicht in dem Vorgang sein“). Gehört zu 930 (Handgemenge und Abstand), betrifft 1072. Nichts hier ist entschieden, solange unter „Entscheidungen“ kein Wort des Chefs steht. Pflegt Sokrates, nach jedem Gesprächsschritt.

## Warum wir das machen

- **23:35, Chef:** „Also bevor Jerry jetzt wieder irgendwas einfach so entwickelt und viel Zeit verplempert, wird schon die erste Runde, ohne dass wir drüber nachgedacht haben, dann würde ich jetzt sagen, macht mal Jerry nicht weiter und wir machen erstmal unsere Hausaufgaben. Weil was wollen wir zusammenbringen? Was kostet was? Wie kann es laufen? Okay?“ Jerry ist seitdem angehalten (1072 Plätze und Laufwege, 709 und 709.1 Bisse zu kurz).
- **23:48, Chef:** „Ja, ich denke, wir müssen uns vorneweg schon mal einen Kopf machen, ob wir das mit Aktionspunkten machen wollen und was wie viel kostet.“
- **23:50, Chef:** „Weil davon hängt ab, inwieweit Leute wieder zurückweichen können oder nicht, weil was es kostet, zum Beispiel. Was kostet Gehen, was kostet Rennen, was kostet ein Tank nehmen, was kostet ein Waffenwechsel, was kostet ein leichter Zauber, was kostet ein schwerer Zauber. Fragen über Fragen, die man da stellen kann.“ Und: „hör auf, jetzt jedes Mal schon wieder 1000 Dinge im Hintergrund zu machen. Ich bin doch noch am Ideen sammeln mit dir zusammen.“
- **00:03, Chef** (Nachricht brach ab): „So, und jetzt machen wir wieder eins nach dem anderen. Jetzt hast du mir gezeigt, was deine Regelseite heute vorschlägt. … Und daran arbeiten wir jetzt mal und stecken Hirnschmalz rein. … jede einzelne Entscheidung, jede einzelne“. Gelesen als: Entscheidung für Entscheidung durchgehen.
- **14.11., 08:47, Chef (Neuanfang):** „Nee, wir fangen nochmal ganz anders an, sondern wir schauen jetzt erstmal, was für mögliche Aktionen gibt es denn überhaupt, die man machen kann. Dann schauen wir, was soll das kosten. … Und dann können wir uns auch überlegen, keine Ahnung, ob es immer sein soll, einmal was tun und einmal bewegen. Und ob Bewegen zum Beispiel auch umsonst sein kann. Also normales Bewegen. Aber erstmal brauchen wir eine Liste von Sachen, die überhaupt machbar sind im Kampf. Und dann schauen wir, wie wir die kategorisieren, und dann schauen wir, was die kosten oder ob sie mal nichts kosten oder ob es nur zwei gibt.“ Damit gilt die Reihenfolge: (1) Liste, (2) Gruppen, (3) Preise, (4) Zahl der Punkte oder „ein Tun, ein Bewegen“. Alles darunter (Abschnitte ab „Erster Wurf“) ist Vorarbeit, nicht der Weg.

## Schritt 1: Was man im Kampf tun kann (Sokrates, 14.11., 08:50)

Ohne Preise. Quellen: Code auf `main` (`424334472`: `mars.gd` `_perform`, `kampf_ui.gd` `_build_orders`), `DESIGN-BRS.md` 7, `STORY-BRS-KOENNEN.md`, `STORY-BRS-KAMPF.md` (Ansagen), Regelseite 930 in `DESIGN-KAMPF.md`. Zeichen: **●** heute im Spiel, **◐** beschlossen, noch nicht gebaut, **○** nur Vorschlag.

**Heute auf dem Bildschirm:** Angriff, Können, Tasche, Wechsel; darunter Abwehr, Flucht, (Decken), Söldner Auto, Held Auto. Heute ist jede Wahl der ganze Zug, außer **Wechsel**: Platztausch und Waffe ziehen kosten nur den Schritt, danach darf man noch handeln (`mars.gd` `act`). „Einmal bewegen, einmal tun“ gibt es also schon, aber nur für den Wechsel.

**A. Bewegen**
1. Heran an einen Gegner (Schritt) ○ – heute nur Bild, kostet nichts
2. Zurück, aus dem Handgemenge (Rückzug) ○
3. Rennen, mehrere Felder ○
4. Platz tauschen in der eigenen Reihe, vorn ↔ hinten ●
5. Fliehen, ganzer Kampf ● (nie vor einem Boss)

**B. Angreifen**
6. Nahkampfschlag ●
7. Schuss (Bogen, Armbrust) ●
8. Wurf (Wurfwaffe, Kampftrank, Wurfmittel) ●
9. Schwung: zweiter Schlag nach einem Treffer ○ (930)
10. Kampfhandlungen der Fertigkeit ab Geselle ● (Liste in Jerrys Code, wirken teils noch nicht): Finte, Stich aus dem Hinterhalt, Wuchtschlag, Schädelstoß, Griff, Ruhige Hand, Durchschlag, Zwei auf einmal
11. Zurückdrängen: Schildstoß, Wuchtschlag drängt ○ (930 Regel 5)

**C. Zaubern** (nach Schule, Mana)
12. Angriff auf einen: Funkenpfeil, Arkanpfeil, Gleißstrahl ●; Glutstrahlen (drei Ziele) ●
13. Fläche, eine Reihe: Flammenfächer, Glutkugel ●
14. Schutz für sich: Arkanhaut, Bannschild ●
15. Heilen eines Freunds: Wundsegen ●
16. Stärken: Beistand ●

**D. Gegenstände**
17. Trank trinken ●
18. Trank einem Freund geben ● (Ziel wählbar)
19. Waffe wechseln, Zweitwaffe ziehen ●
20. Schild ablegen oder aufnehmen, Fackel ziehen ○ (Fackelstoß, Tiere verscheuchen: `LISTE-MARS.md`, ○)

**E. Abwehr und Haltung** (wirkt bis zum eigenen nächsten Zug)
21. Abwehr (heute „warten“, gibt Gegnern Ungunst) ●
22. Decken: Schläge auf einen Freund auf sich ziehen ● (nur alte Klasse Kämpfer; im BRS Fähigkeit des Wächters)
23. Schildwall ● (wirkt in Kapitel 1 nicht, Held allein)
24. Auf Abstand (Stangenwaffe, Gegenstoß) ●
25. Wehrhaltung ○ (nur, wenn Jerry sie behält)
26. Deckung aus übrigen Punkten ○ (930)
27. Atem holen, Ausdauer zurück ○ (930 Regel 3)

**F. Im Zug des Gegners** (kein eigener Zug, aber eine Wahl)
28. Ring der Abwehr bei großen Schlägen ● (1048 A)
29. Ausweichen ● (704 A: kostet nichts)
30. Ring beim eigenen Schlag ◐ (1048 D, Bau 1068)

**G. Einmalig und Sonderfälle**
31. Kraft schöpfen, Leben zurück, einmal je Kampf ●
32. Einschüchtern zu Beginn (Späher verjagen) ●
33. Hinterhalt zu Beginn (nach Schleichen) ●; Abstand selbst wählen ○ (930 Regel 8)
34. Die Kulisse benutzen (Feuer, Fass, Wasser) ○ (Baustein 3, nie gebaut)
35. Bedienung, keine Handlung: Held Auto, Söldner Auto, Schnell

**H. Gegner** (für die Frage, ob für sie dieselben Preise gelten)
- einfacher Schlag oder Biss je Art ● · Schwerer Hieb ● · Anspringen ● · Flanke ● · Einkreisen ● · Durchbrechen ● · Hilfe rufen ● · Kraft sammeln ● · Gift sammeln ● · Netz werfen ● · Anlegen (Schuss) ● · In den Schatten ● · Heilen (Schamane) ● · Fliehen ● · Kroggs Prankenhieb ○ (930 Regel 9)

**Was auffällt:**
- Gut die Hälfte gibt es schon; neu für die Punktefrage sind vor allem A1–A3 (der Weg) und E26, E27.
- „Bewegen umsonst“ (Chef) hieße: A1 und A2 kosten nichts, dann zählt Abstand nur noch, wenn das Tempo begrenzt, wie weit man frei kommt (etwa ein Feld frei, jedes weitere kostet). Sonst wäre der Fernkämpfer ohne Vorteil, und der Rückzug wäre gratis.
- Mehrere Dinge sind keine eigene Wahl im Zug (F), andere nur einmal je Kampf (G31, G32); die brauchen vielleicht gar keinen Preis.

**Nächster Schritt (2):** Gruppen festlegen. Vorschlag zur Prüfung: **Bewegen** (A) · **Tun** (B, C, Angriffe und Zauber) · **Kleines Tun** (D, Tränke und Waffen) · **Haltung** (E) · **frei** (F, G). Dann liest sich die Frage des Chefs so: je Zug ein Bewegen und ein Tun, Kleines Tun statt Bewegen, Haltung statt Tun, Freies immer.

## Vorbilder: wie andere Spiele den Zug einteilen (Sokrates, 14.11., 10:05)

Auftrag Chef 10:02: „Kennst du die Spiele XCOM oder Jagged Alliance? Die arbeiten ja zum Beispiel auch mit Aktionspunkten. Ja, recherchier doch mal ein bisschen … Oder schau dir mal auch normale Brettspiele an, wie da normalerweise Züge eingeteilt sind und so. Was da gut ankommt, was da Ideen wären. Und pack das alles schön immer in unsere Datei rein.“ Quellen unten; wo keine steht, aus eigener Kenntnis der Spiele.

### Die Grundformen

| Form | Beispiel | So geht der Zug | Gut daran | Schwäche |
|---|---|---|---|---|
| **Viele kleine Punkte** | Jagged Alliance 2 (bis 25 je Söldner, nach Werten), Battle Brothers (9) | Jeder Schritt, jedes Drehen, Hinknien, Zielen kostet; übrige Punkte erlauben, den Gegner in seinem Zug zu unterbrechen | sehr fein, Werte spürbar (flinke Figur hat mehr Punkte), Zielen als Wahl | viel Rechnen und Tippen; „lohnt sich ein Schritt mehr?“ ist eine Rechenfrage, keine Spielfrage |
| **Zwei Halbzüge** | XCOM 1 und 2 | Zwei Aktionen: bewegen + schießen oder zweimal bewegen; **Schießen beendet den Zug**; Scharfschuss kostet beide; „Wache“ (Overwatch) schießt im Gegnerzug auf den, der sich bewegt | sofort verständlich, schnell, aufs Handy übertragbar (XCOM gibt es dort) | „Schießen beendet den Zug“ verbietet „schießen, dann zurück“; Kritik: Spieler kriechen vorsichtig vor, Wache wird zur Standardtaste |
| **Drei gleiche Aktionen** | Pathfinder 2 (Tischrollenspiel), Star Wars Zero Company (Nachfolger der XCOM-Macher, 3 Punkte, Wache beendet den Zug) | Drei Aktionen in beliebiger Folge, große Dinge kosten zwei oder drei; dazu eine Reaktion im Gegnerzug | einfach und doch abgestuft; „schwerer Zauber 2, dann noch ein Schritt“ | Kritik: man bleibt lieber stehen und schlägt dreimal; ständige Frage „ist das eine Aktion?“ |
| **Getrennte Töpfe** | Baldur's Gate 3 (D&D 5): Bewegung als eigener Balken (9 m), eine Aktion, eine Bonusaktion, eine Reaktion | Bewegen kostet nicht die Aktion; Trank, Waffe ziehen, kleine Dinge sind Bonusaktion | **„einmal bewegen, einmal tun“** genau so; Bewegen ist praktisch frei bis zur Grenze | wenig Wahl je Zug (eine Aktion), darum viel Lähmen und Betäuben als stärkstes Mittel |
| **Ein Topf für alles** | Divinity: Original Sin 2 (Punkte für alles, auch Laufen) | Alles in Laufen oder alles in Angriffe | viel Freiheit, Einfälle | Durcheinander, schwer abzustimmen; Laufen und Schlagen konkurrieren |
| **Bewegen, dann tun, Gegner sagt an** | Into the Breach | Jede Figur: einmal bewegen, einmal handeln; alle Gegner zeigen vorher, was sie tun | glasklar, jede Runde ein kleines Rätsel; ideal fürs Handy | wenig Raum für Haltung, Tränke, Kleinkram |
| **Brettspiel: zwei Aktionen aus einer Liste** | Descent (Fantasy Flight) | Zwei Aktionen: Bewegen, Angriff, Rasten, Fähigkeit, Aufstehen, Tür …; dieselbe darf zweimal, nur Rasten nicht; **Erschöpfung gegen Extraschritte**; Bewegen darf man unterbrechen, handeln, weitergehen | einfach, Erschöpfung als zweite Währung | zwei Angriffe je Zug sind oft die beste Wahl |
| **Brettspiel: Karten oben, unten** | Gloomhaven | Zwei Karten, je eine obere (meist Angriff) und eine untere (meist Bewegung) Hälfte; vorher wählen, Karten werden mit der Zeit weniger (Erschöpfung) | jede Wahl ein echtes Abwägen, Ermüden ist eingebaut | zu viel Planung für einen schnellen Handykampf |
| **Brettspiel: feste Zahl gleicher Aktionen** | Pandemie (4 Aktionen), viele Eurospiele | Vier Aktionen aus einer kurzen Liste, jede gleich teuer | leicht zu lernen | keine Abstufung (Trank = Schlag) |

### Was gut ankommt (Lob, das sich wiederholt)

1. **Wenige, große Punkte** werden auf dem Handy und für Neulinge besser verstanden als viele kleine (XCOM, Into the Breach gegen Jagged Alliance).
2. **Bewegen und Tun getrennt** (Baldur's Gate 3, Into the Breach, Descent mit Bewegen im Angriff): der Spieler muss nie zwischen „hingehen“ und „zuschlagen“ wählen, nur wohin und was.
3. **Eine Reaktion im Gegnerzug** gilt überall als das, was den Gegnerzug spannend macht (Jagged Alliance Unterbrechen, XCOM Wache, Pathfinder Reaktion). Bei uns: der Ring (F28, F30).
4. **Ansage der Gegner** (Into the Breach, bei uns Baustein 1 schon gebaut) macht jeden Zug zum Rätsel statt zum Würfeln.
5. **Erschöpfung als zweite Währung** (Battle Brothers, Descent, Gloomhaven): Punkte füllen sich jede Runde, Ermüdung nicht; das verhindert „jede Runde dasselbe“. Battle Brothers: jeder kann auch erschöpft noch einen Grundschlag.

### Was oft kritisiert wird

- „Schießen beendet den Zug“ (XCOM) fühlt sich starr an; der Chef will ausdrücklich „zurückweichen und dann schießen“ (930, 12:28).
- Viele kleine Punkte machen Kämpfe langsam (Jagged Alliance), bei uns gegen F9 (Rundenzeit).
- Eine Taste, die immer richtig ist (XCOM Wache, Pathfinder dreimal schlagen), macht den Kampf eintönig. Gegenmittel: der dritte Schlag schwächer (Pathfinder macht das genau so: jeder weitere Angriff im Zug mit Abzug).

### Ideen für uns (zum Prüfen, nichts entschieden)

- **I1 Getrennte Töpfe statt einer Zahl:** je Zug **ein Bewegen** (frei bis zum Tempo, etwa ein Feld; schnell zwei) und **ein Tun**; dazu **ein Kleines** (Trank, Waffe wechseln, wie die Bonusaktion). Das beantwortet die Chefsfrage „einmal tun, einmal bewegen, Bewegen umsonst“ direkt, und es passt zu heute: der Wechsel kostet schon nur den Schritt.
- **I2 Tausch der Töpfe:** das Tun gegen ein zweites Bewegen tauschen (Rennen = zweimal bewegen, wie XCOM und Descent), nie umgekehrt; damit kein Doppelschlag (870a 3).
- **I3 Schwere Dinge kosten Bewegen mit:** schwerer Zauber, Wuchtschlag, gezielter Schuss = Tun und Bewegen (wie XCOMs Scharfschuss mit zwei Aktionen). So entsteht Abstufung ohne Punktezählen.
- **I4 Unverbrauchtes Bewegen wird Deckung** oder Reaktion (Jagged Alliance: gesparte Punkte zum Unterbrechen). Wer stehen bleibt, wehrt besser ab.
- **I5 Ausdauer als zweite Währung** (930 Regel 3; Battle Brothers, Descent): Extraschritt gegen Ausdauer, erschöpft nur Grundschlag.
- **I6 Gegner nach demselben Muster,** aber mit eigenem Tempo und Ansage (Into the Breach); der Wolf „springt und beißt“ ist dann ein Bewegen und ein Tun. Löst den Befund aus der Rechnung (Gegner mit 3 Punkten nehmen dem Abstand den Preis), weil Bewegen begrenzt ist.

**Stärkstes Gegenargument gegen I1:** getrennte Töpfe machen Abstand billig; ist Bewegen frei, kommt jeder Nahkämpfer in jedem Zug heran, der Fernkämpfer gewinnt kaum Zeit. Antwort: das Bewegen hat eine Weite (Tempo) und kostet nur bis dorthin nichts; der Wiedergänger schafft ein Feld nicht in einem Zug (Schlurfen), der Wolf zwei. Gegenprobe nötig: Rechnung mit `handgemenge.py`, sobald der Chef eine Form gewählt hat.

**Votum Sokrates (vorläufig):** I1 mit I2, I3, I6 ist für uns die beste Grundform: einfacher als Punkte zählen, beantwortet „einmal tun, einmal bewegen“ und braucht keine Glutmarken. Punkte (3 je Zug) bleiben der Vergleich.

**Nachtrag zur Liste (Schritt 1):** fehlte **B12 Helfen**: der Gefährte greift im Vorteil an (Idee Chef 12.10., `LISTE-IDEEN.md`, reif zu 72.10a.9), und **A6 Freischritt** ab Geselle Ausweichen oder Leichte Rüstung, ein Schritt je Zug frei (Idee A8, Chef 11.11., 14:33, ebenda) – das ist schon eine Form von „Bewegen umsonst“.

### Idee des Chefs 10:04: Grundzauber, Pfeilarten, Munition

**Wortlaut:** „Dann so grundsätzliche Zauber oder wie auch immer, die es halt immer geben könnte, wäre eine Art Schutzfeld, eine Steinhaut, eine Feuerwand, Blitze, dann kann man auch für die Fernschützen, also wie Bogenschützen oder Armbrustschützen, verschiedene Pfeilarten mit Gift, mit, keine Ahnung, schwarzer Magie, mit brennende Pfeile und so. Auch da Variation oder auch, dass die Pfeile an sich unterschiedlichen Schaden verursachen, weil sie halt besser hergestellt sind oder halt einfach aus besserem Holz gemacht worden sind. … Weil bei den Schwertern haben wir ja schon unterschiedliche Stufen. Also dass nicht nur die Art des Bogens bestimmt, wie stark was ist, sondern natürlich auch die Pfeile einen Einfluss darauf haben. Das hat jetzt noch nicht 100% was gerade mit dem zu tun, was wir hier tun, aber spielt halt alles in die Optionsmöglichkeiten mit rein. Erstens in das, was die Leute herstellen können sollen, was sie dafür sammeln können müssten. Nämlich dann vielleicht auch sozusagen verschiedene Holzsachen im Wald finden. Und daraus kann man ja dann Teile herstellen. Ich habe bloß wieder so eine Idee.“

**Abgleich mit dem Bestand (nachgesehen):**
- **Zauber:** heute zehn (Liste C). Schutzfeld ≈ Bannschild, Steinhaut ≈ Arkanhaut (beide nur für sich selbst). **Feuerwand** und **Blitz** gibt es nicht; Blitz bräuchte eine neue Schadensart (heute Schnitt, Stich, Wucht, Feuer, Gift, Säure, Licht; 870a 8). Feuerwand ist die erste Handlung, die einen **Ort** im Kampf verändert (Abstand!), passt zu 930 Regel 5 („Glutring“) und Baustein 3.
- **Pfeile:** heute keine Munition; der Schuss hängt nur an Bogen und Fertigkeit. Kampftränke und Wurfmittel tragen schon eine Schadensart (870a 8); Pfeilarten wären derselbe Gedanke am Bogen. „Schwarze Magie“ gibt es als Schadensart nicht.
- **Güte** (Schlecht bis Meisterhaft, `DESIGN-BRS.md` 11) gilt für jedes Stück; Pfeile mit Güte passen ohne neue Regel.
- **Holz:** Die Sammeltabelle (`DESIGN-BRS.md` 10) kennt Kräuter, Erz, Fisch, Tierteile, **kein Holz** und kein Handwerk für Bogen und Pfeil (Bogner, Pfeilmacher). Federn und Sehnen kämen aus der Jagd, Spitzen aus Erz über den Schmied.

**Was es für die Aktionspunkte heißt:** Pfeilart wählen ist ein **Kleines Tun** oder frei (wie Waffe wechseln, D19); ein Zauber wie Feuerwand ist ein großes Tun (I3: kostet Tun und Bewegen). Die Liste wächst also, ohne neue Gruppe.

**Stärkstes Gegenargument:** Munition heißt Zählen, Nachkaufen, Tasche voll; viele Spieler empfinden Pfeile zählen als Pflicht ohne Spaß (darum haben viele Spiele unendliche Grundpfeile). Und jede neue Schadensart braucht Schwächen, Stärken und Bilder je Monster. **Antwort:** Grundpfeile unbegrenzt, nur besondere Pfeile gezählt (wie Kampftränke heute); Gift und Feuer nutzen vorhandene Schadensarten.

**Kosten (grob):** Pfeilarten mit vorhandenen Schadensarten klein bis mittel (Datensätze, Wahl im Kampf, ein Bild je Art); Holz und Bogner ein neues Handwerk (mittel, Rezepte, Fundorte, Bilder); Feuerwand und Blitz je ein neuer Zauber mit Bild und Klang, Blitz dazu eine Schadensart (groß).

**Votum Sokrates:** Ja als Richtung, aber nicht für Kapitel 1 (Oberste Direktive: erst Kapitel 1 fertig; 488). Jetzt nur: in Liste und Gruppen mitdenken (Pfeilart = Kleines Tun). Vorschlag für später: (1) Grundpfeile unbegrenzt, besondere Pfeile (Feuer, Gift) gezählt, aus Jagd, Kräutern und Holz; (2) Pfeile mit Güte; (3) Holz als Rohstoff mit neuer Fertigkeit oder unter Kräutersammeln; (4) Feuerwand als erster Zauber, der den Abstand verändert, mit 930.

**Quellen:**
- XCOM: [Incentives and Intent: XCOM's Creeping Forward Problem](https://evizaer.github.io/Incentives-and-Intent/), [A Deep Dive Into XCOM and XCOM 2](https://www.gamedeveloper.com/design/a-deep-dive-into-xcom-and-xcom-2), [XCOM 2 Wiki: Combat](https://xcom2.wiki.fextralife.com/Combat), [Zero Company vs. XCOM](https://hacktheminotaur.com/swzc/star-wars-zero-company-vs-xcom-explained/)
- Jagged Alliance: [Jagged Alliance Wiki](https://jaggedalliance.fandom.com/wiki/Jagged_Alliance_2), [PC Games: Taktik-Klassiker](https://www.pcgames.de/Jagged-Alliance-Spiel-8152/Specials/Taktik-rundenbasiert-Klassiker-1293711/galerie/3052551/), [GOG-Forum](https://gog.com/forum/jagged_alliance_series/ja2_mercy_questions_for_mercy_people), [1.13 Play Guide](https://1dot13.github.io/documentation/play-guide.html)
- Battle Brothers: [Dev-Blog Kampfmechanik](https://indiedb.com/news/dev-blog-on-tactical-combat-mechanics), [Character Stats](https://battlebrothersgame.com/character-stats)
- Pathfinder 2, Gloomhaven: [EN World: Pathfinder 2's 3 Action Economy](https://www.enworld.org/threads/from-7-action-types-to-pathfinder-2s-new-3-action-economy.665200/page-6), [Nerdist: PF2 Action Economy](https://nerdist.com/article/pathfinder-2e-action-economy-guide-beginner/), [Black Gate: Gloomhaven](https://www.blackgate.com/?p=422989), [The Giant Brain: Gloomhaven](https://giantbrain.co.uk/2022/03/09/gloomhaven-in-focus/?amp=1)
- Baldur's Gate 3, Divinity 2: [Divinity Wiki: Action points](https://www.divinitywiki.com/index.php/DOS2:Action_points), [WePC: BG3 vs. Divinity](https://www.wepc.com/gaming/baldurs-gate-3-divinity-original-sin-comparison/)
- Descent: [Regelzusammenfassung 2. Edition](https://lehi-innovation.github.io/boardgame-rules/rules/descent-journeys-in-the-dark-second-edition/), [Community-Regelreferenz](https://descent-community.org/wp-content/uploads/2017/10/CRRG_1_8_1.pdf)
- Into the Breach, Pandemie: eigene Kenntnis, nicht nachgeschlagen.

## Was zusammenhängt (Gesamtbild 13.11., 23:39)

- **1072 Plätze und Laufwege** (29,94 $): wo eine Figur steht, wie sie dorthin kommt; hinterer Wolf läuft außen herum (0,3 m Luftzuschlag, frei wären 0,18–0,26 m), Runde 30,8 s statt 14,6 s.
- **709, 709.1 Bisse zu kurz** (62,14 $, 74,79 $): Grimmzahn 0,52 m vor dem Schild, Ratte 0,135 m vor Kleriker und Zauberer; Ursache vermutet im Bissplan, den 1072 ohnehin neu rechnet.
- **930 Handgemenge** (19,74 $, Rechnung 8,58 $): Regelseite in `DESIGN-KAMPF.md`, unentschieden.
- **Entscheide des Chefs dazu:** Gegner bleibt nach Ausweichen stehen (703 A), setzt nach dem Angriff ab und bleibt (717 C), Held „geht zügig rückwärts heim“ (784 A, F9).
- Zusammen bisher rund 260 $, die sichtbaren Fehler sind noch da.

## Was die Regelseite 930 heute vorschlägt (Stand 11.11.)

Zwei Punkte je Zug, am Fuß des Helden als zwei Glutmarken.
- Weg: ein Feld kostet nach Tempo, schnell einen halben Punkt, normal einen, langsam zwei.
- Angriff, Schuss, Zauber: ein Punkt. Zweiter Angriff nur als Schwung nach einem Treffer.
- Platztausch: ein Punkt. Schritt zurück: ein Punkt; ein schneller Gegner setzt nach.
- Übriger Punkt: Deckung, bis zum nächsten Zug leichter abwehren.
- Kroggs Prankenhieb: beide Punkte.
- Abstand: nah (am Gegner), fern (ein Feld), weit (zwei Felder); ein Kampf beginnt fern.

**Rechnung 930.3** (`git show e38789523:tools/sim444/handgemenge_930.md`, je Fall 1000 Kämpfe, nur mit 2 Punkten gerechnet; 3 Punkte lassen sich mit `"punkte": 3` in `handgemenge.json` rechnen):
- Kämpfe werden kürzer: Wachsoldat gegen Krogg 5,8 statt 8,1 Runden.
- Schwache Herkünfte gewinnen deutlich öfter: Kräutersammler gegen Krogg 38 statt 5 von 100; mit gezähmtem Schwung 15 von 100. Die Balance verschiebt sich.
- Nicht gemessen: wie lange eine Runde mit Punkten auf dem Bildschirm dauert (Film wartet auf 931).

## Erster Wurf: drei Punkte je Zug (Sokrates, 23:50, zum Durchdenken)

| Handlung | Punkte | Gedanke |
|---|---|---|
| Gehen, ein Feld | 1 | Grundmaß; schnelle Figuren 2 Felder je Punkt, langsame 1 Feld für 2 |
| Rennen | 2 für 3 Felder | danach kein Angriff mehr, kostet Ausdauer |
| Schritt zurück | 1 | ein schneller Gegner setzt nach |
| Angriff | 1 | |
| Schwerer Hieb | 2 | trifft härter, langsamer zu lesen |
| Trank nehmen | 1 | einem anderen geben: 2 |
| Waffenwechsel | 1 | Schild ablegen: frei |
| Leichter Zauber | 1 | |
| Schwerer Zauber | 2 | mit drei Punkten bleibt noch ein Schritt |
| Übrige Punkte | Deckung | leichter abwehren bis zum nächsten Zug |

- **Warum drei statt zwei:** Bei zwei kostet ein schwerer Zauber den ganzen Zug, Gehen, Trank und Waffenwechsel lassen sich kaum unterscheiden. Mit drei wird jede Wahl eine Abwägung („Trank, ein Schritt zurück und decken, oder noch einmal zuschlagen?“).
- **Stärkstes Gegenargument:** mehr Tippen, längere Runden, auf dem Handy zäh. Dagegen: „Angreifen“ auf ein Ziel bezahlt den Weg gleich mit; wer nichts plant, tippt einmal wie heute.
- **Offene Fragen an den Chef:** (1) Ausdauer als zweite Währung neben den Punkten oder nur Punkte? (2) Gegner mit denselben Punkten oder eigene Muster (Wolf immer „Sprung plus Biss“)? (3) Kostet schwere Rüstung Punkte (langsameres Gehen) statt nur Ungunst?

## Reihenfolge der Entscheidungen (Sokrates, 00:03)

1. Aktionspunkte überhaupt?
2. Wie viele je Zug?
3. Was kostet der Weg: Gehen, Rennen, Tempo?
4. Was kosten die Handlungen: Angriff, Zauber leicht und schwer, Trank, Waffenwechsel?
5. Was kosten Zurückweichen und Platztausch, und was löst das aus?
6. Was geschieht mit übrigen Punkten?
7. Gelten für Gegner dieselben Regeln?

## Entscheidungen

### 1. Aktionspunkte, ja oder nein? (offen)

- **Heute:** ein Zug, genau eine Handlung; der Weg zum Gegner kostet nichts und ist nur Bild; Abstand gibt es in den Regeln nicht.
- **Mit Punkten:** der Weg kostet, damit bekommen Abstand, Tempo und Zurückweichen Gewicht. Der Fernkämpfer gewinnt Zeit, ein Wolf ist gefährlicher als ein Wiedergänger, weil er schneller da ist; jeder Zug ist eine Abwägung.
- **Stärkstes Gegenargument:** komplizierter, mehr Tippen; die Balance verschiebt sich (schwache Herkünfte gewinnen deutlich öfter), alle Gegnerwerte müssen neu abgestimmt werden.
- **Mittelweg ohne Punkte:** eine Handlung je Zug, aber Abstand zählt; wer weit steht, braucht seinen Zug zum Herankommen. Einfacher, aber Trank, Waffenwechsel und leichter Zauber kosten dann alle einen ganzen Zug; die Liste des Chefs (23:50) ist so nicht abzustufen.
- **Votum Sokrates:** ja, Aktionspunkte; unterschiedliche Preise brauchen eine Währung.
- **Chef (14.11., 00:25):** „Ja, Aktionspunkte machen Sinn. Die Frage ist, wie wir es clever anstellen, damit es eine runde Geschichte wird. Und wie wir uns entwickeln können. Ob gewisse Pfade einen Aktionspunkt mehr geben, ob die Heldenstufe was gibt. Viele Möglichkeiten.“ (Nachricht brach danach ab: „Sie müssten uns bitte nochmal zur Urin“.) → **Aktionspunkte: ja.**

### 2. Wie viele je Zug, und wie wachsen sie? (offen)

Frage des Chefs 00:25: geben Pfade einen Punkt mehr, gibt die Heldenstufe etwas?

**Was das BRS dazu schon sagt** (`DESIGN-BRS.md`):
- „Was ein Pfad bringt: neue Fähigkeiten im Kampf und in der Welt … keine großen Zahlenaufschläge. Die Kraft bleibt in den Fertigkeiten.“ (Abschnitt 5)
- Der Pfad beginnt erst in Kapitel 2 (Weihe); Kapitel 1 endet bei Heldenstufe 6; in Kapitel 1 wachsen die Grundwerte nicht (870a 4).
- „Extra-Angriff, Doppelzug, Zweiwaffenkampf entfallen“ (870a 3, Chef 10.11.).
- „Du wirst, was du tust“: Kraft kommt aus dem, was der Held übt.

**Wege, wie Punkte wachsen können:**
- **A: Mehr Punkte mit der Heldenstufe** (etwa 3, ab Stufe 5 vier). Einfach zu verstehen; aber ein Punkt mehr ist ein Drittel mehr Zug, also ein großer Zahlensprung, und widerspricht „keine großen Zahlenaufschläge“; der Doppelzug käme durch die Hintertür zurück.
- **B: Ein Punkt mehr durch den Pfad.** Passt zum Rollenspiel, aber jeder Pfad müsste ihn bekommen (sonst ist der Pfad ohne Punkt schwächer), dann ist es wieder nur Stufe; in Kapitel 1 gibt es noch keinen Pfad.
- **C: Feste Punkte für alle, Handlungen werden billiger** (Empfehlung). Jeder hat 3; wer übt, zahlt weniger: Rang Geselle im Bogen, dann Nachladen und Schuss für 1 statt 2; Geselle Alchemie, dann Trank für 0 einmal je Kampf; Gewandtheit macht den Weg billiger (Tempo). Wachstum spürbar, aber an der Fertigkeit, wie im BRS.
- **D: Pfad gibt einen gebundenen Punkt** (ab Kapitel 2): ein zusätzlicher Punkt nur für eine Sache des Pfads, etwa Wächter nur für Schild und Schritt, Waldläufer nur für Bewegung, Kriegsmagier nur für Zauber. Zusammen mit C.
- **E: Heldenstufe gibt einen Punkt nur an großen Schwellen der Geschichte** (etwa einmal in Kapitel 3 und einmal in Kapitel 6), nie in Kapitel 1. Selten, gefeiert, Gegner wachsen mit.

**Stärkstes Gegenargument gegen C:** Billigere Handlungen sind schwerer zu sehen als „du hast jetzt 4 Punkte“; der Spieler merkt das Wachsen weniger. Dagegen: die Glutmarken zeigen vor dem Tippen, was eine Handlung kostet; „Trank kostet nichts mehr“ fühlt man sofort.

**Votum Sokrates:** 3 Punkte für alle; Wachsen über C (billiger durch Fertigkeit), ab Kapitel 2 dazu D (gebundener Punkt des Pfads); E offen lassen bis Kapitel 3. Kapitel 1 bleibt bei 3 Punkten für alle.
- **Chef (14.11., 00:44):** „Naja, für mich hängt schon davon ab, wie viele Punkte auch damit zusammen was kostet.“ → **Zahl der Punkte und Preise zusammen entscheiden** (2 und 4 gemeinsam).

### 2 und 4 zusammen: erst die Wunschzüge, dann Preise und Zahl (Sokrates, 00:44)

**Vorgehen:** Nicht mit der Zahl anfangen, sondern festlegen, welche Züge in einen Zug passen sollen und welche nicht. Daraus folgen Preise und Zahl.

**Wunschzüge (Vorschlag, der Chef ergänzt oder streicht):**
1. Ein Feld heran und zuschlagen: geht.
2. Schießen und einen Schritt zurück: geht.
3. Trank und zuschlagen: geht.
4. Waffe wechseln und zuschlagen: geht.
5. Schwerer Zauber: geht, danach höchstens ein Schritt.
6. Von weit (zwei Felder) heran und zuschlagen: geht, kostet aber alles, keine Deckung.
7. Zweimal zuschlagen: geht nicht (Doppelzug gestrichen), nur als Schwung nach einem Treffer.
8. Wer nah steht und nur zuschlägt, hat noch etwas für Deckung übrig.

**Preise zur Probe:** Schritt 1, Schritt zurück 1, Angriff oder Schuss 1, leichter Zauber 1, schwerer Zauber 2, Trank 1, Waffenwechsel 1; dazu Regel „höchstens ein Angriff je Zug, außer Schwung“.

**Prüfung der Zahl gegen die Wunschzüge:**

| Wunschzug | 2 Punkte | 3 Punkte | 4 Punkte |
|---|---|---|---|
| 1 heran und zuschlagen | ja, ohne Deckung | ja, 1 Deckung | ja, 2 Deckung |
| 2 Schuss und zurück | ja, ohne Deckung | ja, 1 Deckung | ja, 2 Deckung |
| 3 Trank und zuschlagen | ja | ja | ja |
| 4 Waffenwechsel und zuschlagen | ja | ja | ja |
| 5 schwerer Zauber, ein Schritt | nein, nur der Zauber | ja | ja, und noch Deckung |
| 6 von weit heran und zuschlagen | nein | ja, ohne Deckung | ja, 1 Deckung |
| 8 nah zuschlagen, Rest Deckung | ja, 1 | ja, 2 | ja, 3 |
| Abstand zählt | stark, oft zu stark | ja: weit kostet die Deckung | kaum: weit kostet fast nichts |

- **Befund:** Mit 2 Punkten scheitern Wunschzug 5 und 6; mit 4 verliert der Abstand seinen Preis (von weit heran und trotzdem gedeckt). 3 ist die kleinste Zahl, bei der alle Wunschzüge gehen und Abstand trotzdem kostet.
- **Feinere Skala** (etwa 6 Punkte, Schritt 2, Angriff 2, Trank 1): erlaubt halbe Preise (Trank billiger als Schritt), aber sechs Glutmarken am Fuß des Helden sind schwer zu lesen. Erst nötig, wenn ein Wunschzug mit 3 nicht abzubilden ist.
- **Votum Sokrates:** 3 Punkte mit den Probepreisen und der Regel „ein Angriff je Zug“; über die Wunschzüge entscheidet der Chef.
- **Chef:** …

### Rechnung: 3 Punkte gegen 2 (Sokrates, 14.11., 00:50, über Nacht)

Gerechnet mit `handgemenge.py` aus `e38789523` (Formeln und Werte vom 11.11., je Fall 1000 Kämpfe, Autopilot ohne Ring und Tränke wie 930.3), Preise wie im Entwurf 930 (Weg nach Tempo, Schlag 1, Schwung nach Treffer, Rest Deckung). Drei Läufe: 2 Punkte für alle (Gegenprobe, gleich 930.3), 3 für alle, 3 für den Helden und 2 für die Gegner (eine Zeile mehr im Werkzeug: `punkte_gegner`). Schwerer Zauber, Trank und Waffenwechsel kennt das Werkzeug nicht; Wunschzug 3 bis 5 ist damit nicht gerechnet.

**Runden bis zum Sieg** (heute / 2 Punkte / 3 Punkte):

| Fall | heute | 2 | 3 |
|---|---|---|---|
| Wachsoldat gegen Rudel St. 1 | 4,1 | 3,2 | 2,9 |
| Wachsoldat gegen Krogg St. 4 | 8,1 | 5,8 | 5,8 |
| Wachsoldat gegen Grak St. 6 | 8,5 | 6,1 | 5,7 |
| Klosterschüler gegen Krogg | 15,1 | 8,5 | 7,6 |
| Kräutersammler gegen Grak | 9,4 | 7,2 | 6,8 |
| Wanderer gegen Grimmzahn St. 5 | 6,3 | 4,9 | 4,4 |
| Jägerkind (Schütze) gegen Grak | 7,0 | 7,0 | 7,2 |

**Sieg je 100 Kämpfe** (heute / 2 / 3): Kräutersammler gegen Krogg 5 / 38 / 36, gegen Grak 28 / 72 / 76, gegen Rudel 41 / 71 / 77; Herumtreiber gegen Krogg 27 / 70 / 68; Wanderer gegen Grimmzahn 60 / 83 / 87. Mit gezähmtem Schwung (Ungunst, Ausdauer doppelt): Kräutersammler gegen Krogg 15 / 16.

**Befund:**
1. **Der dritte Punkt ändert die Balance kaum.** Die große Verschiebung (schwache Herkünfte gewinnen viel öfter) kommt vom Schwung, nicht von der Zahl; sie ist mit 2 und 3 Punkten fast gleich.
2. **Kämpfe werden noch etwas kürzer,** meist 0,3 bis 0,9 Runden gegenüber 2 Punkten. Der Held setzt den dritten Punkt meist für Schwung ein (Schläge je Runde Wachsoldat 1,29 → 1,42), seltener für Deckung. Wunschzug 1 („heran, zuschlagen, 1 Deckung“) wählt der Autopilot so nicht; ob Deckung einen Punkt wert ist, hängt am Ring (930 Abschnitt F) und ist offen.
3. **Wichtig für Frage 7: Haben die Gegner auch 3 Punkte, verliert der Abstand seinen Preis.** Ein langsamer Zombie (Feld 2 Punkte) kommt dann von fern heran und beißt im selben Zug: Zauberlehrling gegen Zombie, Bisse je Kampf mit 2 Punkten 0,0, mit 3 für alle 1,9, mit 3 für den Helden und 2 für die Gegner wieder 0,0. Die Eröffnung „weit“ hilft dem Schützen mit 3 für alle nicht mehr (Jägerkind gegen Rudel 96 → 91 Siege, gegen Goblin 0,7 → 1,6 Bisse), mit 2 für die Gegner wie bisher.
4. Meine Tabelle oben („Abstand zählt: ja“ bei 3 Punkten) stimmt also nur für den Helden. Für die Gegner gilt die Spalte „2 Punkte“: dort wirkt der Abstand.

**Votum Sokrates (vorläufig):** 3 Punkte für den Helden bleibt richtig (Wunschzug 5 und 6). Gegner nicht einfach mit denselben 3 Punkten, sondern mit 2 oder eigenen Mustern (Frage 7 zusammen mit der Zahl entscheiden). Gegenargument: ungleiche Regeln für Held und Gegner sind schwerer zu durchschauen; dagegen: der Spieler sieht nur, was ein Gegner tut (der Wolf springt und beißt, der Zombie schlurft), nicht dessen Punkte. Vor einer Entscheidung fehlen: Rundenzeit auf dem Bildschirm (931) und eine Rechnung mit Trank, Waffenwechsel und schwerem Zauber, die das Werkzeug noch nicht kann.

### 3. bis 7.

Noch nicht besprochen.
