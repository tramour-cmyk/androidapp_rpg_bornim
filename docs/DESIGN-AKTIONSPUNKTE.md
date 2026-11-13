# Aktionspunkte im Kampf: Gespräch Chef und Sokrates

Arbeitsstand des Gesprächs ab 13.11., 23:35, damit der Chef es nachlesen kann (Chef 14.11., 00:07: „Du musst das alles nachhalten, was wir hier erarbeiten, damit ich genau das, so wie wir es hier haben, nachlesen kann. Das muss alles in der Datei jetzt kommen … Eine eigene MD … Wo alles drin ist. Und das muss jetzt nicht in dem Vorgang sein“). Gehört zu 930 (Handgemenge und Abstand), betrifft 1072. Nichts hier ist entschieden, solange unter „Entscheidungen“ kein Wort des Chefs steht. Pflegt Sokrates, nach jedem Gesprächsschritt.

## Warum wir das machen

- **23:35, Chef:** „Also bevor Jerry jetzt wieder irgendwas einfach so entwickelt und viel Zeit verplempert, wird schon die erste Runde, ohne dass wir drüber nachgedacht haben, dann würde ich jetzt sagen, macht mal Jerry nicht weiter und wir machen erstmal unsere Hausaufgaben. Weil was wollen wir zusammenbringen? Was kostet was? Wie kann es laufen? Okay?“ Jerry ist seitdem angehalten (1072 Plätze und Laufwege, 709 und 709.1 Bisse zu kurz).
- **23:48, Chef:** „Ja, ich denke, wir müssen uns vorneweg schon mal einen Kopf machen, ob wir das mit Aktionspunkten machen wollen und was wie viel kostet.“
- **23:50, Chef:** „Weil davon hängt ab, inwieweit Leute wieder zurückweichen können oder nicht, weil was es kostet, zum Beispiel. Was kostet Gehen, was kostet Rennen, was kostet ein Tank nehmen, was kostet ein Waffenwechsel, was kostet ein leichter Zauber, was kostet ein schwerer Zauber. Fragen über Fragen, die man da stellen kann.“ Und: „hör auf, jetzt jedes Mal schon wieder 1000 Dinge im Hintergrund zu machen. Ich bin doch noch am Ideen sammeln mit dir zusammen.“
- **00:03, Chef** (Nachricht brach ab): „So, und jetzt machen wir wieder eins nach dem anderen. Jetzt hast du mir gezeigt, was deine Regelseite heute vorschlägt. … Und daran arbeiten wir jetzt mal und stecken Hirnschmalz rein. … jede einzelne Entscheidung, jede einzelne“. Gelesen als: Entscheidung für Entscheidung durchgehen.

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
- **Chef:** …

### 2. bis 7.

Noch nicht besprochen.
