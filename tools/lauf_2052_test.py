#!/usr/bin/env python3
"""2052 (Chef 26.11., 12:33, 12:44): Kür ruht, solange über alle Rollen ein Muss oder Eilt startbar ist. Fälle an einer Liste nur
aus Testzeilen (Kopie von tools/ und docs/, Lauf am 26.11., 14:00, ohne Netz, ohne Push):
(1) Kampf nur Kür, Figur startbares Muss → kein START Kampf, Zeile „NUR MUSS“, START Figur;
(2) nirgends Muss/Eilt → Kür startet, keine Zeile „NUR MUSS“; (3) Figur Eilt → Kür ruht, Eilt startet;
(4) Figur Muss nur gesperrt (ruht) → zählt nicht, Kür startet.
Dazu Rollenzeile startbar.py und vorgang.py --rolle (mit --alle alles): K-Zeilen nur als Zahl, solange Muss startbar ist.
Aufruf: python3 tools/lauf_2052_test.py"""
import datetime, glob, os, re, shutil, subprocess, sys, tempfile
H = os.path.dirname(os.path.abspath(__file__)); W = os.path.dirname(H)
sys.path.insert(0, H); sys.argv = sys.argv[:1]

fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else str(zeige)[-1500:]))

AUFTRAG = open(os.path.join(W, "docs", "vorgang", "2006.md"), encoding="utf-8").read().split("## Auftrag (23.11., 22:09)\n", 1)[1].split("\n## ", 1)[0]
def datei(nr):
    return "# %s · Test 2052\n\n## Auftrag (23.11., 22:09)\n%s\n" % (nr, AUFTRAG)

# Block 2 = Kampf, 3 = Figur (themenbloecke)
FAELLE = {
    "1 Kampf Kür, Figur Muss": [("9201", 2, "E Kampf", "K", "startbar"), ("9202", 3, "E Figuren", "M", "startbar")],
    "2 nirgends Muss": [("9201", 2, "E Kampf", "K", "startbar"), ("9203", 3, "E Figuren", "K", "startbar")],
    "3 Figur Eilt": [("9201", 2, "E Kampf", "K", "startbar"), ("9204", 3, "E Figuren", "Eilt", "startbar")],
    "4 Figur Muss gesperrt": [("9201", 2, "E Kampf", "K", "startbar"), ("9205", 3, "E Figuren", "M", "ruht, Test 2052")],
}

d = tempfile.mkdtemp(prefix="lauf-2052-")
try:
    A = os.path.join(d, "A"); os.makedirs(os.path.join(A, "tools"))
    shutil.copytree(os.path.join(W, "docs"), os.path.join(A, "docs"))
    for p in glob.glob(os.path.join(H, "*")):
        if os.path.isfile(p): shutil.copy2(p, os.path.join(A, "tools"))
    b = os.path.join(A, "docs", "ARBEIT-BETRIEB.md")
    t = open(b, encoding="utf-8").read()
    open(b, "w", encoding="utf-8").write("".join(l for l in t.splitlines(True) if "Startsperre " not in l))
    li = os.path.join(A, "docs", "LISTE-VORGAENGE.md")
    LISTE = open(li, encoding="utf-8").read()
    SEP = "|---|---|---|---|---|---|---|---|---|---|---|---|\n"
    kopf, rest = LISTE.split(SEP, 1)
    rest = re.sub(r"\A(\|[^\n]*\n)+", "", rest)  # alle echten Zeilen raus: nur Testzeilen
    for n in ("9201", "9202", "9203", "9204", "9205"):
        open(os.path.join(A, "docs", "vorgang", "%s.md" % n), "w", encoding="utf-8").write(datei(n))
    ENV = dict(os.environ, GIT_AUTHOR_NAME="t", GIT_AUTHOR_EMAIL="t@t", GIT_COMMITTER_NAME="t", GIT_COMMITTER_EMAIL="t@t", BORNIM_OHNE_PUSH="1",
               BORNIM_WARN_STAND=os.path.join(d, "warn.json"), BORNIM_MELDUNGEN=os.path.join(d, "meldungen.tsv"), BORNIM_SITZUNG="session_test2052")
    for k in ("BORNIM_WURZEL", "BORNIM_JETZT", "GIT_DIR", "GIT_WORK_TREE", "GIT_INDEX_FILE"): ENV.pop(k, None)
    open(ENV["BORNIM_MELDUNGEN"], "w").close()
    subprocess.run(["git", "init", "-q", "-b", "main"], cwd=A, env=ENV, capture_output=True)
    seite = os.path.join(d, "seite.txt")
    open(seite, "w", encoding="utf-8").write("# has_more: nein\n")
    prog = ("import datetime, sys; sys.path.insert(0, 'tools'); sys.argv = ['lauf.py', '--ohne-pull', %r]\n"
            "import lauf\nlauf.JETZT = datetime.datetime(2026, 11, 26, 14, 0, tzinfo=lauf.BERLIN)\n"
            "lauf.protokoll_pushen = lambda f, n: (print('GEPUSHT-TEST ' + n), True)[1]\nlauf.herzschlag_pushen = lambda leb: None\n"
            "import guthaben\nguthaben.Bremse.erlaubt = lambda *a, **k: None  # Laufsperre prüft laufbremse_test\nlauf.main()\n") % seite
    for name, zeilen in FAELLE.items():
        neu = "".join("| %s | Test 2052 %s | %d | %s | %s | – | – | – | *%s* | *–* | *0* | *–* |\n" % (n, n, bl, ber, kl, s) for n, bl, ber, kl, s in zeilen)
        open(li, "w", encoding="utf-8").write(kopf + SEP + neu + rest)
        for c in (["add", "-A"], ["commit", "-q", "-m", name]):
            subprocess.run(["git"] + c, cwd=A, env=ENV, capture_output=True)
        r = subprocess.run([sys.executable, "-c", prog], cwd=A, env=ENV, capture_output=True, text=True, timeout=600)
        zl = r.stdout.splitlines()
        soll("%s: Lauf ohne Absturz" % name, r.returncode == 0, r.stderr[-1500:])
        start = lambda rolle, n: any(l.startswith("START %s |" % rolle) and n in l for l in zl)
        nm = [l for l in zl if l.startswith("NUR MUSS")]
        zeig = [l[:140] for l in zl if l.startswith(("START", "NICHTS", "NUR MUSS"))]
        if name.startswith("1"):
            soll("1: kein START Kampf mit Kür 9201", not start("Kampf", "9201"), zeig)
            soll("1: START Figur mit Muss 9202", start("Figur", "9202"), zeig)
            soll("1: Zeile „NUR MUSS: 1 Muss/Eilt startbar, Kür ruht (2052)“", nm == ["NUR MUSS: 1 Muss/Eilt startbar, Kür ruht (2052)"], nm or zeig)
        elif name.startswith("2"):
            soll("2: START Kampf mit Kür 9201", start("Kampf", "9201"), zeig)
            soll("2: START Figur mit Kür 9203", start("Figur", "9203"), zeig)
            soll("2: keine Zeile „NUR MUSS“", not nm, nm)
        elif name.startswith("3"):
            soll("3: START Figur mit Eilt 9204", start("Figur", "9204"), zeig)
            soll("3: kein START Kampf mit Kür 9201", not start("Kampf", "9201"), zeig)
            soll("3: Zeile „NUR MUSS“", len(nm) == 1, zeig)
        else:
            soll("4: gesperrtes Muss hält Kür nicht: START Kampf 9201", start("Kampf", "9201"), zeig)
            soll("4: keine Zeile „NUR MUSS“", not nm, nm)
        if name.startswith("1"):  # Rollenzeile und vorgang.py, gleicher Stand wie Fall 1
            q = subprocess.run([sys.executable, "tools/startbar.py"], cwd=A, env=ENV, capture_output=True, text=True, timeout=300)
            soll("1: startbar.py Rollenzeile Kampf zeigt Kür nur als Zahl", "Kampf: Muss – | Kür: 1 ruht" in q.stdout and "9201" not in q.stdout
                 and "NUR MUSS: 1 Muss/Eilt startbar" in q.stdout, q.stdout[:800] + q.stderr[-500:])
            q = subprocess.run([sys.executable, "tools/startbar.py", "--alle"], cwd=A, env=ENV, capture_output=True, text=True, timeout=300)
            soll("1: startbar.py --alle zeigt Kür 9201", "Kampf: Muss – | Kür 9201" in q.stdout, q.stdout[:800] + q.stderr[-500:])
            q = subprocess.run([sys.executable, "tools/vorgang.py", "--rolle", "Kampf"], cwd=A, env=ENV, capture_output=True, text=True, timeout=300)
            soll("1: vorgang.py --rolle Kampf: K-Zeile 9201 nur als Zahl", "9201" not in q.stdout and "Kür: 1 ruht" in q.stdout, q.stdout[-800:] + q.stderr[-500:])
            q = subprocess.run([sys.executable, "tools/vorgang.py", "--rolle", "Figur"], cwd=A, env=ENV, capture_output=True, text=True, timeout=300)
            soll("1: vorgang.py --rolle Figur zeigt Muss 9202", "9202 | M |" in q.stdout, q.stdout[-800:] + q.stderr[-500:])
            q = subprocess.run([sys.executable, "tools/vorgang.py", "--rolle", "Kampf", "--alle"], cwd=A, env=ENV, capture_output=True, text=True, timeout=300)
            soll("1: vorgang.py --rolle Kampf --alle zeigt 9201", "9201 | K |" in q.stdout, q.stdout[-800:] + q.stderr[-500:])
        if name.startswith("2"):
            q = subprocess.run([sys.executable, "tools/vorgang.py", "--rolle", "Kampf"], cwd=A, env=ENV, capture_output=True, text=True, timeout=300)
            soll("2: vorgang.py --rolle Kampf zeigt Kür 9201 ohne Muss", "9201 | K |" in q.stdout and "ruht" not in q.stdout, q.stdout[-800:] + q.stderr[-500:])
            q = subprocess.run([sys.executable, "tools/startbar.py"], cwd=A, env=ENV, capture_output=True, text=True, timeout=300)
            soll("2: startbar.py Rollenzeile Kampf zeigt Kür 9201", "Kampf: Muss – | Kür 9201" in q.stdout and "NUR MUSS" not in q.stdout, q.stdout[:800])
finally:
    shutil.rmtree(d, ignore_errors=True)

print("lauf_2052_test: %s" % ("alles grün" if not fehl else "%d FEHL" % fehl))
sys.exit(1 if fehl else 0)
