# 954a · Sollen in der Erschaffung von Kapitel 1 nur Fertigkeiten zur Wahl stehen, die dort etwas bewirken?
Homer · 11.11., 14:18 · E Kampf · aus 954.1 (Sätze zum Gedrückthalten)
Kurz: 13 der 36 frei wählbaren Fertigkeiten und ein Volksmerkmal tun in Kapitel 1 nichts; wie bei Bergbau ausblenden, statt „wirkt noch nicht“ zu sagen.

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/9a34fec2a (Umzugszweig `claude/tom-870-4-held`; Code und `tools/sim444/werte.json`, fremd geprüft 14:15), Texte `STORY-BRS-ERSCHAFFUNG.md`

**Frage:** Für die Erklärung bei langem Druck (954, dein „ja“ 13:55) habe ich je Fertigkeit nachgesehen, ob sie im Spiel etwas tut. Wer als Wanderer oder Mensch frei wählt, kann heute Fertigkeiten nehmen, die in Kapitel 1 nirgends wirken; ebenso tut das Merkmal des Hügelvolks nichts. Die Erklärung muss dann ehrlich „In diesem Kapitel wirkt das noch nicht.“ sagen. Sollen solche Fertigkeiten wie Bergbau (461c) gar nicht erst zur Wahl stehen?

**Votum:** „954a D“ (Mittelweg, unten; vorher A)

**Berührt:** 954 (Tom, Erschaffung), 841, 842 (Einschüchtern, Überreden, Heilkunde), Herkünfte, Volksmerkmale (Jerry; `LISTE-UMZUG-BRS.md`: „Wirkung neu“), 959, 960

**Begründung:** Leitbild: „echte Wahl“; eine Wahl, die nichts bewirkt, ist eine Falle für Anfänger. Für Bergbau ist das schon so entschieden (461c: zeigt sich ab Kapitel 2, zur Wahl erst dann).

**Sachverhalt:**
- Ohne Wirkung im Umzugszweig (von 36 frei wählbaren): Wurfwaffen (keine Waffe gehört dazu), Schleichen, Spähen, Schlösser knacken, Fallen entschärfen, Illusion, Beschwörung, Tiere beruhigen, Angeln, Jagd, Schmieden, Lederarbeit, Runenkunde; dazu Überreden, Einschüchtern, Heilkunde, bis 841 und 842 gebaut sind.
- Mit Wirkung (20): die übrigen Waffen, alle Rüstungen, Ausweichen, Evokation, Schutzmagie, Heilmagie, Handeln, Kräuterkunde, Alchemie, Kochen.
- Volksmerkmale: Glückskind (Hügelvolk) wirkt nur im alten Kampf `klassisch.gd`, der entfällt (870a 2). Wachsame Sinne (Elf, gegen Lähmung durch den Grabhund), Steinblut, Letzter Atemzug, Wandelbar wirken.
- Herkünfte bringen tote Fertigkeiten mit: Herumtreiber (Schleichen, Spähen), Jägerkind (Wurfwaffen, Spähen), Kräutersammler (Spähen), Klosterschüler (Heilkunde bis 842), Schmiedelehrling (Schmieden, Bergbau; ihm fehlt Stumpfe Waffen aus 461c, Vorgang 959).
- Verstand wirkt heute gar nicht (870d steht im Code, liest aber keiner; Vorgang 960).
- Der Heldenreiter zeigt schon Wirkungen, die der Code nicht hat (Abwehr gegen Krankheit, Furcht und Zauber, Flächenwirkungen; Metall sperrt Zauber); das geht als Fund an Tom (870.4), unabhängig von dieser Frage.

**Auswertung:**
- **A (Empfehlung):** wie Bergbau: frei wählbar nur, was in Kapitel 1 wirkt (heute 20, mit 841 und 842 dann 23); die übrigen kommen zur Wahl, sobald ein Kapitel sie braucht. Herkünfte bleiben, wie sie sind; ihre toten Fertigkeiten erklärt der Satz „wirkt noch nicht“. Glückskind bekommt eine Wirkung im MARS (Jerry, Wert über 444). Kosten: Liste „nicht_waehlbar“ in `werte.json` (klein, Tom mit 954), ein Merkmal (Jerry, unter einer Sitzung).
- **B:** alles bleibt wählbar, jede tote Wahl sagt „In diesem Kapitel wirkt das noch nicht.“ Kosten: keine; der Schirm zeigt den Satz bis zu 16-mal.
- **C:** die fehlenden Wirkungen in Kapitel 1 bauen (Schleichen, Spähen, Truhen, Fallen …). Kosten: je Fertigkeit eine bis mehrere Sitzungen; Inhalt eher für spätere Kapitel.
- **Stärkstes Gegenargument gegen A:** wer einen Schleicher spielen will, findet das in Kapitel 1 nicht und kann es später nicht nachträglich zur Startfertigkeit machen; und Herumtreiber und Jägerkind bleiben in Kapitel 1 schwächer, weil je zwei ihrer drei Fertigkeiten nichts tun.

**Folgerungen:** Bei A trägt Tom die Liste mit 954 ein, Jerry bekommt einen Vorgang für Glückskind; die Sätze `[954.1.…]` gelten unverändert (Bauregel dort).

**Stellungnahme Sokrates (11.11., 14:28):** Ich empfehle A. Es widerspricht nichts Entschiedenem, sondern folgt dem Grundsatz „Sichtbar wird nur, was man getan hat“ (`DESIGN-BRS.md` „Durch Tun“) und der Bergbau-Regel (461c). Weil man Fertigkeiten durch Tun später ohnehin bekommt, verliert der Schleicher weniger, als Homers Gegenargument sagt. Die Kosten sind klein. Das stärkere Gegenargument ist ein anderes: Die eigentliche Falle bleibt bei den Herkünften. Herumtreiber und Jägerkind tragen je zwei Fertigkeiten, die in Kapitel 1 nichts tun, und die Herkunft wählt man vor den freien Fertigkeiten. Deshalb sollten diese beiden Herkünfte als eigene Frage zu Homer und dann zu dir kommen, statt nur „wirkt noch nicht“ zu zeigen.

**Chef 11.11., 15:10 (Wortlaut, gekürzt):** „Bergbau … aus meiner Sicht wäre eigentlich die Fertigkeit eher, weil es ja auch Sammeln ist, Erze sammeln … von mir aus können wir es auch Bergbau nennen. Aber das ist eine Sammeleigenschaft, genauso wie Kräuter sammeln oder mal zukünftig Pilze sammeln oder Wacholder sammeln … Und das andere ist sowas Elementares wie Schleichen, was eine Basisfertigkeit einer Herkunft ist … Und das kann man aus meiner Sicht nicht miteinander in einen Topf schmeißen … ich kann noch nicht schmieden, weil noch keine Schmiede da ist. Okay, aber ich weiß, hey, das kann ich halt dann irgendwann … warum sollte ich mich dann wirklich für irgendeine Herkunft entscheiden, wenn halt da wirklich die Basisfertigkeiten nicht verfügbar stehen. Macht doch da mal ein paar Vorschläge, was wir machen könnten und was wir definitiv ab Kapitel 2 erst einführen. Wäre so der goldene Mittelweg.“

**D, Mittelweg (Sokrates, 15:12, nach Chef 15:10; ersetzt meine Empfehlung A):** Zwei Arten von Fertigkeiten, getrennt behandelt.
- **Grundfertigkeiten wirken ab Kapitel 1**, je mit genau einer Wirkung an etwas, das es schon gibt:
  1. **Schleichen:** Schleichtaste auf der Gebietskarte; die Herde bemerkt den Helden erst, wenn Schleichen unter ihrer Wachsamkeit liegt (`DESIGN-BRS.md` „Schleichen und Hinterhalt“). Den Hinterhalt (HERO_FIRST, `herde.gd` 127, 231) gibt es heute nur über die Blickrichtung; Schleichen macht ihn planbar, mit dem Ring R3 aus 930.
  2. **Spähen:** Eine Herde zeigt vorher ihre Stärke (ein Zeichen „zu stark“) und ob sie lauert. Das ist genau, was du 14:42 für den Anfänger willst: Stärkere erkennen und einen Bogen machen.
  3. **Schlösser knacken:** Verschlossene Truhen und Türen ohne Schlüssel öffnen (Truhen und das Schlüsselzeichen gibt es, `aktionsknopf.gd`); zwei, drei Truhen in Dorf und Höhle mit besserem Inhalt. Fehlschlag: der Dietrich bricht.
  4. **Wurfwaffen:** Wurfmesser im Laden; der MARS kennt Fernkampf schon.
  5. **Tiere beruhigen:** Handlung im Kampf gegen Tiere (Wolf, Wildschwein): Das Tier weicht oder flieht, nicht der Leitwolf; passt zu 930 (Feuer drängt Tiere).
  6. **Jagd:** Tiere geben mehr und bessere Beute (Fell, Fleisch), das geht in Kochen und Handel.
  7. **Fallen entschärfen:** drei Fallen in der Höhle; Spähen findet sie, Entschärfen löst sie, sonst Schaden.
  - Überreden, Einschüchtern, Heilkunde kommen mit 841 und 842; Glückskind bekommt eine Wirkung im MARS (Jerry).
- **Sammeln und Handwerk kommen mit der Welt** (ab Kapitel 2): Bergbau, Angeln, später Pilze und Wacholder, dazu Schmieden, Lederarbeit, Runenkunde (Meisterschaften mit Werkstatt und Lehrmeister). In der Erschaffung stehen sie sichtbar in einer eigenen Gruppe „Sammeln und Handwerk“ mit dem Satz „Kommt, wenn die Welt es bietet“ und sind in Kapitel 1 nicht wählbar. Kräuterkunde und Alchemie wirken schon und bleiben wählbar.
- **Magieschulen Illusion und Beschwörung** kommen mit den Pfaden ab Kapitel 2, in der Erschaffung ebenso sichtbar, aber nicht wählbar.
- **Schmiedelehrling** ist die eine Herkunft, die der Mittelweg nicht rettet: Schmieden und Bergbau tun in Kapitel 1 nichts. Vorschlag: Schmieden wirkt in Kapitel 1 als Schärfen am Lagerfeuer (die Waffe trifft im nächsten Kampf härter), dazu Stumpfe Waffen aus 959.
- **Reihenfolge**, wenn du nicht alles willst: Schleichen und Spähen zuerst (drei Herkünfte hängen daran, und beide stärken den Kampf), dann Wurfwaffen und Schlösser, zuletzt Tiere, Jagd, Fallen.
- **Stärkstes Gegenargument:** Sieben Wirkungen vor dem Ende von Kapitel 1 sind viel Arbeit (meine Schätzung: je eine bis zwei Sitzungen, Tom und Jerry rechnen nach), und die Oberste Direktive sagt Qualität vor Menge. **Weg:** Die Oberste Direktive nennt die Möglichkeiten des Spielers ausdrücklich; jede Wirkung hängt an Vorhandenem, und es gibt genau eine je Fertigkeit; was nicht gut wird, wandert in die Gruppe „kommt später“.
- **Votum:** „954a D“ (oder D bis Nummer n der Reihenfolge, A, B, C).

Antwort: …
