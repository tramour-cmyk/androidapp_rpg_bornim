#!/usr/bin/env python3
"""2042 Teil 6 und 9 (Nachträge Sokrates 22:36, 22:44, Antwort 2042-Ü13 22:53). Ohne Netz, Testordner in /tmp.
(6a) Wecker an eine Fachrolle geht an die Sitzung mit dem Vorgang, nicht an jede der Rolle (Fall 2042-Ü6: Olga/Ralf statt Carla).
(6b) TITEL der eigenen Sitzung: Rolle und Rufname aus der Startnachricht, nicht aus der Besetzung; nie ein Platzhalter.
(6c) rufname.rolle: Startsperre mit der Nummer des Titels vor der jüngsten; „Prüfer“ im Titel ist Prüfer (Paula, Ralf).
(6d) „Frage“ neben Weiterbau lässt „in Arbeit“; „wartet“ nur, wenn die Meldung das Anhalten sagt (Fall Carla 22:46).
(6e) `erledigt` einer Zeile „Fachkraft starten“ nur mit Kennung der gestarteten Sitzung (Fall Otto 1708-Ü10).
(9) LIEGT-Zeilen im Takt zusammengefasst (Zahl je Art), Einzelheiten mit `liegt.py [Art]`.
Aufruf: python3 tools/lauf_2042b_test.py"""
import contextlib, io, json, os, sys, tempfile
HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
os.environ["BORNIM_SITZUNG"] = "session_EIGEN"
import rufname, uebergabe, rueckmeldung

fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else zeige))
def ausgabe(f, *a, **k):
    b = io.StringIO()
    with contextlib.redirect_stdout(b): r = f(*a, **k)
    return r, b.getvalue()

d = tempfile.mkdtemp(prefix="t2042b-"); os.makedirs(os.path.join(d, "docs"))
B = os.path.join(d, "docs", "ARBEIT-BESETZUNG.md")
KOPF = "| Rolle | Sitzung | Vorgang | Zweig | seit |\n|---|---|---|---|---|\n"
OLGA = "| Werkzeug | [Olga – beim Prüfer – 2041 – Nachträge zu d](https://claude.ai/code/session_OLGA) | 2041 | – | 25.11., 21:27 |\n"
RALF = "| Werkzeug | [Ralf – 2041: Prüfer Ü15 Abläufe a–d (25.11., 21:55)](https://claude.ai/code/session_RALF) | 2041 | – | 25.11., 21:55 |\n"
KARL = "| Disponent | [Karl – Disponent – Betrieb (25.11., 21:38)](https://claude.ai/code/session_KARL) | Betrieb | – | 25.11., 21:38 |\n"
CARLA = "| Werkzeug | [Carla – in Arbeit – 2042 – Disponenten klein](https://claude.ai/code/session_CARLA) | 2042 | – | 25.11., 22:31 |\n"
PAULA = "| Arbeitsplaner | [Paula – 1589.4: Stufe 3 Gegnerverhalten (25.11., 21:49)](https://claude.ai/code/session_EIGEN) | 1589.4 | – | 25.11., 21:49 |\n"
uebergabe.WURZEL = d; rufname.BESETZUNG = B

# (6a) Besetzung 22:04 (echt: Olga, Ralf als Werkzeug zu 2041, Karl) plus Carla zu 2042
open(B, "w").write(KOPF + OLGA + RALF + KARL + CARLA)
ss, t = ausgabe(uebergabe.wecker, "2042", "2042-Ü6", "Werkzeug", scharf=True)
soll("(6a) Wecker 2042-Ü6 nur an Carla (Vorgang 2042)", ss == ["session_CARLA"] and "session_OLGA" not in t and "session_RALF" not in t, t)
open(B, "w").write(KOPF + OLGA + RALF + KARL)  # Stand 22:04 ohne Carla
ss, t = ausgabe(uebergabe.wecker, "2042", "2042-Ü6", "Werkzeug", scharf=True)
soll("(6a) ohne Sitzung zu 2042: alle der Rolle wie bisher (kein Wecker fällt still weg)", ss == ["session_OLGA", "session_RALF"], t)
ss, t = ausgabe(uebergabe.wecker, "2041", "2041-Ü20", "Werkzeug", scharf=True)
soll("(6a) Wecker 2041 weiter an die Sitzungen zu 2041", ss == ["session_OLGA", "session_RALF"], t)
ss, t = ausgabe(uebergabe.wecker, "2042", "2042-Ü9", "Disponent", scharf=True)
soll("(6a) Rollen ohne Vorgang (Disponent) unverändert", ss == ["session_KARL"], t)

# (6b) TITEL aus der Startnachricht der eigenen Sitzung
def protokoll(text):
    p = os.path.join(d, "eigen.jsonl")
    open(p, "w").write(json.dumps({"type": "user", "message": {"content": text}}) + "\n"
                       + json.dumps({"type": "user", "message": {"content": "Dein Rufname: Anna (Rolle Figur; zitiert)"}}) + "\n")
    rufname.PROTOKOLL = p
open(B, "w").write(KOPF + OLGA + KARL)
protokoll("Dein Rufname: Britta (Rolle Werkzeug; Titel, Besetzung, Meldung).\n\nWerkzeug …")
z = rufname.titel_zeile("session_EIGEN", "2042", "in Arbeit")
soll("(6b) Britta ohne Besetzung: Name aus der Startnachricht", (z or "").startswith("TITEL Britta – in Arbeit – 2042 – "), z)
open(B, "w").write(KOPF + PAULA)
protokoll("Dein Rufname: Paula (Rolle Kampf; Titel, Besetzung, Meldung).")
z = rufname.titel_zeile("session_EIGEN", "1589.4", "in Arbeit")
soll("(6b) Paula (Kampf) als Arbeitsplaner besetzt: Titel trotzdem", (z or "").startswith("TITEL Paula – in Arbeit – 1589.4"), z)
open(B, "w").write(KOPF + RALF.replace("session_RALF", "session_EIGEN"))
protokoll("Dein Rufname: Ralf (Rolle Prüfer; Titel, Besetzung, Meldung).")
soll("(6b) Ralf (Prüfer) als Werkzeug besetzt: Prüfer-Titel (Teil 7), nicht Werkzeug", (rufname.titel_zeile("session_EIGEN", "2041", "in Arbeit") or "").startswith("TITEL Ralf – Prüfer – in Arbeit – 2041"), rufname.titel_zeile("session_EIGEN", "2041", "in Arbeit"))
open(B, "w").write(KOPF)
protokoll("Hallo ohne Rufname")
z = rufname.titel_zeile("session_EIGEN", "2042", "in Arbeit")
soll("(6b) ohne Startnachricht und Besetzung: nie Platzhalter, laute Warnung", "<Rufname>" not in (z or "") and (z or "").startswith("WARNUNG"), z)
protokoll("Dein Rufname: Britta (Rolle Werkzeug; Titel, Besetzung, Meldung).")
open(B, "w").write(KOPF + OLGA)
soll("(6b) fremde Sitzung (fuer): Name aus der Besetzung, nicht aus der eigenen Startnachricht",
     rufname.titel_zeile("session_OLGA", "2041", "frei", fuer=True) == "TITEL session_OLGA Olga – frei – 2041 – Vorgang 2041"
     or (rufname.titel_zeile("session_OLGA", "2041", "frei", fuer=True) or "").startswith("TITEL session_OLGA Olga – frei – 2041"),
     rufname.titel_zeile("session_OLGA", "2041", "frei", fuer=True))

# (6c) Startrolle (echte Sperren 25.11., ARBEIT-BETRIEB.md Z. 93/95)
BT = os.path.join(d, "docs", "ARBEIT-BETRIEB.md")
open(BT, "w").write("- 21:44 25.11.: Startsperre 21:44 Start Arbeitsplaner, Kampf, Arbeitsplaner, Prüfer (lauf.py, Arbeitsplaner 887 Oda, Kampf 1589.4 Paula, Arbeitsplaner 2029 Rudi, Prüfer 2031 Sven)\n"
                    "- 21:47 25.11.: Startsperre 21:47 Start Arbeitsplaner (lauf.py, Arbeitsplaner 2031 Paula)\n"
                    "- 21:54 25.11.: Startsperre 21:54 Start Werkzeug (lauf.py, Werkzeug 2041 Ralf)\n")
r = rufname.rolle("Paula – 1589.4: Stufe 3 Gegnerverhalten, Figuren in die Arena (25.11., 21:49)", "2026-11-25T20:49:00Z", BT)
soll("(6c) Paula: Sperre mit Nr 1589.4 (Kampf), nicht die jüngere 2031", r == "Kampf", r)
r = rufname.rolle("Ralf – 2041: Prüfer Ü15 Abläufe a–d (25.11., 21:55)", "2026-11-25T20:55:00Z", BT)
soll("(6c) Ralf: „Prüfer“ im Titel vor der Sperre", r == "Prüfer", r)
r = rufname.rolle("Ralf – Prüfer – frei", "2026-11-25T20:55:00Z", BT)
soll("(6c) Prüfer-Titel neu (Teil 7): Prüfer", r == "Prüfer", r)

# (6d) Status nach Frage (Carla 22:38: fragt und baut weiter)
os.environ.pop("BORNIM_SITZUNG")
open(B, "w").write(KOPF + CARLA)
FR = "Frage (Carla) zu Antwort 2042-Ü5: START-Nachricht heute = Ladetext (Kern + Profil) + Auftrag wörtlich. Ich ersetze den wörtlichen Auftrag durch den Verweis."
z = rueckmeldung.titel_zeilen("2042", FR, "", "session_CARLA", "Werkzeug")
soll("(6d) Frage neben Weiterbau: „in Arbeit“", [x for x in z if " – in Arbeit – 2042" in x] and not [x for x in z if "wartet" in x], z)
z = rueckmeldung.titel_zeilen("2042", "Frage (Carla): Ich warte auf die Antwort, vorher baue ich nicht weiter.", "", "session_CARLA", "Werkzeug")
soll("(6d) Frage mit Anhalten: „wartet“", [x for x in z if " – wartet – 2042" in x], z)
z = rueckmeldung.titel_zeilen("2042", "steckt fest: Netz weg", "", "session_CARLA", "Werkzeug")
soll("(6d) steckt fest: „wartet“", [x for x in z if " – wartet – 2042" in x], z)

# (6e) erledigt „Fachkraft starten“ (Kennung der gestarteten Sitzung Pflicht); Test mit echtem Git wie uebergabe_test
import subprocess
o = os.path.join(d, "o.git"); A = os.path.join(d, "a")
def g(*a, cwd=None): return subprocess.run(["git"] + list(a), cwd=cwd, check=True, capture_output=True, text=True).stdout
g("init", "-q", "--bare", "-b", "main", o); g("clone", "-q", o, A); g("checkout", "-q", "-b", "main", cwd=A)
os.makedirs(os.path.join(A, "docs", "vorgang"))
open(os.path.join(A, "docs", "ARBEIT-BESETZUNG.md"), "w").write(KOPF + KARL)
open(os.path.join(A, "docs", "vorgang", "1708.md"), "w").write(
    "# 1708 · Probe\n\n## Übergaben\n\n| Kennung | an | was | seit | Zustand |\n|---|---|---|---|---|\n"
    "| 1708-Ü10 | Disponent | Fachkraft starten: Kampf 1708 | 25.11., 22:00 | offen |\n")
g("add", "-A", cwd=A); g("-c", "user.email=t@t", "-c", "user.name=t", "commit", "-q", "-m", "start", cwd=A); g("push", "-q", "origin", "main", cwd=A)
def vg(*a):
    env = dict(os.environ, BORNIM_WURZEL=A, BORNIM_SITZUNG="session_KARL", BORNIM_JETZT="25.11., 22:05", GIT_AUTHOR_NAME="t",
               GIT_AUTHOR_EMAIL="t@t", GIT_COMMITTER_NAME="t", GIT_COMMITTER_EMAIL="t@t")
    env.pop("BORNIM_OHNE_PUSH", None)
    p = subprocess.run([sys.executable, os.path.join(HIER, "uebergabe.py")] + list(a), env=env, capture_output=True, text=True)
    return p.returncode, p.stdout + p.stderr
vg("annehmen", "1708-Ü10")
rc, t = vg("erledigt", "1708-Ü10")
soll("(6e) erledigt „Fachkraft starten“ ohne Kennung: rot", rc != 0 and "Kennung" in t, (rc, t))
rc, t = vg("erledigt", "1708-Ü10", "session_NEU1")
soll("(6e) erledigt mit Kennung: grün, Kennung in der Zeile", rc == 0 and "ERLEDIGT" in t and "session_NEU1" in open(os.path.join(A, "docs", "vorgang", "1708.md")).read(), (rc, t))

# (9) LIEGT zusammengefasst
import liegt
zs = ["LIEGT 2001 | startbar | 3 Tage | an Disponent: Start (14.2.4)", "LIEGT 2002 | startbar | 2 Tage | an Disponent: Start (14.2.4)",
      "LIEGT 2003 | gebaut | 5 h | an Werkzeug: Prüfer (14.2.6)", "LIEGT 2004 | ruht | 9 Tage | an Arbeitsplaner: ruht ohne Datum (14.2.11)"]
k = liegt.kurz(zs)
soll("(9) eine Zeile statt vier", len(k) == 1, k)
soll("(9) Zahl je Art und Abruf", k and k[0].startswith("LIEGT 4 ") and "startbar 2" in k[0] and "gebaut 1" in k[0] and "ruht 1" in k[0] and "liegt.py" in k[0], k)
soll("(9) Abruf je Art: nur startbar", liegt.nach_art(zs, "startbar") == zs[:2], liegt.nach_art(zs, "startbar"))
soll("(9) ohne LIEGT keine Zeile", liegt.kurz([]) == [])

# (1c) täglich ein voller Lauf (Sokrates 23:00 (3)): erster Lauf ab 7 Uhr mit Kurzform „# bis:“ verlangt alle Seiten
import datetime, lauf
BL = lauf.BERLIN
def bes(stand): return "# Besetzung\n\n**Stand:** %s (lauf.py)\n\n| Rolle | Sitzung | Vorgang | Zweig | seit |\n" % stand
soll("(1c) Stand 06:55, jetzt 07:02 → voller Lauf fällig", lauf.voller_lauf_faellig(bes("26.11., 06:55"), datetime.datetime(2026, 11, 26, 7, 2, tzinfo=BL)))
soll("(1c) Stand gestern 23:50, jetzt 09:00 → fällig", lauf.voller_lauf_faellig(bes("25.11., 23:50"), datetime.datetime(2026, 11, 26, 9, 0, tzinfo=BL)))
soll("(1c) Stand 07:05 (voller Lauf war), jetzt 07:40 → nicht fällig", not lauf.voller_lauf_faellig(bes("26.11., 07:05"), datetime.datetime(2026, 11, 26, 7, 40, tzinfo=BL)))
soll("(1c) Nacht 03:00, Stand 02:40 → nicht fällig", not lauf.voller_lauf_faellig(bes("26.11., 02:40"), datetime.datetime(2026, 11, 26, 3, 0, tzinfo=BL)))
soll("(1c) ohne Stand → fällig (laut statt still)", lauf.voller_lauf_faellig("# Besetzung\n", datetime.datetime(2026, 11, 26, 8, 0, tzinfo=BL)))

# Teil 6 (4) Rufname beim Handstart (Fall Anna 22:15/22:31/22:49, Britta, Carla, Dora gestartet): Seite als JSON wie als Kurzform lesen,
# heutige Startsperren immer dazu; nie ein heute schon vergebener Name
import json as _j
jp = os.path.join(d, "seite.json")
_j.dump({"ccr": {"data": [{"id": "session_B", "title": "Anna – Disponent – Betrieb", "created_at": "2026-11-25T20:37:00Z", "updated_at": "2026-11-25T21:30:00Z", "session_status": "SESSION_STATUS_IDLE"},
                          {"id": "session_C", "title": "Britta – in Arbeit – 2042 – x", "created_at": "2026-11-25T21:16:00Z", "updated_at": "2026-11-25T21:30:00Z", "session_status": "SESSION_STATUS_ARCHIVED"}],
                 "has_more": False}}, open(jp, "w"))
hs = lauf.start_sitzungen([jp])
soll("(6-4) Handstart-Seite als JSON: Titel und created_at gelesen (auch archiviert)", ("Britta – in Arbeit – 2042 – x", "2026-11-25T21:16:00Z") in hs and len(hs) >= 2, hs)
kp = os.path.join(d, "seite.txt"); open(kp, "w").write("session_C | archived | 2026-11-25T21:30:00Z | Britta – in Arbeit – 2042 – x | - | 2026-11-25T21:16:00Z | -\n# bis: 2026-11-24T22:00:00Z\n")
soll("(6-4) Handstart-Seite als Kurzform", ("Britta – in Arbeit – 2042 – x", "2026-11-25T21:16:00Z") in lauf.start_sitzungen([kp]), lauf.start_sitzungen([kp]))

# Teil 7 (Chef 22:43, 22:45 (1); Auftrag Fassung 2, 23:06): Prüfer-Titel, Rolle aus dem Titel, Wecker an freien Prüfer
import guthaben
open(BT, "a").write("- 22:04 25.11.: Startsperre 22:04 Start Arbeitsplaner (lauf.py, Arbeitsplaner 1484 Tanja)\n"
                    "- 22:25 25.11.: Startsperre 22:25 Start Kampf (lauf.py, Kampf 1708 Tanja)\n")
r = rufname.rolle("Tanja – 1708 B: Blut nur bei Berührung (25.11., 22:26)", "2026-11-25T21:26:00Z", BT)
soll("(7) Tanja (Titel „1708 B:“): Sperre mit Nr 1708 → Kampf, nicht Arbeitsplaner 1484", r == "Kampf", r)
soll("(7) titel Prüfer frei", rufname.pruefer_titel("Ralf") == "Ralf – Prüfer – frei")
soll("(7) titel Prüfer in Arbeit", rufname.pruefer_titel("Ralf", "2042", "Disponenten klein") == "Ralf – Prüfer – in Arbeit – 2042 – Disponenten klein")
soll("(7) teile liest Prüfer-Titel", (rufname.teile("Ralf – Prüfer – in Arbeit – 2042 – x") or {}).get("nr") == "2042" and
     (rufname.teile("Ralf – Prüfer – frei") or {}).get("status") == "frei", (rufname.teile("Ralf – Prüfer – in Arbeit – 2042 – x"), rufname.teile("Ralf – Prüfer – frei")))
for t in ("Ralf – Prüfer – frei", "Ralf – Prüfer – in Arbeit – 2042 – x"):
    soll("(7) guthaben.ober_rolle %s → Prüfer" % t, guthaben.ober_rolle("Werkzeug", t) == "Prüfer", guthaben.ober_rolle("Werkzeug", t))
os.environ["BORNIM_SITZUNG"] = "session_EIGEN"
protokoll("Dein Rufname: Ralf (Rolle Prüfer; Titel, Besetzung, Meldung).")
open(B, "w").write(KOPF)
soll("(7) annehmen als Prüfer → „Ralf – Prüfer – in Arbeit – Nr – Betreff“",
     (rufname.titel_zeile("session_EIGEN", "2042", "in Arbeit") or "").startswith("TITEL Ralf – Prüfer – in Arbeit – 2042 – "), rufname.titel_zeile("session_EIGEN", "2042", "in Arbeit"))
soll("(7) ja/nein als Prüfer → „Ralf – Prüfer – frei“", rufname.titel_zeile("session_EIGEN", "2042", "frei") == "TITEL Ralf – Prüfer – frei", rufname.titel_zeile("session_EIGEN", "2042", "frei"))
os.environ.pop("BORNIM_SITZUNG")
z = rueckmeldung.titel_zeilen("2042", "ja. Prüfer Ralf (25.11., 23:20) an 92a094995", "", "session_EIGEN", "Prüfer")
os.environ["BORNIM_SITZUNG"] = "session_EIGEN"
z = rueckmeldung.titel_zeilen("2042", "ja. Prüfer Ralf (25.11., 23:20) an 92a094995", "", "session_EIGEN", "Prüfer")
soll("(7) rueckmeldung ja des Prüfers: eigener Titel frei", "TITEL Ralf – Prüfer – frei" in z, z)
os.environ.pop("BORNIM_SITZUNG")
VD = os.path.join(d, "docs", "vorgang"); os.makedirs(VD, exist_ok=True)
UK = "# x\n\n## Übergaben\n\n| Ü | an | was | seit | Zustand |\n|---|---|---|---|---|\n"
open(os.path.join(VD, "2041.md"), "w").write(UK + "| 2041-Ü15 | Prüfer | prüfen: d | 25.11., 21:40 | angenommen session_GERD bis 25.11., 23:59 |\n")
FREI = "| Prüfer | [Ralf – Prüfer – frei](https://claude.ai/code/session_RFREI) | Betrieb | – | 25.11., 21:55 |\n"
BUSY = "| Prüfer | [Gerd – Prüfer – in Arbeit – 2041 – x](https://claude.ai/code/session_GERD) | 2041 | – | 25.11., 21:00 |\n"
open(B, "w").write(KOPF + KARL + BUSY + FREI)
ss, t = ausgabe(uebergabe.wecker, "2042", "2042-Ü30", "Prüfer", scharf=True)
soll("(7) Wecker an Prüfer: nur der freie (Ralf), nicht Gerd in Arbeit", ss == ["session_RFREI"] and "PRÜFER session_RFREI frei" in t, t)
# (7) frei aus frischer Quelle (Ralf 23:27 Mangel 3): Zustand der Zeilen an den Prüfer in den Vorgangsdateien, nicht der Titel
open(B, "w").write(KOPF + KARL + BUSY)
ss, t = ausgabe(uebergabe.wecker, "2042", "2042-Ü31", "Prüfer", scharf=True)
soll("(7) kein freier Prüfer (Gerd hält 2041-Ü15): START Prüfer für den Aufrufer, kein Wecker an Gerd, keiner an den Disponenten (Mangel 2)",
     "session_GERD" not in t and "START Prüfer" in t and "session_KARL" not in t and ss == [], (ss, t))
open(os.path.join(VD, "2041.md"), "w").write(UK + "| 2041-Ü15 | Prüfer | prüfen: d | 25.11., 21:40 | erledigt 25.11., 22:30 session_GERD |\n")
ss, t = ausgabe(uebergabe.wecker, "2042", "2042-Ü32", "Prüfer", scharf=True)
soll("(7) Gerd meldete ja/nein (Zeile erledigt), Titel noch „in Arbeit“: frei, Wecker an Gerd", ss == ["session_GERD"] and "PRÜFER session_GERD frei" in t, (ss, t))
open(os.path.join(VD, "2042.md"), "w").write(UK + "| 2042-Ü40 | Prüfer | prüfen: x | 25.11., 23:00 | angenommen session_RFREI bis 25.11., 23:59 |\n")
open(B, "w").write(KOPF + KARL + FREI)
ss, t = ausgabe(uebergabe.wecker, "2042", "2042-Ü33", "Prüfer", scharf=True)
soll("(7) Ralf „frei“ im Titel, hält aber 2042-Ü40: nicht frei", ss == [] and "START Prüfer" in t, (ss, t))
os.remove(os.path.join(VD, "2042.md"))
open(os.path.join(VD, "2043.md"), "w").write(UK + "| 2043-Ü1 | Prüfer | prüfen: y | 25.11., 23:00 | offen |\n")
NEU = "| Prüfer | [Hans – Prüfer – in Arbeit – 2043 – y](https://claude.ai/code/session_HANS) | 2043 | – | 25.11., 23:01 |\n"
ALTT = "| Prüfer | [Tanja – 1708 B: Prüfer Blut (25.11., 22:26)](https://claude.ai/code/session_TANJA) | 1708 | – | 25.11., 22:26 |\n"
open(B, "w").write(KOPF + KARL + NEU + ALTT)
ss, t = ausgabe(uebergabe.wecker, "2042", "2042-Ü34", "Prüfer", scharf=True)
soll("(7) Hans eben für 2043 gestartet (Zeile noch offen): nicht frei; Tanja (alter Titel, Rolle Prüfer, keine Zeile): frei, nur ein Wecker",
     ss == ["session_TANJA"] and "session_HANS" not in t, (ss, t))

st = lauf.mit_rufnamen(["START Prüfer | sonnet | e | r | main | Prüfer – 2042: Disponenten klein (25.11., 23:20) | Prüfer\\n\\nprüfen"], [], namen={})
soll("(7) START Prüfer: Titel „Name – Prüfer – in Arbeit – 2042 – Disponenten klein“", " – Prüfer – in Arbeit – 2042 – Disponenten klein | " in st[0], st)

st = lauf.mit_rufnamen(["START Werkzeug | sonnet | e | r | main | Werkzeug – 2042: Teil 7 nachbessern (26.11., 07:06) | Werkzeug\\n\\nlies"], [], namen={})
soll("(6-2) START Fachkraft: Titel gleich „Name – in Arbeit – 2042 – Teil 7 nachbessern“", " – in Arbeit – 2042 – Teil 7 nachbessern | " in st[0], st)
st = lauf.mit_rufnamen(["START Kampf | opus | e | r | main | Kampf – 1708 B: Blut nur bei Berührung (26.11., 07:06) | Kampf\\n\\nlies"], [], namen={})
soll("(6-2) START Kampf 1708 B: Titel „Name – in Arbeit – 1708 – B: Blut …“ nie ohne Nr", " – in Arbeit – 1708" in st[0].split(" | ")[5], st)

# Teil 7 (1) (Antwort 2042-Ü27, 23:37): je Fachprofil der eine Satz, Quelle 1727-muster gleich dem Profil; Disponent.md Prüferstart
import ladesumme
SATZ = "Nach gebaut tust du jede Zeile der Ausgabe."
QUELLE = {p: n for n, (q, p, _) in ladesumme.TEILE.items() if p}
for p in uebergabe.FACHPROFILE + ["Disponent"]:
    pt = ladesumme.messtext(open(os.path.join(HIER, "..", "docs", "profile", p + ".md"), encoding="utf-8").read())
    if p != "Disponent": soll("(7p) Profil %s: Satz „%s“ genau einmal" % (p, SATZ), pt.count(SATZ) == 1)
    soll("(7p) Profil %s gleich Quelle 1727-muster" % p, ladesumme.entwurf_text(QUELLE[p]) == pt)
dt = open(os.path.join(HIER, "..", "docs", "profile", "Disponent.md"), encoding="utf-8").read()
soll("(7p) Disponent.md: „Sitzungen startest nur du“ mit Ausnahme Prüfer", "Sitzungen startest nur du, außer dem Prüfer" in dt)

print("LAUF2042B %d Fehler" % fehl)
sys.exit(1 if fehl else 0)
