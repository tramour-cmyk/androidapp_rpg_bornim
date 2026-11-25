#!/usr/bin/env python3
"""2035 (Chef 25.11., 19:47): lauf.besetzung_text trägt den Disponenten am Titel „Rufname – Disponent – …“ in ARBEIT-BESETZUNG.md ein
(Rolle Disponent), nie „Disponent-Starter“ oder „Wache – Disponent (…)“; Rolle wie im Lauf aus kosten.rolle. Ohne Netz.
Aufruf: python3 tools/lauf_2035_test.py"""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import kosten, lauf

fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else zeige))

TITEL = {  # Bestand list_sessions 25.11., 19:48 (2035 Auftrag 3.)
    "session_DETLEF": "Detlef – Disponent – Betrieb (25.11., 18:47)",
    "session_STARTER": "Disponent-Starter (23.11., 10:13)",
    "session_WACHE": "Wache – Disponent (24.11., 07:01)",
    "session_SABINE": "Sabine – 2035: rote lauf-Tests (25.11., 19:04)",
}
leb = [{"id": k, "title": t, "created_at": "2026-11-25T17:47:00Z"} for k, t in TITEL.items()]
for s in leb: s["_info"] = (kosten.rolle(s["title"], s["created_at"]), True, 1, [])
t = lauf.besetzung_text("| Rolle | Sitzung | Vorgang | Zweig | seit |\n|---|---|---|---|---|\n", leb)
zeilen = {z.split("code/")[1].split(")")[0]: z.split(" | ")[0].strip("| ") for z in t.splitlines() if "code/session_" in z}
soll("Detlef – Disponent – Betrieb: Zeile mit Rolle Disponent", zeilen.get("session_DETLEF") == "Disponent", t)
soll("Disponent-Starter: keine Disponent-Zeile", zeilen.get("session_STARTER") != "Disponent", t)
soll("Wache – Disponent (…): Rolle Wache, nicht Disponent", zeilen.get("session_WACHE") == "Wache", t)
soll("Fachkraft Sabine: Rolle Werkzeug", zeilen.get("session_SABINE") == "Werkzeug", t)
print("lauf_2035_test: " + ("gut" if not fehl else "%d Fehler" % fehl))
sys.exit(1 if fehl else 0)
