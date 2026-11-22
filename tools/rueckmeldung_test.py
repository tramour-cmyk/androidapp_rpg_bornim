# 1763: Rückmeldung in die Vorgangsdatei, Obergrenzen A (zweites „nein, Auftrag“, dritter abgelehnter Auftrag) und B (zweites
# „steckt fest“) → ruht, beim Chef; „steckt fest“, „Frage“, „wirkt nein“ → Zeile an Sokrates, lauf.py startet oder weckt ihn (C).
# Echtes Git mit nacktem origin. Aufruf: python3 tools/rueckmeldung_test.py
import os, re, subprocess, sys, tempfile
HIER = os.path.dirname(os.path.abspath(__file__))
d = tempfile.mkdtemp(); o = os.path.join(d, "origin.git"); A = os.path.join(d, "a")
def g(*a, cwd=None): return subprocess.run(["git"] + list(a), cwd=cwd, check=True, capture_output=True, text=True).stdout
g("init", "-q", "--bare", "-b", "main", o)
g("clone", "-q", o, A); g("config", "user.email", "t@t", cwd=A); g("config", "user.name", "t", cwd=A); g("checkout", "-q", "-b", "main", cwd=A)
os.makedirs(os.path.join(A, "docs")); os.makedirs(os.path.join(A, "tools"))
for f in ("rueckmeldung.py", "chefwort.py", "uebergabe.py", "startbar.py", "bereiche.py", "vorgang.py"):
    os.symlink(os.path.join(HIER, f), os.path.join(A, "tools", f))
open(os.path.join(A, "docs", "LISTE-VORGAENGE.md"), "w").write(
    "# Vorgangsliste\n\n| Nr. | Titel | Besitzer | Kl. | Stand | wartet auf | Zweig | Build | Bereich | Kosten |\n|---|---|---|---|---|---|---|---|---|---|\n"
    "| 9001 | Zwerg auf dem Tisch | Tom | M | startbar | – | – | – | E Welt | – |\n"
    "| 9002 | Schatten im Wald | Spike | M | startbar | – | – | – | T Technik | – |\n"
    "| 9003 | Höhlenklang | Jerry | M | startbar | – | – | – | K Klang | – |\n"
    "| 9005 | Treppe knarrt | Tom | K | startbar | – | – | – | E Welt | – |\n"
    "| 9006 | Treppe zu steil | Tom | K | startbar | – | – | – | E Welt | – |\n"
    "| 9011 | Kerze im Keller | Tom | K | startbar | – | – | – | E Welt | – |\n"
    "| 9012 | Kerze im Hof | Tom | K | startbar | – | – | – | E Welt | – |\n"
    "| 9013 | Nachtstopp-Haken | Spike | K | startbar | – | – | – | B Werkzeuge | – |\n"
    "| 9014 | Fackel im Hof | Tom | K | startbar | – | – | – | E Welt | – |\n"
    "| 9015 | Fackel im Keller | Jerry | K | startbar | – | – | – | E Welt | – |\n"
    "| 9016 | Tür im Keller | Tom | K | startbar | – | – | – | E Welt | – |\n")
open(os.path.join(A, "docs", "ARBEIT-BETRIEB.md"), "w").write("**Nächste freie Vorgangsnummer: 9100**\n")
open(os.path.join(A, "docs", "ARBEIT-BESETZUNG.md"), "w").write(
    "| Rolle | Sitzung | Vorgang | Zweig | seit |\n|---|---|---|---|---|\n| Prüfer | [P](https://claude.ai/code/session_PR1) | – | – | 21.11. |\n")
g("add", "-A", cwd=A); g("commit", "-q", "-m", "start", cwd=A); g("push", "-q", "origin", "main", cwd=A)
ENV = dict(os.environ, BORNIM_WURZEL=A, BORNIM_JETZT="21.11., 20:30", GIT_AUTHOR_NAME="t", GIT_AUTHOR_EMAIL="t@t",
           GIT_COMMITTER_NAME="t", GIT_COMMITTER_EMAIL="t@t", BORNIM_SITZUNG="session_PR1")
ENV.pop("BORNIM_OHNE_PUSH", None); ENV.pop("BORNIM_CHEFWORT_AN", None)
fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else zeige))
def datei(nr):
    g("fetch", "-q", "origin", cwd=A)
    try: return g("show", "origin/main:docs/vorgang/%s.md" % nr, cwd=A)
    except subprocess.CalledProcessError: return ""
def lauf(*a, zeit="21.11., 20:30"):
    p = subprocess.run([sys.executable, os.path.join(A, "tools", "vorgang.py")] + list(a), env=dict(ENV, BORNIM_JETZT=zeit), capture_output=True, text=True, cwd=A)
    return p.returncode, p.stdout + p.stderr
vg = lauf
os.environ.update(ENV)
sys.path.insert(0, os.path.join(A, "tools"))
import rueckmeldung as rm

# 1 Erstes Wort
for t, w in [("nein, Auftrag: Prüffrage am Ziel vorbei", {"nein, Auftrag"}), ("Nein. Bart fehlt. steckt fest: Handwerksregel Bart", {"nein", "steckt fest"}),
             ("Beleg fehlt", {"Beleg fehlt"}), ("wirkt nein", {"wirkt nein"}), ("Frage: welcher Text?", {"Frage"}), ("ja", {"ja"}), ("fertig, Commit abc", {"fertig"}),
             ("„steckt fest“ beim Licht", {"steckt fest"}), ("neinsager", set()),
             ("**Spike** [21.11., 20:41] nein, Auftrag: x", {"nein, Auftrag"}), ("Spike [21.11., 20:41]: steckt fest", {"steckt fest"}),
             ("**Jerry** [21.11., 20:41]\nnein", {"nein"}), ("**Tom**: Frage zum Licht", {"Frage"}), ("Tom 2 [21.11., 20:41] fertig", {"fertig"}),
             ("Nein [Hof] steckt fest", {"nein", "steckt fest"}),
             ("**nein, Auftrag**: falsch", {"nein, Auftrag"}), ("**steckt fest**: Licht", {"steckt fest"}), ("**Frage:** welcher Text?", {"Frage"}),
             ("**Nein.** steckt fest", {"nein", "steckt fest"}), ("**Frage** zum Licht", {"Frage"}), ("**Spike** [21.11.2026, 20:41] nein", {"nein"})]:
    soll("Wort %r" % t[:25], rm.worte(t) == w, rm.worte(t))

# 2 B: erstes „steckt fest“ an Sokrates, zweites an den Chef (ruht)
rc, out = lauf("rueckmeldung", "9001", "steckt fest: Licht im Keller, Regel fehlt")
soll("1. steckt fest → Sokrates", rc == 0 and "OFFEN 9001-Ü1 an Sokrates" in out and "KEINE SITZUNG Sokrates" in out, out)
t = datei("9001")
soll("Rückmeldung wörtlich mit Zeit und Sitzung", "- **21.11., 20:30**, Prüfer (`session_PR1`):\n> steckt fest: Licht im Keller, Regel fehlt\n" in t, t)
soll("Zeile an Sokrates (C)", "| 9001-Ü1 | Sokrates | steckt fest: Rückmeldung 21.11., 20:30 von Prüfer lesen (1763 C); gelöst: `vorgang.py warte 9001 –` | 21.11., 20:30 | offen |" in t, t)
def liste_origin():
    g("fetch", "-q", "origin", cwd=A); return g("show", "origin/main:docs/LISTE-VORGAENGE.md", cwd=A)
soll("1800: steckt fest, wartet auf Sokrates, gepusht", "| 9001 | Zwerg auf dem Tisch | Tom | M | startbar, steckt fest | Sokrates |" in liste_origin(), out)
rc, out = lauf("rueckmeldung", "9001", "nein: Keller zu hell. steckt fest: wieder Licht", zeit="21.11., 21:00")
t = datei("9001")
soll("2. steckt fest → ruht, an den Chef", "OFFEN 9001-Ü2 an Sokrates (Obergrenze B: 2. „steckt fest“ → ruht, beim Chef)" in out, out)
soll("Zustand in der Vorgangsdatei", "Zustand: ruht, beim Chef seit 21.11., 21:00 (Obergrenze B: 2. „steckt fest“, 1763)" in t, t)
soll("Zeile sagt: an den Chef, nicht selbst lösen", "| 9001-Ü2 | Sokrates | an den Chef: Chefsache anlegen, nicht selbst lösen" in t, t)
soll("Liste: ruht, beim Chef", "| 9001 | Zwerg auf dem Tisch | Tom | M | ruht, beim Chef (Obergrenze B) |" in open(os.path.join(A, "docs", "LISTE-VORGAENGE.md")).read())
soll("1800: ruht gepusht", "| 9001 | Zwerg auf dem Tisch | Tom | M | ruht, beim Chef (Obergrenze B) | Sokrates |" in liste_origin(), out)
rc, out = lauf("rueckmeldung", "9001", "steckt fest: noch mal", zeit="21.11., 21:10")
soll("danach nur eingetragen", "EINGETRAGEN 9001: ruht schon, nur eingetragen" in out and datei("9001").count("| 9001-Ü") == 2, out)

# 3 A: zweites „nein, Auftrag“
rc, out = lauf("rueckmeldung", "9002", "nein, Auftrag: Prüffrage fragt am Ziel vorbei")
soll("1. nein, Auftrag → Arbeitsplaner", "OFFEN 9002-Ü1 an Arbeitsplaner" in out, out)
rc, out = lauf("rueckmeldung", "9002", "nein, Auftrag: Text fehlt in der Quelle", zeit="21.11., 20:40")
soll("2. nein, Auftrag → ruht, Sokrates an den Chef", "OFFEN 9002-Ü2 an Sokrates (Obergrenze A: 2. „nein, Auftrag“ → ruht, beim Chef)" in out, out)

# 4 A: dritter abgelehnter Auftrag; „Beleg fehlt“ zählt nicht; 1739 Rückläufer an denselben Macher
def tom(*a, zeit):
    return lauf(*(list(a) + ["--sitzung", "Tom"]), zeit=zeit)
rc, out = tom("rueckmeldung", "9003", "fertig: Hall 1,5 s, Commit 1a2b3c4d", zeit="21.11., 20:30")
soll("fertig mit Commit → Prüfer", "OFFEN 9003-Ü1 an Prüfer" in out and "WECKER session_PR1" in out, out)
for i, (t_, z) in enumerate([("nein: Hall zu lang", "20:31"), ("Beleg fehlt", "20:32"), ("nein: Hall noch zu lang", "20:33")]):
    rc, out = lauf("rueckmeldung", "9003", t_, zeit="21.11., " + z)
t = datei("9003")
soll("1. nein → derselbe Macher mit Satz", "| 9003-Ü2 | Tom | Rückläufer (nein des Prüfers, Rückmeldung 21.11., 20:31 von Prüfer): „nein: Hall zu lang“;" in t, t)
soll("Beleg fehlt → derselbe Macher", "| 9003-Ü3 | Tom | Rückläufer (Beleg fehlt des Prüfers" in t, t)
soll("1766 Laufbremse: zweites nein → steckt fest an Sokrates", "| 9003-Ü4 | Sokrates | steckt fest (Laufbremse, 2. Nein; Chef 19.11., 13:02): Rückmeldung 21.11., 20:33 von Prüfer lesen (1766) |" in t and t.count("Laufbremse") == 1, t)
rc, out = tom("rueckmeldung", "9003", "fertig", zeit="21.11., 20:34")
soll("fertig ohne Commit → Disponent", "OFFEN 9003-Ü5 an Disponent" in out and "„fertig“ ohne Commit" in datei("9003") and "Zustand: ruht" not in datei("9003"), datei("9003") + out)
rc, out = lauf("rueckmeldung", "9003", "nein: Hall immer noch", zeit="21.11., 20:35")
soll("drittes nein → ruht", "Obergrenze A: 3. abgelehnter Auftrag → ruht, beim Chef" in out, out)
rc, out = lauf("rueckmeldung", "9003", "nein: Hall immer noch", zeit="21.11., 20:35")
soll("gleiche Rückmeldung zur gleichen Minute: einmal", "schon eingetragen" in out and datei("9003").count("Hall immer noch") == 1, out)
rc, out = lauf("rueckmeldung", "9006", "nein: Stufe zu hoch", zeit="21.11., 20:36")
soll("nein ohne fertig: Disponent, Macher unbekannt", "OFFEN 9006-Ü1 an Disponent" in out and "Macher unbekannt" in datei("9006"), out)
rc, out = lauf("rueckmeldung", "9006", "Hinweis: Geländer fehlt auch", zeit="21.11., 20:37")
soll("Hinweis → Disponent wie Eingang", "OFFEN 9006-Ü2 an Disponent" in out and "wie einen Eingang" in datei("9006"), out)
rc, out = lauf("rueckmeldung", "9006", "Notiz ohne Signalwort", zeit="21.11., 20:38")
soll("ohne Signalwort: nur eingetragen", out.startswith("EINGETRAGEN 9006: eingetragen, kein Signalwort"), out)

# 5 Chefworte und Rückmeldungen bleiben getrennt
import chefwort as cw
cw.eintragen("9003", "Hall kürzer, 1,2 s", "21.11., 20:50", "Sokrates")
t = datei("9003")
soll("Chefwort im eigenen Abschnitt", "Hall kürzer" in rm.uebergabe.abschnitt(t, "Chefworte") if hasattr(rm, "uebergabe") else "Hall kürzer" in rm.ue.abschnitt(t, "Chefworte"), t)
soll("Rückmeldungen ohne Chefwort", "Hall kürzer" not in rm.ue.abschnitt(t, "Rückmeldungen") and rm.zaehlen(t)["nein"] == 3, t)
soll("Übergaben bleiben unten", t.rstrip().endswith("| offen |"), t)

# 5a 1739 (7.1, F3): Wiederholungswächter auch auf jedes Nein
rc, out = lauf("rueckmeldung", "9002", "nein: Treppe im Turm wirft keinen Schatten")
liste = open(os.path.join(A, "docs", "LISTE-VORGAENGE.md"), encoding="utf-8").read()
soll("1887: Nein mit Stichwort ändert die Liste nicht", rc == 0 and "Systemlösung? Treppe" not in liste and "LISTE docs/LISTE-VORGAENGE.md geändert" not in out
     and not g("status", "--porcelain", "--", "docs", cwd=A).strip(), (out, g("status", "--porcelain", cwd=A)))
soll("1887: Zeile an den Disponenten mit Befehl für Systemlösung? Treppe", re.search(r"\| 9002-Ü\d+ \| Disponent \| Wiederholungswächter \(654, 1887\): Stichwort „Treppe“.*vorgang.py neu \"Systemlösung\? Treppe: .*\" \"[^\"]+\" K Sokrates", datei("9002")), (out, datei("9002")[-600:]))
g("checkout", "-q", "--", "docs", cwd=A); g("pull", "-q", "origin", "main", cwd=A)
rc, out = lauf("rueckmeldung", "9007", "ja: Treppe passt")
soll("Ja ohne Wächter, an den Disponenten", rc == 0 and "Systemlösung" not in out and "an Disponent" in out and "an den Chef vorlegen" in datei("9007"), out)

# 6 C: lauf.py startet oder weckt Sokrates
sys.argv = [sys.argv[0]]
sys.path.insert(0, HIER)
import lauf
g("pull", "-q", "origin", "main", cwd=A)
aus = []
z = lauf.sokrates_zeilen(aus, {}, set(), docs=os.path.join(A, "docs"))
soll("offene Zeilen an Sokrates gefunden", [k for k, _ in z] == ["9001-Ü1", "9001-Ü2", "9002-Ü2", "9003-Ü4", "9003-Ü6"], z)
soll("keine Sitzung: START Sokrates", len(aus) == 1 and aus[0].startswith("START Sokrates |") and "9001-Ü2 an den Chef" in aus[0] and "\n" not in aus[0], aus)
soll("1801: Titel mit Vorgangsnummer der ersten Zeile", "| Sokrates – 9001: offene Zeilen (1763 C, " in aus[0], aus)
gesperrt = []; aus = []; lauf.sokrates_zeilen(aus, {}, set(), docs=os.path.join(A, "docs"), sperre=gesperrt.append)
soll("1801: Startsperre mit Nummer", gesperrt == ["9001"], gesperrt)
so = {"id": "session_SOK", "_info": (0, True, 0), "updated_at": "2026-11-21T19:00:00Z", "created_at": "2026-11-21T18:00:00Z", "context_usage": {"used_tokens": 50000}}
aus = []; lauf.sokrates_zeilen(aus, {"Sokrates": [so]}, set(), docs=os.path.join(A, "docs"))
soll("Sokrates läuft, klein: WEITER", len(aus) == 1 and aus[0].startswith("WEITER session_SOK | Sokrates | 1763 C | "), aus)
aus = []; lauf.sokrates_zeilen(aus, {"Sokrates": [dict(so, context_usage={"used_tokens": 900000})]}, set(), docs=os.path.join(A, "docs"))
soll("Sokrates läuft, groß: NICHTS", len(aus) == 1 and aus[0].startswith("NICHTS Sokrates: 5 offene"), aus)
aus = ["START Sokrates | opus | env | repo | main | Sokrates – Stellungnahme (x) | Sokrates\\n\\nStellungnahme …"]
lauf.sokrates_zeilen(aus, {}, set(), docs=os.path.join(A, "docs"))
soll("schon eine Sokrates-Zeile: angehängt, nie zwei", len(aus) == 1 and "1763 C" in aus[0], aus)
gesperrt = []; aus = ["START Sokrates | opus | env | repo | main | Sokrates – Stellungnahme (22.11., 07:50) | Sokrates\\n\\nStellungnahme …"]
lauf.sokrates_zeilen(aus, {}, set(), docs=os.path.join(A, "docs"), sperre=gesperrt.append)
soll("1807: Stellungnahme-START mit Nummer im Titel", "| Sokrates – 9001: offene Zeilen und Stellungnahme (1763 C, 22.11., 07:50) | " in aus[0] and lauf.nummer_aus_titel(aus[0].split(" | ")[5]) == "9001", aus)
soll("1807: Startsperre mit Nummer auch beim Anhängen", gesperrt == ["9001"], gesperrt)
gesperrt = []; aus = ["WEITER session_SOK | Sokrates | Stellungnahme | Stellungnahme …"]
lauf.sokrates_zeilen(aus, {}, set(), docs=os.path.join(A, "docs"), sperre=gesperrt.append)
soll("1807: WEITER bleibt ohne neue Sperre", gesperrt == [] and "1763 C" in aus[0], (gesperrt, aus))

# 7 1739 F4 (1): offene Zeilen an andere (Arbeitsplaner = Ford bis zur Umschaltung); Stand vor der Umschaltung auch an der Kopie mit tools/1727-SCHARF
_scharf = lauf.ist_scharf; lauf.ist_scharf = lambda: False
aus = []; je = lauf.uebergabe_zeilen(aus, {}, set(), docs=os.path.join(A, "docs"))
soll("Arbeitsplaner-Zeilen an Ford", "Arbeitsplaner" in je and any(z.startswith("NACHRICHT Ford | - | Offene Zeilen an Arbeitsplaner") for z in aus) and not any("Sokrates" in z.split("|")[0] for z in aus), (je, aus))
soll("Disponent bis zur Umschaltung Ford", any(z.startswith("NACHRICHT Ford | - | Offene Zeilen an Disponent") for z in aus), aus)
soll("Prüfer bis zur Umschaltung Diogenes (keine Sitzung: Ford)", any("keine Sitzung Diogenes" in z and "Offene Zeilen an Prüfer" in z for z in aus), aus)
aus = []; lauf.uebergabe_zeilen(aus, {}, set(), docs=os.path.join(A, "docs"), start=lambda r, nr, t: gerufen0.append(r) or True) if (gerufen0 := []) == [] else None
soll("Prüfer ohne Sitzung: Start Diogenes", "Diogenes" in gerufen0 and "Tom" in gerufen0, gerufen0)
lauf.ist_scharf = _scharf

# 8 1739 Befund 1: Empfänger ohne Sitzung starten (start-Rückruf), sonst Ford; Fristen je Lauf
rc, out = vg("uebergabe", "9005", "Tom", "Treppe im Turm prüfen")
soll("Zeile an Tom angelegt", rc == 0 and "9005-Ü1" in datei("9005"), out)
g("pull", "-q", "origin", "main", cwd=A)
gerufen = []
aus = []; lauf.uebergabe_zeilen(aus, {}, set(), docs=os.path.join(A, "docs"), start=lambda r, nr, t: gerufen.append((r, nr)) or True)
soll("Tom ohne Sitzung: start gerufen, keine NACHRICHT Ford für Tom", ("Tom", "9003") in gerufen and not any("keine Sitzung Tom" in z for z in aus), (gerufen, aus))
aus = []; lauf.uebergabe_zeilen(aus, {}, set(), docs=os.path.join(A, "docs"), start=lambda r, nr, t: False)
soll("start kann nicht: NACHRICHT Ford „keine Sitzung Tom“", any(z.startswith("NACHRICHT Ford | - | keine Sitzung Tom") for z in aus), aus)
tom = {"id": "session_TOM", "_info": (0, False, 30), "updated_at": "2026-11-21T19:00:00Z", "created_at": "2026-11-21T18:00:00Z", "title": "Tom – 9005"}
aus = []; lauf.uebergabe_zeilen(aus, {"Tom": [tom]}, set(), docs=os.path.join(A, "docs"), start=lambda r, nr, t: (r == "Tom" and gerufen.append("falsch")) or True)
soll("Tom mit Sitzung: NACHRICHT an sie, kein Start", any(z.startswith("NACHRICHT Tom | session_TOM | ") for z in aus) and "falsch" not in gerufen, aus)
rc, out = subprocess.run([sys.executable, os.path.join(A, "tools", "vorgang.py"), "annehmen", "9005-Ü1", "--frist", "5"], env=dict(ENV, BORNIM_SITZUNG="session_TOM"), capture_output=True, text=True, cwd=A).returncode, ""
soll("Tom nimmt an (Frist 5 Min.)", rc == 0 and "angenommen session_TOM" in datei("9005"), datei("9005"))
seite = os.path.join(d, "seite.txt")
open(seite, "w").write("session_TOM | working | 2026-11-21T19:30:00Z | Tom – 9005 | - | 2026-11-21T18:00:00Z\n# has_more: nein\n")
os.environ["BORNIM_JETZT"] = "21.11., 20:50"
aus = []; frei = lauf.fristen_runde(aus, [seite], docs=os.path.join(A, "docs"))
soll("Frist ab, Halter arbeitet: bleibt angenommen", frei == [] and "angenommen session_TOM" in datei("9005") and not aus, (frei, aus))
open(seite, "w").write("session_TOM | idle | 2026-11-21T19:30:00Z | Tom – 9005 | - | 2026-11-21T18:00:00Z\n# has_more: nein\n")
aus = []; frei = lauf.fristen_runde(aus, [seite], docs=os.path.join(A, "docs"))
soll("Frist ab, Halter ruht: wieder offen, Zeile NICHTS", frei == ["9005-Ü1"] and "| offen (wieder 1) |" in datei("9005") and aus and aus[0].startswith("NICHTS Übergabe: 9005-Ü1 wieder offen"), (frei, aus, datei("9005")))
# 1904 (D340.2): „steckt fest“ von Hand (vorgang.py offen --sitzungen) geschrieben; Schreiben an Sokrates scheitert → nächster Lauf holt nach
os.environ["BORNIM_JETZT"] = "21.11., 20:51"
rc = subprocess.run([sys.executable, os.path.join(A, "tools", "vorgang.py"), "annehmen", "9005-Ü1", "--frist", "5"], env=dict(ENV, BORNIM_SITZUNG="session_TOM", BORNIM_JETZT="21.11., 20:51"), capture_output=True, text=True, cwd=A).returncode
p = subprocess.run([sys.executable, os.path.join(A, "tools", "vorgang.py"), "offen", "--sitzungen", seite], env=dict(ENV, BORNIM_SITZUNG="session_DISP", BORNIM_JETZT="21.11., 21:00"), capture_output=True, text=True, cwd=A)
soll("von Hand: steckt fest geschrieben, keine Zeile an Sokrates", rc == 0 and "| steckt fest (Frist abgelaufen" in datei("9005") and "| Sokrates | steckt fest: Übergabe 9005-Ü1" not in datei("9005"), (p.stdout, datei("9005")))
os.environ["BORNIM_JETZT"] = "21.11., 21:01"
import uebergabe as _ue4
_ad = _ue4.atomar_dateien
def _kaputt(*a, **k): raise _ue4.Fehler("origin/main nicht erreichbar: Probe")
_ue4.atomar_dateien = _kaputt
aus = []; lauf.fristen_runde(aus, [seite], docs=os.path.join(A, "docs"))
_ue4.atomar_dateien = _ad
soll("Schreiben scheitert: WARNUNG, nächster Lauf holt nach", any(z.startswith("WARNUNG Übergabe 9005-Ü1 steckt fest") and "nächster Lauf" in z for z in aus) and "| Sokrates | steckt fest: Übergabe 9005-Ü1" not in datei("9005"), aus)
aus = []; lauf.fristen_runde(aus, [seite], docs=os.path.join(A, "docs"))
t = datei("9005")
soll("nächster Lauf: Zeile an Sokrates nachgeholt", any(z.startswith("NICHTS Übergabe: 9005-Ü1 steckt fest, Zeile 9005-Ü2 an Sokrates") for z in aus) and "| 9005-Ü2 | Sokrates | steckt fest: Übergabe 9005-Ü1 an Tom zweimal ohne Ergebnis (Frist abgelaufen;" in t, (aus, t))
soll("im selben Commit: Liste steckt fest, wartet auf Sokrates", "| 9005 | Treppe knarrt | Tom | K | startbar, steckt fest | Sokrates |" in liste_origin()
     and set(g("show", "--name-only", "--format=", "origin/main", cwd=A).split()) == {"docs/vorgang/9005.md", "docs/LISTE-VORGAENGE.md"}, liste_origin())
aus = []; lauf.fristen_runde(aus, [seite], docs=os.path.join(A, "docs"))
soll("dritter Lauf: keine zweite Zeile an Sokrates", datei("9005").count("| Sokrates | steckt fest: Übergabe 9005-Ü1") == 1 and not any("9005" in z for z in aus), aus)
g("pull", "-q", "origin", "main", cwd=A)
os.environ["BORNIM_JETZT"] = "21.11., 20:30"
import auftrag as _af
ad = os.path.join(d, "adocs"); os.makedirs(os.path.join(ad, "vorgang"))
soll("ohne Vorgangsdatei: kein Auftrag; M? braucht keinen", lauf.auftrag_fehlt("9001", ad) == "kein Auftrag" and lauf.auftrag_fehlt("M?", ad) is None)
open(os.path.join(ad, "vorgang", "9001.md"), "w").write("# Vorgang 9001\n\n## Auftrag (21.11., 20:00)\n\n" + _af.vorlage("9001", "x"))
soll("leere Vorlage: Auftrag ungültig", (lauf.auftrag_fehlt("9001", ad) or "").startswith("Auftrag: Feld 1"))
open(os.path.join(ad, "vorgang", "9001.md"), "a").write("\n## Auftrag (21.11., 20:30)\n\nAuftrag 9001\n\n" + "\n".join("%d. **%s:** etwas Inhalt hier" % (i, f) for i, f in enumerate(_af.FELDER, 1)) + "\n\n## Übergaben\n\nx\n")
soll("jüngster Auftrag gültig: Start erlaubt", lauf.auftrag_fehlt("9001", ad) is None)
soll("Archivschutz: 1 Min. bis zur Umschaltung, scharf 15 Min. (1739, 7.1)", lauf.schutz_min(False) == 1 and lauf.schutz_min(True) == 15)

# 1795: „Befunde: n“ des Testers → Disponent (ohne Nummer anlegen), je Befund mit Nummer Rückläufer an den Arbeitsplaner
soll("Wort Befunde", rm.worte("Befunde: 2") == {"Befunde"} and rm.worte("**Tester** [21.11., 22:00] Befunde: 0") == {"Befunde"} and rm.worte("Befunde ohne Zahl") == set())
_bt = "Befunde: 2\n- Fehler, Keller, Bildrate 7 statt 9, Messung t301, Nr. 1484\n- Lücke, Hof, Tür ohne Klang, Film t301\n\nAbnahmeliste\n- 1: erfüllt\nHinweis: Text klein"
soll("befunde: zwei Zeilen, Nummer nur bei der ersten", rm.befunde(_bt) == (2, [("Fehler, Keller, Bildrate 7 statt 9, Messung t301, Nr. 1484", "1484"), ("Lücke, Hof, Tür ohne Klang, Film t301", None)]), rm.befunde(_bt))
soll("befunde: Nummer als letztes Feld", rm.befunde("Befunde: 1\n1. Rückschritt, Dorf, Gras fehlt, Bild, 1566")[1][0][1] == "1566")
rc, out = vg("rueckmeldung", "9077", _bt, zeit="21.11., 22:00")
t = datei("9077")
soll("Befunde: Zeile an den Disponenten mit Befund ohne Nummer", rc == 0 and re.search(r"\| 9077-Ü\d+ \| Disponent \| Befunde: 2 \(Befunde des Testers zu 9077[^|]*\); ohne Nummer je Befund einen Vorgang anlegen: Lücke, Hof", t), (out, t[-600:]))
soll("Befunde: Rückläufer zu 1484 an den Arbeitsplaner", re.search(r"\| 9077-Ü\d+ \| Arbeitsplaner \| Rückläufer zu 1484 \(Befunde des Testers", t) and "Hinweis: Text klein" not in t.split("## Übergaben")[-1], t[-600:])
_n = [z for z in t.splitlines() if z.startswith("| 9077-Ü")]
soll("Befunde: Kennungen fortlaufend", len({z.split(" | ")[0] for z in _n}) == len(_n), _n)
rc, out = vg("rueckmeldung", "9077", "Befunde: 0", zeit="21.11., 22:10")
soll("Befunde: 0 → nur Disponent, nichts anzulegen", "Befunde: 0 (Befunde des Testers zu 9077" in datei("9077") and "nichts anzulegen" in datei("9077"), out)

# 1873 (Lauf 3 Prüfer-2 Lücke 1): „nein … steckt fest“ → Sokrates und die Mängelsätze an denselben Macher
vg("rueckmeldung", "9011", "fertig, Commit abc1234, Bild t301", "--sitzung", "Tom", zeit="21.11., 22:20")
rc, out = vg("rueckmeldung", "9011", "nein: Zahl und Quelle fehlen. steckt fest: wie zuvor", zeit="21.11., 22:30")
t = datei("9011")
soll("1873: nein … steckt fest → erste Zeile an Sokrates", re.search(r"\| 9011-Ü2 \| Sokrates \| steckt fest: Rückmeldung", t) and "OFFEN 9011-Ü2 an Sokrates" in out, (out, t[-700:]))
soll("1873: Mängelsätze auch an den Macher (Tom), wartet auf Sokrates", re.search(r"\| 9011-Ü3 \| Tom \| Rückläufer \(nein des Prüfers, steckt fest.*Zahl und Quelle fehlen.*erst nach Sokrates", t), t[-700:])
soll("1873: zweite Zeile genannt (Wecker)", "OFFEN 9011-Ü3 an Tom" in out, out)
soll("1873: Liste steckt fest, wartet auf Sokrates", "| 9011 | Kerze im Keller | Tom | K | startbar, steckt fest | Sokrates |" in liste_origin(), out)
rc, out = vg("rueckmeldung", "9012", "steckt fest: Regel fehlt", zeit="21.11., 22:31")
soll("1873: steckt fest ohne nein: nur Sokrates", "| 9012-Ü1 | Sokrates |" in datei("9012") and "9012-Ü2" not in datei("9012"), datei("9012")[-500:])
# 1873 (Lücke 3): „Hinweis: Prüffrage fehlt“ an den Arbeitsplaner
rc, out = vg("rueckmeldung", "9012", "Hinweis: Prüffrage fehlt: Kerze flackert, keine Frage dazu", zeit="21.11., 22:32")
soll("1873: Hinweis Prüffrage fehlt → Arbeitsplaner", re.search(r"\| 9012-Ü2 \| Arbeitsplaner \| Hinweis Prüffrage fehlt", datei("9012")) and "an Arbeitsplaner" in out, (out, datei("9012")[-500:]))
rc, out = vg("rueckmeldung", "9012", "**Prüfer** [21.11., 22:33] Hinweis: Prüffragen fehlen zur Tür", zeit="21.11., 22:33")
soll("1873: mit Stempel und Mehrzahl ebenso", re.search(r"\| 9012-Ü3 \| Arbeitsplaner \|", datei("9012")), datei("9012")[-400:])
# 1877 (Lauf 3 Disponent L9, Soll D1): Hinweis des Disponenten → Besitzer und Sokrates, nicht an sich selbst
rc, out = vg("rueckmeldung", "9013", "Hinweis: Haken kennt die entschiedene Ausnahme 1784 A nicht, Start 4/8", "--sitzung", "Ford", zeit="21.11., 22:40")
t = datei("9013")
soll("1877: Hinweis des Disponenten → Besitzer (Spike)", re.search(r"\| 9013-Ü1 \| Spike \| Hinweis des Disponenten .*1784 A", t) and "OFFEN 9013-Ü1 an Spike" in out, (out, t[-600:]))
soll("1877: dazu Zeile Hinweis an Sokrates", re.search(r"\| 9013-Ü2 \| Sokrates \| Hinweis \(.*an Spike weitergegeben", t), t[-600:])
soll("1877: keine Zeile an den Disponenten", "| Disponent |" not in t, t[-600:])
rc, out = vg("rueckmeldung", "9013", "Hinweis: Text klein", "--sitzung", "Disponent", zeit="21.11., 22:41")
soll("1877: auch unter dem neuen Profilnamen", re.search(r"\| 9013-Ü3 \| Spike \|", datei("9013")), datei("9013")[-400:])

# 1888 (Lauf 3 Prüfer-1 L9): „fertig“ einer Sitzung ohne Besetzungszeile („unbekannt“) → Rückläufer trotzdem an die Fachkraft
def lauf_als(sid, *a, zeit="21.11., 22:50"):
    p = subprocess.run([sys.executable, os.path.join(A, "tools", "vorgang.py")] + list(a), env=dict(ENV, BORNIM_JETZT=zeit, BORNIM_SITZUNG=sid), capture_output=True, text=True, cwd=A)
    return p.returncode, p.stdout + p.stderr
lauf_als("session_FREMD", "rueckmeldung", "9014", "fertig, Commit abc1234, Bild t301")
soll("1888: fertig ohne Besetzung als „unbekannt“ eingetragen", "unbekannt (`session_FREMD`)" in datei("9014"), datei("9014")[-400:])
rc, out = vg("rueckmeldung", "9014", "nein: Fackel zu hell", zeit="21.11., 22:55")
soll("1888: Rückläufer an den Besitzer der Liste (Tom), nicht an den Disponenten", re.search(r"\| 9014-Ü\d+ \| Tom \| Rückläufer \(nein des Prüfers", datei("9014")) and "Macher unbekannt" not in datei("9014"), (out, datei("9014")[-500:]))
_bp = os.path.join(A, "docs", "ARBEIT-BESETZUNG.md"); _b = open(_bp, encoding="utf-8").read()
lauf_als("session_FK2", "rueckmeldung", "9015", "fertig, Commit def5678", zeit="21.11., 22:56")
open(_bp, "w", encoding="utf-8").write(_b + "| Fachkraft | [F](https://claude.ai/code/session_FK2) | 9015 | – | 21.11. |\n")  # Zeile kommt nach dem fertig dazu
rc, out = vg("rueckmeldung", "9015", "nein: Fackel zu dunkel", zeit="21.11., 22:57")
open(_bp, "w", encoding="utf-8").write(_b)
soll("1888: Rolle der Sitzung aus der Besetzung von jetzt (Fachkraft) vor dem Listenbesitzer", re.search(r"\| 9015-Ü\d+ \| Fachkraft \| Rückläufer", datei("9015")), (out, datei("9015")[-500:]))

# 1910 (D342.1): Chef-Nein zählt für Obergrenze A, nicht für die Laufbremse (V5 offen)
cw.eintragen("9016", "Nein, Tür klemmt", "21.11., 23:00", "Sokrates")
rc, out = vg("rueckmeldung", "9016", "nein: Tür klemmt noch", zeit="21.11., 23:05")
t = datei("9016")
soll("1910: Chef-Nein + erstes Prüfer-Nein: keine Laufbremse", "Laufbremse" not in t and rm.zaehlen(t)["nein"] == 2 and rm.zaehlen(t)["nein Prüfer"] == 1, (out, t[-500:]))
rc, out = vg("rueckmeldung", "9016", "nein: klemmt immer noch", zeit="21.11., 23:10")
t = datei("9016")
soll("1910: drittes Nein (eins vom Chef) → Obergrenze A", "Obergrenze A: 3. abgelehnter Auftrag" in t, t[-500:])

print("rueckmeldung_test: %s" % ("alles grün" if not fehl else "%d FEHL" % fehl))
sys.exit(1 if fehl else 0)
