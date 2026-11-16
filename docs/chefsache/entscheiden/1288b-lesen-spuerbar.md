# 1288b · Soll das Lesen der Ansage spürbar werden, und wie?
Sokrates · 16.11., 06:52 · Bereich Kampf · aus 1288 Kerben (dein Satz 15.11., 12:00 „Ist das nicht irgendwie eine Lücke im System?“; deine Antwort 1288a A: ungenutzte Kerben verstreichen weiter, die Lücke „falsche Haltung kostet zu wenig“ kommt ins Gespräch)
Kurz: Heute bringt gutes Lesen kaum etwas (1 Sieg je 100 mehr). Mit zwei kleinen Regeln sind es 10 mehr, gegen Bosse bis zu 40 mehr; Kämpfe dauern gleich lang, Siege insgesamt 1 je 100 weniger.
Beim Chef, weil: Spielgefühl und Aussehen (was das Zeichen über dem Gegner auf der untersten Lesestufe zeigt)

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/93dd006f1/tools/sim444 (`claude/sokrates-1288-lesen`): Rechnung `lesen_1288.py`, Ausgabe `lesen_1288_ergebnis.txt` ebenda, Grundlage die Kerbenrechnung `glut2.py` vom Kerbenzweig `claude/jerry-1266-kerbe`, je Fall 1000 Kämpfe; Regeln `DESIGN-GLUT.md` 3 (Haltung), 5 (Ansage lesen), 10 (Maße)

**Frage:** Im Kerbensystem sagt jeder Gegner vor seinem Zug an, was er vorhat; das Zeichen über ihm (der Chip) zeigt das. Wie viel der Spieler davon sieht, hängt am Helden: wer gute Wahrnehmung und Spähen hat, liest mehr (Lesestufe 0 bis 3). So steht es als Kern in `DESIGN-GLUT.md` 1 („Information als etwas, das man im Rollenspiel steigert“). Gerechnet wirkt das aber kaum. Soll Jerry zwei Regeln einbauen, damit es wirkt?

**Votum:** „1288b A“: beide Regeln unten.

**Begründung:** Schon auf Stufe 0 zeigt der Chip `!` oder `!!`, also ob ein großer Schlag kommt. Genau davon hängt die richtige Haltung ab (gegen großen Schlag Wehr, sonst Gegenschlag). Die höheren Stufen verraten nur Art, Ziel und Täuschung, und die ändern die Wahl fast nie. Dazu kostet eine falsche Haltung wenig: Wehr hilft gegen kleine Schläge genauso, Gegenschlag gegen einen großen schadet nicht. Darum ist es, wie du gefragt hast, eine Lücke.

**Die zwei Regeln:**
- **Regel 1, Größe erst ab Stufe 1:** auf Stufe 0 zeigt der Chip nur `!` (es kommt etwas), nie `!!`. Bosse liest man immer mindestens auf Stufe 1, dort ändert sich nichts. Ein Bild braucht es nicht: das Zeichen `!` gibt es heute schon, nur zeigt es auf Stufe 0 jetzt auch große Schläge so.
- **Regel 2, falsche Haltung kostet:** wer in Gegenschlag steht, wenn ein großer Schlag kommt, steht offen: der Schlag trifft leichter (25 Punkte mehr Trefferchance, wie beim Umreißen) und ein Viertel härter. Wehr ist auf den großen Schlag gerichtet: gegen kleine Schläge senkt sie die Trefferchance nur um 15 statt 25 Punkte.

**Sachverhalt** (Rechnung oben; Held eine Stufe unter dem Gegner; 8 schwierige Kämpfe von Goblin-Späher bis Grak, alle 8 Herkünfte):

| | heute | nur Regel 1 | nur Regel 2 | beide |
|---|---|---|---|---|
| Lesestufe 3 statt 0: Siege je 100 mehr, im Mittel | 1 | 4 | 3 | **10** |
| größter Unterschied | 9 | 18 | 18 | **40** (Kräutersammler gegen Grak: 8 → 48) |
| alle 12 Kampffälle, Lesestufe nach dem Helden: Siege je 100 | 95,6 | 95,6 | 94,5 | 94,4 |
| Runden bis zum Sieg | 5,4 | 5,4 | 5,4 | 5,4 |
| Krogg, schwächste Herkunft (Grenze aus `DESIGN-GLUT.md` 10: nicht unter 15) | 60 | 57 | 56 | 56 |
| Fälle, in denen eine feste Spielweise klar vorn liegt (Grenze: höchstens 24 von 96, sonst gäbe es keine echte Wahl) | 14 | – | – | 13 |

**Auswertung:**
- **A (Empfehlung): beide Regeln.** Erst zusammen wird Lesen eine Fähigkeit, die man spürt; einzeln bringen sie nur 3 bis 4. Kampflänge gleich, Siege im Mittel 1 je 100 weniger, alle Grenzen eingehalten.
- **B: nur Regel 2** (Chip bleibt wie heute). Kein neues Aussehen, aber Lesen bleibt fast wirkungslos (3 mehr). Nur Regel 1 biete ich nicht an: sie ändert den Chip für ebenso wenig Wirkung.
- **C: nichts ändern.** Lesen bleibt Schmuck; dann streiche ich den Satz in `DESIGN-GLUT.md` 1.
- **Stärkstes Gegenargument gegen A:** Stufe 0 wird härter als heute; wer schlecht liest, verliert gegen schwer lesbare Gegner öfter (mit beiden Regeln: Kräutersammler auf erzwungener Stufe 0 gegen Grimmzahn 6 von 100, heute 32). Antwort: auf Stufe 0 landet man nur mit wenig Wahrnehmung gegen schwer lesbare Gegner wie Goblins und Untote, gegen Bosse nie; im Mittel sinken die Siege um 1 je 100. Die Rechnung kennt keinen Spieler, der aus Vorsicht Wehr wählt, wenn er nichts sieht; im Spiel ist es eher leichter.

**Berührt:** 1288 Kerben (diese Lücke); 930 Kerbensystem, `DESIGN-GLUT.md` 5 (Ansage lesen) und 12 Punkt 4 (Sokrates trägt nach); 1266 Kerbenzweig (Jerry baut); Ansage-Chip im Kampfbild (Jerry, beim Bau der Lesestufen).

**Folgerungen:** Nach „A“: Jerry baut beide Regeln, Zahlen in `werte.json`, damit sie ohne Umbau zu ändern sind, mit Kerntests und der Rechnung im Spiel gegen `glut2_lesen.py` (Abweichung höchstens 3 Siege je 100); Homer schreibt eine Eingebung beim ersten „offen getroffen“; Sokrates zieht `DESIGN-GLUT.md` nach. Bei B nur Regel 2, bei C nur der Satz in `DESIGN-GLUT.md`.

Antwort: …
