# 1727k · Gibst du die drei Satzänderungen in `.claude/settings.json` (Auto-Freigabe) für die neue Arbeitsweise frei?
Sokrates · 22.11., 08:12 (Entwurf, wird vor 10:00 gegengeprüft) · B Werkzeuge · aus Spike 08:12 zu 1859
Kurz: drei Sätze der Auto-Freigabe auf die neuen Namen, keine neue Befugnis.
Beim Chef, weil: Rollen und Accounts (`settings.json` schreibt nur der Chef, Archiv 797, 222, 235)

Geprüft an: <Commit vor dem Anlegen>

**Frage:** Mit dem Umschalten (1727h) passen drei Sätze der Auto-Freigabe in `settings.json` (`autoMode.environment`) nicht mehr: (a) wo deine Testfreigabe steht: „… or the team's docs/ARBEIT-*.md file“ → „… or the Vorgangsdatei docs/vorgang/<Nr>.md“; (b) „Ford (Betriebsleiter …)“ archiviert und startet Sitzungen → „Disponent“ mit denselben Rechten; (c) „Team sessions (Tom, Jerry) download Godot …“ → „Fachkraft-Sitzungen“. Gibst du das frei?

**Votum:** „1727k A“: frei, Spike schreibt den Wortlaut an der Kopie, du übernimmst ihn mit dem Umschalten.

**Berührt:** Spike (1859), Ford (wird Disponent), alle Fachkraft-Sitzungen.

**Begründung:** ohne (a) findet die Auto-Freigabe deine Testfreigabe nach dem Umzug nicht; ohne (b) darf der Disponent keine Sitzung starten; ohne (c) laden Fachkräfte Godot nicht. Die Haken selbst ändern sich nicht (Spike 08:12: Dateinamen bleiben, `probelauf.py` bleibt).

**Sachverhalt:**
- Befund Spike 08:12 zu 1859; Wortlaut der drei Sätze in `settings.json` an `main`.

**Auswertung:**
- **A (Empfehlung):** die drei Sätze frei. Keine neue Befugnis, nur neue Namen.
- **B:** nein; dann bleibt die alte Ordnung in `settings.json`, und Disponent und Fachkräfte laufen in Rückfragen.
- **Stärkstes Gegenargument gegen A:** „Fachkraft-Sitzungen“ ist weiter gefasst als „Tom, Jerry“: jede Sitzung, die sich so nennt, lädt dann Godot. Entkräftet: das Laden war schon für jede Spielcode-Sitzung nötig; ein Name gibt keinen Schreibzugriff auf `main`.

**Folgerungen:** bei A schreibt Spike den Satz an der Kopie (1859), er geht mit dem Umschalt-Commit.

Antwort: …
