#!/usr/bin/env python3
"""1694: Kurztabelle aus Läufen von godot/tests/griff_folge_1694.gd (BILD1694=1). Je Lauf: Prüfung, tiefste Handfläche und
Kleinfinger-Grundglied im gezeigten Bild (Bildnummer, Netz zum Holz, griff.gd intern), Schritt (Tragen zwei_winkel, merk.o),
Lage nach jedem Modifikator im tiefsten Bild, Sprung der gezeichneten Hand am Schaft (Spanne, Bilder mit Sprung über 1 cm).
  python3 tools/tabelle_1694.py LOG [LOG …]"""
import re, sys

def vec(s): return [float(x) for x in s.split(",")]

def lauf(pfad):
    L = open(pfad, encoding="utf-8").read().splitlines()
    rows = {}
    for x in L:
        m = re.match(r"BILD1694 P *(\d+) fuehler\S* Waffe-RS (\S+)cm \|(.*)", x)
        if m:
            g = {k: v.split("/") for k, v in re.findall(r" (\w+) (\S+)", m.group(3))}
            rows.setdefault(int(m.group(1)), {})["g"] = g
        m = re.match(r"BILD1694 P *(\d+) Schritte (.*)", x)
        if m:
            t = m.group(2); r = rows.setdefault(int(m.group(1)), {})
            r["schritte"] = re.sub(r"\s*\| gezeichnet.*", "", t)
            zw = re.search(r"zwei_winkel ([\d.]+)", t); mo = re.search(r"merk.o \(([^)]*)\)", t)
            gz = re.search(r"gezeichnet\(RS\): h\(([^)]*)\) i\(([^)]*)\) p\(([^)]*)\)", t)
            r["zw"] = zw.group(1) if zw else "–"; r["mo"] = vec(mo.group(1)) if mo else None
            r["rs"] = [vec(gz.group(k)) for k in (1, 2, 3)] if gz else None
    kopf = next((x for x in L if x.startswith("BILD1694 Fall")), "BILD1694 Fall FEHLT")
    pr = next((x[17:] for x in L if "PRÜFUNG" in x), next((x[9:] for x in L if "FEHLT" in x and "Bewegung" in x), "FEHLT"))
    aus = ["### " + pfad.split("/")[-1], kopf[14:kopf.find(",", kopf.find("Bilder") - 6)] if "Bilder" in kopf else kopf, "Prüfung: " + pr]
    if not rows:
        return aus
    for gl, name in (("hand", "Handfläche"), ("pinky_01", "Kleinfinger-Grundglied")):
        w = [(float(r["g"][gl][0]), p) for p, r in rows.items() if "g" in r and gl in r["g"] and r["g"][gl][0] != "FEHLT"]
        if not w:
            aus.append(f"- {name}: FEHLT"); continue
        d, p = min(w)
        r = rows[p]
        aus.append(f"- {name}: Bild {p}, Netz zum Holz {d:+.2f} cm, griff.gd intern {r['g'][gl][2]}, Schritt: Tragen zwei_winkel {r.get('zw', '–')}°")
        aus.append(f"  - je Modifikator (Waffenkoordinaten cm, h hand_r, i index_01_r, p pinky_01_r): {r.get('schritte', 'FEHLT')}")
    sp = []; prev = None
    for p in sorted(rows):
        r = rows[p]
        if r.get("rs") and prev and prev.get("rs"):
            d = max(sum((a - b) ** 2 for a, b in zip(u, v)) ** .5 for u, v in zip(r["rs"], prev["rs"]))
            dm = sum((a - b) ** 2 for a, b in zip(r["mo"], prev["mo"])) ** .5 if r.get("mo") and prev.get("mo") else None
            if d > 1.0: sp.append(f"Bild {p} {d:.1f} cm" + (f" (merk.o {dm:.1f} cm, neu geschlossen)" if dm and dm > 0.2 else " (merk.o gleich)" if dm is not None else ""))
        prev = r
    rs = [r["rs"] for r in rows.values() if r.get("rs")]
    if rs:
        span = [max(max(abs(a[k][j] - b[k][j]) for j in range(3)) for a in rs for b in rs) for k in range(3)]
        aus.append("- Sprung am Schaft (größte Spanne je Achse): hand_r %.2f, index_01_r %.2f, pinky_01_r %.2f cm; Sprünge über 1 cm von Bild zu Bild: %s" % (*span, "; ".join(sp) or "keine"))
    return aus

if __name__ == "__main__":
    for f in sys.argv[1:]:
        print("\n".join(lauf(f))); print()
