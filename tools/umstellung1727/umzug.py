#!/usr/bin/env python3
"""1727 Umzug „Zu <Nr>“ (1865, mit 1871): Absätze „- **Zu <Nr> …**“ aus den Vorräten `ARBEIT-*.md` in `docs/vorgang/<Nr>.md`.

Stellt einen docs-Ordner um, nie den laufenden: erst der Umschalt-Commit (Bauliste Schritt 8, `tools/1727-SCHARF`) bringt ihn
nach main, Rückweg `git revert` dieses einen Commits.

  umzug.py DOCS [--bericht DATEI] [--trocken]

Was geschieht:
- Ein Absatz ist die Zeile „- **Zu …“ samt eingerückter Folgezeilen. Er wandert wörtlich (Jeder Text an einem Ort) in die
  Vorgangsdatei der ersten genannten Nummer, Abschnitt „## Aus dem Vorrat (Umzug 1727)“, mit Quelle (Vorratsdatei);
  jede weitere Nummer im Kopf („Zu 1760, 1799, 1804“) bekommt dort nur einen Verweis auf die erste Datei.
- Fehlt die Vorgangsdatei, legt der Umzug sie an (Kopf aus Liste oder Archiv: „# <Nr> · <Titel>“).
- Absätze ohne Nummer im Kopf („Zu Archivprüfung …“) wandern nach `docs/vorgang/ohne-nummer.md`, Bericht OHNE.
- Im Vorrat bleibt alles andere (Übergabe, Pause, Einzelheiten); Umzug zählt je Vorrat.
Zweiter Lauf ändert nichts (kein „- **Zu“ mehr im Vorrat).
"""
import os, re, sys

KOPF = re.compile(r"^- \*\*Zu ((?:\d+[0-9a-zA-Z.]*)(?:(?:, | und |/)\d+[0-9a-zA-Z.]*)*)\b")
ABSCHNITT = "## Aus dem Vorrat (Umzug 1727)"


def absaetze(text):
    """(Absätze [(Zeilen von, bis, Text)], übrige Zeilen)."""
    L = text.split("\n")
    aus, rest, i = [], [], 0
    while i < len(L):
        if L[i].startswith("- **Zu "):
            j = i + 1
            while j < len(L) and L[j][:1] in (" ", "\t") and L[j].strip(): j += 1
            aus.append("\n".join(L[i:j])); i = j
        else:
            rest.append(L[i]); i += 1
    return aus, rest


def nummern(absatz):
    m = KOPF.match(absatz)
    if not m: return []
    return [n.rstrip(".") for n in re.split(r", | und |/", m.group(1)) if n]


def titel_aus_liste(docs):
    t = {}
    for f in ("LISTE-VORGAENGE-ARCHIV.md", "LISTE-VORGAENGE.md"):  # Liste zuletzt: ihr Titel gilt
        try:
            for z in open(os.path.join(docs, f), encoding="utf-8"):
                c = [x.strip() for x in z.strip().strip("|").split(" | ")]
                if len(c) > 2 and re.match(r"\d", c[0]): t[c[0]] = c[1]
        except OSError:
            pass
    return t


def anhaengen(docs, nr, eintraege, titel, trocken):
    p = os.path.join(docs, "vorgang", "%s.md" % nr)
    try: text = open(p, encoding="utf-8").read()
    except OSError: text = ""
    neu = not text
    if neu:
        k = titel.get(nr, "")
        k = re.sub(r"^Von [^:(]+?(?:\s*\((?:[^()]|\([^()]*\))*\))?[:,]\s*", "", k)[:120] or "(Titel nicht in Liste oder Archiv)"
        text = "# %s · %s\n\nVorgangsdatei (1727 Gesamtbild 0a). Übergaben schreibt nur `vorgang.py` (1760).\n" % (nr, k)
    if ABSCHNITT not in text:
        text = text.rstrip("\n") + "\n\n" + ABSCHNITT + "\n\nWörtlich aus den Vorräten, je Absatz die Quelle.\n"
    text = text.rstrip("\n") + "\n\n" + "\n\n".join(eintraege) + "\n"
    if not trocken:
        os.makedirs(os.path.dirname(p), exist_ok=True)
        open(p, "w", encoding="utf-8").write(text)
    return neu


def umziehen(docs, trocken=False):
    titel = titel_aus_liste(docs)
    ziel, B = {}, dict(je_vorrat={}, absaetze=0, verweise=0, ohne=[], neu=[], dateien=0)
    for f in sorted(os.listdir(docs)):
        if not (f.startswith("ARBEIT-") and f.endswith(".md")): continue
        p = os.path.join(docs, f)
        text = open(p, encoding="utf-8").read()
        ab, rest = absaetze(text)
        if not ab: continue
        B["je_vorrat"][f] = len(ab)
        for a in ab:
            B["absaetze"] += 1
            ns = nummern(a)
            quelle = "*Quelle: `%s` (bis 1727)*" % f
            if not ns:
                ziel.setdefault("ohne-nummer", []).append(quelle + "\n" + a)
                B["ohne"].append("%s: %s" % (f, a[:70].replace("\n", " ")))
                continue
            ziel.setdefault(ns[0], []).append(quelle + "\n" + a)
            for n in ns[1:]:
                ziel.setdefault(n, []).append("*Verweis: Absatz aus `%s` steht in [%s.md](%s.md), „Aus dem Vorrat“.*" % (f, ns[0], ns[0]))
                B["verweise"] += 1
        if not trocken:
            # Leerzeilen, die nur zwischen umgezogenen Absätzen standen, zusammenfassen
            neu = re.sub(r"\n{3,}", "\n\n", "\n".join(rest))
            open(p, "w", encoding="utf-8").write(neu)
    for nr, e in ziel.items():
        if anhaengen(docs, nr, e, titel, trocken): B["neu"].append(nr)
        B["dateien"] += 1
    return B


def bericht(B):
    z = ["Absätze %d in %d Vorgangsdateien (neu %d), Verweise %d" % (B["absaetze"], B["dateien"], len(B["neu"]), B["verweise"]),
         "je Vorrat: " + ", ".join("%s %d" % kv for kv in sorted(B["je_vorrat"].items())) if B["je_vorrat"] else "je Vorrat: – (schon umgezogen)"]
    z += ["OHNE Nummer → vorgang/ohne-nummer.md: " + o for o in B["ohne"]]
    return "\n".join(z)


if __name__ == "__main__":
    a = sys.argv[1:]
    if not a or a[0].startswith("-"): print(__doc__); sys.exit(2)
    B = umziehen(a[0], trocken="--trocken" in a)
    t = bericht(B)
    if "--bericht" in a: open(a[a.index("--bericht") + 1], "w", encoding="utf-8").write(t + "\n")
    print(t)
