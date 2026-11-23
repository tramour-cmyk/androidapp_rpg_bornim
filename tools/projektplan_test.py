# 1860: projektplan.py ohne Wochenziel, Themenblöcke in der Zeilenfolge von chefsache/themenbloecke.md, Summe gleich Meilenstein. Aufruf: python3 tools/projektplan_test.py
import io, os, re, sys, tempfile, contextlib
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); import startbar, projektplan

FEHL = 0
def soll(name, ok, ist=""):
    global FEHL; FEHL += not ok; print(("ok  " if ok else "FEHL"), name, "" if ok else ist)

A = tempfile.mkdtemp(); os.makedirs(os.path.join(A, "chefsache"))
open(os.path.join(A, "chefsache", "themenbloecke.md"), "w").write(
    "# Themenblöcke\n\n| Nr. | Themenblock | Fachprofil | Kapitel 1 | ruht bis | Bereiche | Vorgänge |\n|---|---|---|---|---|---|---|\n"
    "| 6 | Technik, Leistung, Build | Technik | ja | – | E Technik | – |\n| 2 | Kampf (Ablauf) | Kampf | ja | – | E Kampf | – |\n"
    "| 4 | Kataloge | Kataloge | ja | – | – | 458 |\n")
soll("Blöcke in Zeilenfolge, Klammer weg, Übriges zuletzt", projektplan.bloecke(A) == [("6", "Technik, Leistung, Build"), ("2", "Kampf"), ("4", "Kataloge"), ("9", "Übriges")], projektplan.bloecke(A))
startbar.DOCS = A
zs = [dict(nr="1484", bereich="E Technik", kl="M", wort="startbar"), dict(nr="12", bereich="E Kampf", kl="K", wort="ruht"),
      dict(nr="458.3", bereich="E Figuren", kl="M", wort="gebaut"), dict(nr="77", bereich="E Sonst", kl="K", wort="startbar"),
      dict(nr="900", bereich="M Markt", kl="M", wort="startbar")]
startbar.zeilen_liste = lambda: zs
projektplan.archiv_kosten = lambda: {}
projektplan.teilprojekte = lambda offen: []
f = io.StringIO()
with contextlib.redirect_stdout(f): projektplan.main()
aus = f.getvalue()
soll("kein Wochenziel", "Wochenziel" not in aus and "Perikles" not in aus, aus)
teil = aus.split("Themenblock für Kapitel 1")[1]
reihe = re.findall(r"^\| (\d+) ", teil, re.M)
soll("Themenblöcke in Zeilenfolge, Unternummer zum Block der Nummer, Übriges", reihe == ["6", "2", "4", "9"], reihe)
k1 = re.search(r"^\| Kapitel 1 fertig \| (\d+) ", aus, re.M)
summe = sum(int(x) for x in re.findall(r"^\| \d+ [^|]+\| (\d+) ", teil, re.M))
soll("Summe der Blöcke = Meilenstein Kapitel 1", k1 and int(k1.group(1)) == summe == 4, (k1 and k1.group(1), summe))
print("projektplan_test: " + ("alles grün" if not FEHL else "%d FEHL" % FEHL))
sys.exit(1 if FEHL else 0)
