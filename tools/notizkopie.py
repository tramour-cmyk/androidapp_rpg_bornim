#!/usr/bin/env python3
"""1963 (Chef 22.11., 17:19; Ursache wie 1776): Notizkopie (../bornim-main) mit veraltetem, vorgemerktem Stand selbst aufräumen.
Ursache: `git checkout -B main origin/main` in der Arbeitskopie (Doris 22.11., 16:55; Jerry 21.11., 21:06) setzt bei git 2.43 den
Zweig main um, obwohl die Notizkopie ihn hält; deren Index bleibt auf dem alten Stand und zeigt ihn als vorgemerkt („M “, „A “, „D “).
`notiz.sh` tat bei schmutziger Kopie nichts, der Stop-Haken drängte zum Pushen, das Zurücksetzen lehnte die Auto-Prüfung ab, die
Sitzung fragte den Chef.
Abhilfe: Eine geänderte Datei ist alt, wenn Index und Datei je dem Stand von HEAD oder einem früheren Stand auf origin/main gleichen
(fehlend nur, wenn main laut Reflog früher ohne die Datei stand) oder die Datei älter als 2 h ist. Alte Dateien: erst Sicherung (Zweig backup-notiz-<Zeit>, enthält
Index und Dateien), dann auf HEAD zurück. Junge eigene Änderungen bleiben. Muster: rueckschritt() in gepusht-haken.py, Sicherung
wie 1701 in notiz.sh; `git stash create` legt die Sicherung an, ohne die Kopie zu ändern.
  notizkopie.py [PFAD]   räumt PFAD (Vorgabe ../bornim-main) auf, eine Zeile Ausgabe, wenn etwas geschah oder Junges bleibt.
Test: tools/notizkopie_test.py
"""
import os, subprocess, sys, time

ALTER = 7200  # Sekunden; älter gilt als alt (1701)


def _git(wo, *a, ok=False):
    p = subprocess.run(["git", "-C", wo] + list(a), capture_output=True, text=True, timeout=30)
    if p.returncode and not ok: raise RuntimeError(p.stderr.strip())
    return p.stdout


def _blob(wo, ref, rel):
    """Blob von REL in REF (\":\" = Index), None, wenn dort nicht vorhanden."""
    return _git(wo, "rev-parse", "-q", "--verify", (":0:" if ref == ":" else ref + ":") + rel, ok=True).strip() or None


def _geaendert(wo):
    """Geänderte Pfade aus `status -z`; bei Umbenennung/Kopie (R, C) folgt der alte Pfad ohne Statusvorsatz (Pit 19:14, 1963-Ü5)."""
    aus, teile, i = [], _git(wo, "status", "--porcelain", "-z", "--untracked-files=no").split("\0"), 0
    while i < len(teile):
        z = teile[i]; i += 1
        if len(z) < 4: continue
        aus.append(z[3:])
        if "R" in z[:2] or "C" in z[:2]:
            if i < len(teile) and teile[i]: aus.append(teile[i])
            i += 1
    return aus


def _fehlte_frueher(wo, rel):
    """Fehlte REL in einem früheren Stand von main (Reflog, also wo main vor `checkout -B` stand)? Nur dann ist eine Löschung
    ein Altstand; eine junge eigene Löschung (git rm, rm) einer Datei, die main immer hatte, bleibt (Pit 19:14, 1963-Ü3)."""
    for c in dict.fromkeys(_git(wo, "log", "-g", "-n", "50", "--format=%H", "refs/heads/main", ok=True).split()):
        if _blob(wo, c, rel) is None: return True
    return False


def alt(wo, rel):
    """True, wenn REL nur einen früheren Stand trägt (Index und Datei je HEAD oder früher auf origin/main) oder älter als 2 h ist."""
    pfad = os.path.join(wo, rel)
    if os.path.isfile(pfad) and time.time() - os.path.getmtime(pfad) > ALTER: return True
    kopf = _blob(wo, "HEAD", rel)
    frueher = set()
    for z in _git(wo, "log", "-n", "300", "--no-abbrev", "--format=", "--raw", "origin/main", "--", rel, ok=True).splitlines():
        t = z.split()
        if len(t) >= 4: frueher.update(t[2:4])
    frueher.discard("0" * 40)
    if not frueher: return False  # ohne Geschichte auf main: nicht von dort, also eigen
    datei = _git(wo, "hash-object", "--", rel).strip() if os.path.isfile(pfad) else None
    for b in (_blob(wo, ":", rel), datei):
        if b is None:
            if kopf is not None and not _fehlte_frueher(wo, rel): return False  # junge Löschung
        elif b != kopf and b not in frueher: return False
    return True


def aufraeumen(wo):
    """Räumt die Notizkopie WO auf; Meldung (str) oder None, wenn nichts zu tun war."""
    if not os.path.isdir(wo): return None
    try: _git(wo, "rev-parse", "--verify", "HEAD")
    except Exception: return None
    namen = _geaendert(wo)
    if not namen: return None
    alte = [n for n in namen if alt(wo, n)]
    junge = [n for n in namen if n not in alte]
    teile = []
    if alte:
        sha = _git(wo, "stash", "create", "1963 Notizkopie vor dem Aufräumen").strip()
        if not sha: raise RuntimeError("Sicherung leer")
        b, i = "backup-notiz-" + time.strftime("%m%d-%H%M%S"), 1
        while _git(wo, "rev-parse", "-q", "--verify", "refs/heads/" + b, ok=True).strip():
            b, i = "backup-notiz-%s-%d" % (time.strftime("%m%d-%H%M%S"), i), i + 1
        _git(wo, "branch", b, sha)
        _git(wo, "restore", "--source=HEAD", "--staged", "--worktree", "--", *alte)
        teile.append("%d veraltete Datei(en) eines früheren main-Stands (%s) gesichert als Zweig %s und auf HEAD zurückgesetzt"
                     % (len(alte), ", ".join(alte[:4]) + (" …" if len(alte) > 4 else ""), b))
    if junge:
        teile.append("%d junge Änderung(en) bleiben (%s): eigene committen und pushen, sonst Frage per `vorgang.py rueckmeldung <Nr> \"Frage …\"`"
                     % (len(junge), ", ".join(junge[:4]) + (" …" if len(junge) > 4 else "")))
    return "Bornim (1963): Notizkopie %s: %s." % (wo, "; ".join(teile))


if __name__ == "__main__":
    hier = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    ziel = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(hier), "bornim-main")
    try:
        m = aufraeumen(ziel)
        if m: print(m)
    except Exception as e:
        print("Bornim (1963): Notizkopie nicht aufgeräumt (%s); Frage per `vorgang.py rueckmeldung 1963 \"Frage …\"`." % e)
