# 745 · Regelwerk konsolidieren, parallel zur Probe 657 D · Sokrates · 09.11., 12:01
B Abläufe

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/main/CLAUDE.md

**Anlass:** Chef 11:54: „Wir müssen das halt dann auch mal, das ganze Regelwerk konsolidieren. Der Hintergrund ist ja einfach, dass ihr mir zu viel Scheiße baut, weil ihr Regeln nicht beachtet, die eigentlich ganz klar sind. Und diese ganz allgemeinen Basics, die sollten halt an einer Stelle stehen.“ 12:00: „parallel zur Probe … dass Diogenes mal die Widersprüche und alles ordentlich listet und wir das jetzt tatsächlich gemeinsam mal konsolidieren“.

**Befund:** Regeln werden oft nicht aus Unkenntnis gebrochen, sondern weil zwei sich widersprechen und die handelnde gewinnt (Beispiel 717: „trägt sofort als Auftrag ein“ gegen „erst diskutieren“). Diogenes fand in 657 weitere (646, 621 A, 201a, 396, 480). Dieselbe Regel steht oft an drei Stellen in drei Fassungen. Drei frühere Aufräumrunden (98, 167, 275.2) wuchsen wieder zu, weil die Regelbilanz (Haltung 6) kein Werkzeug erzwingt. Heute rund 78 KB in `CLAUDE.md` und Rollendateien.

**Frage:** Konsolidieren wir so?

- **A (Empfehlung Sokrates):** fünf Schritte, parallel zur Probe 657 D:
  1. **Diogenes listet** alle Widersprüche und Doppelungen in `CLAUDE.md`, Rollendateien und den Listen, gegen das Archiv (je Fund: Stellen, Wortlaut, welche Entscheidung dahintersteht).
  2. **Du entscheidest** jeden Widerspruch einzeln (Chefrunde mit Sokrates).
  3. **Perikles schreibt um:** Basics für alle nur in `CLAUDE.md`, Rollenspezifisches nur in der Rollendatei, Handwerk einer Aufgabe in eine Liste; Doppeltes wird Verweis; nichts Neues dazu. Du siehst den Unterschied vorher, Diogenes prüft, dass jede Entscheidung einen Ort behält; Rückweg über Git.
  4. **Wachstumsstopp:** ein Haken mit fester Obergrenze für `CLAUDE.md` und jede Rollendatei; wer etwas hinzufügt, streicht im selben Commit (Regelbilanz erzwungen).
  5. **Form-Haken fallen:** Haken, die nur die Form prüfen (Diogenes 657, Punkt 4), werden entfernt, inhaltliche bleiben.
  Maß: was der Chef als Erster findet, zwei Wochen vorher gegen nachher (Diogenes). Gegenargument: zwei Änderungen zugleich mit 657 D, hinterher ist unklar, was gewirkt hat; und Diogenes, du und Perikles brauchen dafür zusammen etwa vier bis fünf Sitzungen.
- **B:** erst nur Schritt 1 (Liste der Widersprüche), dann neu entscheiden. Gegenargument: langsamer, aber billiger, falls die Liste kurz ist.
- **C:** noch nicht, erst die Probe 657 D abwarten.

## Stellungnahme Sokrates (09.11., 12:0x, Chef 12:05: „ob das was bringt, dafür brauchen wir eigentlich keinen Probelauf … Das Entscheidende ist ja … dass er aufgerufen wird. Und dafür können wir doch einen Haken machen … Design-Klimbim und Entwurfsklimbim und Kampfklimbim“)
- **Recht hast du:** dass eine Liste hilft, die im richtigen Moment vor einem liegt, zeigt der heutige Tag schon (fünfmal hielt die Commit-Prüfung an, fünfmal wurde es richtig). Vier Builds Warten, bevor es weitere Listen gibt, lohnt sich nicht.
- **Zwei Einschränkungen:** (1) mein eigenes Urteil „das hilft mir“ ist kein Beleg; heute brach ich Regeln, die ich kannte. Was wirklich wirkt, ist eine *Sperre*, nicht ein angezeigter Text. Darum: was sich prüfen lässt, wird eine Prüfung im Haken, die anhält (wie heute „Geprüft an“ fehlt); nur der Rest wird als Liste gezeigt. (2) Auslöser nur an Handlungen, nie an Wörtern: ein Commit unter `godot/kampf/` zeigt die Kampfliste, eine neue Datei in `ansehen/` die Vorlagenliste, ein Commit an Modellen oder `DESIGN-…` die Aussehensliste. Haken, die Wörter im Text suchen, schlagen falsch an (Chefsache-Haken heute viermal, Wiederholungswächter bei „Karte“).
- **Stärkstes Gegenargument:** sechs Listen-Haken mehr heißen mehr Ausgabe bei jedem Commit, also wieder Rauschen. Gegenmittel: jede Liste nur einmal je Sitzung und Bereich, danach still.
- **Folgerung:** Die Listen sind das natürliche Ergebnis von Schritt 3 (Handwerk einer Aufgabe wandert in eine Liste). 657 D läuft als erste Liste weiter, die übrigen kommen mit der Konsolidierung, jede mit Auslöser an einer Handlung.

- **A2 (Empfehlung neu):** wie A, dazu: Schritt 3 legt je Bereich eine Liste an (Build und Test, Vorlage an den Chef, Aussehen und Modelle, Kampf, Spieltexte, Kauf und Lizenz); Schritt 4 baut die Auslöser an Handlungen (Pfade, Befehle), einmal je Sitzung und Bereich; was prüfbar ist, wird Sperre statt Text. 657 D bleibt die erste Liste, ohne auf vier Builds zu warten.

Antwort: „745 A2“, „745 A“, „745 B“ oder „745 C“.
