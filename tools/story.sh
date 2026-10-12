#!/usr/bin/env bash
# Texte im Spiel (Dialoge, Erzähltext, Aushänge, Schilder) zwischen zwei Ständen vergleichen, ohne Code zu lesen
# (Thema 41). Zieht aus core/src/main/kotlin alle deutsch/englischen Textpaare: say(...), narrate(...), T(...).
#   tools/story.sh <von> [<bis>]   Änderungen von <von> bis <bis> (Standard: origin/main), z. B. Stand aus BERATER.md
#   tools/story.sh <von> origin/claude/zweig   auch für Zweige, die noch nicht auf main sind
#   tools/story.sh --alle [<bis>]  alle Texte eines Stands auflisten
# Ausgabe: + neu, - weg, ~ geändert (alt → neu); „EN alt“, wenn der deutsche Text sich änderte, der englische nicht.
cd "$(dirname "$0")/.." || exit 1
git fetch -q origin 2>/dev/null
exec python3 -I - "$@" <<'PY'
import re, subprocess, sys

SRC = "core/src/main/kotlin"
STR = r'"((?:[^"\\]|\\.)*)"'
SAY = re.compile(r'\bsay\(\s*(\w+)\s*,\s*' + STR + r'\s*,\s*' + STR, re.S)
NAR = re.compile(r'\b(?:narrate|T)\(\s*' + STR + r'\s*,\s*' + STR, re.S)
NAME = re.compile(r'val\s+(\w+)\s*=\s*T\(\s*' + STR)

def git(*a):
    return subprocess.run(["git", *a], capture_output=True, text=True).stdout

def texts(rev):
    out = {}
    for path in git("ls-tree", "-r", "--name-only", rev, SRC).split():
        if not path.endswith(".kt"):
            continue
        src = git("show", f"{rev}:{path}")
        if '"' not in src:
            continue
        names = {m.group(1): m.group(2) for m in NAME.finditer(src)}
        file = path.rsplit("/", 1)[-1]
        seen = set()
        for m in SAY.finditer(src):
            seen.add(m.start(2))
            who = names.get(m.group(1), m.group(1))
            add(out, file, src, m.start(), who, m.group(2), m.group(3))
        for m in NAR.finditer(src):
            if m.start(1) in seen:
                continue
            de, en = m.group(1), m.group(2)
            if " " not in de and len(de) < 25:   # Namen und Kennungen weglassen
                continue
            add(out, file, src, m.start(), "", de, en)
    return out

def add(out, file, src, pos, who, de, en):
    line = src.count("\n", 0, pos) + 1
    key = (file, who, de)
    out.setdefault(key, (line, en))

def show(k, line=None):
    file, who, de = k
    w = f"{who}: " if who else ""
    return f"{file}:{line}  {w}{de}" if line else f"{file}  {w}{de}"

args = sys.argv[1:]
if not args:
    print(__doc__ or "Aufruf: tools/story.sh <von> [<bis>] | --alle [<bis>]"); sys.exit(1)
if args[0] == "--alle":
    cur = texts(args[1] if len(args) > 1 else "origin/main")
    for k, (line, _) in sorted(cur.items(), key=lambda x: (x[0][0], x[1][0])):
        print(show(k, line))
    print(f"\n{len(cur)} Texte"); sys.exit(0)

old, new = texts(args[0]), texts(args[1] if len(args) > 1 else "origin/main")
gone = {k: v for k, v in old.items() if k not in new}
came = {k: v for k, v in new.items() if k not in old}
changed, en_old = [], []
# geändert = gleiche Datei und Sprecher, Text weg und neu an fast gleicher Stelle
for k, (line, en) in list(came.items()):
    near = [g for g in gone if g[0] == k[0] and g[1] == k[1] and abs(gone[g][0] - line) <= 3]
    if near:
        g = near[0]
        changed.append((g, k, line))
        if gone[g][1] == en:
            en_old.append((k, line))
        del gone[g], came[k]
en_only = [(k, new[k][0]) for k in new if k in old and old[k][1] != new[k][1]]

for k, (line, _) in sorted(came.items(), key=lambda x: (x[0][0], x[1][0])): print("+ " + show(k, line))
for k, (line, _) in sorted(gone.items()): print("- " + show(k))
for g, k, line in changed: print(f"~ {k[0]}:{line}  {k[1] + ': ' if k[1] else ''}{g[2]}\n    → {k[2]}")
for k, line in en_only: print("  (nur Englisch geändert) " + show(k, line))
for k, line in en_old: print("! EN alt: " + show(k, line))
n = len(came) + len(gone) + len(changed)
print("Keine Textänderungen." if n == 0 and not en_only else f"\n{len(came)} neu, {len(gone)} weg, {len(changed)} geändert, {len(en_old)} mit veraltetem Englisch")
PY
