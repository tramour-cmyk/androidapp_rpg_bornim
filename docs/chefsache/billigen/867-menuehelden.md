# 867 · Vorentscheid „Vorlage 6 der Menühelden passt“ billigen?
Sokrates · 13.11., 03:14 · G Stil · Vorentscheid in der Nacht (Archiv 1077), Vorlage Tom 03:11 aus Sokrates 02:06 („867, Vorlage 5 B“)
Kurz: Vorlage 6: die Wachsoldatin hält das Schwert gesenkt in der rechten Hand, der Schild sitzt am linken Arm mit der Fläche schräg zum Spieler; die drei anderen wie in Vorlage 5. Die Fäuste auf dem Knauf erreicht die gekaufte Figur nicht (nachgestellt), darum der Ersatz, den Sokrates dafür bestimmt hat.

Geprüft an: [Lauf 413](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/43343150706), [Commit e7b740a](https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/e7b740ab18f1ffeff56945f48558b87526ec9399) (Zweig `claude/tom-867-vorlage5`), Hauptmenü am Bauserver mit den gekauften Figuren wie im Spiel; oben von vorn (wie im Menü), unten um 270 Grad gedreht; 90 und 180 Grad im Lauf ebenfalls angesehen

![Oben die vier Helden von vorn: Wachsoldatin mit Kettenhemd, das Schwert gesenkt in der rechten Hand, die Klinge schräg zum Boden, der Rundschild am linken Arm mit der Fläche schräg zum Spieler; Zauberlehrling, Jägerkind und Klosterschülerin wie in Vorlage 5. Unten dieselben von der Seite: der Schild am Unterarm der Wachsoldatin, die Klinge zeigt nach vorn unten](../bilder/867-vorlage6.jpg)

**Frage:** Passt Vorlage 6 so?

**Entschieden:** passt (Votum Tom A). Jede der vier hat eine eigene Haltung, Waffe und Schild sind von vorn zu sehen; die Wachsoldatin hält das Schwert in der Hand (dein Wort 21:55 „Waffe in der Hand“), der Schild sitzt am Arm. Einbau im nächsten Sammelbuild; im Menü am Feuer nicht so dicht, dass der Schild den Zauberlehrling verdeckt.

**Berührt:** 431 (Körperbau je Volk, nach dem Umzug); 870.13 (Fußzeile „SRD 5.1 · CC BY 4.0“, Umzug).

**Begründung:** Sokrates 13.11., 02:06: „Fäuste auf dem Knauf; greift das am Rechner nicht, statt dessen Schwert gesenkt in der rechten Hand, Hand am Griff, keine dritte Bastelrunde; Schild am linken Arm, Fläche schräg zum Spieler“.

**Sachverhalt:**
- Ursache, am Rechner mit den gekauften Figuren nachgestellt: die Wachsoldatin reicht mit dem Arm 51,5 cm, der Knauf des Langschwerts liegt 54 bis 58 cm von ihrer Schulter. Auch mit dem Griff näher am Körper (6,2 cm daneben) oder tiefer gefasst (14 cm daneben) kam sie nicht hin.
- Jetzt: Grundhaltung „Stehen“, die rechte Hand 65 Grad gesenkt, die Klinge zeigt schräg nach vorn unten; die linke Hand 60 Grad gedreht, der Schild zeigt die Fläche schräg zum Spieler und hängt am Arm, nicht mehr frei am Boden.
- Alle vier Blickrichtungen angesehen: nichts schwebt, die Klinge geht nicht durch das Bein, der Schild nicht durch den Körper.
- **Mir ist aufgefallen:** der Schild liegt von vorn nah am Zauberlehrling, berührt ihn aber nicht. Rot im Lauf waren `pruefliste_1020` (Spalte „Passt“, 1087) und `ziege_4162` (1079), beide nicht 867; dazu `menuehelden_867`, der noch das Aufstützen verlangte: angepasst (83bc870).

**Auswertung:**
- **A (entschieden):** passt, Einbau im nächsten Sammelbuild.
- **Stärkstes Gegenargument gegen A:** das Muster 292.3 („stützt beide Hände auf das Schwert“) ist nicht erreicht, und die gesenkte Klinge ist von vorn schmal vor dem dunklen Mantel. Dagegen: mit der gekauften Figur geht das Aufstützen nicht ohne Bücken (nachgestellt); dein Wort 21:55 war „Waffe in der Hand“, und der Schild ist groß und deutlich.
- **B (verworfen):** die Wachsoldatin beugt sich leicht vor, um den Knauf zu erreichen. Gegen B: eine dritte Bastelrunde, die Sokrates ausgeschlossen hat, und gebückt wirkt sie nicht wie eine Wache.

**Umgesetzt:** Vorlage auf `claude/tom-867-vorlage5` (e7b740a, 83bc870); Einbau ins Hauptmenü folgt.

**Rückbau:** sagst du „zurück“, bleibt das alte Menübild, und du sagst, was an Vorlage 6 nicht passt.

**Kosten:** Einbau (Haltungen, `hauptmenue.gd`), Test im Build.

**Folgerungen:** A: Tom baut ein (Haltungen in den Block „Held je Klasse“, `hauptmenue.gd` statt des alten Bilds), 867 wird im Build getestet. B: neue Vorlage, ein Lauf.

Antwort: …
