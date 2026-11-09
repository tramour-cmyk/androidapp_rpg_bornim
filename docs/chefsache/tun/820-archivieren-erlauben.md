# 820 · Archivieren von Sitzungen erlauben?
Ford · 09.11., 22:36 · B Werkzeuge · aus Selbstneustart 22:32
Kurz: `archive_session` ist vom Auto-Modus-Wächter abgelehnt („Interfere With Workloads“); ohne Archivieren geht kein Neustart.

**Frage:** Erlaubst du `mcp__claude-code-remote__archive_session` für Fords Sitzung (Regel in deinen Einstellungen)? Dein Auftrag vom 08.11., 18:06 („Archivier mal alles ordentlich“) deckt es, der Wächter lässt es trotzdem nicht durch.

**Votum:** „820 A“: Regel eintragen, „820 erlaubt“ sagen; Ford führt dann aus: alten Ford archivieren (8,18 $ buchen), Neustart Tom (86e6bccae), Neustart Perikles (e662246f8).

**Berührt:** Neustarts Tom 762 und Perikles 818 (stehen), alter Ford `session_01Hmoj7684czZostW4Q5YTcw`.

**Auswertung:**
- **A (Empfehlung):** erlauben.
- **B:** du archivierst von Hand in der Sitzungsliste; Ford startet dann nur.
- **Stärkstes Gegenargument gegen A:** Archivieren ist nicht umkehrbar im Betrieb (Container weg); Ford prüft vorher `get_session` (idle, Übergabe da).

Antwort: …
