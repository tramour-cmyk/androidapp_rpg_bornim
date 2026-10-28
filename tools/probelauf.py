#!/usr/bin/env python3
"""Probelauf-Haken (389; Chef 27.10., 23:55: „389 ja, höchstens zwei Läufe und die Betonung hierbei liegt auf höchstens.“).

PreToolUse-Haken für Bash, alle Rollen. Je Vorlage höchstens zwei Probeläufe, dann vorlegen: beim dritten Lauf für denselben
Vorgang ohne Vorlage dazwischen hält der Haken den Befehl an (Exit 2), ohne Ausweg.

Probelauf heißt:
- ein Bildlauf am Rechner: Godot mit Fenster (xvfb-run oder `godot --path` ohne `--import`) oder ein Laufskript aus
  `tools/pruef348/` (alle außer `rechner.sh`) oder `*_lauf.sh`; der Vorgang steht davor: `PROBE=<Nr> bash …`;
  kein Probelauf: `godot --headless --path <dir> -s res://tests/<datei>.gd` ohne Bildbefehl in der Testdatei (390a);
- ein Push auf `claude/tom-348-*` oder `claude/jerry-348-*`, der `godot.yml` auslöst (letzter Commit ohne „[skip ci]“, Änderung
  unter godot/, tools/blender348/, core/src/main/ oder am Workflow); der Vorgang ist die erste Nummer der Commit-Nachricht.
Vorlage heißt: eine Meldung mit Bild, Film oder Datei zu dem Vorgang (Zeile im Zweig „meldungen“, schreibt `meldung.sh`, 383).
Jeder Lauf wird gezählt, auch einer, der abbricht. Die Zählung steht im Zweig „probelaeufe“ in `probelaeufe.tsv` (überlebt den
Neustart) und hilfsweise in ~/.bornim-probelaeufe.tsv. Bei eigenem Fehler (kein Git, kein Netz) lässt der Haken durch.

Auch von Hand: `python3 tools/probelauf.py --stand <Nr>` zeigt die Zählung.
"""
import datetime
import json
import os
import re
import subprocess
import sys
import tempfile
import uuid
import zoneinfo

GRENZE = 2
BERLIN = zoneinfo.ZoneInfo("Europe/Berlin")
REPO = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
LOKAL = os.environ.get("BORNIM_PROBELAEUFE") or os.path.expanduser("~/.bornim-probelaeufe.tsv")
ZWEIG = "probelaeufe"  # eigener Zweig: meldung.sh schreibt „meldungen“ mit nur einer Datei
DATEI = "probelaeufe.tsv"

NR = r"[A-Za-z]?\d+[a-z]?(?:\.\d+[a-z]?)*"
PROBE = re.compile(r"\bPROBE=(" + NR + r")\b")
GODOT_LAUF = re.compile(r"xvfb-run[^\n|;&]*godot[^\n|;&]*|\bgodot(?:\.\S+)?\s[^\n|;&]*--path[^\n|;&]*")
SKRIPT = re.compile(r"tools/pruef348/(?!rechner\.sh)[\w.-]+\.sh|\b\w+_lauf\.sh")
PUSH = re.compile(r"\bgit\s+(?:-C\s+(\S+)\s+)?push\b([^\n|;&]*)")
COMMIT = re.compile(r"\bgit\s+(?:-C\s+\S+\s+)?commit\b[^\n]*?\s-[a-zA-Z]*m\s*(.+)", re.S)
TEST_SKRIPT = re.compile(r"(?:^|\s)-s\s+[\"']?res://tests/([\w./-]+\.gd)\b")
BILDBEFEHL = re.compile(r"save_png|save_jpg|save_webp|save_exr|get_image\s*\(|get_texture\s*\(|MovieWriter|screenshot", re.I)
CD = re.compile(r"\bcd\s+([^\s;&|]+)")
CI_ZWEIG = re.compile(r"claude/(?:tom|jerry)-348-[\w./-]+")
CI_PFADE = ("godot/", "tools/blender348/", "core/src/main/", ".github/workflows/godot.yml", ".github/workflows/godot-kampf.yml")


def jetzt():
    return datetime.datetime.now(BERLIN).strftime("%Y-%m-%d %H:%M:%S")  # Sekunden: Läufe derselben Minute zählen einzeln


def testlauf(lauf, befehl, cwd):
    """390a (Chef 28.10., 10:26): Testprogramm aus godot/tests/ ist kein Probelauf, wenn eng: `--headless`, kein xvfb-run,
    `-s res://tests/….gd`, und die Testdatei enthält keinen Bildbefehl. Datei nicht gefunden: zählt als Bildlauf."""
    s = TEST_SKRIPT.search(lauf)
    if "--headless" not in lauf or "xvfb-run" in lauf or "--write-movie" in lauf or not s:
        return False
    p = re.search(r"--path[=\s]+(\S+)", lauf)
    pfad = os.path.expanduser(p.group(1).strip("\"'")) if p else "."
    for basis in [cwd] + [os.path.join(cwd, os.path.expanduser(c)) for c in CD.findall(befehl)]:
        datei = os.path.join(basis, pfad, "tests", s.group(1))
        if os.path.isfile(datei):
            return not BILDBEFEHL.search(open(datei, encoding="utf-8", errors="replace").read())
    return False


def bildlauf(befehl, cwd="."):
    return SKRIPT.search(befehl) or any("--import" not in m.group(0) and not testlauf(m.group(0), befehl, cwd)
                                        for m in GODOT_LAUF.finditer(befehl))


def git(*args, cwd=REPO, timeout=8):
    return subprocess.run(["git", "-C", cwd, *args], capture_output=True, text=True, timeout=timeout)


def zweig_lesen(name, zweig=ZWEIG):
    r = git("fetch", "-q", "origin", zweig)
    if r.returncode:
        return None, ""
    kopf = git("rev-parse", "FETCH_HEAD").stdout.strip()
    return kopf, git("show", f"{kopf}:{name}").stdout


def zeilen(text):
    return [z.split("\t") for z in text.splitlines() if z.count("\t") >= 2]


def stand(nr):
    """(Läufe seit der letzten Vorlage zu nr, Zeit der Vorlage oder None)."""
    _, laeufe = zweig_lesen(DATEI)
    _, meld = zweig_lesen("meldungen.tsv", "meldungen")
    lokal = open(LOKAL, encoding="utf-8").read() if os.path.exists(LOKAL) else ""
    vorlage = None
    for z in zeilen(meld):
        if z[3:4] and z[3] in ("photo", "video", "document") and nr in z[1].split(","):
            vorlage = max(vorlage or "", z[0])
    gesehen = set()
    for z in zeilen(laeufe) + zeilen(lokal):
        if z[1] == nr and (vorlage is None or z[0] > vorlage):
            gesehen.add(tuple(z[:5]))
    return len(gesehen), vorlage


def zaehlen(nr, wer, art):
    zeile = f"{jetzt()}\t{nr}\t{wer}\t{art}\t{uuid.uuid4().hex[:8]}"  # Kennung: Zweig und Datei doppeln Zeilen
    with open(LOKAL, "a", encoding="utf-8") as f:
        f.write(zeile + "\n")
    if os.environ.get("BORNIM_PROBELAUF_TROCKEN"):
        return
    for versuch in range(3):
        kopf, alt = zweig_lesen(DATEI)
        neu = "\n".join(alt.splitlines()[-2000:] + [zeile]) + "\n"
        blob = subprocess.run(["git", "-C", REPO, "hash-object", "-w", "--stdin"], input=neu, capture_output=True,
                              text=True, timeout=20).stdout.strip()
        idx = tempfile.mktemp()
        env = dict(os.environ, GIT_INDEX_FILE=idx)
        baum = ""
        if kopf:
            subprocess.run(["git", "-C", REPO, "read-tree", kopf], env=env, capture_output=True, timeout=20)
        subprocess.run(["git", "-C", REPO, "update-index", "--add", "--cacheinfo", f"100644,{blob},{DATEI}"], env=env,
                       capture_output=True, timeout=20)
        baum = subprocess.run(["git", "-C", REPO, "write-tree"], env=env, capture_output=True, text=True, timeout=20).stdout.strip()
        if os.path.exists(idx):
            os.remove(idx)
        commit = git("commit-tree", baum, *(["-p", kopf] if kopf else []), "-m", f"Probelauf {nr} ({wer})").stdout.strip()
        if commit and git("push", "-q", "origin", f"{commit}:refs/heads/{ZWEIG}").returncode == 0:
            return
    # Push fehlgeschlagen: die lokale Zeile zählt weiter


def push_lauf(befehl, cwd):
    """Vorgang eines Pushes, der godot.yml auslöst, sonst None."""
    m = PUSH.search(befehl)
    if not m:
        return None
    cds = CD.findall(befehl[:m.start()])  # `cd ../bornim-main && git push`: Zweig des cd-Ziels (Jerry 12:05, 13:08)
    wo = m.group(1) or (os.path.join(cwd, os.path.expanduser(cds[-1].strip("\"'"))) if cds else cwd)
    ziel = CI_ZWEIG.search(m.group(2))
    zweig = ziel.group(0).split(":")[-1] if ziel else git("rev-parse", "--abbrev-ref", "HEAD", cwd=wo).stdout.strip()
    if not CI_ZWEIG.fullmatch(zweig):
        return None
    oben = git("rev-parse", "--verify", "-q", f"origin/{zweig}", cwd=wo).stdout.strip()
    # Commit im selben Befehl vor dem Push (PreToolUse sieht ihn noch nicht): Nachricht aus -m, Pfade aus dem Arbeitsbaum
    neu = COMMIT.search(befehl[:m.start()])
    nachricht = re.sub(r"^\s*[\"']?(?:\$\(cat\s*<<-?\s*['\"]?\w+['\"]?\s*)?", "", neu.group(1)) if neu else \
        git("log", "-1", "--format=%B", "HEAD", cwd=wo).stdout
    if "[skip ci]" in nachricht or "[ci skip]" in nachricht:
        return None
    if oben:
        pfade = git("diff", "--name-only", f"{oben}..HEAD", cwd=wo).stdout.split()
        if neu:
            pfade += git("diff", "--name-only", "HEAD", cwd=wo).stdout.split()
            pfade += git("ls-files", "--others", "--exclude-standard", cwd=wo).stdout.split()
        if not pfade or not any(p.startswith(CI_PFADE) for p in pfade):
            return None
    nr = re.match(r"\s*(?:\w+:\s*)?(" + NR + r")\b", nachricht)
    return nr.group(1) if nr else zweig


def anhalten(text):
    print(text, file=sys.stderr)
    sys.exit(2)


def main():
    if sys.argv[1:2] == ["--stand"]:
        for nr in sys.argv[2:]:
            n, v = stand(nr)
            print(f"{nr}: {n} von {GRENZE} Probeläufen seit {'Vorlage ' + v if v else 'Beginn der Zählung'}")
        return
    try:
        d = json.load(sys.stdin)
    except ValueError:
        return
    befehl = (d.get("tool_input") or {}).get("command") or ""
    cwd = d.get("cwd") or os.getcwd()
    wer = (d.get("session_id") or "?")[:20]
    try:
        if bildlauf(befehl, cwd):
            m = PROBE.search(befehl)
            if not m:
                anhalten("389 (Chef 27.10., 23:55, höchstens zwei Probeläufe je Vorlage): Bildlauf erkannt. "
                         "Vorgang davorsetzen: `PROBE=<Nr> <Befehl>`; der Haken zählt je Vorgang.")
            nr, art = m.group(1), "rechner"
        else:
            nr, art = push_lauf(befehl, cwd), "ci"
            if not nr:
                return
        n, vorlage = stand(nr)
    except (OSError, subprocess.SubprocessError, ValueError):
        return
    if n >= GRENZE:
        anhalten(f"389 (Chef 27.10., 23:55: „höchstens zwei Läufe und die Betonung hierbei liegt auf höchstens“): für {nr} "
                 f"schon {n} Probeläufe seit {'der Vorlage ' + vorlage if vorlage else 'Beginn der Zählung'}. Kein weiterer Lauf: "
                 f"jetzt vorlegen, was da ist (Datei in docs/chefsache/ansehen/, `meldung.sh --bild` oder `--film` mit „{nr}:“), "
                 "Befund der Fehlerprüfung danach als Text (396). Erst die Vorlage gibt zwei neue Läufe frei.")
    zaehlen(nr, wer, art)
    print(json.dumps({"hookSpecificOutput": {"hookEventName": "PreToolUse",
                      "additionalContext": f"389: Probelauf {n + 1} von {GRENZE} für {nr}"
                      + ("; danach vorlegen." if n + 1 == GRENZE else ".")}}, ensure_ascii=False))


if __name__ == "__main__":
    main()
