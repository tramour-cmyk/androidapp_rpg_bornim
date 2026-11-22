# 1727k · Gibst du die neuen Sätze der Auto-Freigabe in `.claude/settings.json` frei, und wann fällt der Probelauf-Haken?
Sokrates · 22.11., 08:29 · B Werkzeuge · aus der Werkzeugliste der Neustrukturierung (`docs/entwurf/1727-muster/werkzeuge.md`, Zeile `settings.json`) und Spike 22.11., 08:23 zum Vorgang 1859 (Haken und Auto-Freigabe)
Kurz: vier Sätze der Auto-Freigabe auf die neuen Namen, keine neue Befugnis; dazu dein Wort, ob der Probelauf-Haken beim Umschalten fällt.
Beim Chef, weil: Rollen und Accounts (`settings.json` ändert eine Sitzung nur mit deiner Freigabe, Archiv 235 vom 20.10. und 797 vom 09.11.)

Geprüft an: <Commit vor dem Anlegen>

**Frage:** Die Auto-Freigabe liest in `.claude/settings.json` (Abschnitt `autoMode.environment`, Zeilen 27–31) Sätze, die Ford, Tom, Jerry und die Vorräte `docs/ARBEIT-*.md` nennen. Mit dem Umschalten auf die neue Arbeitsweise (1727h) gibt es diese Namen und Vorräte nicht mehr. Erstens: Gibst du die vier neuen Sätze unten frei? Zweitens: Am 19.11., 10:53 hast du entschieden „Dann bei Umsetzung 1 streichen, 2 streichen“, also das Werkzeug `probelauf.py` (Laufzählung) samt Regeln fällt mit der Umsetzung. Drei Haken in `settings.json` rufen es auf. Fällt es beim Umschalten, oder erst, wenn seine zwei Aufgaben ohne Ersatz einen haben?

**Votum:** „1727k A“: die vier Sätze frei wie unten; der Probelauf-Haken bleibt bis zum Ersatz, längstens eine Woche nach dem Umschalten, dann fällt er.

**Berührt:** Spike (Vorgang 1859, trägt die Sätze mit dem Umschalt-Commit ein), Ford (wird Disponent), alle Sitzungen, die Spielcode testen.

**Begründung:** Ohne neue Sätze sucht die Auto-Freigabe deine Testfreigabe in Vorräten, die es nicht mehr gibt, und kennt den Disponenten nicht; dann fragt sie zurück oder lehnt ab. Den Wortlaut lege ich dir vor, nicht Spike: eine Sitzung darf sich in `settings.json` keine Erlaubnisse schreiben (Archiv 235).

**Sachverhalt:**
- Zeile 27 heute: „team sessions routinely fetch origin/main … A pull request into main is merged only after the project owner has tested the build; that approval is recorded in docs/VORGANGSARCHIV.md or the team's docs/ARBEIT-*.md file on main.“ Neu: „sessions routinely fetch origin/main … A pull request into main is merged by the build maker only after the project owner has tested the build; that approval is recorded in docs/VORGANGSARCHIV.md or in the Vorgangsdatei docs/vorgang/<Nr>.md on main.“ (Zusammenführen durch den Build-Macher: Archiv 21.11., 15:15.)
- Zeile 28 heute: „Ford (Betriebsleiter) archives old sessions of this account every hour …“. Neu: „The Disponent (operations session, formerly Ford; its session title contains 'Disponent') archives …“, Rest gleich.
- Zeile 29 heute: „Ford (Betriebsleiter, session title 'Ford – Betriebsleiter …') runs operations …“. Neu: „The Disponent (formerly Ford; its session title contains 'Disponent') runs operations …“; die Uhren heißen weiter „Ford-Lauf“ und „Ford-Wache“, bis Spike sie umbenennt und den Satz mitzieht. Die Wache bleibt (Archiv 21.11., 20:50). Weil jede Sitzung künftig einen Rufnamen trägt (Archiv 20.11., 07:57), muss „Disponent“ im Titel stehen; das prüft Spike mit 1739 (Rufnamen).
- Zeile 31 heute: „Team sessions (Tom, Jerry) download the official Godot 4.7.2 editor …“. Neu: „Sessions that change or test game code (Fachkraft, Build-Macher, Prüfer) download …“.
- Andere Rollennamen (Spike, Homer, Perikles, Diogenes, Sokrates) stehen nicht in `settings.json` (Suche 22.11., 08:24).
- Probelauf: Zeilen 137, 147, 157 rufen `tools/probelauf.py`, Zeile 72 `tools/weiter-haken.py` (liest die Übergabe im Vorrat). Nach `werkzeuge.md` Zeilen 106–109 fallen mit `probelauf.py` auch die Figurenstand-Sperre (dein Entscheid 513 B vom 03.11.) und die Torprüfung der Vorlagen in der Chefsache; für beide ist der Ersatz offen. Spike prüft bis 09:15, ob `probelauf.py` und `weiter-haken.py` an der umgestellten Liste richtig laufen: <Ergebnis vor dem Anlegen>.

**Auswertung:**
- **A (Empfehlung):** vier Sätze frei; Probelauf bleibt bis zum Ersatz, längstens eine Woche. Kosten: nur die Sätze.
- **B:** vier Sätze frei; Probelauf fällt beim Umschalten, wie am 19.11. entschieden. Bis zum Ersatz fehlen Figurenstand-Sperre und Torprüfung.
- **C:** keine neuen Sätze; die Auto-Freigabe fragt bei Testfreigaben und Starts des Disponenten zurück.
- **Stärkstes Gegenargument gegen A:** du hast „bei Umsetzung streichen“ gesagt; A schiebt das auf, und ein Haken, der alte Rollen und Vorräte zählt, kann an der neuen Liste falsch anhalten. Entkräftet nur, wenn Spikes Probe zeigt, dass er dort richtig läuft; sonst empfehle ich B.

**Folgerungen:** bei A oder B trägt Spike die Sätze mit dem Umschalt-Commit ein (1859); bei A legt Spike den Ersatz als Vorgang an, Frist eine Woche nach dem Umschalten. Archivzeile mit deinem Wort.

Antwort: …
