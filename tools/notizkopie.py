#!/usr/bin/env python3
"""1963 (Chef 22.11., 17:19; Ursache wie 1776): Notizkopie (../bornim-main) mit veraltetem, vorgemerktem Stand selbst aufräumen.
Ursache: `git checkout -B main origin/main` in der Arbeitskopie (Doris 22.11., 16:55; Jerry 21.11., 21:06) setzt bei git 2.43 den
Zweig main um, obwohl die Notizkopie ihn hält; deren Index bleibt auf dem alten Stand und zeigt ihn als vorgemerkt („M “, „A “, „D “).
`notiz.sh` tat bei schmutziger Kopie nichts, der Stop-Haken drängte zum Pushen, das Zurücksetzen lehnte die Auto-Prüfung ab, die
Sitzung fragte den Chef.
Abhilfe (Sokrates 22.11., 20:06, 1963-Ü8): Der Fehler lässt den ganzen Index auf einem früheren main-Stand stehen. Nur wenn
`git write-tree` dem Baum eines früheren main-Stands (Reflog refs/heads/main) gleicht, erst Sicherung (Zweig backup-notiz-<Zeit>,
`git stash create`, enthält Index und Dateien), dann Index auf HEAD und jede Datei, die noch den alten Stand trägt, auf HEAD.
Sonst nichts automatisch zurücksetzen (junge Löschung, Umbenennung, alte eigene Änderung bleiben), nur Meldung: Frage per
`vorgang.py rueckmeldung`, nie an den Chef. Sicherung wie 1701 in notiz.sh.
  notizkopie.py [PFAD]   räumt PFAD (Vorgabe ../bornim-main) auf, eine Zeile Ausgabe, wenn etwas geschah oder Junges bleibt.
Test: tools/notizkopie_test.py
"""
import os, subprocess, sys, time


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


def _altbaum(wo):
    """Baum des Index, wenn er einem früheren main-Stand (Reflog) gleicht und nicht HEAD; sonst None."""
    idx = _git(wo, "write-tree", ok=True).strip()
    if not idx or idx == _git(wo, "rev-parse", "HEAD^{tree}").strip(): return None
    return idx if idx in _git(wo, "log", "-g", "-n", "50", "--format=%T", "refs/heads/main", ok=True).split() else None


def aufraeumen(wo):
    """Räumt die Notizkopie WO auf; Meldung (str) oder None, wenn nichts zu tun war."""
    if not os.path.isdir(wo): return None
    try: _git(wo, "rev-parse", "--verify", "HEAD")
    except Exception: return None
    namen = _geaendert(wo)
    if not namen: return None
    alte, baum = [], _altbaum(wo)
    if baum:
        sha = _git(wo, "stash", "create", "1963 Notizkopie vor dem Aufräumen").strip()
        if not sha: raise RuntimeError("Sicherung leer")
        b, i = "backup-notiz-" + time.strftime("%m%d-%H%M%S"), 1
        while _git(wo, "rev-parse", "-q", "--verify", "refs/heads/" + b, ok=True).strip():
            b, i = "backup-notiz-%s-%d" % (time.strftime("%m%d-%H%M%S"), i), i + 1
        _git(wo, "branch", b, sha)
        _git(wo, "reset", "-q")  # Index auf HEAD
        for n in namen:
            pfad = os.path.join(wo, n)
            datei = _git(wo, "hash-object", "--", n).strip() if os.path.isfile(pfad) else None
            if datei != _blob(wo, baum, n): continue  # junge Änderung der Datei auf dem Altstand bleibt
            if _blob(wo, "HEAD", n): _git(wo, "checkout", "HEAD", "--", n)
            elif datei: os.remove(pfad)
            alte.append(n)
    junge = _geaendert(wo) if baum else namen
    teile = []
    if alte:
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
