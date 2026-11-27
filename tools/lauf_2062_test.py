#!/usr/bin/env python3
"""2062 (Chef 27.11., 11:07; „Startblock ja, V7 genauso“ 22.11., 11:09): jede START-Zeile trägt wieder Ladetext (Kern, Fachprofil,
Querprofile) und Auftrag wörtlich, im Takt und bei `lauf.py --start`; keine einzelne Rollenzeile mehr in der Nachricht.
Der Disponent sieht auf der Konsole weiter die gekürzte Zeile (KURZ_TAT plus „… (voll: sed -n Np <Restdatei>)“), die Restdatei
trägt die Zeile ungekürzt; aus ihr kommt der Text für create_session. Ohne Netz, ohne Push. Aufruf: python3 tools/lauf_2062_test.py"""
import glob, os, re, shutil, subprocess, sys, tempfile
H = os.path.dirname(os.path.abspath(__file__)); W = os.path.dirname(H)
sys.path.insert(0, H); sys.argv = sys.argv[:1]
import lauf

fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else str(zeige)[:600]))

AUFTRAG = ("1. **Ziel:** WOERTLICH-2062 Probe für den Startblock.\n2. **Systemfrage:** kein neuer Weg.\n3. **Bisher:** nichts.\n"
           "4. **Beachte:** Profil Werkzeug; Querprofil Fremde Inhalte.\n5. **Umsetzen:** Zweig claude/probe.\n"
           "6. **Prüfart und Prüfe vor dem Senden:** Test am Rechner. (1) Läuft der Test? (2) Ist er grün? (3) Steht der Auftrag wörtlich?\n7. **Zurück:** fertig per vorgang.py.")
def datei(nr): return "# %s · Test 2062\n\n## Auftrag (27.11., 11:07)\n\n%s\n\n## Chefworte\n" % (nr, AUFTRAG)

def pruefe_start(was, st, rolle, nr, docs):
    soll("%s: START-Zeile da" % was, bool(st), st)
    if not st: return
    msg = st.split(" | ", 6)[6].replace("\\n", "\n")
    k, auftrag = lauf._block(rolle, nr, docs)
    soll("%s: Ladetext (Kern, Profil, Querprofile) wörtlich" % was, k and k in msg, msg[:300])
    for n, _ in lauf.startblock(rolle, nr, docs)[0]: soll("%s: Teil **%s**" % (was, n), "**%s**\n" % n in msg, msg[:300])
    soll("%s: Auftrag wörtlich aus docs/vorgang/%s.md" % (was, nr), auftrag and AUFTRAG in auftrag and auftrag in msg, msg[-600:])
    soll("%s: kein Kurzaufruf --startblock" % was, "--startblock" not in msg, msg[:300])
    soll("%s: keine einzelne Rollenzeile „%s“" % (was, rolle), not re.search(r"(?m)^%s$" % rolle, msg), msg)
    soll("%s: Kaufrepo-Satz bleibt" % was, "add_repo" in msg, msg[-300:])
    soll("%s: kein echter Zeilenumbruch" % was, "\n" not in st)

d = tempfile.mkdtemp(prefix="lauf-2062-")
try:
    # (1) lauf.py --start Werkzeug NR (start_zeilen) an Testdocs
    dd = os.path.join(d, "docs"); os.makedirs(os.path.join(dd, "vorgang"))
    shutil.copytree(os.path.join(lauf.DOCS, "profile"), os.path.join(dd, "profile"))
    open(os.path.join(dd, "vorgang", "9301.md"), "w", encoding="utf-8").write(datei("9301"))
    lauf.neue_liste()
    zs = lauf.start_zeilen("Werkzeug", "9301", "Bau das Werkzeug.", [], docs=dd)
    st = next((z for z in zs if z.startswith("START ")), "")
    pruefe_start("(1) --start Werkzeug 9301", st, "Werkzeug", "9301", dd)
    soll("(1) Nachricht bleibt", "Bau das Werkzeug." in st, st[-300:])
    print("BYTE --start Werkzeug 9301: %d" % len(st.encode()))

    # (2) Takt: Kopie von tools/ und docs/, eine startbare Zeile 9302 (Figur), Konsole gekürzt, Restdatei ganz
    A = os.path.join(d, "A"); os.makedirs(os.path.join(A, "tools"))
    shutil.copytree(os.path.join(W, "docs"), os.path.join(A, "docs"))
    for p in glob.glob(os.path.join(H, "*")):
        if os.path.isfile(p): shutil.copy2(p, os.path.join(A, "tools"))
    b = os.path.join(A, "docs", "ARBEIT-BETRIEB.md")
    t = open(b, encoding="utf-8").read()
    open(b, "w", encoding="utf-8").write("".join(l for l in t.splitlines(True) if "Startsperre " not in l))
    li = os.path.join(A, "docs", "LISTE-VORGAENGE.md")
    SEP = "|---|---|---|---|---|---|---|---|---|---|---|---|\n"
    kopf, rest = open(li, encoding="utf-8").read().split(SEP, 1)
    rest = re.sub(r"\A(\|[^\n]*\n)+", "", rest)
    open(li, "w", encoding="utf-8").write(kopf + SEP + "| 9302 | Test 2062 9302 | 3 | E Figuren | M | – | – | – | *startbar* | *–* | *0* | *–* |\n" + rest)
    open(os.path.join(A, "docs", "vorgang", "9302.md"), "w", encoding="utf-8").write(datei("9302"))
    rd = os.path.join(d, "rest.txt")
    ENV = dict(os.environ, GIT_AUTHOR_NAME="t", GIT_AUTHOR_EMAIL="t@t", GIT_COMMITTER_NAME="t", GIT_COMMITTER_EMAIL="t@t", BORNIM_OHNE_PUSH="1",
               BORNIM_WARN_STAND=os.path.join(d, "warn.json"), BORNIM_MELDUNGEN=os.path.join(d, "meldungen.tsv"), BORNIM_SITZUNG="session_test2062",
               BORNIM_LAUF_REST=rd)
    for k in ("BORNIM_WURZEL", "BORNIM_JETZT", "GIT_DIR", "GIT_WORK_TREE", "GIT_INDEX_FILE", "BORNIM_LAUF_VOLL"): ENV.pop(k, None)
    open(ENV["BORNIM_MELDUNGEN"], "w").close()
    for c in (["init", "-q", "-b", "main"], ["add", "-A"], ["commit", "-q", "-m", "t"]):
        subprocess.run(["git"] + c, cwd=A, env=ENV, capture_output=True)
    seite = os.path.join(d, "seite.txt"); open(seite, "w", encoding="utf-8").write("# has_more: nein\n")
    prog = ("import datetime, sys; sys.path.insert(0, 'tools'); sys.argv = ['lauf.py', '--ohne-pull', %r]\n"
            "import lauf\nlauf.JETZT = datetime.datetime(2026, 11, 27, 14, 0, tzinfo=lauf.BERLIN)\n"
            "lauf.protokoll_pushen = lambda f, n: (print('GEPUSHT-TEST ' + n), True)[1]\nlauf.herzschlag_pushen = lambda leb: None\n"
            "import guthaben\nguthaben.Bremse.erlaubt = lambda *a, **k: None\nlauf.main()\n") % seite
    r = subprocess.run([sys.executable, "-c", prog], cwd=A, env=ENV, capture_output=True, text=True, timeout=600)
    soll("(2) Takt ohne Absturz", r.returncode == 0, r.stderr[-1500:])
    kon = [l for l in r.stdout.splitlines() if l.startswith("START Figur") and "9302" in l]
    voll = [l for l in (open(rd, encoding="utf-8").read().splitlines() if os.path.isfile(rd) else []) if l.startswith("START Figur") and "9302" in l]
    soll("(2) Takt: START Figur 9302 auf der Konsole", len(kon) == 1, r.stdout[-1500:])
    soll("(2) Takt: START Figur 9302 in der Restdatei", len(voll) == 1, rd)
    if kon and voll:
        m = re.search(r" … \(voll: sed -n (\d+)p (\S+)\)$", kon[0])
        soll("(2) Konsole gekürzt: höchstens %d Zeichen plus Verweis auf die Restdatei" % lauf.KURZ_TAT,
             m and m.group(2) == rd and len(kon[0]) - len(m.group(0)) <= lauf.KURZ_TAT, kon[0][-200:])
        if m:
            z = subprocess.run(["sed", "-n", m.group(1) + "p", rd], capture_output=True, text=True).stdout.rstrip("\n")
            soll("(2) sed -n Np aus dem Verweis liefert die volle Zeile (Text für create_session)", z == voll[0], z[:200])
            soll("(2) Konsolenzeile ist Anfang der vollen Zeile", voll[0].startswith(kon[0][:len(kon[0]) - len(m.group(0))]))
        dA = os.path.join(A, "docs")
        sys.path.insert(0, os.path.join(A, "tools"))
        pruefe_start("(2) Takt Figur 9302 (Restdatei)", voll[0], "Figur", "9302", dA)
        print("BYTE Takt START Figur 9302: Konsole %d, Restdatei %d" % (len(kon[0].encode()), len(voll[0].encode())))
finally:
    shutil.rmtree(d, ignore_errors=True)

print("lauf_2062_test: %s" % ("alles grün" if not fehl else "%d FEHL" % fehl))
sys.exit(1 if fehl else 0)
