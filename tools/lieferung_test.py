# 1739 (Bauliste 1727, 7.1): vorgang.py fertig leert „wartet auf <Nr>“ bei allen wartenden Zeilen, andere Einträge bleiben.
# Aufruf: python3 tools/lieferung_test.py
import os, subprocess, sys, tempfile
HIER = os.path.dirname(os.path.abspath(__file__))
A = tempfile.mkdtemp()
os.makedirs(os.path.join(A, "docs")); os.makedirs(os.path.join(A, "tools"))
for f in ("vorgang.py", "startbar.py", "bereiche.py", "uebergabe.py", "auftrag.py", "lehren.py", "rueckmeldung.py", "chefwort.py"):
    os.symlink(os.path.join(HIER, f), os.path.join(A, "tools", f))
open(os.path.join(A, "docs", "LISTE-VORGAENGE.md"), "w").write(
    "# Vorgangsliste\n\n| Nr. | Titel | Besitzer | Kl. | Stand | wartet auf | Zweig | Build | Bereich | Kosten |\n|---|---|---|---|---|---|---|---|---|---|\n"
    "| 9001 | Brücke bauen | Tom | M | startbar | – | – | – | E Welt | – |\n"
    "| 9002 | Weg über die Brücke | Tom | M | startbar | 9001 | – | – | E Welt | – |\n"
    "| 9003 | Klang der Brücke | Jerry | M | startbar | 9001, 23.11. | – | – | E Welt | – |\n")
open(os.path.join(A, "docs", "ARBEIT-BETRIEB.md"), "w").write("**Nächste freie Vorgangsnummer: 9100**\n")
p = subprocess.run([sys.executable, os.path.join(A, "tools", "vorgang.py"), "fertig", "9001"], capture_output=True, text=True, cwd=A,
                   env=dict(os.environ, BORNIM_WURZEL=A))
liste = open(os.path.join(A, "docs", "LISTE-VORGAENGE.md")).read()
fehl = 0
for name, ok in [("Aufruf", p.returncode == 0), ("9002 geleert", "| 9002 | Weg über die Brücke | Tom | M | startbar | – |" in liste),
                 ("9003 behält Termin", "| 9003 | Klang der Brücke | Jerry | M | startbar | 23.11. |" in liste),
                 ("9001 erledigt", "| 9001 | Brücke bauen | Tom | M | erledigt |" in liste), ("Meldung", "geleert bei: 9002" in p.stdout)]:
    fehl += not ok; print(("ok  " if ok else "FEHL"), name, "" if ok else p.stdout + p.stderr + liste)
print("lieferung_test: " + ("grün" if not fehl else "%d Fehler" % fehl))
sys.exit(1 if fehl else 0)
