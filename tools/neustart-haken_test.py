#!/usr/bin/env python3
# 1520: Neustart-Haken: Schwellen je Rolle (Tabelle SCHWELLEN), Sperre ab der Schwelle, Ford und Übergabe nie gesperrt.
# Ohne Netz. Aufruf: python3 tools/neustart-haken_test.py
import importlib.util, json, os, shutil, subprocess, sys, tempfile
HIER = os.path.dirname(os.path.abspath(__file__))
fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else zeige))

tmp = tempfile.mkdtemp()
HAKEN = os.path.join(HIER, "neustart-haken.py")
# ohne Kaufrepo, ohne Sitzungskennung (kein „Ford (aktuell)“, nicht geschützt), ohne Prüfliste
ENV = {k: v for k, v in os.environ.items() if k not in ("CLAUDE_CODE_REMOTE_SESSION_ID", "BORNIM_NEUSTART_AB", "BORNIM_SPERRE_AB")}
ENV.update(BORNIM_KAUF=os.path.join(tmp, "kein-kauf"), CLAUDE_PROJECT_DIR=tmp, HOME=tmp)
n = [0]

def protokoll(erste, token):
    n[0] += 1
    p = os.path.join(tmp, "p%d.jsonl" % n[0])
    with open(p, "w") as f:
        f.write(json.dumps({"type": "user", "message": {"content": erste}}) + "\n")
        f.write(json.dumps({"type": "assistant", "message": {"usage": {"input_tokens": 2, "cache_read_input_tokens": token - 2}}}) + "\n")
    return p

def vor(erste, token, werkzeug="Bash", eingabe=None):
    sid = "t1520-%d-%d" % (os.getpid(), n[0] + 1)
    e = {"session_id": sid, "transcript_path": protokoll(erste, token), "tool_name": werkzeug, "tool_input": eingabe or {"command": "ls tools"}}
    r = subprocess.run([sys.executable, HAKEN, "vor"], input=json.dumps(e), capture_output=True, text=True, env=ENV)
    for f in ("/tmp/bornim-name-" + sid, "/tmp/bornim-neustart-" + sid + ".json"):
        try: os.remove(f)
        except OSError: pass
    return r.returncode

spec = importlib.util.spec_from_file_location("neustarthaken", HAKEN)
nh = importlib.util.module_from_spec(spec); spec.loader.exec_module(nh)

# Tabelle je Rolle
soll("Tabelle SCHWELLEN vorhanden", isinstance(getattr(nh, "SCHWELLEN", None), dict))
soll("Spike 200/300 Tsd.", nh.schwellen("Spike") == (200000, 300000), nh.schwellen("Spike"))
soll("Werkzeug (Neustruktur) 200/300 Tsd.", nh.schwellen("Werkzeug") == (200000, 300000))
soll("unbekannte Rolle: Standard", nh.schwellen("") == nh.STANDARD == (200000, 300000))
soll("Sokrates 400/500 Tsd. (1643)", nh.schwellen("Sokrates") == (400000, 500000))
soll("Kaufrepo +200 Tsd. (818)", nh.schwellen("Spike", True) == (400000, 500000))
soll("Erinnerung bei 2/3 der Sperre (Standard)", nh.STANDARD[0] == round(nh.STANDARD[1] * 2 / 3, -5))

# Rolle aus der ersten Nachricht
p = protokoll("Dein Rufname: Tanja (Rolle Werkzeug; Titel, Besetzung, Meldung).\n\nAuftrag", 1000)
soll("Rolle aus Rufnamen-Start (Werkzeug)", nh.rolle(p, "t1520-r1-%d" % os.getpid()) == "Werkzeug", nh.rolle(p, "x"))
p = protokoll("Dein Rufname: Britta (Rolle Spike; Titel)", 1000)
soll("Rolle aus Rufnamen-Start (Spike)", nh.rolle(p, "t1520-r2-%d" % os.getpid()) == "Spike")
for s in ("t1520-r1-%d" % os.getpid(), "t1520-r2-%d" % os.getpid()):
    try: os.remove("/tmp/bornim-name-" + s)
    except OSError: pass

# Sperre am Werkzeugaufruf
W = "Dein Rufname: Tanja (Rolle Werkzeug; Titel)\n\nAuftrag"
soll("Werkzeug 290 Tsd.: frei", vor(W, 290000) == 0)
soll("Werkzeug 310 Tsd.: gesperrt", vor(W, 310000) == 2)
S = "Sokrates – 1727: Leitung"
soll("Sokrates 450 Tsd.: frei", vor(S, 450000) == 0)
soll("Sokrates 510 Tsd.: gesperrt", vor(S, 510000) == 2)

# Ford nie gesperrt (1574)
soll("Ford 900 Tsd.: frei", vor("Ford – Betriebsleiter", 900000) == 0)
soll("Ford 2 900 Tsd.: frei", vor("Ford 2 – Betrieb", 900000) == 0)

# Übergabe, Push, Nachricht an Ford ab der Sperre frei (1537)
soll("Übergabe (Edit ARBEIT-*.md) frei", vor(W, 900000, "Edit", {"file_path": "/home/user/x/docs/ARBEIT-TEAM-SPIKE.md"}) == 0)
soll("Commit und Push frei", vor(W, 900000, "Bash", {"command": "git add -A && git commit -qm x && git push -q origin main"}) == 0)
soll("vorgang.py rueckmeldung frei", vor(W, 900000, "Bash", {"command": "python3 tools/vorgang.py rueckmeldung 1520 \"fertig\""}) == 0)
soll("Nachricht an Ford frei", vor(W, 900000, "mcp__claude-code-remote__send_message", {"message": "Neustart"}) == 0)
soll("anderes Lesen gesperrt", vor(W, 900000, "Read", {"file_path": "/home/user/x/tools/lauf.py"}) == 2)

shutil.rmtree(tmp, ignore_errors=True)
print("neustart-haken_test: %s" % ("alles grün" if not fehl else "%d FEHL" % fehl))
sys.exit(1 if fehl else 0)
