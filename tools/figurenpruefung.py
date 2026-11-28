#!/usr/bin/env python3
"""Figurenprüfung (1385, 649b A Build 1): alle Stellen, an denen eine Monsterart steht, gegen die Kennungstabelle.

    python3 tools/figurenpruefung.py             # Befunde zeigen (neue und bekannte), Exit 1 bei neuen
    python3 tools/figurenpruefung.py --pruefen   # wie oben, kurz (Bau, Commit-Haken)
    python3 tools/figurenpruefung.py --stand     # heutige Befunde als bekannt ablegen (Sperrklinke neu setzen)
    python3 tools/figurenpruefung.py --namen     # nur die Namenswidersprüche (1473; alter Name --homer geht weiter, 1739)

Quelle ist werte.json „kennungen“ (Kennung -> Art, Name, Gruppe; seit 1385 dazu die Felder, die bisher nur im Code
stehen). Geprüft wird: Art in „monster“, „monsterregeln“, Klänge (kampfklang.json), Absichten, Namen im Code
(aufruf.gd), die Felder der Tabelle gegen die Listen im Code (figur.gd, kampfort.gd, streuner.gd, aufruf.gd) und jede
andere Liste im Spielcode, die Kennungen enthält, auf unbekannte Kennungen.

Sperrklinke (Einwand Spike zu 649b): was heute schon widerspricht, steht in tools/figurenpruefung_bekannt.txt und
macht nichts rot; rot wird nur ein neuer Befund. Behobenes meldet das Werkzeug, „--stand“ streicht es aus der Datei.
Build 2 stellt den Code auf die Tabelle um; dann fallen die Spiegelfelder samt ihrer Prüfung weg.
"""
import json
import re
import sys
from pathlib import Path

WURZEL = Path(__file__).resolve().parent.parent
WERTE = WURZEL / "tools/sim444/werte.json"
KLANG = WURZEL / "godot/daten/klang/kampfklang.json"
BEKANNT = WURZEL / "tools/figurenpruefung_bekannt.txt"
GODOT = WURZEL / "godot"

# Körper (Modelle), die im Code neben den Kennungen stehen; keine eigene Art (Kaufmodelle 348.12c, 494, Grimmzahn 348.7)
KOERPER = {"kaufwolf", "kauf_keiler", "kauf_hundertfuesser", "kauf_egel", "kauf_schnecke", "grimm"}

# Spiegelfelder: Feld der Kennungstabelle <- Liste im Code (Datei, Name, Art: "wert" je Kennung, "menge" = ja/nein)
SPIEGEL = [
    ("kartengruppe", "skripte/streuner.gd", "GRUPPE", "wert"),
    ("jaeger", "skripte/streuner.gd", "JAEGER", "menge"),
    ("lauerer", "skripte/streuner.gd", "LAUERER", "menge"),
    ("ruhe", "skripte/streuner.gd", "RUHE_KARTE", "wert"),
    ("sitz", "skripte/streuner.gd", "SITZ_KARTE", "wert"),
    ("vierbeiner", "kampf/figur.gd", "VIERBEINER", "menge"),
    ("felle", "kampf/figur.gd", "ERSATZ_FELLE", "wert"),
    ("kopf", "kampf/figur.gd", "ERSATZ_KOPF", "wert"),
    ("schatten", "kampf/figur.gd", "ERSATZ_SCHATTEN", "wert"),
    ("groesse_modell", "kampf/figur.gd", "ART_GROESSE", "wert"),
    ("groesse_kampfort", "kampf/kampfort.gd", "ART_SIZE", "wert"),
]


# --- GDScript lesen (nur Literale, ohne Godot) ------------------------------------------------------------------

def ohne_kommentar(text):
    """Kommentare (#) außerhalb von Zeichenketten entfernen."""
    aus, i, n, s = [], 0, len(text), None
    while i < n:
        c = text[i]
        if s:
            aus.append(c)
            if c == "\\" and i + 1 < n:
                aus.append(text[i + 1]); i += 2; continue
            if c == s:
                s = None
        elif c in "\"'":
            s = c; aus.append(c)
        elif c == "#":
            while i < n and text[i] != "\n":
                i += 1
            continue
        else:
            aus.append(c)
        i += 1
    return "".join(aus)


def konstanten():
    """Zeichenketten-Konstanten von Mars und Figur (Mars.WOLF -> "wolf")."""
    k = {}
    for name, datei in (("Mars", "regeln/mars.gd"), ("Figur", "kampf/figur.gd")):
        for m in re.finditer(r'^const (\w+) := "([^"]*)"', (GODOT / datei).read_text(encoding="utf-8"), re.M):
            k[f"{name}.{m.group(1)}"] = m.group(2)
    return k


def zahlen(text):
    """Zahlen-Konstanten einer Datei (für Ausdrücke wie 1.0 / (FOE_SIZE * WOLF_SIZE))."""
    return {m.group(1): float(m.group(2)) for m in re.finditer(r"^const (\w+) := (-?[0-9.]+)\s*$", text, re.M)}


def klammer(text, i):
    """Text der Klammer ab text[i] ({ oder [) bis zur passenden schließenden."""
    auf = text[i]; zu = "}" if auf == "{" else "]"
    tiefe, s, j = 0, None, i
    while j < len(text):
        c = text[j]
        if s:
            if c == "\\":
                j += 2; continue
            if c == s:
                s = None
        elif c in "\"'":
            s = c
        elif c in "{[(":
            tiefe += 1
        elif c in "}])":
            tiefe -= 1
            if tiefe == 0:
                return text[i:j + 1]
        j += 1
    return text[i:]


def teile(inhalt):
    """Elemente einer Klammer auf oberster Ebene, durch Komma getrennt."""
    aus, tiefe, s, cur = [], 0, None, []
    for j, c in enumerate(inhalt):
        if s:
            cur.append(c)
            if c == s and inhalt[j - 1] != "\\":
                s = None
            continue
        if c in "\"'":
            s = c
        elif c in "{[(":
            tiefe += 1
        elif c in "}])":
            tiefe -= 1
        if c == "," and tiefe == 0:
            aus.append("".join(cur).strip()); cur = []
        else:
            cur.append(c)
    if "".join(cur).strip():
        aus.append("".join(cur).strip())
    return aus


def wert(ausdruck, konst, num):
    """GDScript-Literal als Python-Wert: Zeichenkette, Zahl (auch einfache Rechnung), Liste, Wörterbuch."""
    a = ausdruck.strip()
    if a.startswith("["):
        return [wert(x, konst, num) for x in teile(a[1:-1])]
    if a.startswith("{"):
        return dict(paar(x, konst, num) for x in teile(a[1:-1]))
    m = re.fullmatch(r'"((?:[^"\\]|\\.)*)"', a)
    if m:
        return m.group(1)
    if a in konst:
        return konst[a]
    if a in ("true", "false"):
        return a == "true"
    r = re.sub(r"[A-Z_][A-Z0-9_]*", lambda m: repr(num[m.group(0)]) if m.group(0) in num else m.group(0), a)
    if re.fullmatch(r"[0-9.+\-*/() eE]+", r):
        v = eval(r, {"__builtins__": {}})  # nur Ziffern und Rechenzeichen (geprüft)
        return round(float(v), 6)
    return a


def paar(x, konst, num):
    k, _, v = x.partition(":")
    return wert(k, konst, num), wert(v, konst, num)


def listen(datei, konst):
    """Alle Konstanten und Variablen mit {…} oder […] einer Datei: Name -> (Python-Wert, Rohtext)."""
    text = ohne_kommentar((GODOT / datei).read_text(encoding="utf-8"))
    num = zahlen(text)
    aus = {}
    for m in re.finditer(r"^\s*(?:static var|const|var) (\w+)(?:\s*:\s*\w+)?\s*:?=\s*([\[{])", text, re.M):
        roh = klammer(text, m.end(2) - 1)
        try:
            aus[m.group(1)] = (wert(roh, konst, num), roh)
        except Exception:
            aus[m.group(1)] = (None, roh)
    return aus


# --- Prüfung -------------------------------------------------------------------------------------------------------

def befunde():
    W = json.loads(WERTE.read_text(encoding="utf-8"))
    ken = {k: v for k, v in W["kennungen"].items() if not k.startswith("_")}
    K = set(ken)
    arten = {k for k in W["monster"] if not k.startswith("_")}
    b = []

    # Kennung <-> Monsterwerte (unter dem Namen der Art)
    for k, v in ken.items():
        if v.get("art") not in arten:
            b.append(f"werte: Kennung {k}: Art „{v.get('art')}“ fehlt in „monster“")
    for a in sorted(arten - {v.get("art") for v in ken.values()}):
        b.append(f"werte: Art „{a}“ in „monster“ ohne Kennung")
    regeln = {k for k in W["monsterregeln"] if not k.startswith("_")}
    for k in sorted(K - regeln):
        b.append(f"werte: Kennung {k} fehlt in „monsterregeln“")
    for k in sorted(regeln - K):
        b.append(f"werte: „monsterregeln“ {k} ohne Kennung")
    absicht = {k for k in W["absichten"]["je_art"] if not k.startswith("_")}
    for k in sorted(K - absicht):
        b.append(f"absichten: {k} ohne eigene Absichten (nimmt „_sonst“)")
    for k in sorted(absicht - K):
        b.append(f"absichten: {k} ohne Kennung")

    # Klänge
    kl = json.loads(KLANG.read_text(encoding="utf-8"))
    for teil in ("monster_fx", "stimme"):
        da = {k for k in kl.get(teil, {}) if not k.startswith("_")}
        for k in sorted(K - da):
            b.append(f"kampfklang.json: {k} fehlt in „{teil}“")
        for k in sorted(da - K):
            b.append(f"kampfklang.json: „{teil}“ {k} ohne Kennung")

    # Namen: Tabelle in sich und im Code
    for k, v in ken.items():
        if v.get("art") and v.get("de") and v["art"] not in v["de"]:
            b.append(f"name: {k}: Art „{v['art']}“, Anzeigename „{v['de']}“")
    konst = konstanten()
    auf = listen("kampf/aufruf.gd", konst)
    gruppe = (listen("skripte/streuner.gd", konst).get("GRUPPE") or ({}, ""))[0]
    gruppe_zu = {}
    for k, g in gruppe.items():
        gruppe_zu.setdefault(g, []).append(k)
    for g, (de, en) in (auf.get("NAMEN_494", ({}, ""))[0] or {}).items():
        lineup = re.search(r'"%s":\s*\[\[\s*"[^"]*",\s*(\w+\.\w+|"[^"]*")' % re.escape(g), auf_roh())
        k = None
        if lineup:
            k = wert(lineup.group(1), konst, {})
        for kk in ([k] if k else gruppe_zu.get(g, [])):
            v = ken.get(kk, {})
            if v and (v.get("de"), v.get("en")) != (de, en):
                b.append(f"name: {kk}: Code aufruf.gd NAMEN_494 {g} „{de}“/„{en}“, Tabelle „{v.get('de')}“/„{v.get('en')}“")
    t = auf_roh()
    m_de = re.search(r'm\.de = "([^"]*)"', t); m_en = re.search(r'm\.en = "([^"]*)"', t)
    if m_de and m_en:
        v = ken.get("dire_wolf", {})
        if (v.get("de"), v.get("en")) != (m_de.group(1), m_en.group(1)):
            b.append(f"name: dire_wolf: Code aufruf.gd „{m_de.group(1)}“/„{m_en.group(1)}“, Tabelle „{v.get('de')}“/„{v.get('en')}“")
        b.append("name: dire_wolf: Name fest im Code (aufruf.gd gegner), nicht aus der Tabelle")

    # Spiegelfelder: Tabelle gegen Code
    for feld, datei, name, art in SPIEGEL:
        code = (listen(datei, konst).get(name) or (None, ""))[0]
        if code is None:
            b.append(f"spiegel: {datei} {name} nicht gefunden (Feld „{feld}“)")
            continue
        for k in sorted(K):
            soll = (k in code) if art == "menge" else code.get(k)
            ist = ken[k].get(feld, False if art == "menge" else None)
            if soll != ist:
                b.append(f"spiegel: {k}.{feld}: Tabelle {json.dumps(ist, ensure_ascii=False)}, Code {datei} {name} {json.dumps(soll, ensure_ascii=False)}")
        fremd = [x for x in (code if isinstance(code, (list, dict)) else []) if x not in K and x not in KOERPER]
        for x in fremd:
            b.append(f"spiegel: {datei} {name}: „{x}“ ist keine Kennung")

    # alle übrigen Listen im Spielcode, die Kennungen enthalten: unbekannte Kennungen
    bekannte_listen = {(d, n) for _, d, n, _ in SPIEGEL}
    for p in sorted(GODOT.rglob("*.gd")):
        rel = str(p.relative_to(GODOT))
        if rel.startswith("tests/") or "/addons/" in rel:
            continue
        for name, (v, roh) in listen(rel, konst).items():
            if (rel, name) in bekannte_listen or v is None:
                continue
            schluessel = list(v.keys()) if isinstance(v, dict) else [x for x in v if isinstance(x, str)] if isinstance(v, list) else []
            schluessel = [x for x in schluessel if isinstance(x, str)]
            if not any(x in K for x in schluessel):
                continue
            for x in schluessel:
                if x not in K and x not in KOERPER and re.fullmatch(r"[a-z][a-z_]+", x):
                    b.append(f"liste: {rel} {name}: „{x}“ ist keine Kennung")
    return sorted(set(b))


_AUF = None


def auf_roh():
    global _AUF
    if _AUF is None:
        _AUF = ohne_kommentar((GODOT / "kampf/aufruf.gd").read_text(encoding="utf-8"))
    return _AUF


def lies_bekannt():
    if not BEKANNT.exists():
        return set()
    return {z for z in BEKANNT.read_text(encoding="utf-8").splitlines() if z and not z.startswith("#")}


def main():
    alle = befunde()
    if "--namen" in sys.argv or "--homer" in sys.argv:  # 1739: Option nach Inhalt, --homer als Rückweg
        for z in alle:
            if z.startswith("name: "):
                print(z)
        return 0
    if "--stand" in sys.argv:
        kopf = ("# Figurenprüfung (1385): heute bekannte Befunde, machen den Bau nicht rot (Sperrklinke, 649b A).\n"
                "# Nie von Hand ergänzen; behoben -> python3 tools/figurenpruefung.py --stand\n")
        BEKANNT.write_text(kopf + "\n".join(alle) + "\n", encoding="utf-8")
        print(f"figurenpruefung: {len(alle)} Befunde als bekannt abgelegt")
        return 0
    bek = lies_bekannt()
    neu = [z for z in alle if z not in bek]
    weg = sorted(bek - set(alle))
    kurz = "--pruefen" in sys.argv
    if not kurz:
        for z in alle:
            print(("NEU  " if z in neu else "     ") + z)
    for z in weg:
        print(f"behoben (bitte --stand): {z}")
    for z in neu if kurz else []:
        print(f"NEU: {z}")
    print(f"figurenpruefung: {len(alle)} Befunde, davon {len(neu)} neu, {len(weg)} behoben")
    return 1 if neu else 0


if __name__ == "__main__":
    sys.exit(main())
