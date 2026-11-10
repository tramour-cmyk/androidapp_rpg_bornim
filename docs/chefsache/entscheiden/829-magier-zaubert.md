# 829 · Magier gegen das Wolfsrudel: Mit Zaubern gewinnt er schon, nur der Autopilot nicht. Werte lassen, Autopilot klüger?
Sokrates · 10.11., 11:45 · E Kampf · aus 705 B (Chef 10.11., 08:43)
Kurz: Jerrys 21 % (BRS) gelten für einen Magier, der nur mit dem Stab zuschlägt; nur mit dem Feuerpfeil (wie der Autopilot) 33 %, mit allen Zaubern 91 %

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/91b44ad1f/godot/tests/anspringen_702.gd (Lauf am Rechner 10.11., 11:43; abgewandelt: Spieler zaubert, Regel der Zauberwahl unter „Sachverhalt“; Fremdprüfung 11:42 rechnete nach)

**Frage:** Der Auftrag 705 B lautete: eine Regel vorschlagen, damit der Magier Stufe 1 ohne Söldner und ohne Ausweichen etwa 40 % gegen das Rudel gewinnt. Nachgemessen: Mit allen Zaubern schafft er das schon heute. Nur der Autopilot und wer nur den Feuerpfeil benutzt, bleibt darunter. Sollen die Werte so bleiben, und soll der Autopilot Brennende Hände benutzen?

**Votum:** „829 B“: keine neue Regel; der Autopilot des Magiers wirkt Brennende Hände, wenn zwei Gegner in einer Reihe stehen; Jerry misst den Magier künftig zaubernd; Homers Lehrsatz zum ersten Wolfskampf (830) nennt auch „Können“.

**Berührt:** 705 B (Archiv 10.11., 08:43), 704 A (Ausweichen kostet nichts), 830 (Lehrsatz Homer), 478 (Zauberschaden nach Maßstab), `DESIGN-LEITBILD.md` „echte Wahl“

**Begründung:** Die Messung in 705 ließ den Magier jeden Zug mit dem Kampfstab zuschlagen. Seine Zauber benutzte er nie, auch die zwei Heiltränke nicht. So spielt keiner einen Magier. Mit allen Zaubern liegt er weit über 40 %. Neue Werte würden ihn noch höher heben und den Abstand zum Kämpfer (99–100 %) tilgen. Die Lücke liegt beim Autopiloten (`mars.gd` 666): Er kennt nur den Feuerpfeil und bleibt mit 33 % unter dem Ziel.

**Sachverhalt:** 600 Kämpfe je Zeile, nur Regeln (`mars.gd`, 702 C „handeln“), Held Stufe 1 Zauberlehrling, 2 Heiltränke, ohne Söldner. „Zaubert“ heißt: Brennende Hände auf eine Reihe mit zwei Wölfen (im Rudel stehen immer zwei vorn); Magisches Geschoss auf einen Wolf mit höchstens 9 Leben; sonst Feuerpfeil. 4 Zauberpunkte reichen für zwei Zauber, der Feuerpfeil kostet nichts.

| Rechnung | Spieler | Rudel, ohne Ausweichen | Rudel, weicht aus | Wolf, ohne Ausweichen | Wolf, weicht aus |
|---|---|---|---|---|---|
| BRS | nur Stab (Messung 705) | 21 % | 65 % | 32 % | 83 % |
| BRS | nur Feuerpfeil (wie Autopilot) | 33 % | 76 % | 82 % | 92 % |
| BRS | alle Zauber | **91 %** | 96 % | 84 % | 93 % |
| BRS | alle Zauber, trinkt unter 40 % Leben | 97 % | 99 % | 98 % | 99 % |
| SRD (Held im Spiel heute) | alle Zauber | 76 % | 82 % | 82 % | 90 % |

**Einschränkung:** Brennende Hände und Magisches Geschoss rechnen im BRS noch in SRD-Würfeln, hochgerechnet nach dem Verhältnis der Leben (478, Annahme in `brs_kampf.gd`); beim Wolf etwa das 2,8-Fache. Bekommt das BRS eigene Zauberregeln, gilt die Zahl 91 % nicht mehr; dann neu messen. Die SRD-Zeile (76 %) zeigt, dass der Vorsprung nicht nur aus dem Maßstab kommt.

**Auswertung:**
- **A:** Werte so lassen, 705 schließen; Jerry misst zaubernd, Homer erwähnt im Lehrsatz 830 „Können“. Kosten: eine Teständerung, eine Zeile Text. Der Autopilot bleibt bei 33 %.
- **B (Empfehlung):** wie A, dazu wirkt der Autopilot des Magiers Brennende Hände auf eine Reihe mit zwei Gegnern, solange Zauberpunkte reichen. Kosten: wenige Zeilen in `mars.gd` (Team Jerry), eine Messung, ein Build.
- **C:** die Werte stärken (wie 705 B gedacht). Kosten: ein Regelvorschlag, eine Messung, ein Build; der Magier läge mit Zaubern noch über 91 % und gleichauf mit dem Kämpfer.
- **Stärkstes Gegenargument gegen B:** Der Autopilot spielt dann klüger als ein neuer Spieler, der „Können“ nicht findet und mit dem Stab verliert. Weg: Lehrsatz 830 zeigt auf „Können“; ob der Knopf trotzdem übersehen wird, zeigt erst der Test am Gerät mit einem Magier.

**Folgerungen:** A: 705 erledigt, Zusatz an 830 (Homer), Teständerung an Jerry (zu 705). B: zusätzlich Vorgang an Jerry (Autopilot Brennende Hände). C: Regelvorschlag Sokrates, Messung Jerry.

Antwort: …
