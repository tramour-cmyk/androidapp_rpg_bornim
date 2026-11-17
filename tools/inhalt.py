#!/usr/bin/env python3
"""Inhaltsverzeichnis docs/README.md prüfen (650.2 E2, Chef 09.11., 20:52: „650.2 wie Vorschlag“).

Meldet (1) jede Datei docs/*.md und docs/kapitel2/*.md ohne Link im Inhaltsverzeichnis, (2) jeden toten relativen Link
in docs/README.md und in den Notizen docs/*.md, docs/kapitel2/*.md (ohne die drei großen Archive, deren alte Verweise
Verlauf sind). Exit 1 bei Funden. `--kurz`: eine Zeile je Fund, höchstens zehn (für notiz.sh).
"""
import os
import re
import sys

DOCS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "docs")
ARCHIVE = {"VORGANGSARCHIV.md", "LISTE-VORGAENGE-ARCHIV.md", "PRUEFBERICHT-ARCHIV.md", "CHANGELOG.md"}
LINK = re.compile(r"\]\(([^)\s]+)\)")


def notizen():
    for ordner in ("", "kapitel2"):
        d = os.path.join(DOCS, ordner)
        for n in sorted(os.listdir(d)) if os.path.isdir(d) else []:
            if n.endswith(".md"):
                yield os.path.join(ordner, n) if ordner else n


def ohne_code(text):
    """Links in Codeblöcken und `…` zählen nicht."""
    text = re.sub(r"```.*?```", "", text, flags=re.S)
    return re.sub(r"`[^`\n]*`", "", text)


def funde():
    readme = open(os.path.join(DOCS, "README.md"), encoding="utf-8").read()
    verlinkt = {os.path.normpath(z.split("#")[0]) for z in LINK.findall(ohne_code(readme))}
    aus = [f"ohne Zeile im Inhaltsverzeichnis: {p}" for p in notizen()
           if p != "README.md" and os.path.normpath(p) not in verlinkt]
    for p in notizen():
        if os.path.basename(p) in ARCHIVE:
            continue
        basis = os.path.dirname(os.path.join(DOCS, p))
        text = ohne_code(open(os.path.join(DOCS, p), encoding="utf-8").read())
        for ziel in LINK.findall(text):
            ziel = ziel.split("#")[0].strip("<>")
            if not ziel or re.match(r"[a-z][\w+.-]*:", ziel):  # http:, cs:, bilder:, mailto: …
                continue
            if re.fullmatch(r"(?:\.\./)*chefsache/(?:entscheiden|ansehen|billigen|tun)/", ziel):  # Ordner darf leer sein
                continue
            if not os.path.exists(os.path.normpath(os.path.join(basis, ziel))):
                aus.append(f"toter Link in {p}: {ziel}")
    return aus


if __name__ == "__main__":
    f = funde()
    if "--kurz" in sys.argv:
        for z in f[:10]:
            print("  - " + z)
        if len(f) > 10:
            print(f"  … und {len(f) - 10} weitere (python3 tools/inhalt.py)")
    else:
        print("\n".join(f) or "Inhaltsverzeichnis vollständig, keine toten Links.")
    sys.exit(1 if f else 0)
