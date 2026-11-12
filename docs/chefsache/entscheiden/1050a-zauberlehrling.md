# 1050a · Zauberlehrling: Punkte der Herkunft nach 952 D neu verteilen?
Sokrates · 12.11., 17:24 · G Balance · aus 952 D Zaubergrundwert (dein Wort 11.11., 20:00: „Verstand als Grundwert da ganz entscheidend“) und Rechnung 1050 (Jerry)
Kurz: Seit der Zauberschaden aus Verstand kommt, legt die Herkunft Zauberlehrling ihre Punkte noch auf Wille. Vorschlag: Verstand und Wille je 3, wie beim Jägerkind Schaden und Kritisch je 3.

Geprüft an: [Rechnung `rechnung_1050a.py`, Commit dd999ebe4](https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/dd999ebe4/tools/sim444/rechnung_1050a.py) (Simulation 444, Jerrys Rechnung 1050 mit 9 Punkten; 2000 Kämpfe je Boss, 300 Läufe, Mittel aus drei Zufallsreihen), `werte.json` „herkuenfte“, `brs_held.gd` `waehle_herkunft` (main), `DESIGN-BRS.md` Grundwerte und Heldenerschaffung, Archiv 952 D, 984 A, 644a; gegengelesen (Helfer, 10 Punkte eingearbeitet)

**Frage:** Die Herkunft verteilt die 9 Punkte der Erschaffung vor (der Spieler kann sie ändern). Beim Zauberlehrling liegen sie so: Wille +5, Verstand +1, Zähigkeit +2, Gewandtheit +1. Das passte, als Wille den Zauberschaden gab. Seit 952 D gibt ihn Verstand; Wille gibt Mana, kritische Zauber und Schutzmagie. Soll die Herkunft neu verteilen, und wie?

**Votum:** „1050a A“: Die Herkunft Zauberlehrling legt je 3 Punkte auf Verstand und Wille statt Wille 5, Verstand 1; Zähigkeit +2 und Gewandtheit +1 bleiben.

**Berührt:** 952 D, 984 A, 644a (Grundwert steigt durch Üben), 481 (Kräutersammler, Wachsoldat, Klosterschüler ausgleichen, offen), 1058 (Jerry: Simulation rechnete mit 6 statt 9 Punkten), Erschaffung (Punkte der Herkunft), Simulation 444

**Begründung:** Wer die Herkunft Zauberlehrling nimmt und die Punkte so lässt, beginnt mit Verstand 4, also fast dem kleinsten Zauberschaden (Untergrenze 3, höchstens 8). Gegen Krogg gewinnt er so nur 12 von 100 Kämpfen; schwächer ist nur der Kräutersammler. Das ist keine Absicht, sondern eine Lücke aus 952 D. Mit Verstand 3 und Wille 3 rückt er zu Herumtreiber und Schmiedelehrling auf, ohne dass eine Regel sich ändert.

**Sachverhalt:**
- **Rechnung, Siege auf Bossstufe** (Krogg Stufe 4, Grimmzahn 5, Grak 6; gerechnet mit „Grundwert steigt durch Üben“ nach 644a), dazu der Anteil verlorener Kämpfe auf Stufe 1:

| Zauberlehrling | Krogg | Grimmzahn | Grak | verloren auf Stufe 1 |
|---|---|---|---|---|
| heute: Wille 5, Verstand 1 | 12 % | 56 % | 66 % | 7 % |
| A: Verstand 3, Wille 3 | 23 % | 59 % | 76 % | 4 % |
| B: Verstand 5, Wille 1 | 34 % | 55 % | 64 % | 3 % |
| C: Punkte wie heute, Zauberschaden doppelt je Punkt Verstand | 37 % | 74 % | 83 % | 2 % |

- **Die übrigen Herkünfte zum Vergleich:** Herumtreiber 25 / 53 / 76 % (verloren auf Stufe 1: 14 %), Schmiedelehrling 31 / 48 / 77 % (3 %), Jägerkind 36 / 58 / 86 % (12 %), Wanderer (verteilt selbst, gerechnet mit einem angenommenen Kämpfer) 41 / 60 / 85 % (2 %). Wachsoldat und Klosterschüler gewinnen fast immer, der Kräutersammler selten (12 / 27 / 62 %, verloren auf Stufe 1: 38 %). Diese Ausreißer gehören zu 481, nicht hierher.
- **Mana** kommt aus Wille (10 + 5 × Wille): heute 50, bei A 40, bei B 30. Nach dem Bannschild in der ersten Runde (4 Mana) reicht das für etwa 11, 9 oder 6 Funkenpfeile je Kampf.
- **Grenze der Rechnung:** Die Simulation rechnet ohne Volk. Ein Mensch legt sein freies +1 auf den höchsten Wert, heute also Wille 9 (55 Mana), bei A Verstand 7.
- **Rechenfehler gefunden:** Jerrys Rechnung 1050 (16:56) gab der Herkunft nur 6 der 9 Punkte (ohne Zähigkeit +2, Gewandtheit +1); darum stand der Zauberlehrling dort schlechter da (7 / 44 / 55 %). Die Rechnung von 00:12 (7 / 30 / 45 % ohne 644a) passt zu denselben 6 Punkten. Die Zahlen hier geben alle 9 Punkte wie das Spiel; die Werkzeugkorrektur hat Jerry als 1058.

**Auswertung:**
- **A (Empfehlung) Verstand 3, Wille 3:** Gegen Krogg knapp unter Herumtreiber und Schmiedelehrling, gegen Grimmzahn über beiden, gegen Grak gleichauf; seltener verloren als heute. Verstand für den Schaden und Wille für Mana und kritische Zauber stehen gleich, so wie beim Jägerkind Gewandtheit (Schaden) und Wahrnehmung (kritisch) je 3. Nur Zahlen in der Datei der Herkünfte, keine Regel.
- **B Verstand 5, Wille 1:** Gegen Krogg am stärksten, gegen Grak so schwach wie heute (64 %), dazu das wenigste Mana (30).
- **C Zauberschaden doppelt je Punkt Verstand:** Stärkste Wirkung, aber dann zählt beim Zauber der Grundwert doppelt, bei jeder Waffe einfach. Die Regel „Zauber wie Waffe“ (`DESIGN-BRS.md`) bräche, und ab Kapitel 2 wüchse der Abstand mit jedem Punkt Verstand.
- **D so lassen:** Wer klug verteilt, kann es selbst ändern; wer der Herkunft folgt, spielt einen Magier mit fast dem kleinsten Zauberschaden.
- **Stärkstes Gegenargument gegen A:** Gegen Krogg bleibt der Zauberlehrling mit 23 % Vorletzter, und die Herkunft ist nur ein Vorschlag. Antwort: Der Abstand zu Herumtreiber (25 %) ist klein, bei Grimmzahn und Grak steht er in der Mitte. Wer mehr will, verteilt selbst; die Herkunft soll niemanden in die Schwäche führen. Mehr gegen Krogg gäbe nur B, und das kostet bei Grak.

**Folgerungen:**
- **Bei A oder B:** Jerry ändert „plus“ des Zauberlehrlings in `werte.json` (Spiel und Simulation lesen dieselben Zahlen); Homer prüft, ob der Satz bei der Erschaffung („Zu Magier oder Kriegsmagier“) passt; ich ziehe `DESIGN-BRS.md` nach.
- **Bei C:** Jerry ändert die Formel, ich die Regel „Zauber wie Waffe“.
- Die Rechnung „Gewandtheit je Kampfstil“ (984 A) rechnet Jerry mit 1058 neu; Abweichungen kommen als eigene Vorlage.

Antwort: „1050a A“, „1050a B“, „1050a C“ oder „1050a D“
