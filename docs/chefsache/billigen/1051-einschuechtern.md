# 1051 · Vorentscheid billigen: vorläufige Zahlen für „Verjag den Späher (Einschüchtern)“?
Sokrates · 12.11., 22:06 · G Balance · aus 807 A und 807a A, Bau 841 Jerry
Kurz: Den Goblin-Späher verjagen gelingt anfangs zu 45 %, an der Rangdecke von Kapitel 1 zu 59 %, je Heldenstufe über dem Späher 5 % mehr; wie Überreden

Geprüft an: [Commit 3f26edb52](https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/3f26edb52) auf `claude/jerry-841-einschuechtern` (`godot/regeln/mars.gd` `einschuechtern_chance`, `tools/sim444/werte.json` „proben“ „_einschuechtern“); `DESIGN-BRS.md` 3 und 4; Vorentscheid 1038 (Überreden, Archiv)

**Frage:** Mit 807 A soll man den Goblin-Späher zu Beginn des Kampfs verjagen können. Jerry hat es gebaut (841, Build 281 Punkt 281.6), die Zahlen sind vorläufig. Ich habe sie übernommen. Billigst du das?

**Entschieden:**
- **Chance:** 35 % + 1 % je Punkt Einschüchtern + 5 % je Heldenstufe über der Stufe des Spähers (darunter 5 % weniger), höchstens 95 %, mindestens 5 %. Ohne die Fertigkeit 35 %, mit Startwert 10 sind es 45 %, an der Rangdecke von Kapitel 1 (24) 59 %, jeweils auf gleicher Stufe wie der Späher.
- **Folge:** Gelingt es, flieht der Späher mit einer Zeile, du bekommst die Erfahrung wie für einen Sieg über ihn, aber nicht seine Beute; der Kampf geht gegen die übrigen weiter. Misslingt es, beginnt der Kampf mit allen. Jeder Versuch übt Einschüchtern, auch ein misslungener.

**Umgesetzt:** `3f26edb52` auf `claude/jerry-841-einschuechtern` (841, Jerry), in Build 281.

**Rückbau:** drei Zahlen in `werte.json` („einschuechtern_basis“, „einschuechtern_je_punkt“, „je_stufe“).

**Kosten:** keine eigenen, läuft mit 841.

**Berührt:** 841 (Jerry), 807 A, 1038 (Überreden, gleiche Zahlen), 133 (Einschüchtern in Kapitel 2)

**Begründung:** Dieselben Zahlen wie beim Überreden (Vorentscheid 1038), damit beide Gesellschaftsfertigkeiten gleich viel wert sind; dazu die Stufe, weil ein starker Held einen schwachen Späher eher vertreibt, und die gilt in allen Proben schon (5 % je Stufe). Ohne Grundwert, weil BRS 3 sagt: „Charisma gibt es nicht; die soziale Wirkung kommt aus Ruf und Gesellschaftsfertigkeiten.“ Üben bei jedem Versuch nach BRS 4 („du wirst, was du tust“).

**Sachverhalt:**
- **Rechnung im Code** (`mars.gd`): genau die Formel oben, begrenzt auf 5 bis 95; der Startwert jeder Fertigkeit ist 10 (`werte.json` „held“), die Decke in Kapitel 1 ist Anfänger, also 24 (BRS 4).
- **Andere Proben:** 50 % + 5 je Grundwertpunkt Unterschied + 5 je Stufe; Überreden 35 % + 1 je Punkt (1038).
- **Wahl nur, wo ein Späher dabei ist,** nie mit Krogg oder Grak (Commit 841).

**Auswertung:**
- **Jerrys Zahlen (entschieden):** Anfangs ein Wagnis, das mit Übung und Stufe sicherer wird; am Ende von Kapitel 1 (Einschüchtern 24, fünf Stufen über dem Späher) liegt es bei 84 %. Das passt: wer stark ist, vor dem flieht der Späher.
- **Höher, etwa 50 % Grundwert (verworfen):** dann ist Einschüchtern von Anfang an fast sicher und die Fertigkeit muss man nicht üben.
- **Mit Grundwert Kraft oder Wille (verworfen):** widerspricht BRS 3.
- **Stärkstes Gegenargument:** Der Versuch kostet nichts; misslingt er, kämpft man ohnehin, also versucht es jeder immer, und das ist keine echte Wahl (Leitbild). Antwort: Du hast es selbst so gewollt (133, 19.10.: „wenn die Charisma-Probe scheitert, muss ich ja eh kämpfen“), und der Preis ist die Beute des Spähers, die beim Verjagen ausfällt. Soll ein Fehlschlag mehr kosten (etwa: die Goblins schlagen zuerst), wäre das Spielgefühl und damit deine Entscheidung; ich schlage es nicht vor.
- **Noch offen, nicht Teil dieses Vorentscheids:** Einschüchtern gegen andere Gegner (`DESIGN-KAMPF.md` 224) ist nicht gebaut; Ruf wirkt noch nicht (BRS 13).

**Folgerungen:** Bei „gebilligt“ lösche ich die Datei und setze „gebilligt“ ins Archiv. Bei „zurück“ nennst du die Zahl, die du willst; Jerry ändert sie in `werte.json`.

Antwort: „1051 gebilligt“ oder „1051 zurück, …“
