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
# 2002 (e): Handstart prüft die Obergrenze wie der Takt (Eilt bis N+1); Laufende aus der übergebenen Sitzungsliste
def _e():
    import datetime, guthaben
    O = "- **287 Laufsperre** (22.11., 10:30, Chef an Sokrates: „x“) → **Laufsperre: höchstens drei Fachkräfte zugleich, nur Spiel, spätestens 28.12., 20:00**\n"
    j = lauf.JETZT.replace(hour=15, minute=0) if lauf.JETZT.hour >= 23 or lauf.JETZT.hour < 7 else lauf.JETZT
    WE = {"nr": "1961", "bereich": "B Werkzeuge", "eilt": True, "titel": "x", "stand": "startbar"}
    def br(n): return guthaben.Bremse(j, "", archiv=O, protokoll=[], laufend=n)
    zs = lauf.start_zeilen("Werkzeug", "1961", "Bau das.", [], bremse=br(3), zeile=WE)
    pruefe(any(x.startswith("START Werkzeug") for x in zs), "2002 (e): Handstart Eilt bei N → START: %s" % [x[:120] for x in zs])
    zs = lauf.start_zeilen("Werkzeug", "1961", "Bau das.", [], bremse=br(4), zeile=WE)
    pruefe(not any(x.startswith(("START", "STARTSPERRE")) for x in zs) and any(x.startswith("NICHTS Werkzeug") and "höchstens 3" in x for x in zs),
           "2002 (e): Handstart Eilt bei N+1 → nein: %s" % [x[:160] for x in zs])
    zs = lauf.start_zeilen("Werkzeug", "1961", "Bau das.", [], bremse=br(3), zeile=dict(WE, eilt=False))
    pruefe(not any(x.startswith("START") for x in zs), "2002 (e): Handstart ohne Eilt außerhalb Spiel → nein: %s" % [x[:160] for x in zs])
    zs = lauf.start_zeilen("Prüfer", "1961", "Prüfe.", [], bremse=br(9), zeile=WE)
    pruefe(any(x.startswith("START Prüfer") for x in zs), "2002 (e): Handstart Prüfer frei")
    # Laufende aus der Sitzungsliste (Kurzform wie im Takt), fertige ohne Rückläufer zählen nicht
    u = (lauf.JETZT - datetime.timedelta(minutes=5)).astimezone(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    d = tempfile.mkdtemp(); sp = os.path.join(d, "s.txt")
    open(sp, "w", encoding="utf-8").write("".join("session_0%d | working | %s | %s – 10%d: Handstart (x) | - | %s | \n" % (i, u, r, i, u) for i, r in enumerate(("Kampf", "Welt", "Regeln", "Prüfer"))) + "# has_more: nein\n")
    b = br(None)
    lauf.laufend_setzen(b, lauf.sitzungen_lesen([sp]), marken={}, fertig={"session_02"})
    pruefe(b.laufend == 2 and b.namen == ["Kampf (Kampf)", "Welt (Welt)"], "2002 (e): Laufende aus der Sitzungsliste (Prüfer frei, Regeln fertig): %s %s" % (b.laufend, b.namen))
try: _e()
except Exception as ex: pruefe(False, "2002 (e): Ausnahme %r" % ex)
# 1992: eine lokale Variable in main() darf keine Funktion des Moduls überdecken (for z in zs → UnboundLocalError bei z(...))
import ast, symtable
_q = open(os.path.join(H, "lauf.py"), encoding="utf-8").read()
_main = [c for c in symtable.symtable(_q, "lauf.py", "exec").get_children() if c.get_name() == "main"][0]
_mast = [n for n in ast.parse(_q).body if isinstance(n, ast.FunctionDef) and n.name == "main"][0]
_mod = {n.name for n in ast.parse(_q).body if isinstance(n, ast.FunctionDef)}
_ruf = _mod & {n.func.id for n in ast.walk(_mast) if isinstance(n, ast.Call) and isinstance(n.func, ast.Name)}
_lok = sorted(s.get_name() for s in _main.get_symbols() if s.is_local() and s.get_name() in _ruf)
pruefe(not _lok, "1992: main() ruft Namen auf, die dort lokal überdeckt sind: %s" % _lok)
print("handstart_test: %s" %("gut" if not fehler else "%d Fehler" % fehler))
sys.exit(1 if fehler else 0)
