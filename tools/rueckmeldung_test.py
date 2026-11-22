# 1763: Rückmeldung in die Vorgangsdatei, Obergrenzen A (zweites „nein, Auftrag“, dritter abgelehnter Auftrag) und B (zweites
# „steckt fest“) → ruht, beim Chef; „steckt fest“, „Frage“, „wirkt nein“ → Zeile an Sokrates, lauf.py startet oder weckt ihn (C).
# Echtes Git mit nacktem origin. Aufruf: python3 tools/rueckmeldung_test.py
import os, subprocess, sys, tempfile
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
    "| 9006 | Treppe zu steil | Tom | K | startbar | – | – | – | E Welt | – |\n")
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
rm_lauf = lauf  # 1797: lauf wird weiter unten zum Modul lauf.py
import rueckmeldung as rm

# 1 Erstes Wort
for t, w in [("nein, Auftrag: Prüffrage am Ziel vorbei", {"nein, Auftrag"}), ("Nein. Bart fehlt. steckt fest: Handwerksregel Bart", {"nein", "steckt fest"}),
             ("Beleg fehlt", {"Beleg fehlt"}), ("wirkt nein", {"wirkt nein"}), ("Frage: welcher Text?", {"Frage"}), ("ja", {"ja"}), ("fertig, Commit abc", {"fertig"}),
             ("„steckt fest“ beim Licht", {"steckt fest"}), ("neinsager", set()),
             ("**Spike** [21.11., 20:41] nein, Auftrag: x", {"nein, Auftrag"}), ("Spike [21.11., 20:41]: steckt fest", {"steckt fest"}),
             ("**Jerry** [21.11., 20:41]\nnein", {"nein"}), ("**Tom**: Frage zum Licht", {"Frage"}), ("Tom 2 [21.11., 20:41] fertig", {"fertig"}),
             ("Nein [Hof] steckt fest", {"nein", "steckt fest"}),
             ("**nein, Auftrag**: falsch", {"nein, Auftrag"}), ("**steckt fest**: Licht", {"steckt fest"}), ("**Frage:** welcher Text?", {"Frage"}),
             ("**Nein.** steckt fest", {"nein", "steckt fest"}), ("**Frage** zum Licht", {"Frage"}), ("**Spike** [21.11.2026, 20:41] nein", {"nein"}),
             ("abgebrochen: Filmlauf ohne Ausgabe", {"abgebrochen"}), ("**Spike** [22.11., 08:00] abgebrochen", {"abgebrochen"}),
             ("Auftrag steht: 1694-4", {"Auftrag steht"}), ("kein Auftrag nötig: schon gebaut", {"kein Auftrag nötig"}),
             ("fertig 1a2b3c4. Hinweis: Prüffrage fehlt", {"fertig", "Hinweis im Text"}), ("Notiz. Hinweis: Geländer", {"Hinweis"})]:
    soll("Wort %r" % t[:25], rm.worte(t) == w, rm.worte(t))

# 2 B: erstes „steckt fest“ an Sokrates, zweites an den Chef (ruht)
rc, out = lauf("rueckmeldung", "9001", "steckt fest: Licht im Keller, Regel fehlt")
soll("1. steckt fest → Sokrates", rc == 0 and "OFFEN 9001-Ü1 an Sokrates" in out and "KEINE SITZUNG Sokrates" in out, out)
t = datei("9001")
soll("Rückmeldung wörtlich mit Zeit und Sitzung", "- **21.11., 20:30**, Prüfer (`session_PR1`):\n> steckt fest: Licht im Keller, Regel fehlt\n" in t, t)
soll("Zeile an Sokrates (C)", "| 9001-Ü1 | Sokrates | steckt fest: Rückmeldung 21.11., 20:30 von Prüfer lesen (1763 C) | 21.11., 20:30 | offen |" in t, t)
rc, out = lauf("rueckmeldung", "9001", "nein: Keller zu hell. steckt fest: wieder Licht", zeit="21.11., 21:00")
t = datei("9001")
soll("2. steckt fest → ruht, an den Chef", "OFFEN 9001-Ü2 an Sokrates (Obergrenze B: 2. „steckt fest“ → ruht, beim Chef)" in out, out)
soll("Zustand in der Vorgangsdatei", "Zustand: ruht, beim Chef seit 21.11., 21:00 (Obergrenze B: 2. „steckt fest“, 1763)" in t, t)
soll("Zeile sagt: an den Chef, nicht selbst lösen", "| 9001-Ü2 | Sokrates | an den Chef: Chefsache anlegen, nicht selbst lösen" in t, t)
soll("Liste: ruht, beim Chef", "| 9001 | Zwerg auf dem Tisch | Tom | M | ruht, beim Chef (Obergrenze B) |" in open(os.path.join(A, "docs", "LISTE-VORGAENGE.md")).read())
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
soll("nein ohne fertig: Disponent, Fachkraft unbekannt", "OFFEN 9006-Ü1 an Disponent" in out and "Fachkraft unbekannt" in datei("9006"), out)
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
soll("Nein mit Stichwort: Systemlösung? für Sokrates", rc == 0 and "Systemlösung? Treppe" in liste and "LISTE docs/LISTE-VORGAENGE.md geändert" in out, out)
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

# 7 1739 F4 (1): offene Zeilen an andere (Arbeitsplaner = Ford bis zur Umschaltung)
aus = []; je = lauf.uebergabe_zeilen(aus, {}, set(), docs=os.path.join(A, "docs"))
soll("Arbeitsplaner-Zeilen an Ford", "Arbeitsplaner" in je and any(z.startswith("NACHRICHT Ford | - | Offene Zeilen an Arbeitsplaner") for z in aus) and not any("Sokrates" in z.split("|")[0] for z in aus), (je, aus))
soll("Disponent bis zur Umschaltung Ford", any(z.startswith("NACHRICHT Ford | - | Offene Zeilen an Disponent") for z in aus), aus)
soll("Prüfer bis zur Umschaltung Diogenes (keine Sitzung: Ford)", any("keine Sitzung Diogenes" in z and "Offene Zeilen an Prüfer" in z for z in aus), aus)
aus = []; lauf.uebergabe_zeilen(aus, {}, set(), docs=os.path.join(A, "docs"), start=lambda r, nr, t: gerufen0.append(r) or True) if (gerufen0 := []) == [] else None
soll("Prüfer ohne Sitzung: Start Diogenes", "Diogenes" in gerufen0 and "Tom" in gerufen0, gerufen0)

# 8 1739 Befund 1: Empfänger ohne Sitzung starten (start-Rückruf), sonst Ford; Fristen je Lauf
rc, out = vg("uebergabe", "9005", "Tom", "Treppe im Turm prüfen")
soll("Zeile an Tom angelegt", rc == 0 and "9005-Ü1" in datei("9005"), out)
g("pull", "-q", "origin", "main", cwd=A)
gerufen = []
aus = []; lauf.uebergabe_zeilen(aus, {}, set(), docs=os.path.join(A, "docs"), start=lambda r, nr, t: gerufen.append((r, nr)) or True)
soll("Tom ohne Sitzung: start gerufen, keine NACHRICHT Ford für Tom", any(r == "Tom" for r, _ in gerufen) and not any("keine Sitzung Tom" in z for z in aus), (gerufen, aus))
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
soll("Frist ab, Halter ruht: wieder offen, Zeile NICHTS", frei == ["9005-Ü1"] and "| offen |" in datei("9005") and aus and aus[0].startswith("NICHTS Übergabe: 9005-Ü1 wieder offen"), (frei, aus, datei("9005")))
os.environ["BORNIM_JETZT"] = "21.11., 20:30"
import auftrag as _af
ad = os.path.join(d, "adocs"); os.makedirs(os.path.join(ad, "vorgang"))
soll("ohne Vorgangsdatei: kein Auftrag; M? braucht keinen", lauf.auftrag_fehlt("9001", ad) == "kein Auftrag" and lauf.auftrag_fehlt("M?", ad) is None)
open(os.path.join(ad, "vorgang", "9001.md"), "w").write("# Vorgang 9001\n\n## Auftrag (21.11., 20:00)\n\n" + _af.vorlage("9001", "x"))
soll("leere Vorlage: Auftrag ungültig", (lauf.auftrag_fehlt("9001", ad) or "").startswith("Auftrag: Feld 1"))
open(os.path.join(ad, "vorgang", "9001.md"), "a").write("\n## Auftrag (21.11., 20:30)\n\nAuftrag 9001\n\n" + "\n".join("%d. **%s:** etwas Inhalt hier" % (i, f) for i, f in enumerate(_af.FELDER, 1)) + "\n\n## Übergaben\n\nx\n")
soll("jüngster Auftrag gültig: Start erlaubt", lauf.auftrag_fehlt("9001", ad) is None)
soll("Archivschutz: 1 Min. bis zur Umschaltung, scharf 15 Min. (1739, 7.1)", lauf.schutz_min(False) == 1 and lauf.schutz_min(True) == 15)

# 1797 abgebrochen (ein Neustart, zweites an Sokrates), Auftrag steht, kein Auftrag nötig, Hinweis hinter fertig
rc, out = rm_lauf("rueckmeldung", "9027", "abgebrochen: Filmlauf ohne Ausgabe", zeit="21.11., 20:40")
soll("1797 abgebrochen → Disponent, ein Neustart", "OFFEN 9027-Ü1 an Disponent" in out and "einmal neu starten" in datei("9027"), out)
rc, out = rm_lauf("rueckmeldung", "9027", "abgebrochen: wieder ohne Ausgabe", zeit="21.11., 20:41")
soll("1797 zweites abgebrochen → Sokrates steckt fest", "OFFEN 9027-Ü2 an Sokrates" in out and "2. „abgebrochen“" in datei("9027"), out)
rc, out = rm_lauf("rueckmeldung", "9008", "Auftrag steht: 9008-1", zeit="21.11., 20:42")
soll("1797 Auftrag steht → Disponent startet Fachkraft", "OFFEN 9008-Ü1 an Disponent" in out and "Fachkraft nach Profil" in datei("9008"), out)
rc, out = rm_lauf("rueckmeldung", "9008", "kein Auftrag nötig: schon gebaut in abc1234", zeit="21.11., 20:43")
soll("1797 kein Auftrag nötig → Disponent", "OFFEN 9008-Ü2 an Disponent" in out and "schliessen" in datei("9008"), out)
rc, out = rm_lauf("rueckmeldung", "9009", "fertig 1a2b3c4d. Hinweis: Prüffrage 3 fehlt", zeit="21.11., 20:44")
soll("1797 fertig mit Hinweis: Prüfer und zweite Zeile an Disponent", "OFFEN 9009-Ü1 an Prüfer" in out
     and "| 9009-Ü2 | Disponent | Hinweis (Rückmeldung 21.11., 20:44" in datei("9009") and "Prüffrage 3 fehlt" in datei("9009"), datei("9009"))

print("rueckmeldung_test: %s" % ("alles grün" if not fehl else "%d FEHL" % fehl))
sys.exit(1 if fehl else 0)
