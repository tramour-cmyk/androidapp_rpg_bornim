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
def pruefen(cwd):
    sys.path.insert(0, HIER)
    import importlib.util
    spec = importlib.util.spec_from_file_location("cp", PR); cp = importlib.util.module_from_spec(spec)
    alt = os.getcwd(); os.chdir(cwd)
    try:
        spec.loader.exec_module(cp); return cp.zweig_doppelt()
    finally: os.chdir(alt)
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
    g(b, "checkout", "-q", "--detach")
    soll("nach --detach wieder frei", pruefen(a) == "")
print("ZWEIG-DOPPELT %s" % ("gut" if not fehler else "%d rot" % fehler))
sys.exit(1 if fehler else 0)
