# 1776 (222.2): Commit-Prüfung hält an, wenn der Zweig auch in einer zweiten Arbeitskopie ausgecheckt ist
# (veralteter Index setzte am 21.11. mit 023edc9b7 fremde Dateien zurück). Aufruf: python3 tools/zweig_doppelt_test.py
import os, subprocess, sys, tempfile
HIER = os.path.dirname(os.path.abspath(__file__))
PR = os.path.join(HIER, "commit-pruefung.py")
fehler = 0
def soll(name, ok, info=""):
    global fehler
    print(("gut  " if ok else "ROT  ") + name + ("" if ok else "  " + info[-400:]))
    if not ok: fehler += 1
def g(cwd, *a):
    return subprocess.run(["git"] + list(a), cwd=cwd, capture_output=True, text=True)
def pruefen(cwd, fn="zweig_doppelt"):
    sys.path.insert(0, HIER)
    import importlib.util, io, contextlib
    spec = importlib.util.spec_from_file_location("cp", PR); cp = importlib.util.module_from_spec(spec)
    alt = os.getcwd(); os.chdir(cwd)
    try:
        spec.loader.exec_module(cp)
        with contextlib.redirect_stdout(io.StringIO()): return getattr(cp, fn)()
    finally: os.chdir(alt)
def lies(cwd, p):
    try: return open(os.path.join(cwd, p)).read()
    except OSError: return None
with tempfile.TemporaryDirectory() as t:
    a, b = os.path.join(t, "a"), os.path.join(t, "b")
    g(t, "init", "-q", "-b", "main", a)
    for k, v in (("user.email", "x@x"), ("user.name", "x")): g(a, "config", k, v)
    open(os.path.join(a, "f"), "w").write("1\n"); g(a, "add", "f"); g(a, "commit", "-qm", "c1")
    g(a, "worktree", "add", "-q", "--detach", b)
    soll("abgelöste zweite Arbeitskopie: kein Halt", pruefen(a) == "" and pruefen(b) == "")
    # so geschehen am 21.11. (git 2.43: -B übergeht die Sperre); neuere git sperren, die Lage entsteht dort mit --ignore-other-worktrees
    r = g(b, "checkout", "-q", "--ignore-other-worktrees", "-B", "main")
    soll("zweite Arbeitskopie auf main (Ausgangslage)", r.returncode == 0, r.stderr)
    soll("Halt in der Notizkopie, nennt die andere", os.path.realpath(b) == pruefen(a), pruefen(a))
    soll("Halt in der Arbeitskopie, nennt die andere", os.path.realpath(a) == pruefen(b), pruefen(b))
    # 1778 (D329.4): b rückt main vor (f 1 → 2, neue Datei werk), dann --detach; a behält den veralteten Index
    for k, v in (("user.email", "x@x"), ("user.name", "x")): g(b, "config", k, v)
    open(os.path.join(b, "f"), "w").write("2\n"); open(os.path.join(b, "werk"), "w").write("w\n")
    g(b, "add", "f", "werk"); g(b, "commit", "-qm", "b: fremd")
    g(b, "checkout", "-q", "--detach")
    soll("nach --detach wieder frei", pruefen(a) == "")
    open(os.path.join(a, "notiz"), "w").write("n\n"); g(a, "add", "notiz")
    soll("veralteter Index erkannt (f, werk), eigene Notiz nicht", sorted(pruefen(a, "veraltet")) == ["f", "werk"], repr(pruefen(a, "veraltet")))
    open(os.path.join(a, "eigen"), "w").write("e\n"); g(a, "add", "eigen")
    rc = pruefen(a, "auffrischen")
    soll("auffrischen: nichts mehr veraltet", rc == 0 and pruefen(a, "veraltet") == [], repr(rc))
    soll("auffrischen: fremde Dateien auf HEAD, eigene bleiben", lies(a, "f") == "2\n" and lies(a, "werk") == "w\n"
         and lies(a, "notiz") == "n\n" and lies(a, "eigen") == "e\n")
    g(a, "commit", "-q", "--no-verify", "-m", "a: notiz")
    st = g(a, "show", "--name-status", "--format=", "HEAD").stdout.split()
    soll("Commit in der Notizkopie setzt nichts Fremdes zurück", sorted(st) == ["A", "A", "eigen", "notiz"], repr(st))
    # gewollte Änderung, die nicht auf einen alten Stand fällt, gilt nicht als veraltet
    open(os.path.join(a, "f"), "w").write("3\n"); g(a, "add", "f")
    soll("neue eigene Änderung ist nicht veraltet", pruefen(a, "veraltet") == [])
    # eigene Änderung an einer veralteten Datei bleibt stehen und wird genannt
    g(a, "commit", "-q", "--no-verify", "-m", "a: f3")
    g(b, "checkout", "-q", "--ignore-other-worktrees", "-B", "main"); open(os.path.join(b, "werk"), "w").write("w2\n")
    g(b, "commit", "-qam", "b: werk2"); g(b, "checkout", "-q", "--detach")
    open(os.path.join(a, "werk"), "w").write("selbst\n")
    soll("auffrischen lässt selbst Geändertes stehen (Exit 1)", pruefen(a, "auffrischen") == 1 and lies(a, "werk") == "selbst\n")
print("ZWEIG-DOPPELT %s" % ("gut" if not fehler else "%d rot" % fehler))
sys.exit(1 if fehler else 0)
