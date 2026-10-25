#!/usr/bin/env python3
"""348.7: zieht die Kampfzeilen von MARS (Msg72, Msg130, Msg301, Msg279 in core/.../Skirmish.kt) nach godot/regeln/mars_texte.gd.
Aufruf im Hauptordner: python3 tools/godot/mars_texte.py. Die Texte bleiben wortgetreu (Homer); nichts von Hand ändern."""
import re, json, pathlib

root = pathlib.Path(__file__).resolve().parents[2]
src = (root / "core/src/main/kotlin/de/bornim/core/Skirmish.kt").read_text()
src = src[src.index("private object Msg72"):]
T = re.compile(r'T\("((?:[^"\\]|\\.)*)",\s*"((?:[^"\\]|\\.)*)"\)')
blocks = re.split(r'\n(?=(?:private )?object |/\*\*[^\n]*\n(?:private )?object |class Lines)', src)

def q(s):
    return json.dumps(s, ensure_ascii=False)

out = ["# 348.7: erzeugt von tools/godot/mars_texte.py aus Skirmish.kt (Msg72, Msg130, Msg301, Msg279); nicht von Hand ändern.",
       "# Ein Text ist [de, en]; eine Zeile in mehreren Fassungen ist eine Liste davon (279).", ""]
for obj in ("Msg72", "Msg130", "Msg301", "Msg279"):
    body = src[src.index("object " + obj):]
    body = body[:body.index("\n}\n")]
    names = [(m.start(), m.group(1)) for m in re.finditer(r'\bval (\w+) =', body)]
    keys = [(m.start(), m.group(1)) for m in re.finditer(r'"(\w+)" to Lines\(', body)]
    entries = {}
    order = []
    for m in T.finditer(body):
        pos = m.start()
        name = max((n for n in names if n[0] < pos), default=None)
        key = max((k for k in keys if k[0] < pos), default=None)
        if obj == "Msg130" and name and name[1] == "signs" and key:
            ident = "sign_" + key[1]
            lines = True
        else:
            ident = name[1]
            decl = body[name[0]:body.index("=", name[0]) + 40]
            lines = "Lines(" in decl
        if ident not in entries:
            entries[ident] = (lines, [])
            order.append(ident)
        entries[ident][1].append([m.group(1), m.group(2)])
    out.append(f"# {obj}")
    for ident in order:
        lines, ts = entries[ident]
        if lines:
            out.append(f"const {obj.upper()}_{ident.upper()} = [" + ", ".join(f"[{q(a)}, {q(b)}]" for a, b in ts) + "]")
        else:
            assert len(ts) == 1, ident
            out.append(f"const {obj.upper()}_{ident.upper()} = [{q(ts[0][0])}, {q(ts[0][1])}]")
    out.append("")
(root / "godot/regeln").mkdir(parents=True, exist_ok=True)
(root / "godot/regeln/mars_texte.gd").write_text("\n".join(out))
print(len(out), "Zeilen")
