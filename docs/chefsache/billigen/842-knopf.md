# 842 · Vorentscheid „Pim, Osric und Verband passen“ billigen?
Sokrates · 13.11., 00:03 · E Welt · Vorentscheid in der Nacht (Archiv 1077), nach deinem „nö, passt nicht“ 20:48
Kurz: Pim hat drei Knöpfe, Osric „Kaufen“ und „Nicht jetzt“, der Verband steht in Tasche und Laden; Osric bekommt noch einen Satz, der sagt, was er verkauft

Geprüft an: [Commit 3641ee7e4](https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/3641ee7e4) (`claude/spike-842`, `geschichte.gd` 123–135), Bild Tom 00:00 (`ansehen/842-knopf.md`, gelöscht 13.11., 00:03, in Git; Bild `bilder/842-knopf.webp`)

**Frage:** Erfüllt der neue Stand deine Funde von 20:31 bis 20:33 (Pim nur ein Knopf; bei Osric „wo ist denn hier weiter?“)?

**Entschieden:** Ja, 842 und 1086 fahren im nächsten Build. Dazu ein Rest: Osric sagt vor „Kaufen“ in einem Satz, dass er Verbände hat (Text Homer 1088, Einbau Tom vor dem Build; kommt der Text nicht rechtzeitig, steht es in der Prüfliste als „bekannt“).

**Berührt:** 842, 1086 (Tom), 1088 (Homer), 1074, 1085

**Begründung:** Pim: „Schick Pim heim (Überreden) ›“ und „Gib Pim 5 Gold ›“ rechts, „‹ Nicht jetzt“ links, Pim sagt „Brandflaschen“, genau wie Homer 1074 und 1085. Osric: der fehlende zweite Knopf ist da. Tippen auf den Text überspringt keine Wahl mehr, das ▼ ist bei stehenden Knöpfen weg. Offen ist nur, dass „Kaufen“ direkt unter der Heilzeile steht, ohne dass einer sagt, was es zu kaufen gibt. Das wäre dein erster Fund im Tempel.

**Sachverhalt:**
- Bild 1 Pim, Bild 2 Osric nach der Heilung, Bild 3 Verband in der Tasche („Stillt Blutung … Nur außerhalb des Kampfs“), Bild 4 Thessas Laden mit Verband 8 Gold.
- Osric verkauft nur Verbände (807 A, `OSRIC_STOCK`); vor „Kaufen“ steht heute die Erzählzeile `[504.osric.heilung]`.
- Das rote ▼ neben der Robe im Laden heißt „schlechter als getragen“ und ist kein Fehler.

**Auswertung:**
- **A (entschieden):** passt, plus Angebotssatz bei Osric.
- **B (verworfen):** noch einmal zurück an Tom mit neuem Bild. Das kostet eine Runde für einen Satz.
- **Stärkstes Gegenargument gegen A:** ein neuer Satz ohne Bild geht ungeprüft in den Build. Dagegen: es ist eine Sprechzeile in einem Kasten, den du schon kennst, und du siehst sie im Test.

**Folgerungen:** Homer schreibt 1088 (ein Satz, drei Wortlaute wie `[504.osric.*]`); Tom setzt ihn vor „Kaufen“ und nimmt 842 mit 1086 in den nächsten Build, mit den Zahlen von 1084 (`claude/tuffy-1084`). Sagst du „zurück“, legt Tom 842 neu vor.

**Umgesetzt:** 842 und 1086 gebaut auf `claude/spike-842`; der Satz fehlt noch.

**Rückbau:** 842 auf „startbar“ mit deinem Fund.

**Kosten:** ein Satz Homer, eine Zeile Tom.

Antwort: …
