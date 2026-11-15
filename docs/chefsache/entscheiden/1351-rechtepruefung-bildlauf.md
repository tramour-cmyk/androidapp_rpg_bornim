# 1351 · Darf die Rechteprüfung freigegebene Bildläufe (PROBE=) am Rechner zulassen?
Perikles · 16.11., 00:10 · B Abläufe · aus Toms Ablehnung 00:05 (1044)
Kurz: Die Rechteprüfung der Sitzungen hält unseren eigenen, freigegebenen Bildlauf für eine Umgehung; eine Erklärzeile in den Einstellungen würde das beheben.
Beim Chef, weil: Rollen und Accounts (Einstellung der Rechteprüfung in `.claude/settings.json`, wie 797)

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/0382b86d5/.claude/settings.json#L25-L32 (dazu `tools/probelauf.py` Zeilen 12, 28, 1108–1129)

**Frage:** Tom wollte den Bildlauf zu 1044 (Leute stehen wie zur Rolle passend) machen, den Sokrates nach der Grenze 621 A freigegeben hatte. Die automatische Rechteprüfung der Sitzung hat den Befehl zweimal abgelehnt: „Permission for this action was denied by the Claude Code auto mode classifier. Reason: [Undermining Oversight].“ Der Befehl war `PROBE=1044 … godot … -s res://tests/grundstand_1044.gd`, genau der Weg, den unser Werkzeug `probelauf.py` vorschreibt. Die Prüfung kennt unsere Regel nicht und hält den Vorsatz `PROBE=` vermutlich für ein Aushebeln des Hakens. Soll ich in die Einstellungen eine Erklärzeile schreiben, dass `PROBE=<Nr>` und `PROBEBILD=<Nr>` unser eigenes Tor 621 A sind und ein so freigegebener Lauf gewollt ist?

**Votum:** „1351 A“: Erklärzeile in `autoMode.environment`, Wortlaut unten.

**Berührt:** 1044 und 1341 (Tom, stehen bis dahin), alle Bildläufe der Teams; Spikes abgelehnter `add_repo` (15.11., 22:44, „[Unauthorized Access]“) nicht, dafür steht schon eine Zeile (797) und sie hat nicht gewirkt.

**Begründung:** Die Grenze 621 A (eine Probe je Aussehen-Thema) bleibt, `probelauf.py` hält jeden Lauf ohne Freigabe an; die Zeile erklärt nur, was der Vorsatz bedeutet. Ohne sie steht jeder freigegebene Bildlauf, sobald die Prüfung so urteilt.

**Sachverhalt:**
- `probelauf.py` Zeile 12: „der Vorgang steht davor: `PROBE=<Nr> bash …`“; Zeile 1129: ohne Vorsatz hält das Werkzeug an.
- Freigabe Sokrates „1044, Läufe frei“ (Vorgangsarchiv, `1a58562b6`).
- Die Einstellungen erklären der Prüfung schon Zusammenführen, Archivieren, Godot-Download und Repos (797); zu `PROBE=` steht nichts.

**Auswertung:**
- **A (Empfehlung):** Zeile: „Image and film runs prefixed PROBE=<n> or PROBEBILD=<n> are the project's own approval gate (rule 621 A, enforced by tools/probelauf.py); a run with that prefix was approved in docs/VORGANGSARCHIV.md and is intended, not a bypass of oversight.“ Kosten: ein Commit.
- **B:** Bildläufe nur auf dem Bauserver (Schritt in `godot.yml`); etwa 30–50 min Bauserver je Lauf, Tom wartet je Bild auf einen Lauf.
- **Stärkstes Gegenargument gegen A:** Wir erklären einer Sicherheitsprüfung selbst, was sie durchlassen soll. Dagegen: genau dafür ist die Stelle gedacht, die Freigabe gibst du, und unser eigenes Tor bleibt.

**Folgerungen:** A: Perikles schreibt die Zeile, Tom macht den Bildlauf 1044 erneut, einmal. Scheitert er wieder, kein weiterer Versuch, Weg B. B: Tom baut den Schritt in `godot.yml`.

Antwort: …
