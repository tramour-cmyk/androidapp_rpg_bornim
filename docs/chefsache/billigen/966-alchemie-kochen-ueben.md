# 966 · Wodurch üben Alchemie und Kochen in Kapitel 1?
Sokrates · 11.11., 15:36 · E Welt · Vorentscheid auf Vorschlag Homer (aus 963, Tom 14:56)
Kurz: Alchemie übt bei Morwens Sud, Kochen beim Braten am Lagerfeuer; beide bleiben wählbar.

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/9a34fec2a (Umzugszweig `claude/tom-870-4-held`)

**Frage:** Alchemie (Chance auf einen Trank mehr, wenn Morwen braut) und Kochen (mehr Leben beim Essen) wirken im Umzugszweig, werden aber nie geübt. Das verletzt die Prüfregel in `DESIGN-BRS.md` 3: Eine Fertigkeit gibt es nur mit einer Tätigkeit, die sie übt, und einer Wirkung, die man merkt. Wodurch üben sie?

**Votum:** Entschieden (Vorentscheid Sokrates, 783 W5): „966 A“. Antwort „gebilligt“ oder „zurück“.

**Berührt:** 966.1 (Homer, ein Satz am Kessel), 966.2 (Tom, Übung im Umzugszweig, 870.4), 954a (D), 481

**Begründung:** Beide Fertigkeiten bleiben nach 954a D wählbar („Kräuterkunde und Alchemie wirken schon und bleiben wählbar“; Jagd liefert Fleisch, „das geht in Kochen und Handel“). Dann brauchen sie eine Tätigkeit. Beide Tätigkeiten gibt es im Spiel schon; neu ist nur, dass sie üben.

**Sachverhalt:**
- Alchemie wirkt in `laden.gd` 19 und 202 (`brau_chance`, je Punkt 1 % auf einen zweiten Trank); `braue` übt nichts.
- Kochen wirkt in `laden.gd` 26 und `menue.gd` 718 (`essen_bonus`). Gekocht wird schon: Bei der Rast am Lagerfeuer kommt rohes Fleisch aufs Feuer und wird Braten (`rast.gd` 76–80). Das übt bisher nichts.
- `uebe` rufen heute nur Handeln (`laden.gd` 87, 97) und Kräutersammeln.
- Homer schlug für Kochen vor, es in Kapitel 1 nicht wählbar zu machen („Essen ist kein Kochen“). Das übersieht das Braten am Feuer.

**Auswertung:**
- **A (entschieden):** Alchemie übt bei jedem Sud, den Morwen braut; der Held geht ihr am Kessel zur Hand (Satz Homer, 966.1). Kochen übt bei jedem Stück, das am Lagerfeuer brät. Kosten: zwei Aufrufe von `uebe` und ein Test (Tom, klein).
- **B (verworfen, Homer b):** Kochen in Kapitel 1 nicht wählbar, bis ein Feldkoch kommt. Dann läuft `essen_bonus` in Kapitel 1 ins Leere, und wer Kochen gewählt hat, hat eine tote Wahl; genau die verbietet 954a.
- **Stärkstes Gegenargument gegen A:** Übung gegen Gold und Kräuter: Wer viel brauen lässt (×5, `braue_mehr`), kauft sich Alchemie. **Weg:** Jede Übung folgt „Durch Tun“ (`DESIGN-BRS.md` 3): Zu leichte Ziele bringen kaum etwas, und jeder Rang endet an einer Prüfung. Gold und Kräuter sind knapp; Grinden darf man, muss man nie (Leitbild 3).
- **Abgleich:** Leitbild 3 (Grinden freiwillig) passt; Stil und Aussehen unberührt (nur ein Satz, von Homer); Kampf unberührt; Abnahme (`DESIGN-ABNAHME.md`) nennt beides nicht; BRS 3 (Prüfregel, „Durch Tun“) wird erst damit erfüllt; Archiv: 954a D, 857a A (Trankwirkung nach Alchemie, 481) widersprechen nicht.

**Folgerungen:** Homer schreibt den Satz (966.1), Tom baut beide Übungen in den Umzugszweig (966.2), danach Test des Chefs mit dem Build.

**Umgesetzt:** noch nicht (966.2).

**Rückbau:** zwei Zeilen entfernen; Kochen dann wie Homer b.

**Kosten:** unter einer Sitzung Tom, ein Satz Homer.

Antwort: …
