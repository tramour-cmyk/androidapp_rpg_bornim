#!/usr/bin/env python3
"""1989 (Chef 23.11., 09:04 und 09:11 „1 bis 3 ja“): `lauf.py --start ROLLE NR "Nachricht"` gibt eine fertige START-Zeile mit
Startblock (mit_kern, Kaufrepo-Satz, Rufname) und eine Startsperre mit Rolle; startsperre-haken.py weist ein create_session ohne
Startblock ab, außer mit „Notstart: <Grund>“ (dann Meldung an Sokrates)."""
import importlib.util, os, re, sys, tempfile
H = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, H)
sys.argv = [sys.argv[0]]
import lauf, rufname
spec = importlib.util.spec_from_file_location("startsperre_haken", os.path.join(H, "startsperre-haken.py"))
haken = importlib.util.module_from_spec(spec); spec.loader.exec_module(haken)

fehler = 0
def pruefe(ok, was):
    global fehler
    if not ok:
        fehler += 1
        print("FEHLER", was)

lauf.neue_liste()
for rolle, nr in (("Prüfer", "1988"), ("Werkzeug", "1989"), ("Sokrates", "1989")):
    zs = lauf.start_zeilen(rolle, nr, "Prüfe die Rückmeldung.", [])
    start = [z for z in zs if z.startswith("START ")]
    pruefe(len(start) == 1, "%s: genau eine START-Zeile: %s" % (rolle, zs))
    if not start: continue
    l = start[0]; f = l.split(" | ", 6)
    pruefe(f[0] == "START " + rolle and f[3] == lauf.REPO and f[4] == lauf.REVISION, "%s: Kopf (Rolle, Repo, main): %s" % (rolle, f[:5]))
    pruefe(("– %s: Handstart" % nr) in f[5], "%s: Titel mit Nummer: %s" % (rolle, f[5]))
    pruefe("\n" not in l, "%s: echter Zeilenumbruch" % rolle)
    msg = f[6].replace("\\n", "\n")
    teile = lauf.leitung_block() if rolle == "Sokrates" else lauf.startblock(rolle, nr)[0]
    pruefe(teile and all(("**%s**\n%s" % (n, t)) in msg for n, t in teile), "%s: Startblock nicht vollständig in der Nachricht" % rolle)
    pruefe("Prüfe die Rückmeldung." in msg and "Rollendatei" not in msg, "%s: Nachricht fehlt oder alter Verweis: %s" % (rolle, msg[-200:]))
    pruefe("add_repo" in msg, "%s: Kaufrepo-Satz fehlt" % rolle)
    pruefe(haken.startblock_fehlt({"title": f[5], "prompt": msg}) is None, "%s: Haken weist die Zeile aus lauf.py --start ab" % rolle)
    sp = [z for z in zs if z.startswith("STARTSPERRE ")]
    pruefe(len(sp) == 1 and re.search(r"Startsperre \d\d:\d\d Start %s \(lauf\.py, " % rolle, sp[0]), "%s: Startsperre mit Rolle: %s" % (rolle, sp))
    if sp and rolle != "Sokrates" and lauf.ist_scharf():
        n = rufname.aus_titel(f[5])
        b = os.path.join(tempfile.mkdtemp(), "b.md"); open(b, "w", encoding="utf-8").write(sp[0][len("STARTSPERRE "):] + "\n")
        pruefe(n and rufname.rolle(f[5], None, b) == rolle, "%s: rufname.rolle ordnet die Startsperre nicht zu (Fund Viola): %s / %s" % (rolle, n, sp[0]))

# Werkzeugsperre im Haken
ohne = {"title": "Werkzeug – 1989: x", "prompt": "Werkzeug\n\nBau das. Zuerst Start nach deiner Rollendatei."}
pruefe(haken.startblock_fehlt(ohne) is not None, "Haken: Handstart ohne Startblock geht durch")
falsch = {"title": "Werkzeug – 1989: x", "prompt": "**Gibtsnicht**\nText\n\nAuftrag: Bau das."}
pruefe(haken.startblock_fehlt(falsch) is not None, "Haken: Kopfzeile ohne Profildatei zählt als Startblock")
gemeldet = []
haken.MELDEN = lambda nr, text: gemeldet.append((nr, text))
nots = {"title": "Werkzeug – 1989: x", "prompt": "Werkzeug\n\nNotstart: lauf.py bricht ab. Bau das."}
pruefe(haken.startblock_fehlt(nots) is None, "Haken: Notstart abgewiesen")
pruefe(gemeldet and gemeldet[0][0] == "1989" and "lauf.py bricht ab" in gemeldet[0][1], "Haken: Notstart ohne Meldung an Sokrates: %s" % gemeldet)
pruefe(haken.startblock_fehlt({"title": "Rundblick 23.11.", "prompt": "Rundblick: x"}) is None, "Haken: Routine (ohne Kern) abgewiesen")
print("handstart_test: %s" % ("gut" if not fehler else "%d Fehler" % fehler))
sys.exit(1 if fehler else 0)
