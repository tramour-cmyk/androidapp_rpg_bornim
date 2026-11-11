# 976a · Wie heißen die vier Gütestufen?
Sokrates · 11.11., 18:16 · E Welt · aus deinem Wort 17:53 („schlechter, normaler, hoher und meisterlicher Güte? Dann hätten wir 4 Gütestufen“) und 17:58 („pack's doch mal zusammen mit 976 rein“)
Kurz: Vier Gütestufen sind entschieden; offen ist nur der Name: Schlecht, Normal, Gut, Meisterhaft (Empfehlung) oder deine Wörter Schlecht, Normal, Hoch, Meisterlich.

Geprüft an: [main 84db9a2fb](https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/84db9a2fb): `DESIGN-BRS.md` „Alle Stufen auf einen Blick“ (Zeile Güte) und 11 (Vier Achsen, Einzelstücke); `VORGANGSARCHIV.md` „Güte: vier Stufen …“ (11.11., 18:01) und 870a 6 A (10.11., 15:08); `godot/regeln/brs_held.gd` 433, 458; Gegenlesung durch einen Helfer 18:04 (Funde eingearbeitet)

**Frage:** Jedes Ding hat künftig eine Güte in vier Stufen, von unten Schlecht bis zur besten (entschieden im Gespräch 17:53–18:01, steht im Vorgangsarchiv). Im Spiel steht die Güte als Wort am Ding, etwa im Gegenstandsfenster und in der Tasche. Du hast „schlecht, normal, hoch, meisterlich“ gesagt; im Regelwerk stehen vorläufig „Schlecht, Normal, Gut, Meisterhaft“ mit dem Vermerk „Namen beim Chef“. Welche vier Wörter sollen es sein, deutsch und englisch?

**Votum:** „976a A“: Schlecht, Normal, Gut, Meisterhaft (englisch Poor, Common, Fine, Masterwork); „von hoher Güte“ darf im Erklärtext stehen.

**Berührt:** 976 Tom (Herstellen, Rezeptbuch), 870.7 Tom (Gegenstandsfenster), 644 (Gegenstandskatalog); Homer (Handbuchtext zur Güte, Gegenstandsfenster); Einzelstücke Graks Kriegsaxt und Klinge von Bornim (heute „Meisterhaft“, 870a 6 A).

**Begründung:** Das Wort steht am Ding und muss die Reihenfolge ohne Erklärung zeigen. „Gut“ über „Normal“ versteht jeder; „Meisterhaft“ steht schon für die Einzelstücke (870a 6 A), es ändert sich also nichts im Bestand.

**Sachverhalt:**
- Regelwerk: Güte vorläufig „Schlecht, Normal, Gut, Meisterhaft (Namen beim Chef)“ (`DESIGN-BRS.md` „Alle Stufen auf einen Blick“ und 11); Graks Kriegsaxt und die Klinge von Bornim sind „Meisterhaft“ (870a 6 A, Chef 10.11., 15:08).
- Code: `brs_held.gd` reicht die Güte als Zahl weiter (`int(aus.get("guete", 0))`, ohne feste Grenze; Tests mit 0 und 2); keine Namen, keine Wirkung auf Werte, sonst nirgends im Godot-Code verwendet.
- Entschieden (Vorgangsarchiv 18:01, ausgeschrieben in `DESIGN-BRS.md` „Alle Stufen auf einen Blick“): vier Stufen mit Schlecht; die Spanne hängt vom Rang ab (Anfänger Schlecht bis Normal, Geselle Schlecht bis Gut, Meister Normal bis Meisterhaft, Großmeister Gut bis Meisterhaft), Ring und Material entscheiden darin; Seltenheit aus Zutaten und Rezept; bessere Güte nutzt sich langsamer ab.
- Spieltexte und Namen gehen sonst über Homer; hier fragst du selbst nach den Namen, darum liegt die Wahl bei dir, Homer schreibt danach die Texte.

**Auswertung:**
- **A (Empfehlung): Schlecht, Normal, Gut, Meisterhaft** (Poor, Common, Fine, Masterwork). Klar in der Reihenfolge, deckt sich mit Regelwerk und Einzelstücken. Kosten: keine.
- **B: Schlecht, Normal, Hoch, Meisterlich** (dein Wortlaut). Klingt gehobener; am Ding als „von hoher Güte“ gut lesbar, als kurzes Wort in der Tasche („Langschwert, hoch“) missverständlich; die Einzelstücke wechseln auf „Meisterlich“ (nur Text).
- **C: Schlecht, Normal, Gut, Meisterlich.** „Meisterlich“ klingt älter und passt zum düsteren Ton; sonst wie A.
- **D: Homer schlägt eigene Wörter vor** (etwa „Grob, Gewöhnlich, Fein, Meisterhaft“), du wählst danach. Passt am besten zur Sprache der Welt, kostet eine Runde mehr.
- **Stärkstes Gegenargument gegen A:** „Normal“ klingt technisch und liest sich am Ding so schwach wie „hoch“ („ein normales Langschwert“); „Meisterhaft“ lässt sich mit dem Rang „Meister“ und der „Meisterschaft“ verwechseln, gerade weil der Meister-Rang erst Meisterhaft erlaubt. Dagegen: die Nähe ist gewollt (der Meister macht Meisterhaftes); „Normal“ steht in der Tasche meist gar nicht, nur die Abweichungen. Wiegt der Ton für dich schwerer, ist D der Weg.

**Folgerungen:** Nach der Antwort trägt Sokrates die Namen in `DESIGN-BRS.md` ein und gibt sie Tom (976, 870.7) und Homer (Handbuchtext, Gegenstandsfenster); bei D zuerst Vorgang an Homer.

Antwort: …
