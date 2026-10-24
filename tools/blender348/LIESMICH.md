# Probe 348: Blender-Held (Sokrates, 24.10.)

Versuchsskripte, kein Spielcode. Blender 5.2.3 als Python-Modul (`pip install bpy==5.2.3` in einer venv, Python 3.13), Rendern mit Cycles (CPU), Look in `post.py` (numpy). Pfade in den Skripten zeigen auf das Scratchpad der Sitzung vom 24.10. und sind anzupassen.

- `build.py` Held v1, `mk2.py` erzeugt `build2.py` aus `teil2.py`, `teil3.py` (Held v2, Abnutzung)
- `render.py` Passes, `post.py` Toon/gemalt und Tusche nach Licht
- `vgl.py`, `vgl2.py`, `final.py` Vergleichsbilder; `st.py`, `stk.py` stilisiert nah und Karte
- `aldric/kopf.py` Grundkopf mit Reglern (Shape Keys), drei Köpfe

Bilder und Befund: `docs/chefsache/entscheiden/348-engine.md` auf `main`.
