#!/usr/bin/env python3
"""2006 (Sokrates 23.11., 19:02; Alter Ego 19:01): keine Fachkraft startet für einen Vorgang mit offener Übergabezeile an den
Arbeitsplaner, gleich wie alt (auch ohne Auftrag); Ü an Büro (Disponent, Prüfer) halten nicht; der Planer startet weiter.
Je Startweg ein Fall: Zeilenregel, WEITER, Nachfolger, ue_start; dazu startbar.plan („wartet auf <Nr>-Ü<k> (Arbeitsplaner)“)
und ruecklaeufer_offen als gemeinsame Prüfung. Ohne Netz, ohne Push (Kopie von tools/ und docs/, Lauf am 24.11., 10:00).
Aufruf: python3 tools/lauf_2006_test.py"""
import datetime, glob, json, os, re, shutil, subprocess, sys, tempfile
H = os.path.dirname(os.path.abspath(__file__)); W = os.path.dirname(H)
sys.path.insert(0, H); sys.argv = sys.argv[:1]
import lauf

fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else str(zeige)[-1500:]))

J = datetime.datetime(2026, 11, 24, 10, 0)
KOPF = "| Ü | an | was | seit | Zustand |\n|---|---|---|---|---|\n"
AUFTRAG = open(os.path.join(W, "docs", "vorgang", "2006.md"), encoding="utf-8").read().split("## Auftrag (23.11., 22:09)\n", 1)[1].split("\n## ", 1)[0]

def datei(nr, ue, auftrag=True):
    """Vorgangsdatei mit gültigem Auftrag 23.11., 22:09 (Text aus 2006) und den Übergaben ue = [(k, an, seit, zustand)]."""
    t = "# %s · Test 2006\n\n" % nr + ("## Auftrag (23.11., 22:09)\n%s\n" % AUFTRAG if auftrag else "")
    return t + "## Übergaben\n\n" + KOPF + "".join("| %s-Ü%d | %s | Test | %s | %s |\n" % (nr, k, an, s, z) for k, an, s, z in ue)

# Gemeinsame Prüfung ruecklaeufer_offen
F = [("alte Ü an den Planer (älter als der Auftrag) hält", [(1, "Arbeitsplaner", "23.11., 08:00", "offen")], True, "9001-Ü1"),
     ("junge Ü an den Planer hält", [(1, "Arbeitsplaner", "23.11., 22:30", "offen")], True, "9001-Ü1"),
     ("angenommene Ü an den Planer hält", [(1, "Arbeitsplaner", "23.11., 08:00", "angenommen session_x bis 23.11., 08:30")], True, "9001-Ü1"),
     ("erledigte Ü an den Planer hält nicht", [(1, "Arbeitsplaner", "23.11., 08:00", "erledigt 23.11., 09:00 session_x")], True, None),
     ("Ü an Disponent und Prüfer halten nicht", [(1, "Disponent", "23.11., 08:00", "offen"), (2, "Prüfer", "23.11., 22:30", "offen")], True, None),
     ("ohne Auftrag: offene Ü an den Planer hält (1676)", [(1, "Arbeitsplaner", "23.11., 18:28", "offen")], False, "9001-Ü1")]
for name, ue, mit, k in F:
    g = lauf.ruecklaeufer_offen(datei("9001", ue, mit), J)
    soll("ruecklaeufer_offen: " + name, (g is None) if k is None else bool(g and k in g and "Arbeitsplaner" in g), g)

# Kopie: Zeilen 9101 (Kampf, Zeilenregel), 9102 (Figur, WEITER), 9103 (Klang, ue_start), 9104 (Technik, Nachfolger), je mit offener
# Ü an den Planer; 9105 (Kampf) nur mit offenen Ü an Disponent und Prüfer: startet.
# Kl. Eilt, damit eine Laufsperre („nur Spiel und Eilt“) den Fall nicht schon vorher hält
ZEILEN = [("9101", 2, "E Kampf", "startbar"), ("9105", 2, "E Kampf", "startbar"), ("9102", 3, "E Figuren", "startbar"),
          ("9103", 11, "E Klang", "ruht, Test 2006"), ("9104", 6, "E Technik", "startbar")]
UE = {"9101": [(1, "Arbeitsplaner", "23.11., 08:00", "offen")],
      "9102": [(1, "Arbeitsplaner", "23.11., 08:00", "offen")],
      "9103": [(1, "Klang", "23.11., 08:00", "offen"), (2, "Arbeitsplaner", "23.11., 08:00", "offen")],
      "9104": [(1, "Arbeitsplaner", "23.11., 08:00", "offen")],
      "9105": [(1, "Disponent", "23.11., 08:00", "offen"), (2, "Prüfer", "23.11., 08:00", "offen")]}
d = tempfile.mkdtemp(prefix="lauf-2006-")
try:
    A = os.path.join(d, "A"); os.makedirs(os.path.join(A, "tools"))
    shutil.copytree(os.path.join(W, "docs"), os.path.join(A, "docs"))
    for p in glob.glob(os.path.join(H, "*")):
        if os.path.isfile(p): shutil.copy2(p, os.path.join(A, "tools"))
    # 2035-Ü8: echte Startsperren des Betriebs (etwa 24.11., 09:55) gehören nicht in die Kopie, sonst hält die Laufsperre den Fall
    b = os.path.join(A, "docs", "ARBEIT-BETRIEB.md")
    t = open(b, encoding="utf-8").read()
    open(b, "w", encoding="utf-8").write("".join(l for l in t.splitlines(True) if "Startsperre " not in l))
    li = os.path.join(A, "docs", "LISTE-VORGAENGE.md")
    t = open(li, encoding="utf-8").read()
    neu = "".join("| %s | Test 2006 %s | %d | %s | Eilt | – | – | – | *%s* | *–* | *0* | *–* |\n" % (n, n, b, ber, s) for n, b, ber, s in ZEILEN)
    t = t.replace("|---|---|---|---|---|---|---|---|---|---|---|---|\n", "|---|---|---|---|---|---|---|---|---|---|---|---|\n" + neu, 1)
    open(li, "w", encoding="utf-8").write(t)
    for n, ue in UE.items():
        open(os.path.join(A, "docs", "vorgang", "%s.md" % n), "w", encoding="utf-8").write(datei(n, ue))
    ENV = dict(os.environ, GIT_AUTHOR_NAME="t", GIT_AUTHOR_EMAIL="t@t", GIT_COMMITTER_NAME="t", GIT_COMMITTER_EMAIL="t@t", BORNIM_OHNE_PUSH="1", BORNIM_LAUF_VOLL="1",
               BORNIM_WARN_STAND=os.path.join(d, "warn.json"), BORNIM_MELDUNGEN=os.path.join(d, "meldungen.tsv"), BORNIM_SITZUNG="session_test2006")
    for k in ("BORNIM_WURZEL", "BORNIM_JETZT", "GIT_DIR", "GIT_WORK_TREE", "GIT_INDEX_FILE"): ENV.pop(k, None)
    open(ENV["BORNIM_MELDUNGEN"], "w").close()
    for c in (["init", "-q", "-b", "main"], ["add", "-A"], ["commit", "-q", "-m", "Stand"]):
        subprocess.run(["git"] + c, cwd=A, env=ENV, capture_output=True)

    # startbar.plan
    prog = ("import json, sys; sys.path.insert(0, 'tools'); sys.argv = ['x']\nimport startbar\n"
            "print(json.dumps({r: {z[0]: z[4] for z in startbar.plan(r)} for r in ('Kampf', 'Figur', 'Technik')}))\n")
    r = subprocess.run([sys.executable, "-c", prog], cwd=A, env=ENV, capture_output=True, text=True, timeout=300)
    pl = json.loads(r.stdout.strip().splitlines()[-1]) if r.returncode == 0 else {}
    soll("plan: läuft", r.returncode == 0, r.stderr[-1500:])
    for rolle, n in (("Kampf", "9101"), ("Figur", "9102"), ("Technik", "9104")):
        g = pl.get(rolle, {}).get(n, "fehlt")
        soll("plan %s: %s wartet auf %s-Ü1 (Arbeitsplaner)" % (rolle, n, n), g == "wartet auf %s-Ü1 (Arbeitsplaner)" % n, g)
    soll("plan Kampf: 9105 (Ü an Disponent, Prüfer) startbar", pl.get("Kampf", {}).get("9105", "fehlt") is None, pl.get("Kampf", {}).get("9105", "fehlt"))

    # lauf.py: Figur ruht seit 30 Minuten (WEITER-Weg), Technik mit Nachfolger 9104, sonst keine Sitzung
    seite = os.path.join(d, "seite.txt")
    open(seite, "w", encoding="utf-8").write("# has_more: nein\nsession_fig2006 | idle | 2026-11-24T08:30:00Z | Figur – 9102 (24.11., 09:20) | 0,10 | 2026-11-24T08:20:00Z | 50000\n")
    prog = ("import datetime, sys; sys.path.insert(0, 'tools'); sys.argv = ['lauf.py', '--ohne-pull', %r]\n"
            "import lauf\nlauf.JETZT = datetime.datetime(2026, 11, 24, 10, 0, tzinfo=lauf.BERLIN)\n"
            "lauf.protokoll_pushen = lambda f, n: (print('GEPUSHT-TEST ' + n), True)[1]\nlauf.herzschlag_pushen = lambda leb: None\n"
            "import guthaben\nguthaben.Bremse.erlaubt = lambda *a, **k: None  # Guthaben und Laufsperre prüft 2001, nicht dieser Test\n"
            "_nf = lauf.nachfolger\n"
            "lauf.nachfolger = lambda r: ('Technik – 9104', lauf.JETZT - datetime.timedelta(hours=1), 'Technik – 9104') if r == 'Technik' else _nf(r)\n"
            "lauf.VORRAT.setdefault('Technik', 'ARBEIT-TEST-2006.md')\nlauf.main()\n") % seite
    r = subprocess.run([sys.executable, "-c", prog], cwd=A, env=ENV, capture_output=True, text=True, timeout=600)
    aus = r.stdout; zl = aus.splitlines()
    soll("lauf: ohne Absturz", r.returncode == 0, r.stderr[-1500:])
    def hat(rolle, n): return [l[:160] for l in zl if (l.startswith("START %s |" % rolle) or l.startswith("WEITER ") and " | %s | " % rolle in l) and n in l]
    soll("Zeilenregel: kein START Kampf für 9101", not hat("Kampf", "9101"), hat("Kampf", "9101"))
    soll("Zeilenregel: Grund nennt 9101-Ü1", any(l.startswith("NICHTS Kampf:") and "9101-Ü1 (Arbeitsplaner)" in l for l in zl), [l for l in zl if "Kampf" in l][:5])
    soll("Zeilenregel: START Kampf für 9105 (Ü an Büro hält nicht)", any(l.startswith("START Kampf |") and "9105" in l for l in zl), [l[:160] for l in zl if "Kampf" in l][:5])
    soll("WEITER: kein WEITER/START Figur für 9102", not hat("Figur", "9102"), hat("Figur", "9102"))
    soll("WEITER: Grund nennt 9102-Ü1", any(l.startswith("NICHTS Figur:") and "9102-Ü1 (Arbeitsplaner)" in l for l in zl), [l[:160] for l in zl if "Figur" in l][:5])
    soll("ue_start: kein START Klang für 9103", not hat("Klang", "9103"), hat("Klang", "9103"))
    soll("ue_start: Grund nennt 9103-Ü2", any(l.startswith("NICHTS Klang:") and "9103-Ü2 (Arbeitsplaner)" in l for l in zl), [l[:160] for l in zl if "Klang" in l][:5])
    soll("Nachfolger: kein START Technik für 9104", not hat("Technik", "9104"), hat("Technik", "9104"))
    soll("Nachfolger: Grund nennt 9104-Ü1", any(l.startswith("NICHTS Technik:") and "9104-Ü1 (Arbeitsplaner)" in l for l in zl), [l[:160] for l in zl if "Technik" in l][:5])
    pl_ = [l[:200] for l in zl if l.startswith("START Arbeitsplaner |") or l.startswith("NACHRICHT Arbeitsplaner |")]
    soll("Planer: START Arbeitsplaner trägt 9101-Ü1 und 9103-Ü2", any(l.startswith("START Arbeitsplaner |") and "9101-Ü1" in l and "9103-Ü2" in l for l in zl), pl_)
finally:
    shutil.rmtree(d, ignore_errors=True)

print("lauf_2006_test: %s" % ("alles grün" if not fehl else "%d FEHL" % fehl))
sys.exit(1 if fehl else 0)
