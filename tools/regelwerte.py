#!/usr/bin/env python3
"""Regelwerte zum Nachschlagen (969): erzeugt docs/LISTE-REGELWERTE.md aus tools/sim444/werte.json.

    python3 tools/regelwerte.py            # Seite neu schreiben
    python3 tools/regelwerte.py --pruefen  # nur pruefen (Exit 1, wenn die Seite nicht zur Datendatei passt)

werte.json ist die einzige Quelle der Zahlen (870.3): das Spiel (godot/regeln/brs*.gd) und die Simulation 444
lesen sie. Die Seite wird nie von Hand geschrieben. Je Block: die Regel als Satz aus DESIGN-BRS.md (ueber die
Verweise „N <Abschnitt>“ in „_quelle“), die Erlaeuterungen und Formeln (Schluessel mit „_“), die heutige Zahl und
wo sie im Spiel gelesen wird (Suche im Spielcode ohne Tests, dazu die Simulation).
"""
import json
import re
import subprocess
import sys
from pathlib import Path

WURZEL = Path(__file__).resolve().parent.parent
DATEI = WURZEL / "tools/sim444/werte.json"
REGELN = WURZEL / "docs/DESIGN-BRS.md"
LISTE = WURZEL / "docs/LISTE-REGELWERTE.md"
CODE = [p for p in sorted((WURZEL / "godot").rglob("*.gd")) if "/tests/" not in str(p)]
SIM = [WURZEL / "tools/sim444/sim.py", WURZEL / "tools/sim444/handlungen.py"]


def zahl(w):
    if isinstance(w, bool):
        return "ja" if w else "nein"
    if isinstance(w, float):
        t = f"{w:.4f}".rstrip("0").rstrip(".")
        return t.replace(".", ",")
    if isinstance(w, list):
        return ", ".join(zahl(x) if not isinstance(x, list) else "(" + ", ".join(zahl(y) for y in x) + ")" for x in w) or "–"
    if isinstance(w, dict):
        return "; ".join(f"{k} {zahl(v)}" for k, v in w.items() if not k.startswith("_")) or "–"
    if w is None:
        return "–"
    return str(w)


def zelle(t):
    return str(t).replace("|", "\\|").replace("\n", " ")


# --- Regel als Satz aus DESIGN-BRS.md -------------------------------------------------------------------------

def abschnitte():
    """Ueberschrift -> Text bis zur naechsten Ueberschrift gleicher oder hoeherer Ebene."""
    zeilen = REGELN.read_text(encoding="utf-8").splitlines()
    kopf = [(i, len(m.group(1)), m.group(2).strip()) for i, z in enumerate(zeilen) if (m := re.match(r"^(#{2,3}) (.+)$", z))]
    aus = {}
    for n, (i, ebene, titel) in enumerate(kopf):
        ende = next((j for j, e, _ in kopf[n + 1:] if e <= ebene), len(zeilen))
        aus[titel] = zeilen[i + 1:ende]
    return aus


def erster_satz(zeilen):
    for z in zeilen:
        z = z.strip()
        if not z or z.startswith(("#", "|", "<", ">")):
            continue
        z = re.sub(r"^[-*] ", "", z)
        z = re.sub(r"\*\*|`", "", z)
        m = re.search(r"^(.{40,}?[.!?])(\s|$)", z)
        satz = m.group(1) if m else z
        return satz if len(satz) <= 320 else satz[:317].rsplit(" ", 1)[0] + " …"
    return ""


def norm(s):
    s = s.lower()
    for x, y in (("ä", "ae"), ("ö", "oe"), ("ü", "ue"), ("ß", "ss")):
        s = s.replace(x, y)
    return s


def stamm(woerter):
    return {norm(w)[:5] for w in woerter if len(w) >= 5}


def saetze(z):
    """Saetze und Teilsaetze (nach „; “ und vor „(1) “), nie innerhalb einer Klammer getrennt."""
    z = re.sub(r" \((\d+)\) ", "\x00\\1) ", z)
    aus, tiefe, anf = [], 0, 0
    for i, c in enumerate(z):
        tiefe += (c == "(") - (c == ")")
        tiefe = max(tiefe, 0)
        ende = c == "\x00" or (tiefe == 0 and (
            (c in ".!?" and z[i + 1:i + 2] == " " and re.match(r"[A-ZÄÖÜ„]", z[i + 2:i + 3] or "")) or (c == ";" and z[i + 1:i + 2] == " ")))
        if ende:
            aus.append(z[anf:i + (c != "\x00" and c != ";")].strip())
            anf = i + 1
    aus.append(z[anf:].strip())
    return [re.sub(r"^(\d+)\) ", r"(\1) ", s) for s in aus if s]


def bester_satz(zeilen, thema, stich):
    """Satz des Abschnitts, der die Stichworte (Thema dreifach) am meisten trifft; sonst der erste Satz."""
    best, punkte = "", 0
    for z in zeilen:
        z = z.strip()
        if not z or z.startswith(("#", "<", ">")) or re.match(r"^\|[-| :]+\|$", z):
            continue
        if z.startswith("|"):
            z = " – ".join(c.strip() for c in z.strip("|").split("|") if c.strip())
        z = re.sub(r"\*\*|`", "", re.sub(r"^[-*] ", "", z))
        for satz in saetze(z):
            if len(satz) < 30:
                continue
            w = {norm(x)[:5] for x in re.findall(r"[\wäöüßÄÖÜ]{5,}", satz)}
            p = 3 * len(w & thema) + len(w & stich)
            if p > punkte:
                best, punkte = satz, p
    if not best:
        return erster_satz(zeilen)
    return best if len(best) <= 320 else best[:317].rsplit(" ", 1)[0] + " …"


def verweise(quelle, abschn, stich):
    """„N 3 'Wie Fertigkeiten wachsen'“, „N 2 und 4“, „N 8 Tiere beruhigen“, „DESIGN-BRS.md 7“, „N Entwurf A“ -> [(Titel, Satz)]."""
    nummern = {re.match(r"(\d+)\.", t).group(1): t for t in abschn if re.match(r"\d+\. ", t)}
    gefunden = []
    for m in re.finditer(r"\bN (\d+)(?: und (\d+))?(?: '([^']+)')?|DESIGN-BRS\.md (\d+)\b|\bN Entwurf ([A-Z])\b", quelle):
        thema = stamm(re.findall(r"[\wäöüßÄÖÜ]+", re.split(r"[;,(]", quelle[m.end():] + ";")[0]))
        if m.group(3) and m.group(3) in abschn:
            gefunden.append((m.group(3), thema))
            continue
        for nr in (m.group(1), m.group(2), m.group(4)):
            if nr and nr in nummern:
                gefunden.append((nummern[nr], thema))
        if m.group(5):
            gefunden += [(t, thema) for t in abschn if t.startswith(f"Entwurf {m.group(5)} ")]
    aus = {}
    for t, thema in gefunden:
        satz = bester_satz(abschn[t], thema, stich)
        if satz and satz not in aus.values():
            aus.setdefault(t, satz)
    return list(aus.items())


# --- Wo die Zahl wirkt ----------------------------------------------------------------------------------------

ZUGRIFF = re.compile(r'(?:\blade\(\)|\bw\(\)|\bW_?|self\.W)\s*(?:\[|\.get\()\s*"([a-z_]+)"')     # nur Zugriffe auf werte.json
WORT = re.compile(r'(?<=["\'])([^"\'\n]{1,60})(?=["\'])')     # jedes Stueck zwischen zwei Anfuehrungszeichen, auch ueberlappend


def lade_code():
    """Einmal lesen: je Block die Dateien, die ihn lesen; je Wort in Anfuehrungszeichen seine Stellen."""
    bloecke, woerter, dateien = {}, {}, []
    for p in CODE + SIM:
        if not p.exists():
            continue
        d = p.relative_to(WURZEL).as_posix()
        dateien.append(d)
        for i, z in enumerate(p.read_text(encoding="utf-8", errors="replace").splitlines()):
            for m in ZUGRIFF.finditer(z):
                bloecke.setdefault(m.group(1), []).append(d)
            for w in set(WORT.findall(z)):
                woerter.setdefault(w, []).append((d, i + 1))
    return {"bloecke": {k: list(dict.fromkeys(v)) for k, v in bloecke.items()}, "woerter": woerter, "dateien": dateien}


def orte(code, block, schluessel=None, breit=False):
    """Dateien, die den Block lesen; mit Schluessel: Zeilen darin, die ihn nennen."""
    dateien = code["bloecke"].get(block, [])
    if schluessel is None:
        return dateien
    if breit and "_" in schluessel and len(schluessel) >= 8:     # oberste Ebene und eindeutig genug: auch Dateien, die den Block ueber eine Hilfsfunktion lesen
        dateien = code["dateien"]
    erlaubt = set(dateien)
    stellen = [s for s in code["woerter"].get(schluessel, []) if s[0] in erlaubt]
    stellen.sort(key=lambda s: (code["dateien"].index(s[0]), s[1]))
    return [f"{d}:{n}" for d, n in stellen]


def ortstext(liste):
    """Spielcode: hoechstens zwei Stellen (ohne „godot/“), dazu „+n“; liest die Simulation mit, steht „Sim.“ dahinter."""
    spiel = [o.removeprefix("godot/") for o in liste if not o.startswith("tools/")]
    sim = any(o.startswith("tools/") for o in liste)
    teile = [f"`{o}`" for o in spiel[:2]] + ([f"+{len(spiel) - 2}"] if len(spiel) > 2 else [])
    if sim:
        teile.append("Sim.")
    return ", ".join(teile) or "–"


# --- Seite ----------------------------------------------------------------------------------------------------

def ist_skalar(w):
    return not isinstance(w, dict) and not (isinstance(w, list) and any(isinstance(x, dict) for x in w))


def ist_satz(w):
    """Eintrag einer Tabelle (Monster, Waffe …): nur Zahlen, Listen und kleine Woerterbuecher, keine Erlaeuterungen."""
    return isinstance(w, dict) and not any(k.startswith("_") for k in w) and all(
        ist_skalar(v) or (isinstance(v, dict) and all(ist_skalar(x) for x in v.values())) for v in w.values())


def erlaeuterungen(obj):
    """'_bedarf' -> zum Schluessel 'bedarf_basis' usw.; was keinem Schluessel zuzuordnen ist, steht frei."""
    werte = [k for k in obj if not k.startswith("_")]
    zu, frei = {}, []
    for k, v in obj.items():
        if not k.startswith("_") or k == "_quelle" or not isinstance(v, str):
            continue
        name = k[1:]
        ziel = next((w for w in werte if w == name), None) or next((w for w in werte if w.startswith(name)), None) \
            or next((w for w in werte if name in w), None)
        if ziel:
            zu.setdefault(ziel, []).append(v)
        else:
            frei.append((name, v))
    return zu, frei


def schreibe_obj(aus, code, block, obj, pfad, ebene):
    zu, frei = erlaeuterungen(obj)
    skalare = [(k, v) for k, v in obj.items() if not k.startswith("_") and ist_skalar(v)]
    saetze = [(k, v) for k, v in obj.items() if not k.startswith("_") and ist_satz(v)]
    rest = [(k, v) for k, v in obj.items() if not k.startswith("_") and isinstance(v, dict) and not ist_satz(v)]
    if saetze and len({s for _, v in saetze for s in v}) > 1.5 * max(len(v) for _, v in saetze):
        rest = saetze + rest     # verschiedenartige Eintraege: je einer mit eigener Tabelle statt einer breiten
        saetze = []
    if skalare:
        aus += ["| Wert | heute | Formel, Erläuterung | wirkt in |", "|---|---|---|---|"]
        for k, v in skalare:
            aus.append(f"| `{k}` | {zelle(zahl(v))} | {zelle(' '.join(zu.get(k, [])) or '–')} | {ortstext(orte(code, block, k, breit=pfad == block))} |")
        aus.append("")
    for name, v in frei:
        aus.append(f"- **{name}:** {v}")
    if frei:
        aus.append("")
    if saetze:
        spalten = list(dict.fromkeys(s for _, v in saetze for s in v))
        aus += ["| " + " | ".join(["Eintrag"] + spalten) + " |", "|" + "---|" * (len(spalten) + 1)]
        for k, v in saetze:
            aus.append("| " + " | ".join([zelle(k)] + [zelle(zahl(v[s])) if s in v else "" for s in spalten]) + " |")
        aus.append("")
    for k, v in rest:
        aus.append(f"{'#' * min(ebene, 4)} {pfad}.{k}")
        aus.append("")
        if isinstance(v.get("_quelle"), str):
            aus += [f"Herkunft: {v['_quelle']}", ""]
        gelesen = orte(code, block, k)
        if gelesen:
            aus += [f"Gelesen in: {ortstext(gelesen)}", ""]
        schreibe_obj(aus, code, block, v, f"{pfad}.{k}", ebene + 1)


def stand():
    r = subprocess.run(["git", "log", "-1", "--format=%h", "--", "tools/sim444/werte.json"], cwd=WURZEL, capture_output=True, text=True)
    return r.stdout.strip() or "?"


def seite():
    werte = json.loads(DATEI.read_text(encoding="utf-8"))
    abschn = abschnitte()
    regelzeilen = [z for z in REGELN.read_text(encoding="utf-8").splitlines() if z.startswith("|")]
    code = lade_code()
    bloecke = [(k, v) for k, v in werte.items() if isinstance(v, dict)]
    aus = [
        "# Regelwerte (erzeugt, nicht von Hand ändern)",
        "",
        "Nachschlagen (969, Chef 11.11., 15:49): jede Zahl des Bornimer Rollenspielsystems, mit der das Spiel heute rechnet, "
        "je Block die Regel als Satz (`DESIGN-BRS.md`), Formel und Erläuterung, die heutige Zahl und wo sie im Spiel gelesen wird. "
        "Aus `tools/sim444/werte.json` mit `python3 tools/regelwerte.py`.",
        "",
        f"**Stand:** `werte.json` aus Commit `{stand()}` auf `main`; {len(bloecke)} Blöcke.",
        "",
        "- **Ändern:** nur in `werte.json` auf einem Arbeitszweig (das Spiel liest die Datei, also testet der Chef); "
        "nach dem Mischen auf `main` das Werkzeug laufen lassen und die Seite committen. Wer Einfluss nehmen will, nennt Block und Wert (z. B. `ueben.bedarf_teiler`).",
        "- **Herkunft** je Block: " + str(werte.get("_info", "")).split("Quelle je Block in '_quelle': ")[-1],
        "- **wirkt in:** Fundstellen des Schlüssels in Dateien, die den Block lesen (Spielcode ohne Tests, dazu die Simulation `tools/sim444`); "
        "Pfade unter `godot/`, „Sim.“ = die Simulation `tools/sim444` liest den Wert auch; „–“ heißt: im Code nicht unter diesem Namen gefunden (oft nur Simulation, über eine Hilfsfunktion gelesen oder noch nicht gebaut).",
        "",
        "**Blöcke:** " + ", ".join(f"[{k}](#{k})" for k, _ in bloecke),
        "",
    ]
    for block, obj in bloecke:
        aus += [f"## {block}", ""]
        stich = stamm([block] + [w for k in obj if not k.startswith("_") for w in re.split(r"[_ ]", k)])
        for titel, satz in verweise(str(obj.get("_quelle", "")), abschn, stich):
            aus.append(f"- **Regel** (`DESIGN-BRS.md` „{titel}“): {satz}")
        for z in regelzeilen:
            if f"Regelwerte `{block}`" in z:
                zellen = [re.sub(r"\*\*|`", "", c).strip() for c in z.strip().strip("|").split("|")]
                aus.append(f"- **Regel** (`DESIGN-BRS.md`, Tabelle): {' – '.join(c for c in zellen[:-1] if c)}")
        if isinstance(obj.get("_quelle"), str):
            aus.append(f"- **Herkunft der Zahlen:** {obj['_quelle']}")
        dateien = orte(code, block)
        aus.append("- **Gelesen von:** " + (", ".join(f"`{d.removeprefix('godot/')}`" for d in dateien) if dateien else "– (im Code nicht unter dem Blocknamen gefunden)"))
        aus.append("")
        schreibe_obj(aus, code, block, obj, block, 3)
    return "\n".join(aus).rstrip() + "\n"


def main():
    neu = seite()
    if "--pruefen" in sys.argv:
        alt = LISTE.read_text(encoding="utf-8") if LISTE.exists() else ""
        if alt != neu:
            print("regelwerte.py: docs/LISTE-REGELWERTE.md passt nicht zu werte.json oder zum Code; python3 tools/regelwerte.py laufen lassen")
            sys.exit(1)
        print("regelwerte.py: Seite aktuell")
        return
    LISTE.write_text(neu, encoding="utf-8")
    print(f"regelwerte.py: {LISTE.relative_to(WURZEL)} geschrieben ({len(neu.encode())} Byte)")


if __name__ == "__main__":
    main()
