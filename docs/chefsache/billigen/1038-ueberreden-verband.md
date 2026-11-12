# 1038 · Vorentscheid billigen: vorläufige Zahlen für Pim überreden und den Verband?
Sokrates · 12.11., 16:06 · E Kampf · aus 807 A (Chef 09.11., 22:26), Bau 842 Tom, Zahlen Jerry 1037
Kurz: Überreden gelingt anfangs zu 45 %, an der Rangdecke zu 59 %; ein Verband heilt anfangs 7 Leben und kostet 8 Gold, nur außerhalb des Kampfs

Geprüft an: [Commit 7696371e0](https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/7696371e0) auf `claude/jerry-1037-werte` (`werte.json`, `LISTE-REGELWERTE.md` „proben“, „welt.verband“, „wirtschaft.preise“); `godot/skripte/rast.gd` auf `main` (Rast); `DESIGN-BRS.md` 3, 4, 13; `STORY-K1-FERTIGKEITEN.md` „Überreden“, „Heilkunde: Verband“

**Frage:** Mit 807 A hast du drei neue Fertigkeiten ohne Kampf gewollt, darunter Pim überreden (heimschicken) und den Verband. Tom hat beides gebaut (842), es fehlten die Zahlen. Jerry hat sie vorgeschlagen, ich habe sie übernommen. Billigst du das?

**Entschieden:**
- **Überreden:** Chance 35 % + 1 % je Punkt Überreden, gegen Pim ohne Abzug. Ohne die Fertigkeit 35 %, mit Startwert 10 sind es 45 %, an der Rangdecke von Kapitel 1 (24) 59 %. Misslingt es, geht es am nächsten Tag wieder. Jeder Versuch übt, auch ein misslungener.
- **Verband:** heilt 5 Leben + 1 je 5 Punkte Heilkunde, also mit Heilkunde 10 genau 7, mit 24 genau 10, mit 100 genau 25. Er kostet 8 Gold, hat Stufe 1 und liegt bei Osric und Thessa. Anlegen geht nur außerhalb des Kampfs, jedes Anlegen übt Heilkunde um 1.

**Umgesetzt:** `7696371e0` auf `claude/jerry-1037-werte` (1037, Jerry); kommt mit 842 in den nächsten gemeinsamen Build.

**Rückbau:** vier Zahlen in `werte.json`.

**Kosten:** keine eigenen, läuft mit 1037 und 842.

**Berührt:** 842 (Tom, Knopf und Verband, Bild beim Chef), 1037 (Jerry, Werte), 807 A

**Begründung:** Beide Zahlen folgen dem, was 807 A und das Regelwerk schon festlegen; offen war nur die Höhe. Abgeglichen mit: Leitbild (echte Wahl, Grinden darf man, muss man nie: Pim geht täglich neu, keiner hängt fest), BRS 3 („Charisma gibt es nicht; die soziale Wirkung kommt aus Ruf und Gesellschaftsfertigkeiten“, daher Überreden ohne Grundwert), BRS 4 („du wirst, was du tust“: Üben bei jedem Versuch), Rast (`rast.gd`), Tränke und Essen (`LISTE-REGELWERTE.md`), Texte Homer (Verband nur außerhalb des Kampfs, `[807.verband.kampf]`).

**Sachverhalt:**
- **Leben eines Helden auf Stufe 1:** 10 + 5 je Stufe + 2 je Zähigkeit, also 21 bis 31. Ein Verband mit 7 Leben gibt ein Viertel bis ein Drittel zurück.
- **Andere Wege zu heilen, außerhalb des Kampfs:** kurze Rast am Feuer kostenlos, 2 Stunden, ein Viertel des Lebens (`rast.gd`); lange Rast einmal je Tag, am Feuer kostenlos, im Zimmer 5 Gold, alles voll; Heiltrank 14 Leben für 25 Gold; Braten 14 Leben, Fleisch 6 Gold.
- **Leben je Gold:** Verband 0,9 (Heilkunde 10), Heiltrank 0,6, Braten über 2.
- **Proben sonst:** 50 % + 5 je Punkt Grundwert Unterschied. Ein Überreden zu 45 % liegt also etwa bei einer Probe mit einem Grundwertpunkt weniger als der Gegner.

**Auswertung:**
- **Jerrys Zahlen (entschieden):** Pim ist am Anfang ein Wagnis, das sich mit Übung lohnt; der Verband spart die 2 Stunden der kurzen Rast und hilft dort, wo kein Feuer brennt (Höhle). Er wird mit Heilkunde spürbar besser, der Klosterschüler hat davon etwas.
- **Überreden mit Wille oder Verstand als Grundwert (verworfen):** BRS 3 sagt ausdrücklich: kein Charisma, soziale Wirkung aus Ruf und Fertigkeit. Ein Grundwert würde das Gegenteil sagen.
- **Verband teurer, etwa 15 Gold (verworfen):** dann lohnt er gegen die kostenlose kurze Rast kaum noch, die Fertigkeit Heilkunde bliebe außerhalb des Pfads Heiler ohne Nutzen.
- **Stärkstes Gegenargument:** Der Verband ist je Gold billiger als der Heiltrank; wer klug ist, heilt außerhalb des Kampfs nur noch mit Verbänden. Das stimmt und ist gewollt: Tränke sind für den Kampf, dort geht der Verband nicht. Billiger als beide ist der Braten, ohne dass das bisher stört.
- **Noch offen, nicht Teil dieses Vorentscheids:** Ruf wirkt auf Überreden noch nicht; das kommt mit den Rufstufen (BRS 13, offen). Der Heiltrank heilt in der Welt 14, in der Simulation 12 (`wirtschaft.traenke`); Hinweis an Jerry.

**Folgerungen:** Bei „gebilligt“ lösche ich die Datei und setze „gebilligt“ ins Archiv. Bei „zurück“ nennst du die Zahl, die du willst; Jerry ändert sie in `werte.json`.

Antwort: „1038 gebilligt“ oder „1038 zurück, …“
