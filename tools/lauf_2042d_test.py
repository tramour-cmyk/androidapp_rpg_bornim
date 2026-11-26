#!/usr/bin/env python3
"""2042 (d) (Alter Ego in Vertretung 26.11., 10:06; Chef 11:07 „die kurze Sitzungsliste“): list_sessions nur über lauf.py. Das Ergebnis
landet als Datei (Hinweis „saved to <Pfad>“); lauf.py liest die Datei selbst (auch mit dem Rahmen <other-session …>), der Disponent
liest sie nicht und schreibt keine Kurzform. Je lebende Sitzung eine Zeile SITZUNG (Kennung kurz, Titel, Status, Tokens);
JSON-Seite mit has_more, deren letzte Sitzung vor der Zeitgrenze liegt, gilt als vollständig; sonst nennt die Warnung after_id;
Tokens aus get_session über --token ID=N statt Kurzform."""
import datetime, json, os, sys, tempfile
H = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, H)
SEITEN = sys.argv[1:]
sys.argv = [sys.argv[0]]
import lauf, kosten

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

J = lauf.JETZT
iso = lambda d: d.astimezone(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.000000Z")
g = lauf.zeitgrenze(J)
def sitz(i, titel, status="SESSION_STATUS_IDLE", bucket="SESSION_STATUS_BUCKET_REVIEW_READY", alter=None):
    c = (J - datetime.timedelta(minutes=10 * i)) if alter is None else alter
    return {"id": "session_01Hmoj7%025dABCDEF" % i, "title": titel, "session_status": status, "status_bucket": bucket,
            "created_at": iso(c), "updated_at": iso(J - datetime.timedelta(minutes=i))}
def seite(daten, has_more, rahmen=True):
    d = tempfile.mkdtemp(); p = os.path.join(d, "mcp-claude-code-remote-list_sessions-1-x.txt")
    obj = {"ccr": {"data": daten, "has_more": has_more, "first_id": daten[0]["id"], "last_id": daten[-1]["id"]}}
    t = json.dumps(obj, ensure_ascii=False)
    if rahmen: t = '<other-session nonce="x" untrusted="true">\nAnother Claude session\'s record … DATA\n' + t + "\n</other-session>\n"
    open(p, "w", encoding="utf-8").write(t)
    return p

D = sitz(1, "Disponent – Büro (26.11., 10:28)", "SESSION_STATUS_RUNNING", "SESSION_STATUS_BUCKET_WORKING")
W = sitz(2, "Wiebke – in Arbeit – 2042 – Wieso werden die Disponenten so schnell groß", "SESSION_STATUS_RUNNING", "SESSION_STATUS_BUCKET_WORKING")
A = sitz(3, "Nora – in Arbeit – 2042 – alt", "SESSION_STATUS_ARCHIVED", "SESSION_STATUS_BUCKET_COMPLETED")
X = sitz(4, "Fritz – Prüfer – frei", alter=g - datetime.timedelta(minutes=5))

# Datei mit Rahmen lesen
p1 = seite([D, W, A, X], True)
offen = []; s = kosten.sitzungen(p1, offen)
pruefe(len(s) == 4 and offen == [p1], "Seite mit Rahmen: %d Sitzungen, offen %s" % (len(s), offen))
# has_more, letzte vor der Zeitgrenze: vollständig bis zur Grenze
r = versuch(lauf.grenze_offen, [p1], J)
pruefe(isinstance(r, tuple) and r[0] == [] and r[1] == [p1], "JSON-Seite bis zur Zeitgrenze nicht vollständig: %r" % (r,))
# has_more, letzte nach der Grenze: offen, Warnung nennt after_id
p2 = seite([D, W], True)
r = versuch(lauf.grenze_offen, [p2], J)
pruefe(isinstance(r, tuple) and r[0] == [p2], "JSON-Seite vor der Grenze abgeschnitten gilt als vollständig: %r" % (r,))
w = versuch(lauf.seite_warnung, [p2]) if hasattr(lauf, "seite_warnung") else None
pruefe(isinstance(w, str) and "after_id %s" % W["id"] in w and "WARNUNG" in w, "Warnung ohne after_id: %r" % w)
# je lebende Sitzung eine Zeile
alle = {x["id"]: x for x in kosten.sitzungen(p1, [])}
zs = versuch(lauf.sitzung_zeilen, alle.values()) if hasattr(lauf, "sitzung_zeilen") else None
pruefe(isinstance(zs, list) and len(zs) == 3 and all(z.startswith("SITZUNG ") for z in zs), "SITZUNG-Zeilen: %r" % zs)
if isinstance(zs, list) and zs:
    pruefe(all(len(z) <= 120 for z in zs), "Zeile über 120 Zeichen: %r" % max(zs, key=len))
    pruefe(any("…ABCDEF" in z and "Disponent – Büro" in z and "working" in z for z in zs), "Disponent-Zeile ohne Kennung/Status: %r" % zs)
    pruefe(not any("Nora" in z for z in zs), "archivierte Sitzung gelistet")
    pruefe(any("Fritz" in z and "idle" in z and z.endswith("| -") for z in zs), "ohne Tokens nicht „-“: %r" % zs)
# --token ID=N trägt used_tokens ein (Zeile TOKEN)
t = versuch(lauf.token_setzen, alle, ["%s=123456" % D["id"]]) if hasattr(lauf, "token_setzen") else None
pruefe(alle[D["id"]].get("context_usage", {}).get("used_tokens") == 123456, "--token setzt used_tokens nicht: %r" % (t,))
zs = lauf.sitzung_zeilen(alle.values()) if hasattr(lauf, "sitzung_zeilen") else []
pruefe(any("Disponent" in z and z.endswith("| 123 Tsd.") for z in zs), "Tokens nicht in der Zeile: %r" % zs)
t = versuch(lauf.token_setzen, alle, ["session_unbekannt=5"]) if hasattr(lauf, "token_setzen") else None
pruefe(isinstance(t, Exception), "--token mit unbekannter Kennung still angenommen")
je = {"Disponent": [dict(D)]}
tz = lauf.leitung_neustart(je, set(), wache="w")
pruefe(tz and tz[0].startswith("TOKEN ") and "--token %s=" % D["id"] in tz[0] and "Kurzform" not in tz[0], "TOKEN-Zeile ohne --token: %r" % tz)
# Byte: echte Seite (nur wenn vorhanden)
for q in SEITEN:
    leb = [x for x in kosten.sitzungen(q, []) if x.get("session_status") != "SESSION_STATUS_ARCHIVED"]
    print("BYTE %s: Datei %d, SITZUNG-Zeilen %d (%d lebende)" % (os.path.basename(q), os.path.getsize(q), len("\n".join(lauf.sitzung_zeilen(leb)).encode()), len(leb)))

print("LAUF2042D %d Fälle, %d FEHL" % (faelle, fehler))
sys.exit(1 if fehler else 0)
