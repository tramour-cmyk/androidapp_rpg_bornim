#!/usr/bin/env python3
"""git-Haken pre-push (1937, Ersatz für die Push-Prüfungen aus probelauf.py; legt notiz.sh an wie den pre-commit).

Muster (erst nachsehen, wie andere es lösen): git pre-push (githooks(5)): git gibt je Ref „<lokal> <sha> <entfernt> <sha>“ auf
stdin; Exit ungleich 0 hält den Push an. Anders als der PreToolUse-Haken liest dieser Haken keinen Befehl nach (cd, -C, Heredoc),
greift auch bei Skripten und hat keine Zeitgrenze von 90 s. `--no-verify` hält sperre-haken.py an.

Hält an (Exit 1, Grund auf stderr):
  647/731  Spielcode unter godot/ (ohne tests/) auf Teamzweig claude/(tom|jerry|spike|tuffy)-… ohne Zeile „Alt: …“ in einer
           eigenen Commit-Nachricht (692: nur eigene Commits, ohne Einmischen von main).
  464      Parsefehler in einer geänderten .gd-Datei (Godot --check-only nach --import) bei Push auf claude/….
  748      letzter abgeschlossener Lauf auf dem Zweig rot, neue Commits mit CI-Pfaden, keine Zeile „Rot: …“.
  1719     Push auf claude/build-<n> ändert Bauskripte ohne Modelle am Rechner zu diesem Stand oder ohne Zeile „Kaufmodelle: …“.
Eigener Fehler (kein Netz, kein Godot) lässt durch. Von Hand: python3 tools/vorpush.py --test
"""
import json, os, re, subprocess, sys

NULL = "0" * 40
TEAMZWEIG = re.compile(r"claude/(?:tom|jerry|spike|tuffy)-[\w./-]+")
CI_ZWEIG = re.compile(r"claude/[\w./-]+")
CI_PFADE = ("godot/", "tools/blender348/", ".github/workflows/")
MODELL_PFADE = ("tools/blender348/", "tools/gegenstaende/")
ALT_ZEILE = re.compile(r"^Alt:\s*\S", re.M)
ROT_ZEILE = re.compile(r"^Rot:\s*\S", re.M)
GODOT_BIN = [os.path.expanduser("~/godot/godot"), "/usr/local/bin/godot", "/usr/bin/godot"]
GITHUB_LAEUFE = "https://api.github.com/repos/tramour-cmyk/androidapp_rpg_bornim/actions/runs"


def git(wo, *a, timeout=20):
    return subprocess.run(["git", "-C", wo, *a], capture_output=True, text=True, timeout=timeout)


class Push:
    """Ein Ref des Pushs: Zweig, Basis (Stand auf origin oder Abzweig von main), eigene Commits, Pfade, Nachrichten."""

    def __init__(self, wo, sha, ref, alt):
        self.wo, self.sha, self.zweig = wo, sha, ref.replace("refs/heads/", "")
        basis = alt if alt != NULL and git(wo, "cat-file", "-e", alt + "^{commit}").returncode == 0 else ""
        self.basis = basis or git(wo, "merge-base", "origin/main", sha).stdout.strip()
        main = ["^origin/main"] if git(wo, "rev-parse", "--verify", "-q", "origin/main").stdout.strip() else []
        self.bereich = [f"{self.basis}..{sha}"] if self.basis else [sha]
        self.eigen = self.bereich + main
        self.pfade = git(wo, "diff", "--name-only", self.basis, sha).stdout.split() if self.basis else []
        self.texte = git(wo, "log", "--format=%B%x00", *self.bereich).stdout

    def eigene_pfade(self):
        return git(self.wo, "log", "--no-merges", "--name-only", "--format=", *self.eigen).stdout.split()

    def eigene_texte(self):
        return git(self.wo, "log", "--no-merges", "--format=%B%x00", *self.eigen).stdout


def spielcode(pfade):
    return [p for p in pfade if p.startswith("godot/") and not p.startswith("godot/tests/") and not p.endswith((".uid", ".import"))]


def alt_fehlt(p):
    """647 (Chef 08.11., 12:44: „Alter Code, neuer Code. Nicht 1:1 kopieren, aber die guten Sachen … übernehmen und besser machen“)."""
    if not TEAMZWEIG.fullmatch(p.zweig):
        return None
    spiel = spielcode(p.eigene_pfade())
    if not spiel or ALT_ZEILE.search(p.eigene_texte()):
        return None
    return ("647 (Chef 08.11., 12:44: „Alter Code, neuer Code. Nicht 1:1 kopieren, aber die guten Sachen … übernehmen und besser "
            f"machen“): Push auf {p.zweig} ändert Spielcode ({', '.join(spiel[:3])}{' …' if len(spiel) > 3 else ''}), aber keine "
            "Commit-Nachricht nennt die alte Fassung. Vor dem Bauen die Fundstelle in der Kotlin-Fassung lesen (Zweit-Repo "
            "bornim-kaufmodelle, kotlin-alt/app, kotlin-alt/core; mit add_repo einbinden, 1279), dann eine Zeile "
            "„Alt: <Datei:Zeilen>, übernommen: …, besser: …“ in die Nachricht (git commit --amend, solange nicht gepusht), "
            "oder „Alt: keine (<Grund>)“, wenn es nichts Altes gibt.")


def parse_fehler(p, godot_bin=None):
    """464 (Chef 01.11., 20:4x: „irgendwer produziert hier abends brutal viele Fehler … fast 20 E-Mails“)."""
    if not CI_ZWEIG.fullmatch(p.zweig) or not os.path.isdir(os.path.join(p.wo, "godot")):
        return None
    gd = sorted({x[len("godot/"):] for x in p.pfade if x.startswith("godot/") and x.endswith(".gd")
                 and os.path.isfile(os.path.join(p.wo, x))})
    godot = godot_bin or next((b for b in GODOT_BIN if os.path.isfile(b)), None)
    if not gd or not godot:  # ohne Godot nicht anhalten, sonst steht der Push ganz
        return None
    pfad = os.path.join(p.wo, "godot")
    vorher = set(git(p.wo, "ls-files", "--others", "--exclude-standard", "godot").stdout.split())
    try:
        subprocess.run([godot, "--headless", "--import", "--path", pfad], capture_output=True, timeout=120)
    except subprocess.TimeoutExpired:
        pass
    for neu in set(git(p.wo, "ls-files", "--others", "--exclude-standard", "godot").stdout.split()) - vorher:
        if neu.endswith(".uid"):  # vom Import angelegt: Arbeitsbaum bleibt, wie er war
            try: os.remove(os.path.join(p.wo, neu))
            except OSError: pass
    fehler = []
    for datei in gd:
        try:
            r = subprocess.run([godot, "--headless", "--path", pfad, "--check-only", "-s", "res://" + datei],
                               capture_output=True, text=True, timeout=30)
        except subprocess.TimeoutExpired:
            continue
        zeilen = [z.strip() for z in (r.stdout + r.stderr).splitlines() if "Parse Error" in z or "GDScript::reload" in z]
        if r.returncode != 0 and zeilen:
            fehler.append(datei + ": " + " ".join(zeilen[:2]))
    if fehler:
        return ("464: Push angehalten, Parsefehler in GDScript (CI würde rot, der Chef bekommt eine E-Mail). Erst beheben, "
                "dann erneut pushen:\n" + "\n".join(fehler[:6]))
    return None


def letzter_lauf(zweig):
    """748: jüngster abgeschlossener CI-Lauf auf zweig (öffentliches Repo, ohne Anmeldung), sonst None."""
    import urllib.parse, urllib.request
    url = GITHUB_LAEUFE + "?" + urllib.parse.urlencode({"branch": zweig, "status": "completed", "per_page": 1})
    with urllib.request.urlopen(urllib.request.Request(url, headers={"Accept": "application/vnd.github+json"}), timeout=8) as r:
        laeufe = json.load(r).get("workflow_runs") or []
    return laeufe[0] if laeufe else None


def rot_vorher(p, lauf_holen=None):
    """748 (D95.1, zu 464): nach rotem Lauf erst Ursache nachstellen, Zeile „Rot: …“, dann Push."""
    if not CI_ZWEIG.fullmatch(p.zweig) or "[skip ci]" in p.texte or "[ci skip]" in p.texte \
            or not any(x.startswith(CI_PFADE) for x in p.pfade):
        return None
    try:
        lauf = (lauf_holen or letzter_lauf)(p.zweig)
    except Exception:  # Netz weg: nicht anhalten
        return None
    if not lauf or lauf.get("conclusion") != "failure":
        return None
    sha = lauf.get("head_sha") or ""
    alle = p.texte
    if sha and git(p.wo, "cat-file", "-e", sha + "^{commit}").returncode == 0:
        alle += git(p.wo, "log", "--format=%B", f"{sha}..{p.sha}").stdout
    if ROT_ZEILE.search(alle):
        return None
    return (f"748: Push angehalten, der letzte Lauf auf {p.zweig} ist rot ({lauf.get('html_url', '')}, Stand {sha[:9]}). "
            "Erst das Protokoll lesen (GitHub-Werkzeug get_job_logs mit run_id und failed_only), die Ursache nachstellen "
            "(Bekannte Fehler: nie zweimal mit Vermutung bauen), dann in einem der neuen Commits die Zeile "
            "„Rot: <welcher Test, welche Zeile> – <Ursache, wie nachgestellt>“, dann pushen. Scheitert ein Test, der nicht "
            "dir gehört: Vorgang an den Besitzer (vorgang.py neu) und die Zeile „Rot: <Test> – fremd, Vorgang <Nr>“.")


def modelle_vor_build(p):
    """1719 (Perikles 18.11., 23:13): Bauskripte im Buildzweig nur mit Modellen am Rechner zu diesem Stand und Zeile „Kaufmodelle:“."""
    if not re.fullmatch(r"claude/build-\d+", p.zweig) or not p.basis \
            or git(p.wo, "diff", "--quiet", p.basis, p.sha, "--", *MODELL_PFADE).returncode != 1:
        return None
    gd = git(p.wo, "rev-parse", "--git-dir").stdout.strip()
    pfad = os.path.join(p.wo, gd, "bornim-modellstand") if gd else ""
    c = open(pfad).read().strip() if pfad and os.path.exists(pfad) else ""
    if not c or git(p.wo, "diff", "--quiet", c, p.sha, "--", *MODELL_PFADE).returncode != 0:
        return ("1719: die neuen Commits auf " + p.zweig + " ändern Bauskripte (tools/blender348/, tools/gegenstaende/); der "
                "Bauserver baut den Block dann frisch und die Prüfungen treffen ungeprüfte Modelle. Erst am Rechner "
                "`python3 tools/godot/bau_am_rechner.py --cache --laden` (baut fehlende Blöcke, Stempel), die Prüfungen mit "
                "Kaufmodellen laufen lassen, dann pushen.")
    if not re.search(r"(?m)^Kaufmodelle: \S", p.texte):
        return ("1719: Bauskripte geändert; in eine der neuen Commit-Nachrichten die Zeile „Kaufmodelle: <Prüfungen> grün am "
                "Rechner (Modellstand " + c[:9] + ")“, dann pushen.")
    return None


PRUEFUNGEN = (alt_fehlt, modelle_vor_build, rot_vorher, parse_fehler)  # teure zuletzt


def gruende(wo, zeilen):
    for z in zeilen:
        t = z.split()
        if len(t) != 4 or t[1] == NULL or not t[2].startswith("refs/heads/"):
            continue  # Löschen hält sperre-haken.py an; Tags gehen durch
        p = Push(wo, t[1], t[2], t[3])
        for f in PRUEFUNGEN:
            try:
                g = f(p)
            except (OSError, subprocess.SubprocessError, ValueError):
                g = None
            if g:
                yield g
                break


def main():
    wo = git(".", "rev-parse", "--show-toplevel").stdout.strip() or "."
    for g in gruende(wo, sys.stdin.read().splitlines()):
        print("vorpush (1937): " + g, file=sys.stderr)
        return 1
    return 0


def test():
    import shutil, tempfile
    global GODOT_BIN, letzter_lauf
    GODOT_BIN, letzter_lauf = [], (lambda z: None)  # gruende() ohne Godot und Netz
    f = 0
    def ok(b, was):
        nonlocal f
        if not b: f += 1; print("FEHLER", was)
    d = tempfile.mkdtemp(); r = os.path.join(d, "r"); o = os.path.join(d, "o.git")
    sh = lambda *a, wo=r: subprocess.run(["git", "-C", wo, *a], capture_output=True, text=True, check=True).stdout.strip()
    subprocess.run(["git", "init", "-q", "--bare", "-b", "main", o], check=True)
    subprocess.run(["git", "init", "-q", "-b", "main", r], check=True)
    sh("config", "user.email", "t@t"); sh("config", "user.name", "t"); sh("remote", "add", "origin", o)
    os.makedirs(os.path.join(r, "godot/tests")); open(os.path.join(r, "README"), "w").write("x")
    sh("add", "."); sh("commit", "-qm", "a"); sh("push", "-q", "origin", "main")
    def commit(datei, nachricht):
        os.makedirs(os.path.dirname(os.path.join(r, datei)) or r, exist_ok=True)
        with open(os.path.join(r, datei), "a") as h: h.write("x\n")
        sh("add", "."); sh("commit", "-qm", nachricht); return sh("rev-parse", "HEAD")
    sh("checkout", "-qb", "claude/tom-1-x")
    s = commit("godot/skripte/a.gd", "1: neu")
    zeile = lambda z, sha: [f"refs/heads/{z} {sha} refs/heads/{z} {NULL}"]
    ok(any(g.startswith("647") for g in gruende(r, zeile("claude/tom-1-x", s))), "647 ohne Alt hält an")
    s = commit("godot/skripte/a.gd", "1: weiter\n\nAlt: keine (neu)")
    ok(not list(gruende(r, zeile("claude/tom-1-x", s))), "647 mit Alt geht")
    s2 = commit("godot/tests/t.gd", "1: Test")
    ok(not list(gruende(r, [f"refs/heads/claude/tom-1-x {s2} refs/heads/claude/tom-1-x {s}"])), "nur Test, Basis entfernt")
    sh("checkout", "-q", "main"); m = commit("godot/skripte/b.gd", "main ändert"); sh("push", "-q", "origin", "main")
    sh("checkout", "-q", "claude/tom-1-x"); sh("merge", "-q", "--no-edit", "main"); s3 = sh("rev-parse", "HEAD")
    ok(not list(gruende(r, [f"refs/heads/claude/tom-1-x {s3} refs/heads/claude/tom-1-x {s2}"])), "692: Einmischen von main zählt nicht")
    ok(not list(gruende(r, zeile("main", m))), "main geht durch")
    ok(not list(gruende(r, [f"(delete) {NULL} refs/heads/claude/tom-1-x {s}"])), "Löschen nicht hier")
    s3b = commit("docs/n.md", "1: Notiz")
    p = Push(r, s3b, "refs/heads/claude/tom-1-x", s3)
    ok(rot_vorher(p, lambda z: {"conclusion": "failure", "head_sha": s2}) is None, "748 ohne CI-Pfad im Bereich")
    sh("checkout", "-qb", "claude/jerry-2-y"); s4 = commit("godot/skripte/c.gd", "2: c\n\nAlt: keine (neu)")
    p = Push(r, s4, "refs/heads/claude/jerry-2-y", NULL)
    ok((rot_vorher(p, lambda z: {"conclusion": "failure", "head_sha": s3}) or "").startswith("748"), "748 rot hält an")
    ok(rot_vorher(p, lambda z: {"conclusion": "success", "head_sha": s3}) is None, "748 grün geht")
    s5 = commit("godot/skripte/c.gd", "2: d\n\nRot: Test x – nachgestellt")
    ok(rot_vorher(Push(r, s5, "refs/heads/claude/jerry-2-y", NULL), lambda z: {"conclusion": "failure", "head_sha": s3}) is None, "748 mit Rot-Zeile")
    sh("checkout", "-qb", "claude/build-9"); s6 = commit("tools/blender348/held.py", "Bau")
    ok((modelle_vor_build(Push(r, s6, "refs/heads/claude/build-9", NULL)) or "").startswith("1719"), "1719 ohne Modellstand")
    gd = sh("rev-parse", "--git-dir"); open(os.path.join(r, gd, "bornim-modellstand"), "w").write(s6)
    ok("Kaufmodelle" in (modelle_vor_build(Push(r, s6, "refs/heads/claude/build-9", NULL)) or ""), "1719 ohne Zeile")
    s7 = commit("godot/x.txt", "Bau\n\nKaufmodelle: alle grün")
    ok(modelle_vor_build(Push(r, s7, "refs/heads/claude/build-9", NULL)) is None, "1719 mit Stempel und Zeile")
    fake = os.path.join(d, "godot.sh")
    open(fake, "w").write('#!/bin/sh\ncase "$*" in *check-only*c.gd*) echo "SCRIPT ERROR: Parse Error: x"; exit 1;; esac\nexit 0\n')
    os.chmod(fake, 0o755)
    ok((parse_fehler(Push(r, s5, "refs/heads/claude/jerry-2-y", NULL), fake) or "").startswith("464"), "464 Parsefehler")
    sh("checkout", "-q", "claude/tom-1-x")
    ok(parse_fehler(Push(r, s, "refs/heads/claude/tom-1-x", NULL), fake) is None, "464 sauber")
    shutil.rmtree(d, ignore_errors=True)
    print("VORPUSH1937 %d Fehler" % f)
    return 1 if f else 0


if __name__ == "__main__":
    sys.exit(test() if "--test" in sys.argv else main())
