# 1739 Lehrenbuch (Archiv „Lehrenbuch“ 21.11., 14:19): Suche nach Bereich, Treffer in die Vorgangsdatei, roh sammeln,
# zuordnen mit Wirkung („wirkt nein“, „nicht gefunden“ → Zeile an Sokrates). Echtes Git mit nacktem origin.
# Aufruf: python3 tools/lehren_test.py
import os, subprocess, sys, tempfile
HIER = os.path.dirname(os.path.abspath(__file__))
d = tempfile.mkdtemp(); o = os.path.join(d, "origin.git"); A = os.path.join(d, "a")
def g(*a, cwd=None): return subprocess.run(["git"] + list(a), cwd=cwd, check=True, capture_output=True, text=True).stdout
g("init", "-q", "--bare", "-b", "main", o)
g("clone", "-q", o, A); g("config", "user.email", "t@t", cwd=A); g("config", "user.name", "t", cwd=A); g("checkout", "-q", "-b", "main", cwd=A)
os.makedirs(os.path.join(A, "docs")); os.makedirs(os.path.join(A, "tools"))
for f in ("lehren.py", "auftrag.py", "rueckmeldung.py", "chefwort.py", "uebergabe.py", "startbar.py", "bereiche.py", "vorgang.py"):
    os.symlink(os.path.join(HIER, f), os.path.join(A, "tools", f))
open(os.path.join(A, "docs", "LISTE-VORGAENGE.md"), "w").write(
    "# Vorgangsliste\n\n| Nr. | Titel | Besitzer | Kl. | Stand | wartet auf | Zweig | Build | Bereich | Kosten |\n|---|---|---|---|---|---|---|---|---|---|\n"
    "| 9001 | Waffe halten: Faust schließt nicht | Tom | M | startbar | – | – | – | E Figuren | – |\n"
    "| 9002 | Kleidung Stoff flattert | Tom | M | startbar | – | – | – | E Figuren | – |\n"
    "| 9003 | Höhlenklang hallt | Jerry | M | startbar | – | – | – | E Welt | – |\n")
open(os.path.join(A, "docs", "ARBEIT-BETRIEB.md"), "w").write("**Nächste freie Vorgangsnummer: 9100**\n")
open(os.path.join(A, "docs", "ARBEIT-BESETZUNG.md"), "w").write("| Rolle | Sitzung | Vorgang | Zweig | seit |\n|---|---|---|---|---|\n")
g("add", "-A", cwd=A); g("commit", "-q", "-m", "start", cwd=A); g("push", "-q", "origin", "main", cwd=A)
ENV = dict(os.environ, BORNIM_WURZEL=A, BORNIM_JETZT="21.11., 22:00", GIT_AUTHOR_NAME="t", GIT_AUTHOR_EMAIL="t@t",
           GIT_COMMITTER_NAME="t", GIT_COMMITTER_EMAIL="t@t", BORNIM_SITZUNG="session_T1")
ENV.pop("BORNIM_OHNE_PUSH", None)
fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else zeige))
def zeige(pfad):
    g("fetch", "-q", "origin", cwd=A)
    try: return g("show", "origin/main:" + pfad, cwd=A)
    except subprocess.CalledProcessError: return ""
def vg(*a):
    p = subprocess.run([sys.executable, os.path.join(A, "tools", "vorgang.py")] + list(a), env=ENV, capture_output=True, text=True, cwd=A)
    return p.returncode, p.stdout + p.stderr

# 1 roh anhängen, Buch wird angelegt, doppelt nur einmal
rc, out = vg("lehre", "roh", "9001", "Fund des Chefs", "Stiel liegt quer über den Fingern, Messung am Knochen statt am Netz")
buch = zeige("docs/LISTE-LEHREN.md")
soll("roh angelegt", rc == 0 and "| R1 | E Figuren | 9001 | Fund des Chefs |" in buch, out + buch)
vg("lehre", "roh", "9001", "Fund des Chefs", "Stiel liegt quer über den Fingern, Messung am Knochen statt am Netz")
soll("gleiche rohe Zeile nur einmal", zeige("docs/LISTE-LEHREN.md").count("| R") == 2, zeige("docs/LISTE-LEHREN.md"))  # Kopf + R1

# 2 als neue Lehre fassen
rc, out = vg("lehre", "zuordnen", "R1", "--neu", "Waffe halten Griff", "erst am Netz messen, dann am Knochen")
buch = zeige("docs/LISTE-LEHREN.md")
soll("neue Lehre L1", rc == 0 and "| L1 | E Figuren | Waffe halten Griff | 9001 |" in buch and "| R1 |" in buch and "| → L1 |" in buch, out + buch)
rc, out = vg("lehre", "zuordnen", "R1", "L1")
soll("zweimal zuordnen hält an", rc != 0 and "schon zugeordnet" in out, out)

# 3 Auftrag: Vorlage zeigt Lehren des Bereichs, Eintragen schreibt Treffer
rc, out = vg("auftrag", "9002")
soll("Vorlage zeigt L1 (gleicher Bereich)", "L1 [E Figuren]" in out, out)
rc, out = vg("auftrag", "9003")
soll("anderer Bereich: keine", "- keine" in out and "L1" not in out, out)
auftr = "\n".join("%d. **%s:** %s" % (i, f, "x? y? z?" if i == 6 else "x y z") for i, f in enumerate(["Ziel", "Systemfrage", "Bisher", "Beachte", "Umsetzen", "Prüfart und Prüfe vor dem Senden", "Zurück"], 1))
open(os.path.join(d, "auftrag.md"), "w").write(auftr)
rc, out = vg("auftrag", "9002", "--datei", os.path.join(d, "auftrag.md"))
soll("Treffer in der Vorgangsdatei", rc == 0 and "Lehren-Treffer (21.11., 22:00): L1" in zeige("docs/vorgang/9002.md"), out + zeige("docs/vorgang/9002.md"))

# 4 Fehler kehrt wieder: zuordnen → wirkt nein, Zeile an Sokrates
vg("lehre", "roh", "9002", "zweites Nein (Prüfer)", "Faust wieder offen")
rc, out = vg("lehre", "zuordnen", "R2", "L1")
buch, akte = zeige("docs/LISTE-LEHREN.md"), zeige("docs/vorgang/9002.md")
soll("wirkt nein in der Lehre", rc == 0 and "wirkt nein 21.11., 22:00 (9002)" in buch and "9001, 9002" in buch, out + buch)
soll("Zeile an Sokrates", "| Sokrates | Lehrenbuch: L1 wirkt nein" in akte, akte)

# 5 nicht gefunden: gleicher Bereich, Lehre nicht unter den Treffern
vg("lehre", "roh", "9001", "zweites Nein (Prüfer)", "Daumen offen")
rc, out = vg("lehre", "zuordnen", "R3", "L1")
soll("nicht gefunden an Sokrates", "nicht gefunden" in out and "Lehrenbuch: L1 nicht gefunden" in zeige("docs/vorgang/9001.md"), out)

# 6 keine Lehre, Suche
vg("lehre", "roh", "9003", "geschlossen", "doppelt angelegt")
rc, out = vg("lehre", "zuordnen", "R4", "--keine", "kurz")
soll("Grund zu kurz hält an", rc != 0, out)
rc, out = vg("lehre", "zuordnen", "R4", "--keine", "Einzelfall, weil doppelt angelegt")
soll("keine Lehre", "| keine Lehre: Einzelfall, weil doppelt angelegt |" in zeige("docs/LISTE-LEHREN.md"), out)
rc, out = vg("lehre", "suche", "netz")
soll("Suche findet L1 und R1", "L1 [" in out and "R1 [" in out and "R4" not in out, out)

# 7 Rückmeldung: zweites Nein sammelt roh
vg("rueckmeldung", "9003", "nein, Hall zu lang", "--sitzung", "Prüfer")
rc, out = vg("rueckmeldung", "9003", "nein, Hall immer noch zu lang", "--sitzung", "Prüfer")
soll("zweites Nein → roh", "LEHRENBUCH R5" in out and "| R5 | E Welt | 9003 | zweites Nein (Prüfer) |" in zeige("docs/LISTE-LEHREN.md"), out)

print("lehren_test: " + ("grün" if not fehl else "%d Fehler" % fehl))
sys.exit(1 if fehl else 0)
