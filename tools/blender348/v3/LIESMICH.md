# 348.4: Held v3 für die Engine (Sokrates, 24.10.)

Blender 5.2.3 als Python-Modul (`uv venv -p 3.13 bl && uv pip install bpy==5.2.3 numpy pillow`).

1. `OUT=<ordner> bl/bin/python -I held3.py`: Held v2 (Abnutzung über `WEAR`, Vorgabe 0,7), Hände aus einem Guss (Voxel), `gelenke.json`.
2. `OUT=<ordner> bl/bin/python -I rig.py`: Albedo in Eckfarben backen (Abnutzung, Gesichtslinien), ein Netz, Skelett mit Gewichten, Bewegungen „Gehen“ (32 Bilder, 30 je s, Füße automatisch am Boden) und „Stehen“; `held.glb` (Zentimeter), `held-info.json` (Gehtempo gegen Fußgleiten).
3. `OUT=<ordner> bl/bin/python -I blatt.py`: Kontaktblatt zum Prüfen (`ACT=Gehen`).

## 348.6: für das Spiel (Tom, 25.10.)

- Ausgabe in Metern (Modellregel 1): `held.glb` (rig.py) und `dorf.glb` (dorf.py); gebaut wird intern weiter in Zentimetern.
- `dorf.py` liest die Karte aus dem Export von `core` (`KARTEN=<karten.json>`, `KARTE=village`), nicht mehr aus `Story.kt`.
- Bau im Workflow `godot.yml`; Ablage im Spiel: `godot/daten/`.

## 348.6: CC0-Gerüst (Tom, 26.10.; Chef 25.10., 23:33, 348.12)

- `rig.py` mit `GERUEST=cc0` (Vorgabe): Gewichte wie bisher, dann `geruest.py`: Knochen und Bewegungen aus Quaternius' Universal Animation Library (CC0 1.0, `cc0_laden.sh <ordner>`, dann `CC0=<ordner>`, Vorgabe `~/cc0`), Knochen an unsere Gelenke, Gliedmaßen in Richtung der fremden Knochen, Rumpf und Kopf nur deren Drehung. `GERUEST=eigen`: bisheriges Gerüst mit eigenen Bewegungen (zum Vergleich).
- Held: Stehen, Gehen, Rennen (Jog_Fwd_Loop), dazu `_Fackel` (linker Arm aus Idle_Torch_Loop); Leute: Stehen, Gehen. Kopf je Bewegung auf −3° (fremd 10–18° gesenkt), Stehen zum Betrachter zurückgedreht.
- `held-info.json`: `faust_L` (Knochen `hand_l`, Griff, Achse) für `held.gd`; `knochen_R`, `griff_R` für `leute.gd`.
- Runde 3 (26.10.): Schalen erben die Beschriftung des Körpers (`seg`, held3.py → rig.py), Schulterglättung 0,8 Oberarmlängen, Gürtel nur am Rumpf; Leute gehen mit `gang.schritt` (lange Gewänder × 0,8, Rock 16 cm Mitte, Wade 0,5); Held rennt mit Armschwung 0,6 (Schlüsselbein und Oberarm); ausdrücklich „haengen“ hängt; Prüfblatt zeigt das getragene Ding (`WAFFEN=<ordner>` mit `<kennung>.glb`, Vorgabe `<OUT>/../waffen`).
- Feinschliff 10 (26.10.): Kittel und Ärmel der Leute einlagig (`EINLAGIG=0`: Doppelschale wie bisher). Prüfen ohne Bild: `TEILFARBE=1 OUT=<figur> pruefblatt.py` malt jede Lage in eigener Farbe (Rückseiten ein Viertel so hell) nach `<figur>/pbt`, `python3 pruef_farbe.py <figur>…` zählt je Schulterbild sichtbaren Körper und Rückseiten (beides Fehler). `pruef_lagen` `aermel_durch` führte bei der Flanke in die Irre (Ärmel an der Flanke nach innen: Zahl besser, Bild schlechter).
