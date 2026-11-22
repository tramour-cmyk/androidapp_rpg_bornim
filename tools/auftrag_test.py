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
open(os.path.join(A, "docs", "LISTE-VORGAENGE-ARCHIV.md"), "w").write(
    "# Archiv\n\n| Nr. | Vorgang | Bereich | Kl. | Kosten | Vorrat | Stand |\n|---|---|---|---|---|---|---|\n"
    "| 8001 | Alte Laterne | E Welt | M | 1,20 $ | Tom | erledigt |\n")
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
6. **Prüfart und Prüfe vor dem Senden:** Bild in Spielkamera; steht er auf der Fläche? Ist nichts im Tisch? Zeigt das Bild den Commit?
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
# 1878 (Lauf 3 Arbeitsplaner L4): wörtliche Zitate unter „Bisher“ zählen nicht zur Grenze, eigene Grenze
nein = "„" + "der Stiel liegt nicht in der geschlossenen Hand, also fail " * 30 + "“"
mit_zitat = GUT.replace("3. **Bisher:**", "3. **Bisher:** Chef 17:38: " + nein + " ·", 1)
soll("1878: langes Zitat unter „Bisher“ hält nicht an", au.pruefen(mit_zitat) == [] and len(mit_zitat.encode()) > 2048, au.pruefen(mit_zitat))
soll("1878: Zitat mit geraden Anführungszeichen ebenso", au.pruefen(mit_zitat.replace("„", '"').replace("“", '"')) == [])
soll("1878: dasselbe ohne Anführungszeichen hält an", any("ohne Zitate" in x for x in au.pruefen(mit_zitat.replace("„", "").replace("“", ""))))
lang_ziel = GUT.replace("1. **Ziel:**", "1. **Ziel:** " + nein, 1)
soll("1878: Zitat außerhalb „Bisher“ zählt mit", any("ohne Zitate" in x for x in au.pruefen(lang_ziel)), au.pruefen(lang_ziel))
zuviel = GUT.replace("3. **Bisher:**", "3. **Bisher:** " + nein + nein + nein, 1)
soll("1878: Zitate über 2048 Byte halten an", any("Zitate unter „Bisher“" in x for x in au.pruefen(zuviel)), au.pruefen(zuviel))
soll("1878: groesse trennt Zitate", au.groesse(mit_zitat)[1] == len(nein.encode()) and sum(au.groesse(mit_zitat)) == len(mit_zitat.encode()))
# 1879 (Lauf 3 Arbeitsplaner L7, Prüfer-1 L8): Inhalt statt nur Form
a3_ziel = GUT.replace("Der Zwerg steht auf dem Tisch, nicht darin.", "Ziel und Herkunft fehlen, „Frage“ an Sokrates; dieser Auftrag wird erst mit der Antwort eingetragen.")
soll("1879: Fehlwörter im Ziel halten an (A3)", any("Feld 1" in x and "fehlt" in x for x in au.pruefen(a3_ziel)), au.pruefen(a3_ziel))
a3_zur = GUT.replace("an das Büro, erstes Wort", "`vorgang.py rueckmeldung <Nr> \"fertig …\"` an das Büro, erstes Wort")
soll("1879: Platzhalter <Nr> in Zurück hält an (A3)", any("Platzhalter <Nr>" in x for x in au.pruefen(a3_zur)), au.pruefen(a3_zur))
pfad = GUT.replace("Stellfläche aus dem Netz lesen.", "Stellfläche aus dem Netz lesen, Muster `docs/vorgang/<Nr>.md` und docs/profil/<Name>.md.")
soll("1879: Platzhalter in Pfaden zählt nicht", au.pruefen(pfad) == [], au.pruefen(pfad))
zitat = GUT.replace("Höhe fest eingetragen", "Chef: „steht <wieder> drin“, Ursache unbekannt, Quelle fehlt; Höhe fest eingetragen")
soll("1879: in Bisher sind „unbekannt“, „fehlt“ und Zitate erlaubt", au.pruefen(zitat) == [], au.pruefen(zitat))
eine = GUT.replace("steht er auf der Fläche? Ist nichts im Tisch? Zeigt das Bild den Commit?", "steht er auf der Fläche? Ja/Nein.")
soll("1879: eine Prüffrage hält an", any("1 Prüffragen" in x for x in au.pruefen(eine)), au.pruefen(eine))
sechsf = GUT.replace("Zeigt das Bild den Commit?", "Zeigt das Bild den Commit? A? B? C?")
soll("1879: sechs Prüffragen halten an", any("6 Prüffragen" in x for x in au.pruefen(sechsf)), au.pruefen(sechsf))
frage = GUT.replace("Der Zwerg steht auf dem Tisch, nicht darin.", "Steht der Zwerg auf dem Tisch?")
soll("1879: Ziel als Frage hält an", any("Feld 1" in x and "Frage" in x for x in au.pruefen(frage)), au.pruefen(frage))
offen = GUT.replace("Stellfläche aus dem Netz lesen.", "Weg noch offen, TODO.")
soll("1879: „noch offen“, TODO in Umsetzen halten an", any("Feld 5" in x for x in au.pruefen(offen)), au.pruefen(offen))
gefehlt = GUT.replace("Der Zwerg steht auf dem Tisch, nicht darin.", "Der Zwerg steht auf dem Tisch; fehlerhafte Höhe weg.")
soll("1879: „fehlerhaft“ ist kein Fehlwort", au.pruefen(gefehlt) == [], au.pruefen(gefehlt))
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

# 4a 1798: Kern Arbeitsplaner (Feld 6 „Prüfart“, Auftrag oben, Größe in der Vorlage, Rückläufer zu archivierter Nummer)
soll("Feld 6 auch als „Prüfart“", au.pruefen(GUT.replace("Prüfart und Prüfe vor dem Senden:", "Prüfart:")) == [], au.pruefen(GUT.replace("Prüfart und Prüfe vor dem Senden:", "Prüfart:")))
soll("Vorlage nennt die Größe", "2048 Byte" in au.vorlage("9001") and "etwa 2 KB" in au.vorlage("9001"))
os.environ["BORNIM_JETZT"] = ENV["BORNIM_JETZT"] = "21.11., 21:10"
c, t = lauf("auftrag", "9001", "--datei", "-", eingabe=GUT.replace("Stellfläche aus dem Netz lesen.", "Zweiter Auftrag."))
x = datei("9001")
soll("zweiter Auftrag oben, vor dem ersten", c == 0 and 0 < x.find("## Auftrag (21.11., 21:10)") < x.find("## Auftrag (21.11., 20:40)"), (t, x))
sys.path.insert(0, HIER)
import lauf as _lauf, datetime as _dt
ab = _lauf.juengster_auftrag(x, _dt.datetime(2026, 11, 22))
soll("lauf: jüngster Auftrag nach Zeit, nicht nach Ort", ab and "Zweiter Auftrag." in x[ab[0]:ab[1]] and "## Auftrag (21.11., 20:40)" not in x[ab[0]:ab[1]], ab)
alt_unten = "# 1\n\n## Auftrag (20.11., 10:00)\n\nalt\n\n## Rückmeldung\n\nx\n\n## Auftrag (21.11., 10:00)\n\nneu\n"
ab = _lauf.juengster_auftrag(alt_unten, _dt.datetime(2026, 11, 22))
soll("lauf: alte Datei mit Auftrag unten", ab and alt_unten[ab[0]:ab[1]].strip() == "neu", ab)
_vor = open(os.path.join(A, "docs", "LISTE-VORGAENGE.md")).read()  # 1899: scheitert der Push, bleibt die Liste auch lokal unverändert
ENV["BORNIM_OHNE_PUSH"] = "1"; c, t = lauf("auftrag", "8001", "--datei", "-", eingabe=GUT); ENV.pop("BORNIM_OHNE_PUSH")
soll("Rückläufer: Push scheitert, Liste und Archiv unverändert", c != 0 and open(os.path.join(A, "docs", "LISTE-VORGAENGE.md")).read() == _vor
     and "| 8001 |" in open(os.path.join(A, "docs", "LISTE-VORGAENGE-ARCHIV.md")).read() and not g("status", "--porcelain", "docs", cwd=A).strip(), (t, g("status", "--porcelain", cwd=A)))
c, t = lauf("auftrag", "8001", "--datei", "-", eingabe=GUT)
g("fetch", "-q", "origin", cwd=A)
_ol = g("show", "origin/main:docs/LISTE-VORGAENGE.md", cwd=A); _oa = g("show", "origin/main:docs/LISTE-VORGAENGE-ARCHIV.md", cwd=A)
soll("Rückläufer: Liste und Archiv auf origin/main, ein Commit mit dem Auftrag", "| 8001 | Alte Laterne | Tom | M | startbar |" in _ol and "| 8001 |" not in _oa
     and set(g("show", "--name-only", "--format=", "origin/main", cwd=A).split()) == {"docs/LISTE-VORGAENGE.md", "docs/LISTE-VORGAENGE-ARCHIV.md", "docs/vorgang/8001.md"}, t)
liste = open(os.path.join(A, "docs", "LISTE-VORGAENGE.md")).read(); arch = open(os.path.join(A, "docs", "LISTE-VORGAENGE-ARCHIV.md")).read()
soll("archivierte Nummer: wieder offen, Auftrag eingetragen", c == 0 and "| 8001 | Alte Laterne | Tom | M | startbar |" in liste and "| 8001 |" not in arch
     and "## Auftrag (21.11., 21:10)" in datei("8001"), (t, liste[-300:]))
c, t = lauf("auftrag", "8002", "--datei", "-", eingabe=GUT)
soll("Nummer weder in Liste noch Archiv hält an", c != 0 and "nicht im Archiv" in t, t)
g("checkout", "-q", "--", "docs/LISTE-VORGAENGE.md", "docs/LISTE-VORGAENGE-ARCHIV.md", cwd=A)
os.environ["BORNIM_JETZT"] = ENV["BORNIM_JETZT"] = "21.11., 20:40"

# 5 Schließen
c, t = lauf("schliessen", "9002", "erledigt")
soll("Grund zu kurz hält an", c != 0 and "drei Wörtern" in t, t)
c, t = lauf("schliessen", "9002", "doppelt zu 9001, dort gebaut")
x = datei("9002"); liste = open(os.path.join(A, "docs", "LISTE-VORGAENGE.md")).read()
soll("schliessen: Liste erledigt, Grund in Vorgangsdatei", c == 0 and "| 9002 | Schatten im Wald | Spike | M | erledigt |" in liste
     and "Geschlossen (21.11., 20:40): doppelt zu 9001, dort gebaut" in x, (t, x))

print("auftrag_test: " + ("alles grün" if not fehl else "%d Fehler" % fehl))
sys.exit(1 if fehl else 0)
