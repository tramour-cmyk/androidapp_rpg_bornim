#!/usr/bin/env python3
"""Ein Vorgang an allen Orten (275 Stufe 1): gezielt suchen statt ganze Listen lesen (Chef 27.10., 15:11).

Aufruf: python3 tools/vorgang.py NR [NR …]
Zeigt je Nummer: Zeile in LISTE-VORGAENGE.md (oder -ARCHIV.md), Vorratszeile(n) mit Rolle, Absätze „Zu NR“,
Entscheide im Vorgangsarchiv, Dateien in der Chefsache, Leiche laut startbar.py. Liest nur, schreibt nichts.
"""
import os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import startbar

DOCS = startbar.DOCS

def treffer(nr):
    aus = []
    n = re.escape(nr)
    for d in ("LISTE-VORGAENGE.md", "LISTE-VORGAENGE-ARCHIV.md"):
        aus += ["Liste%s: %s" % (" (Archiv)" if "ARCHIV" in d else "", z) for z in startbar.lesen(d).splitlines() if re.match(r"\| " + n + r" \|", z)]
    for datei, rolle in startbar.ROLLEN + [("ARBEIT-BETRIEB.md", "Ford")]:
        for z in startbar.lesen(datei).splitlines():
            if re.match(r"\| " + n + r" \|", z): aus.append("Vorrat %s: %s" % (rolle, z))
            elif re.match(r"- \*\*(Zu|Von [^*]*zu) " + n + r"\b", z): aus.append("Zu %s (%s): %s" % (nr, rolle, z[:600] + (" …" if len(z) > 600 else "")))
    for z in startbar.lesen("VORGANGSARCHIV.md").splitlines():
        if re.match(r"- \*\*" + n + r"[ ,.*:]", z): aus.append("Archiv: " + z[:600] + (" …" if len(z) > 600 else ""))
    pre = nr.replace(".", "").lower()
    for ordner in ("entscheiden", "ansehen", "billigen", "tun"):
        d = os.path.join(DOCS, "chefsache", ordner)
        aus += ["Chefsache: %s/%s" % (ordner, f) for f in (sorted(os.listdir(d)) if os.path.isdir(d) else []) if f.lower().startswith(pre + "-")]
    for datei, rolle in startbar.ROLLEN:
        zs = [z for z in startbar.zeilen(startbar.lesen(datei)) if z[0] == nr]
        if zs:
            l = startbar.leiche(nr, zs[0][3], startbar.blocker(nr, zs[0][3], startbar.chefdateien(), zs[0][2]))
            if l: aus.append("Leiche (%s): %s" % (rolle, l))
    return aus

if __name__ == "__main__":
    if len(sys.argv) < 2: print(__doc__); sys.exit(2)
    for nr in sys.argv[1:]:
        print("== %s" % nr)
        print("\n".join(treffer(nr)) or "nichts gefunden")
