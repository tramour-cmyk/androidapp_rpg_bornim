#!/usr/bin/env python3
"""2042 (c) (Alter Ego in Vertretung 26.11., 10:06; Chef 11:07 „erst den kurzen Startprompt“): die Startnachricht jeder START-Zeile
trägt statt des Startblocks nur den Aufruf `python3 tools/lauf.py --startblock ROLLE NR, Ausgabe ist dein Auftrag.`; die Option
gibt den Startblock (Ladetext, Verweis auf den Auftrag) aus, den mit_kern bisher einsetzte. Rufname-Zeile bleibt (startsperre-haken,
rufname.eigener_start); der Haken nimmt den Aufruf als Startblock an, nicht für eine Rolle ohne Profil."""
import importlib.util, os, subprocess, sys
H = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, H)
sys.argv = [sys.argv[0]]
import lauf
spec = importlib.util.spec_from_file_location("startsperre_haken", os.path.join(H, "startsperre-haken.py"))
haken = importlib.util.module_from_spec(spec); spec.loader.exec_module(haken)

fehler = 0; faelle = 0
def pruefe(ok, was):
    global fehler, faelle
    faelle += 1
    if not ok:
        fehler += 1
        print("FEHL", was)

def versuch(f, *a, **k):
    try: return f(*a, **k)
    except Exception as ex: return ex

lauf.neue_liste()
NR = "2042"
for rolle, nr, aufruf in (("Werkzeug", NR, "--startblock Werkzeug 2042"), ("Prüfer", NR, "--startblock Prüfer 2042"),
                          ("Sokrates", None, "--startblock Sokrates"), ("Alter Ego", None, '--startblock "Alter Ego"')):
    zs = versuch(lauf.start_zeilen, rolle, nr, "Prüfe die Rückmeldung.", [], lebende=[] if nr is None else None)
    st = [z for z in zs if z.startswith("START ")] if isinstance(zs, list) else []
    pruefe(len(st) == 1, "%s: genau eine START-Zeile: %r" % (rolle, zs))
    if not st: continue
    f = st[0].split(" | ", 6); msg = f[6].replace("\\n", "\n")
    pruefe(("python3 tools/lauf.py %s, Ausgabe ist dein Auftrag." % aufruf) in msg, "%s: Aufruf fehlt: %r" % (rolle, msg[:160]))
    voll = lauf.blocktext(rolle, nr) if hasattr(lauf, "blocktext") else ""
    pruefe(voll and "**" in voll and voll not in msg and "\n**%s**\n" % rolle not in "\n" + msg, "%s: Ladetext steht noch in der Startnachricht" % rolle)
    pruefe("Prüfe die Rückmeldung." in msg and "add_repo" in msg, "%s: Nachricht oder Kaufrepo-Satz fehlt: %r" % (rolle, msg[-200:]))
    pruefe("Ladetext oben" not in msg and "Rollendatei" not in msg, "%s: Verweis auf Ladetext oben/Rollendatei: %r" % (rolle, msg))
    pruefe(len(msg) < 1200, "%s: Startnachricht %d Zeichen (Ziel < 1.200)" % (rolle, len(msg)))
    if nr and lauf.ist_scharf(): pruefe(msg.startswith("Dein Rufname: "), "%s: Rufname-Zeile fehlt vorn: %r" % (rolle, msg[:80]))
    pruefe(haken.startblock_fehlt({"title": f[5], "prompt": msg}) is None, "%s: Haken weist den Kurzstart ab" % rolle)
    # die Option gibt genau den Block aus (Ausgabe ist der Auftrag)
    arg = [sys.executable, os.path.join(H, "lauf.py"), "--startblock", rolle] + ([nr] if nr else []) + ["--ohne-pull"]
    r = subprocess.run(arg, capture_output=True, text=True, timeout=120)
    pruefe(r.returncode == 0 and voll and r.stdout.strip() == voll.strip(), "%s: --startblock Exit %s, Ausgabe ≠ blocktext: %r" % (rolle, r.returncode, (r.stdout + r.stderr)[:200]))
    if nr: pruefe("docs/vorgang/%s.md" % nr in r.stdout, "%s: Verweis auf den Auftrag fehlt in --startblock" % rolle)
    print("BYTE %s Startnachricht %d, Ladetext daraus nach --startblock %d" % (rolle, len(msg.encode()), len((voll or "").encode())))

# Haken: Aufruf für eine Rolle ohne Profil ist kein Startblock; ohne Aufruf weiter abgewiesen
falsch = {"title": "Werkzeug – 1989: x", "prompt": "python3 tools/lauf.py --startblock Gibtsnicht 1989, Ausgabe ist dein Auftrag.\n\nBau."}
pruefe(haken.startblock_fehlt(falsch) is not None, "Haken: Aufruf mit unbekannter Rolle geht durch")
ohne = {"title": "Werkzeug – 1989: x", "prompt": "Werkzeug\n\nBau das."}
pruefe(haken.startblock_fehlt(ohne) is not None, "Haken: Start ohne Startblock geht durch")
# mit_kern ohne kurz bleibt die Vollform (Leser: lauf_kern_test, ladesumme)
l = lauf.mit_kern("START Story | opus | env | repo | main | Story – 2099: z | Schreibe.")
pruefe("**Story**" in l and "--startblock" not in l, "mit_kern ohne kurz verändert: %r" % l[:120])
k = versuch(lauf.mit_kern, "START Story | opus | env | repo | main | Story – 2099: z | Schreibe.", None, True)
pruefe(isinstance(k, str) and "--startblock Story 2099" in k and "**Story**" not in k, "mit_kern kurz: %r" % k)
r = subprocess.run([sys.executable, os.path.join(H, "lauf.py"), "--startblock", "--ohne-pull"], capture_output=True, text=True, timeout=60)
pruefe(r.returncode != 0, "--startblock ohne Rolle: Exit 0")

print("LAUF2042C %d Fälle, %d FEHL" % (faelle, fehler))
sys.exit(1 if fehler else 0)
