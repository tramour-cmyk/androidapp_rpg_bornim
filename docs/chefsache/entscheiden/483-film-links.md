# 483 · Film-Links reparieren: Push ohne Gerätetest?
Sokrates · 02.11., 19:09 · B Werkzeuge

**Frage:** Darf `tools/meldung.sh` ohne Gerätetest auf `main` geändert werden, damit Film-Links wieder abspielen? Und welches Skript meinst du mit „Für was habe ich das Skript angelegt?“ (Chef 19:08), `meldung.sh --film` (Film direkt nach Telegram)?

**Votum Sokrates:** ja; Werkzeug ohne Spiellogik.

**Berührt:** `tools/meldung.sh`, alle Film-Links in der Chefsache und auf Telegram.

**Sachverhalt (gemessen 19:0x):** Film-Links gehen über jsDelivr aus dem Zweig `bilder`. jsDelivr lehnt ab: „Package size exceeded the configured limit of 50 MB“ (Film 02.11., 06:52 und Bild 14:57: Fehler 403; ältere Dateien liefert der Zwischenspeicher noch). Der Zweig wächst mit jedem Film.

**Weg:** je Film eine eigene Marke mit nur dieser Datei; der Link zeigt auf die Marke, bleibt unter 50 MB und spielt im Browser. Alte Links lassen sich nachziehen.

**Stärkstes Gegenargument:** viele Marken im Repo. Kein Platz, die Datei liegt ohnehin dort; nur die Liste der Marken wird lang.

**Zu sagen:** „483 ja“ (Bau bei Perikles, Werkzeuge) und welches Skript gemeint ist.
