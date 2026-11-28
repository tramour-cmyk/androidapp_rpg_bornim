# 1944–1950 (1727 Falltest Lauf 4, Befund 9; Chef 22.11., 14:51 „veranlasse die Korrektur“): Werkzeuglücken.
# Echtes Git mit nacktem origin, Werkzeug ohne tools/1727-SCHARF (alte Namen gelten). Aufruf: python3 tools/werkzeugluecken_lauf4_test.py
import io, contextlib, os, subprocess, sys, tempfile
HIER = os.path.dirname(os.path.abspath(__file__))
d = tempfile.mkdtemp(); o = os.path.join(d, "origin.git"); A = os.path.join(d, "a")
def g(*a, cwd=None): return subprocess.run(["git"] + list(a), cwd=cwd, check=True, capture_output=True, text=True).stdout
g("init", "-q", "--bare", "-b", "main", o)
g("clone", "-q", o, A); g("config", "user.email", "t@t", cwd=A); g("config", "user.name", "t", cwd=A); g("checkout", "-q", "-b", "main", cwd=A)
os.makedirs(os.path.join(A, "docs")); os.makedirs(os.path.join(A, "tools"))
for f in ("auftrag.py", "uebergabe.py", "startbar.py", "bereiche.py", "vorgang.py", "chefwort.py", "rueckmeldung.py", "liegt.py", "lehren.py", "kernregeln.txt"):
    if os.path.exists(os.path.join(HIER, f)): os.symlink(os.path.join(HIER, f), os.path.join(A, "tools", f))
open(os.path.join(A, "docs", "LISTE-VORGAENGE.md"), "w").write(
    "# Vorgangsliste\n\n| Nr. | Titel | Besitzer | Kl. | Stand | wartet auf | Zweig | Build | Bereich | Kosten |\n|---|---|---|---|---|---|---|---|---|---|\n"
    "| 9001 | Zwerg auf dem Tisch | Tom | M | startbar | – | – | – | E Welt | – |\n"
    "| 9013 | Nachtstopp-Haken | Spike | K | startbar | – | – | – | B Werkzeuge | – |\n"
    "| 1734 | Forschung bei Sokrates | Sokrates | K | startbar | – | – | – | B Abläufe | – |\n")
open(os.path.join(A, "docs", "LISTE-VORGAENGE-ARCHIV.md"), "w").write(
    "# Archiv\n\n| Nr. | Vorgang | Bereich | Kl. | Kosten | Vorrat | Stand |\n|---|---|---|---|---|---|---|\n"
    "| 300 | Bilder prüfen nur in einer Extra-Sitzung | B Abläufe | M | 1,20 $ | Perikles | erledigt |\n")
open(os.path.join(A, "docs", "ARBEIT-BETRIEB.md"), "w").write("**Nächste freie Vorgangsnummer: 9100**\n")
open(os.path.join(A, "docs", "ARBEIT-BESETZUNG.md"), "w").write("| Rolle | Sitzung | Vorgang | Zweig | seit |\n|---|---|---|---|---|\n")
g("add", "-A", cwd=A); g("commit", "-q", "-m", "start", cwd=A); g("push", "-q", "origin", "main", cwd=A)
ENV = dict(os.environ, BORNIM_WURZEL=A, BORNIM_JETZT="22.11., 15:00", GIT_AUTHOR_NAME="t", GIT_AUTHOR_EMAIL="t@t",
           GIT_COMMITTER_NAME="t", GIT_COMMITTER_EMAIL="t@t", BORNIM_SITZUNG="session_T")
ENV.pop("BORNIM_OHNE_PUSH", None); ENV.pop("BORNIM_CHEFWORT_AN", None)
os.environ.update(ENV)
sys.path.insert(0, os.path.join(A, "tools"))
fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else zeige))
def datei(nr):
    g("fetch", "-q", "origin", cwd=A)
    try: return g("show", "origin/main:docs/vorgang/%s.md" % nr, cwd=A)
    except subprocess.CalledProcessError: return ""
def vg(*a, eingabe=None):
    g("pull", "-q", "origin", "main", cwd=A)
    p = subprocess.run([sys.executable, os.path.join(A, "tools", "vorgang.py")] + list(a), env=ENV, capture_output=True, text=True, cwd=A, input=eingabe)
    return p.returncode, p.stdout + p.stderr

GUT = """1. **Ziel:** Der Zwerg steht auf dem Tisch, nicht darin.
2. **Systemfrage:** Gilt für alle Möbel; wie lösen es andere: Stellfläche je Möbel.
3. **Bisher:** Höhe fest eingetragen, Ursache Netz ohne Fläche.
4. **Beachte:**
   - Kerntests
5. **Umsetzen:** Stellfläche aus dem Netz lesen.
6. **Prüfart und Prüfe vor dem Senden:** Bild in Spielkamera; steht er auf der Fläche? Ist nichts im Tisch? Zeigt das Bild den Commit?
7. **Zurück:** an das Büro, erstes Wort „fertig“, mit Commit und Bild.
"""

# 1944: unbekannte Nummer nie „gültig“
c, t = vg("auftrag", "1997", "--datei", "-", "--pruefen", eingabe=GUT)
soll("1944: auftrag --pruefen 1997 (nicht in Liste/Archiv) hält an", c != 0 and "nicht in der Vorgangsliste" in t and "gültig" not in t, t)
c, t = vg("auftrag", "9001", "--datei", "-", "--pruefen", eingabe=GUT)
soll("1944: bekannte Nummer bleibt gültig", c == 0 and "gültig" in t, t)
c, t = vg("auftrag", "300", "--datei", "-", "--pruefen", eingabe=GUT)
soll("1944: archivierte Nummer (Rückläufer) gilt", c == 0 and "gültig" in t, t)

# 1945: lauf.py --help ohne jede Prüfung
sys.path.insert(0, HIER)
import lauf
lauf.notizen_frisch = lambda: (_ for _ in ()).throw(AssertionError("Notizen geprüft"))
sys.argv = ["lauf.py", "--help"]; buf = io.StringIO()
try:
    with contextlib.redirect_stdout(buf): r = lauf.main()
    ok = True
except BaseException as e:
    ok = False; buf.write(repr(e))
soll("1945: lauf.py --help zeigt Hilfe, prüft nichts", ok and "Aufruf:" in buf.getvalue(), buf.getvalue()[-300:])
for h in ("-h", "hilfe"):
    sys.argv = ["lauf.py", "--sperre", h]; buf = io.StringIO()
    with contextlib.redirect_stdout(buf): lauf.main()
    soll("1945: lauf.py %s ebenso" % h, "Aufruf:" in buf.getvalue())
sys.path.remove(HIER)

# 1946: Empfänger
import uebergabe as ue
soll("1946: Schreibung fest („figur“ → Figur)", ue.empfaenger("figur", scharf=True) == "Figur")
for alt, neu in (("Spike", "Technik"), ("Diogenes", "Prüfer"), ("Ford", "Disponent")):
    try: ue.empfaenger(alt, scharf=True); soll("1946: %s nach der Umschaltung abgelehnt" % alt, False)
    except ue.Fehler as e: soll("1946: %s nach der Umschaltung → „%s“" % (alt, neu), neu in str(e), str(e))
soll("1946: alte Namen vor der Umschaltung gelten", ue.empfaenger("spike", scharf=False) == "Spike")
try: ue.empfaenger("Figuren", scharf=True); soll("1946: unbekannter Name abgelehnt", False)
except ue.Fehler as e: soll("1946: unbekannter Name nennt die gültigen", all(x in str(e) for x in ("Technik", "Prüfer", "Sokrates", "Fachkraft")), str(e))
c, t = vg("uebergabe", "9001", "Quatsch", "bauen")
soll("1946: vorgang.py uebergabe mit unbekanntem AN hält an, nichts geschrieben", c != 0 and "gültig:" in t and "9001-Ü" not in datei("9001"), t)
c, t = vg("--hilfe")
soll("1946: --hilfe nennt die Empfänger", "Fachkraft" in t and "Spike = Technik" in t, t[-500:])

# 1947: Routine-Sitzung meldet „fertig“ ohne Commit unter 1734
import rueckmeldung as rm
soll("1947: ist_routine an der Rolle der Sitzung", rm.ist_routine("1734", "Rundblick") and not rm.ist_routine("1734", "Figur"))
c, t = vg("rueckmeldung", "1734", "fertig: drei Vorschläge als Übergabezeilen", "--sitzung", "Rundblick")
x = datei("1734")
soll("1947: Disponent nimmt es als Routine an", c == 0 and "Routine fertig" in x and "nicht annehmen" not in x, (t, x[-500:]))

# 1948: Chef-Nein ohne „nein“ am Anfang und unter „Bisher“
import chefwort as cw
for w in ("Ja, also die Hand ist geschlossen … Also fail. Sorry. Wieder daneben.", "kein Unterschied zwischen alt und neu", "Film t300.11 Fail", "Nein des Chefs: 299.3 ✗"):
    soll("1948: chef_nein „%s“" % w[:40], cw.chef_nein(w))
for w in ("Passt.", "Gut, Build 301", "Warum ist die Tür blau?"):
    soll("1948: kein chef_nein „%s“" % w, not cw.chef_nein(w))
soll("1948: bisher_nein mit Chefzitat", cw.bisher_nein("Langschwert gekürzt. Chef 18.11., 17:38: „Der Stiel liegt nicht in der Hand. Also fail.“"))
soll("1948: bisher_nein „Nein des Chefs“", cw.bisher_nein("Nein des Chefs: „299.3 ✗“ (18.11.)"))
soll("1948: kein bisher_nein ohne Chef", not cw.bisher_nein("Höhe fest eingetragen, Ursache Netz ohne Fläche; Prüfer: „fail“"))
txt = "# 9001\n\n## Auftrag (22.11., 14:00)\n\n" + GUT.replace("Höhe fest eingetragen", "Chef 18.11., 17:38: „Wieder daneben.“ Höhe fest eingetragen") + "\n## Rückmeldungen\n\n"
soll("1948: zaehlen zählt das Nein unter Bisher einmal", rm.zaehlen(txt)["nein"] == 1, rm.zaehlen(txt))
txt2 = txt + "\n## Chefworte\n\n- **18.11., 17:38**, Chef (`s`):\n> Wieder daneben.\n"
soll("1948: nicht doppelt, wenn „Chefworte“ es schon zählt", rm.zaehlen(txt2)["nein"] == 1, rm.zaehlen(txt2))
# 1951 (D386.1): „daneben“ als Ortsangabe und lobendes „kein Unterschied“ sind kein Nein
for w in ("Die Truhe sitzt, daneben fehlt noch die Fackel.", "Licht ok, daneben die Bank etwas höher.", "Kein Unterschied zu gestern beim Laden, gut so.",
          "Die Fackel steht daneben.", "Kein Unterschied beim Laden. Passt."):
    soll("1951: kein chef_nein „%s“" % w, not cw.chef_nein(w))
for w in ("Wieder daneben.", "Daneben.", "Das ist total daneben!", "Kein Unterschied zwischen alt und neu, schade.", "Kein Unterschied, gut ist das nicht."):
    soll("1951: chef_nein „%s“" % w, cw.chef_nein(w))
soll("1951: kein bisher_nein mit Ortsangabe", not cw.bisher_nein("Chef 18.11., 17:38: „Die Truhe sitzt, daneben fehlt die Fackel.“"))
soll("1951: kein bisher_nein mit Lob", not cw.bisher_nein("Chef 18.11., 17:38: „Kein Unterschied zu gestern beim Laden, gut so.“"))
soll("1948: ohne Chef-Nein unter Bisher 0", rm.zaehlen("# x\n\n## Auftrag (22.11., 14:00)\n\n" + GUT)["nein"] == 0)

# 1949: Build-Auftrag B<n>
c, t = vg("auftrag", "B300", "--datei", "-", "--pruefen", eingabe=GUT)
soll("1949: auftrag B300 --pruefen gültig ohne Listenzeile", c == 0 and "gültig" in t, t)
c, t = vg("auftrag", "B300", "--datei", "-", eingabe=GUT)
soll("1949: auftrag B300 trägt in docs/vorgang/B300.md ein", c == 0 and "## Auftrag (" in datei("B300"), t)
c, t = vg("rueckmeldung", "300", "Befunde: 0 zu Build 300")
soll("1949: Meldung zu Build 300 unter Vorgang 300 hält an", c != 0 and "B300" in t and "Rückmeldungen" not in datei("300"), t)
c, t = vg("rueckmeldung", "B300", "Befunde: 0")
soll("1949: Meldung unter B300 geht an den Disponenten", c == 0 and "B300-Ü1 | Disponent" in datei("B300"), (t, datei("B300")[-300:]))
c, t = vg("uebergabe", "B300", "Technik", "Build 300 auf main")
soll("1949: uebergabe B300 Technik", c == 0 and "B300-Ü2 | Technik" in datei("B300"), t)
soll("1949: Kennung B300-Ü2 gelesen", ue.nr_aus("B300-Ü2") == "B300")

# 1950: Werkzeug „fertig“ mit Commit, der nicht auf main steht
open(os.path.join(A, "x.txt"), "w").write("lokal\n"); g("add", "x.txt", cwd=A); g("commit", "-q", "-m", "lokal", cwd=A)
lokal = g("rev-parse", "HEAD", cwd=A).strip(); g("push", "-q", "origin", "HEAD:refs/heads/werkzeug", cwd=A); g("reset", "-q", "--hard", "origin/main", cwd=A)
c, t = vg("rueckmeldung", "9013", "fertig: Haken gebaut, Commit %s, Test grün" % lokal[:9], "--sitzung", "Werkzeug")
x = datei("9013")
soll("1950: Zeile an den Prüfer und sofort an die Fachkraft „auf main“", c == 0 and "| Prüfer |" in x and "| Werkzeug | auf main, Vollzug mit Commit: %s" % lokal[:9] in x, (t, x[-600:]))
auf = g("rev-parse", "origin/main", cwd=A).strip()
c, t = vg("rueckmeldung", "9013", "fertig: zweiter Stand, Commit %s, Test grün" % auf[:9], "--sitzung", "Werkzeug")
x = datei("9013")
soll("1950: Commit auf main → nur an den Prüfer", c == 0 and x.count("auf main, Vollzug") == 1, (t, x[-600:]))
c, t = vg("rueckmeldung", "9001", "fertig: Zwerg steht, Commit %s" % lokal[:9], "--sitzung", "Figur")
soll("1950: Spielcode (kein Werkzeug) nicht geprüft", "auf main, Vollzug" not in datei("9001"), datei("9001")[-300:])

print("werkzeugluecken_lauf4_test: %s" % ("alles grün" if not fehl else "%d FEHL" % fehl))
sys.exit(1 if fehl else 0)
