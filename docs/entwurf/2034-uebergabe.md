# 2034 Teil 0: Übergabe Edda (25.11., 18:29)

Nachfolger: Edda – 2034 Teil 0: Abzug (Figur)

Stand: Signatur-Probe und Liste fertig (Zweig `claude/figur-2034-abzug`, 8337e31fe; Rückmeldungen 18:29 in `docs/vorgang/2034.md`). Offen: der eine Beleglauf Abzug (243 Bilder), erst nach Freigabe des Prüfers (Laufanforderung 18:29).

Weiter (Befehle, Pakete neu laden wie in der Liste beschrieben, `p/M<n>` je Paket ausgepackt):
1. `bl/bin/python -I tools/blender348/v3/abzug_mh.py <p> <glb>` (bpy 5.2.3 im venv ~/bl), dann `python3 tools/godot/abzug_2034_liste.py <p> <glb>/liste.json docs/entwurf/2034-abzug.md <commit> <messung.json>` (setzt `lizenz`, `zeichnen`).
2. Nur Stücke mit „ja“: `NUR=` aus liste.json (zeichnen true), `PROBE=2034 LISTE=… GLB=… AUS=<roh> xvfb-run -a ~/godot/godot --path godot --rendering-method mobile -s res://tests/abzug_2034.gd > lauf.log`.
3. `tools/godot/abzug_2034.sh <roh> <liste.json> lauf.log docs/entwurf/2034-abzug <commit> abzug "" <NUR>`; jedes zehnte Bild ansehen; Häute (49) als `<Nr>_haut.png` noch ohne Randtext: im Skript ergänzen.
4. Rückmeldung „fertig“ mit Commit über `vorgang.py rueckmeldung 2034` in ../bornim-main.

## Nachtrag 18:46: Prüfer-Nein 18:42 (2034-Ü6, von Edda angenommen, an Nachfolger)

Erst lesen: `docs/vorgang/2034.md` Rückmeldung 18:42 und Hinweis 2034-Ü7. Kern:
1. Robe M36-05 und Stiefel M57-09: mit und ohne Tusche im Bild gleich; dunkles Stück (Helligkeit 0,09–0,16) auf blauschwarzem Grund, Tusche unsichtbar, die Messung (Umriss 54–55 %) widerspricht dem Bild. Tusche an dunklen Stücken sichtbar machen (Licht- oder Randkante gegen den Grund, nicht linear aufhellen), neues Probebild Robe und Stiefel; sonst „Frage“ mit Probebild. Messung in `abzug_2034_signatur.py` so ändern, dass sie die Sichtbarkeit misst (Kontrast Linie gegen Grund und Stück), nicht nur „dunkler als ohne“.
2. Stiefel füllen nur etwa 40 % der Höhe (Paar weit auseinander): Rahmung in `abzug_2034.gd` anpassen (z. B. einen Stiefel zeigen oder Paar enger); Pixelblöcke im Leder prüfen.
Laufbremse: Lauf 1 für 2034 ist verbraucht, nächster Bildlauf erst nach Prüfer-Ja zur neuen Laufanforderung.
