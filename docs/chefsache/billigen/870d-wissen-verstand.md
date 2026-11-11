# 870d · Vorentscheid: Schwächen der Monster vorher sehen mit Verstand 6 statt „Fertigkeit Wissen“ billigen?
Sokrates (Vorentscheid, Hinweis Homer 870.14 a) · 11.11., 02:00 · E Kampf · aus 870.4/870.5 (Umzug BRS)
Kurz: 870a 8 A sagt „mit der Fertigkeit Wissen sieht man sie vorher“; diese Fertigkeit gibt es im BRS nicht. Ich habe festgelegt: ab Verstand 6 sieht der Held Schwäche, Stärke und Gegenwirkung vorher.

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/5dcd1a113 (`godot/regeln/talente.gd` 38, 137: „Ab INT 12 erkennst du Schwächen“; dazu `DESIGN-BRS.md` 3, Grundwerttabelle, 7)

**Frage:** Woran hängt, dass der Held Schwächen und Stärken eines Monsters schon vor dem ersten Kampf sieht?

**Votum:** Entschieden (Vorentscheid Sokrates, 11.11., 02:00; Nachtauftrag Chef 10.11., 22:24: „Du bist Chef“): **A**, Verstand 6 oder mehr. Bitte „gebilligt“ oder „zurück“.

- **A** Verstand ab 6 (Start 3–8, Mittel 4,5; wie heute INT 12 knapp über dem Mittel). Ohne das zeigt der Kampf die Schwäche beim ersten Mal, danach steht sie im Bestiarium (870a 8 A unverändert).
- **B** eine neue Fertigkeit „Monsterkunde“: verworfen, die 37 Fertigkeiten sind entschieden, eine 38. ändert Pfade und Simulation 444.

**Abgleich (783 W5):** BRS „du wirst, was du tust“: Verstand wächst (870a 4), also bleibt der Weg offen; Leitbild „echte Wahl“: Verstand bekommt für Kämpfer einen sichtbaren Nutzen. Stärkstes Gegenargument: ein Kämpfer mit Verstand 3 sieht es nie vorher. Antwort: er erfährt es im ersten Kampf, die Gegenwirkung ist beim ersten Mal sichtbar und nie tödlich (870a 8 A).

**Umgesetzt:** `DESIGN-BRS.md` 7 „mit Verstand ab 6“ statt „mit der Fertigkeit Wissen“. Bau: Tom in 870.4 (`talente.gd`), Texte `[870.14.wissen…]` (Homer) passen unverändert.

**Rückbau:** „zurück“ = Wortlaut in 7 zurück, Schwelle neu festlegen.

**Kosten:** wenige Minuten im laufenden 870.4.

**Berührt:** 870.4 (Tom), 870.5 (Jerry, Anzeige), `STORY-BRS-HELD.md` 116–118.

**Begründung:** Tom baut `talente.gd` in dieser Nacht unter 870.4 um; ohne Schwelle bliebe „INT 12“ als SRD-Rest stehen oder er müsste raten. Homer hat die Lücke gemeldet (870.14 a) und denselben Weg vorgeschlagen.

**Sachverhalt:** Grundwerte beginnen bei 1, 21 Punkte verteilt, jeder Wert 3–8 (Mittel 4,5); Zwerg Verstand +1. Heute im Spiel: INT 12 (SRD-Modifikator +1, knapp über dem Mittel 10).

**Auswertung:** Verstand 6 liegt wie INT 12 knapp über dem Mittel; wer Verstand betont (Zauberlehrling, Kräutersammler, Zwerg), sieht es ab Stufe 1, andere später, sobald Verstand wächst. Keine neue Fertigkeit, keine Änderung an 444. Gegenargument: Verstand wird für Kämpfer zur Pflicht, wenn das Vorher-Sehen zu viel wert ist. Lösung: der Vorteil bleibt klein, weil jede Schwäche nach dem ersten Kampf ohnehin im Bestiarium steht.

**Folgerungen:** Tom stellt `talente.gd` in 870.4 um; „zurück“ ändert nur die Zahl.

Antwort: … (gebilligt / zurück)
