# 1085 · Vorentscheid „Pim heimschicken auch für 5 Gold“ billigen?
Sokrates · 12.11., 22:33 · G Story · Vorentscheid in der Nacht (Archiv 1077), aus deinem Wort 20:31
Kurz: Pim lässt sich auch für 5 Gold heimschicken, sicher, aber ohne Übung und ohne Ruf

Geprüft an: [Commit aab1e6c88](https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/aab1e6c88) `STORY-K1-FERTIGKEITEN.md` (Überreden: Pim heimschicken, 1074), alte Fassung `Story.kt` 229–234, [LISTE-SIMULATION-444.md](../../LISTE-SIMULATION-444.md) 7

**Frage:** Bekommt Pim neben „Schick Pim heim (Überreden)“ und „Nicht jetzt“ (1074) einen dritten Knopf, mit dem man ihn für Gold heimschickt?

**Entschieden:** Ja, „Gib Pim 5 Gold“. Das gelingt immer, kostet 5 Gold und übt keine Fertigkeit; die Mutter dankt mit einer eigenen Zeile, der Ruf steigt nicht. Text Homer 1085, Bau Tom 1086 nach 842.

**Berührt:** 842 (Tom), 1074, 807 A, 1051 A, 1085 (Homer), 1086 (Tom)

**Begründung:** Du hast es selbst genannt (20:31: „Es gibt weder ein Abbrechen, noch ein Gib PIM 5 Goldstücke oder sonst was“). Das Abbrechen ist mit 1074 gelöst, das Gold fehlt noch. Damit gibt es eine echte Wahl: Überreden kostet nichts, kann aber misslingen (dann erst am nächsten Tag wieder) und übt die Fertigkeit; Gold ist sicher, kostet aber etwas und bringt weder Übung noch Ruf.

**Sachverhalt:**
- In der alten Fassung hat Pim nur Sprüche und keine Wahl (`Story.kt` 229–234).
- Der heutige Weg steht in `STORY-K1-FERTIGKEITEN.md` unter „Überreden: Pim heimschicken“. Überreden gelingt nach 1051 A mit 30 % + 0,6 je Punkt, am Anfang also selten.
- Gold in Kapitel 1 (Simulation 444 Teil 7): fünf Herkünfte haben am Ende 17 bis 38 Gold, Heilung kostet 20 bis 60.

**Auswertung:**
- **A (entschieden):** 5 Gold, sicher, ohne Übung und Ruf. Kosten: ein Text, ein kleiner Bau im Baustein `Skript.knopf`.
- **B (verworfen):** eine Probe auf Handeln mit Gold. Zwei Proben für ein Kind sind zu viel.
- **C (verworfen):** 1 Gold. Das ist kein Preis.
- **Stärkstes Gegenargument gegen A:** Ist Gold sicher, nimmt am Anfang jeder das Gold, und das Überreden verliert seinen Sinn. Dagegen halten zwei Dinge: nur das Überreden bringt Ruf und Übung, und Gold ist in Kapitel 1 knapp. Das zweite Gegenargument: 842 ist zweimal zurückgekommen, und mehr Umfang verzögert es. Deshalb wird 1086 erst nach 842 gebaut, als eigener Vorgang.

**Folgerungen:** Homer schreibt 1085 (Knopf, drei Wortlaute für Pims Antwort, Dankzeile der Mutter). Tom baut 1086, sobald 842 und 1085 fertig sind. Sagst du „zurück“, fallen 1085 und 1086 weg.

**Umgesetzt:** noch nichts gebaut, nur die Vorgänge 1085 und 1086.

**Rückbau:** beide Vorgänge streichen, der Knopf entfällt.

**Kosten:** ein Text Homer, ein kleiner Bau Tom.

Antwort: …
