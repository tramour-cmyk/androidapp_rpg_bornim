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
  (run_workflow) oder `gh workflow run`/API `…/dispatches`; Vorgang = erste Nummer der Commit-Nachricht oben auf dem Zweig (ohne Nummer, etwa ein Merge: jüngster eigener Commit mit Nummer, 911;
  gehört dessen Vorgang einer anderen Rolle als der Zweig, Spike wie Tom, Tuffy wie Jerry: Vorgang aus dem Zweignamen, 912, 920),
  sonst Nummer in Klammern im Namen des Ablaufs; auch ein Messlauf mit bild=nein (646, ersetzt 390a für den Bauserver),
  nur ein Sammelbuild `claude/build-<n>` für den Gerätetest nicht; Neustart eines Laufs (rerun) hält der Haken an;
- ein Push auf einen Zweig `claude/…`, der einen Ablauf auslöst (letzter Commit ohne „[skip ci]“, Änderung
  unter godot/, tools/blender348/, core/src/main/ oder am Workflow); der Vorgang ist die erste Nummer der Commit-Nachricht.
Vorlage heißt: eine Meldung mit Bild, Film oder Datei zu dem Vorgang (Zeile im Zweig „meldungen“, schreibt `meldung.sh`, 383).
Jeder Lauf wird gezählt, auch einer, der abbricht. Die Zählung steht im Zweig „probelaeufe“ in `probelaeufe.tsv` (überlebt den
Neustart) und hilfsweise in ~/.bornim-probelaeufe.tsv. Bei eigenem Fehler (kein Git, kein Netz) lässt der Haken durch.

Auch von Hand: `python3 tools/probelauf.py --stand <Nr>` zeigt die Zählung.

783 W1 (Chef 09.11., 20:12, ersetzt 511, 511a, 578): Bewegung geht gleich als Film, ohne Probebild und ohne Freigabe.
Vorher macht der Ersteller für sich ein Einzelbild am Rechner (`PROBEBILD=<Nr> <Befehl ohne Film>`, zählt nicht als Probelauf)
und sieht selbst nach, ob Inhalt da ist; kein Helfer. Die Zahl der Läufe begrenzt weiter 621 A (früher 389).
- Filmlauf: Bildlauf am Rechner mit `--write-movie`, `FILM=`/`WALKFILM=`/`IDLEFILM=`/`FOEFILM=`/`FILMBATCH=`, `tools/t film`
  `.mp4`, `ffmpeg` oder einem Laufskript, dessen Name „film“ enthält oder das so filmt; jeder von Hand gestartete Ablauf mit
  Bild; jeder Push, der einen Ablauf mit `--write-movie` auslöst. Gezählt als „-film“ wie jeder Probelauf.

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
ZUWEISUNG = re.compile(r"(?:^|[;&|(\s])(?:export\s+)?([A-Za-z_]\w*)=(\"[^\"]*\"|'[^']*'|[^\s;&|]*)")
VARIABLE = re.compile(r"\$(?:\{(\w+)\}|(\w+))")


class Unaufloesbar(Exception):
    """725 (D72): Ziel eines `cd` mit Variable oder Befehlsersetzung, die der Haken nicht auflösen kann."""


def cd_pfad(roh, cwd, vorher=""):
    """725 (D72, Diogenes Lauf 70): `cd $VAR`, `cd "$HOME/…"`, `cd ~/…` auflösen; Variablen aus Zuweisungen in `vorher`
    (Befehlstext vor diesem cd: `W=…; cd $W`, `export W=…`), sonst aus der Umgebung. Bleibt `$` oder eine Befehlsersetzung
    übrig: Unaufloesbar; der Haken hält an, statt in einem erfundenen Ordner nichts zu finden und durchzulassen."""
    ziel = roh.strip("\"'")
    lokal = {m.group(1): m.group(2).strip("\"'") for m in ZUWEISUNG.finditer(vorher)}
    for _ in range(3):  # W=$HOME/x; cd $W
        neu = VARIABLE.sub(lambda m: lokal.get(m.group(1) or m.group(2), os.environ.get(m.group(1) or m.group(2), m.group(0))), ziel)
        if neu == ziel:
            break
        ziel = neu
    ziel = os.path.expanduser(ziel)
    if "$" in ziel or "`" in ziel:
        raise Unaufloesbar(f"725 (D72): Ziel `cd {roh}` kann der Haken nicht auflösen; Figurenstand (513.1), Parse (464) und "
                           "Zählung (621 A) liefen sonst im falschen Ordner und ließen durch. Ziel ausschreiben "
                           "(`cd /home/user/…`) oder `git -C <Pfad>`.")
    return os.path.join(cwd, ziel)


# 943: eigener Name, HEREDOC weiter unten (Zeile ~810) überschrieb diesen mit anderen Gruppen; Körper galten nie als Text
HEREDOC_TEXT = re.compile(r"<<-?\s*['\"]?(\w+)['\"]?[^\n]*\n(.*?)(?:\n[ \t]*\1\b|\Z)", re.S)


def text_bereiche(befehl):
    """929 (D163.1): Bereiche (Anfang, Ende), die nur Text sind: Heredoc-Körper, dann Inhalt von '…' und "…" außerhalb davon.
    Ein `cd` darin (Commit-Nachricht, Vorgangstitel) ist kein Befehl. Das Ziel eines echten `cd "$HOME/x"` bleibt lesbar,
    weil nur der Anfang des Treffers zählt. Grenze: `bash -c "cd …"` gilt ebenfalls als Text."""
    aus = [(m.start(2), m.end(2)) for m in HEREDOC_TEXT.finditer(befehl)]
    heredocs = list(aus)
    i, n = 0, len(befehl)
    while i < n:
        imtext = next((e for s, e in aus if s <= i < e), None)
        if imtext is not None:
            i = imtext
            continue
        c = befehl[i]
        if c == "\\":
            i += 2
            continue
        if c in "'\"":
            j = i + 1
            while j < n:
                hd = next((e for s, e in heredocs if s <= j < e), None)  # 943 (D171.3): ein " im Heredoc-Körper schließt nicht
                if hd is not None:  # 961 (D175.1): Sprung vor dem Vergleich, auch wenn der Körper mit " beginnt
                    j = hd
                    continue
                if befehl[j] == c:
                    break
                j += 2 if c == '"' and befehl[j] == "\\" else 1
            aus.append((i + 1, j))
            i = j + 1
            continue
        i += 1
    return aus


def cd_befehle(befehl):
    """Treffer von CD, die als Befehl stehen, nicht in Text (929)."""
    bereiche = text_bereiche(befehl)
    return [m for m in CD.finditer(befehl) if not any(s <= m.start() < e for s, e in bereiche)]


def cd_ziel(befehl, cwd, erstes=False):
    """Ordner nach dem ersten (erstes=True) oder letzten `cd` in befehl, sonst cwd; Unaufloesbar wie cd_pfad."""
    ms = cd_befehle(befehl)
    if not ms:
        return cwd
    m = ms[0] if erstes else ms[-1]
    return cd_pfad(m.group(1), cwd, befehl[:m.start()])


def wo_von(befehl, m, cwd):
    """Arbeitskopie eines git-Befehls (Treffer m mit `-C` in Gruppe 1): letztes cd davor, darin `-C`."""
    vorn = befehl[:m.start()]
    if not m.group(1):
        return cd_ziel(vorn, cwd)
    try:
        basis = cd_ziel(vorn, cwd)
    except Unaufloesbar:  # `-C` mit festem Pfad braucht das cd nicht
        basis = cwd
    return cd_pfad(m.group(1), basis, vorn)


def cd_ordner(befehl, cwd):
    """Alle auflösbaren cd-Ziele (Suche nach Dateien; Unauflösbares fällt weg)."""
    aus = []
    for m in cd_befehle(befehl):
        try:
            aus.append(cd_pfad(m.group(1), cwd, befehl[:m.start()]))
        except Unaufloesbar:
            pass
    return aus
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
    for basis in [cwd] + cd_ordner(befehl, cwd):
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
    wo = wo_von(befehl, m, cwd)  # `cd ../bornim-main && git push`: Zweig des cd-Ziels (Jerry 12:05, 13:08); 725
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
    return (nr.group(1) if nr else (nr_aus_verlauf(wo, "HEAD", zweig) or zweig)), los == FILMT  # 911; 924: Rolle aus dem Push-Ziel


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
        # 858 (D129.1): in der Wurzel suchen, nicht im Ordner des Aufrufs; im Paket (push_files) genügt der Pfad
        if datei == "vorschau.yml" and not os.path.exists(os.path.join(wurzel, "tools", "preview", "vorschau.env")) \
                and "tools/preview/vorschau.env" not in (pfade or []):
            continue  # 848 (Tom 10.11., 506a): Kotlin-Vorschau ohne vorschau.env bricht ohne Bild ab, keine Probe
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
    nachricht, name, sha = "", "", ""
    if ref and git("fetch", "-q", "origin", ref).returncode == 0:
        sha = git("rev-parse", "FETCH_HEAD").stdout.strip()
        STAND_REF.update(wo=REPO, rev=sha)
        nachricht = git("log", "-1", "--format=%B", "FETCH_HEAD").stdout
        if ablauf and not ablauf.isdigit():
            datei = ablauf if "/" in ablauf else ".github/workflows/" + ablauf
            name = (re.search(r"^name:\s*(.+)$", git("show", f"FETCH_HEAD:{datei}").stdout, re.M) or [None, ""])[1]
    nr = re.match(r"\s*(?:\w+:\s*)?(" + NR + r")\b", nachricht)
    eigen = nr_aus_verlauf(REPO, sha, ref) if sha and not nr else None  # 911, 913
    nr = nr or re.search(r"\((" + NR + r")\)", name)
    return nr.group(1) if nr and not eigen else (eigen or ref or ablauf or "?")


BESITZER = ("Homer", "Tom", "Jerry", "Perikles", "Diogenes", "Sokrates", "Ford")
ZUSATZ_TEAM = {"Spike": "Tom", "Tuffy": "Jerry"}  # Zusatzentwickler (433)


def vorgaenge():
    """912: {Nummer: Besitzer} aus Vorgangsliste und Archiv (Stand main, sonst die Arbeitskopie)."""
    texte = []
    for name in ("docs/LISTE-VORGAENGE.md", "docs/LISTE-VORGAENGE-ARCHIV.md"):
        _, t = zweig_lesen(name, "main")
        if not t and os.path.exists(os.path.join(REPO, name)):
            t = open(os.path.join(REPO, name), encoding="utf-8").read()
        texte.append(t)
    aus = {}
    for z in "\n".join(texte).splitlines():
        m = re.match(r"\| (" + NR + r") \|", z)
        if m:
            zellen = [c.strip() for c in z.split("|")]
            aus.setdefault(m.group(1), next((c for c in zellen if c in BESITZER), ""))
    return aus


def nr_aus_zweigname(zweig, bekannt):
    """912: Vorgang aus dem Zweignamen („claude/tom-870-4-held“ → 870.4), nur wenn es ihn gibt; längste Lesart zuerst."""
    teile = (zweig or "").removeprefix("refs/heads/").removeprefix("claude/").split("-")
    for i, t in enumerate(teile):
        if not re.fullmatch(r"\d+[a-z]?", t):
            continue
        folge = [t]
        for u in teile[i + 1:]:
            if not re.fullmatch(r"\d+[a-z]?", u):
                break
            folge.append(u)
        for j in range(len(folge), 0, -1):
            if ".".join(folge[:j]) in bekannt:
                return ".".join(folge[:j])
        return None
    return None


def nr_aus_verlauf(wo, rev, zweig=None):
    """911 (Tom 11.11., 09:19): oben ein Merge oder Commit ohne Nummer. Dann die Nummer des jüngsten eigenen Commits
    (erste Eltern, nicht auf origin/main), außer sein Vorgang gehört einer anderen Rolle als der Zweig (912, D156.1: B1
    claude/tom-…, oben Jerrys 864); dann der Vorgang im Zweignamen, zuletzt doch der Verlauf. 914 (D157.2): Verlauf vor
    Name, sonst 264 statt 264.1, 348 statt 642. 913 (D157.1): rev vorher fest auflösen, zweig_lesen verbiegt FETCH_HEAD."""
    sha = git("rev-parse", "--verify", "-q", rev, cwd=wo).stdout.strip()
    if zweig is None:
        zweig = git("rev-parse", "--abbrev-ref", "HEAD", cwd=wo).stdout.strip() if rev == "HEAD" else ""
    if not sha:
        return None
    log = git("log", "--first-parent", "--no-merges", "-n", "30", "--format=%B%x00", sha, "^origin/main", cwd=wo).stdout
    eigen = None
    for nachricht in log.split("\0"):
        nr = re.match(r"\s*(?:\w+:\s*)?(" + NR + r")\b", nachricht)
        if nr:
            eigen = nr.group(1); break
    bekannt = vorgaenge()
    rolle = (zweig or "").removeprefix("refs/heads/").removeprefix("claude/").split("-")[0].capitalize()
    rolle = ZUSATZ_TEAM.get(rolle, rolle)  # 920 (D158.1): Spike arbeitet Toms, Tuffy Jerrys Zeilen; Besitzer in der Liste ist das Team
    if eigen and not (rolle in BESITZER and bekannt.get(eigen) in BESITZER and bekannt.get(eigen) != rolle):
        return eigen
    return nr_aus_zweigname(zweig, bekannt) or eigen


def ohne_film(eingaben):
    """646 (Chef 08.11., 12:34: „646 grundsätzlich ja … Es sollte logisch sein“; ersetzt 390a für den Bauserver): jeder
    Lauf auf dem Bauserver zählt als die eine Probe, auch ein Messlauf ohne Bild (bild=nein); ohne Film (bild=nein oder
    film=nein) greift nur die Filmsperre 511 nicht."""
    return any(str(eingaben.get(k, "")).strip().lower() == "nein" for k in ("bild", "film"))


SAMMELBUILD = re.compile(r"(?:refs/heads/)?claude/build-\d+")  # 646: Sammelbuild für den Gerätetest des Chefs ist keine Probe


def sammelbuild_frei(ref, eingaben=None):
    """646: ein Lauf auf claude/build-<n> ist der Testbuild des Chefs, keine Probe; 730 (D86.1, Diogenes Lauf 86): aber nur ohne
    Probe-Eingaben. Ein Handlauf mit kampf=ja, dorf=ja, schild=ja … (Filme, Vergleiche) zählt; bild=nein, film=nein ändern nichts.
    (Nicht auf android.yml beschränkt: seit 894 baut godot.yml jeden Testbuild selbst.)"""
    if not SAMMELBUILD.fullmatch(str(ref or "")):
        return False
    return not any(str(v).strip() for k, v in (eingaben or {}).items() if k not in ("bild", "film", "ref"))


def handlauf_mcp(d):
    """407: `actions_run_trigger` über den GitHub-Server: (Vorgang, Art), RERUN zum Anhalten, oder None."""
    e = d.get("tool_input") or {}
    methode = e.get("method", "")
    if methode in ("rerun_workflow_run", "rerun_failed_jobs"):
        return RERUN
    if methode != "run_workflow" or sammelbuild_frei(e.get("ref"), e.get("inputs") or {}):
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
        if sammelbuild_frei(ref, eing):
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
        alle = dict(re.findall(r"\\?[\"'](\w+)\\?[\"']\s*:\s*\\?[\"']([^\"'\\]*)", befehl))  # 730: jede Eingabe, nicht nur bild/film
        alle.update(re.findall(r"(?:-f|-F|--field|--raw-field)[=\s]+[\"']?inputs\[(\w+)\]=([^\s\"']*)", befehl))
        if sammelbuild_frei(ref, alle):
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
    wo = wo_von(befehl, m, cwd)
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


ROT_ZEILE = re.compile(r"^Rot:\s*\S", re.M)
GITHUB_LAEUFE = "https://api.github.com/repos/tramour-cmyk/androidapp_rpg_bornim/actions/runs"


def letzter_lauf(zweig):
    """748: jüngster abgeschlossener CI-Lauf auf zweig (öffentliches Repo, ohne Anmeldung), sonst None."""
    import urllib.parse
    import urllib.request
    url = GITHUB_LAEUFE + "?" + urllib.parse.urlencode({"branch": zweig, "status": "completed", "per_page": 1})
    with urllib.request.urlopen(urllib.request.Request(url, headers={"Accept": "application/vnd.github+json"}), timeout=6) as r:
        laeufe = json.load(r).get("workflow_runs") or []
    return laeufe[0] if laeufe else None


def rot_vorher(befehl, cwd, lauf_holen=letzter_lauf):
    """748 (D95.1, zu 464): rote Läufe am 08.11. kamen aus Tests, nicht aus Parsefehlern, und kehrten wieder (Atem 453.1
    dreimal auf drei Zweigen, AUFTRAEGE zweimal, 6236 dreimal in 13 Minuten). Die Tests lokal vor jedem Push laufen zu
    lassen geht nicht (Schritt „Skripte pruefen“ 9 min nach 30 min Modellbau, Kaufmodelle nur in CI; Hakengrenze 90 s).
    Darum: ist der letzte abgeschlossene Lauf auf dem Zweig rot, hält ein Push mit CI-Pfaden an, bis einer der neuen
    Commits die Zeile „Rot: <was scheiterte> – <Ursache, nachgestellt>“ trägt. Grund zum Anhalten oder None."""
    m = PUSH.search(befehl)
    if not m:
        return None
    vorn = befehl[:m.start()]
    wo = wo_von(befehl, m, cwd)
    ziel = CI_ZWEIG.search(m.group(2))
    if not ziel and len([a for a in m.group(2).split() if not a.startswith("-")]) >= 2:
        return None  # ausdrücklich ein anderer Zweig (git push origin main)
    zweig = ziel.group(0).split(":")[-1] if ziel else git("rev-parse", "--abbrev-ref", "HEAD", cwd=wo).stdout.strip()
    if not CI_ZWEIG.fullmatch(zweig):
        return None
    neu_f = COMMIT_F.search(vorn)
    neu = neu_f or COMMIT.search(vorn)
    nachricht = neu_f.group(2) if neu_f else (neu.group(1) if neu else "")
    oben = git("rev-parse", "--verify", "-q", f"origin/{zweig}", cwd=wo).stdout.strip() or \
        git("merge-base", "origin/main", "HEAD", cwd=wo).stdout.strip()
    if not oben:
        return None
    pfade = git("diff", "--name-only", f"{oben}..HEAD", cwd=wo).stdout.split()
    if neu:
        pfade += git("diff", "--name-only", "HEAD", cwd=wo).stdout.split()
        pfade += git("ls-files", "--others", "--exclude-standard", cwd=wo).stdout.split()
    alle = nachricht + "\n" + git("log", "--format=%B", f"{oben}..HEAD", cwd=wo).stdout
    if "[skip ci]" in alle or "[ci skip]" in alle or not any(p.startswith(CI_PFADE) for p in pfade):
        return None
    try:
        lauf = lauf_holen(zweig)
    except Exception:  # Netz weg: nicht anhalten, sonst steht jeder Push
        return None
    if not lauf or lauf.get("conclusion") != "failure":
        return None
    sha = lauf.get("head_sha") or ""
    if sha and git("cat-file", "-e", sha + "^{commit}", cwd=wo).returncode == 0:
        alle += git("log", "--format=%B", f"{sha}..HEAD", cwd=wo).stdout
    if ROT_ZEILE.search(alle):
        return None
    return (f"748: Push angehalten, der letzte Lauf auf {zweig} ist rot ({lauf.get('html_url', '')}, Stand {sha[:9]}). "
            "Erst das Protokoll lesen (GitHub-Werkzeug get_job_logs mit run_id und failed_only), die Ursache nachstellen "
            "(Bekannte Fehler: nie zweimal mit Vermutung bauen), dann in einem der neuen Commits die Zeile "
            "„Rot: <welcher Test, welche Zeile> – <Ursache, wie nachgestellt>“, dann pushen. Scheitert ein Test, der nicht "
            "dir gehört: Vorgang an den Besitzer (vorgang.py neu) und die Zeile „Rot: <Test> – fremd, Vorgang <Nr>“.")


TEAMZWEIG = re.compile(r"claude/(?:tom|jerry|spike|tuffy)-[\w./-]+")
ALT_ZEILE = re.compile(r"^Alt:\s*\S", re.M)


def spielcode(pfade):
    return [p for p in pfade if p.startswith("godot/") and not p.startswith("godot/tests/") and not p.endswith((".uid", ".import"))]


def alt_meldung(zweig, spiel):
    return ("647 (Chef 08.11., 12:44: „Alter Code, neuer Code. Nicht 1:1 kopieren, aber die guten Sachen … übernehmen und besser "
            f"machen“): Push auf {zweig} ändert Spielcode ({', '.join(spiel[:3])}{' …' if len(spiel) > 3 else ''}), aber keine "
            "Commit-Nachricht nennt die alte Fassung. Vor dem Bauen die Fundstelle in app/ oder core/ lesen, dann eine Zeile "
            "„Alt: <Datei:Zeilen>, übernommen: …, besser: …“ in die Nachricht (git commit --amend, solange nicht gepusht), "
            "oder „Alt: keine (<Grund>)“, wenn es nichts Altes gibt.")


def alt_fehlt_mcp(d):
    """731 (D87.1, Diogenes Lauf 87): dieselbe Prüfung für push_files/create_or_update_file auf die mitgegebene Nachricht."""
    e = d.get("tool_input") or {}
    zweig = str(e.get("branch") or "")
    if not TEAMZWEIG.fullmatch(zweig):
        return None
    pfade = [str(f.get("path", "")) for f in (e.get("files") or []) if isinstance(f, dict)] + ([str(e["path"])] if e.get("path") else [])
    spiel = spielcode(pfade)
    if not spiel or ALT_ZEILE.search(str(e.get("message") or "")):
        return None
    return alt_meldung(zweig, spiel).replace("(git commit --amend, solange nicht gepusht)", "(Feld message)")


def alt_fehlt(befehl, cwd):
    """647 (Chef 08.11., 12:44: „Alter Code, neuer Code. Nicht 1:1 kopieren, aber die guten Sachen, die schon da sind,
    übernehmen und besser machen“): ein Push auf einen Teamzweig mit Spielcode unter godot/ (ohne tests/) braucht in einer
    seiner Commit-Nachrichten die Zeile „Alt: <Datei:Zeilen der alten Fassung, was übernommen, was besser>“ oder
    „Alt: keine (<Grund>)“. Grund zum Anhalten oder None."""
    m = PUSH.search(befehl)
    if not m:
        return None
    wo = wo_von(befehl, m, cwd)
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
    # 692: Pfade wie Nachrichten nur aus eigenen Commits; nach `git merge origin/main` lagen sonst Dateien aus main im Diff
    eigen = [f"{oben}..HEAD"] + (["^origin/main"] if git("rev-parse", "--verify", "-q", "origin/main", cwd=wo).stdout.strip() else [])
    pfade = git("log", "--no-merges", "--name-only", "--format=", *eigen, cwd=wo).stdout.split()
    texte = git("log", "--no-merges", "--format=%B%x00", *eigen, cwd=wo).stdout
    neu_f = COMMIT_F.search(befehl[:m.start()])
    neu = neu_f or COMMIT.search(befehl[:m.start()])
    if neu:
        pfade += git("diff", "--name-only", "HEAD", cwd=wo).stdout.split()
        texte += "\n" + (neu_f.group(2) if neu_f else neu.group(1))
    spiel = spielcode(pfade)
    if not spiel or ALT_ZEILE.search(texte):
        return None
    return alt_meldung(zweig, spiel)


def filmlauf_rechner(befehl, cwd):
    """511: filmt dieser Bildlauf am Rechner? Marke im Befehl oder ein Laufskript, das filmt (`--write-movie`, mp4, ffmpeg)."""
    if FILM.search(befehl):
        return True
    for m in SKRIPT.finditer(befehl):
        for basis in [cwd, REPO] + cd_ordner(befehl, cwd):
            datei = os.path.join(basis, m.group(0))
            if os.path.isfile(datei):
                if FILM.search(open(datei, encoding="utf-8", errors="replace").read()):
                    return True
                break
    return False


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
    return cd_ziel(befehl, cwd, erstes=True)


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


GIT_SCHREIBT = re.compile(r"\bgit\s+(?:-C\s+(\S+)\s+)?(?:commit|push)\b")


def vorlage_unvollstaendig(befehl, cwd, d=None):
    """799 (Chef 09.11., 20:46): eine Vorlage in docs/chefsache/entscheiden/ oder billigen/ ohne die Teile nach 364 kommt
    nicht nach main. Bash: vor `git commit`/`git push` in einer Arbeitskopie auf main jede solche Datei, die von origin/main
    abweicht (Arbeitsstand);
    GitHub-Server: Inhalt aus push_files/create_or_update_file. Grund zum Anhalten oder None."""
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import vorlage_pruefen as vp
    befunde = []
    if d is not None:
        e = d.get("tool_input") or {}
        dateien = [f for f in (e.get("files") or []) if isinstance(f, dict)] + ([e] if e.get("path") else [])
        for f in dateien:
            o = vp.ordner_von(str(f.get("path", "")))
            if o and (fehlt := vp.luecken(str(f.get("content") or ""), o)):
                befunde.append((f["path"], fehlt))
        return vp.meldung(befunde) if befunde else None
    m = GIT_SCHREIBT.search(befehl)
    if not m:
        return None
    wo = wo_von(befehl, m, cwd)
    wurzel = git("rev-parse", "--show-toplevel", cwd=wo).stdout.strip()
    if not wurzel or not os.path.isdir(os.path.join(wurzel, "docs", "chefsache")):
        return None
    if git("rev-parse", "--abbrev-ref", "HEAD", cwd=wurzel).stdout.strip() != "main":  # Notizen nur auf main
        return None
    sp = ["--", "docs/chefsache/entscheiden", "docs/chefsache/billigen"]
    pfade = git("diff", "--name-only", "origin/main", *sp, cwd=wurzel).stdout.split() + \
        git("ls-files", "--others", "--exclude-standard", *sp, cwd=wurzel).stdout.split()
    for p in sorted(set(pfade)):
        datei = os.path.join(wurzel, p)
        o = vp.ordner_von(p)
        if o and os.path.isfile(datei) and (fehlt := vp.luecken(open(datei, encoding="utf-8").read(), o)):
            befunde.append((p, fehlt))
    return vp.meldung(befunde) if befunde else None


def anhalten(text):
    print(text, file=sys.stderr)
    sys.exit(2)


def main():
    if sys.argv[1:2] == ["--stand"]:
        for nr in sys.argv[2:]:
            n, v = stand(nr)
            print(f"{nr}: {n} von {GRENZE} Probeläufen seit {'Urteil ' + v if v else 'Beginn der Zählung'}")
        return
    if sys.argv[1:2] in (["--helfer"], ["--probebild"]):
        sys.exit("783 W1 (Chef 09.11., 20:12): Probebild und Helfer entfallen; Einzelbild selbst ansehen, dann gleich Film.")
    try:
        d = json.load(sys.stdin)
    except ValueError:
        return
    roh = (d.get("tool_input") or {}).get("command") or ""  # Push und Commit-Nachricht (Heredoc) aus dem ganzen Befehl
    befehl = ohne_heredoc(roh)
    cwd = d.get("cwd") or os.getcwd()
    wer = (d.get("session_id") or "?")[:20]
    e822 = d.get("tool_input") or {}
    bereich_merken([f.get("path", "") for f in (e822.get("files") or []) if isinstance(f, dict)] + ([e822["path"]] if e822.get("path") else []),
                   befehl, d.get("session_id") or "x", cwd)  # 822
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
            grund = vorlage_unvollstaendig("", cwd, d)  # 799
        except (OSError, subprocess.SubprocessError, ValueError, ImportError):
            grund = None
        if grund:
            anhalten(grund)
        if (grund := alt_fehlt_mcp(d)):  # 731
            anhalten(grund)
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
        grund = vorlage_unvollstaendig(befehl, cwd)  # 799: Vorlage nach 364
    except (OSError, subprocess.SubprocessError, ValueError, ImportError):
        grund = None
    if grund:
        anhalten(grund)
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
    try:
        grund = rot_vorher(roh, cwd)  # 748: nach rotem Lauf erst Ursache, dann Push
    except (OSError, subprocess.SubprocessError, ValueError):
        grund = None
    if grund:
        anhalten(grund)
    film = False
    try:
        if bildlauf(befehl, cwd) and not PROBE.search(befehl) and (pb := PROBEBILD.search(befehl)):
            if (fs := figur_sperre(arbeitskopie(befehl, cwd), "HEAD")):
                anhalten(fs)
            if filmlauf_rechner(befehl, cwd):  # 783 W1: Probebild ist ein Einzelbild, kein Film
                anhalten(f"783 W1: `PROBEBILD={pb.group(1)}` gilt nur für ein Einzelbild; dieser Befehl filmt. Für den Film "
                         f"`PROBE={pb.group(1)}`.")
            return hinweis_geben(f"783 W1: Einzelbild zu {pb.group(1)}, zählt nicht als Probelauf. Selbst ansehen, ob Inhalt da "
                                 "ist (kein Weißbild, richtiger Ort), dann gleich Film; nicht an den Chef, kein Helfer.")
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
        sperre = figur_sperre(STAND_REF.get("wo"), STAND_REF.get("rev"))
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


BEREICH = {"text": ""}  # 822: Liste je Bereich, einmal je Sitzung (tools/bereichslisten.py)


def bereich_merken(pfade, befehl, sitzung, cwd="."):
    try:
        sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
        import bereichslisten as bl
        if not pfade and re.search(r"\bgit\b.*\b(commit|push)\b", befehl):
            m = GIT_SCHREIBT.search(befehl)
            wo = wo_von(befehl, m, cwd) if m else cd_ziel(befehl, cwd)
            pfade = bl.pfade_git(befehl, wo)
        BEREICH["text"] = bl.zusatz(pfade, befehl, sitzung)
    except Exception:
        BEREICH["text"] = ""


def hinweis_geben(text=""):
    """Zusatztext an die Sitzung (PreToolUse additionalContext): Zählstand 389, falls nötig Ungeprüftes 464.1, Liste je Bereich 822."""
    text = " ".join(t for t in (text, ungeprueft_hinweis(), BEREICH["text"]) if t)
    if text:
        print(json.dumps({"hookSpecificOutput": {"hookEventName": "PreToolUse", "additionalContext": text}}, ensure_ascii=False))


if __name__ == "__main__":
    try:
        main()
    except Unaufloesbar as e:  # 725
        anhalten(str(e))
