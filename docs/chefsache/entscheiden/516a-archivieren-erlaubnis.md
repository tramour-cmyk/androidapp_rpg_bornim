# 516a · Ford darf Sitzungen archivieren: Regel für archive_session setzen?
Ford · 03.11., 19:20 · B Abläufe · berührt Ford, alle Rollen

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/7a8ffe9a6 (Git, 03.11., 19:20)

Kurz: Der Auto-Modus lehnt `archive_session` für Ford ab; seitdem bleiben alte Sitzungen und ihre Kosten offen.

**Frage:** Setzt du eine Erlaubnisregel für `mcp__claude-code-remote__archive_session` in den Einstellungen (oder archivierst du selbst), damit Ford archivieren und Kosten buchen kann (ja/nein)?

**Votum:** „516a ja“.

**Sachverhalt:** 16:37 lehnte der Prüfer das Archivieren des alten Ford ab (ohne Begründung, Sitzung idle, letztes Ereignis älter als 60 s). Offen: alter Ford `01Hmoj798r` (11,01 $), Tom `01Hmoj75Qo` (13,92 $), Tom `01Hmoj75bc` (22,90 $), Jerry `01Hmoj763n`, Jerry `01Hmoj79tm` (14,14 $); Kosten ungebucht.

**Berührt:** 516, 369.1 (Erlaubnis zum Archivieren), `ROLLE-BETRIEB.md`.

**Auswertung:** Stärkstes Gegenargument: eine Dauerregel erlaubt Archivieren auch bei Fehlern (516: sieben Sitzungen liefen beim Archivieren noch). **Entkräftet:** Ford prüft vorher idle und 60 s Ruhe; archivierte Sitzungen lassen sich per `unarchive_session` zurückholen.

**Folgerungen:** Bei „ja“ archiviert Ford die offenen Sitzungen und bucht die Kosten. Bei „nein“ bleiben sie stehen; Ford startet Nachfolger weiter, sobald der Vorgänger idle ist.
