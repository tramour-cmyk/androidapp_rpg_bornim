# 1732: Stop-Haken (zug-haken.py) hält eine Antwort von Sokrates mit „Votum“ ohne Zeile „Gegengeprüft:“ einmal an.
# Ohne Netz. Aufruf: python3 tools/zug_haken_test.py
import json, os, subprocess, sys, tempfile
HIER = os.path.dirname(os.path.abspath(__file__))
fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else zeige))

tmp = tempfile.mkdtemp()
import shutil
HAKEN = os.path.join(tmp, "zug-haken.py")   # Kopie ohne tools/1727-SCHARF daneben (1943), damit der Test auch an der Umschalt-Kopie gilt
shutil.copy(os.path.join(HIER, "zug-haken.py"), HAKEN)
ENV = dict(os.environ, BORNIM_REGELTREUE=os.path.join(tmp, "z.tsv"), HOME=tmp)
def haken(text, aktiv=False):
    e = {"session_id": "session_T1732", "last_assistant_message": text, "stop_hook_active": aktiv}
    p = subprocess.run([sys.executable, HAKEN], input=json.dumps(e), capture_output=True, text=True, env=ENV)
    return p.stdout.strip()

S = "**Sokrates** [22.11., 13:20] "
a = haken(S + "Votum: Weg B, weil billiger.")
soll("Sokrates, Votum ohne Gegengeprüft: hält an", '"block"' in a and "1732" in a, a)
soll("mit Zeile „Gegengeprüft: <Datei>“: durch", haken(S + "Votum: Weg B.\n\nGegengeprüft: docs/entwurf/x-pruefung.md; Befund 1 stimmt.") == "")
soll("Zeile fett „**Gegengeprüft:** …“: durch", haken(S + "Votum: B.\n**Gegengeprüft:** docs/x.md") == "")
soll("„Gegengeprüft: entfällt, …“: durch", haken(S + "Votum Sokrates im Titel.\nGegengeprüft: entfällt, kein Vorschlag") == "")
soll("Gegengeprüft nur im Fließtext, nicht als Zeile: hält an", '"block"' in haken(S + "Votum B, Gegengeprüft: x.md"))
soll("Votum nur im Zitat oder Code: durch", haken(S + "Titel „Votum Sokrates“ steht in `1621`.") == "")
soll("ohne Votum: durch", haken(S + "1931 Kern Büro V6 fertig.") == "")
soll("andere Rolle mit Votum: durch", haken("**Perikles** [22.11., 13:20] Votum: B.") == "")
soll("zweites Beenden: durch (keine Schleife)", haken(S + "Votum: B.", aktiv=True) == "")

# 1943: mit tools/1727-SCHARF schweigt der Haken (Gegenprüfen nur für den Umbau 1727)
sys.path.insert(0, HIER)
import importlib.util
_sp = importlib.util.spec_from_file_location("zug_haken", os.path.join(HIER, "zug-haken.py")); zh = importlib.util.module_from_spec(_sp); _sp.loader.exec_module(zh)
soll("1943: scharf: schweigt", zh.votum_ohne_gegenpruefung(S + "Votum: B.", scharf=True) is None)
soll("1943: nicht scharf: hält an", zh.votum_ohne_gegenpruefung(S + "Votum: B.", scharf=False) is not None)
soll("1943: Schalter ist tools/1727-SCHARF", zh.SCHARF == os.path.join(HIER, "1727-SCHARF"))

print("zug_haken_test: %s" % ("alles grün" if not fehl else "%d FEHL" % fehl))
sys.exit(1 if fehl else 0)
