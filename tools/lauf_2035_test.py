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
# Teil „Disponent erkennen“ (Auftrag 25.11., 20:45): kosten.rolle, guthaben (R53), leitung_neustart
import guthaben, rufname
for t_ in ("Otto – Disponent – Betrieb (25.11., 20:29)", "Detlef – Disponent – Betrieb (25.11., 18:47)"):
    soll("kosten.rolle %s → Disponent" % t_, kosten.rolle(t_, "2026-11-25T19:29:00Z") == "Disponent", kosten.rolle(t_, "2026-11-25T19:29:00Z"))
for t_ in ("Disponent-Starter (23.11., 10:13)", "Wache – Disponent (23.11., 13:35)", "Vera – 2039: Bauliste (25.11., 20:40)",
           "Olga – Auftrag 1961: Ford heißt Disponent (22.11., 17:16)"):
    soll("kosten.rolle %s → nicht Disponent" % t_, kosten.rolle(t_, "2026-11-25T19:40:00Z") != "Disponent", kosten.rolle(t_))
soll("rufname.ALLE kennt Edda, Ines, Selma, Inge, Tilda, Detlef, Ralf, Otto",
     {"Edda", "Ines", "Selma", "Inge", "Tilda", "Detlef", "Ralf", "Otto"} <= rufname.ALLE, sorted({"Edda", "Ines", "Selma", "Inge", "Tilda", "Detlef", "Ralf"} - rufname.ALLE))
soll("Vergabeliste NAMEN ohne die sieben (nur Erkennung)", not {"Edda", "Ines", "Selma", "Inge", "Tilda", "Detlef", "Ralf"} & {n for ns in rufname.NAMEN.values() for n in ns})
RALF = "Ralf – 2035: Prüfung 2035-Ü30 (25.11., 20:31)"
soll("guthaben.ober_rolle Ralf – 2035: Prüfung → Prüfer", guthaben.ober_rolle(kosten.rolle(RALF, "2026-11-25T19:31:00Z"), RALF) == "Prüfer")
def jr(ss):
    j = {}
    for s in ss: s["_info"] = (kosten.rolle(s["title"], s["created_at"]), True, 1, []); j.setdefault(s["_info"][0], []).append(s)
    return j
j = jr([{"id": "session_DET", "title": TITEL["session_DETLEF"], "created_at": "2026-11-25T17:47:00Z", "status_bucket": "WORKING"},
        {"id": "session_RALF", "title": RALF, "created_at": "2026-11-25T19:31:00Z", "status_bucket": "WORKING"}])
soll("guthaben (R53): Detlef zählt nicht als Fachkraft, Ralf nicht (Prüfer frei)", guthaben.laufende_fachkraefte(j) == 0, guthaben.laufende_namen(j))
s = {"id": "session_DET", "title": TITEL["session_DETLEF"], "created_at": "2026-11-25T17:47:00Z", "context_usage": {"used_tokens": 314000}}
z = lauf.leitung_neustart(jr([s]), set(), wache="session_W")
soll("leitung_neustart Detlef 314 Tsd. → NEUSTART-DISPONENT", any(l.startswith("NEUSTART-DISPONENT session_DET") for l in z), z)
s = {"id": "session_DET", "title": TITEL["session_DETLEF"], "created_at": "2026-11-25T17:47:00Z"}
z = lauf.leitung_neustart(jr([s]), set(), wache="session_W")
soll("leitung_neustart Detlef ohne Zahl → TOKEN", z == ["TOKEN session_DET | Disponent: get_session, lauf.py neu mit --token session_DET=<used_tokens> (2042 d)"], z)
print("lauf_2035_test: " + ("gut" if not fehl else "%d Fehler" % fehl))
sys.exit(1 if fehl else 0)
