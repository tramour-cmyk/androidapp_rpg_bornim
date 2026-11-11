#!/usr/bin/env python3
"""Fundstellen zum Glossar (648, Chef 08.11., 13:01: „schlaue Verlinkung“, „nicht nonstop aktualisieren“).

Aufruf: python3 tools/glossar.py <Begriff> [<Begriff> …]   Eintrag aus docs/LISTE-GLOSSAR.md und Dateien, die den Begriff nennen
        python3 tools/glossar.py --pruefen                 wo Wörter aus der Spalte „nicht“ noch stehen (ohne Archive und docs/alt)
Nur lesen; ändert nichts.
"""
import os
import re
import subprocess
import sys

REPO = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
GLOSSAR = os.path.join(REPO, "docs", "LISTE-GLOSSAR.md")
OHNE = [":!docs/VORGANGSARCHIV.md", ":!docs/PRUEFBERICHT*.md", ":!docs/LISTE-VORGAENGE-ARCHIV.md", ":!docs/alt",
        ":!docs/LISTE-GLOSSAR.md", ":!CLAUDE.md", ":!docs/LISTE-KOSTEN.md"]
ALLTAG = {"Thema", "Nummer", "Stand", "Auftrag", "Priorität"}  # „nicht“ nur als Ersatz für den Begriff, sonst übliche Wörter


def eintraege():
    aus = []
    for z in open(GLOSSAR, encoding="utf-8"):
        t = [x.strip() for x in z.strip().strip("|").split("|")]
        if len(t) == 5 and t[0].startswith("**"):
            namen = re.findall(r"\*\*([^*]+)\*\*", t[0])
            aus.append((namen, t[1], t[2], t[3], t[4]))
    return aus


def fundstellen(wort):
    r = subprocess.run(["git", "-C", REPO, "grep", "-l", "-w", "-F", "-e", wort, "--", "docs", "CLAUDE.md", "tools/*.py", *[o for o in OHNE if o != ":!CLAUDE.md"]],
                       capture_output=True, text=True)
    return r.stdout.split()


def main():
    a = sys.argv[1:]
    if not a:
        sys.exit(__doc__)
    if a[0] == "--pruefen":
        treffer = 0
        for namen, _, _, nicht, _ in eintraege():
            for w in re.split(r"[;,]\s*", nicht):
                w = w.strip()
                if not w or w == "–" or " " in w or w in ALLTAG:
                    continue
                r = subprocess.run(["git", "-C", REPO, "grep", "-n", "-w", "-F", "-e", w, "--", "docs", *OHNE],
                                   capture_output=True, text=True).stdout.splitlines()
                if r:
                    treffer += len(r)
                    print(f"„{w}“ statt „{namen[0]}“: {len(r)} Stellen, z. B. " + "; ".join(x.split(":")[0] + ":" + x.split(":")[1] for x in r[:3]))
        print(f"glossar.py: {treffer} Stellen mit Wörtern aus „nicht“")
        return
    alle = eintraege()
    for wort in a:
        e = [x for x in alle if any(n.lower() == wort.lower() for n in x[0])]
        for namen, bed, baum, nicht, wo in e:
            print(f"{', '.join(namen)}: {bed}\n  gehört zu → darunter: {baum}\n  nicht: {nicht}\n  steht in: {wo}")
        if not e:
            print(f"{wort}: nicht im Glossar")
        f = fundstellen(wort)
        print(f"  Fundstellen ({len(f)}): " + ", ".join(f[:20]) + (" …" if len(f) > 20 else ""))


if __name__ == "__main__":
    main()
