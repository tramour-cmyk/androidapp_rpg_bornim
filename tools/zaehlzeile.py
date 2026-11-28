#!/usr/bin/env python3
"""Zählzeile im Zweig „probelaeufe“ (1937, Sokrates 22.11., 12:48: „275 bleibt, als eigene Zählzeile in C“).

Eine Zeile je Ereignis in eine TSV-Datei des Zweigs, lokal immer, im Zweig mit drei Versuchen; Diogenes zählt daraus.
Genutzt von `commit-pruefung.py` (275, warnungen-275.tsv) und `probelauf.py` (Laufbremse, probelaeufe.tsv),
damit die Commit-Prüfung nicht an `probelauf.py` hängt, das mit seinen Prüfungen schrittweise fällt.
"""
import datetime
import os
import subprocess
import tempfile
import uuid
import zoneinfo

REPO = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
ZWEIG = "probelaeufe"
BERLIN = zoneinfo.ZoneInfo("Europe/Berlin")


def _git(*args, timeout=20, **kw):
    return subprocess.run(["git", "-C", REPO, *args], capture_output=True, text=True, timeout=timeout, **kw)


def zaehlen(nr, wer, art, datei, lokal, extra=(), zweig=ZWEIG):
    """Hängt „Zeit, nr, wer, art, Kennung, *extra“ an `lokal` und an `datei` im Zweig an (nicht mit BORNIM_PROBELAUF_TROCKEN)."""
    zeit = datetime.datetime.now(BERLIN).strftime("%Y-%m-%d %H:%M:%S")  # Sekunden: Läufe derselben Minute zählen einzeln
    zeile = "\t".join([zeit, nr, wer, art, uuid.uuid4().hex[:8], *extra])  # Kennung: Zweig und Datei doppeln Zeilen
    with open(lokal, "a", encoding="utf-8") as f:
        f.write(zeile + "\n")
    if os.environ.get("BORNIM_PROBELAUF_TROCKEN"):
        return
    for _ in range(3):
        kopf, alt = "", ""
        if _git("fetch", "-q", "origin", zweig, timeout=8).returncode == 0:
            kopf = _git("rev-parse", "FETCH_HEAD").stdout.strip()
            alt = _git("show", f"{kopf}:{datei}").stdout
        neu = "\n".join(alt.splitlines()[-2000:] + [zeile]) + "\n"
        blob = _git("hash-object", "-w", "--stdin", input=neu).stdout.strip()
        idx = tempfile.mktemp()
        env = dict(os.environ, GIT_INDEX_FILE=idx)
        if kopf:
            _git("read-tree", kopf, env=env)
        _git("update-index", "--add", "--cacheinfo", f"100644,{blob},{datei}", env=env)
        baum = _git("write-tree", env=env).stdout.strip()
        if os.path.exists(idx):
            os.remove(idx)
        commit = _git("commit-tree", baum, *(["-p", kopf] if kopf else []), "-m", f"Probelauf {nr} ({wer})", timeout=8).stdout.strip()
        if commit and _git("push", "-q", "origin", f"{commit}:refs/heads/{zweig}", timeout=8).returncode == 0:
            return
    # Push fehlgeschlagen: die lokale Zeile zählt weiter
