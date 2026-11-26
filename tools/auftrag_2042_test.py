#!/usr/bin/env python3
"""2042 Fassung 5 (5) (Auftrag 26.11., 15:32): (d) `vorgang.py auftrag NR` zeigt den neuesten Auftrag wörtlich, keine Vorlage,
höchstens fünf Lehren voll, Rest nur als Nummer; Vorlage nur ohne Auftrag. (e) `auftrag NR --datei` (eintragen): danach nur der
neue Auftrag in der Datei, alter Auftrag und erledigte Rückmeldungen wörtlich in archiv/NR.md, Merkmale gleich, ein Commit.
Echtes Git mit nacktem origin. Aufruf: python3 tools/auftrag_2042_test.py"""
import glob, os, subprocess, sys, tempfile
HIER = os.path.dirname(os.path.abspath(__file__))
d = tempfile.mkdtemp(); o = os.path.join(d, "origin.git"); A = os.path.join(d, "a")
def g(*a, cwd=A): return subprocess.run(["git"] + list(a), cwd=cwd, check=True, capture_output=True, text=True).stdout
g("init", "-q", "--bare", "-b", "main", o, cwd=d)
g("clone", "-q", o, A, cwd=d); g("config", "user.email", "t@t"); g("config", "user.name", "t"); g("checkout", "-q", "-b", "main")
os.makedirs(os.path.join(A, "docs", "vorgang", "archiv")); os.makedirs(os.path.join(A, "tools"))
for f in glob.glob(os.path.join(HIER, "*.py")) + [os.path.join(HIER, "kernregeln.txt")]:
    if not f.endswith("_test.py"): os.symlink(f, os.path.join(A, "tools", os.path.basename(f)))
open(os.path.join(A, "docs", "LISTE-VORGAENGE.md"), "w").write(
    "# Vorgangsliste\n\n| Nr. | Titel | Besitzer | Kl. | Stand | wartet auf | Zweig | Build | Bereich | Kosten |\n|---|---|---|---|---|---|---|---|---|---|\n"
    "| 9001 | Zwerg auf dem Tisch | Tom | M | startbar | – | – | – | E Welt | – |\n"
    "| 9002 | Laterne im Hof | Tom | M | startbar | – | – | – | E Welt | – |\n")
open(os.path.join(A, "docs", "LISTE-VORGAENGE-ARCHIV.md"), "w").write(
    "# Archiv\n\n| Nr. | Vorgang | Bereich | Kl. | Kosten | Vorrat | Stand |\n|---|---|---|---|---|---|---|\n")
import importlib.util
_s = importlib.util.spec_from_file_location("lehren_k", os.path.join(HIER, "lehren.py")); _l = importlib.util.module_from_spec(_s)
_s.loader.exec_module(_l)
lehren = "".join("| L%d | E Welt | Zwerg Tisch %d | 9001 | Ursache %d | Lehre %d zum Zwerg | bewährt |\n" % (i, i, i, i) for i in range(1, 9))
open(os.path.join(A, "docs", "LISTE-LEHREN.md"), "w").write(_l.LEER.replace(_l.KOPF_L, _l.KOPF_L + lehren))
ALT = "1. **Ziel:** Alte Fassung: Zwerg sitzt.\n7. **Zurück:** fertig mit Commit.\n"
NEU2 = "1. **Ziel:** Zweite Fassung: Zwerg steht.\n7. **Zurück:** fertig mit Commit.\n"
V = ("# 9001 · Zwerg auf dem Tisch\n\n## Auftrag (21.11., 10:00)\n\n" + ALT + "\n## Auftrag (21.11., 12:00)\n\n" + NEU2 +
     "\n## Chefworte\n\n- **21.11., 09:00**, Chef (`session_C`):\n> Der Zwerg soll stehen.\n\n"
     "## Rückmeldungen\n\nWörtlich, mit Zeit.\n\n"
     "- **21.11., 10:30**, Tom (`session_T`):\n> fertig: Zwerg sitzt, abc1234.\n\n"
     "- **21.11., 10:40**, Prüfer (`session_P`):\n> nein. Zwerg sitzt noch, abc1234.\n\n"
     "- **21.11., 10:50**, Tom (`session_T`):\n> Frage: soll er stehen?\n\n"
     "- **21.11., 11:00**, Arbeitsplaner (`session_A`):\n> Auftrag steht: zweite Fassung folgt.\n\n"
     "- **21.11., 12:30**, Tom (`session_T`):\n> fertig: Zwerg steht, def5678.\n\n"
     "## Stand Tom (21.11., 11:30)\n\nZwerg sitzt noch, Stand überholt.\n\n"
     "## Übergaben\n\n| Ü | an | was | seit | Zustand |\n|---|---|---|---|---|\n"
     "| 9001-Ü1 | Tom | Zwerg aufstellen | 21.11., 10:00 | offen |\n"
     "| 9001-Ü2 | Disponent | von Arbeitsplaner | 21.11., 11:00 | erledigt 21.11., 11:05 session_01Hmoj7A8igQ43P4wp9x2NMj Start session_01Hmoj78hwtJLoxbwoxqpoij |\n")
open(os.path.join(A, "docs", "vorgang", "9001.md"), "w").write(V)
g("add", "-A"); g("commit", "-q", "-m", "start"); g("push", "-q", "origin", "main")
ENV = dict(os.environ, BORNIM_WURZEL=A, BORNIM_JETZT="21.11., 20:40", GIT_AUTHOR_NAME="t", GIT_AUTHOR_EMAIL="t@t",
           GIT_COMMITTER_NAME="t", GIT_COMMITTER_EMAIL="t@t", BORNIM_SITZUNG="session_T")
ENV.pop("BORNIM_OHNE_PUSH", None)
fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else str(zeige)[:1500]))
def lauf(*a, eingabe=None):
    p = subprocess.run([sys.executable, os.path.join(A, "tools", "vorgang.py")] + list(a), env=ENV, capture_output=True, text=True, cwd=A, input=eingabe)
    return p.returncode, p.stdout + p.stderr
def datei(p):
    g("fetch", "-q", "origin")
    try: return g("show", "origin/main:" + p)
    except subprocess.CalledProcessError: return ""

# (d) neuester Auftrag statt Vorlage
c, t = lauf("auftrag", "9001")
soll("auftrag 9001: Exit 0", c == 0, t)
soll("zeigt den neuesten Auftrag wörtlich", "## Auftrag (21.11., 12:00)" in t and NEU2.strip() in t, t)
soll("nicht den alten Auftrag", "Alte Fassung" not in t, t)
soll("keine Vorlage", "1. **Ziel:**\n" not in t and "(was der Spieler sieht" not in t, t)
voll = [z for z in t.splitlines() if z.startswith("- L")]
soll("höchstens fünf Lehren voll", 1 <= len(voll) <= 5, voll)
soll("weitere Lehren nur als Nummer", "L6" in t and "Lehre 6 zum Zwerg" not in t, t)
c, t = lauf("auftrag", "9002")
soll("ohne Auftrag: Vorlage", c == 0 and "1. **Ziel:**" in t and "Laterne im Hof" in t, t)

# (e) eintragen: alter Auftrag und erledigte Rückmeldungen ins Archiv, ein Commit
import importlib
sys.path.insert(0, os.path.join(A, "tools")); os.environ.update(ENV)
import uebergabe as ue, rueckmeldung as rm
rm._ARCHIV.clear()
vor = ue._merkmale(V, "9001")
kopf = g("rev-parse", "origin/main").strip()
NEU = open(os.path.join(HIER, "auftrag_test.py"), encoding="utf-8").read().split('GUT = """', 1)[1].split('"""', 1)[0]
c, t = lauf("auftrag", "9001", "--datei", "-", eingabe=NEU)
soll("eintragen: Exit 0", c == 0, t)
n = datei("docs/vorgang/9001.md"); a = datei("docs/vorgang/archiv/9001.md")
soll("ein Commit", g("rev-list", "--count", "%s..origin/main" % kopf).strip() == "1", g("log", "--oneline", "-3", "origin/main"))
soll("nur der neue Auftrag in der Datei", n.count("## Auftrag (") == 1 and "## Auftrag (21.11., 20:40)" in n, n)
soll("alte Fassungen wörtlich im Archiv", ALT.strip() in a and NEU2.strip() in a, a)
for k, w in (("10:30", "fertig: Zwerg sitzt"), ("11:00", "Auftrag steht: zweite"), ("12:30", "fertig: Zwerg steht")):
    soll("erledigte Rückmeldung %s im Archiv, nicht in der Datei" % k, w in a and w not in n, (n, a))
for w in ("nein. Zwerg sitzt", "Frage: soll er", "Der Zwerg soll stehen"):
    soll("bleibt in der Datei: " + w, w in n, n)
soll("Übergabezeile bleibt", "9001-Ü1" in n, n)
soll("Stand älter als der Auftrag im Archiv (Sokrates 16:15)", "Stand überholt" in a and "Stand überholt" not in n, n)
soll("erledigte Zeile kurz: wer, wann, Ergebnis", "| 9001-Ü2 | Disponent | von Arbeitsplaner | 21.11., 11:00 | erledigt 21.11., 11:05 …9x2NMj Start …xqpoij |" in n and "session_01Hmoj7A8igQ43P4wp9x2NMj Start" in a, (n, a))
rm._ARCHIV.clear(); rm._ARCHIV["archiv/9001.md"] = a
nach = ue._merkmale(n, "9001")
soll("Merkmale gleich außer neuestem Auftrag", vor[:4] == nach[:4] and vor[5] == nach[5], (vor, nach))
c, t = lauf("auftrag", "9001")
soll("auftrag danach zeigt den neuen Auftrag", "## Auftrag (21.11., 20:40)" in t and "Zwerg steht auf dem Tisch" in t, t)

print("AUFTRAG2042 %d FEHL" % fehl)
sys.exit(1 if fehl else 0)
