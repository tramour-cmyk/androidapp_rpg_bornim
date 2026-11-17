#!/usr/bin/env python3
"""1268.5 (1268 A, Chef 15.11., 10:51: „Bildrate und Ladezeit je Ort in jedem Lauf melden, Warnung beim Abfall“).

Liest die Messung von `spiel.gd --bildrate=<datei>` (Dorf, Wald, Höhle, Kampf im Renderer mobile unter Lavapipe) und vergleicht sie
mit dem Grundwert `godot/tests/bildrate_grundwert.json`. Schreibt eine Tabelle (Ausgabe und `$GITHUB_STEP_SUMMARY`) und je Abfall eine
Warnung `::warning::` im Lauf; der Lauf bleibt grün (Meldung, kein Halt).

Abfall: Bilder/s unter 80 % des Grundwerts, langsamstes 1 % über 150 % und 30 ms mehr (am Rechner schwankt es um 50 %: wenige Bilder), Ladezeit über 150 % und 300 ms mehr,
Zeichenaufrufe oder Dreiecke über 120 %. Zeiten vergleicht es nur auf demselben Prozessor wie der Grundwert (Lavapipe rechnet auf
dem Prozessor, ein anderer Bauserver ist kein Abfall); Zeichenaufrufe und Dreiecke hängen nicht am Prozessor und zählen immer.
Die Zahlen sind Bauserver-Zahlen (Software-Grafik), nicht die des Handys; sie zeigen, ob ein Stand langsamer ist als der vorige.

Aufruf:  tools/bildrate.py <messung.json> [--grundwert <datei>] [--neu]   (--neu: Messung als neuen Grundwert ablegen)
         tools/bildrate.py --selbsttest
"""
import json
import os
import sys

GRUNDWERT = os.path.join(os.path.dirname(__file__), "..", "godot", "tests", "bildrate_grundwert.json")
ORTE = [("dorf", "Dorf"), ("wald", "Wald"), ("hoehle", "Höhle"), ("kampf", "Wolfskampf")]
# Schlüssel, Name, Richtung (+1 höher ist schlechter, -1 niedriger ist schlechter), Faktor, Mindestabstand, hängt am Prozessor
GRENZEN = [
    ("fps", "Bilder/s", -1, 0.80, 0.0, True),
    ("eins_ms", "langsamstes 1 %", +1, 1.50, 30.0, True),
    ("laden_ms", "Ladezeit", +1, 1.50, 300.0, True),
    ("zeichen", "Zeichenaufrufe", +1, 1.20, 0.0, False),
    ("dreiecke", "Dreiecke", +1, 1.20, 0.0, False),
]


def abfall(jetzt, vorher, richtung, faktor, abstand):
    if jetzt is None or vorher is None or vorher <= 0:
        return False
    if richtung < 0:
        return jetzt < vorher * faktor
    return jetzt > vorher * faktor and jetzt - vorher >= abstand


def vergleiche(m, g):
    """Gibt (Zeilen der Tabelle, Warnungen) zurück."""
    gleich = bool(g) and g.get("cpu") == m.get("cpu") and g.get("kerne") == m.get("kerne")
    zeilen, warn = [], []
    for k, name in ORTE:
        w = m.get("orte", {}).get(k)
        if w is None:
            warn.append(f"{name}: keine Messung")
            continue
        v = (g or {}).get("orte", {}).get(k, {})
        teile = []
        for sch, sname, r, f, a, cpu in GRENZEN:
            x = w.get(sch)
            y = v.get(sch)
            zahl = "–" if x is None else (f"{x:.1f}" if sch == "fps" else f"{x:.0f}")
            if y is not None:
                zahl += f" ({y:.1f})" if sch == "fps" else f" ({y:.0f})"
            if (gleich or not cpu) and abfall(x, y, r, f, a):
                zahl += " ⚠"
                warn.append(f"{name}: {sname} {x:g} statt {y:g}")
            teile.append(zahl)
        zeilen.append(f"| {name} | " + " | ".join(teile) + f" | {w.get('ueber50', '–')} |")
    return zeilen, warn, gleich


def bericht(m, g):
    zeilen, warn, gleich = vergleiche(m, g)
    kopf = [f"### Bildrate je Ort (1268.5), {m.get('renderer', '?')}, {m.get('grafik', '?')}, {m.get('cpu', '?')} ({m.get('kerne', '?')} Kerne)", ""]
    if not g:
        kopf.append("Kein Grundwert (godot/tests/bildrate_grundwert.json); Zahlen nur gemeldet.")
    elif not gleich:
        kopf.append(f"Grundwert von anderem Prozessor ({g.get('cpu', '?')}): Zeiten nur gemeldet, Zeichenaufrufe und Dreiecke verglichen.")
    else:
        kopf.append("In Klammern der Grundwert; ⚠ = Abfall.")
    kopf += ["", "| Ort | Bilder/s | langsamstes 1 % ms | Laden ms | Zeichenaufrufe | Dreiecke | über 50 ms |", "|---|---|---|---|---|---|---|"]
    return kopf + zeilen + [""] + ([f"Abfall: {w}" for w in warn] or ["Kein Abfall."]), warn


def selbsttest():
    g = {"cpu": "A", "kerne": 4, "orte": {k: {"fps": 20.0, "eins_ms": 60, "laden_ms": 1000, "zeichen": 100, "dreiecke": 1000} for k, _ in ORTE}}
    m = json.loads(json.dumps(g))
    fehler = 0

    def pruefe(ok, was):
        nonlocal fehler
        print(("gut " if ok else "FEHLER ") + was)
        fehler += 0 if ok else 1

    pruefe(vergleiche(m, g)[1] == [], "gleich: kein Abfall")
    m["orte"]["dorf"]["fps"] = 15.9
    m["orte"]["wald"]["eins_ms"] = 89          # 148 %, 29 ms mehr
    m["orte"]["hoehle"]["laden_ms"] = 1600     # 160 %, 600 ms mehr
    m["orte"]["kampf"]["dreiecke"] = 1300
    w = vergleiche(m, g)[1]
    pruefe(any(x.startswith("Dorf: Bilder/s") for x in w), "Dorf langsamer gemeldet")
    pruefe(not any(x.startswith("Wald") for x in w), "Wald unter Mindestabstand nicht gemeldet")
    pruefe(any(x.startswith("Höhle: Ladezeit") for x in w), "Höhle Ladezeit gemeldet")
    pruefe(any(x.startswith("Wolfskampf: Dreiecke") for x in w), "Kampf Dreiecke gemeldet")
    m["cpu"] = "B"
    w = vergleiche(m, g)[1]
    pruefe(w == ["Wolfskampf: Dreiecke 1300 statt 1000"], "anderer Prozessor: nur Dreiecke (%s)" % w)
    del m["orte"]["wald"]
    pruefe("Wald: keine Messung" in vergleiche(m, g)[1], "fehlender Ort gemeldet")
    pruefe(vergleiche(m, {})[1] == ["Wald: keine Messung"], "ohne Grundwert nur gemeldet")
    print("BILDRATE-SELBSTTEST %d Fehler" % fehler)
    return 1 if fehler else 0


def main(a):
    if "--selbsttest" in a:
        return selbsttest()
    if not a or a[0].startswith("--"):
        print(__doc__)
        return 2
    gpfad = a[a.index("--grundwert") + 1] if "--grundwert" in a else GRUNDWERT
    try:
        m = json.load(open(a[0], encoding="utf-8"))
    except (OSError, ValueError) as e:
        print(f"::warning title=Bildrate 1268.5::keine Messung ({e})")
        return 0
    g = json.load(open(gpfad, encoding="utf-8")) if os.path.exists(gpfad) else {}
    zeilen, warn = bericht(m, g)
    text = "\n".join(zeilen)
    print(text)
    for w in warn:
        print(f"::warning title=Bildrate 1268.5::{w}")
    if os.environ.get("GITHUB_STEP_SUMMARY"):
        with open(os.environ["GITHUB_STEP_SUMMARY"], "a", encoding="utf-8") as f:
            f.write(text + "\n")
    if "--neu" in a:
        with open(gpfad, "w", encoding="utf-8") as f:
            json.dump(m, f, ensure_ascii=False, indent=2)
            f.write("\n")
        print(f"Grundwert neu: {gpfad}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
