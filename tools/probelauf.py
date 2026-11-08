#!/usr/bin/env python3
"""Probelauf-Haken (621 A, Chef 07.11., 16:4x: je Aussehen-Thema höchstens eine Probe vor dem Chef; ersetzt die Rundenzahl 389).

PreToolUse-Haken für Bash, alle Rollen. Je Vorlage höchstens ein Probelauf, dann vorlegen: beim zweiten Lauf für denselben
Vorgang hält der Haken den Befehl an (Exit 2), ohne Ausweg. Seit 407 (Chef 29.10., 10:05: „nach 2 ist maximal Schluss …
Ich habe noch nichts geguckt und freigegeben. Also, warten, bis ich gucke.“) gibt erst das Urteil des Chefs (nach „nein“: seine Wahl aus der Rückfrage mit Wegen und Kosten, 621 A) einen neuen Lauf frei,
nicht schon die Vorlage: Urteil = Eintrag im Vorgangsarchiv (`origin/main`), dessen fette Kopfzeile die Nummer nennt, mit Datum
nach dem letzten gezählten Lauf; gilt für jeden Zweig `claude/tom-…` und `claude/jerry-…`.

Probelauf heißt:
- ein Bildlauf am Rechner: Godot mit Fenster (xvfb-run oder `godot --path` ohne `--import`) oder ein Laufskript aus
  `tools/pruef348/` (alle außer `rechner.sh`) oder `*_lauf.sh`; der Vorgang steht davor: `PROBE=<Nr> bash …`;
  kein Probelauf: `godot --headless --path <dir> -s res://tests/<datei>.gd` ohne Bildbefehl in der Testdatei (390a);
- ein Ablauf auf GitHub, von Hand gestartet (407, 02.11.: 20 Filme zu 417 über `tom-probe-417.yml` ungezählt): `actions_run_trigger`
  (run_workflow) oder `gh workflow run`/API `…/dispatches`; Vorgang = erste Nummer der Commit-Nachricht oben auf dem Zweig,
  sonst Nummer in Klammern im Namen des Ablaufs; auch ein Messlauf mit bild=nein (646, ersetzt 390a für den Bauserver),
  nur ein Sammelbuild `claude/build-<n>` für den Gerätetest nicht; Neustart eines Laufs (rerun) hält der Haken an;
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
  Kopfzeile (deren Zeit) oder im Text mit „(Chef [TT.MM.,] HH:MM“ dahinter. Danach (511a, Chef 13:59: „1“) prüft ein
  Helfer das Probebild genau: `python3 tools/probelauf.py --helfer <Nr> "ok: <was zu sehen ist>"`; erst dann der Film.
  Am Rechner muss der Name des Filmskripts im Filmbefehl stehen. Jeder Filmlauf verbraucht das Probebild.
  Push: filmt, wenn ein Schritt mit `--write-movie` bei dieser Commit-Nachricht läuft (`if: contains(…head_commit.message…)`).
  578 (Chef 04.11., 21:03: „Also ich brauche den Film“): ein Archivkopf „<Nr>, gleich Film“ gibt den Film ohne Probebild
  frei, solange danach kein neues Probebild zu <Nr> eingetragen ist; die Zahl der Läufe begrenzt weiter 389.

513.1 (Chef 03.11., 15:56: „513 B“; Leitlinie: was der Chef an einer Figur abnimmt, gilt in jedem Zweig, der Figuren zeigt):
jeder Probelauf und jedes Probebild hält an, wenn der Stand (Rechner: HEAD der Arbeitskopie; Push: HEAD; Start von Hand: der
Zweig) einen abgenommenen Figurencommit aus `tools/figurenstand.tsv` auf `main` nicht enthält. Eine Zeile je Abnahme
(Commit, Vorgang, Chefwort); trägt ein, wer das „passt“ des Chefs zu einer Figur ins Archiv schreibt.
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

GRENZE = 1  # 621 A (Chef 07.11., 16:4x), vorher 2 (389)
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
COMMIT_F = re.compile(r"\bgit\s+(?:-C\s+\S+\s+)?commit\b[^\n]*?\s-[a-zA-Z]*F\s*-\s[^\n]*?<<-?\s*['\"]?(\w+)['\"]?[^\n]*\n(.*?)\n\s*\1\b", re.S)  # 627: `commit -F - <<EOF`
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
    if not CI_ZWEIG.fullmatch(zweig) or SAMMELBUILD.fullmatch(zweig):  # 646, 627: Sammelbuild für den Gerätetest ist keine Probe
        return None
    oben = git("rev-parse", "--verify", "-q", f"origin/{zweig}", cwd=wo).stdout.strip()
    if not oben:  # 627 (Jerry 07.11., 21:2x): neuer Zweig, Pfade gegen den Abzweig von origin/main statt „alle Abläufe“
        oben = git("merge-base", "origin/main", "HEAD", cwd=wo).stdout.strip()
    # Commit im selben Befehl vor dem Push (PreToolUse sieht ihn noch nicht): Nachricht aus -m, Pfade aus dem Arbeitsbaum
    neu_f = COMMIT_F.search(befehl[:m.start()])  # 627 (Tuffy 07.11., 21:15): Nachricht aus dem Heredoc, nicht die des alten HEAD
    neu = neu_f or COMMIT.search(befehl[:m.start()])
    nachricht = neu_f.group(2) if neu_f else (re.sub(r"^\s*[\"']?(?:\$\(cat\s*<<-?\s*['\"]?\w+['\"]?\s*)?", "", neu.group(1)) if neu else
                                         git("log", "-1", "--format=%B", "HEAD", cwd=wo).stdout)
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
    STAND_REF.update(wo=wo, rev="HEAD")
    los = loest_aus(wo, zweig, pfade, nachricht)
    if not los:  # Tom 02.11., 16:3x: Push ohne Lauf zählte als Probelauf
        return None
    nr = re.match(r"\s*(?:\w+:\s*)?(" + NR + r")\b", nachricht)
    return (nr.group(1) if nr else zweig), los == FILMT


FILMT = 2
STAND_REF = {}  # 513.1: Arbeitskopie und Stand des zuletzt erkannten Laufs (wo, rev)


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
        los = max(los, FILMT if filmt_bei(jobs, nachricht) else 1)
    return los


def filmt_bei(jobs, nachricht):
    """511: ruft ein Schritt, der bei dieser Commit-Nachricht läuft, `--write-movie`? Bedingungen aus
    contains(github.event.head_commit.message, '…') mit &&, ||, ! werden ausgewertet; andere gelten als erfüllt
    (lieber sperren als durchlassen)."""
    def laeuft(bed):
        bed = re.sub(r"\$\{\{|\}\}", "", str(bed or "")).strip()
        if not bed:
            return True
        ausdruck = re.sub(r"contains\(\s*github\.event\.head_commit\.message\s*,\s*'([^']+)'\s*\)",
                          lambda m: " True " if m.group(1) in nachricht else " False ", bed)
        if re.sub(r"True|False|&&|\|\||!|[()\s]", "", ausdruck):
            return True
        ausdruck = ausdruck.replace("&&", " and ").replace("||", " or ").replace("!", " not ")
        try:
            return bool(eval(ausdruck, {"__builtins__": {}}, {}))
        except Exception:
            return True

    for job in (jobs or {}).values():
        if not isinstance(job, dict) or not laeuft(job.get("if")):
            continue
        for schritt in job.get("steps") or []:
            if isinstance(schritt, dict) and "--write-movie" in str(schritt.get("run", "")) and laeuft(schritt.get("if")):
                return True
    return False


RERUN = ("407 (Chef 02.11., 07:18: „die ganze Nacht über jetzt 1000 Filmchen gedreht“): einen Lauf neu starten zählt der Haken "
         "nicht nach Vorgang; neu starten nur mit run_workflow (`mcp__github__actions_run_trigger` method run_workflow oder "
         "`gh workflow run`), dann zählt er je Vorgang.")


def vorgang_aus_ref(ref, ablauf):
    """407: Vorgang eines von Hand gestarteten Ablaufs: erste Nummer der Commit-Nachricht oben auf ref, sonst Nummer in
    Klammern im Namen des Ablaufs („Tom Probe Tragart (417)“), sonst der Zweig selbst."""
    ref = (ref or "").removeprefix("refs/heads/")
    nachricht, name = "", ""
    if ref and git("fetch", "-q", "origin", ref).returncode == 0:
        STAND_REF.update(wo=REPO, rev=git("rev-parse", "FETCH_HEAD").stdout.strip())
        nachricht = git("log", "-1", "--format=%B", "FETCH_HEAD").stdout
        if ablauf and not ablauf.isdigit():
            datei = ablauf if "/" in ablauf else ".github/workflows/" + ablauf
            name = (re.search(r"^name:\s*(.+)$", git("show", f"FETCH_HEAD:{datei}").stdout, re.M) or [None, ""])[1]
    nr = re.match(r"\s*(?:\w+:\s*)?(" + NR + r")\b", nachricht) or re.search(r"\((" + NR + r")\)", name)
    return nr.group(1) if nr else (ref or ablauf or "?")


def ohne_film(eingaben):
    """646 (Chef 08.11., 12:34: „646 grundsätzlich ja … Es sollte logisch sein“; ersetzt 390a für den Bauserver): jeder
    Lauf auf dem Bauserver zählt als die eine Probe, auch ein Messlauf ohne Bild (bild=nein); ohne Film (bild=nein oder
    film=nein) greift nur die Filmsperre 511 nicht."""
    return any(str(eingaben.get(k, "")).strip().lower() == "nein" for k in ("bild", "film"))


SAMMELBUILD = re.compile(r"(?:refs/heads/)?claude/build-\d+")  # 646: Sammelbuild für den Gerätetest des Chefs ist keine Probe


def handlauf_mcp(d):
    """407: `actions_run_trigger` über den GitHub-Server: (Vorgang, Art), RERUN zum Anhalten, oder None."""
    e = d.get("tool_input") or {}
    methode = e.get("method", "")
    if methode in ("rerun_workflow_run", "rerun_failed_jobs"):
        return RERUN
    if methode != "run_workflow" or SAMMELBUILD.fullmatch(str(e.get("ref") or "")):
        return None
    return vorgang_aus_ref(e.get("ref"), str(e.get("workflow_id") or "")), "hand", not ohne_film(e.get("inputs") or {})


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
        ref = ref.group(1).strip("\"'") if ref else ""
        if SAMMELBUILD.fullmatch(ref):
            return None
        return vorgang_aus_ref(ref, ablauf), "hand", not ohne_film(eing)
    m = API_LAUF.search(befehl)
    if m:
        # JSON (curl -d '{"ref":…}') oder Felder (gh api -f ref=…, -F, --field, --raw-field; D64.1)
        ref = re.search(r"\\?[\"']ref\\?[\"']\s*:\s*\\?[\"']([^\"'\\]+)", befehl) or \
            re.search(r"(?:-f|-F|--field|--raw-field)[=\s]+[\"']?ref=([^\s\"']+)", befehl)
        eing = dict(re.findall(r"\\?[\"'](bild|film)\\?[\"']\s*:\s*\\?[\"'](\w+)", befehl))
        eing.update(re.findall(r"(?:-f|-F|--field|--raw-field)[=\s]+[\"']?inputs\[(bild|film)\]=(\w+)", befehl))
        ref = ref.group(1) if ref else ""
        if SAMMELBUILD.fullmatch(ref):
            return None
        return vorgang_aus_ref(ref, m.group(1)), "hand", not ohne_film(eing)
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


TEAMZWEIG = re.compile(r"claude/(?:tom|jerry|spike|tuffy)-[\w./-]+")
ALT_ZEILE = re.compile(r"^Alt:\s*\S", re.M)


def alt_fehlt(befehl, cwd):
    """647 (Chef 08.11., 12:44: „Alter Code, neuer Code. Nicht 1:1 kopieren, aber die guten Sachen, die schon da sind,
    übernehmen und besser machen“): ein Push auf einen Teamzweig mit Spielcode unter godot/ (ohne tests/) braucht in einer
    seiner Commit-Nachrichten die Zeile „Alt: <Datei:Zeilen der alten Fassung, was übernommen, was besser>“ oder
    „Alt: keine (<Grund>)“. Grund zum Anhalten oder None."""
    m = PUSH.search(befehl)
    if not m:
        return None
    cds = CD.findall(befehl[:m.start()])
    wo = m.group(1) or (os.path.join(cwd, os.path.expanduser(cds[-1].strip("\"'"))) if cds else cwd)
    ziel = CI_ZWEIG.search(m.group(2))
    teile = [t for t in m.group(2).split() if not t.startswith("-")]
    if not ziel and len(teile) >= 2:  # `git push origin main`: ausdrücklich ein anderer Zweig
        return None
    zweig = ziel.group(0).split(":")[-1] if ziel else git("rev-parse", "--abbrev-ref", "HEAD", cwd=wo).stdout.strip()
    if not TEAMZWEIG.fullmatch(zweig):
        return None
    oben = git("rev-parse", "--verify", "-q", f"origin/{zweig}", cwd=wo).stdout.strip() or \
        git("merge-base", "origin/main", "HEAD", cwd=wo).stdout.strip()
    if not oben:
        return None
    pfade = git("diff", "--name-only", f"{oben}..HEAD", cwd=wo).stdout.split()
    texte = git("log", "--no-merges", "--format=%B%x00", f"{oben}..HEAD", cwd=wo).stdout
    neu_f = COMMIT_F.search(befehl[:m.start()])
    neu = neu_f or COMMIT.search(befehl[:m.start()])
    if neu:
        pfade += git("diff", "--name-only", "HEAD", cwd=wo).stdout.split()
        texte += "\n" + (neu_f.group(2) if neu_f else neu.group(1))
    spiel = [p for p in pfade if p.startswith("godot/") and not p.startswith("godot/tests/")
             and not p.endswith((".uid", ".import"))]
    if not spiel or ALT_ZEILE.search(texte):
        return None
    return ("647 (Chef 08.11., 12:44: „Alter Code, neuer Code. Nicht 1:1 kopieren, aber die guten Sachen … übernehmen und besser "
            f"machen“): Push auf {zweig} ändert Spielcode ({', '.join(spiel[:3])}{' …' if len(spiel) > 3 else ''}), aber keine "
            "Commit-Nachricht nennt die alte Fassung. Vor dem Bauen die Fundstelle in app/ oder core/ lesen, dann eine Zeile "
            "„Alt: <Datei:Zeilen>, übernommen: …, besser: …“ in die Nachricht (git commit --amend, solange nicht gepusht), "
            "oder „Alt: keine (<Grund>)“, wenn es nichts Altes gibt.")


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
    return sorted({(z[0], z[5], z[6], z[7]) for z in zeilen(text) + zeilen(lokal)
                   if len(z) >= 8 and z[1] == nr and z[3] == "probebild"})


def helfer_ok(nr):
    """511a: Zeit des jüngsten Helferbefunds „ok“ zum Probebild von nr, sonst ""."""
    _, text = zweig_lesen(BILDER)
    lokal = open(LOKAL_BILDER, encoding="utf-8").read() if os.path.exists(LOKAL_BILDER) else ""
    return max((z[0] for z in zeilen(text) + zeilen(lokal) if len(z) >= 8 and z[1] == nr and z[3] == "helfer"), default="")


def letzter_film(nr):
    _, laeufe = zweig_lesen(DATEI)
    lokal = open(LOKAL, encoding="utf-8").read() if os.path.exists(LOKAL) else ""
    return max((z[0] for z in zeilen(laeufe) + zeilen(lokal) if z[1] == nr and z[3].endswith("-film")), default="")


def gleich_film(nr):
    """578 (Chef 04.11., 21:03: „Also ich brauche den Film“): Zeit des jüngsten Archivkopfs „<nr>, gleich Film“, sonst ""."""
    return probebild_passt(nr, r",?\s*gleich Film", nur_kopf=True)


def probebild_passt(nr, wort=r"[^;:]{0,30}?Probebild passt", nur_kopf=False):
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
        if re.search(nrx + wort, m.group(1)):
            beste = max(beste, zeit(m.group(2), m.group(3), m.group(4), m.group(5), m.group(6)))
        if nur_kopf:
            continue
        for g in re.finditer(nrx + r"[^;→]{0,30}?Probebild passt\W{0,4}\(Chef\s+(?:(\d\d)\.(\d\d)\.,?\s*)?(\d\d):(\d)([\dx])",
                             eintrag):
            beste = max(beste, zeit(g.group(1) or m.group(2), g.group(2) or m.group(3), g.group(3), g.group(4), g.group(5)))
    return beste


def film_sperre(nr, art, befehl):
    """511: Grund zum Anhalten oder None. Gilt ein Probebild, das nach dem letzten Filmlauf zu nr eingetragen wurde und das
    der Chef danach mit „<nr> Probebild passt“ freigegeben hat."""
    seit = letzter_film(nr)
    bilder = [b for b in probebilder(nr) if b[0] > seit]
    gleich = gleich_film(nr)
    if gleich and not [b for b in bilder if b[0][:16] > gleich[:16]]:
        return None  # 578: „<nr>, gleich Film“ des Chefs gibt den Film ohne Probebild frei (Läufe zählt 389)
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
    if helfer_ok(nr)[:16] < passt[:16]:
        return (f"511a (Chef 13:59: „1“): Chef hat das Probebild zu {nr} freigegeben ({passt}); jetzt prüft ein Helfer es "
                "genau gegen die Liste, dann `python3 tools/probelauf.py --helfer " + nr + " \"ok: <was zu sehen ist>\"`. "
                "Fehlt etwas: Ursache nachstellen, neues Probebild.")
    skript = os.path.basename(bilder[-1][2].rstrip("/"))
    if art == "rechner" and skript not in ("", "-") and skript not in befehl:
        return (f"511: das Probebild zu {nr} ({bilder[-1][1]}) kommt aus „{skript}“, der Filmlauf ruft ein anderes Skript. "
                "Probebild aus demselben Filmskript eintragen.")
    return None


def helfer_eintragen(args):
    """511a: `--helfer <Nr> "ok: <was zu sehen ist>"` nach dem „Probebild passt“ des Chefs."""
    if len(args) != 2:
        sys.exit("Aufruf: python3 tools/probelauf.py --helfer <Nr> \"ok: <was zu sehen ist>\"")
    nr, befund = (a.replace("\t", " ").replace("\n", " ").strip() for a in args)
    seit = letzter_film(nr)
    bilder = [b for b in probebilder(nr) if b[0] > seit]
    passt = probebild_passt(nr)
    if not bilder or not passt or passt[:16] < bilder[-1][0][:16]:
        sys.exit(f"511a: erst Probebild zu {nr} eintragen und vom Chef „{nr} Probebild passt“ abwarten.")
    if not re.match(r"ok:\s*\S.{10,}", befund, re.I) or re.search(r"\bfehlt|nicht zu sehen|unsichtbar|\bleer\b", befund, re.I):
        sys.exit("511a: Befund muss mit „ok:“ beginnen und nennen, was zu sehen ist; fehlt etwas: kein Eintrag, Ursache "
                 "nachstellen, neues Probebild.")
    wer = os.environ.get("CLAUDE_SESSION_ID", "hand")[:20]
    zaehlen(nr, wer, "helfer", BILDER, LOKAL_BILDER, ("-", "-", befund[:300]))
    print(f"511a: Helferbefund zu {nr} eingetragen; ein Filmlauf zu {nr} darf starten.")


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


def alte_einstellungen(befehl, cwd):
    """511 (Spike 03.11., 13:4x: Lauf 244 über `actions_run_trigger` nicht gezählt): die Sitzung liest Haken aus
    `.claude/settings.json` ihrer Arbeitskopie; ein Zweig von vor ff8821827 (02.11., 11:19) kennt den Haken für Starts über
    den GitHub-Server nicht, Zählung und Filmsperre greifen dort nicht. Grund zum Anhalten oder None; git-Befehle gehen
    immer durch (zum Mischen)."""
    if re.match(r"\s*(?:cd\s+\S+\s*&&\s*)?git\b", befehl):
        return None
    wurzel = os.environ.get("CLAUDE_PROJECT_DIR") or git("rev-parse", "--show-toplevel", cwd=cwd).stdout.strip()
    datei = os.path.join(wurzel, ".claude", "settings.json") if wurzel else ""
    if not datei or not os.path.isfile(datei) or "probelauf" not in open(datei, encoding="utf-8").read():
        return None
    if "actions_run_trigger" in open(datei, encoding="utf-8").read():
        return None
    return ("511: diese Arbeitskopie hat eine alte `.claude/settings.json` ohne den Haken für Abläufe über den GitHub-Server "
            "(Starts von Hand würden nicht gezählt und nicht gesperrt). Erst `git fetch origin main && git merge origin/main`, "
            "dann weiter; greift der Haken danach nicht, Sitzung über Ford neu starten.")


HEREDOC = re.compile(r"^(?P<kopf>[^\n]*?)<<-?\s*(?P<q>['\"]?)(?P<ende>\w+)(?P=q)[^\n]*\n", re.M)


def ohne_heredoc(befehl):
    """407 (Tom 02.11., 20:4x; Spike 03.11., 08:10; Perikles 03.11., 13:5x): Text in einem Heredoc für Python, cat, tee
    u. Ä. ist kein Befehl und zählt nicht; ein Heredoc für eine Shell oder Godot bleibt stehen (dort läuft er)."""
    aus, pos = [], 0
    for m in HEREDOC.finditer(befehl):
        if m.start() < pos:
            continue
        schluss = re.compile(r"^\s*" + re.escape(m.group("ende")) + r"\s*$", re.M).search(befehl, m.end())
        if not schluss:
            continue
        if re.search(r"(?<![\w.-])(?:bash|sh|zsh|xvfb-run|godot\S*|ssh|env)(?![\w.])[^|;&]*$", m.group("kopf")):
            continue
        aus.append(befehl[pos:m.end()])
        pos = schluss.start()
    return "".join(aus) + befehl[pos:]


def arbeitskopie(befehl, cwd):
    cds = CD.findall(befehl)
    return os.path.join(cwd, os.path.expanduser(cds[0].strip("\"'"))) if cds else cwd


def figur_sperre(wo, rev):
    """513.1: Grund zum Anhalten oder None. Jeder abgenommene Figurencommit aus tools/figurenstand.tsv (main) muss in rev
    enthalten sein; Arbeitskopie ohne godot/: keine Figuren, nichts zu prüfen."""
    if not wo or not rev:
        return None
    wurzel = git("rev-parse", "--show-toplevel", cwd=wo).stdout.strip()
    if not wurzel or not os.path.isdir(os.path.join(wurzel, "godot")):
        return None
    _, liste = zweig_lesen("tools/figurenstand.tsv", "main")
    if not liste:
        p = os.path.join(REPO, "tools", "figurenstand.tsv")
        liste = open(p, encoding="utf-8").read() if os.path.exists(p) else ""
    fehlt = []
    for z in liste.splitlines():
        t = z.split("\t")
        if z.startswith("#") or len(t) < 2 or not re.fullmatch(r"[0-9a-f]{7,40}", t[0].strip()):
            continue
        c = t[0].strip()
        if git("cat-file", "-e", c + "^{commit}", cwd=wurzel).returncode:
            git("fetch", "-q", "origin", c, cwd=wurzel, timeout=30)
        r = git("merge-base", "--is-ancestor", c, rev, cwd=wurzel)
        if r.returncode:
            fehlt.append(f"{c} ({t[1].strip()})")
    if not fehlt:
        return None
    flach = git("rev-parse", "--is-shallow-repository", cwd=wurzel).stdout.strip() == "true"
    return ("513.1 (Chef 03.11., 15:56: „513 B“): dieser Stand enthält den abgenommenen Figurenstand nicht: "
            + ", ".join(fehlt) + ". Erst den Figurenstand hineinmischen (Zweig mit allen Abnahmen, Toms 513; `git fetch origin "
            "<Zweig> && git merge FETCH_HEAD`), dann laufen lassen." + (" Die Arbeitskopie ist flach geklont: vorher "
            "`git fetch --unshallow`, sonst sieht der Haken die Vorfahren nicht." if flach else ""))


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
                  f"{frei[-1][0]} ({frei[-1][2]}), " + ("wartet auf den Chef" if not passt or passt[:16] < frei[-1][0][:16]
                                                         else "Chef " + passt + (", wartet auf den Helfer (511a)"
                                                         if helfer_ok(nr)[:16] < passt[:16] else ", Helfer ok, Filmlauf frei"))))
        return
    if sys.argv[1:2] == ["--helfer"]:
        return helfer_eintragen(sys.argv[2:])
    if sys.argv[1:2] == ["--probebild"]:
        return probebild_eintragen(sys.argv[2:])
    try:
        d = json.load(sys.stdin)
    except ValueError:
        return
    roh = (d.get("tool_input") or {}).get("command") or ""  # Push und Commit-Nachricht (Heredoc) aus dem ganzen Befehl
    befehl = ohne_heredoc(roh)
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
            nr, art, film = hand
            pruefen_und_zaehlen(nr, art, wer, film=film)
        return
    if re.search(r"(push_files|create_or_update_file)$", d.get("tool_name") or ""):  # D75.1: Push über den GitHub-Server zählt wie git push
        try:
            e = d.get("tool_input") or {}
            zweig, nachricht = str(e.get("branch") or ""), str(e.get("message") or "")
            pfade = [f.get("path", "") for f in (e.get("files") or []) if isinstance(f, dict)] + ([e["path"]] if e.get("path") else [])
            if CI_ZWEIG.fullmatch(zweig) and not SAMMELBUILD.fullmatch(zweig) and "[skip ci]" not in nachricht and "[ci skip]" not in nachricht \
                    and any(x.startswith(CI_PFADE) for x in pfade) and (los := loest_aus(cwd, zweig, pfade, nachricht)):
                m = re.match(r"\s*(?:\w+:\s*)?(" + NR + r")\b", nachricht)
                return pruefen_und_zaehlen(m.group(1) if m else zweig, "ci", wer, los == FILMT)
        except (OSError, subprocess.SubprocessError, ValueError):
            pass
        return hinweis_geben()
    try:
        alt = alte_einstellungen(befehl, cwd)
    except (OSError, subprocess.SubprocessError, ValueError):
        alt = None
    if alt:
        anhalten(alt)
    try:
        grund = alt_fehlt(roh, cwd)  # 647: Fundstelle der alten Fassung vor dem Push
    except (OSError, subprocess.SubprocessError, ValueError):
        grund = None
    if grund:
        anhalten(grund)
    try:
        grund = parse_pruefen(roh, cwd)  # 464: vor dem Zählen, ein angehaltener Push ist kein Lauf
    except (OSError, subprocess.SubprocessError, ValueError):
        grund = None
    if grund:
        anhalten(grund)
    film = False
    try:
        if bildlauf(befehl, cwd) and not PROBE.search(befehl) and (pb := PROBEBILD.search(befehl)):
            if (fs := figur_sperre(arbeitskopie(befehl, cwd), "HEAD")):
                anhalten(fs)
            if filmlauf_rechner(befehl, cwd):  # 511: Probebild ist ein Einzelbild, kein Film
                anhalten(f"511: `PROBEBILD={pb.group(1)}` gilt nur für ein Einzelbild; dieser Befehl filmt. Für den Film "
                         f"`PROBE={pb.group(1)}` mit eingetragenem Probebild.")
            return hinweis_geben(f"511: Probebild zu {pb.group(1)}, zählt nicht als Probelauf. Eintragen mit "
                                 "`python3 tools/probelauf.py --probebild …`, dann dem Chef vorlegen.")
        if bildlauf(befehl, cwd):
            m = PROBE.search(befehl)
            if not m:
                anhalten("621 A (Chef 07.11., höchstens eine Probe je Aussehen-Thema): Bildlauf erkannt. "
                         "Vorgang davorsetzen: `PROBE=<Nr> <Befehl>`; der Haken zählt je Vorgang.")
            nr, art, film = m.group(1), "rechner", filmlauf_rechner(befehl, cwd)
            STAND_REF.update(wo=arbeitskopie(befehl, cwd), rev="HEAD")
        elif (hand := handlauf_bash(befehl)):
            if hand == RERUN:
                anhalten(RERUN)
            nr, art, film = hand
        else:
            push = push_lauf(roh, cwd)
            if not push:
                return hinweis_geben()
            (nr, film), art = push, "ci"
    except (OSError, subprocess.SubprocessError, ValueError):
        return hinweis_geben()
    pruefen_und_zaehlen(nr, art, wer, film, befehl)


def pruefen_und_zaehlen(nr, art, wer, film=False, befehl=""):
    try:
        n, vorlage = stand(nr)
        sperre = figur_sperre(STAND_REF.get("wo"), STAND_REF.get("rev")) or (film_sperre(nr, art, befehl) if film else None)
    except (OSError, subprocess.SubprocessError, ValueError):
        return hinweis_geben()
    if n >= GRENZE:
        anhalten(f"621 A (Chef 07.11., 16:4x: je Aussehen-Thema höchstens eine Probe vor dem Chef): für {nr} "
                 f"schon {n} Probelauf seit {'deinem Urteil ' + vorlage if vorlage else 'Beginn der Zählung'}. Kein weiterer Lauf: "
                 f"jetzt vorlegen, was da ist, auch ein Messlauf (646; Datei in docs/chefsache/ansehen/, Sitz und Aussehen `meldung.sh --bild`, Bewegung `--film`, mit „{nr}:“ und offenen Punkten als Vermerk), "
                 "Befund der Fehlerprüfung danach als Text (396). Passt die Probe nicht: Rückfrage mit Wegen und Kosten in docs/chefsache/entscheiden/, keine neue Runde (621 A). Erst das Urteil des Chefs (Eintrag im Vorgangsarchiv) gibt einen neuen "
                 "Lauf frei (407), oder Sokrates mit einem Archiveintrag „<Nr>, Läufe frei“ (480.1; Bitte an ihn per Vorrat, nie "
                 "Chefsache); bis dahin an einem anderen Vorgang weiter.")
    if sperre:
        anhalten(sperre)
    zaehlen(nr, wer, art + ("-film" if film else ""))
    hinweis_geben(f"621 A: Probelauf {n + 1} von {GRENZE} für {nr}" + (
        "; danach geht das Ergebnis an den Chef, auch mit offenen Punkten (Vermerk: Punkt, warum offen; 646): Sitz und "
        "Aussehen als Bild, Bewegung als Film. Nachstellen am Rechner nur zur Ursache eines Fehlers, den der Chef gemeldet hat."
        if n + 1 == GRENZE else "."))


def hinweis_geben(text=""):
    """Zusatztext an die Sitzung (PreToolUse additionalContext): Zählstand 389 und, falls nötig, Ungeprüftes 464.1."""
    text = " ".join(t for t in (text, ungeprueft_hinweis()) if t)
    if text:
        print(json.dumps({"hookSpecificOutput": {"hookEventName": "PreToolUse", "additionalContext": text}}, ensure_ascii=False))


if __name__ == "__main__":
    main()
