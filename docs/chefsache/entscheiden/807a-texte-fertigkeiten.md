# 807a · Texte zu Pim überreden, Goblin-Späher einschüchtern und Verband so nehmen?
Homer · 10.11., 10:39 · G Story · aus 807 A (Chef 09.11., 22:26: Texte zuerst dir)
Kurz: Zwölf Marken in `STORY-K1-FERTIGKEITEN.md`, wiederholte Zeilen in drei Wortlauten; Knöpfe nennen die Fertigkeit

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/92b2f63f3/godot/skripte/geschichte.gd (Pim 67–71; dazu `spiel.gd` 466, `regeln/tabellen.json`, `skripte/erschaffung_brs.gd` 65; fremd geprüft 10.11., 10:38)

**Frage:** Für die drei neuen Stellen aus 807 A liegen die Texte vor, Deutsch und Englisch, in `docs/STORY-K1-FERTIGKEITEN.md`. Beispiele:
- Pim, gelingt: Pim: „Na gut. Aber nur, weil du es bist.“ Erzähler: Pim trottet heim, mit einem letzten Blick zum Schlagbaum. Misslingt: Pim: „Du klingst wie Mama.“ Erzähler: Er verschränkt die Arme und rührt sich nicht. Danach Pims Mutter einmal: „Pim kam heim, ganz zahm. Was du ihm auch gesagt hast: danke, {name}.“
- Späher, gelingt: Der Späher weicht zurück, Schritt um Schritt, und rennt. Misslingt: Ein kehliges Lachen. Der Goblin legt einen Pfeil auf.
- Verband: „Saubere Leinenstreifen, fest gerollt. Außerhalb des Kampfs anlegen; wer Heilkunde versteht, holt mehr heraus.“ Anlegen: Ein fester Knoten, und das Blut steht. +{0} TP.

Dazu eine Frage zur Form: Soll der Knopf die Fertigkeit nennen („Schick Pim heim (Überreden)“, „Verjag den Späher (Einschüchtern)“) oder nur die Handlung („Schick Pim heim“, „Verjag den Späher“)?

**Votum:** „807a A“: Texte so, Knopf mit Fertigkeit.

**Berührt:** Tom (Pim, Verband), Jerry (Einschüchtern, mit Tiere beruhigen 3.6), 504 (drei Wortlaute), 471 (Fertigkeiten durch Tun)

**Begründung:** Dein Wort 09.11., 20:51 (Wortlaut in `ARBEIT-KREATIV.md` „Zu 807, von Spike“: „Es gibt keine Fertigkeiten, die losgelöst vom Kampf sind … da sollte man dann schon nochmal ein bisschen drauf [schauen]“): der Spieler soll merken, dass hier eine Fertigkeit wirkt und geübt wird. Steht sie im Knopf, sieht er das, ohne Zahlen.

**Sachverhalt:**
- Pim streift tagsüber im Dorf (`geschichte.gd` 67–71); seine Mutter sagt schon „Wenn du ihn am Schlagbaum siehst, schick ihn heim.“ (`[504.tuer.pim]` Wortlaut 1, `spiel.gd` 466).
- Der Goblin-Späher heißt in Godot so (EN „Goblin Scout“, `tabellen.json` „goblin_archer“) und trägt einen Kurzbogen (`LISTE-BESTIARIUM.md`); er läuft im Wald und in der Höhle, darum kein „Unterholz“ im Text. Er kommt auch zusammen mit einem Goblin; dann flieht nur er.
- Englische Fertigkeitsnamen wie im Spiel: Persuasion, Intimidation, Medicine (`erschaffung_brs.gd` 65, `[423.fert.liste]`).
- Heilung wie alle Heilmeldungen im Spiel „+{0} TP“ / „+{0} HP“ (`STORY-SPIEL.md`); ob TP überall „Leben“ heißen soll (BRS), ist eine eigene Frage, nicht diese.
- Wiederholte Zeilen (gelingt, misslingt, Anlegen) je drei Wortlaute; einmalige Zeilen, Knöpfe und Systemmeldungen je einer (504).

**Auswertung:**
- **A (Empfehlung):** Texte so, Knopf nennt die Fertigkeit. Kosten: keine über den Bau hinaus.
- **B:** Texte so, Knopf nur mit der Handlung; welche Fertigkeit wirkt, sieht man nur im Heldenblatt, wenn sie steigt. Kosten: gleich.
- **Stärkstes Gegenargument gegen A:** Ein Fertigkeitsname im Gespräch klingt nach Regelwerk und bricht das Eintauchen; die Handlung „Schick Pim heim“ sagt genug. Dagegen: ohne Namen merkt der Spieler nicht, warum es mal gelingt und mal nicht.

**Folgerungen:** Homer setzt die Texte fest (Entwurf weg); je ein Vorgang an Tom (Pim, Verband) und Jerry (Einschüchtern).

Antwort: …
