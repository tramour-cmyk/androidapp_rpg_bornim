# 348.4: Held v3 für die Engine (Sokrates, 24.10.)

Blender 5.2.3 als Python-Modul (`uv venv -p 3.13 bl && uv pip install bpy==5.2.3 numpy pillow`).

1. `OUT=<ordner> bl/bin/python -I held3.py`: Held v2 (Abnutzung über `WEAR`, Vorgabe 0,7), Hände aus einem Guss (Voxel), `gelenke.json`.
2. `OUT=<ordner> bl/bin/python -I rig.py`: Albedo in Eckfarben backen (Abnutzung, Gesichtslinien), ein Netz, Skelett mit Gewichten, Bewegungen „Gehen“ (32 Bilder, 30 je s, Füße automatisch am Boden) und „Stehen“; `held.glb` (Zentimeter), `held-info.json` (Gehtempo gegen Fußgleiten).
3. `OUT=<ordner> bl/bin/python -I blatt.py`: Kontaktblatt zum Prüfen (`ACT=Gehen`).

## 348.6: für das Spiel (Tom, 25.10.)

- Ausgabe in Metern (Modellregel 1): `held.glb` (rig.py) und `dorf.glb` (dorf.py); gebaut wird intern weiter in Zentimetern.
- `dorf.py` liest die Karte aus dem Export von `core` (`KARTEN=<karten.json>`, `KARTE=village`), nicht mehr aus `Story.kt`.
- Bau im Workflow `godot.yml`; Ablage im Spiel: `godot/daten/`.

## 348.12: Probe CC0-Grundkörper (Jerry, 25.10.)

- Nur Probe, kein Ersatz für Held und Leute (Chefsache 348.12). Fremde Dateien werden nicht eingecheckt; `cc0_laden.sh <ordner>` lädt sie von itch.io und bricht ab, wenn die Lizenzdatei nicht „CC0 1.0“ nennt.
- Quellen, alle von Quaternius (quaternius.com, quaternius.itch.io), Lizenz CC0 1.0 laut `License*.txt` im Paket, nachgesehen 25.10.: Universal Base Characters [Standard] (Kopf, Augen, Brauen aus `Superhero_Male_FullBody.gltf`), Modular Character Outfits – Fantasy [Standard] (`Male_Ranger.gltf` ohne Schulterstück, oder `AUSRUESTUNG=Male_Peasant`), Universal Animation Library [Standard] (`UAL1_Standard.glb`).
- `CC0=<ordner> OUT=<ordner> bl/bin/python -I cc0.py` → `cc0.glb` (5880 Dreiecke, 65 Knochen des fremden Skeletts, Bewegungen Stehen, Gehen, Rennen, Hieb, Abwehr, Treffer, Tod, Fackel), `cc0-info.json` (Gehtempo, Quellen).
- Im Spiel: `godot/daten/probe/cc0.bin` (+ `-info.json`), dann `godot --path godot -- --cc0=<ordner>`: Held r5 und Probe nebeneinander auf dem Dorfplatz (Klinge nur als Platzhalter in der Probe).
- Völker (Chef 25.10., 23:33: erst Probe, ob das Gerüst Zwerg und Halbling trägt): `VOLK=zwerg|halbling` → `cc0-zwerg.glb`, `cc0-halbling.glb`; Knochen länger/kürzer nach `Doll.kt` (Beine, Rumpf, Hals, Kopf, Arme, Dicke, Schultern, Hände, Füße), Netz linear mitgezogen, Beckenverschiebung der Bewegungen mit der Beinlänge; Zwerg ohne Kapuze mit Bart. `info` meldet je Bewegung den tiefsten Fußpunkt (`boden_m`). Im Spiel neben `cc0.bin` nach `godot/daten/probe/`, `--cc0` stellt dann Held, Mensch, Zwerg, Halbling in eine Reihe.
