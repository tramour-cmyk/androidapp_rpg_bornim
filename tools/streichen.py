#!/usr/bin/env python3
"""1688 (Chef 23.11., 08:38, Sokrates 08:56): befristete Anweisungen stehen nur als „Zu <Nr>, bis erledigt, streicht: <Rolle>“.
Wird NR fertig, sucht dieses Werkzeug (nicht jede Rolle selbst) alle solchen Zeilen und legt je Fund eine Übergabe an den
Disponenten an: „streichen: <Datei>, Zeile <n>: <Anfang>“. Der Disponent streicht im selben Takt, vor jedem Start; lauf.py gibt
offene Streichzeilen als erste Zeilen aus („STREICHEN <Kennung> | …“), bis sie erledigt sind.

  streichen.py funde NR      Funde zeigen, nichts schreiben
  streichen.py melden NR     je Fund eine Übergabe an den Disponenten (gepusht wie vorgang.py uebergabe); schon offene nicht doppelt
  streichen.py lauf [DOCS]   offene Streichzeilen als STREICHEN-Zeilen (lokal, ohne Netz; für lauf.py)

Gesucht wird in docs/ARBEIT-*.md (Vorräte), docs/profile/*.md (Ladetexte der Starts) und CLAUDE.md. „vorgang.py fertig NR“ ruft melden.
"""
import glob, os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import uebergabe

KOPF = "streichen: "

def dateien(wurzel=None):
    w = wurzel or uebergabe.WURZEL
    aus = sorted(glob.glob(os.path.join(w, "docs", "ARBEIT-*.md"))) + sorted(glob.glob(os.path.join(w, "docs", "profile", "*.md")))
    c = os.path.join(w, "CLAUDE.md")
    return aus + ([c] if os.path.exists(c) else [])

def funde(nr, wurzel=None):
    """[(Datei relativ, Zeilennummer, Zeile)] mit „Zu NR, bis erledigt“ (NR genau: 1589 trifft nicht 1589.2)."""
    w = wurzel or uebergabe.WURZEL
    m = re.compile(r"\bZu " + re.escape(nr) + r", bis erledigt\b")
    aus = []
    for p in dateien(w):
        try: zz = open(p, encoding="utf-8").read().splitlines()
        except OSError: continue
        aus += [(os.path.relpath(p, w), i, z.strip()) for i, z in enumerate(zz, 1) if m.search(z)]
    return aus

def was(f):
    anfang = re.sub(r"[*|]", "", f[2]).strip()
    return "%s%s, Zeile %d: %s" % (KOPF, f[0], f[1], anfang[:80])

def _schon_offen(nr):
    uebergabe._git("fetch", "-q", "origin", "main")
    rc, t, _ = uebergabe._git("show", "origin/main:" + uebergabe._pfad(nr))
    if rc: return set()
    return {z["was"].split(":", 2)[0] + ":" + z["was"].split(":", 2)[1] for z in uebergabe.zeilen(t)
            if uebergabe.ist_offen(z["z"]) and z["an"] == "Disponent" and z["was"].startswith(KOPF) and z["was"].count(":") >= 2}

def melden(nr):
    ff = funde(nr)
    if not ff:
        print("STREICHEN %s: keine Zeile „Zu %s, bis erledigt“" % (nr, nr)); return []
    offen = _schon_offen(nr); neu = []
    for f in ff:
        w = was(f)
        if w.split(":", 2)[0] + ":" + w.split(":", 2)[1] in offen:
            print("STREICHEN %s: schon offen: %s" % (nr, w)); continue
        neu.append(uebergabe.uebergabe(nr, "Disponent", w))
    return neu

def lauf_zeilen(docs=None):
    return ["STREICHEN %s | %s (1688: zuerst, vor jedem Start; danach vorgang.py erledigt %s)" % (k, w, k)
            for k, w in uebergabe.offen_lokal("Disponent", docs) if w.startswith(KOPF)]

def zuerst(zeilen):
    """STREICHEN-Zeilen an den Anfang, sonst Reihenfolge unverändert."""
    return [l for l in zeilen if l.startswith("STREICHEN ")] + [l for l in zeilen if not l.startswith("STREICHEN ")]

def haupt(a):
    if len(a) == 2 and a[0] == "funde":
        ff = funde(a[1]); print("\n".join(was(f) for f in ff) or "keine Zeile"); return 0
    if len(a) == 2 and a[0] == "melden":
        try: melden(a[1]); return 0
        except uebergabe.Fehler as e: print("streichen.py: %s" % e); return 1
    if a and a[0] == "lauf" and len(a) <= 2:
        z = lauf_zeilen(a[1] if len(a) == 2 else None)
        if z: print("\n".join(z))
        return 0
    print(__doc__); return 2

if __name__ == "__main__":
    sys.exit(haupt(sys.argv[1:]))
