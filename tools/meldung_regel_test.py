#!/usr/bin/env python3
"""Test 1739: meldung.sh zeigt die Telegram-Regel bei jedem Aufruf; mit Schalter 1727-SCHARF geht die erste Meldung je Sitzung
erst beim zweiten Aufruf raus. Sendet nichts: curl und git sind Attrappen, die nur mitschreiben."""
import os, subprocess, sys, tempfile

HIER = os.path.dirname(os.path.abspath(__file__))
fehler = 0
def soll(name, ok, info=""):
    global fehler
    print(("ok   " if ok else "FEHL ") + name, "" if ok else info)
    if not ok: fehler += 1

tmp = tempfile.mkdtemp()
binr = os.path.join(tmp, "bin"); os.makedirs(binr)
log = os.path.join(tmp, "curl.log")
for n, text in (("curl", 'echo "$@" >> %s; echo \'{"ok":false,"description":"Attrappe"}\'' % log), ("git", "exit 1")):
    p = os.path.join(binr, n); open(p, "w").write("#!/bin/sh\n" + text + "\n"); os.chmod(p, 0o755)
scharf = os.path.join(tmp, "1727-SCHARF")

def lauf(sitzung, scharf_an=True, werkzeug=False):
    env = dict(os.environ, PATH=binr + ":" + os.environ["PATH"], TELEGRAM_BOT_TOKEN="x", MELDUNG_WEITER="1",
               MELDUNG_MARKEN=os.path.join(tmp, "marken"), MELDUNG_SCHARF=scharf if scharf_an else os.path.join(tmp, "fehlt"),
               CLAUDE_CODE_REMOTE_SESSION_ID=sitzung)
    env.pop("MELDUNG_WERKZEUG", None)
    if werkzeug: env["MELDUNG_WERKZEUG"] = "1"
    try: os.remove(log)
    except OSError: pass
    r = subprocess.run([os.path.join(HIER, "meldung.sh"), "Test", "9001: Probe"], env=env, capture_output=True, text=True, timeout=60)
    return r.returncode, r.stderr, os.path.exists(log)

open(scharf, "w").close()
c, e, gesendet = lauf("cse_a")
soll("erste Meldung: Regel gezeigt", "Telegram ist dein Protokoll" in e, e)
soll("erste Meldung: nichts gesendet, Exit 3", c == 3 and not gesendet, (c, gesendet))
c, e, gesendet = lauf("cse_a")
soll("zweiter Aufruf: Regel wieder gezeigt", "Telegram ist dein Protokoll" in e, e)
soll("zweiter Aufruf: geht raus", gesendet and "erste Meldung" not in e, (c, e))
c, e, gesendet = lauf("cse_b")
soll("andere Sitzung: wieder erst anhalten", c == 3 and not gesendet, (c, gesendet))
c, e, gesendet = lauf("cse_c", scharf_an=False)
soll("ohne Schalter: Regel gezeigt, gesendet (rückwärtsverträglich)", "Telegram ist dein Protokoll" in e and gesendet and c != 3, (c, e))
c, e, gesendet = lauf("cse_d", werkzeug=True)
soll("Werkzeug (MELDUNG_WERKZEUG): ohne Regel, gesendet", "Telegram ist dein Protokoll" not in e and gesendet, (c, e))

print("meldung_regel_test: " + ("alles grün" if not fehler else "%d Fehler" % fehler))
sys.exit(1 if fehler else 0)
