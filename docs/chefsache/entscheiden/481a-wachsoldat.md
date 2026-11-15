# 481a · Soll der Wachsoldat schwerer werden, weil er in der Rechnung fast nie verliert und Wölfe ihm nichts tun?
Sokrates · 15.11., 10:19 · E Kampf · aus Film 930.7 (Wolf beißt 0) und Rechnung 930.5
Kurz: Wachsoldat gewinnt 100 % gegen alle Gegner von Kapitel 1; ausgleichen über eine Schadensregel für alle, nicht über den Wolf.
Beim Chef, weil: neue Richtung im Spielgefühl (Balance)

Geprüft an: [glut2_ergebnis.md](https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/f27992170/tools/sim444/glut2_ergebnis.md) (400 Kämpfe je Zelle) und [Film 930.7](https://cdn.jsdelivr.net/gh/tramour-cmyk/androidapp_rpg_bornim@film/20261115-012636-930.7/2026-11/15-0126-930.7-Sokrates.mp4); Befund Tuffy 15.11., 01:30

**Frage:** Im Film 930.7 beißen die Wölfe den Wachsoldaten fast immer für 0. Das ist kein Rechenfehler: Rüstung und Schild ziehen 5,5 ab, der Biss macht roh 5,7. Die Rechnung zeigt, dass es nicht am Wolf liegt: der Wachsoldat gewinnt **100 von 100 gegen jeden Gegner in Kapitel 1, auch Krogg, Grimmzahn und Grak**, mit jeder Spielweise. Ist eine Herkunft gewollt, mit der man nicht verlieren kann, oder soll sie schwerer werden?

**Votum:** „481a A“: Jerry rechnet eine Regel für alle: Rüstung und Schild ziehen höchstens die Hälfte eines Treffers ab (jeder Treffer tut etwas); Vorlage mit den Zahlen, erst dann gebaut.

**Berührt:** 481 (Herkünfte ausgleichen, Sokrates), 930.8 (Stufe 3 Glut, wartet auf das Gespräch), Simulation 444 (Jerry), `DESIGN-BRS.md` 4 (Abzug).

**Begründung:** Leitbild „Kampf nie langweilig, echte Wahl“. Gegen einen Gegner ohne Schaden sind Haltung, Wehr und Vertiefen gleichgültig: in der Rechnung haben beim Wachsoldaten alle sieben Spielweisen 100 %. Dann trägt das neue Kampfsystem bei ihm nicht.

**Sachverhalt:**
- Siege je 100 (Held gleiche Stufe; Held eine Stufe drunter): Wachsoldat Rudel 100, Krogg 100 (77), Grak 100 (83); Klosterschüler ebenso 100 (62 bis 77); Kräutersammler Rudel 80, Krogg 62 (29).
- Wolf je Biss gegen Wachsoldat Stufe 3: 0 Schaden in 41 %, 1 in 40 %, 2 in 18 % (`sim.py`); gleiche Stufe 0 in 18 %.
- Seit 02.11. offen in 481: „Wachsoldat 100 %, Klosterschüler lange Kämpfe“.

**Auswertung:**
- **A (Empfehlung): Abzug höchstens die Hälfte des Treffers**, für Helden und Gegner gleich. Wirkt dort, wo das Problem sitzt (viel Rüstung gegen kleine Treffer), lässt Kräutersammler fast unberührt. Kosten: eine Rechnung (etwa 1 bis 2 $), dann Bau klein.
- **B: so lassen.** Der Wachsoldat ist die leichte Herkunft für Ungeübte; die Wahl der Herkunft ist dann auch die Wahl der Schwierigkeit.
- **C: Wölfe stärker** (Schaden oder Rudelgröße). Trifft alle; der Kräutersammler verliert schon heute jeden fünften Rudelkampf. Nicht empfohlen.
- **Stärkstes Gegenargument gegen A:** Rüstung verliert Wert; wer Schwere Rüstung wählt, spürt sie weniger. Ob der Wachsoldat dann unter Krogg leidet, weiß man erst nach der Rechnung, darum Vorlage vor dem Bau.

**Folgerungen:** A: Zeile 481.2 an Jerry (Rechnung `glut2.py` mit Deckel 50 %, dazu 40 und 60 %), Vorlage an dich, Film 930.7 bleibt. B: 481a schließen, Wachsoldat in der Heldenerschaffung als „leicht“ kennzeichnen (Homer). C: Rechnung Wolf an Jerry.

Antwort: …
