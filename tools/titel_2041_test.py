#!/usr/bin/env python3
"""2041 d (Chef 25.11., 20:36 „Name, Status, Vorgangsnummer, Betreff“; Lesart A Sokrates 21:01): Titel „Name – Status – Nr – Betreff“,
Status aus der Übergabezeile der Sitzung („in Arbeit“, „beim Prüfer“, „wartet“, „frei“); jeder Titelleser in tools/ liest alt und neu;
vorgang.py annehmen, rueckmeldung „fertig“/„Frage“ geben „TITEL <Titel>“ aus, der Prüfer bei ja/nein „TITEL <Kennung> <Titel>“.
Ohne Netz und ohne Schreiben. Aufruf: python3 tools/titel_2041_test.py"""
import importlib.util, io, json, os, re, sys, tempfile, contextlib
HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
import rufname as rn, kosten, guthaben, lauf, uebergabe as ue, rueckmeldung

fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else zeige))
def fn(mod, name):  # fehlt die Funktion oder bricht sie: Test rot statt Absturz
    f = getattr(mod, name, None)
    def g(*a, **k):
        try: return f(*a, **k) if f else "fehlt"
        except Exception as e: return "Fehler %r" % e
    return g

ALT = "Nora – 2041: Abläufe a–d jetzt (25.11., 21:09)"
NEU = "Nora – in Arbeit – 2041 – Abläufe a–d jetzt"
P_ALT = "Ralf – 2035: Prüfung Disponent erkennen (25.11., 21:00)"
P_NEU = "Ralf – beim Prüfer – 2035 – Prüfung Disponent erkennen"
DISP = "Detlef – Disponent – Betrieb (25.11., 18:47)"
ZEILEN = [{"nr": "2041", "besitzer": "Werkzeug", "titel": "Abläufe a–d jetzt: Prüfzeile bei gebaut"},
          {"nr": "2035", "besitzer": "Werkzeug", "titel": "Disponent erkennen"}]
rn._ZEILEN["liste"] = ZEILEN
guthaben.ZEILEN = ZEILEN
leser = set()

# Titelbauer
soll("d Bauer: rufname.titel → Name – Status – Nr – Betreff", fn(rn, "titel")("Nora", "2041", "Abläufe a–d jetzt") == NEU, fn(rn, "titel")("Nora", "2041", "Abläufe a–d jetzt"))
soll("d Bauer: Status beim Prüfer", fn(rn, "titel")("Ralf", "2035", "Prüfung Disponent erkennen", "beim Prüfer") == P_NEU)
soll("d Bauer: unbekannter Status bricht ab", fn(rn, "titel")("Nora", "2041", "x", "irgendwas") is None)
soll("d teile alt", fn(rn, "teile")(ALT) == {"name": "Nora", "status": None, "nr": "2041", "betreff": "Abläufe a–d jetzt"}, fn(rn, "teile")(ALT))
soll("d teile neu", fn(rn, "teile")(NEU) == {"name": "Nora", "status": "in Arbeit", "nr": "2041", "betreff": "Abläufe a–d jetzt"}, fn(rn, "teile")(NEU))
soll("d teile Disponent: None", fn(rn, "teile")(DISP) is None, fn(rn, "teile")(DISP))

# Leser, je alt und neu
for t in (ALT, NEU):
    soll("Leser rufname.aus_titel: %s" % t, rn.aus_titel(t) == "Nora"); leser.add("rufname.aus_titel")
    soll("Leser rufname.bereich: %s" % t, rn.bereich(t, ZEILEN) == "Werkzeug"); leser.add("rufname.bereich")
    soll("Leser kosten.rolle: %s" % t, kosten.rolle(t) == "Werkzeug", kosten.rolle(t)); leser.add("kosten.rolle")
    soll("Leser uebergabe.DISPONENT_TITEL trifft nicht: %s" % t, not ue.DISPONENT_TITEL.match(t)); leser.add("uebergabe.DISPONENT_TITEL")
    soll("Leser guthaben.FREI_TITEL trifft nicht: %s" % t, not guthaben.FREI_TITEL.match(t)); leser.add("guthaben.FREI_TITEL")
    soll("Leser guthaben.vorgang_rolle (TITEL_NR): %s" % t, guthaben.vorgang_rolle(t) == "Werkzeug"); leser.add("guthaben.TITEL_NR")
    soll("Leser guthaben.ober_rolle Fachkraft: %s" % t, guthaben.ober_rolle("Werkzeug", t) == "Werkzeug"); leser.add("guthaben.ober_rolle")
    soll("Leser lauf.nummer_aus_titel: %s" % t, lauf.nummer_aus_titel(t) == "2041", lauf.nummer_aus_titel(t)); leser.add("lauf.nummer_aus_titel")
    soll("Leser lauf.nummern_aus_titel: %s" % t, lauf.nummern_aus_titel(t) == "2041", lauf.nummern_aus_titel(t)); leser.add("lauf.nummern_aus_titel")
for t in (P_ALT, P_NEU):
    soll("Leser guthaben.TITEL_ROLLE Prüfer: %s" % t, guthaben.ober_rolle("Werkzeug", t) == "Prüfer", guthaben.ober_rolle("Werkzeug", t)); leser.add("guthaben.TITEL_ROLLE")
soll("Leser uebergabe.DISPONENT_TITEL Disponent", bool(ue.DISPONENT_TITEL.match(DISP)) and kosten.rolle(DISP) == "Disponent")
for t, n in (("Paula – Auftrag 2041 (25.11., 21:00)", "2041"), ("Paula – in Arbeit – 2041 – Auftrag Abläufe", "2041"), ("Paula – in Arbeit – 2041 – Abläufe", "2041")):
    soll("Leser lauf.auftrag_aus_titel: %s" % t, lauf.auftrag_aus_titel(t) == n, lauf.auftrag_aus_titel(t)); leser.add("lauf.auftrag_aus_titel")
soll("Leser lauf.auftrag_aus_titel alt ohne Auftrag: None", lauf.auftrag_aus_titel(ALT) is None)
z = "START Werkzeug | a | b | c | d | %s | Auftrag"
for t, soll_t in (("Werkzeug – 2041: Abläufe (25.11., 21:09)", "Nora – 2041: Abläufe (25.11., 21:09)"), ("Werkzeug – in Arbeit – 2041 – Abläufe", "Nora – in Arbeit – 2041 – Abläufe")):
    rn_alt = rn.naechster; rn.naechster = lambda belegt, docs=None: "Nora"
    try: aus = lauf.mit_rufnamen([z % t], [])
    finally: rn.naechster = rn_alt
    soll("Leser lauf.mit_rufnamen: %s" % t, aus[0].split(" | ")[5] == soll_t, aus); leser.add("lauf.mit_rufnamen")
d = tempfile.mkdtemp()
open(os.path.join(d, "ARBEIT-BESETZUNG.md"), "w").write(
    "| Rolle | Sitzung | Vorgang | Zweig | seit |\n|---|---|---|---|---|\n"
    "| Werkzeug | [%s](https://claude.ai/code/session_N) | 2041 | – | x |\n| Werkzeug | [%s](https://claude.ai/code/session_A) | 2041 | – | x |\n"
    "| Prüfer | [%s](https://claude.ai/code/session_P) | 2035 | – | x |\n| Disponent | [%s](https://claude.ai/code/session_D) | Betrieb | – | x |\n" % (NEU, ALT.replace("Nora", "Nils"), P_ALT, DISP))
os.makedirs(os.path.join(d, "docs")); os.rename(os.path.join(d, "ARBEIT-BESETZUNG.md"), os.path.join(d, "docs", "ARBEIT-BESETZUNG.md"))
w_alt = ue.WURZEL; ue.WURZEL = d
try:
    soll("Leser uebergabe.besetzung neu", ue.besetzung("Nora") == ["session_N"], ue.besetzung("Nora")); leser.add("uebergabe.besetzung")
    soll("Leser uebergabe.besetzung alt", ue.besetzung("Nils") == ["session_A"], ue.besetzung("Nils"))
finally:
    ue.WURZEL = w_alt
sp = importlib.util.spec_from_file_location("neustart_haken", os.path.join(HIER, "neustart-haken.py")); nh = importlib.util.module_from_spec(sp); sp.loader.exec_module(nh)
for t, r in ((NEU, ""), (ALT, ""), (DISP, "Disponent")):
    p = os.path.join(d, "t.jsonl"); open(p, "w").write(json.dumps({"type": "user", "message": {"content": t}}) + "\n")
    s = "test2041-%d" % abs(hash(t))
    try: os.remove("/tmp/bornim-name-" + s)
    except OSError: pass
    soll("Leser neustart-haken.name: %s" % t, nh.name(p, s) == r, nh.name(p, s)); leser.add("neustart-haken.name")
    try: os.remove("/tmp/bornim-name-" + s)
    except OSError: pass

# TITEL-Zeilen (Pfad der Besetzung aus dem Testordner)
B = os.path.join(d, "docs", "ARBEIT-BESETZUNG.md")
tz = fn(rn, "titel_zeile")
soll("d TITEL annehmen (Fachkraft)", tz("session_N", "2041", "in Arbeit", pfad=B) == "TITEL " + NEU, tz("session_N", "2041", "in Arbeit", pfad=B))
soll("d TITEL alter Titel: Name aus Besetzung", tz("session_A", "2041", "wartet", pfad=B) == "TITEL Nils – wartet – 2041 – Abläufe a–d jetzt", tz("session_A", "2041", "wartet", pfad=B))
soll("d TITEL für andere Sitzung mit Kennung", tz("session_A", "2041", "frei", fuer=True, pfad=B) == "TITEL session_A Nils – frei – 2041 – Abläufe a–d jetzt")
soll("d Prüfer behält Titel", tz("session_P", "2035", "in Arbeit", pfad=B) is None, tz("session_P", "2035", "in Arbeit", pfad=B))
soll("d Disponent behält Titel", tz("session_D", "2041", "in Arbeit", pfad=B) is None)
soll("d Sitzung ohne Besetzung: Platzhalter statt fremdem Namen", tz("session_X", "2041", "in Arbeit", pfad=B) == "TITEL <Rufname> – in Arbeit – 2041 – Abläufe a–d jetzt", tz("session_X", "2041", "in Arbeit", pfad=B))
soll("d Rolle aus --sitzung Prüfer behält Titel", tz("session_X", "2041", "in Arbeit", pfad=B, rolle="Prüfer") is None)

# rueckmeldung: Status aus der Meldung
VORHER = ("# 2041 · Abläufe\n\n## Rückmeldungen\n\n- **25.11., 21:00**, unbekannt (`session_A`):\n> fertig 2041 a–c, Kopf 741186fd77\n\n")
tn = fn(rueckmeldung, "titel_zeilen")
rn.BESETZUNG = B
try:
    soll("d rueckmeldung fertig mit Commit → beim Prüfer", tn("2041", "fertig a–c, Kopf 741186fd77", VORHER, "session_N", "unbekannt") == ["TITEL Nora – beim Prüfer – 2041 – Abläufe a–d jetzt"], tn("2041", "fertig a–c, Kopf 741186fd77", VORHER, "session_N", "unbekannt"))
    soll("d rueckmeldung Frage → wartet", tn("2041", "Frage: Lesart A oder B?", VORHER, "session_N", "unbekannt") == ["TITEL Nora – wartet – 2041 – Abläufe a–d jetzt"])
    soll("d rueckmeldung Laufanforderung → wartet", tn("2041", "Laufanforderung: Ursache x, Commit abc1234", VORHER, "session_N", "unbekannt") == ["TITEL Nora – wartet – 2041 – Abläufe a–d jetzt"])
    soll("d rueckmeldung fertig ohne Commit → kein Titel", tn("2041", "fertig", VORHER, "session_N", "unbekannt") == [])
    soll("d Prüfer ja → Fachkraft frei", tn("2041", "ja: alle Prüffragen", VORHER, "session_P", "unbekannt") == ["TITEL session_A Nils – frei – 2041 – Abläufe a–d jetzt"], tn("2041", "ja: alle Prüffragen", VORHER, "session_P", "unbekannt"))
    soll("d Prüfer nein → Fachkraft in Arbeit", tn("2041", "nein: Prüffrage 2", VORHER, "session_P", "unbekannt") == ["TITEL session_A Nils – in Arbeit – 2041 – Abläufe a–d jetzt"])
    soll("d Prüfer ja ohne fertig in der Datei → nichts", tn("2041", "ja", "# 2041 · x\n\n## Rückmeldungen\n\n", "session_P", "unbekannt") == [])
    soll("d Hinweis → nichts", tn("2041", "Hinweis: x", VORHER, "session_N", "unbekannt") == [])
finally:
    rn.BESETZUNG = None

# annehmen gibt TITEL aus
a_alt, s_alt = ue.atomar, ue.sitzung
ue.atomar = lambda nr, f, n: ("ANGENOMMEN", "bis 25.11., 22:00")
ue.sitzung = lambda: "session_N"
rn.BESETZUNG = B
try:
    o = io.StringIO()
    with contextlib.redirect_stdout(o): ue.annehmen("2041-Ü6")
    soll("d annehmen → TITEL in Arbeit", "\nTITEL " + NEU + "\n" in "\n" + o.getvalue(), o.getvalue())
finally:
    ue.atomar, ue.sitzung = a_alt, s_alt; rn.BESETZUNG = None

print("Leser: %d (%s)" % (len(leser), ", ".join(sorted(leser))))
print("gut" if not fehl else "%d Fehler" % fehl)
sys.exit(1 if fehl else 0)
