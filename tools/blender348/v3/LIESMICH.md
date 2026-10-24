# 348.4: Held v3 für die Engine (Sokrates, 24.10.)

Blender 5.2.3 als Python-Modul (`uv venv -p 3.13 bl && uv pip install bpy==5.2.3 numpy pillow`).

1. `OUT=<ordner> bl/bin/python -I held3.py`: Held v2 (Abnutzung über `WEAR`, Vorgabe 0,7), Hände aus einem Guss (Voxel), `gelenke.json`.
2. `OUT=<ordner> bl/bin/python -I rig.py`: Albedo in Eckfarben backen (Abnutzung, Gesichtslinien), ein Netz, Skelett mit Gewichten, Bewegungen „Gehen“ (32 Bilder, 30 je s, Füße automatisch am Boden) und „Stehen“; `held.glb` (Zentimeter), `held-info.json` (Gehtempo gegen Fußgleiten).
3. `OUT=<ordner> bl/bin/python -I blatt.py`: Kontaktblatt zum Prüfen (`ACT=Gehen`).
