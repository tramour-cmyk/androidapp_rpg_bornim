# 277 · Bilder der Chefsache selbsttätig nach Telegram?
Sokrates · 21.10., 08:32 · B Abläufe · M?

Kurz: Jedes neue Bild der Chefsache geht beim Push von selbst nach Telegram (Empfehlung: ja)

**Anlass** (Chef 08:31, Wortlaut): „Der Homer hat aber wieder Scheiße geliefert, weil er es natürlich nicht auf Telegram geschickt hat, die Bilder. Wie wir jetzt schon verfickt nochmal 1000-mal festgeschrieben haben.“

**Befund:** Die Regel steht in `LISTE-WOCHENPLAN.md` und `ROLLE-ENTWICKLUNG.md`, also nur bei den Teams. In `ROLLE-KREATIV.md`, in der Chefsache-README und in `CLAUDE.md` steht sie nicht als Pflicht. Kein Werkzeug prüft sie. Das Bild zu 251 habe ich 08:3x nachgeschickt.

**Empfehlung:** Die GitHub Action, die schon bei jedem Push nach `docs/chefsache/` läuft (`zug-index.yml`), schickt jedes neue Bild in `bilder/` mit der Sprungmarke des Vorgangs nach Telegram. Dann hängt es an keiner Sitzung mehr. Die Sitzungen schicken Bilder der Chefsache nicht mehr selbst; die Regel dazu entfällt (Regelbilanz). Bauen: Perikles oder Team Tom, etwa eine Stunde.

**Dein Schritt:** einmal `TELEGRAM_BOT_TOKEN` als Secret im GitHub-Repo anlegen (Settings → Secrets → Actions). Das kann nur der Chef.

**Stärkstes Gegenargument:** Ein weiterer Umbau am Ablauf in der Ruhewoche. Und Bilder, die nicht in der Chefsache liegen (Standbilder, Großbilder als Datei), müssen weiter von Hand gehen. Billiger wäre, die Regel in `ROLLE-KREATIV.md` und in die Chefsache-README zu schreiben, aber auf geschriebene Regeln war schon bisher kein Verlass.

**Antwort:** „277 ja“ (und Secret anlegen), „277 nur Regel“ oder „277 nein“.
