#!/usr/bin/env python3
"""1765 (Build-Kette 1727, Chef 19.11., 22:05; Profil Technik F12, Chef 21.11., 15:15; Auftrag Chef 21.11., 20:20 „Jerry, ja“):
Build-Werkzeug. Prüft, was der Build-Macher bisher von Hand prüfte (Profil Technik Aufbau). Jeder Befehl holt die Zweige selbst
(git fetch), druckt je Befund eine Zeile und endet mit Exit 0 (in Ordnung) oder 1 (anhalten; laut an den Chef, nicht senden).

  buildwerkzeug.py spitze N [--spitze SHA] [--auftrag DATEI]
      Build-Kette 2 „Sicherung durch Vergleich“: die Spitze von origin/claude/build-N muss genau der Commit sein, den der
      Build-Macher gepusht hat (--spitze; ohne: HEAD dieser Arbeitskopie, wenn sie auf claude/build-N steht). Jeder fremde Commit
      darüber macht den Build ungültig. Mit --auftrag (Zeilen „<Vorgang> <Commit>“, Build-Kette 1 Einfrieren) zusätzlich: jeder
      eingefrorene Commit ist im Build.
  buildwerkzeug.py zug N
      Build-Kette 5 und 6: jeder frühere Build, der beim Chef liegt (Vorgang „zu testen, Build M“ in LISTE-VORGAENGE.md) und nicht
      verworfen ist (feste Archivzeile „Build M verworfen“ in VORGANGSARCHIV.md), ist Vorfahr von Build N (git merge-base
      --is-ancestor); ein Build, der schon auf main ist, zählt als enthalten. Druckt die Zeile für die Telegram-Meldung
      „enthält alle früheren Builds: ja“ (sonst „nein (…)“) und warnt ab drei offenen Builds (höchstens zwei).
  buildwerkzeug.py pfade --getestet SHA [--merge SHA] [--kerntest]
      Build-Kette 4 „Nach main mit Nachweis“: Spielcode-Pfade (Pfadfilter von godot.yml) zwischen getesteter Spitze und dem Stand
      nach dem Einmischen von main (--merge, sonst HEAD). Leer → Merge frei. Nicht leer → Kerntests auf dem Merge nötig; mit
      --kerntest laufen sie gleich (tools/t logik in einer eigenen Arbeitskopie des Merges), rot → kein Merge.
  buildwerkzeug.py gebilligt N [--vorgaenge NR,…] [--ohne NR,…]
      Gesamtbetrachtung 21.11. (Fall 1566): je gebilligtem Vorgang des Builds sind seine Commits auf origin/main und ihre Änderung
      ist nicht zurückgenommen (kein Revert auf main; Änderung an Spielcode-Pfaden steckt im Merge des Builds nach main, so fällt
      ein Einmischen auf, das sie herausnahm). Vorgang eines Commits = erste Zahl der Nachricht
      (wie probelauf.py, 407). Ohne --vorgaenge alle Vorgänge des Builds außer --ohne (per Revert herausgenommene).
  buildwerkzeug.py --test      Selbsttest an einem Wegwerf-Repo.
Bis zur Umstellung (1727) rückwärtsverträglich: liest nur, ändert nichts, gilt neben Checkliste 13.
"""
import argparse, os, re, shutil, subprocess, sys, tempfile

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WORKFLOW = ".github/workflows/godot.yml"
ZWEIG = "claude/build-%s"


def git(*a, cwd=None, ok=False, eingabe=None, env=None):
    r = subprocess.run(["git"] + list(a), cwd=cwd or REPO, capture_output=True, text=True, input=eingabe,
                       env=dict(os.environ, **(env or {})))
    if r.returncode and not ok:
        raise RuntimeError("git %s: %s" % (" ".join(a), (r.stderr or r.stdout).strip()[:300]))
    return r.stdout.strip() if not ok else r


def holen(*refs, cwd=None):
    """Zweige vom Server holen (Einzelzweig-Klon: nur benannte Refs); Fehler zählen nicht, die Prüfung danach findet den Ref nicht."""
    for r in refs:
        git("fetch", "-q", "origin", "+refs/heads/%s:refs/remotes/origin/%s" % (r, r), cwd=cwd, ok=True)


def ref_da(ref, cwd=None):
    return git("rev-parse", "-q", "--verify", ref + "^{commit}", cwd=cwd, ok=True).returncode == 0


def vorfahr(a, b, cwd=None):
    return git("merge-base", "--is-ancestor", a, b, cwd=cwd, ok=True).returncode == 0


def spielcode_pfade(cwd=None):
    """Pfadfilter von godot.yml (on.push.paths) ohne die Workflow-Datei selbst: eine Quelle wie in logik.py."""
    import yaml
    d = yaml.safe_load(open(os.path.join(cwd or REPO, WORKFLOW), encoding="utf-8"))
    on = d.get("on", d.get(True)) or {}
    return [p for p in (on.get("push") or {}).get("paths", []) if p != WORKFLOW]


def pathspec(pfade):
    return [":(glob)" + p for p in pfade]


def vorgang_von(nachricht):
    m = re.search(r"\d+(?:\.\d+)*", nachricht.split("\n", 1)[0])
    return m.group(0) if m else None


# --- spitze -------------------------------------------------------------------------------------------------------------
def auftrag_lesen(pfad):
    aus = []
    for z in open(pfad, encoding="utf-8"):
        z = z.split("#")[0].strip()
        m = re.match(r"(\S+)\s+([0-9a-f]{7,40})\b", z)
        if m:
            aus.append((m.group(1), m.group(2)))
    return aus


def cmd_spitze(n, spitze=None, auftrag=None, cwd=None):
    zweig = ZWEIG % n
    holen(zweig, cwd=cwd)
    fern = "refs/remotes/origin/" + zweig
    if not ref_da(fern, cwd):
        print("%s fehlt auf dem Server" % zweig); return 1
    if not spitze:
        if git("rev-parse", "--abbrev-ref", "HEAD", cwd=cwd) != zweig:
            print("ohne --spitze nur in einer Arbeitskopie auf %s" % zweig); return 1
        spitze = "HEAD"
    soll, ist = git("rev-parse", spitze + "^{commit}", cwd=cwd), git("rev-parse", fern, cwd=cwd)
    f = 0
    if soll != ist:
        f += 1
        if vorfahr(soll, ist, cwd):
            fremd = git("log", "--format=%h %an %s", soll + ".." + ist, cwd=cwd).splitlines()
            print("UNGÜLTIG: %d fremde Commits über der Spitze %s des Build-Machers (Build-Kette 2):" % (len(fremd), soll[:9]))
            for z in fremd[:20]:
                print("  " + z[:150])
        else:
            print("UNGÜLTIG: Spitze auf dem Server %s ist nicht der gepushte Stand %s und enthält ihn nicht "
                  "(überschrieben oder nicht gepusht)" % (ist[:9], soll[:9]))
    for v, c in (auftrag_lesen(auftrag) if auftrag else []):
        if not ref_da(c, cwd):
            f += 1; print("FEHLT: %s Commit %s unbekannt (Auftrag)" % (v, c))
        elif not vorfahr(c, ist, cwd):
            f += 1; print("FEHLT: %s Commit %s nicht im Build (Auftrag, Build-Kette 1)" % (v, c))
    if not f:
        print("Spitze %s = gepushter Stand%s: in Ordnung" % (ist[:9], ", alle eingefrorenen Commits drin" if auftrag else ""))
    return 1 if f else 0


# --- zug ----------------------------------------------------------------------------------------------------------------
def offene_builds(cwd=None):
    """Builds, die beim Chef liegen: Vorgangszeilen mit Stand „zu testen, Build M“."""
    p = os.path.join(cwd or REPO, "docs", "LISTE-VORGAENGE.md")
    return sorted(set(re.findall(r"zu testen, Build (\d+[a-z]?)\b", open(p, encoding="utf-8").read())), key=nummer)


def verworfene(cwd=None):
    p = os.path.join(cwd or REPO, "docs", "VORGANGSARCHIV.md")
    return set(re.findall(r"\bBuild (\d+[a-z]?) verworfen\b", open(p, encoding="utf-8").read()))


def nummer(b):
    m = re.match(r"(\d+)", b)
    return (int(m.group(1)), b)


def cmd_zug(n, cwd=None):
    frueher = [m for m in offene_builds(cwd) if nummer(m) < nummer(n) and m not in verworfene(cwd)]
    holen("main", ZWEIG % n, *[ZWEIG % m for m in frueher], cwd=cwd)
    neu = "refs/remotes/origin/" + ZWEIG % n
    if not ref_da(neu, cwd):
        print("%s fehlt auf dem Server" % (ZWEIG % n)); return 1
    fehlt = []
    for m in frueher:
        alt = "refs/remotes/origin/" + ZWEIG % m
        if not ref_da(alt, cwd):
            fehlt.append("%s (Zweig fehlt auf dem Server)" % m)
        elif not (vorfahr(alt, neu, cwd) or vorfahr(alt, "refs/remotes/origin/main", cwd)):
            fehlt.append(m)
    if len(frueher) + 1 > 2:
        print("Warnung: %d Builds offen (%s, %s), höchstens zwei (Build-Kette 5)" % (len(frueher) + 1, ", ".join(frueher), n))
    if fehlt:
        print("enthält alle früheren Builds: nein (fehlt Build %s); anhalten, Build-Kette 5" % ", ".join(fehlt)); return 1
    print("enthält alle früheren Builds: ja" + (" (%s)" % ", ".join(frueher) if frueher else ""))
    return 0


# --- pfade --------------------------------------------------------------------------------------------------------------
def cmd_pfade(getestet, merge="HEAD", kerntest=False, cwd=None):
    pfade = spielcode_pfade(cwd)
    a, b = git("rev-parse", getestet + "^{commit}", cwd=cwd), git("rev-parse", merge + "^{commit}", cwd=cwd)
    anders = git("diff", "--name-only", a, b, "--", *pathspec(pfade), cwd=cwd).splitlines()
    if not anders:
        print("Spielcode gleich zwischen getestet %s und Merge %s: Merge frei (Build-Kette 4)" % (a[:9], b[:9])); return 0
    print("Spielcode anders zwischen getestet %s und Merge %s (%d Dateien):" % (a[:9], b[:9], len(anders)))
    for p in anders[:30]:
        print("  " + p)
    if not kerntest:
        print("Kerntests auf dem Merge nötig (--kerntest), rot → kein Merge"); return 1
    d = tempfile.mkdtemp(prefix="buildwerkzeug-")
    try:
        git("worktree", "add", "-q", "--detach", d, b, cwd=cwd)
        r = subprocess.run([os.path.join(d, "tools", "t"), "logik"], cwd=d)
        print("Kerntests auf dem Merge %s: %s" % (b[:9], "grün, Merge frei" if r.returncode == 0 else "ROT, kein Merge"))
        return 0 if r.returncode == 0 else 1
    finally:
        git("worktree", "remove", "--force", d, cwd=cwd, ok=True)
        shutil.rmtree(d, ignore_errors=True)


# --- gebilligt ----------------------------------------------------------------------------------------------------------
def noch_da(c, ziel, pfade=(), cwd=None):
    """Änderung von Commit c (nur Spielcode-Pfade) steckt in ziel: ihr Gegenstück lässt sich auf ziel anwenden (eigener Index)."""
    patch = git("diff", "--binary", c + "^", c, "--", *pfade, cwd=cwd)
    if not patch:
        return True
    idx = tempfile.mktemp(prefix="buildwerkzeug-idx-")
    try:
        env = {"GIT_INDEX_FILE": idx}
        git("read-tree", ziel, cwd=cwd, env=env)
        return git("apply", "--cached", "--check", "-R", "-", cwd=cwd, ok=True, eingabe=patch + "\n", env=env).returncode == 0
    finally:
        if os.path.exists(idx):
            os.remove(idx)


def main_anteil(fern, main, cwd=None):
    """Was im Buildzweig von main stammt, auch nachdem er auf main ist: der Abzweig (erster Commit der Erst-Eltern-Kette des
    Buildzweigs, der auf der Erst-Eltern-Kette von main liegt) und jedes eingemischte main (zweite Eltern auf dieser Kette).
    Der Rest sind die Commits der Vorgänge des Builds samt eigener Nachbesserung des Build-Machers."""
    hauptlinie = set(git("rev-list", "--first-parent", main, cwd=cwd).split())
    aus = []
    for z in git("rev-list", "--first-parent", "--parents", fern, cwd=cwd).splitlines():
        c, *eltern = z.split()
        if c in hauptlinie:
            aus.append(c); break
        aus += [e for e in eltern[1:] if e in hauptlinie]
    return aus


def blob(c, f, cwd=None):
    r = git("rev-parse", "-q", "--verify", "%s:%s" % (c, f), cwd=cwd, ok=True)
    return r.stdout.strip() if r.returncode == 0 else None


def verluste(fern, main, je, pfade, cwd=None):
    """Fall 1566 („das Einmischen von main nahm Jerrys 1566 heraus“): ein Merge im Build oder beim Zusammenführen nach main, der
    für eine Spielcode-Datei einfach die andere Seite nimmt und so die Änderung eines Vorgangs-Commits dieser Seite verwirft
    (Ergebnis = Datei der anderen Seite, beide Seiten verschieden, die Änderung lässt sich auf das Ergebnis nicht zurückspielen).
    Spätere gewollte Änderungen derselben Zeilen in gewöhnlichen Commits zählen nicht."""
    meine = {c for cs in je.values() for c in cs}
    merges = git("rev-list", "--merges", fern, "--not", *main_anteil(fern, main, cwd), cwd=cwd).split()
    merges += git("rev-list", "--merges", "--first-parent", "--ancestry-path", "--reverse", fern + ".." + main, cwd=cwd).split()[:1]
    aus = {}
    for m in merges:
        eltern = git("rev-list", "--parents", "-n", "1", m, cwd=cwd).split()[1:]
        if len(eltern) != 2:
            continue
        b = git("merge-base", *eltern, cwd=cwd)
        for seite, andere in ((eltern[0], eltern[1]), (eltern[1], eltern[0])):
            for f in git("diff", "--name-only", b, seite, "--", *pfade, cwd=cwd).splitlines():
                bm, bs, ba = blob(m, f, cwd), blob(seite, f, cwd), blob(andere, f, cwd)
                if bm != ba or bs == ba:
                    continue
                for c in git("rev-list", "--no-merges", b + ".." + seite, "--", f, cwd=cwd).split():
                    if c in meine and not noch_da(c, m, [f], cwd):
                        aus.setdefault(c, []).append("Änderung an %s beim Merge %s verworfen" % (f, m[:9]))
    return aus


def zurueck_genannt(v, cs, ziel, cwd=None):
    """Rücknahme nach dem ersten Commit des Vorgangs bis zum Merge, erkannt an der Nachricht: „Revert "V: …"“ (auch über
    eingemischtes main, Fall 1566) oder „V … zurückgenommen/herausgenommen“ (Handrevert wie 1724 für 760 in Build 300); eine
    spätere Nachricht „Reapply … V“ hebt sie auf."""
    alt = git("rev-list", "--no-walk=sorted", *cs, cwd=cwd).split()[-1]
    nr = re.escape(v)
    stand = None
    for z in git("log", "--reverse", "--format=%h%x09%s", alt + ".." + ziel, cwd=cwd).splitlines():
        h, s = z.split("\t", 1)
        if re.match(r'Revert "%s\b' % nr, s) or (re.search(r"(?<![\d.])%s(?![\d.])" % nr, s) and re.search(r"zurückgenommen|herausgenommen", s)
                                                and vorgang_von(s) != v):
            stand = "%s nimmt ihn zurück (%s)" % (h, s[:80])
        elif s.startswith("Reapply") and re.search(r"(?<![\d.])%s(?![\d.])" % nr, s):
            stand = None
    return [stand] if stand else []


def cmd_gebilligt(n, vorgaenge=None, ohne=(), cwd=None):
    zweig = ZWEIG % n
    holen("main", zweig, cwd=cwd)
    fern, main = "refs/remotes/origin/" + zweig, "refs/remotes/origin/main"
    if not ref_da(fern, cwd):
        print("%s fehlt auf dem Server" % zweig); return 1
    pfade = pathspec(spielcode_pfade(cwd))
    je = {}
    for z in git("log", "--no-merges", "--format=%H%x09%s", fern, "--not", *main_anteil(fern, main, cwd), "--", *pfade,
                 cwd=cwd).splitlines():
        h, s = z.split("\t", 1)
        v = vorgang_von(s)
        if v and not s.startswith("Revert "):
            je.setdefault(v, []).append(h)
    pruef = [v for v in (vorgaenge or sorted(je, key=lambda x: [int(t) for t in x.split(".")])) if v not in ohne]
    revs = git("log", "--format=%B%x00", main, "--grep", "This reverts commit", cwd=cwd)
    weg = verluste(fern, main, je, pfade, cwd)
    zusammen = (git("rev-list", "--first-parent", "--ancestry-path", "--reverse", fern + ".." + main, cwd=cwd).split() or [None])[0]
    f = 0
    for v in pruef:
        cs = je.get(v, [])
        if not cs:
            f += 1; print("%s: kein Commit im Build gefunden (erste Zahl der Nachricht)" % v); continue
        fehl = []
        for c in cs:
            if not vorfahr(c, main, cwd):
                fehl.append("%s nicht auf main" % c[:9])
            elif c in revs or c[:9] in revs:
                fehl.append("%s per Revert zurückgenommen" % c[:9])
            fehl += ["%s %s" % (c[:9], w) for w in weg.get(c, [])]
        if not fehl:
            fehl += zurueck_genannt(v, cs, zusammen or fern, cwd)
        if fehl:
            f += 1; print("%s: %s" % (v, "; ".join(fehl)))
        else:
            print("%s: %d Commits auf main, kein Revert, kein Merge verwarf sie" % (v, len(cs)))
    return 1 if f else 0


# --- Selbsttest ---------------------------------------------------------------------------------------------------------
def test():
    fehler = 0

    def ok(b, was):
        nonlocal fehler
        if not b:
            fehler += 1; print("FEHLER", was)

    t = tempfile.mkdtemp(prefix="buildwerkzeug-test-")
    server, a = os.path.join(t, "server.git"), os.path.join(t, "a")
    try:
        git("init", "-q", "--bare", "-b", "main", server, cwd=t)
        git("clone", "-q", server, a, cwd=t)
        g = lambda *x, **k: git(*x, cwd=a, **k)
        g("config", "user.email", "t@t"); g("config", "user.name", "t")

        def schreib(p, inhalt, msg):
            os.makedirs(os.path.dirname(os.path.join(a, p)) or a, exist_ok=True)
            open(os.path.join(a, p), "w").write(inhalt); g("add", "-A"); g("commit", "-q", "-m", msg)
            return g("rev-parse", "HEAD")
        os.makedirs(os.path.join(a, ".github/workflows"))
        schreib(WORKFLOW, "on:\n  push:\n    paths: [\"godot/**\", \"tools/karten/**\", \"%s\"]\n" % WORKFLOW, "Werkzeug")
        schreib("docs/LISTE-VORGAENGE.md", "| 10 | x | Jerry | M | zu testen, Build 5 |\n", "Liste")
        schreib("docs/VORGANGSARCHIV.md", "- Build 3 verworfen\n", "Archiv")
        schreib("godot/a.gd", "eins\nzwei\n", "1: Grundstand")
        g("push", "-q", "origin", "main")
        # Build 5: Vorgang 10, liegt beim Chef
        g("checkout", "-q", "-b", ZWEIG % 5)
        c10 = schreib("godot/b.gd", "zehn\n", "10: Wolf springt")
        g("push", "-q", "origin", ZWEIG % 5)
        ok(cmd_spitze("5", cwd=a) == 0, "spitze gleich")
        auf = os.path.join(t, "auftrag"); open(auf, "w").write("10 %s\n" % c10[:9])
        ok(cmd_spitze("5", auftrag=auf, cwd=a) == 0, "Auftrag drin")
        # fremder Commit von einer zweiten Arbeitskopie
        b = os.path.join(t, "b"); git("clone", "-q", "-b", ZWEIG % 5, server, b, cwd=t)
        git("config", "user.email", "t@t", cwd=b); git("config", "user.name", "t", cwd=b)
        open(os.path.join(b, "godot/c.gd"), "w").write("fremd\n"); git("add", "-A", cwd=b); git("commit", "-q", "-m", "99: fremd", cwd=b)
        git("push", "-q", "origin", ZWEIG % 5, cwd=b)
        ok(cmd_spitze("5", cwd=a) == 1, "fremder Commit erkannt")
        ok(cmd_spitze("5", spitze=git("rev-parse", "HEAD", cwd=b), cwd=a) == 0, "mit --spitze des Fremden gleich")
        g("pull", "-q", "--no-rebase", "origin", ZWEIG % 5)
        # Build 6 ohne Build 5: Zug hält an; Build 7 auf 5 aufgesetzt: ja; verworfener Build 3 zählt nicht
        g("checkout", "-q", "main"); g("checkout", "-q", "-b", ZWEIG % 6)
        schreib("godot/d.gd", "sechs\n", "11: Ratte"); g("push", "-q", "origin", ZWEIG % 6)
        ok(cmd_zug("6", cwd=a) == 1, "Zug: 6 ohne 5 hält an")
        g("checkout", "-q", ZWEIG % 5); g("checkout", "-q", "-b", ZWEIG % 7)
        schreib("godot/e.gd", "sieben\n", "12: Spinne"); g("push", "-q", "origin", ZWEIG % 7)
        ok(cmd_zug("7", cwd=a) == 0, "Zug: 7 auf 5 ja")
        # Pfade: main bekommt Notiz und Werkzeug, Spielcode gleich → frei; Spielcode auf main → nötig
        g("checkout", "-q", "main")
        schreib("docs/notiz.md", "x\n", "Notiz"); g("push", "-q", "origin", "main")
        g("checkout", "-q", ZWEIG % 5); getestet = g("rev-parse", "HEAD")
        g("merge", "-q", "--no-edit", "main")
        ok(cmd_pfade(getestet, cwd=a) == 0, "Pfade: nur Notiz → frei")
        g("checkout", "-q", "main"); schreib("godot/a.gd", "eins\nzwei\ndrei\n", "13: auf main"); g("push", "-q", "origin", "main")
        g("checkout", "-q", ZWEIG % 5); g("merge", "-q", "--no-edit", "main")
        ok(cmd_pfade(getestet, cwd=a) == 1, "Pfade: Spielcode anders → Kerntests nötig")
        ok(spielcode_pfade(a) == ["godot/**", "tools/karten/**"], "Pfadfilter ohne Workflow")
        # gebilligt: Build 5 nach main; dann 10 per Revert zurück → Befund
        g("push", "-q", "origin", ZWEIG % 5)
        g("checkout", "-q", "main"); g("merge", "-q", "--no-ff", "--no-edit", ZWEIG % 5); g("push", "-q", "origin", "main")
        ok(cmd_gebilligt("5", vorgaenge=["10"], cwd=a) == 0, "gebilligt: 10 auf main")
        ok(cmd_gebilligt("5", vorgaenge=["11"], cwd=a) == 1, "gebilligt: 11 nicht im Build")
        g("revert", "--no-edit", c10); g("push", "-q", "origin", "main")
        ok(cmd_gebilligt("5", vorgaenge=["10"], cwd=a) == 1, "gebilligt: Revert erkannt")
        ok(vorgang_von("760.1: Sprung") == "760.1" and vorgang_von("Text: x") is None, "Vorgang aus Nachricht")
    finally:
        shutil.rmtree(t, ignore_errors=True)
    print("BUILDWERKZEUG1765 %d Fehler" % fehler)
    return 1 if fehler else 0


def main():
    if "--test" in sys.argv:
        return test()
    ap = argparse.ArgumentParser(description="Build-Werkzeug 1765 (Build-Kette 1727)")
    s = ap.add_subparsers(dest="befehl", required=True)
    p = s.add_parser("spitze"); p.add_argument("n"); p.add_argument("--spitze"); p.add_argument("--auftrag")
    p = s.add_parser("zug"); p.add_argument("n")
    p = s.add_parser("pfade"); p.add_argument("--getestet", required=True); p.add_argument("--merge", default="HEAD")
    p.add_argument("--kerntest", action="store_true")
    p = s.add_parser("gebilligt"); p.add_argument("n"); p.add_argument("--vorgaenge"); p.add_argument("--ohne", default="")
    a = ap.parse_args()
    liste = lambda x: [v.strip() for v in x.split(",") if v.strip()] if x else []
    try:
        if a.befehl == "spitze":
            return cmd_spitze(a.n, a.spitze, a.auftrag)
        if a.befehl == "zug":
            return cmd_zug(a.n)
        if a.befehl == "pfade":
            return cmd_pfade(a.getestet, a.merge, a.kerntest)
        return cmd_gebilligt(a.n, liste(a.vorgaenge) or None, liste(a.ohne))
    except RuntimeError as e:
        print("Build-Werkzeug: %s" % e); return 1


if __name__ == "__main__":
    sys.exit(main())
