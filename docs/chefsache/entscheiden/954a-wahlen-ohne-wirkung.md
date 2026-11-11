# 954a · Sollen in der Erschaffung von Kapitel 1 nur Fertigkeiten zur Wahl stehen, die dort etwas bewirken?
Homer · 11.11., 14:18 · E Kampf · aus 954.1 (Sätze zum Gedrückthalten)
Kurz: 13 der 36 frei wählbaren Fertigkeiten und ein Volksmerkmal tun in Kapitel 1 nichts; wie bei Bergbau ausblenden, statt „wirkt noch nicht“ zu sagen.

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/9a34fec2a (Umzugszweig `claude/tom-870-4-held`; Code und `tools/sim444/werte.json`, fremd geprüft 14:15), Texte `STORY-BRS-ERSCHAFFUNG.md`

**Frage:** Für die Erklärung bei langem Druck (954, dein „ja“ 13:55) habe ich je Fertigkeit nachgesehen, ob sie im Spiel etwas tut. Wer als Wanderer oder Mensch frei wählt, kann heute Fertigkeiten nehmen, die in Kapitel 1 nirgends wirken; ebenso tut das Merkmal des Hügelvolks nichts. Die Erklärung muss dann ehrlich „In diesem Kapitel wirkt das noch nicht.“ sagen. Sollen solche Fertigkeiten wie Bergbau (461c) gar nicht erst zur Wahl stehen?

**Votum:** „954a A“

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

Antwort: …
