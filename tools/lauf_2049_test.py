#!/usr/bin/env python3
"""2049 (Chef 26.11., 09:51): Start der Leitung mit `lauf.py --start Sokrates|"Alter Ego" "Nachricht"`:
(a) ohne Vorgangsnummer, (b) Titel „Sokrates – Leitung (TT.MM.)“ / „Alter Ego – Supervisor (TT.MM.)“ (kosten.rolle erkennt sie),
(c) Alter Ego mit Startblock aus docs/leitung/alter-ego.md bis vor „## Protokoll“, ohne WARNUNG 1923, Haken ohne „Notstart:“,
(d) läuft die Rolle laut Titel schon (auch Altformen), nur HINWEIS statt START; ohne Sitzungsliste HINWEIS (wie 2002)."""
import importlib.util, os, sys, tempfile, datetime
H = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, H)
sys.argv = [sys.argv[0]]
import lauf, kosten, rufname
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

TAG = lauf.JETZT.strftime("%d.%m.")
SOLL = {"Sokrates": "Sokrates – Leitung (%s)" % TAG, "Alter Ego": "Alter Ego – Supervisor (%s)" % TAG}
AE = open(os.path.join(H, "..", "docs", "leitung", "alter-ego.md"), encoding="utf-8").read().split("\n")
AE_TEXT = "\n".join(AE[1:next(k for k, z in enumerate(AE) if z.startswith("## Protokoll"))]).strip()
u = (lauf.JETZT - datetime.timedelta(minutes=5)).astimezone(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

def lebend(titel, status="SESSION_STATUS_IDLE"):
    return {"id": "session_x1", "title": titel, "created_at": u, "updated_at": u, "session_status": status}

for rolle in ("Sokrates", "Alter Ego"):
    # (a) zwei Argumente: ROLLE "Nachricht" [SEITE …]
    r = versuch(lambda *a: lauf.start_argumente(*a), [rolle, "Leite den Betrieb.", "/tmp/s.json"])
    pruefe(r == (rolle, None, "Leite den Betrieb.", ["/tmp/s.json"]), "(a) %s ohne Nummer: %r" % (rolle, r))
    r = versuch(lambda *a: lauf.start_argumente(*a), [rolle, "Leite den Betrieb."])
    pruefe(r == (rolle, None, "Leite den Betrieb.", []), "(a) %s ohne Nummer, ohne Seite: %r" % (rolle, r))
    # (b) Titel, kosten.rolle, kein Rufname
    zs = versuch(lauf.start_zeilen, rolle, None, "Leite den Betrieb.", [], lebende=[])
    zs = zs if isinstance(zs, list) else [repr(zs)]
    start = [x for x in zs if x.startswith("START ")]
    pruefe(len(start) == 1, "(b) %s: genau eine START-Zeile: %s" % (rolle, [x[:160] for x in zs]))
    f = start[0].split(" | ", 6) if start else ["", "", "", "", "", "", ""]
    pruefe(f[0] == "START " + rolle and f[5] == SOLL[rolle], "(b) %s: Titel %r" % (rolle, f[5]))
    pruefe(kosten.rolle(SOLL[rolle], u) == rolle, "(b) kosten.rolle(%r) = %r" % (SOLL[rolle], kosten.rolle(SOLL[rolle], u)))
    pruefe(rufname.aus_titel(SOLL[rolle]) is None and rufname.teile(SOLL[rolle]) is None, "(b) rufname hält %r für Rufnamen" % SOLL[rolle])
    # (c) Startblock, keine WARNUNG 1923, Haken ohne Notstart, keine Meldung 1989
    msg = f[6].replace("\\n", "\n")
    blk = lauf.blocktext(rolle) + "\n\nAuftrag: "  # 2042 (c): der Block kommt aus `lauf.py --startblock`, die Nachricht trägt den Aufruf
    pruefe(lauf.startblock_aufruf(rolle) in msg, "(c) %s: Aufruf --startblock fehlt: %r" % (rolle, msg[:120]))
    pruefe(not any(x.startswith("WARNUNG") for x in zs), "(c) %s: WARNUNG in der Ausgabe: %s" % (rolle, [x for x in zs if x.startswith("WARNUNG")]))
    if rolle == "Alter Ego":
        pruefe(blk.startswith("**Alter Ego**\n" + AE_TEXT + "\n\nAuftrag: "), "(c) Alter Ego: Block nicht „**Alter Ego**“ + alter-ego.md bis Protokoll: %r" % msg[:120])
        pruefe("## Protokoll" not in blk and "# Alter Ego" not in blk, "(c) Alter Ego: Protokoll oder Kopfzeile im Block")
    else:
        teile = lauf.leitung_block()
        pruefe(teile and blk.startswith("\n\n".join("**%s**\n%s" % (n, t) for n, t in teile) + "\n\nAuftrag: "), "(c) Sokrates: leitung_block nicht unverändert vorn")
    pruefe("Leite den Betrieb." in msg and "Notstart" not in msg, "(c) %s: Nachricht fehlt oder Notstart: %r" % (rolle, msg[-200:]))
    gemeldet = []; haken.MELDEN = lambda nr, text: gemeldet.append((nr, text))
    pruefe(haken.startblock_fehlt({"title": f[5], "prompt": f[6]}) is None and not gemeldet, "(c) %s: Haken weist ab oder meldet 1989: %s" % (rolle, gemeldet))
    # (d) läuft schon: Hinweis statt START; archiviert zählt nicht; ohne Liste Hinweis
    alt = {"Sokrates": ["Sokrates Leitung", "Sokrates – 1989: Handstart (26.11., 09:17)", SOLL["Sokrates"]],
           "Alter Ego": ["Alter Ego – Supervisor (25.11.)", SOLL["Alter Ego"]]}[rolle]
    for t in alt:
        zs = versuch(lauf.start_zeilen, rolle, None, "x", [], lebende=[lebend(t)])
        zs = zs if isinstance(zs, list) else [repr(zs)]
        pruefe(not any(x.startswith(("START", "STARTSPERRE")) for x in zs) and any(x.startswith("HINWEIS %s läuft schon: session_x1 %s" % (rolle, t)) for x in zs),
               "(d) %s läuft (%r): %s" % (rolle, t, [x[:120] for x in zs]))
    zs = versuch(lauf.start_zeilen, rolle, None, "x", [], lebende=[lebend(alt[0], "SESSION_STATUS_ARCHIVED"), lebend("Anna – in Arbeit – 2049 – x")])
    zs = zs if isinstance(zs, list) else [repr(zs)]
    pruefe(any(x.startswith("START " + rolle) for x in zs), "(d) %s archiviert/andere Rolle → START: %s" % (rolle, [x[:120] for x in zs]))
    zs = versuch(lauf.start_zeilen, rolle, None, "x", [])
    zs = zs if isinstance(zs, list) else [repr(zs)]
    pruefe(not any(x.startswith("START") for x in zs) and any(x.startswith("HINWEIS Sitzungsliste fehlt, Doppelstart nicht prüfbar") for x in zs),
           "(d) %s ohne Sitzungsliste: %s" % (rolle, [x[:120] for x in zs]))

# (d) aus der Kurzform von list_sessions (wie der Takt), Altform „Sokrates Leitung“
d = tempfile.mkdtemp(); sp = os.path.join(d, "s.txt")
open(sp, "w", encoding="utf-8").write("session_01 | idle | %s | Sokrates Leitung | - | %s | \n# has_more: nein\n" % (u, u))
zs = versuch(lauf.start_zeilen, "Sokrates", None, "x", [], lebende=lauf.sitzungen_lesen([sp]))
zs = zs if isinstance(zs, list) else [repr(zs)]
pruefe(any(x.startswith("HINWEIS Sokrates läuft schon: session_01") for x in zs) and not any(x.startswith("START") for x in zs), "(d) Kurzform: %s" % zs)
# Fachkräfte und Büro: Nummer bleibt Pflicht, Titel wie bisher
pruefe(versuch(lambda *a: lauf.start_argumente(*a), ["Werkzeug", "Bau das."]) is None, "(a) Werkzeug ohne Nummer angenommen")
pruefe(versuch(lambda *a: lauf.start_argumente(*a), ["Werkzeug", "2049", "Bau das.", "s.json"]) == ("Werkzeug", "2049", "Bau das.", ["s.json"]), "(a) Werkzeug mit Nummer")
zs = lauf.start_zeilen("Werkzeug", "2049", "Bau das.", [])
pruefe(any(x.startswith("START Werkzeug") and "2049" in x.split(" | ")[5] for x in zs), "Werkzeug: Titel mit Nummer")

print("LAUF2049 %d Fälle, %d Fehler" % (faelle, fehler))
sys.exit(1 if fehler else 0)
