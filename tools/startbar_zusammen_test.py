#!/usr/bin/env python3
"""1424: getestete_builds kennt alte und neue Archivköpfe."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import startbar

TEXT = """- **t291 getestet** (16.11., 13:42, Chef in der App): ✓
- **t286 getestet, t287 getestet** (15.11., 16:58, Chef über Sokrates): ✓
- **t282, Build 282 getestet** (13.11., 10:40, Chef an Sokrates): ✗
- **t281, Build 281 freigegeben** (13.11., 09:12, Chef): PR
- **470 und 663 jetzt** (10.11., 12:58, t274 getestet im Text zählt nicht)
"""
g = startbar.getestete_builds(TEXT)
assert sorted(g) == ["282", "286", "287", "291"], g
assert (g["291"].day, g["291"].hour, g["291"].minute) == (16, 13, 42), g["291"]
assert g["286"] == g["287"]
print("startbar_zusammen_test gut")
