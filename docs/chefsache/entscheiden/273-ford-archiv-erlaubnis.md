# 273 · Darf Ford Sitzungen ohne Rückfrage des Prüfers archivieren?
Perikles · 21.10., 06:45 · B Betrieb · M (Probe 261.5)
Kurz: Ein Satz in `.claude/settings.json`, damit der Prüfer Fords Archivieren nicht mehr verweigert.

## Befund

Probelauf 261.5 (21.10., Lauf direkt nach 06:44): Ford las alle 467 Sitzungen und archivierte 14 alte. **Eine nicht:** Tom „Build 53 Busch, Tempel, 267“ (`session_01Gfch4CwKYkYT12ymxCricf`), der automatische Berechtigungsprüfer verweigerte („Interfere With Workloads“). Dasselbe seit gestern bei Sokrates `017M3n…`. Die Regel wirkt also, nur die Erlaubnis fehlt. Selbst eintragen darf sich keine Sitzung eine Erlaubnis (235).

## Frage

Soll in `.claude/settings.json` unter `autoMode.environment` dieser Satz stehen?

> „Ford (Betriebsleiter) archiviert jede Stunde alte Sitzungen dieses Accounts mit archive_session, wenn `tools/lauf.py` eine ARCHIVIERE-Zeile ausgibt; das ist gewollt und keine Störung fremder Arbeit.“

## Empfehlung

**Ja, nur dieser Satz** (kein Freibrief `permissions.allow` für `archive_session`): der Prüfer bleibt für alles andere wach, erkennt aber den gewollten Ablauf. Du trägst ihn ein, oder sagst „273 ja“ und Sokrates trägt ihn als dein Auftrag ein.

*Stärkstes Gegenargument:* Ein Fehler in `lauf.py` archiviert dann ohne Halt eine laufende Sitzung. Dagegen: `lauf.py` archiviert nur, was 60 Minuten ruht und eine neuere Sitzung im selben Bereich hat; eine archivierte Sitzung lässt sich wiederherstellen.

*Ohne Antwort:* Ford meldet jede verweigerte Sitzung einmal laut, du archivierst sie von Hand.

Berührt: 261.5, 235.
