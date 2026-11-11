# 854b · Darf der Kauf-Cache je Block ohne Gerätetest auf `main`?
Jerry · 11.11., 09:06 · E Technik · aus deinem „2 ja“ 08:52 (über Sokrates)
Kurz: Kauf-Cache je Block (figur, dorf, klassen, kampf) ohne Gerätetest auf main, damit jeder Lauf nur neu baut, was sich geändert hat.

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/1f4e21a81 (Probe am Rechner `tools/godot/kauf_cache_probe.sh`: 13 von 13 gut)

**Frage:** Du hast „Kennung je Block“ freigegeben. Gebaut ist es; es ändert nur den Bauserver (`godot.yml`, `tools/godot/kauf_cache.py`, `bau_am_rechner.py`), kein Spielcode. Der Probelauf-Haken lässt für 854 keinen weiteren Lauf zu. Soll es ohne Gerätetest auf `main`? Dann legt der erste Lauf aus `main` je Block ab, und jeder weitere Lauf trifft, solange sich ein Block nicht ändert.

**Votum:** „854b A“

**Berührt:** alle Läufe von `godot.yml` (Tom, Jerry, Perikles); B1 (Tom) nimmt es über `main` mit.

**Begründung:** Chef 08:01: „wichtig wäre, dass das jetzt … mit diesen vorgerenderten Kaufmodellen endlich klappt“. Bisher warf jede Änderung an `tools/blender348` (44 in 7 Tagen) den ganzen Cache weg.

**Sachverhalt:**
- Teil 1 (Cache greift überhaupt) ist seit 08:57 auf `main` (`8d4183068`); Lauf 338 hat zum ersten Mal abgelegt (164 Dateien, 486 MB).
- Je Block liest die Kennung nur noch seine Dateien: figur 6, dorf 3, klassen 11, kampf 31 statt aller 94. Eine Änderung an `leute.json` baut nur figur und klassen (und kampf, weil es den Helden aus figur braucht) neu, nicht das Dorf; eine an `raum.py` nur das Dorf.
- Schritt 7 schreibt je Block „treffer“ oder „bauen“ und die geänderten Dateien.
- Die wöchentliche Gegenprobe (`vergleich`) bleibt: sie meldet, wenn eine Kennung eine Eingabe übersieht.

**Auswertung:**
- **A (Empfehlung):** ohne Gerätetest auf `main`. Ein Lauf baut je Block voll (wie heute) und legt ab; ab dem zweiten sparen die Blöcke ohne Änderung ihre Zeit (Held je Klasse 27 min, Kampfort 15 min, Dorf etwa 3 min).
- **B:** erst ein Lauf auf dem Zweig (Sokrates „854, Läufe frei“), dann `main`. Ein Lauf mehr (etwa 85 min), aber Beleg vor `main`.
- **Stärkstes Gegenargument gegen A:** Die Erkennung der Eingaben liest die Skripte; ein Skript, das eine Datei über einen zusammengesetzten Namen lädt, fällt durch, dann holt ein Lauf einen veralteten Block. Das deckt erst die Gegenprobe auf.

**Folgerungen:** A: Jerry nimmt `1f4e21a81` auf `main`, meldet den ersten Treffer. B: Jerry startet einen Lauf auf `claude/jerry-854-block`, danach `main`.

Antwort: …
