#!/usr/bin/env python3
"""1642: Startwarnung nach 6 h als Vorgang beim Besitzer, Zähler hoch; Warnung weg → Vorgang erledigt; unter 6 h nichts; Pflegezeilen fallen weg."""
import datetime, json, os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import startwarnung as W

jetzt = W.jetzt()
w = dict(schluessel="groesse:docs/ARBEIT-BETRIEB.md", besitzer="Ford", code="Größe", text="docs/ARBEIT-BETRIEB.md hat 31953 Bytes (Grenze 30000)")
echt = W.zeige
fehler = []

def lauf(stand, liste=None):
    W.stand_laden = lambda ref="origin/main": stand
    W.zeige = lambda ref, p: (liste if (p == W.LISTE and liste is not None) else ("" if p == W.STAND else echt(ref, p)))
    return W.berechnen("origin/main", [w], jetzt) if stand is not None else None

# unter 6 h: kein Vorgang
aus, m = lauf({w["schluessel"]: {"seit": (jetzt - datetime.timedelta(hours=5)).isoformat()}})
if m or "| Startwarnung" in aus.get(W.LISTE, ""): fehler.append("unter 6 h angelegt")
if any(z.startswith("| Pflege |") for z in aus.get(W.LISTE, echt("origin/main", W.LISTE)).split("\n")): fehler.append("Pflegezeile blieb")

# über 6 h: Vorgang bei Ford, Zähler hoch
aus, m = lauf({w["schluessel"]: {"seit": (jetzt - datetime.timedelta(hours=7)).isoformat()}})
st = json.loads(aus.get(W.STAND, "{}"))
nr = st.get(w["schluessel"], {}).get("vorgang")
if not nr: fehler.append("kein Vorgang nach 7 h")
else:
    z = next((z for z in aus[W.LISTE].split("\n") if z.startswith(f"| {nr} |")), "")
    if "| Ford | K | startbar |" not in z or "Startwarnung" not in z: fehler.append("Zeile falsch: " + z)
    mm = re.search(r"Nächste freie Vorgangsnummer: (\d+)", aus.get("docs/ARBEIT-BETRIEB.md", ""))
    if not mm or int(mm.group(1)) != int(nr) + 1: fehler.append("Zähler nicht hoch")
    # zweiter Lauf mit Vorgang: kein neuer
    liste = aus[W.LISTE]
    aus2, m2 = lauf(st, liste)
    if m2: fehler.append("zweimal angelegt: %s" % m2)
    # Warnung weg: erledigt
    W.stand_laden = lambda ref="origin/main": st
    W.zeige = lambda ref, p: (liste if p == W.LISTE else ("" if p == W.STAND else echt(ref, p)))
    aus3, m3 = W.berechnen("origin/main", [], jetzt)
    z3 = next((z for z in aus3.get(W.LISTE, "").split("\n") if z.startswith(f"| {nr} |")), "")
    if "erledigt, Warnung weg" not in z3: fehler.append("nicht erledigt: " + z3)

# Besitzer fest
if W.datei_besitzer("docs/ARBEIT-TEAM-SPIKE.md") != "Spike" or W.datei_besitzer("STORY-MERKMALE-TIERE.md") != "Homer": fehler.append("Besitzer")
print("startwarnung_test:", "grün" if not fehler else "ROT: " + "; ".join(fehler))
sys.exit(1 if fehler else 0)
