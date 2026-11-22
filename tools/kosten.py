#!/usr/bin/env python3
"""Kosten je Rolle und Tag aus gespeicherten list_sessions-Ausgaben (167.5, 167.4).

Aufruf: python3 tools/kosten.py [--tag TT.MM.] [--ab TT.MM.] DATEI [DATEI …]
DATEI = Ausgabe von list_sessions (oder Kurzform, eine Zeile je Sitzung, siehe `kurzzeilen`) (die Datei, in der das Werkzeug sie ablegt, oder von Hand gesichert); mehrere Seiten (has_more) einfach alle angeben.
Rolle = erstes Wort des Sitzungstitels (Homer, Tom, Jerry, Ford, Ford 2, Perikles, Diogenes, Sokrates; Spike und Tuffy zählen zu Tom und Jerry, 394), sonst „Sonstige“.
Anteil Spiel = (Tom + Jerry + Homer) / alle Kosten. Kosten = usage.cost_usd, auch bei archivierten Sitzungen (geprüft 18.10.); Niederlassung (Pro) ist nicht lesbar.
Sitzungen ohne cost_usd werden gezählt und genannt („ohne Kosten“), nie als 0 $ gerechnet.
"""
import json, sys, re, datetime
from collections import defaultdict

SPIEL = {"Tom", "Jerry", "Homer"}
ROLLEN = ["Ford 2", "Ford", "Perikles", "Diogenes", "Sokrates", "Tom", "Jerry", "Homer", "Spike", "Tuffy", "Rundblick", "Ideenlauf", "Tagesbericht",
          "Prüfer", "Büro", "Arbeitsplaner", "Tester"]  # 1789, 1907: Routinen Rundblick, Ideenlauf (lauf.rundblick_zeilen); 1779 d: Rollen nach der Umstellung, sonst „Sonstige“ (Höchstdauer prüft sie nie)
TEAM = {"Tuffy": "Jerry"}  # 1328: Spike eigene Rolle; 394 (Chef 28.10., 10:26): Zusatzentwickler, eigene Sitzung, Vorrat und Kosten ihres Teams

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
    aus = c.get("data", [c] if "id" in c else [])
    for s in aus:  # 1618 (D311.1): blocked und IDLE = Zug zu Ende, Rückfrage an den Chef, keine Freigabe; wie Kurzform need_input (1617)
        if "BLOCKED" in s.get("status_bucket", "") and s.get("session_status") == "SESSION_STATUS_IDLE":
            s["status_bucket"] = ""; s.setdefault("post_turn_summary", {})["status_category"] = "need_input"
    return aus

BEKANNTE_STATUS = {"working", "idle", "blocked", "need_input", "archived", "failed"}  # failed: Zug mit Fehler beendet (status_bucket, 1782)

def kurzzeilen(t):
    """Kurzform statt Seiten-JSON (Ford kann Ausgaben nicht in Dateien umleiten, 167.2): je Sitzung eine Zeile
    `Kennung | Status | updated_at | Titel | Kosten $ [| created_at [| used_tokens]]`, Status working|idle|blocked|need_input|archived|failed (status_bucket „failed“, 1782),
    Kosten leer oder „-“ = unbekannt. Zeilen mit # und Leerzeilen fallen weg."""
    aus = []
    for z in t.splitlines():
        f = [x.strip() for x in z.split("|")]
        if len(f) < 4 or not f[0].startswith("session_"): continue
        st = f[1].lower()
        if st == "running": st = "working"  # 693.1: Rohwort der Schnittstelle (SESSION_STATUS_RUNNING) heißt hier working
        if st not in BEKANNTE_STATUS:  # 693.1: unbekannt = Fehler, nie stillschweigend „ruhend“ (sonst startet lauf.py doppelt)
            raise ValueError("Kurzzeile %s: unbekannter Status „%s“ (erlaubt: %s)" % (f[0], f[1], ", ".join(sorted(BEKANNTE_STATUS))))
        s = {"id": f[0], "title": f[3], "updated_at": f[2], "created_at": f[5] if len(f) > 5 and f[5] else f[2],
             "session_status": {"working": "SESSION_STATUS_RUNNING", "blocked": "SESSION_STATUS_RUNNING", "archived": "SESSION_STATUS_ARCHIVED"}.get(st, "SESSION_STATUS_IDLE"),
             "status_bucket": {"working": "WORKING", "blocked": "BLOCKED", "failed": "FAILED"}.get(st, "")}
        if st == "need_input": s["post_turn_summary"] = {"status_category": "need_input"}
        k = f[4].replace(",", ".").replace("$", "").strip() if len(f) > 4 else ""
        if k not in ("", "-", "–"): s["external_metadata"] = {"usage": {"cost_usd": float(k)}}
        tk = f[6].replace(".", "").strip() if len(f) > 6 else ""
        if tk.isdigit(): s["context_usage"] = {"used_tokens": int(tk)}  # 261.5: für WEITER
        aus.append(s)
    return aus

_PROFILE = {}
def rolle(titel, created_at=None):
    """Rolle eines Sitzungstitels; created_at (1957) ordnet Rufnamen-Sitzungen über die Startsperre ihrer Startrolle zu."""
    for r in ROLLEN:
        if titel == r or titel.startswith((r + " ", r + ",", r + ":")): return r  # 360: „Homer, 279 …“ blieb als Klon stehen
    try:  # 1893: Titel mit Profil statt Rufname („Technik – 1893 …“, Start vor tools/1727-SCHARF an der neuen Liste)
        import os
        sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
        import startbar
        if "p" not in _PROFILE: _PROFILE["p"] = startbar.profile()
        for r in _PROFILE["p"]:
            if titel == r or titel.startswith((r + " ", r + ",", r + ":")): return r
    except Exception:
        pass
    # 1957: Rufname → Startrolle aus der Startsperre (Arbeitsplaner, Prüfer, Tester schreiben Vorgänge anderer);
    # 1739 sonst: „Anna – 1739: …“ zählt beim Besitzer des Vorgangs im Titel (Bereich), alte Titel wie bisher
    try:
        import os
        sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
        import rufname
        b = rufname.rolle(titel, created_at) if created_at else None
        b = b or rufname.bereich(titel)
        if b: return b
    except Exception:
        pass
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
        r = rolle(s.get("title", ""), s.get("created_at"))
        r = TEAM.get(r, r)
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

def selbsttest():
    """693.1: Kerntest der Kurzzeile; Exit-Code 0 = ok."""
    z = "session_x | %s | 2026-11-08T16:34:21Z | Tom – 492 | - | 2026-11-08T16:02:48Z | -"
    for roh in ("running", "working"):
        s = kurzzeilen(z % roh)[0]
        assert s["session_status"] == "SESSION_STATUS_RUNNING" and s["status_bucket"] == "WORKING", roh
    assert kurzzeilen(z % "idle")[0]["session_status"] == "SESSION_STATUS_IDLE"
    try: kurzzeilen(z % "runing")
    except ValueError: pass
    else: raise AssertionError("unbekannter Status muss abbrechen")
    print("kosten.py Selbsttest ok")

if __name__ == "__main__":
    if sys.argv[1:] == ["--selbsttest"]: selbsttest()
    else: main()
