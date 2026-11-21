# 1739: vorgang.py --hilfe, auftrag (Vorlage, Prüfung der sieben Felder, „Zurück“, 2 KB, Eintrag in docs/vorgang/NR.md),
# schliessen mit Grund. Echtes Git mit nacktem origin. Aufruf: python3 tools/auftrag_test.py
import os, subprocess, sys, tempfile
HIER = os.path.dirname(os.path.abspath(__file__))
d = tempfile.mkdtemp(); o = os.path.join(d, "origin.git"); A = os.path.join(d, "a")
def g(*a, cwd=None): return subprocess.run(["git"] + list(a), cwd=cwd, check=True, capture_output=True, text=True).stdout
g("init", "-q", "--bare", "-b", "main", o)
g("clone", "-q", o, A); g("config", "user.email", "t@t", cwd=A); g("config", "user.name", "t", cwd=A); g("checkout", "-q", "-b", "main", cwd=A)
os.makedirs(os.path.join(A, "docs")); os.makedirs(os.path.join(A, "tools"))
for f in ("auftrag.py", "uebergabe.py", "startbar.py", "bereiche.py", "vorgang.py", "chefwort.py", "rueckmeldung.py", "neustart-haken.py", "kernregeln.txt"):
    if os.path.exists(os.path.join(HIER, f)): os.symlink(os.path.join(HIER, f), os.path.join(A, "tools", f))
open(os.path.join(A, "docs", "LISTE-VORGAENGE.md"), "w").write(
    "# Vorgangsliste\n\n| Nr. | Titel | Besitzer | Kl. | Stand | wartet auf | Zweig | Build | Bereich | Kosten |\n|---|---|---|---|---|---|---|---|---|---|\n"
    "| 9001 | Zwerg auf dem Tisch | Tom | M | startbar | – | – | – | E Welt | – |\n"
    "| 9002 | Schatten im Wald | Spike | M | gebaut, Geprüft an: abc1234 | – | – | – | B Werkzeuge | – |\n")
g("add", "-A", cwd=A); g("commit", "-q", "-m", "start", cwd=A); g("push", "-q", "origin", "main", cwd=A)
ENV = dict(os.environ, BORNIM_WURZEL=A, BORNIM_JETZT="21.11., 20:40", GIT_AUTHOR_NAME="t", GIT_AUTHOR_EMAIL="t@t",
           GIT_COMMITTER_NAME="t", GIT_COMMITTER_EMAIL="t@t", BORNIM_SITZUNG="session_T")
ENV.pop("BORNIM_OHNE_PUSH", None)
os.environ.update(ENV)
sys.path.insert(0, os.path.join(A, "tools"))
import auftrag as au
fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else zeige))
def datei(nr):
    g("fetch", "-q", "origin", cwd=A)
    try: return g("show", "origin/main:docs/vorgang/%s.md" % nr, cwd=A)
    except subprocess.CalledProcessError: return ""
def lauf(*a, eingabe=None):
    p = subprocess.run([sys.executable, os.path.join(A, "tools", "vorgang.py")] + list(a), env=ENV, capture_output=True, text=True, cwd=A, input=eingabe)
    return p.returncode, p.stdout + p.stderr

GUT = """1. **Ziel:** Der Zwerg steht auf dem Tisch, nicht darin.
2. **Systemfrage:** Gilt für alle Möbel; wie lösen es andere: Stellfläche je Möbel.
3. **Bisher:** Höhe fest eingetragen, Ursache Netz ohne Fläche.
4. **Beachte:**
   - nur Tom-Bereich
   - Kerntests
5. **Umsetzen:** Stellfläche aus dem Netz lesen.
6. **Prüfart und Prüfe vor dem Senden:** Bild in Spielkamera; steht er auf der Fläche? Ja/Nein.
7. **Zurück:** an das Büro, erstes Wort „fertig“, mit Commit und Bild.
"""

# 1 Hilfe
c, t = lauf("--hilfe")
soll("--hilfe zeigt Hilfe, Exit 0", c == 0 and "auftrag NR" in t and "schliessen NR" in t, t[-300:])

# 2 Vorlage
c, t = lauf("auftrag", "9001")
soll("Vorlage mit Titel und sieben Feldern", c == 0 and "Zwerg auf dem Tisch" in t and all(f in t for f in au.FELDER), t)
soll("Vorlage selbst gilt nicht (Felder leer)", len(au.pruefen(au.vorlage("9001"))) >= 7, au.pruefen(au.vorlage("9001")))
c, t = lauf("auftrag", "9999")
soll("unbekannte Nummer hält an", c != 0 and "nicht in der Vorgangsliste" in t, t)

# 3 Prüfung
soll("gültiger Auftrag ohne Fehler", au.pruefen(GUT) == [], au.pruefen(GUT))
soll("ohne „Zurück“ hält an", any("Zurück" in x for x in au.pruefen(GUT.split("7. ")[0])), au.pruefen(GUT.split("7. ")[0]))
soll("„Zurück“ zu knapp", any("knapp" in x for x in au.pruefen(GUT.replace("an das Büro, erstes Wort „fertig“, mit Commit und Bild.", "Büro"))))
soll("über 2 KB hält an", any("Byte" in x for x in au.pruefen(GUT + "x" * 2100)))
sechs = GUT.replace("   - Kerntests\n", "   - a\n   - b\n   - c\n   - d\n   - e\n")
soll("Beachte mit sechs Punkten hält an", any("Beachte" in x for x in au.pruefen(sechs)), au.pruefen(sechs))
num = GUT.replace("   - nur Tom-Bereich\n   - Kerntests\n", "   1. nur Tom\n   2. Kerntests\n")
soll("nummerierte Punkte in Beachte trennen keine Felder", au.pruefen(num) == [], au.pruefen(num))
ohne_fett = GUT.replace("**", "")
soll("Felder auch ohne Fettschrift", au.pruefen(ohne_fett) == [], au.pruefen(ohne_fett))

# 4 Eintragen
p = os.path.join(d, "auftrag.md"); open(p, "w").write(GUT.split("7. ")[0])
c, t = lauf("auftrag", "9001", "--datei", p)
soll("ungültig: Exit 1, nichts geschrieben", c == 1 and datei("9001") == "", t)
open(p, "w").write(GUT)
c, t = lauf("auftrag", "9001", "--datei", p, "--pruefen")
soll("--pruefen schreibt nichts", c == 0 and "gültig" in t and datei("9001") == "", t)
c, t = lauf("auftrag", "9001", "--datei", "-", eingabe=GUT)
x = datei("9001")
soll("gültig: Abschnitt „## Auftrag (21.11., 20:40)“ gepusht", c == 0 and "## Auftrag (21.11., 20:40)" in x and "Stellfläche aus dem Netz" in x, (t, x))

# 5 Schließen
c, t = lauf("schliessen", "9002", "erledigt")
soll("Grund zu kurz hält an", c != 0 and "drei Wörtern" in t, t)
c, t = lauf("schliessen", "9002", "doppelt zu 9001, dort gebaut")
x = datei("9002"); liste = open(os.path.join(A, "docs", "LISTE-VORGAENGE.md")).read()
soll("schliessen: Liste erledigt, Grund in Vorgangsdatei", c == 0 and "| 9002 | Schatten im Wald | Spike | M | erledigt |" in liste
     and "Geschlossen (21.11., 20:40): doppelt zu 9001, dort gebaut" in x, (t, x))

print("auftrag_test: " + ("alles grün" if not fehl else "%d Fehler" % fehl))
sys.exit(1 if fehl else 0)
