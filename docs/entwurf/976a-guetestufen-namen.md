# 976a · Wie heißen die vier Gütestufen?
Sokrates · 11.11., 18:05 · E Welt · aus deinem Wort 17:53 („schlechter, normaler, hoher und meisterlicher Güte? Dann hätten wir 4 Gütestufen“) und 17:58 („pack's doch mal zusammen mit 976 rein“)
Kurz: Vier Gütestufen sind entschieden; offen ist nur der Name: Schlecht, Normal, Gut, Meisterhaft (Empfehlung) oder Schlecht, Normal, Hoch, Meisterlich.

Geprüft an: main `091fcb2a8`: `DESIGN-BRS.md` „Alle Stufen auf einen Blick“ und 11 (Vier Achsen, Einzelstücke); `VORGANGSARCHIV.md` 870a 6 A (10.11., 15:08); `godot/regeln/brs_held.gd` 433, 458 (Güte als Zahl 0 bis 2, noch ohne Namen und ohne Wirkung)

**Frage:** Jedes Ding hat künftig eine Güte in vier Stufen, von unten Schlecht bis zur besten (entschieden im Gespräch 17:53–18:01, steht im Vorgangsarchiv). Im Spiel steht die Güte als Wort am Ding, etwa im Gegenstandsfenster und in der Tasche. Du hast „schlecht, normal, hoch, meisterlich“ gesagt; im Regelwerk stehen bisher „Normal, Gut, Meisterhaft“. Welche vier Wörter sollen es sein?

**Votum:** „976a A“: Schlecht, Normal, Gut, Meisterhaft; „hohe Güte“ darf im Erklärtext stehen.

**Berührt:** 976 Tom (Herstellen, Rezeptbuch), 870.7 Tom (Gegenstandsfenster), 644 (Gegenstandskatalog); Texte Homer (`[423.…]` im Handbuch, Gegenstandsfenster); Einzelstücke Graks Kriegsaxt und Klinge von Bornim (870a 6 A).

**Begründung:** Das Wort steht am Ding und muss sich als Eigenschaft lesen: „ein gutes Langschwert“, „ein meisterhafter Heiltrank“. „Hoch“ beschreibt die Güte, nicht das Ding („ein hohes Langschwert“ meint die Länge). „Meisterhaft“ steht schon im Regelwerk für die Einzelstücke (870a 6 A).

**Sachverhalt:**
- Regelwerk heute: Güte „Normal, Gut, Meisterhaft“ (`DESIGN-BRS.md` 11); Graks Kriegsaxt und die Klinge von Bornim sind „Meisterhaft“ (870a 6 A, Chef 10.11., 15:08).
- Code: Güte nur als Zahl 0 bis 2 in `brs_held.gd`, ohne Namen im Spiel; noch keine Wirkung auf Werte. Eine vierte Stufe kostet dort eine Zeile.
- Entschieden (Archiv, 11.11., 18:01): vier Stufen mit Schlecht; Güte nach Rang (Anfänger Schlecht bis Normal, Geselle Schlecht bis Gut, Meister Normal bis Meisterhaft, Großmeister Gut bis Meisterhaft); Güte aus dem Können, Seltenheit aus Zutaten und Rezept; bessere Güte nutzt sich langsamer ab.

**Auswertung:**
- **A (Empfehlung): Schlecht, Normal, Gut, Meisterhaft.** Liest sich am Ding natürlich, deckt sich mit Regelwerk und Einzelstücken. Kosten: keine.
- **B: Schlecht, Normal, Hoch, Meisterlich** (dein Wortlaut). Klingt gehobener; aber „hoch“ passt nicht als Wort am Ding, und „Meisterhaft“ der Einzelstücke wechselt.
- **C: Schlecht, Normal, Gut, Meisterlich.** „Meisterlich“ klingt älter und passt zum düsteren Ton; Einzelstücke ziehen mit (nur Text).
- **Stärkstes Gegenargument gegen A:** „Normal“ und „Gut“ klingen schlicht, fast technisch, und passen schwach zur Sprache der Welt; Homer könnte eigene Wörter wollen (etwa „Grob, Gewöhnlich, Fein, Meisterhaft“). Dagegen: der Spieler muss die Reihenfolge ohne Erklärung sehen; „Gut“ über „Normal“ versteht jeder. Wenn dir der Ton wichtiger ist, ist C der kleinste Schritt.

**Folgerungen:** Nach der Antwort trägt Sokrates die Namen in `DESIGN-BRS.md` ein und gibt sie Tom (976, 870.7) und Homer (Handbuch, Gegenstandsfenster).

Antwort: …
