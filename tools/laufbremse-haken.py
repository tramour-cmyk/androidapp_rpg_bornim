#!/usr/bin/env python3
"""Laufbremse-Haken (1859, 1937; Chef 1727k A 22.11., 12:28): ein Eintrag in `.claude/settings.json` statt drei für
`probelauf.py` (Bash, `actions_run_trigger`, `push_files`/`create_or_update_file`). Die Prüfungen selbst stehen weiter in
`probelauf.py` (Bibliothek für `commit-pruefung.py`, `vorlage_pruefen.py` u. a.); was dort Ersatz hat, fällt einzeln (1937)."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import probelauf  # noqa: E402

if __name__ == "__main__":
    try:
        probelauf.main()
    except probelauf.Unaufloesbar as e:  # 725, 1938 (D377.1): wie probelauf.py, sonst Exit 1 und der Befehl ginge durch
        probelauf.anhalten(str(e))
