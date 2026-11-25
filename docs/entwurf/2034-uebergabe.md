# 2034 Teil 0: Übergabe Edda (25.11., 18:29)

Nachfolger: Edda – 2034 Teil 0: Abzug (Figur)

Stand: Signatur-Probe und Liste fertig (Zweig `claude/figur-2034-abzug`, 8337e31fe; Rückmeldungen 18:29 in `docs/vorgang/2034.md`). Offen: der eine Beleglauf Abzug (243 Bilder), erst nach Freigabe des Prüfers (Laufanforderung 18:29).

Weiter (Befehle, Pakete neu laden wie in der Liste beschrieben, `p/M<n>` je Paket ausgepackt):
1. `bl/bin/python -I tools/blender348/v3/abzug_mh.py <p> <glb>` (bpy 5.2.3 im venv ~/bl), dann `python3 tools/godot/abzug_2034_liste.py <p> <glb>/liste.json docs/entwurf/2034-abzug.md <commit> <messung.json>` (setzt `lizenz`, `zeichnen`).
2. Nur Stücke mit „ja“: `NUR=` aus liste.json (zeichnen true), `PROBE=2034 LISTE=… GLB=… AUS=<roh> xvfb-run -a ~/godot/godot --path godot --rendering-method mobile -s res://tests/abzug_2034.gd > lauf.log`.
3. `tools/godot/abzug_2034.sh <roh> <liste.json> lauf.log docs/entwurf/2034-abzug <commit> abzug "" <NUR>`; jedes zehnte Bild ansehen; Häute (49) als `<Nr>_haut.png` noch ohne Randtext: im Skript ergänzen.
4. Rückmeldung „fertig“ mit Commit über `vorgang.py rueckmeldung 2034` in ../bornim-main.
