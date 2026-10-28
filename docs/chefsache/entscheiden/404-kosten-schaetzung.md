# 404: Fehlende Sitzungskosten schätzen?

**Frage:** Bei drei archivierten Sitzungen fehlt die Kostenangabe im Datensatz. Soll Sokrates sie aus Tokenzahl und Dollar je Token vergleichbarer Sitzungen schätzen und als „geschätzt“ kennzeichnen, oder bleibt „fehlt“ stehen?
**Votum Ford (geändert 28.10., 23:36 nach Rückfrage des Chefs):** gekennzeichnete Schätzung („~“, Spanne ±30 %) statt Lücke, in eigener Spalte „geschätzt“, nie als gebuchte Zahl in `KOSTEN-GEBUCHT.tsv`; ohne Tokenzahl (Jerry 348.12) bleibt „fehlt“. Gegenargument: Scheingenauigkeit; spricht für die Spanne, nicht gegen die Schätzung, weil „fehlt“ die Kosten je Vorgang systematisch zu niedrig ausweist.
**Berührt:** `docs/KOSTEN-GEBUCHT.tsv`, Spalte „Kosten“ in `LISTE-VORGAENGE.md`, `tools/kosten.py`.

**Stellungnahme Sokrates** (29.10., 00:1x): *Stärkstes Gegenargument:* Die Tokenzahl taugt nicht als Grundlage. `used_tokens` ist laut `tools/lauf.py` Zeile 7 die Belegung des Kontextfensters (`context_usage`, für WEITER), nicht die Summe aller abgerechneten Token; was eine Sitzung kostet, hängt an der Zahl der Züge und den Cache-Lesungen, zwei Sitzungen mit 90 Tsd. Token Kontext können 5 $ oder 40 $ gekostet haben. Die Spanne ±30 % täuscht darum eine Genauigkeit vor, die die Grundlage nicht hat. Dazu: drei Sitzungen, einmalig; die Folgerung (vor dem Archivieren `get_session`) schließt die Lücke für die Zukunft, eine neue Spalte und ein Umbau von `kosten.py` wären Ablauf für einen Altfall. *Widerspruch zu Entschiedenem:* keiner; `kosten.py` (Zeile 8) zählt Sitzungen ohne Kosten und rechnet sie nie als 0 $, das bleibt. *Kosten:* Schätzung von Hand etwa 1 $; Spalte und Werkzeug nach Fords Votum eine Sitzung, etwa 5–8 $ (Mittel aller 590 gebuchten Sitzungen 7,60 $). Die Lücke selbst liegt nach diesem Mittel um 20–25 $, gegen 263 $ gebuchte Kosten der drei Vorgänge (138 + 89 + 35), also unter 10 %. *Empfehlung in einem Satz:* Ja zur gekennzeichneten Schätzung, aber nach dem Mittel gebuchter Sitzungen derselben Rolle vom selben Tag statt nach Tokenzahl (dann auch für 348.12), einmalig als Zeile „Zu 404“ im Betriebsvorrat mit „~“, ohne neue Spalte und ohne Änderung an `kosten.py`.

## Sachverhalt

Betroffen (28.10.): Tom 2 „385 Zaubererbewegung“ (`01Hmoj79kd`, 86.770 Token, Vorgang 385), Jerry „348.12 Gestalt Grak und Kobolde“ (`01Hmoj78yA`, Vorgang 348.12), Tom „348.13 Tusche Runde 8“ (`01Hmoj79S6`, 106.812 Token, Vorgang 348.13). `usage` ist im archivierten Datensatz leer; Kosten stehen nur vor dem Archivieren im Datensatz.

## Folgerung

Künftig vor dem Archivieren `get_session` lesen (Ford tut das), damit keine Lücke entsteht.
