# 1352a · Wann taumelt ein Gegner im Kampf mit Kerben?
Homer · 16.11., 00:20 · E Kampf · aus 1352 (Jerry: Regel zum Taumeln fehlt, gefunden beim Abgleich des Kerbensystems mit den Regeln, 1275)
Kurz: Taumeln wie im alten Kampf (ein Fünftel seines Lebens seit seiner Ansage) oder im Kampf mit Kerben streichen?
Beim Chef, weil: neue Richtung im Spielgefühl (Kampfregel und Balance)

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/ce3dda066/godot/regeln/kerbe.gd (Zweig `claude/jerry-1266-kerbe`, `_absicht`, `brechen`), `main` `00df20b44` (`godot/regeln/mars.gd` `BREAK_SHARE`), `DESIGN-GLUT.md` Regeln 8 und 19, Simulator `tools/sim444/glut2.py` (Zweig `claude/sokrates-930-glut`); fremd geprüft 16.11., 00:16

**Frage:** Die Regeln des neuen Kampfs mit Kerben (`DESIGN-GLUT.md`) sagen zweimal, dass ein Gegner taumeln kann. Regel 8: „Ein Gegenschlag, der tötet oder taumeln lässt, bricht den Angriff ab.“ Regel 19: „Zurückdrängen, Netz verbrennen und Taumeln lassen einen angesagten großen Schlag ins Leere gehen.“ Wann ein Gegner taumelt, sagen sie nicht. Der gebaute Kampf mit Kerben lässt deshalb nie einen taumeln. Die Spieltexte versprechen es aber: der Tipp zum Gegenschlag („Fällt er davon oder taumelt er, bleibt sein Schlag aus“) und die Ansage des schweren Hiebs („vorher ein Fünftel seines Lebens nehmen, dann taumelt er und der Zug ist verloren“). Entweder gilt eine Regel, oder die Texte werden geändert.

**Votum:** „1352a A“: Taumeln gilt wie im alten Kampf. Hat ein Gegner seit seiner Ansage ein Fünftel seines Lebens verloren, taumelt er, und sein angesagter großer Schlag geht ins Leere. Es zählt jeder Schaden: dein Schlag, ein Gegenschlag, der Schlag eines Freundes.

**Berührt:** 1352 (Regel in `DESIGN-GLUT.md`, Homer); 1275 (Jerry: der gebaute Kampf mit Kerben weicht von den Regeln ab, Jerry gleicht an); Messung im Simulator (Sokrates); die Texte `[1267.tip.gegenschlag]` und `[870.14.ansage.heavy]` in `STORY-BRS-KAMPF.md` (Homer).

**Begründung:** Den Schlag zu brechen, bevor er fällt, ist eine Wahl im Kampf: ich sehe den schweren Hieb kommen und entscheide, ob ich ihm mit Schaden zuvorkomme, mich in Wehr stelle oder auf den Ring setze (Leitbild: jeder Zug eine echte Wahl). Die Regel ist gebaut (`mars.gd`) und bekannt; die Texte stimmen dann ohne Änderung.

**Sachverhalt:**
- Alter Kampf (`mars.gd` auf `main`): ein angesagter Schlag bricht, wenn der Gegner seit der Ansage ein Fünftel seines Lebens verloren hat (`BREAK_SHARE = 5`; schwerer Hieb, Kraft sammeln, Gift sammeln, Durchbrechen), oder bei jedem Schaden (Flanke, Einkreisen, Schatten).
- Kampf mit Kerben (`kerbe.gd` `_absicht`): jede Ansage ist ausdrücklich „nie brechbar über Schaden wie im alten Kampf (Brechen ist Regel 19)“. `brechen()` gibt es, ruft aber niemand auf, auch nicht für Zurückdrängen und Netz verbrennen.
- `DESIGN-GLUT.md`: Regel 8 und 19 nennen das Taumeln ohne Schwelle.
- Simulator `glut2.py`: kennt weder Taumeln noch Brechen. Die Siegzahlen, auf denen der Kampf mit Kerben beruht, sind ohne beides gemessen.
- Zurückdrängen und Netz verbrennen brechen ebenfalls nie; das sind keine Fragen der Regel (sie ist dort klar), sondern des Baus. Jerry gleicht sie in 1275 an.

**Auswertung:**
- **A (Empfehlung):** Schwelle wie im alten Kampf, ein Fünftel des Lebens seit der Ansage, jeder Schaden zählt, nur für angesagte große Schläge. Jerry ruft `brechen()` dafür auf (klein); Sokrates misst im Simulator nach, bevor die Werte abgenommen werden. Ein Satz im Tipp zum Gegenschlag wird genauer: „Fällt er davon, bleibt sein Schlag aus; taumelt er, geht ein großer Schlag ins Leere.“
- **B:** Kein Taumeln im Kampf mit Kerben. Regel 8 und 19 verlieren das Wort; Homer schreibt den Tipp zum Gegenschlag und die Ansage des schweren Hiebs neu (gegen den schweren Hieb helfen dann Wehr, der Ring, Zurückdrängen). Kein Bau fürs Taumeln, keine neue Messung.
- **C:** Taumeln nur durch einen Gegenschlag, ohne Schwelle: wer einem großen Schlag mit einem Gegenschlag zuvorkommt, bricht ihn immer. Einfach zu lesen, aber dann gewinnt der Gegenschlag fast jeden Zweikampf gegen große Schläge; Sokrates müsste zuerst messen, vermutlich wäre es zu dämpfen. Die Ansage des schweren Hiebs („ein Fünftel seines Lebens“) schreibt Homer neu.
- **Stärkstes Gegenargument gegen A:** Der Kampf mit Kerben gibt gegen große Schläge schon drei Antworten (Wehr, Gegenschlag, Ring); die Schwelle macht daraus leicht ein Rennen um Schaden, das der stärkste Held immer gewinnt, statt einer Wahl. Der Code lässt sie ausdrücklich weg. Dazu ist der Simulator ohne Taumeln gemessen: Gegner mit großen Schlägen, vor allem Grak und Krogg, werden mit A leichter als gemessen. Darum A nur mit der Nachmessung; sind die Bosse danach zu leicht, setzt man bei ihnen die Schwelle höher (Einzelheit der Balance, kein neuer Entscheid).

**Folgerungen:** Bei A trägt Homer die Schwelle in `DESIGN-GLUT.md` Regel 19 ein und passt den Tipp zum Gegenschlag an, Jerry baut in 1275, Sokrates misst nach. Bei B schreibt Homer Regel 8, 19 und die beiden Texte um; `brechen()` bleibt für Zurückdrängen und Netz. Bei C misst Sokrates zuerst, dann baut Jerry, Homer schreibt die Ansage neu.

Antwort: …
