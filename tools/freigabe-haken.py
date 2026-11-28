#!/usr/bin/env python3
"""1610 (D305.1, zu 1572, Chef 17.11., 17:05: „Da muss mir das mal jemand sagen.“): Notification-Haken.
Zeigt die Sitzung eine Freigabe-Frage (notification_type permission_prompt), geht sofort ein Telegram an den Chef
(tags laut, 22–7 Uhr lautlos), Name verlinkt auf diese Sitzung (meldung.sh). Höchstens eins je 10 Minuten und Sitzung.
Spur in /tmp/freigabe-haken.log, damit Diogenes sieht, ob der Haken in Cloud-Sitzungen überhaupt feuert (greift?).
Lauf.py (15 Minuten) und Wache bleiben das Netz darunter."""
import json, os, sys, time, subprocess, datetime, zoneinfo
try: d = json.load(sys.stdin)
except Exception: d = {}
art = d.get("notification_type") or ""
text = (d.get("message") or "").strip()
jetzt = datetime.datetime.now(zoneinfo.ZoneInfo("Europe/Berlin"))
log = "/tmp/freigabe-haken.log"
try: open(log, "a").write("%s %s %s\n" % (jetzt.strftime("%d.%m. %H:%M:%S"), art or "-", text[:120]))
except OSError: pass
if art != "permission_prompt" and not (not art and "permission" in text.lower()): sys.exit(0)
marke = "/tmp/freigabe-haken.marke"
try:
    if time.time() - os.path.getmtime(marke) < 600: sys.exit(0)
except OSError: pass
open(marke, "w").close()
m = "/home/user/bornim-main/tools/meldung.sh"
if not os.path.exists(m): m = os.path.join(os.path.dirname(os.path.abspath(__file__)), "meldung.sh")
args = [m] + (["--laut"] if 7 <= jetzt.hour < 22 else []) + ["Freigabe", "1572: Sitzung wartet auf deine Freigabe („%s“); Chef: in der Sitzung freigeben oder ablehnen" % text[:150].replace("„", "").replace("“", "")]
try: subprocess.run(args, capture_output=True, timeout=20, env=dict(os.environ, MELDUNG_WERKZEUG="1"))  # 1739: ohne Telegram-Regel
except Exception: pass
sys.exit(0)
