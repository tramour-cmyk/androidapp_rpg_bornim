# 1398: Bild/Film ohne APK-Weg, „Ein Weg“ ohne Bild-/Filmnummer, Handy nur zum Lesen warnt. Aufruf: python3 tools/art_weg_test.py
import importlib.util, os, sys
d = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, d)
spec = importlib.util.spec_from_file_location("cp", os.path.join(d, "commit-pruefung.py")); cp = importlib.util.module_from_spec(spec); spec.loader.exec_module(cp)

fehl = 0
def soll(name, ist, erwartet):
    global fehl; ok = ist == erwartet; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ist)

KOPF = "| # | Team | Nr. | Art | Wo und wie | Passt | Falsch |\n|---|---|---|---|---|---|---|\n"
def liste(weg, *zeilen): return "# x\ny\n\nEin Weg: " + weg + "\n\n" + KOPF + "\n".join(zeilen) + "\n"
def arten(t): return sorted(f[0] for f in cp.art_weg_befunde(t))

H1 = "| 9.1 | Tom | 1 | Handy | im Dorf rennen | a | b |"
B2 = "| 9.2 | Tom | 2 | Bild | Leiste oben mit Plakette [Bild](https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/bilder/x.png) | a | b |"
F3 = "| 9.3 | Tom | 3 | Film | Menü → Held → Reiter „Ausrüstung“, Drehteller | a | b |"
H4 = "| 9.4 | Tom | 4 | Handy | Hauptmenü: Zeile unter dem Zeichen lesen | a | b |"
soll("sauber", arten(liste("Weiter, 9.1. Bilder und Filme (9.2) nur auf Telegram.", H1, B2)), [])
soll("Film mit Menüpfad hält an", arten(liste("Weiter, 9.1.", H1, F3)), ["stop"])
soll("Weg nennt Bild", arten(liste("Weiter, 9.1, dann 9.2.", H1, B2)), ["stop"])
soll("Weg mit Bereich über Bild", arten(liste("Weiter, 9.1 bis 9.4.", H1, B2, H4)), ["stop", "warn"])
soll("Handy lesen warnt", arten(liste("Weiter, 9.4.", H4)), ["warn"])
soll("9.2 nicht in 9.20", arten(liste("Weiter, 9.20.", H1, B2)), [])
sys.exit(1 if fehl else 0)
