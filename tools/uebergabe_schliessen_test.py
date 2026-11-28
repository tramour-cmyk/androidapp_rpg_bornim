#!/usr/bin/env python3
"""2012 (Bauliste Sokrates 23.11., 23:01; Chef 23.11., 23:00 „1 bis 4 ja“): offene Übergabezeilen schließen, eine Funktion für alle Orte
(uebergabe.schliessen_nr). Teilnummern exakt (9001.2 schließt nichts von 9001), nur Zeilen bis zum Zeitpunkt „bis“, zwei gleichzeitige
Aufrufe verlieren keine Zeile. Echtes Git mit nacktem origin und zwei Kopien. Aufruf: python3 tools/uebergabe_schliessen_test.py"""
import os, subprocess, sys, tempfile
from concurrent.futures import ThreadPoolExecutor
HIER = os.path.dirname(os.path.abspath(__file__))
d = tempfile.mkdtemp(); o = os.path.join(d, "origin.git"); A = os.path.join(d, "a"); B = os.path.join(d, "b")
def g(*a, cwd=None): return subprocess.run(["git"] + list(a), cwd=cwd, check=True, capture_output=True, text=True).stdout
g("init", "-q", "--bare", "-b", "main", o)
g("clone", "-q", o, A); g("config", "user.email", "t@t", cwd=A); g("config", "user.name", "t", cwd=A); g("checkout", "-q", "-b", "main", cwd=A)
os.makedirs(os.path.join(A, "docs", "vorgang")); os.makedirs(os.path.join(A, "tools"))
for f in ("uebergabe.py", "startbar.py", "bereiche.py", "vorgang.py", "auftrag.py", "chefwort.py", "rueckmeldung.py", "streichen.py", "lehren.py"):
    if os.path.exists(os.path.join(HIER, f)): os.symlink(os.path.join(HIER, f), os.path.join(A, "tools", f))
KOPF = "## Übergaben\n\n| Ü | an | was | seit | Zustand |\n|---|---|---|---|---|\n"
def zeile(nr, k, an, was, seit, zu="offen"): return "| %s-Ü%d | %s | %s | %s | %s |\n" % (nr, k, an, was, seit, zu)
V9001 = ("# 9001 · Zwerg auf dem Tisch\n\n" + KOPF
         + zeile("9001", 1, "Disponent", "Auftrag steht (Rückmeldung 23.11., 10:00 von Arbeitsplaner): Fachkraft nach Profil des Auftrags starten (1797)", "23.11., 10:00")
         + zeile("9001", 2, "Disponent", "Nachfolger: Kampf für 9001 auf Zweig x", "23.11., 10:05", "angenommen session_ALT bis 23.11., 10:35")
         + zeile("9001", 3, "Disponent", "Hinweis (Rückmeldung 23.11., 10:10 von Sokrates): wie einen Eingang behandeln (1739)", "23.11., 10:10")
         + zeile("9001", 4, "Kampf", "Rückläufer (nein des Prüfers, Rückmeldung 23.11., 10:20 von Prüfer): „Satz“ (1739)", "23.11., 10:20")
         + zeile("9001", 5, "Prüfer", "prüfen: „fertig“ (Rückmeldung 23.11., 10:30 von Kampf) (1739)", "23.11., 10:30")
         + zeile("9001", 6, "Disponent", "Auftrag steht (Rückmeldung 23.11., 09:00 von Arbeitsplaner): starten (1797)", "23.11., 09:00", "erledigt 23.11., 09:30 session_X")
         + zeile("9001", 7, "Disponent", "Auftrag steht (Rückmeldung 23.11., 12:00 von Arbeitsplaner): starten (1797)", "23.11., 12:00")
         + zeile("9001", 8, "Disponent", "Nachfolger: Technik für 9001", "23.11., 10:40", "steckt fest (Frist abgelaufen 23.11., 11:40, session_Y)"))
V9001_2 = "# 9001.2 · Zwerg, Teil 2\n\n" + KOPF + zeile("9001.2", 1, "Disponent", "Auftrag steht (Rückmeldung 23.11., 10:00 von Arbeitsplaner): starten (1797)", "23.11., 10:00")
open(os.path.join(A, "docs", "vorgang", "9001.md"), "w").write(V9001)
open(os.path.join(A, "docs", "vorgang", "9001.2.md"), "w").write(V9001_2)
for nr, zs in (("9004", [(1, "Disponent", "Auftrag steht (Rückmeldung 23.11., 10:00 von Arbeitsplaner): starten (1797)"), (2, "Disponent", "Hinweis (Rückmeldung 23.11., 10:01 von Sokrates): wie einen Eingang behandeln (1739)"),
                             (3, "Kampf", "Rückläufer (nein des Prüfers, Rückmeldung 23.11., 10:02 von Prüfer): „Satz“ (1739)")]),
               ("9004.2", [(1, "Disponent", "Auftrag steht (Rückmeldung 23.11., 10:00 von Arbeitsplaner): starten (1797)")]),
               ("9005", [(1, "Disponent", "Nachfolger: Kampf für 9005 auf Zweig y")]),
               ("9006", [(1, "Disponent", "Auftrag steht (Rückmeldung 23.11., 10:00 von Arbeitsplaner): starten (1797)")])):
    open(os.path.join(A, "docs", "vorgang", nr + ".md"), "w").write("# %s · Test\n\n" % nr + KOPF + "".join(zeile(nr, k, an, w, "23.11., 10:0%d" % k) for k, an, w in zs))
HW = "Hinweis (Rückmeldung 23.11., 10:01 von Sokrates): wie einen Eingang behandeln (1739)"
for nr in ("9007", "9007.2", "9008", "9009", "9010"):
    open(os.path.join(A, "docs", "vorgang", nr + ".md"), "w").write("# %s · Test\n\n" % nr + KOPF + zeile(nr, 1, "Disponent", HW, "23.11., 10:01")
        + zeile(nr, 2, "Kampf", "Rückläufer (nein des Prüfers): „Satz“ (1739)", "23.11., 10:02") + zeile(nr, 3, "Prüfer", "prüfen: „fertig“ (1739)", "23.11., 10:03", "angenommen session_P bis 23.11., 10:33"))
open(os.path.join(A, "docs", "LISTE-VORGAENGE.md"), "w").write(
    "# Vorgangsliste\n\n| Nr. | Titel | Besitzer | Kl. | Stand | wartet auf | Zweig | Build | Bereich | Kosten |\n|---|---|---|---|---|---|---|---|---|---|\n"
    + "".join("| %s | Test %s | Tom | M | startbar | – | – | – | E Welt | – |\n" % (n, n) for n in ("9001", "9004", "9004.2", "9005", "9006", "9007", "9007.2", "9008", "9009", "9010")))
open(os.path.join(A, "docs", "vorgang", "9002.md"), "w").write("# 9002 · Schatten\n\n" + KOPF + "".join(
    zeile("9002", k, "Disponent", "Auftrag steht (Rückmeldung 23.11., 10:0%d von Arbeitsplaner): starten (1797)" % k, "23.11., 10:0%d" % k) for k in range(1, 7)))
g("add", "-A", cwd=A); g("commit", "-q", "-m", "start", cwd=A); g("push", "-q", "origin", "main", cwd=A)
g("clone", "-q", o, B); g("config", "user.email", "t@t", cwd=B); g("config", "user.name", "t", cwd=B)
ENV = dict(os.environ, BORNIM_WURZEL=A, BORNIM_JETZT="23.11., 13:00", GIT_AUTHOR_NAME="t", GIT_AUTHOR_EMAIL="t@t",
           GIT_COMMITTER_NAME="t", GIT_COMMITTER_EMAIL="t@t", BORNIM_SITZUNG="session_T")
ENV.pop("BORNIM_OHNE_PUSH", None)
os.environ.update(ENV)
sys.path.insert(0, os.path.join(A, "tools"))
import uebergabe as ue
fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else zeige))
def datei(nr):
    g("fetch", "-q", "origin", cwd=A); return g("show", "origin/main:docs/vorgang/%s.md" % nr, cwd=A)
def archiv(nr):  # 2060: erledigte Zeilen stehen nur im Archiv
    g("fetch", "-q", "origin", cwd=A)
    try: return g("show", "origin/main:docs/vorgang/archiv/%s.md" % nr, cwd=A)
    except subprocess.CalledProcessError: return ""
def zu(nr, k): return next(z["z"] for z in ue.zeilen(datei(nr) + "\n" + archiv(nr)) if z["k"] == "%s-Ü%d" % (nr, k))
def py(kopie, code):
    env = dict(ENV, BORNIM_WURZEL=kopie)
    p = subprocess.run([sys.executable, "-c", "import sys; sys.path.insert(0, %r); import uebergabe as ue; %s" % (os.path.join(A, "tools"), code)],
                       env=env, capture_output=True, text=True)
    return p.returncode, p.stdout + p.stderr

# (1) Zeilenart aus „was“
soll("art: Auftrag steht, Nachfolger, Hinweis, Rückläufer, sonst None",
     [ue.art(x) for x in ("Auftrag steht (…)", "Nachfolger: Kampf", "Hinweis (…)", "Rückläufer (nein …)", "prüfen: „fertig“", "Auftrag für Werkzeug schreiben")]
     == ["Auftrag steht", "Nachfolger", "Hinweis", "Rückläufer", None, None])

# (1) Start-Arten bis 11:00: Ü1 (offen) und Ü2 (angenommen) zu; Ü8 (steckt fest) auch; Ü7 jünger als bis: bleibt; Hinweis, Rückläufer, prüfen bleiben
import datetime
k = ue.schliessen_nr("9001", ue.START_ARTEN, "Start angekommen 11:00 (lauf.py, 2012)", bis=datetime.datetime(2026, 11, 23, 11, 0))
soll("schliessen_nr gibt die geschlossenen Kennungen zurück", k == ["9001-Ü1", "9001-Ü2", "9001-Ü8"], k)
soll("Zustand „erledigt <Zeit> (<Grund>)“", zu("9001", 1) == "erledigt 23.11., 13:00 (Start angekommen 11:00 (lauf.py, 2012))", zu("9001", 1))
soll("angenommene Zeile auch zu", zu("9001", 2).startswith("erledigt 23.11., 13:00"), zu("9001", 2))
soll("Hinweis, Rückläufer, prüfen bleiben offen", [zu("9001", i) for i in (3, 4, 5)] == ["offen"] * 3, datei("9001"))
soll("schon erledigte Zeile unverändert", zu("9001", 6) == "erledigt 23.11., 09:30 session_X", zu("9001", 6))
soll("Zeile nach „bis“ bleibt offen", zu("9001", 7) == "offen", zu("9001", 7))
soll("Teilnummer exakt: 9001.2 unberührt", datei("9001.2") == V9001_2, datei("9001.2"))
k = ue.schliessen_nr("9001.2", None, "Vorgang 9001.2 erledigt")
soll("9001.2 schließt nur 9001.2", k == ["9001.2-Ü1"] and zu("9001", 3) == "offen" and zu("9001", 7) == "offen", (k, datei("9001")))
n = g("rev-list", "--count", "origin/main", cwd=A)
k = ue.schliessen_nr("9001", ue.START_ARTEN, "nochmal", bis=datetime.datetime(2026, 11, 23, 11, 0))
soll("zweiter Aufruf: nichts, kein Commit", k == [] and g("rev-list", "--count", "origin/main", cwd=A) == n, k)
k = ue.schliessen_nr("9003", None, "Datei fehlt")
soll("Vorgang ohne Datei: nichts, keine Datei angelegt", k == [] and "9003.md" not in g("ls-tree", "--name-only", "origin/main", "docs/vorgang/", cwd=A))
k = ue.schliessen_nr("9001", None, "Vorgang 9001 erledigt (vorgang.py fertig)")
soll("arten None: alle offenen Zeilen zu", k == ["9001-Ü3", "9001-Ü4", "9001-Ü5", "9001-Ü7"] and not [z for z in ue.zeilen(datei("9001") + "\n" + archiv("9001")) if not z["z"].startswith("erledigt")], k)

# (1) zwei gleichzeitige schliessen_nr aus zwei Kopien (je drei Zeilen) und eine gleichzeitige neue Übergabe: keine Zeile verloren
with ThreadPoolExecutor(3) as ex:
    r = list(ex.map(lambda a: py(*a), [
        (A, "print(ue.schliessen_nr('9002', None, 'A', bis=__import__('datetime').datetime(2026, 11, 23, 10, 3)))"),
        (B, "print(ue.schliessen_nr('9002', ue.START_ARTEN, 'B'))"),
        (B, "ue.uebergabe('9002', 'Prüfer', 'neu dazu')")]))
t = datei("9002"); ta = archiv("9002"); zs = {z["k"]: z["z"] for z in ue.zeilen(t + "\n" + ta)}  # 2060: erledigte im Archiv
soll("gleichzeitig: alle Aufrufe ohne Fehler", all(c == 0 for c, _ in r), r)
soll("gleichzeitig: 7 Zeilen, keine verloren, keine doppelt", sorted(zs) == ["9002-Ü%d" % i for i in range(1, 8)] and (t + ta).count("| 9002-Ü") == 7, (t, ta))
soll("gleichzeitig: Ü1–Ü6 zu, neue Zeile Ü7 offen", all(zs["9002-Ü%d" % i].startswith("erledigt") for i in range(1, 7)) and zs["9002-Ü7"] == "offen", zs)

# (3) rueckmeldung.py: „fertig“, „Laufanforderung“ (mit Commit), „steckt fest“ schließen Auftrag steht/Nachfolger der Nummer im selben
# Commit (Fall 1068 Ü10/Ü11: Ü10 „Auftrag steht“ blieb offen neben Ü11 „prüfen: fertig“); Hinweise und Rückläufer bleiben bis
# vorgang.py fertig (4); die neue Zeile der Rückmeldung bleibt offen
import rueckmeldung as rm
n = g("rev-list", "--count", "origin/main", cwd=A)
k, _ = rm.eintragen("9004", "fertig (Rückläufer 9004-Ü3): Tipp nennt den Ring, Commit 1a2b3c4d", "Kampf")
soll("fertig: Auftrag steht zu, im selben Commit", zu("9004", 1).startswith("erledigt 23.11., 13:00 (fertig")
     and int(g("rev-list", "--count", "origin/main", cwd=A)) == int(n) + 1, datei("9004"))
soll("fertig: Hinweis und Rückläufer bleiben offen (erst vorgang.py fertig)", zu("9004", 2) == "offen" and zu("9004", 3) == "offen", datei("9004"))
soll("fertig: neue Zeile an den Prüfer offen", k == "9004-Ü4" and zu("9004", 4) == "offen" and "| 9004-Ü4 | Prüfer |" in datei("9004"), datei("9004"))
soll("fertig 9004: 9004.2 unberührt", zu("9004.2", 1) == "offen", datei("9004.2"))
rm.eintragen("9005", "steckt fest: Kamera hängt, Ursache unklar", "Kampf")
soll("steckt fest: Nachfolger zu, neue Zeile an Sokrates offen", zu("9005", 1).startswith("erledigt") and zu("9005", 2) == "offen" and "| 9005-Ü2 | Sokrates |" in datei("9005"), datei("9005"))
rm.eintragen("9006", "Laufanforderung: Sitzung brach ab, Ursache Speicher", "Kampf")
soll("Laufanforderung ohne Commit (zurückgewiesen): nichts zu", zu("9006", 1) == "offen", datei("9006"))
rm.eintragen("9006", "Laufanforderung: Sitzung brach ab, Ursache Speicher, behoben in 1a2b3c4d", "Kampf")
soll("Laufanforderung mit Commit: Auftrag steht zu, Zeile an den Prüfer offen", zu("9006", 1).startswith("erledigt") and "| 9006-Ü2 | Prüfer |" in datei("9006") and zu("9006", 2) == "offen", datei("9006"))

# (4) vorgang.py fertig und vorgang.py schliessen schließen alle offenen Zeilen der Nummer (auch Hinweis, Rückläufer, angenommene);
# nicht bei rest_sperre (Rest ohne Folgevorgang); 9007.2 bleibt bei fertig 9007
def vg(*a):
    p = subprocess.run([sys.executable, os.path.join(A, "tools", "vorgang.py")] + list(a), cwd=A, env=ENV, capture_output=True, text=True)
    return p.returncode, p.stdout + p.stderr
def alle_zu(nr): return all(z["z"].startswith("erledigt") for z in ue.zeilen(datei(nr)))
c, out = vg("fertig", "9007")
soll("fertig: alle Zeilen zu (Hinweis 2012-Ü1/Ü2-Fall, Rückläufer, angenommen)", c == 0 and alle_zu("9007") and "(Vorgang 9007 erledigt" in zu("9007", 1), (out, datei("9007")))
soll("fertig 9007: 9007.2 bleibt offen", not alle_zu("9007.2") and zu("9007.2", 1) == "offen", datei("9007.2"))
soll("fertig: Ausgabe nennt geschlossene Zeilen", "9007-Ü1" in out and "9007-Ü3" in out, out)
g("pull", "-q", "--rebase", "origin", "main", cwd=B); open(os.path.join(B, "code9008.txt"), "w").write("x\n")
g("add", "code9008.txt", cwd=B); g("commit", "-q", "-m", "9008: Teil gebaut\n\nRest: Kamera braucht noch Licht", cwd=B); g("push", "-q", "origin", "main", cwd=B); g("fetch", "-q", "origin", cwd=A)
c, out = vg("fertig", "9008")
soll("rest_sperre: fertig hält an, keine Zeile zu", c != 0 and "1143" in out and not [z for z in ue.zeilen(datei("9008")) if z["z"].startswith("erledigt")], (out, datei("9008")))
c, out = vg("schliessen", "9009", "doppelt zu 9001, dort gebaut")
soll("schliessen: alle Zeilen zu, Grund in der Datei", c == 0 and alle_zu("9009") and "Geschlossen (23.11., 13:00): doppelt zu 9001" in datei("9009"), (out, datei("9009")))

c, out = vg("stand", "9010", "erledigt")
soll("stand erledigt: alle Zeilen zu", c == 0 and alle_zu("9010"), (out, datei("9010")))

print("uebergabe_schliessen_test: %s" % ("alles grün" if not fehl else "%d FEHL" % fehl))
sys.exit(1 if fehl else 0)
