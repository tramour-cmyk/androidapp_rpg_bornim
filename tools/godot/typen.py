#!/usr/bin/env python3
# 1268.3 (1268 A, Chef 15.11., 10:51: „Warnungen für fehlende Typen als Fehler, zuerst in regeln/ und kampf/“): Sperrklinke statt
# Schalter. Godot zählt je Datei, wo ein Typ fehlt (Warnung UNTYPED_DECLARATION: Variable, Parameter, Rückgabe ohne Typ); heute
# 1422 Stellen in regeln/ und kampf/ (15.11.). Der Schalter im Projekt („als Fehler“) hielte das Spiel an, bis alle getippt sind,
# und ein Umbau aller Stellen träfe jeden offenen Zweig von Jerry; darum wie 1268 A für Textabfragen: abbauen, wo man ohnehin
# anfasst. Die Sperrklinke (godot/tests/typen_1268.json) hält je Datei die Zahl von heute: mehr ist rot, eine neue Datei muss 0
# haben, weniger ist gut (Hinweis „--neu“ senkt die Grenze). Ist eine Datei bei 0, gilt dort „als Fehler“ von selbst.
# Gezählt in einer Kopie des Projekts (Verweise, eigene project.godot mit override.cfg), damit nebenher laufende Tests
# (pruefsatz.py) das echte Projekt unverändert sehen.
# Aufruf im Hauptordner: python3 tools/godot/typen.py [--neu]   -> „TYPEN1268 n Fehler, k Stellen in m Dateien“
import json, os, re, shutil, subprocess, sys, tempfile

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
G = os.path.join(REPO, "godot")
ORDNER = ["regeln", "kampf"]
GRENZE = os.path.join(G, "tests", "typen_1268.json")
GODOT = os.path.expanduser("~/godot/godot")
LADER = """extends SceneTree
func _initialize() -> void:
\tfor o: String in %s:
\t\tfor f: String in DirAccess.get_files_at("res://" + o):
\t\t\tif f.ends_with(".gd"):
\t\t\t\tprint("TYPEN_DATEI ", o, "/", f)
\t\t\t\tvar _s: Resource = ResourceLoader.load("res://%%s/%%s" %% [o, f], "", ResourceLoader.CACHE_MODE_IGNORE)
\tquit(0)
""" % json.dumps(ORDNER)


def zaehlen() -> dict:
    t = tempfile.mkdtemp(prefix="typen-")
    try:
        for n in os.listdir(G):
            if n in ("project.godot", "override.cfg", ".godot"):
                continue
            os.symlink(os.path.join(G, n), os.path.join(t, n))
        shutil.copy(os.path.join(G, "project.godot"), t)
        os.makedirs(os.path.join(t, ".godot"))
        for n in os.listdir(os.path.join(G, ".godot")):
            q = os.path.join(G, ".godot", n)
            if os.path.isdir(q):
                os.symlink(q, os.path.join(t, ".godot", n))
            else:
                shutil.copy(q, os.path.join(t, ".godot", n))
        open(os.path.join(t, "override.cfg"), "w").write("[debug]\ngdscript/warnings/untyped_declaration=2\n")
        open(os.path.join(t, "typen_lader.gd"), "w").write(LADER)
        env = dict(os.environ, XDG_DATA_HOME=tempfile.mkdtemp(prefix="typen-user-"))
        r = subprocess.run([GODOT, "--headless", "--path", t, "-s", "res://typen_lader.gd"], capture_output=True, text=True,
                           timeout=300, env=env)
    finally:
        shutil.rmtree(t, ignore_errors=True)
    aus = r.stdout + r.stderr
    gesehen = set(re.findall(r"TYPEN_DATEI (\S+\.gd)", aus))
    if not gesehen:
        sys.exit("TYPEN1268: keine Datei geladen\n" + aus[-1500:])
    zahl = {d: 0 for d in gesehen}
    stellen = set()
    fehler = re.findall(r"Parse Error: (.*?)\(Warning treated as error\.\)\s*\n\s*at: GDScript::reload \(res://(\S+?\.gd):(\d+)\)", aus)
    for text, datei, zeile in fehler:
        if (datei, zeile, text) in stellen:
            continue   # dieselbe Stelle, weil eine andere Datei sie mit lud
        stellen.add((datei, zeile, text))
        if datei in zahl:
            zahl[datei] += 1
    return zahl


def main():
    zahl = zaehlen()
    if "--neu" in sys.argv:
        json.dump(dict(sorted(zahl.items())), open(GRENZE, "w"), indent=1, ensure_ascii=False)
        print("TYPEN1268 Grenze geschrieben: %d Stellen in %d Dateien (%s)" % (sum(zahl.values()), len(zahl), GRENZE))
        return
    grenze = json.load(open(GRENZE)) if os.path.exists(GRENZE) else {}
    rot = 0
    for d in sorted(zahl):
        g = grenze.get(d, 0)
        if zahl[d] > g:
            rot += 1
            print("FEHLER %s: %d Stellen ohne Typ, erlaubt %d (neue Variable, Parameter oder Rückgabe mit Typ schreiben)" % (d, zahl[d], g))
        elif zahl[d] < g:
            print("HINWEIS %s: %d statt %d Stellen ohne Typ, gut; python3 tools/godot/typen.py --neu senkt die Grenze" % (d, zahl[d], g))
    print("TYPEN1268 %d Fehler, %d Stellen in %d Dateien (Grenze %d)" % (rot, sum(zahl.values()), len(zahl), sum(grenze.values())))
    sys.exit(1 if rot else 0)


if __name__ == "__main__":
    main()
