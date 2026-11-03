#!/usr/bin/env python3
"""Probelauf-Haken (389; Chef 27.10., 23:55: „389 ja, höchstens zwei Läufe und die Betonung hierbei liegt auf höchstens.“).

PreToolUse-Haken für Bash, alle Rollen. Je Vorlage höchstens zwei Probeläufe, dann vorlegen: beim dritten Lauf für denselben
Vorgang hält der Haken den Befehl an (Exit 2), ohne Ausweg. Seit 407 (Chef 29.10., 10:05: „nach 2 ist maximal Schluss …
Ich habe noch nichts geguckt und freigegeben. Also, warten, bis ich gucke.“) gibt erst das Urteil des Chefs zwei neue Läufe frei,
nicht schon die Vorlage: Urteil = Eintrag im Vorgangsarchiv (`origin/main`), dessen fette Kopfzeile die Nummer nennt, mit Datum
nach dem letzten gezählten Lauf; gilt für jeden Zweig `claude/tom-…` und `claude/jerry-…`.

Probelauf heißt:
- ein Bildlauf am Rechner: Godot mit Fenster (xvfb-run oder `godot --path` ohne `--import`) oder ein Laufskript aus
  `tools/pruef348/` (alle außer `rechner.sh`) oder `*_lauf.sh`; der Vorgang steht davor: `PROBE=<Nr> bash …`;
  kein Probelauf: `godot --headless --path <dir> -s res://tests/<datei>.gd` ohne Bildbefehl in der Testdatei (390a);
- ein Ablauf auf GitHub, von Hand gestartet (407, 02.11.: 20 Filme zu 417 über `tom-probe-417.yml` ungezählt): `actions_run_trigger`
  (run_workflow) oder `gh workflow run`/API `…/dispatches`; Vorgang = erste Nummer der Commit-Nachricht oben auf dem Zweig,
  sonst Nummer in Klammern im Namen des Ablaufs; mit Eingabe bild=nein oder film=nein kein Probelauf (390a); Neustart eines
  Laufs (rerun) hält der Haken an;
- ein Push auf einen Zweig `claude/…`, der einen Ablauf auslöst (letzter Commit ohne „[skip ci]“, Änderung
  unter godot/, tools/blender348/, core/src/main/ oder am Workflow); der Vorgang ist die erste Nummer der Commit-Nachricht.
Vorlage heißt: eine Meldung mit Bild, Film oder Datei zu dem Vorgang (Zeile im Zweig „meldungen“, schreibt `meldung.sh`, 383).
Jeder Lauf wird gezählt, auch einer, der abbricht. Die Zählung steht im Zweig „probelaeufe“ in `probelaeufe.tsv` (überlebt den
Neustart) und hilfsweise in ~/.bornim-probelaeufe.tsv. Bei eigenem Fehler (kein Git, kein Netz) lässt der Haken durch.

Auch von Hand: `python3 tools/probelauf.py --stand <Nr>` zeigt die Zählung.

511 (Chef 03.11., 13:50: „511 ja“; Anlass 13:47: „Warum werden so viele sinnlose und kaputte Filme gemacht?“): ein Filmlauf
startet nur mit Verweis auf ein geprüftes Probebild, das nach dem letzten Filmlauf zu diesem Vorgang eingetragen ist.
Geprüft heißt (Chef 13:58: „Auf mich warten. Die Helfer können gerne sonstwas prüfen, aber ob Inhalt da ist, kann ich als
Mensch sicher besser sehen.“): der Chef hat es gesehen, Eintrag im Vorgangsarchiv „<Nr> Probebild passt“ nach dem Probebild.
- Filmlauf: Bildlauf am Rechner mit `--write-movie`, `FILM=`/`WALKFILM=`/`IDLEFILM=`/`FOEFILM=`/`FILMBATCH=`, `tools/t film`
  `.mp4`, `ffmpeg` oder einem Laufskript, dessen Name „film“ enthält oder das so filmt; jeder von Hand gestartete Ablauf mit
  Bild; jeder Push, der einen Ablauf mit `--write-movie` auslöst (unlesbar: zählt als Filmlauf).
- Probebild: ein Einzelbild aus demselben Filmskript und derselben Szene, am Rechner mit `PROBEBILD=<Nr> <Befehl>` (ohne
  Film; zählt nicht als Probelauf 389); eintragen mit
  `python3 tools/probelauf.py --probebild <Nr> <Bild.png|Link> <Filmskript> "<was zu sehen sein muss>"`, dann an den Chef
  (13:56: „das Probebild kann man mir vorlegen. Mit dem Hinweis, was zu prüfen ist.“): `meldung.sh --bild` mit dieser Liste
  und Datei `docs/chefsache/ansehen/<Nr>-probebild.md`. Freigabe: Archiveintrag mit „<Nr> Probebild passt“ in der fetten
  Kopfzeile (deren Zeit) oder im Text mit „(Chef [TT.MM.,] HH:MM“ dahinter. Am Rechner muss der Name des Filmskripts im
  Filmbefehl stehen. Jeder Filmlauf verbraucht das Probebild.
"""
import datetime
import json
import os
import re
import subprocess
import sys
import tempfile
import time
import uuid
import zoneinfo

GRENZE = 2
BERLIN = zoneinfo.ZoneInfo("Europe/Berlin")
REPO = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
LOKAL = os.environ.get("BORNIM_PROBELAEUFE") or os.path.expanduser("~/.bornim-probelaeufe.tsv")
ZWEIG = "probelaeufe"  # eigener Zweig: meldung.sh schreibt „meldungen“ mit nur einer Datei
DATEI = "probelaeufe.tsv"
BILDER = "probebilder.tsv"  # 511: geprüfte Probebilder, gleicher Zweig
LOKAL_BILDER = os.environ.get("BORNIM_PROBEBILDER") or os.path.expanduser("~/.bornim-probebilder.tsv")

NR = r"[A-Za-z]?\d+[a-z]?(?:\.\d+[a-z]?)*"
PROBE = re.compile(r"\bPROBE=(" + NR + r")\b")
PROBEBILD = re.compile(r"\bPROBEBILD=(" + NR + r")\b")
FILM = re.compile(r"--write-movie|\.mp4\b|\bffmpeg\b|\b(?:WALK|IDLE|FOE)?FILM(?:BATCH)?=|\btools/t\s+film\b|[\w./-]*film[\w-]*\.(?:sh|py)\b", re.I)
GODOT_LAUF = re.compile(r"xvfb-run[^\n|;&]*godot[^\n|;&]*|\bgodot(?:\.\S+)?\s[^\n|;&]*--path[^\n|;&]*")
SKRIPT = re.compile(r"tools/pruef348/(?!rechner\.sh)[\w.-]+\.sh|\b\w+_lauf\.sh")
PUSH = re.compile(r"\bgit\s+(?:-C\s+(\S+)\s+)?push\b([^\n|;&]*)")
COMMIT = re.compile(r"\bgit\s+(?:-C\s+\S+\s+)?commit\b[^\n]*?\s-[a-zA-Z]*m\s*(.+)", re.S)
TEST_SKRIPT = re.compile(r"(?:^|\s)-s\s+[\"']?res://tests/([\w./-]+\.gd)\b")
BILDBEFEHL = re.compile(r"save_png|save_jpg|save_webp|save_exr|get_image\s*\(|get_texture\s*\(|MovieWriter|screenshot", re.I)
CD = re.compile(r"\bcd\s+([^\s;&|]+)")
CI_ZWEIG = re.compile(r"claude/[\w./-]+")  # 407 (02.11.): jeder Arbeitszweig, auch grundstand-461, spike-, tuffy-
BEFEHL_ANFANG = r"(?:^|[;&|(`]|\$\()\s*(?:\w+=\S*\s+)*"  # nur als Befehl, nicht in einer Commit-Nachricht (Fehlzählung 02.11.)
GH_LAUF = re.compile(BEFEHL_ANFANG + r"gh\s+workflow\s+run\s+([^\n|;&]*)", re.M)
GH_RERUN = re.compile(BEFEHL_ANFANG + r"(?:gh\s+run\s+rerun\b|(?:curl|gh\s+api)\b[^\n|;&]*/actions/(?:runs|jobs)/\d+/rerun)", re.M)
API_LAUF = re.compile(BEFEHL_ANFANG + r"(?:curl|gh\s+api)\b[^\n|;&]*/actions/workflows/([\w.-]+)/dispatches[^\n|;&]*", re.M)
ARCHIV_KOPF = re.compile(r"^- \*\*([^*]+)\*\*\s*\((\d\d)\.(\d\d)\.,\s*(\d\d):(\d)([\dx])", re.M)
CI_PFADE = ("godot/", "tools/blender348/", "core/src/main/", ".github/workflows/")  # 407: auch eigene Probe-Abläufe


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
    # 464: `--check-only` liest nur den Quelltext (Parsefehler), führt nichts aus, zeigt kein Bild
    return SKRIPT.search(befehl) or any("--import" not in m.group(0) and "--check-only" not in m.group(0)
                                        and not testlauf(m.group(0), befehl, cwd) for m in GODOT_LAUF.finditer(befehl))


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


def urteil(nr):
    """407: Zeit des jüngsten Archiveintrags zu nr (fette Kopfzeile nennt die Nummer), sonst None; „21:1x“ zählt als 21:10."""
    _, archiv = zweig_lesen("docs/VORGANGSARCHIV.md", "main")
    if not archiv:
        p = os.path.join(REPO, "docs", "VORGANGSARCHIV.md")
        archiv = open(p, encoding="utf-8").read() if os.path.exists(p) else ""
    heute = datetime.datetime.now(BERLIN)
    beste = None

    def zeit(tag, monat, std, m1, m2):
        tag, monat = int(tag), int(monat)
        jahr = heute.year if (monat, tag) <= (heute.month, heute.day) else heute.year - 1
        # D50.5 (c): „21:1x“ zählt als 21:19, damit kein Lauf vor dem echten Urteil als danach gilt
        return f"{jahr}-{monat:02d}-{tag:02d} {std}:{m1}{'9' if m2 == 'x' else m2}:00"

    for m in ARCHIV_KOPF.finditer(archiv):
        ende = archiv.find("\n- **", m.end())
        eintrag = archiv[m.end():ende if ende >= 0 else len(archiv)]
        # D68.1: „453b und 463a … zwei Läufe frei (Sokrates)“ im Text eines Eintrags gibt frei, ab dessen Zeit
        if any("Läufe frei" in teil and re.search(r"(?<![\w.])" + re.escape(nr) + r"(?![\w]|\.\d)", teil)
               for teil in re.split(r"[;:]\s", eintrag)):
            beste = max(beste or "", zeit(m.group(2), m.group(3), m.group(4), m.group(5), m.group(6)))
            continue
        klammer = eintrag[:eintrag.find(")")] if ")" in eintrag else ""
        vorentscheid = "Vorentscheid" in m.group(1) or "Vorentscheid" in klammer or "→ **Vorentscheid" in eintrag
        if "Probebild passt" in m.group(1):  # 511: Freigabe des Probebilds gibt nur den Film frei, keine zwei neuen Läufe
            continue
        if "Läufe frei" in m.group(1):  # 480.1 (Chef 02.11., 18:46): weitere Läufe gibt Sokrates frei, Kopf „<Nr>, Läufe frei“
            vorentscheid = False
        if not re.search(r"(?<![\w.])" + re.escape(nr) + r"(?![\w]|\.\d)", m.group(1)):
            continue
        if not vorentscheid:
            beste = max(beste or "", zeit(m.group(2), m.group(3), m.group(4), m.group(5), m.group(6)))
            continue
        # D50.5 (b): ein Vorentscheid ist kein Urteil des Chefs; D63.3: gebilligt gilt ab der Zeit der Billigung,
        # „348.12k **gebilligt** (Chef 02.11., 11:08 …“ oder „461a, 461d **gebilligt** (Chef 23:01 …“ (Tag des Kopfs)
        g = re.search(r"(?<![\w.])" + re.escape(nr) + r"(?![\w]|\.\d)[^;→]{0,40}?\*?\*?gebilligt\*?\*?\s*\(Chef\s+"
                      r"(?:(\d\d)\.(\d\d)\.,?\s*)?(\d\d):(\d)([\dx])", eintrag)
        if g:
            beste = max(beste or "", zeit(g.group(1) or m.group(2), g.group(2) or m.group(3), g.group(3), g.group(4), g.group(5)))
            continue
        g = re.search(r"\*\*gebilligt (\d\d)\.(\d\d)\.", eintrag)  # „→ **gebilligt 27.10. (Vorentscheid …)**“: ohne Uhrzeit Tagesende
        if g and "gebilligt" in eintrag[eintrag.rfind("→"):]:
            beste = max(beste or "", zeit(g.group(1), g.group(2), "23", "5", "9"))
    return beste


def stand(nr):
    """(Läufe seit dem letzten Urteil des Chefs zu nr, Zeit des Urteils oder None); 407: eine Vorlage allein gibt nichts frei."""
    _, laeufe = zweig_lesen(DATEI)
    lokal = open(LOKAL, encoding="utf-8").read() if os.path.exists(LOKAL) else ""
    frei = urteil(nr)
    gesehen = set()
    for z in zeilen(laeufe) + zeilen(lokal):
        if z[1] == nr and (frei is None or z[0] > frei):
            gesehen.add(tuple(z[:5]))
    return len(gesehen), frei


def zaehlen(nr, wer, art, datei=DATEI, lokal=LOKAL, extra=()):
    zeile = "\t".join([jetzt(), nr, wer, art, uuid.uuid4().hex[:8], *extra])  # Kennung: Zweig und Datei doppeln Zeilen
    with open(lokal, "a", encoding="utf-8") as f:
        f.write(zeile + "\n")
    if os.environ.get("BORNIM_PROBELAUF_TROCKEN"):
        return
    for versuch in range(3):
        kopf, alt = zweig_lesen(datei)
        neu = "\n".join(alt.splitlines()[-2000:] + [zeile]) + "\n"
        blob = subprocess.run(["git", "-C", REPO, "hash-object", "-w", "--stdin"], input=neu, capture_output=True,
                              text=True, timeout=20).stdout.strip()
        idx = tempfile.mktemp()
        env = dict(os.environ, GIT_INDEX_FILE=idx)
        baum = ""
        if kopf:
            subprocess.run(["git", "-C", REPO, "read-tree", kopf], env=env, capture_output=True, timeout=20)
        subprocess.run(["git", "-C", REPO, "update-index", "--add", "--cacheinfo", f"100644,{blob},{datei}"], env=env,
                       capture_output=True, timeout=20)
        baum = subprocess.run(["git", "-C", REPO, "write-tree"], env=env, capture_output=True, text=True, timeout=20).stdout.strip()
        if os.path.exists(idx):
            os.remove(idx)
        commit = git("commit-tree", baum, *(["-p", kopf] if kopf else []), "-m", f"Probelauf {nr} ({wer})").stdout.strip()
        if commit and git("push", "-q", "origin", f"{commit}:refs/heads/{ZWEIG}").returncode == 0:
            return
    # Push fehlgeschlagen: die lokale Zeile zählt weiter


def push_lauf(befehl, cwd):
    """(Vorgang, Film?) eines Pushes, der einen Ablauf auslöst, sonst None; Film: der Ablauf ruft `--write-movie` (511)."""
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
    else:
        pfade = None
    los = loest_aus(wo, zweig, pfade, nachricht)
    if not los:  # Tom 02.11., 16:3x: Push ohne Lauf zählte als Probelauf
        return None
    nr = re.match(r"\s*(?:\w+:\s*)?(" + NR + r")\b", nachricht)
    return (nr.group(1) if nr else zweig), los == FILMT


FILMT = 2


def _glob(muster, text):
    """GitHub-Muster: ** über Schrägstriche, * innerhalb eines Teils."""
    rx = re.escape(muster).replace(r"\*\*", "\0").replace(r"\*", "[^/]*").replace("\0", ".*")
    return re.fullmatch(rx, text) is not None


def loest_aus(wo, zweig, pfade, nachricht):
    """Startet ein Ablauf unter .github/workflows/ bei einem Push auf zweig? (on.push.branches/paths; Job-Bedingung
    startsWith(github.event.head_commit.message, '…')). 0 nein, 1 ja, FILMT ja und er filmt (`--write-movie`, 511).
    Unlesbar oder unklar: FILMT, lieber zählen und sperren als durchlassen."""
    try:
        import yaml
    except ImportError:
        return FILMT
    wurzel = git("rev-parse", "--show-toplevel", cwd=wo).stdout.strip()
    ordner = os.path.join(wurzel, ".github", "workflows")
    if not wurzel or not os.path.isdir(ordner):
        return FILMT
    los = 0
    for datei in os.listdir(ordner):
        if not datei.endswith((".yml", ".yaml")):
            continue
        try:
            text = open(os.path.join(ordner, datei), encoding="utf-8").read()
            d = yaml.safe_load(text) or {}
        except Exception:
            return FILMT
        an = d.get("on", d.get(True))  # YAML liest „on“ als True
        if isinstance(an, str):
            an = {an: None}
        if isinstance(an, list):
            an = {k: None for k in an}
        if not isinstance(an, dict) or "push" not in an:
            continue
        push = an.get("push") or {}
        zweige = push.get("branches")
        if zweige and not any(_glob(m, zweig) for m in zweige):
            continue
        if any(_glob(m, zweig) for m in push.get("branches-ignore") or []):
            continue
        wege = push.get("paths")
        if wege and pfade is not None and not any(_glob(m, p) for m in wege for p in pfade):
            continue
        bed = re.findall(r"startsWith\(\s*github\.event\.head_commit\.message\s*,\s*'([^']+)'\s*\)", text)
        jobs = d.get("jobs") or {}
        if bed and jobs and all("startsWith(github.event.head_commit.message" in str((j or {}).get("if", "")) for j in jobs.values()) \
                and not any(nachricht.lstrip().startswith(b) for b in bed):
            continue
        los = max(los, FILMT if "--write-movie" in text else 1)
    return los


RERUN = ("407 (Chef 02.11., 07:18: „die ganze Nacht über jetzt 1000 Filmchen gedreht“): einen Lauf neu starten zählt der Haken "
         "nicht nach Vorgang; neu starten nur mit run_workflow (`mcp__github__actions_run_trigger` method run_workflow oder "
         "`gh workflow run`), dann zählt er je Vorgang.")


def vorgang_aus_ref(ref, ablauf):
    """407: Vorgang eines von Hand gestarteten Ablaufs: erste Nummer der Commit-Nachricht oben auf ref, sonst Nummer in
    Klammern im Namen des Ablaufs („Tom Probe Tragart (417)“), sonst der Zweig selbst."""
    ref = (ref or "").removeprefix("refs/heads/")
    nachricht, name = "", ""
    if ref and git("fetch", "-q", "origin", ref).returncode == 0:
        nachricht = git("log", "-1", "--format=%B", "FETCH_HEAD").stdout
        if ablauf and not ablauf.isdigit():
            datei = ablauf if "/" in ablauf else ".github/workflows/" + ablauf
            name = (re.search(r"^name:\s*(.+)$", git("show", f"FETCH_HEAD:{datei}").stdout, re.M) or [None, ""])[1]
    nr = re.match(r"\s*(?:\w+:\s*)?(" + NR + r")\b", nachricht) or re.search(r"\((" + NR + r")\)", name)
    return nr.group(1) if nr else (ref or ablauf or "?")


def ohne_bild(eingaben):
    """390a: Ablauf nur mit Messung ohne Bild (Eingabe bild=nein oder film=nein) ist kein Probelauf."""
    return any(str(eingaben.get(k, "")).strip().lower() == "nein" for k in ("bild", "film"))


def handlauf_mcp(d):
    """407: `actions_run_trigger` über den GitHub-Server: (Vorgang, Art), RERUN zum Anhalten, oder None."""
    e = d.get("tool_input") or {}
    methode = e.get("method", "")
    if methode in ("rerun_workflow_run", "rerun_failed_jobs"):
        return RERUN
    if methode != "run_workflow" or ohne_bild(e.get("inputs") or {}):
        return None
    return vorgang_aus_ref(e.get("ref"), str(e.get("workflow_id") or "")), "hand"


def handlauf_bash(befehl):
    """407: `gh workflow run …` oder Aufruf der API (…/dispatches, …/rerun) aus der Shell; wie handlauf_mcp."""
    if GH_RERUN.search(befehl):
        return RERUN
    m = GH_LAUF.search(befehl)
    if m:
        teile = m.group(1).split()
        ablauf = next((t for t in teile if not t.startswith("-")), "")
        ref = re.search(r"(?:--ref|-r)[=\s]+(\S+)", m.group(1))
        eing = dict(re.findall(r"(?:-f|-F|--field|--raw-field)[=\s]+[\"']?(\w+)=([^\s\"']*)", m.group(1)))
        if ohne_bild(eing):
            return None
        return vorgang_aus_ref(ref.group(1).strip("\"'") if ref else "", ablauf), "hand"
    m = API_LAUF.search(befehl)
    if m:
        # JSON (curl -d '{"ref":…}') oder Felder (gh api -f ref=…, -F, --field, --raw-field; D64.1)
        ref = re.search(r"\\?[\"']ref\\?[\"']\s*:\s*\\?[\"']([^\"'\\]+)", befehl) or \
            re.search(r"(?:-f|-F|--field|--raw-field)[=\s]+[\"']?ref=([^\s\"']+)", befehl)
        eing = dict(re.findall(r"\\?[\"'](bild|film)\\?[\"']\s*:\s*\\?[\"'](\w+)", befehl))
        eing.update(re.findall(r"(?:-f|-F|--field|--raw-field)[=\s]+[\"']?inputs\[(bild|film)\]=(\w+)", befehl))
        if ohne_bild(eing):
            return None
        return vorgang_aus_ref(ref.group(1) if ref else "", m.group(1)), "hand"
    return None


GODOT_BIN = [os.path.expanduser("~/godot/godot"), "/usr/local/bin/godot", "/usr/bin/godot"]


ENDE = time.monotonic() + 80  # Haken-Zeitgrenze 90 s (.claude/settings.json), 10 s Rand für das Zählen
UNGEPRUEFT = []  # 464.1 (D61.2): .gd-Dateien, die aus Zeitgründen nicht gelesen wurden; der Haken nennt sie


def ungeprueft_hinweis():
    if not UNGEPRUEFT:
        return ""
    return (f"464: {len(UNGEPRUEFT)} geänderte .gd-Dateien aus Zeitgründen nicht auf Parsefehler gelesen "
            f"({', '.join(UNGEPRUEFT[:4])}{' …' if len(UNGEPRUEFT) > 4 else ''}); vor dem Push selbst prüfen: "
            "godot --headless --path godot --check-only -s res://<datei>.")


def parse_pruefen(befehl, cwd):
    """464 (Chef 01.11., 20:4x: „irgendwer produziert hier abends brutal viele Fehler … fast 20 E-Mails“): vor jedem Push auf
    einen Zweig `claude/…` jede geänderte .gd-Datei mit Godot `--check-only` lesen (nach `--import`, sonst fehlen die
    Klassennamen); Parsefehler hält den Push an. Nachgestellt an Lauf ef817fa (Tom, 13:31 UTC): gleicher Fehler wie in CI.
    Gibt den Grund zum Anhalten zurück oder None."""
    m = PUSH.search(befehl)
    if not m:
        return None
    cds = CD.findall(befehl[:m.start()])
    wo = m.group(1) or (os.path.join(cwd, os.path.expanduser(cds[-1].strip("\"'"))) if cds else cwd)
    ziel = re.search(r"claude/[\w./-]+", m.group(2))
    zweig = ziel.group(0).split(":")[-1] if ziel else git("rev-parse", "--abbrev-ref", "HEAD", cwd=wo).stdout.strip()
    if not zweig.startswith("claude/"):
        return None
    wurzel = git("rev-parse", "--show-toplevel", cwd=wo).stdout.strip()
    if not wurzel or not os.path.isdir(os.path.join(wurzel, "godot")):
        return None
    oben = git("rev-parse", "--verify", "-q", f"origin/{zweig}", cwd=wo).stdout.strip() or \
        git("merge-base", "HEAD", "origin/main", cwd=wo).stdout.strip()
    if not oben:
        return None
    pfade = git("diff", "--name-only", f"{oben}..HEAD", cwd=wo).stdout.split()
    if COMMIT.search(befehl[:m.start()]):  # Commit im selben Befehl: Arbeitsbaum zählt mit
        pfade += git("diff", "--name-only", "HEAD", cwd=wo).stdout.split()
        pfade += git("ls-files", "--others", "--exclude-standard", cwd=wo).stdout.split()
    gd = sorted({p[len("godot/"):] for p in pfade if p.startswith("godot/") and p.endswith(".gd")
                 and os.path.isfile(os.path.join(wurzel, p))})
    if not gd:
        return None
    godot = next((b for b in GODOT_BIN if os.path.isfile(b)), None)
    if not godot:  # Jerrys Sitzung darf Godot nicht immer laden (01.11.): nicht anhalten, sonst steht der Push ganz
        return None
    pfad = os.path.join(wurzel, "godot")
    vorher = set(git("ls-files", "--others", "--exclude-standard", "godot", cwd=wurzel).stdout.split())
    try:
        subprocess.run([godot, "--headless", "--import", "--path", pfad], capture_output=True, timeout=45)
    except subprocess.TimeoutExpired:
        pass
    for neu in set(git("ls-files", "--others", "--exclude-standard", "godot", cwd=wurzel).stdout.split()) - vorher:
        if neu.endswith(".uid"):  # vom Import angelegt: Arbeitsbaum bleibt, wie er war
            try:
                os.remove(os.path.join(wurzel, neu))
            except OSError:
                pass
    fehler = []
    for datei in gd:  # 464.1 (D61.2): alle Dateien, bis die Hakenzeit (90 s) knapp wird; Rest als Hinweis
        rest = ENDE - time.monotonic()
        if rest < 5:
            UNGEPRUEFT.append(datei)
            continue
        try:
            r = subprocess.run([godot, "--headless", "--path", pfad, "--check-only", "-s", "res://" + datei],
                               capture_output=True, text=True, timeout=min(20, rest - 2))
        except subprocess.TimeoutExpired:
            UNGEPRUEFT.append(datei)
            continue
        zeilen = [z.strip() for z in (r.stdout + r.stderr).splitlines() if "Parse Error" in z or "GDScript::reload" in z]
        if r.returncode != 0 and zeilen:
            fehler.append(datei + ": " + " ".join(zeilen[:2]))
    if fehler:
        return ("464: Push angehalten, Parsefehler in GDScript (CI würde rot, der Chef bekommt eine E-Mail). Erst beheben, "
                "dann erneut pushen:\n" + "\n".join(fehler[:6]))
    return None


def filmlauf_rechner(befehl, cwd):
    """511: filmt dieser Bildlauf am Rechner? Marke im Befehl oder ein Laufskript, das filmt (`--write-movie`, mp4, ffmpeg)."""
    if FILM.search(befehl):
        return True
    for m in SKRIPT.finditer(befehl):
        for basis in [cwd, REPO] + [os.path.join(cwd, os.path.expanduser(c)) for c in CD.findall(befehl)]:
            datei = os.path.join(basis, m.group(0))
            if os.path.isfile(datei):
                if FILM.search(open(datei, encoding="utf-8", errors="replace").read()):
                    return True
                break
    return False


def probebilder(nr):
    """511: eingetragene Probebilder zu nr, [(Zeit, Bild, Filmskript, Befund)], aus Zweig und lokaler Datei."""
    _, text = zweig_lesen(BILDER)
    lokal = open(LOKAL_BILDER, encoding="utf-8").read() if os.path.exists(LOKAL_BILDER) else ""
    return sorted({(z[0], z[5], z[6], z[7]) for z in zeilen(text) + zeilen(lokal) if len(z) >= 8 and z[1] == nr})


def letzter_film(nr):
    _, laeufe = zweig_lesen(DATEI)
    lokal = open(LOKAL, encoding="utf-8").read() if os.path.exists(LOKAL) else ""
    return max((z[0] for z in zeilen(laeufe) + zeilen(lokal) if z[1] == nr and z[3].endswith("-film")), default="")


def probebild_passt(nr):
    """511 (Chef 13:58): Zeit des jüngsten Archiveintrags „<nr> Probebild passt“, sonst ""; „13:5x“ zählt als 13:59."""
    _, archiv = zweig_lesen("docs/VORGANGSARCHIV.md", "main")
    if not archiv:
        p = os.path.join(REPO, "docs", "VORGANGSARCHIV.md")
        archiv = open(p, encoding="utf-8").read() if os.path.exists(p) else ""
    heute = datetime.datetime.now(BERLIN)
    nrx = r"(?<![\w.])" + re.escape(nr) + r"(?![\w]|\.\d)"
    beste = ""

    def zeit(tag, monat, std, m1, m2):
        tag, monat = int(tag), int(monat)
        jahr = heute.year if (monat, tag) <= (heute.month, heute.day) else heute.year - 1
        return f"{jahr}-{monat:02d}-{tag:02d} {std}:{m1}{'9' if m2 == 'x' else m2}:59"

    for m in ARCHIV_KOPF.finditer(archiv):
        ende = archiv.find("\n- **", m.end())
        eintrag = archiv[m.end():ende if ende >= 0 else len(archiv)]
        if re.search(nrx + r"[^;:]{0,30}?Probebild passt", m.group(1)):
            beste = max(beste, zeit(m.group(2), m.group(3), m.group(4), m.group(5), m.group(6)))
        for g in re.finditer(nrx + r"[^;→]{0,30}?Probebild passt\W{0,4}\(Chef\s+(?:(\d\d)\.(\d\d)\.,?\s*)?(\d\d):(\d)([\dx])",
                             eintrag):
            beste = max(beste, zeit(g.group(1) or m.group(2), g.group(2) or m.group(3), g.group(3), g.group(4), g.group(5)))
    return beste


def film_sperre(nr, art, befehl):
    """511: Grund zum Anhalten oder None. Gilt ein Probebild, das nach dem letzten Filmlauf zu nr eingetragen wurde und das
    der Chef danach mit „<nr> Probebild passt“ freigegeben hat."""
    seit = letzter_film(nr)
    bilder = [b for b in probebilder(nr) if b[0] > seit]
    if not bilder:
        return (f"511 (Chef 03.11., 13:50: „511 ja“): Filmlauf für {nr} ohne Probebild"
                + (f" seit dem letzten Filmlauf {seit}" if seit else "") + ". Erst ein Einzelbild aus demselben Filmskript "
                f"und derselben Szene (`PROBEBILD={nr} <Befehl ohne Film>`, zählt nicht als Probelauf); fehlt sichtbar etwas: "
                f"Ursache nachstellen. Dann `python3 tools/probelauf.py --probebild {nr} <Bild.png|Link> <Filmskript> "
                "\"<was zu sehen sein muss>\"` und dem Chef vorlegen; Filmlauf erst nach seinem „Probebild passt“.")
    passt = probebild_passt(nr)
    if not passt or passt[:16] < bilder[-1][0][:16]:
        return (f"511 (Chef 03.11., 13:58: „Auf mich warten.“): Probebild zu {nr} ({bilder[-1][0]}) ist noch nicht vom Chef "
                f"freigegeben. Vorlegen: `meldung.sh <Name> --bild <Bild> \"{nr}: Probebild; zu prüfen: {bilder[-1][3]}\"` und "
                f"Datei docs/chefsache/ansehen/{nr}-probebild.md; Filmlauf erst nach Archiveintrag „{nr} Probebild passt“. "
                "Bis dahin an einem anderen Vorgang weiter.")
    skript = os.path.basename(bilder[-1][2].rstrip("/"))
    if art == "rechner" and skript not in ("", "-") and skript not in befehl:
        return (f"511: das Probebild zu {nr} ({bilder[-1][1]}) kommt aus „{skript}“, der Filmlauf ruft ein anderes Skript. "
                "Probebild aus demselben Filmskript eintragen.")
    return None


def probebild_eintragen(args):
    """511: `--probebild <Nr> <Bild.png|Link> <Filmskript> "<was zu sehen sein muss>"`; Exit 1 mit Grund bei Fehler."""
    if len(args) != 4:
        sys.exit("Aufruf: python3 tools/probelauf.py --probebild <Nr> <Bild.png|Link> <Filmskript> \"<was zu sehen sein muss>\"")
    nr, bild, skript, befund = (a.replace("\t", " ").replace("\n", " ").strip() for a in args)
    if not re.fullmatch(NR, nr):
        sys.exit(f"511: „{nr}“ ist keine Vorgangsnummer.")
    if not re.match(r"https?://", bild):
        if not os.path.isfile(bild):
            sys.exit(f"511: Bild „{bild}“ nicht gefunden.")
        with open(bild, "rb") as f:
            kopf = f.read(8)
        if kopf != b"\x89PNG\r\n\x1a\n" or os.path.getsize(bild) < 1000:
            sys.exit(f"511: „{bild}“ ist kein PNG oder fast leer (unter 1000 Bytes).")
        bild = os.path.abspath(bild)
    if not skript:
        sys.exit("511: Filmskript fehlt (Datei oder Ablauf, aus dem auch der Film kommt).")
    if len(befund) < 10:
        sys.exit("511: Prüfliste fehlt: was muss zu sehen sein (Figur, Waffe, Gegner, kein Menü …)?")
    wer = os.environ.get("CLAUDE_SESSION_ID", "hand")[:20]
    zaehlen(nr, wer, "probebild", BILDER, LOKAL_BILDER, (bild, skript, befund[:300]))
    print(f"511: Probebild für {nr} eingetragen. Jetzt dem Chef vorlegen (`meldung.sh --bild`, „{nr}: Probebild; zu prüfen: "
          f"{befund}“, Datei docs/chefsache/ansehen/{nr}-probebild.md); Filmlauf erst nach Archiveintrag „{nr} Probebild passt“.")


def anhalten(text):
    print(text, file=sys.stderr)
    sys.exit(2)


def main():
    if sys.argv[1:2] == ["--stand"]:
        for nr in sys.argv[2:]:
            n, v = stand(nr)
            print(f"{nr}: {n} von {GRENZE} Probeläufen seit {'Urteil ' + v if v else 'Beginn der Zählung'}")
            seit = letzter_film(nr)
            frei = [b for b in probebilder(nr) if b[0] > seit]
            passt = probebild_passt(nr)
            print(f"{nr}: Probebild (511) " + ("fehlt, kein Filmlauf" if not frei else
                  f"{frei[-1][0]} ({frei[-1][2]}), " + ("vom Chef freigegeben " + passt + ", Filmlauf frei"
                                                         if passt and passt[:16] >= frei[-1][0][:16] else "wartet auf den Chef")))
        return
    if sys.argv[1:2] == ["--probebild"]:
        return probebild_eintragen(sys.argv[2:])
    try:
        d = json.load(sys.stdin)
    except ValueError:
        return
    befehl = (d.get("tool_input") or {}).get("command") or ""
    cwd = d.get("cwd") or os.getcwd()
    wer = (d.get("session_id") or "?")[:20]
    if "actions_run_trigger" in (d.get("tool_name") or ""):  # 407: Start von Hand über den GitHub-Server
        try:
            hand = handlauf_mcp(d)
        except (OSError, subprocess.SubprocessError, ValueError):
            hand = None
        if hand == RERUN:
            anhalten(RERUN)
        if hand:
            pruefen_und_zaehlen(*hand, wer, film=True)
        return
    try:
        grund = parse_pruefen(befehl, cwd)  # 464: vor dem Zählen, ein angehaltener Push ist kein Lauf
    except (OSError, subprocess.SubprocessError, ValueError):
        grund = None
    if grund:
        anhalten(grund)
    film = False
    try:
        if bildlauf(befehl, cwd) and not PROBE.search(befehl) and (pb := PROBEBILD.search(befehl)):
            if filmlauf_rechner(befehl, cwd):  # 511: Probebild ist ein Einzelbild, kein Film
                anhalten(f"511: `PROBEBILD={pb.group(1)}` gilt nur für ein Einzelbild; dieser Befehl filmt. Für den Film "
                         f"`PROBE={pb.group(1)}` mit eingetragenem Probebild.")
            return hinweis_geben(f"511: Probebild zu {pb.group(1)}, zählt nicht als Probelauf. Eintragen mit "
                                 "`python3 tools/probelauf.py --probebild …`, dann dem Chef vorlegen.")
        if bildlauf(befehl, cwd):
            m = PROBE.search(befehl)
            if not m:
                anhalten("389 (Chef 27.10., 23:55, höchstens zwei Probeläufe je Vorlage): Bildlauf erkannt. "
                         "Vorgang davorsetzen: `PROBE=<Nr> <Befehl>`; der Haken zählt je Vorgang.")
            nr, art, film = m.group(1), "rechner", filmlauf_rechner(befehl, cwd)
        elif (hand := handlauf_bash(befehl)):
            if hand == RERUN:
                anhalten(RERUN)
            (nr, art), film = hand, True
        else:
            push = push_lauf(befehl, cwd)
            if not push:
                return hinweis_geben()
            (nr, film), art = push, "ci"
    except (OSError, subprocess.SubprocessError, ValueError):
        return hinweis_geben()
    pruefen_und_zaehlen(nr, art, wer, film, befehl)


def pruefen_und_zaehlen(nr, art, wer, film=False, befehl=""):
    try:
        n, vorlage = stand(nr)
        sperre = film_sperre(nr, art, befehl) if film else None
    except (OSError, subprocess.SubprocessError, ValueError):
        return hinweis_geben()
    if n >= GRENZE:
        anhalten(f"389 (Chef 27.10., 23:55: „höchstens zwei Läufe und die Betonung hierbei liegt auf höchstens“): für {nr} "
                 f"schon {n} Probeläufe seit {'deinem Urteil ' + vorlage if vorlage else 'Beginn der Zählung'}. Kein weiterer Lauf: "
                 f"jetzt vorlegen, was da ist (Datei in docs/chefsache/ansehen/, `meldung.sh --bild` oder `--film` mit „{nr}:“), "
                 "Befund der Fehlerprüfung danach als Text (396). Erst das Urteil des Chefs (Eintrag im Vorgangsarchiv) gibt zwei neue "
                 "Läufe frei (407), oder Sokrates mit einem Archiveintrag „<Nr>, Läufe frei“ (480.1; Bitte an ihn per Vorrat, nie "
                 "Chefsache); bis dahin an einem anderen Vorgang weiter.")
    if sperre:
        anhalten(sperre)
    zaehlen(nr, wer, art + ("-film" if film else ""))
    hinweis_geben(f"389: Probelauf {n + 1} von {GRENZE} für {nr}" + ("; danach vorlegen." if n + 1 == GRENZE else "."))


def hinweis_geben(text=""):
    """Zusatztext an die Sitzung (PreToolUse additionalContext): Zählstand 389 und, falls nötig, Ungeprüftes 464.1."""
    text = " ".join(t for t in (text, ungeprueft_hinweis()) if t)
    if text:
        print(json.dumps({"hookSpecificOutput": {"hookEventName": "PreToolUse", "additionalContext": text}}, ensure_ascii=False))


if __name__ == "__main__":
    main()
