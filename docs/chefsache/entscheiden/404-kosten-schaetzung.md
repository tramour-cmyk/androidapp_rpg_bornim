# 404: Fehlende Sitzungskosten schätzen?

**Frage:** Bei drei archivierten Sitzungen fehlt die Kostenangabe im Datensatz. Soll Sokrates sie aus Tokenzahl und Dollar je Token vergleichbarer Sitzungen schätzen und als „geschätzt“ kennzeichnen, oder bleibt „fehlt“ stehen?
**Votum Ford:** „fehlt“ stehen lassen; eine Schätzung höchstens in einer eigenen Spalte „geschätzt“, nie in `KOSTEN-GEBUCHT.tsv`.
**Berührt:** `docs/KOSTEN-GEBUCHT.tsv`, Spalte „Kosten“ in `LISTE-VORGAENGE.md`, `tools/kosten.py`.

## Sachverhalt

Betroffen (28.10.): Tom 2 „385 Zaubererbewegung“ (`01Hmoj79kd`, 86.770 Token, Vorgang 385), Jerry „348.12 Gestalt Grak und Kobolde“ (`01Hmoj78yA`, Vorgang 348.12), Tom „348.13 Tusche Runde 8“ (`01Hmoj79S6`, 106.812 Token, Vorgang 348.13). `usage` ist im archivierten Datensatz leer; Kosten stehen nur vor dem Archivieren im Datensatz.

## Folgerung

Künftig vor dem Archivieren `get_session` lesen (Ford tut das), damit keine Lücke entsteht.
