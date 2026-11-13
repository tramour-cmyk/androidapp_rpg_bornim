# 1108 · Soll Pim nur einmal heimgeschickt werden können, mit höchstens drei Versuchen beim Überreden?
Sokrates · 13.11., 09:35 · G Balance · aus deiner Frage 09:33 („Kann ich den PIM 100-mal hintereinander versuchen zu überreden? Weil das wäre ein Fehler.“)
Kurz: heute geht ein Versuch je Tag, aber an jedem neuen Tag wieder, ohne Ende, und jeder Versuch übt Überreden; Vorschlag: Pim wird nur einmal heimgeschickt, höchstens drei Versuche

Geprüft an: [Commit 9e68163](https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/9e68163a7) auf `claude/build-282` (Build 282): `godot/skripte/geschichte.gd` 214–268 (`pim_versucht` je Tag, `pim_heute` je Tag), `skript.gd` 52–57 (jede Probe übt die Fertigkeit); `STORY-K1-FERTIGKEITEN.md` „Überreden: Pim heimschicken“ und `[1085.pim.wahl]`

**Frage:** Heute kannst du Pim an einem Tag nur einmal zu überreden versuchen. Am nächsten Tag steht er wieder draußen, und die Wahl kommt neu, auch nach einem Erfolg, ohne Grenze. Rastest du bis zum nächsten Tag, kannst du ihn also 100 Tage hintereinander überreden, und jeder Versuch übt Überreden. Soll das so bleiben?

**Votum:** „1108 A“: Pim wird nur einmal heimgeschickt; beim Überreden höchstens drei Versuche an drei Tagen, danach nur noch Gold.

**Berührt:** 842, 1086 (Tom, Bau), 1085 (Homer: Satz „am nächsten Tag steht er wieder draußen“ in `STORY-K1-FERTIGKEITEN.md`), 1051 A (Probe), alle späteren Proben auf Leute (gleiche Frage bei Einschüchtern, Tiere beruhigen am selben Tier)

**Begründung:** Leitbild: „Grinden darf man, muss man nie. Wiederkehrende Gegner bringen Beute und Übung, aber kaum noch Stufen“ (`DESIGN-BRS.md`). Pim ist kein wiederkehrender Gegner, sondern eine kleine Geschichte: das Kind wird einmal heimgeschickt, die Mutter dankt einmal. Ein Kind, das man jeden Tag ohne Risiko als Übungspuppe benutzt, bricht die Szene und macht Überreden billig. Die Grenze gehört zur Art der Probe, nicht nur zu Pim: dieselbe Frage kommt bei jeder Probe auf Leute wieder.

**Sachverhalt:**
- Ein Versuch je Tag: Flagge `pim_tried_<Tag>`; Erfolg: `pim_home_<Tag>`, gilt nur für diesen Tag (Build 282).
- Jeder Versuch übt Überreden, auch der misslungene (`skript.gd`: „würfelt die Chance, übt [fert]“).
- Der Dank der Mutter kommt nur einmal (Flagge `PIM_DANK`), der Ruf steigt also nur einmal; die Übung dagegen jedes Mal.
- Eine Frist in Kapitel 1, die die Tage begrenzt, gibt es nicht (in `DESIGN-` und `STORY-K1` nichts gefunden). Ein neuer Tag kostet nur Rasten.
- Am Anfang gelingt Überreden zu 36 % (1084, gebilligt 09:31).

**Auswertung:**
- **A (Empfehlung):** einmalig, höchstens drei Versuche. Gelingt das Überreden oder zahlst du 5 Gold, ist die Szene vorbei: Pim spielt danach bei seiner Hütte und hat keine Wahl mehr. Misslingt es dreimal (an drei Tagen), fällt der Überreden-Knopf weg, Gold bleibt. Bei 36 % gelingt es in drei Versuchen zu etwa 74 %. Kosten: ein kleiner Bau Tom (zwei Flaggen statt Tagesflaggen), ein Satz Homer, falls Pim bei der Hütte etwas sagen soll.
- **B:** einmalig, Versuche ohne Grenze (einer je Tag). Kein Übungsautomat nach dem Erfolg, aber vorher beliebig viele Tage mit Übung. Kosten wie A.
- **C:** so lassen.
- **Stärkstes Gegenargument gegen A:** nach dem Heimschicken fehlt Pim als kleine Wahl im Dorf, das Dorf wird ein Stück stiller; und drei Fehlschläge sperren den Weg ohne Geld, auch wenn der Held später viel besser überredet. Dagegen: die Szene hat mit dem Dank der Mutter ein Ende, wie in einer Geschichte; Gold bleibt als Ausweg; das Leben im Dorf kommt aus den Leuten und ihren Tagesläufen, nicht aus einem Knopf, der jeden Tag wiederkommt.

**Folgerungen:** Bei A oder B: Homer zieht den Satz in `STORY-K1-FERTIGKEITEN.md` nach (1085), Tom baut nach 842 und 1086; die Grenze „einmalig, höchstens drei Versuche“ wird Regel für Proben auf Leute in `DESIGN-BRS.md` (Sokrates). Bei C bleibt alles.

Antwort: …
