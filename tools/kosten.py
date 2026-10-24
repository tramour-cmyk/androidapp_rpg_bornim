#!/usr/bin/env python3
"""Kosten je Rolle und Tag aus gespeicherten list_sessions-Ausgaben (167.5, 167.4).

Aufruf: python3 tools/kosten.py [--tag TT.MM.] [--ab TT.MM.] DATEI [DATEI …]
DATEI = Ausgabe von list_sessions (oder Kurzform, eine Zeile je Sitzung, siehe `kurzzeilen`) (die Datei, in der das Werkzeug sie ablegt, oder von Hand gesichert); mehrere Seiten (has_more) einfach alle angeben.
Rolle = erstes Wort des Sitzungstitels (Homer, Tom, Jerry, Ford, Ford 2, Perikles, Diogenes, Sokrates), sonst „Sonstige“.
Anteil Spiel = (Tom + Jerry + Homer) / alle Kosten. Kosten = usage.cost_usd, auch bei archivierten Sitzungen (geprüft 18.10.); Niederlassung (Pro) ist nicht lesbar.
Sitzungen ohne cost_usd werden gezählt und genannt („ohne Kosten“), nie als 0 $ gerechnet.
"""
import json, sys, re, datetime
from collections import defaultdict

SPIEL = {"Tom", "Jerry", "Homer"}
ROLLEN = ["Ford 2", "Ford", "Perikles", "Diogenes", "Sokrates", "Tom", "Jerry", "Homer"]

def sitzungen(pfad, offen):
    """Sitzungen einer Seite; ist has_more wahr, kommt der Dateiname in offen (D28.3c)."""
    t = open(pfad, encoding="utf-8").read()
    i = t.find('{"ccr"')
    if i < 0:
        if not re.search(r"^#\s*has_more:\s*nein\s*$", t, re.M | re.I): offen.append(pfad)  # 261.4: Kurzform ohne Vermerk gilt als abgeschnitten
        return kurzzeilen(t)
    obj, _ = json.JSONDecoder().raw_decode(t[i:])
    c = obj.get("ccr", {})
    if c.get("has_more") or obj.get("has_more"): offen.append(pfad)
    return c.get("data", [c] if "id" in c else [])

def kurzzeilen(t):
    """Kurzform statt Seiten-JSON (Ford kann Ausgaben nicht in Dateien umleiten, 167.2): je Sitzung eine Zeile
    `Kennung | Status | updated_at | Titel | Kosten $ [| created_at [| used_tokens]]`, Status working|idle|blocked|need_input|archived,
    Kosten leer oder „-“ = unbekannt. Zeilen mit # und Leerzeilen fallen weg."""
    aus = []
    for z in t.splitlines():
        f = [x.strip() for x in z.split("|")]
        if len(f) < 4 or not f[0].startswith("session_"): continue
        st = f[1].lower()
        s = {"id": f[0], "title": f[3], "updated_at": f[2], "created_at": f[5] if len(f) > 5 and f[5] else f[2],
             "session_status": {"working": "SESSION_STATUS_RUNNING", "blocked": "SESSION_STATUS_RUNNING", "archived": "SESSION_STATUS_ARCHIVED"}.get(st, "SESSION_STATUS_IDLE"),
             "status_bucket": {"working": "WORKING", "blocked": "BLOCKED"}.get(st, "")}
        if st == "need_input": s["post_turn_summary"] = {"status_category": "need_input"}
        k = f[4].replace(",", ".").replace("$", "").strip() if len(f) > 4 else ""
        if k not in ("", "-", "–"): s["external_metadata"] = {"usage": {"cost_usd": float(k)}}
        tk = f[6].replace(".", "").strip() if len(f) > 6 else ""
        if tk.isdigit(): s["context_usage"] = {"used_tokens": int(tk)}  # 261.5: für WEITER
        aus.append(s)
    return aus

def rolle(titel):
    for r in ROLLEN:
        if titel == r or titel.startswith((r + " ", r + ",", r + ":")): return r  # 360: „Homer, 279 …“ blieb als Klon stehen
    return "Sonstige"

def tag(s):
    z = datetime.datetime.fromisoformat(s["created_at"].replace("Z", "+00:00"))
    return (z + datetime.timedelta(hours=2)).strftime("%d.%m.")  # MESZ; ab 25.10. MEZ (1 h Abweichung, nur Tagesgrenze)

def main():
    a = sys.argv[1:]; nur = ab = None; dateien = []
    while a:
        x = a.pop(0)
        if x == "--tag": nur = a.pop(0)
        elif x == "--ab": ab = a.pop(0)
        else: dateien.append(x)
    if not dateien: sys.exit(__doc__)
    alle = {}; offen = []
    for d in dateien:
        for s in sitzungen(d, offen): alle[s["id"]] = s
    je_rolle = defaultdict(lambda: [0, 0.0]); je_tag = defaultdict(lambda: [0.0, 0.0]); ohne = []
    for s in alle.values():
        tg = tag(s)
        if nur and tg != nur: continue
        if ab and (tg[3:5], tg[:2]) < (ab[3:5], ab[:2]): continue
        k = s.get("external_metadata", {}).get("usage", {}).get("cost_usd")
        if k is None: ohne.append(s.get("title", s["id"])); continue
        r = rolle(s.get("title", ""))
        je_rolle[r][0] += 1; je_rolle[r][1] += k
        je_tag[tg][0] += k
        if r in SPIEL: je_tag[tg][1] += k
    ges = sum(v[1] for v in je_rolle.values())
    print("Kosten aus %d Sitzungen (%s):" % (len(alle), ", ".join(dateien) if len(dateien) < 3 else "%d Dateien" % len(dateien)))
    for r, (n, k) in sorted(je_rolle.items(), key=lambda x: -x[1][1]):
        print("  %-9s %2d Sitzungen  %7.2f $  %3.0f %%" % (r, n, k, 100 * k / ges if ges else 0))
    sp = sum(v[1] for r, v in je_rolle.items() if r in SPIEL)
    print("  gesamt %.2f $, Anteil Spiel (Tom, Jerry, Homer) %.0f %%" % (ges, 100 * sp / ges if ges else 0))
    for tg, (k, s) in sorted(je_tag.items(), key=lambda x: (x[0][3:5], x[0][:2])):
        print("  %s  %7.2f $  Spiel %3.0f %%" % (tg, k, 100 * s / k if k else 0))
    if ohne: print("  ohne Kosten: %d (%s)" % (len(ohne), "; ".join(ohne[:5])))
    if offen: print("ACHTUNG: Seite abgeschnitten (has_more) in %s – Summen unvollständig, weitere Seite mit after_id holen." % ", ".join(offen))
    print("Hinweis: nur gelistete Sitzungen.")

if __name__ == "__main__":
    main()
