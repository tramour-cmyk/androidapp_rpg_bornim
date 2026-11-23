#!/usr/bin/env python3
"""1964 (Fund Disponent 22.11., 17:23; Nachträge 17:25, 17:46): lauf.py ohne Fehlalarm und falschen START.
(a) Titel „<Rolle> – …“ jeder Rolle samt Wache ergibt die Rolle (keine Warnung „keine Rolle im Titel“, Start angekommen), Wache nie archiviert;
(b) `--ohne <Rolle>:Grund` wirkt für jede Rolle und Routine, auch Tagesbericht: kein START, keine Sperre;
(c) eine Kopfregel „## Auftrag ([Name, [Rolle, ]]TT.MM., HH:MM[; Zusatz])“ für juengster_auftrag und auftrag_seit, alle Köpfe in docs/vorgang;
(d) offene Übergabe an den Arbeitsplaner jünger als der jüngste Auftrag (Rückläufer, 1960-Ü7) → kein gültiger Auftrag (Zeile „Auftrag“, kein START).
Ohne Netz, ohne Push (Ende-zu-Ende an einer Kopie von tools/ und docs/). Aufruf: python3 tools/lauf_1964_test.py"""
import datetime, glob, json, os, re, shutil, subprocess, sys, tempfile
H = os.path.dirname(os.path.abspath(__file__)); W = os.path.dirname(H)
sys.path.insert(0, H); sys.argv = sys.argv[:1]
import kosten, lauf, startbar

fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else str(zeige)[-1500:]))

ROLLEN = sorted(set(startbar.profile()) | lauf.ROUTINE_ROLLEN | {"Wache", "Sokrates", "Ford"})
J = datetime.datetime(2026, 11, 22, 17, 30, tzinfo=lauf.BERLIN)

# (a) Titel jeder Rolle, wie der Disponent und lauf.py sie schreiben
for r in ROLLEN:
    for t in ("%s – Disponent (22.11., 17:12)" % r, "%s – 1964: Thema (22.11., 17:12)" % r):
        soll("a: Titel „%s“ = Rolle %s" % (t, r), kosten.rolle(t, "2026-11-22T16:12:00Z") == r, kosten.rolle(t, "2026-11-22T16:12:00Z"))
soll("a: Wache nie archiviert (NIE_ARCHIV)", "Wache" in lauf.NIE_ARCHIV, lauf.NIE_ARCHIV)
lauf.neue_liste()
soll("a: Wache nie in der Startreihe", "Wache" not in lauf.START_REIHE, lauf.START_REIHE)
wache = {"id": "session_w", "title": "Wache – Disponent (22.11., 17:12)", "created_at": "2026-11-22T16:12:30Z", "updated_at": "2026-11-22T16:20:00Z",
         "session_status": "SESSION_STATUS_IDLE"}
soll("a: Start Wache angekommen", lauf.start_angekommen("Wache", J.replace(hour=17, minute=12), {"w": wache}))

# (b) --ohne mit jeder Rolle und Routine
ohne_rollen_aus = getattr(lauf, "ohne_rollen_aus", lambda a: {n for n in a if re.fullmatch(startbar.ROLLEN_NAMEN, n)})  # vor 1964: Ausdruck in main()
for r in ROLLEN:
    soll("b: --ohne %s:Grund nimmt die Rolle aus dem Lauf" % r, ohne_rollen_aus({r: "1959"}) == {r}, ohne_rollen_aus({r: "1959"}))
soll("b: --ohne 1959:Grund ist keine Rolle", ohne_rollen_aus({"1959": "x", "1589.2": "y"}) == set())

# (c) Kopfformen
KOEPFE = ["## Auftrag (22.11., 17:01)", "## Auftrag (Greta, 22.11., 17:01; ergänzt)", "## Auftrag (Nora, Arbeitsplaner, 22.11., 17:01)",
          "## Auftrag (22.11., 17:01; Rückläufer, ersetzt Auftrag 16:30)", "## Auftrag (Nora, 22.11., 17:01)"]
for k in KOEPFE:
    t = "# x\n\n## Auftrag (21.11., 09:00)\n\nALT\n\n%s\n\nNEU\n\n## Rückmeldungen\n" % k
    ab = lauf.juengster_auftrag(t, J.replace(tzinfo=None)); seit = lauf.auftrag_seit(t, J)
    soll("c: Kopf „%s“: jüngster Auftrag" % k, ab and t[ab[0]:ab[1]].strip() == "NEU", ab and t[ab[0]:ab[1]])
    soll("c: Kopf „%s“: auftrag_seit 17:01" % k, seit == J.replace(hour=17, minute=1), seit)
for k in ("## Auftrag (Vorschlag Sokrates)", "## Auftrag", "## Auftragslage (22.11., 17:01)"):
    soll("c: „%s“ ist kein Auftrag mit Zeit" % k, lauf.juengster_auftrag(k + "\n\nx\n", J.replace(tzinfo=None)) is None and lauf.auftrag_seit(k, J) is None)
ohne = []
for p in sorted(glob.glob(os.path.join(W, "docs", "vorgang", "*.md"))):
    t = open(p, encoding="utf-8").read()
    for m in re.finditer(r"(?m)^## Auftrag \(([^)\n]*\d\d\.\d\d\.,? \d\d:\d\d[^)\n]*)\)", t):
        if lauf.juengster_auftrag(m.group(0) + "\n", datetime.datetime(2026, 12, 31)) is None: ohne.append("%s: %s" % (os.path.basename(p), m.group(0)))
soll("c: jeder Kopf „## Auftrag (… TT.MM., HH:MM …)“ in docs/vorgang gilt", not ohne, ohne)

# (d) 1960 mit offener Ü7 wie am 22.11., 17:46 (Stand 319a8ee59): Auftrag 17:01, Rückläufer an den Arbeitsplaner 17:22 offen.
# Aus der heutigen Datei (CI holt keinen Verlauf): Kopf 18:17 → 17:01, Ü7 wieder offen.
d = tempfile.mkdtemp(prefix="lauf-1964-")
try:
    os.makedirs(os.path.join(d, "vorgang"))
    alt = open(os.path.join(W, "docs", "vorgang", "1960.md"), encoding="utf-8").read()
    alt = re.sub(r"(?m)^## Auftrag \(22\.11\., 18:17[^)]*\)$", "## Auftrag (22.11., 17:01)", alt)
    alt = re.sub(r"(\| 1960-Ü7 \| Arbeitsplaner \|.*\| 22\.11\., 17:22 \| )erledigt[^|]*\|", r"\1offen |", alt)
    soll("d: Stand 1960 mit offener Ü7 lesbar", "| 1960-Ü7 | Arbeitsplaner |" in alt and "| 22.11., 17:22 | offen |" in alt, alt[-300:])
    p = os.path.join(d, "vorgang", "1960.md")
    open(p, "w", encoding="utf-8").write(alt)
    g = lauf.auftrag_fehlt("1960", docs=d, titel="x")
    soll("d: 1960 mit offener Ü7: kein gültiger Auftrag (Rückläufer)", g and "1960-Ü7" in g, g)
    open(p, "w", encoding="utf-8").write(alt.replace("| 22.11., 17:22 | offen |", "| 22.11., 17:22 | angenommen session_x bis 22.11., 17:52 |"))
    g = lauf.auftrag_fehlt("1960", docs=d, titel="x")
    soll("d: Ü7 beim Planer angenommen: weiter kein Auftrag", g and "1960-Ü7" in g, g)
    open(p, "w", encoding="utf-8").write(alt.replace("| 22.11., 17:22 | offen |", "| 22.11., 17:22 | erledigt 22.11., 18:17 session_x |")
                                         + "\n## Auftrag (Nora, Arbeitsplaner, 22.11., 18:17)\n\n" + alt.split("## Auftrag (22.11., 17:01)")[1].split("\n## ")[0])
    g = lauf.auftrag_fehlt("1960", docs=d, titel="x")
    soll("d: Ü7 erledigt, neuer Auftrag 18:17: gültig", g is None, g)
    open(p, "w", encoding="utf-8").write(alt.replace("| 1960-Ü7 | Arbeitsplaner |", "| 1960-Ü7 | Werkzeug |"))
    soll("d: offene Übergabe an andere Rolle hält den Auftrag nicht", lauf.auftrag_fehlt("1960", docs=d, titel="x") is None)
    open(p, "w", encoding="utf-8").write(alt.replace("| 22.11., 17:22 | offen |", "| 22.11., 16:22 | offen |"))
    soll("d: Übergabe an den Planer älter als der Auftrag hält ihn nicht", lauf.auftrag_fehlt("1960", docs=d, titel="x") is None)
finally:
    shutil.rmtree(d, ignore_errors=True)

# (a)+(b) Ende zu Ende: Kopie von tools/ und docs/, Lauf am 24.11., 08:00 mit laufender Wache und --ohne Tagesbericht:1959
d = tempfile.mkdtemp(prefix="lauf-1964-e2e-")
try:
    A = os.path.join(d, "A"); os.makedirs(os.path.join(A, "tools"))
    shutil.copytree(os.path.join(W, "docs"), os.path.join(A, "docs"))
    for p in glob.glob(os.path.join(H, "*")):
        if os.path.isfile(p): shutil.copy2(p, os.path.join(A, "tools"))
    b = os.path.join(A, "docs", "ARBEIT-BETRIEB.md")
    open(b, "a", encoding="utf-8").write("\n- 07:30 24.11.: Startsperre 07:30 Start Wache (Disponent von Hand, 1964-Test)\n")
    ENV = dict(os.environ, GIT_AUTHOR_NAME="t", GIT_AUTHOR_EMAIL="t@t", GIT_COMMITTER_NAME="t", GIT_COMMITTER_EMAIL="t@t", BORNIM_OHNE_PUSH="1",
               BORNIM_WARN_STAND=os.path.join(d, "warn.json"), BORNIM_MELDUNGEN=os.path.join(d, "meldungen.tsv"), BORNIM_SITZUNG="session_test1964")
    for k in ("BORNIM_WURZEL", "BORNIM_JETZT", "GIT_DIR", "GIT_WORK_TREE", "GIT_INDEX_FILE"): ENV.pop(k, None)
    open(ENV["BORNIM_MELDUNGEN"], "w").close()
    for c in (["init", "-q", "-b", "main"], ["add", "-A"], ["commit", "-q", "-m", "Stand"]):
        subprocess.run(["git"] + c, cwd=A, env=ENV, capture_output=True)
    seite = os.path.join(d, "seite.txt")
    open(seite, "w", encoding="utf-8").write("# has_more: nein\nsession_w1964 | working | 2026-11-24T06:55:00Z | Wache – Disponent (24.11., 07:31) | 0,10 | 2026-11-24T06:31:00Z\n")
    prog = ("import datetime, sys; sys.path.insert(0, 'tools'); sys.argv = ['lauf.py', '--ohne-pull', '--nur-muss', '--ohne', 'Tagesbericht:1959', %r]\n"
            "import lauf\nlauf.JETZT = datetime.datetime(2026, 11, 24, 8, 0, tzinfo=lauf.BERLIN)\n"
            "lauf.protokoll_pushen = lambda f, n: (print('GEPUSHT-TEST ' + n), True)[1]\nlauf.herzschlag_pushen = lambda leb: None\nlauf.main()\n") % seite
    r = subprocess.run([sys.executable, "-c", prog], cwd=A, env=ENV, capture_output=True, text=True, timeout=600)
    aus = r.stdout
    soll("e2e: Lauf ohne Absturz", r.returncode == 0, r.stderr[-1500:])
    warn = [l for l in aus.splitlines() if l.startswith("WARNUNG")]
    soll("e2e: keine Warnung „keine Rolle im Titel“ für die Wache", not [l for l in warn if "keine Rolle" in l and "session_w1964" in l], [l for l in warn if "keine Rolle" in l])
    soll("e2e: kein „Start Wache nicht angekommen“", not [l for l in warn if "Start Wache nicht angekommen" in l], [l for l in warn if "nicht angekommen" in l])
    soll("e2e: Wache nicht archiviert", "ARCHIVIERE session_w1964" not in aus, aus)
    soll("e2e: kein START Wache", "START Wache" not in aus, aus)
    tb = [l for l in aus.splitlines() if re.match(r"(START Tagesbericht|TAGESBERICHT\S*) ", l)]
    soll("e2e: --ohne Tagesbericht: kein START Tagesbericht", not tb, [l[:120] for l in tb])
    sp = [l for l in aus.splitlines() if l.startswith(("GEPUSHT-TEST", "STARTSPERRE"))] + open(b, encoding="utf-8").read().split("1964-Test")[1].splitlines()
    soll("e2e: --ohne Tagesbericht: keine Sperre Tagesbericht", not [l for l in sp if "Tagesbericht" in l], sp)
    soll("e2e: kein „Start Tagesbericht nicht angekommen“", not [l for l in warn if "Start Tagesbericht nicht angekommen" in l], warn)
    soll("e2e: Ausschluss genannt", "AUSGESCHLOSSEN Tagesbericht: 1959" in aus, aus)
finally:
    shutil.rmtree(d, ignore_errors=True)

print("lauf_1964_test: %s" % ("alles grün" if not fehl else "%d FEHL" % fehl))
sys.exit(1 if fehl else 0)
