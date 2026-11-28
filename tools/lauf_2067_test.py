#!/usr/bin/env python3
"""2067 (Chef 28.11., 09:29 „ja, so machen, weil selbst wenn dann eine Sitzung vergessen wird, was passiert dann?“): der erste Lauf
ab 7 Uhr liest list_sessions nur VOLL_STUNDEN = 48 Stunden zurück statt alle Seiten; Älteres prüft die Besetzungsliste. Fälle an einer
Kopie von tools/ und docs/ (28.11., 07:30, Besetzung Stand 06:40, ohne Netz, ohne Push):
(1) Kurzform „# bis:“ 48 h zurück und „# has_more: ja“ → kein „VOLLER LAUF“, Lauf mit Plan (SITZUNG-Zeile);
(2) „# bis:“ nur bis zur Zeitgrenze (heute 00:00), nicht 48 h → „VOLLER LAUF“ nennt 48 Stunden;
(3) laufende Sitzung der Besetzung älter als 48 h und nicht in den Seiten → GET_SESSION (laut), kein Plan.
Aufruf: python3 tools/lauf_2067_test.py"""
import glob, os, re, shutil, subprocess, sys, tempfile
H = os.path.dirname(os.path.abspath(__file__)); W = os.path.dirname(H)
sys.path.insert(0, H); sys.argv = sys.argv[:1]

fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else str(zeige)[-1500:]))

import lauf
soll("Konstante VOLL_STUNDEN = 48", getattr(lauf, "VOLL_STUNDEN", None) == 48, getattr(lauf, "VOLL_STUNDEN", None))

KOPF = "# Besetzung\n\n**Stand:** 28.11., 06:40 (lauf.py)\n\n| Rolle | Sitzung | Vorgang | Zweig | seit |\n|---|---|---|---|---|\n"
NEU = "| Kampf | [Dana – in Arbeit – 2065 – x](https://claude.ai/code/session_NEU2067) | 2065 | – | 27.11., 11:00 |\n"
ALT = "| Sokrates | [Sokrates – Leitung (25.11.)](https://claude.ai/code/session_ALT2067) | Betrieb | – | 25.11., 09:00 |\n"
SEITE = "session_NEU2067 | working | 2026-11-28T06:20:00Z | Dana – in Arbeit – 2065 – x | - | 2026-11-27T10:00:00Z | 50000\n"
FAELLE = {
    "1 bis 48 h zurück": (KOPF + NEU, SEITE + "# bis: 2026-11-26T06:00:00Z\n# has_more: ja\n"),
    "2 bis nur Zeitgrenze": (KOPF + NEU, SEITE + "# bis: 2026-11-27T20:00:00Z\n# has_more: ja\n"),
    "3 Besetzung älter 48 h": (KOPF + NEU + ALT, SEITE + "# bis: 2026-11-26T06:00:00Z\n# has_more: ja\n"),
}

d = tempfile.mkdtemp(prefix="lauf-2067-")
try:
    A = os.path.join(d, "A"); os.makedirs(os.path.join(A, "tools"))
    shutil.copytree(os.path.join(W, "docs"), os.path.join(A, "docs"))
    for p in glob.glob(os.path.join(H, "*")):
        if os.path.isfile(p): shutil.copy2(p, os.path.join(A, "tools"))
    shutil.copytree(os.path.join(H, "umstellung1727"), os.path.join(A, "tools", "umstellung1727"))
    ENV = dict(os.environ, GIT_AUTHOR_NAME="t", GIT_AUTHOR_EMAIL="t@t", GIT_COMMITTER_NAME="t", GIT_COMMITTER_EMAIL="t@t", BORNIM_OHNE_PUSH="1", BORNIM_LAUF_VOLL="1",
               BORNIM_WARN_STAND=os.path.join(d, "warn.json"), BORNIM_MELDUNGEN=os.path.join(d, "meldungen.tsv"), BORNIM_SITZUNG="session_test2067")
    for k in ("BORNIM_WURZEL", "BORNIM_JETZT", "GIT_DIR", "GIT_WORK_TREE", "GIT_INDEX_FILE"): ENV.pop(k, None)
    open(ENV["BORNIM_MELDUNGEN"], "w").close()
    subprocess.run(["git", "init", "-q", "-b", "main"], cwd=A, env=ENV, capture_output=True)
    seite = os.path.join(d, "seite.txt")
    prog = ("import datetime, sys; sys.path.insert(0, 'tools'); sys.argv = ['lauf.py', '--ohne-pull', %r]\n"
            "import lauf\nlauf.JETZT = datetime.datetime(2026, 11, 28, 7, 30, tzinfo=lauf.BERLIN)\n"
            "lauf.protokoll_pushen = lambda f, n: (print('GEPUSHT-TEST ' + n), True)[1]\nlauf.herzschlag_pushen = lambda leb: None\n"
            "lauf.main()\n") % seite
    for name, (bes, s) in FAELLE.items():
        open(os.path.join(A, "docs", "ARBEIT-BESETZUNG.md"), "w", encoding="utf-8").write(bes)
        open(seite, "w", encoding="utf-8").write(s)
        for c in (["add", "-A"], ["commit", "-q", "-m", name]):
            subprocess.run(["git"] + c, cwd=A, env=ENV, capture_output=True)
        r = subprocess.run([sys.executable, "-c", prog], cwd=A, env=ENV, capture_output=True, text=True, timeout=600)
        zl = r.stdout.splitlines()
        soll("%s: Lauf ohne Absturz" % name, r.returncode == 0, r.stderr[-1500:])
        voll = [l for l in zl if l.startswith("VOLLER LAUF")]
        gs = [l for l in zl if l.startswith("GET_SESSION")]
        zeig = zl[:12]
        if name.startswith("1"):
            soll("1: kein „VOLLER LAUF“", not voll, voll)
            soll("1: kein GET_SESSION", not gs, gs)
            soll("1: Plan läuft (SITZUNG …2067)", any(l.startswith("SITZUNG …EU2067") for l in zl), zeig)
        elif name.startswith("2"):
            soll("2: „VOLLER LAUF“ verlangt 48 Stunden", len(voll) == 1 and "48 Stunden" in voll[0], voll or zeig)
            soll("2: kein Plan", not any(l.startswith("SITZUNG ") for l in zl), zeig)
        else:
            soll("3: kein „VOLLER LAUF“", not voll, voll)
            soll("3: GET_SESSION nennt die alte Sitzung der Besetzung", len(gs) == 1 and "session_ALT2067" in gs[0] and "session_NEU2067" not in gs[0], gs or zeig)
            soll("3: kein Plan", not any(l.startswith("SITZUNG ") for l in zl), zeig)
finally:
    shutil.rmtree(d, ignore_errors=True)

print("lauf_2067_test: %s" % ("alles grün" if not fehl else "%d FEHL" % fehl))
sys.exit(1 if fehl else 0)
