# 1084 · Vorentscheid „Pim zählt als Stufe 1, Handeln bleibt ohne Probe“ billigen?
Sokrates · 12.11., 23:08 · E Kampf · Vorentscheid in der Nacht (Archiv 1077), aus Tuffys Befund 23:06 zu 1051 A
Kurz: Für die Überreden-Probe bei Pim gilt Stufe 1; Handeln bekommt vorerst keine Probe

Geprüft an: [Commit 096ac8149](https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/096ac8149) auf `claude/tuffy-1084` (`werte.json`, `mars.gd`, Simulation 444 über alle Kapitel)

**Frage:** Deine Formel 1051 A rechnet 30 % + 0,6 je Punkt + 5 je Stufe über dem Gegner. Zwei Dinge fehlen: (1) Pim ist ein Kind ohne Stufe. Gegen welche Stufe wird gerechnet? (2) Handeln hat im Spiel bisher keine Probe, nur den Preisnachlass (0,2 % je Punkt). Bekommt es jetzt eine?

**Entschieden:**
- (1) Pim zählt als Stufe 1.
- (2) Handeln bleibt vorerst ohne Probe. Die Formel liegt in `werte.json` bereit und wird gebaut, sobald eine Szene sie braucht (Text Homer).

**Berührt:** 1051 A, 1084 (Jerry/Tuffy), 842 und 1086 (Tom), 1085

**Begründung:** Mit Stufe 1 bleibt Pim am Anfang ein echtes Wagnis und wird erst mit dem Helden leichter. Wenn Pim keine Stufe hat, entfällt der Stufenteil der Formel, und dann wirkt es so, als wäre das Kind so stark wie der Held. Für Handeln gibt es in Kapitel 1 keine Szene, in der man feilscht. Eine Probe ohne Szene wäre Bau ohne Nutzen.

**Sachverhalt:**
- Tuffy hat 1051 A auf `claude/tuffy-1084` gebaut. Tiere beruhigen gelingt in Kapitel 1 zu 29 bis 36 %. Über alle Kapitel gegen das Gebietsband: Start 10 Punkte 26–61 %, Ende Kapitel 1 bei 24 Punkten 34–69 %, Geselle 49–84 %, Meister 64–95 %.
- Überreden auf `claude/spike-842` rechnet heute ohne Stufe (Hinweis Tuffy bei Team Tom, Zu 842).
- Handeln: `DESIGN-BRS.md` Gesellschaft (Überreden, Einschüchtern, Handeln), im Spiel nur der Preisfaktor.

**Auswertung:**
- **A (entschieden):** Pim Stufe 1. Ein Held auf Stufe 1 mit 10 Punkten hat 36 %, auf Stufe 6 mit 24 Punkten am Ende von Kapitel 1 69 %.
- **B (verworfen):** Pim Stufe 0 (+5 von Anfang an, 41 %). Das macht den Unterschied zum sicheren Gold-Weg (1085) kleiner, ohne dass es etwas bringt.
- **C (verworfen):** Handeln jetzt bauen. Dafür gibt es keine Szene, das wäre Bau ohne Nutzen.
- **Stärkstes Gegenargument gegen A:** Bei 36 % misslingt das Überreden am Anfang meistens. Nach einem Fehlschlag fehlen nach Homers Text 1085 an diesem Tag beide Knöpfe, auch der Gold-Knopf, das wirkt hart. Dagegen spricht: Am nächsten Tag geht es wieder, und Gold ist der sichere Weg für den, der nicht würfeln will. Genau das ist die echte Wahl.

**Folgerungen:** Tom rechnet in 842 und 1086 mit Stufe 1 für Pim, Tuffy setzt den Wert in `werte.json`. Handeln bleibt, wie es ist. Sagst du „zurück“, gilt Pim ohne Stufe, und Handeln wird gebaut, wenn du es willst.

**Umgesetzt:** noch nichts, nur dieser Entscheid; Bau mit 842 und 1084.

**Rückbau:** den Wert für Pim auf „ohne Stufe“ setzen.

**Kosten:** keine eigenen, eine Zahl in `werte.json`.

Antwort: …
