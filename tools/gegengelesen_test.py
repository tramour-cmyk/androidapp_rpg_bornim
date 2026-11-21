# 1783 (1739): Commit-Prüfung erkennt „Gegengelesen:“ auch mit Rufnamen; Rolle in Klammern oder Besitzer des Vorgangs;
# nie das eigene Team (881, 1410). Aufruf: python3 tools/gegengelesen_test.py
import importlib.util, io, contextlib, os, shutil, subprocess, sys, tempfile
HIER = os.path.dirname(os.path.abspath(__file__))
PR = os.path.join(HIER, "commit-pruefung.py")
fehler = 0
def soll(name, ok, info=""):
    global fehler
    print(("gut  " if ok else "ROT  ") + name + ("" if ok else "  " + str(info)[-600:]))
    if not ok: fehler += 1
spec = importlib.util.spec_from_file_location("cp", PR); cp = importlib.util.module_from_spec(spec)
with contextlib.redirect_stdout(io.StringIO()): spec.loader.exec_module(cp)
cp._rufname._ZEILEN["liste"] = [{"nr": "9001", "besitzer": "Tom"}, {"nr": "9002", "besitzer": "Sokrates"}]
def rolle(z):
    g = cp.GEGENGELESEN.search(z)
    return g and cp.gegenleser_rolle(g)
soll("Rollenname wie bisher", rolle("Gegengelesen: Sokrates 21.11., 22:00") == "Sokrates")
soll("Rufname mit Rolle in Klammern", rolle("Gegengelesen: Anna (Tom) 21.11., 22:00") == "Tom")
soll("Rufname „(Rolle Jerry; …)“", rolle("**Gegengelesen:** Benno (Rolle Jerry; Team) 21.11., 22:00") == "Jerry")
soll("Rufname mit Vorgang: Besitzer", rolle("Gegengelesen: Carla – 9002: Liste (21.11., 22:00)") == "Sokrates")
soll("Rufname ohne Rolle: erkannt, Rolle offen", cp.GEGENGELESEN.search("Gegengelesen: Anna 21.11., 22:00") and rolle("Gegengelesen: Anna 21.11., 22:00") is None)
soll("fremder Name zählt nicht", cp.GEGENGELESEN.search("Gegengelesen: Bernd 21.11., 22:00") is None)

def lauf(zeilen, kopf="# Tom · Build 999"):
    """Prüfliste t999 nach ansehen/ in einem Wegwerf-Repo stagen, Commit-Prüfung laufen lassen; Meldungen zu 881/1783."""
    with tempfile.TemporaryDirectory() as t:
        subprocess.run(["git", "init", "-q", "-b", "main", t], check=True)
        os.makedirs(os.path.join(t, "tools")); os.makedirs(os.path.join(t, "docs/chefsache/ansehen"))
        for f in os.listdir(HIER):  # die Prüfung lädt weitere Werkzeuge (startbar, namenpruefung …)
            if f.endswith(".py"): shutil.copy(os.path.join(HIER, f), os.path.join(t, "tools", f))
        p = "docs/chefsache/ansehen/t999-probe.md"
        open(os.path.join(t, p), "w").write(kopf + "\nhttps://example.org/apk\n\n" + "\n".join(zeilen) + "\n")
        subprocess.run(["git", "add", p], cwd=t, check=True)
        r = subprocess.run([sys.executable, "tools/commit-pruefung.py"], cwd=t, capture_output=True, text=True)
        return [z for z in r.stderr.splitlines() if "Gegengelesen" in z or "gegengelesen vom eigenen Team" in z]
m = lauf(["Gegengelesen: Anna (Jerry) 21.11., 22:00"])
soll("Rufname anderes Team: frei", m == [], m)
m = lauf(["Gegengelesen: Anna (Tom) 21.11., 22:00"])
soll("Rufname eigenes Team: hält an", any("eigenen Team" in z for z in m), m)
m = lauf(["Gegengelesen: Anna 21.11., 22:00"])
soll("Rufname ohne Rolle: hält an mit Hinweis", any("ohne Rolle" in z for z in m), m)
m = lauf(["Gegengelesen: Tom 21.11., 22:00", "Gegengelesen: Dana (Sokrates) 21.11., 22:05"])
soll("eigenes Team plus Rufname Sokrates: frei (1410)", m == [], m)
m = lauf([])
soll("ohne Zeile: hält an wie bisher", any("fehlt" in z for z in m), m)
print("GEGENGELESEN %s" % ("gut" if not fehler else "%d rot" % fehler))
sys.exit(1 if fehler else 0)
