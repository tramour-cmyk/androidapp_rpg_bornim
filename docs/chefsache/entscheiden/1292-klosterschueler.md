# 1292 · Soll Wundsegen höchstens zweimal je Kampf wirken, damit der Klosterschüler verlieren kann?
Tuffy (Team Jerry) · 16.11., 09:14 · G Balance · aus deinem „481.2 A“ (15.11., 12:44)
Kurz: Der Klosterschüler gewinnt fast immer, weil Wundsegen ihn in jedem Kampf unter halbem Leben so oft heilt, wie das Mana reicht (bis zu achtmal); mit höchstens zwei Segen je Kampf steht er neben dem Wachsoldaten, und wie er kämpft, zählt wieder.
Beim Chef, weil: neue Richtung im Spielgefühl (Balance)

Geprüft an: `99b19c66c` (Zweig `claude/tuffy-1292-klosterschueler`, `tools/sim444/klosterschueler_1292.py`: je Fall 400 Kämpfe, gleicher Zufall für jede Spalte, Rüstung zieht höchstens die Hälfte ab wie seit 481.2 gebaut; Aufruf mit `--politik warten` für das Warten)

**Frage:** Bei 481.2 kam heraus: der Klosterschüler gewinnt gegen jeden Gegner, auch eine Stufe drunter, und auch, wenn er nur wartet. Du hast entschieden, dass ich die Ursache rechne. Die Ursache ist Wundsegen: Fällt er unter die Hälfte seines Lebens, heilt er sich; ein Segen bringt auf Stufe 1 13 Leben (die Hälfte seines Lebens von 25), kostet 5 Mana, und er hat 40 Mana, also acht Segen in jedem Kampf. Soll Wundsegen künftig höchstens zweimal je Kampf wirken?

**Votum:** „1292 A“: Wundsegen höchstens zweimal je Kampf.

**Berührt:** 481 (Herkünfte ausgleichen, Sokrates), 930.8 (Stufe 3 des Kerbensystems), `DESIGN-BRS.md` 4 (Zauber), `werte.json` Wundsegen (Simulation 444 und Spiel), Text der Herkunft bei der Erschaffung („mit Wundsegen schließt du Wunden“) bleibt richtig.

**Begründung:** Leitbild „Kampf nie langweilig, echte Wahl“ und „herausfordernd, aber nicht zu leicht“. Heute ist beim Klosterschüler jede Spielweise gleich gut: er heilt sich aus jeder Lage heraus. Die Heilung soll seine Stärke bleiben, aber nicht jeden Fehler aufheben.

**Sachverhalt:** (Siege in Prozent, Held eine Stufe unter dem Gegner; Vergleich mit Wachsoldat und Schmiedelehrling, zwei anderen Herkünften ohne Heilung; Spielweise „S“ = zuschlagen und Haltung nach der Ansage, wie die Bedienung vorschlägt; „W“ = nur warten und antworten)
- **Gegenprobe ohne Wundsegen:** Der Klosterschüler fällt unter den Schmiedelehrling (gleiche Waffe und Rüstung, ohne Heilung): Krogg 100 → 31 (Schmiedelehrling 59), Wolf mit Goblin-Späher 96 → 18 (56). Andere Ursachen (Leben, Rüstung, Waffe) scheiden damit aus; seine Waffe ist sogar schwächer.
- **Wie oft er heilt:** gegen Krogg (Held Stufe 3, 35 Leben) 3,4 Segen je Kampf, zusammen 1,3-mal sein ganzes Leben (gezählt nur, was wirklich heilt, nicht über das volle Leben hinaus); zwei Stufen drunter (Stufe 2, 30 Leben) 4,8 Segen, 2,1-mal sein Leben. Das Mana reicht für acht.
- **S, eine Stufe drunter, heute / höchstens 2 / höchstens 3 / Wachsoldat / Schmiedelehrling:** Krogg 100 / 72 / 87 / 98 / 59; Grimmzahn 99 / 82 / 88 / 98 / 73; Riesenspinne 100 / 90 / 98 / 100 / 85; Wolf mit Goblin-Späher 96 / 65 / 78 / 92 / 56; Riesenfledermaus 100 / 95 / 98 / 99 / 79; leichte Gegner (Rudel, Kobold, Zombie, Skelett) mit höchstens 2 oder 3 Segen 100.
- **W, eine Stufe drunter, gleiche Reihenfolge:** Riesenfledermaus 100 / 20 / 44 / 54 / 5; Krogg 100 / 67 / 78 / 91 / 48. Heute gewinnt der Klosterschüler auch mit Warten jeden dieser Kämpfe; mit höchstens 2 verliert, wer nur wartet (Fledermaus 20 statt 95 mit S).
- **Gleiche Stufe, S:** mit höchstens 2 gewinnt er 94 bis 100 (Krogg 97); das Kapitel bleibt ohne Grinden schaffbar.
- **Vier Kämpfe ohne Rast** (Rudel, Wolf mit Goblin-Späher, Riesenfledermaus, Riesenspinne; Leben und Mana tragen sich fort), Held Stufe 3, ganze Kette überstanden, S: heute 92, höchstens 2: 62, höchstens 3: 84, Wachsoldat 63, Schmiedelehrling 5.
- **Andere Hebel gerechnet:** doppelte Kosten (10 Mana, vier Segen): eine Stufe drunter weiter 88 bis 100, mit Warten gegen Krogg 90; halbe Heilung: er segnet dann öfter (bis 7-mal) und gewinnt eine Stufe drunter 61 bis 100, in der Kette nur 26.
- **Alter Kampf:** dort betet er nach einem perfekten Ring zusätzlich (Wundsegen ohne Mana, `mars.gd`); das ändert kaum etwas (0 bis 5 Punkte). Das Kerbensystem kennt das Gebet nicht.

**Auswertung:**
- **A (Empfehlung): höchstens zwei Segen je Kampf.** Der Klosterschüler gewinnt eine Stufe drunter gegen schwere Gegner 65 bis 90 (Wachsoldat 92 bis 100), in der Kette gleichauf mit ihm; Warten verliert, Zuschlagen gewinnt. Bau klein (Regelkern des Kampfs, Simulation, `werte.json`, Kerntest); wie die Bedienung die übrigen Segen zeigt, kommt als Bild zu dir.
- **B: höchstens drei.** Milder: eine Stufe drunter 78 bis 100, in der Kette über dem Wachsoldaten (84 zu 63); Warten gegen die Fledermaus 44.
- **C: doppelte Kosten (10 Mana).** Im einzelnen Kampf höchstens 12 Punkte weniger, eine Stufe drunter weiter 88 bis 100; trifft nur Ketten ohne Rast.
- **D: nichts ändern.** Er bleibt unverlierbar, jede Spielweise gewinnt.
- **Stärkstes Gegenargument gegen A:** Eine feste Zahl je Kampf ist eine neue Art Regel, die das Spiel bisher nicht hat (Zauber kosten nur Mana); der Spieler muss sie lernen. Antwort: Nur Mana als Grenze greift nicht, weil 40 Mana für mehr Segen reichen, als ein Kampf braucht (C zeigt es); die Grenze betrifft nur einen Zauber und lässt sich an seinem Knopf zeigen.

**Folgerungen:** Bei A oder B baut Jerry die Grenze (ohne Test durch dich: automatischer Test und Gegenrechnung im Spielcode) und trägt sie in `DESIGN-BRS.md` ein (über Sokrates, 481). Bei C ändert sich nur `werte.json`. Bei D nichts.

Antwort: …
