#!/usr/bin/env python3
"""Zählt, wann ein Haken anhält (1129.1 P3, Systemprüfung 13.11.: kein Haken schrieb auf, wie oft er anhält; „wie oft griff es,
was fand es“ war für keinen beantwortbar, darum wurde nie eine Prüfung gestrichen, die nie anschlägt).

`vermerk(haken, text)` hängt eine Zeile an `haken.tsv` im eigenen Zweig „haken“ an (nicht auf main, wie „probelaeufe“):
Zeit (Berlin), Haken, Grund (erste Zeile, höchstens 200 Zeichen), Zweig der Arbeitskopie. Der Push läuft abgelöst im Hintergrund
und hält den Haken nicht auf; scheitert er, bleibt die Zeile in ~/.bornim-haken.tsv. Jeder Fehler wird verschluckt.
Zählen: `python3 tools/hakenzahl.py [--ab TT.MM.]` (Haken und Grund je Anzahl; Diogenes montags, Perikles für die Regelbilanz).
"""
import datetime, os, re, subprocess, sys, tempfile, zoneinfo

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ZWEIG, DATEI = "haken", "haken.tsv"
LOKAL = os.path.expanduser("~/.bornim-haken.tsv")
BERLIN = zoneinfo.ZoneInfo("Europe/Berlin")


def _git(*a, **k):
    return subprocess.run(["git", "-C", REPO, *a], capture_output=True, text=True, timeout=30, **k)


def vermerk(haken, text):
    try:
        grund = re.sub(r"\s+", " ", (text or "").strip().splitlines()[0] if (text or "").strip() else "")[:200].replace("\t", " ")
        zweig = subprocess.run(["git", "rev-parse", "--abbrev-ref", "HEAD"], capture_output=True, text=True, timeout=5).stdout.strip()
        zeile = "\t".join([datetime.datetime.now(BERLIN).strftime("%Y-%m-%d %H:%M:%S"), haken, grund, zweig or "-"])
        with open(LOKAL, "a", encoding="utf-8") as f:
            f.write(zeile + "\n")
        if os.environ.get("BORNIM_HAKEN_TROCKEN"):
            return
        subprocess.Popen([sys.executable, os.path.abspath(__file__), "--push", zeile], stdout=subprocess.DEVNULL,
                         stderr=subprocess.DEVNULL, start_new_session=True)
    except Exception:
        pass


def _push(zeile):
    for _ in range(3):
        if _git("fetch", "-q", "origin", ZWEIG).returncode == 0:
            kopf = _git("rev-parse", "FETCH_HEAD").stdout.strip()
            alt = _git("show", f"{kopf}:{DATEI}").stdout
        else:
            kopf, alt = "", ""
        neu = "\n".join(alt.splitlines()[-5000:] + [zeile]) + "\n"
        blob = _git("hash-object", "-w", "--stdin", input=neu).stdout.strip()
        idx = tempfile.mktemp()
        env = dict(os.environ, GIT_INDEX_FILE=idx)
        _git("update-index", "--add", "--cacheinfo", f"100644,{blob},{DATEI}", env=env)
        baum = _git("write-tree", env=env).stdout.strip()
        if os.path.exists(idx):
            os.remove(idx)
        c = _git("commit-tree", baum, *(["-p", kopf] if kopf else []), "-m", "Haken: " + zeile.split("\t")[1]).stdout.strip()
        if c and _git("push", "-q", "origin", f"{c}:refs/heads/{ZWEIG}").returncode == 0:
            return


def zaehlen(ab=None):
    _git("fetch", "-q", "origin", ZWEIG)
    t = _git("show", f"FETCH_HEAD:{DATEI}").stdout
    je = {}
    for z in t.splitlines():
        f = z.split("\t")
        if len(f) < 3 or (ab and f[0][:10] < ab):
            continue
        schluessel = (f[1], re.sub(r"\d+", "N", f[2])[:90])  # gleiche Prüfung trotz anderer Nummern zusammen
        je[schluessel] = je.get(schluessel, 0) + 1
    for (h, g), n in sorted(je.items(), key=lambda x: -x[1]):
        print("%4d  %-16s %s" % (n, h, g))
    if not je:
        print("keine Halte gezählt" + (" seit " + ab if ab else ""))


if __name__ == "__main__":
    if len(sys.argv) > 2 and sys.argv[1] == "--push":
        _push(sys.argv[2])
    else:
        ab = None
        if "--ab" in sys.argv:
            tm = sys.argv[sys.argv.index("--ab") + 1]
            ab = "%d-%s-%s" % (datetime.date.today().year, tm[3:5], tm[0:2])
        zaehlen(ab)
