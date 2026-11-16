#!/usr/bin/env python3
# 1268.2 (1268 A, Chef 15.11., 10:51: „alle schnellen Tests in einem Godot-Prozess, Ziel halbe Dauer“): „Skripte pruefen“ in godot.yml
# brauchte 2152 s (Lauf 491, 236 Godot-Aufrufe nacheinander; Messung Tom). Ein gemeinsamer Godot-Prozess hieße alle 370 Tests umbauen
# (jeder ist ein eigener SceneTree mit quit()); dasselbe Ziel erreicht der Bauserver mit seinen Kernen: die einfachen Testzeilen laufen
# nebeneinander, wie am Rechner im Logiksatz (logik.py, 155 Tests in 2,5 min).
# Aufruf als erste Zeile des Schritts: [ -n "$PRUEFSATZ" ] || exec env PRUEFSATZ=1 python3 tools/godot/pruefsatz.py "$0"
#  - liest das Skript des Schritts ($0), eine Quelle wie bisher (logik.py liest dieselben Zeilen);
#  - „einfach“ ist eine Zeile zwischen „STUFE=test“ und „909: auf die Messungen nebenher warten“, die genau einen Test startet
#    ([VAR=wert …] timeout …), ohne „|| true“, ohne Shell-Variablen des Skripts (ROT, NEBEN, B …) und ohne „nebenher“;
#  - das übrige Skript läuft unverändert der Reihe nach (bash), die einfachen Zeilen stehen dort als „:“; sie laufen mit so vielen
#    Kernen, wie der Bauserver hat, ab „STUFE=test“ (Import und Vorprüfung fertig), je Test eigenes user:// (XDG_DATA_HOME);
#  - rot nebeneinander: einmal allein wiederholt; grün allein heißt WACKELIG (genannt, nicht rot), rot allein geht nach rot.txt wie
#    eine rote Zeile („test tests/x.gd: …“, ::error::918);
#  - vor der Warteschleife „909“ wartet das Skript, bis alle fertig sind, und zeigt je Test seine Ausgabe und Dauer (PRUEFSATZ …).
import os, re, shutil, signal, subprocess, sys, tempfile, time, threading
from concurrent.futures import ThreadPoolExecutor

UMGEBUNG = {"GITHUB_WORKSPACE", "RUNNER_TEMP", "HOME"}
ZEILE = re.compile(r"^(set -o pipefail; )?([A-Z_][A-Z0-9_]*=\S+ )*timeout \d+ ")
VORN = "STUFE=test"
HINTEN = "909: auf die Messungen nebenher warten"


def einfach(z: str) -> bool:
    s = z.strip()
    if not re.search(r"res://tests/[a-z0-9_]+\.gd", s) or s.startswith("nebenher") or "|| true" in s:
        return False
    befehl = s.split("   #")[0]
    if set(re.findall(r"\$\{?([A-Za-z_]\w*)", befehl)) - UMGEBUNG:
        return False
    return ZEILE.match(s) is not None


def teile(text: str):
    """(Skript für bash, [(Nr, Name, Befehl)]) — Nr = Zeilennummer im Original (für rot.txt)."""
    z = text.split("\n")
    a = next(i for i, l in enumerate(z) if l.strip() == VORN)
    b = next(i for i, l in enumerate(z) if HINTEN in l)
    los = os.path.join(os.environ.get("GITHUB_WORKSPACE", tempfile.gettempdir()), "pruefsatz")
    satz = []
    for i in range(a + 1, b):
        if einfach(z[i]):
            name = re.search(r"res://tests/([a-z0-9_]+)\.gd", z[i]).group(1)
            satz.append((i + 1, name, z[i].strip()))
            z[i] = re.match(r"\s*", z[i]).group(0) + ":   # pruefsatz " + name
    ein = re.match(r"\s*", z[a]).group(0)
    z[a] += "; touch %s/los" % los
    z[b] = ein + "while [ ! -e %s/fertig ]; do sleep 2; done; cat %s/ausgabe.txt\n" % (los, los) + z[b]
    return "\n".join(z), satz, los


def lauf(name: str, befehl: str, cwd: str):
    d = tempfile.mkdtemp(prefix="pruefsatz-")
    env = dict(os.environ, XDG_DATA_HOME=d)
    env.pop("PRUEFSATZ", None)
    t = time.time()
    p = subprocess.Popen(["bash", "-c", "set -o pipefail; " + befehl], cwd=cwd, env=env, stdout=subprocess.PIPE,
                         stderr=subprocess.STDOUT, text=True, start_new_session=True)
    try:
        out, _ = p.communicate(timeout=1800); rc = p.returncode
    except subprocess.TimeoutExpired:
        os.killpg(p.pid, signal.SIGKILL); out, _ = p.communicate(); rc = 124
    shutil.rmtree(d, ignore_errors=True)
    return rc, time.time() - t, out


def satz_laufen(satz, los: str, cwd: str, rot: str):
    try:
        _satz(satz, los, cwd, rot)
    except Exception as e:   # nie hängen lassen: das Skript wartet auf „fertig“
        with open(rot, "a") as f:
            f.write("test pruefsatz.py: %r\n" % e)
        with open(os.path.join(los, "ausgabe.txt"), "a") as f:
            f.write("::error::918 rot (test) pruefsatz.py %r\n" % e)
        open(os.path.join(los, "fertig"), "w").close()


def _satz(satz, los: str, cwd: str, rot: str):
    while not os.path.exists(os.path.join(los, "los")):
        time.sleep(1)
    t0 = time.time()
    # die längsten zuerst (Zeitgrenze der Zeile als Maß), damit die Kerne am Ende gleich voll sind
    folge = sorted(satz, key=lambda s: -int(re.search(r"timeout (\d+)", s[2]).group(1)))
    erg = {}
    with ThreadPoolExecutor(os.cpu_count() or 2) as ex:
        for s, r in zip(folge, ex.map(lambda s: lauf(s[1], s[2], cwd), folge)):
            erg[s[0]] = r
    nebeneinander = time.time() - t0
    zeilen = []
    for nr, name, befehl in satz:   # Ausgabe in der Reihenfolge des Skripts
        rc, s, out = erg[nr]
        if rc != 0:
            rc2, s2, out2 = lauf(name, befehl, cwd)
            if rc2 == 0:
                zeilen.append("WACKELIG %s (nebeneinander Exit %s, allein grün)" % (name, rc))
                rc, s, out = rc2, s2, out2
            else:
                rc, s, out = rc2, s2, out2
                with open(rot, "a") as f:
                    f.write("test tests/%s.gd: %s\n" % (name, befehl[:160]))
                zeilen.append("::error::918 rot (test) tests/%s.gd" % name)
        zeilen.append("── PRUEFSATZ %s Exit %s nach %.0f s" % (name, rc, s))
        zeilen.extend(out.rstrip("\n").split("\n") if out.strip() else [])
    zeilen.append("PRUEFSATZ %d Tests nebeneinander in %.0f s (%d Kerne), Wiederholungen bis %.0f s" %
                  (len(satz), nebeneinander, os.cpu_count() or 2, time.time() - t0))
    with open(os.path.join(los, "ausgabe.txt"), "w") as f:
        f.write("\n".join(zeilen) + "\n")
    open(os.path.join(los, "fertig"), "w").close()


def main():
    quelle = sys.argv[1]
    skript, satz, los = teile(open(quelle, encoding="utf-8").read())
    shutil.rmtree(los, ignore_errors=True)
    os.makedirs(los)
    neu = os.path.join(los, "skript.sh")
    open(neu, "w", encoding="utf-8").write(skript)
    cwd = os.path.join(os.getcwd(), "godot")
    rot = os.path.join(os.environ.get("GITHUB_WORKSPACE", os.getcwd()), "rot.txt")
    print("PRUEFSATZ %d einfache Testzeilen nebeneinander, Rest der Reihe nach" % len(satz), flush=True)
    th = threading.Thread(target=satz_laufen, args=(satz, los, cwd, rot), daemon=True)
    th.start()
    rc = subprocess.run(["bash", "-e", neu]).returncode
    sys.exit(rc)


if __name__ == "__main__":
    main()
