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
# 1427: Vergleich aus dem Gedächtnis
H5 = "| 9.5 | Spike | 5 | Handy | in die Höhle gehen | so hell wie in Build 292 | dunkler als vorher |"
H6 = "| 9.6 | Spike | 6 | Handy | zweiter Kampf | nach höchstens 0,7 s bereit, halb so lang wie in Build 287 | über 0,7 s |"
B7 = "| 9.7 | Spike | 7 | Bild | links Build 292, rechts neu, gleich hell wie in Build 292 | a | b |"
soll("Vergleich aus dem Gedächtnis (und nur Aussehen, 1672)", arten(liste("Weiter, 9.5.", H5)), ["aussehen", "vergleich"])
soll("Vergleich mit Messzahl frei", arten(liste("Weiter, 9.6.", H6)), [])
soll("Bild alt gegen neu frei", arten(liste("Weiter, 9.1.", H1, B7)), [])
# 1446: Lücken aus D273.1
H8 = "| 9.8 | Spike | 8 | Handy | Höhle laden | in 2 s da; nicht dunkler als in Build 290 | b |"
H9 = "| 9.9 | Spike | 9 | Handy | Höhle laden | a | langsamer wie in 290 |"
H10 = "| 9.10 | Spike | 10 | Handy | Höhle laden | so flüssig wie gewohnt | b |"
H11 = "| 9.11 | Spike | 11 | Handy | Brücke | Fall wie in 200 m Höhe | b |"
soll("Zahl in anderem Satzteil gibt nicht frei", arten(liste("Weiter, 9.8.", H8)), ["vergleich"])
soll("wie in 290 ohne Build", arten(liste("Weiter, 9.9.", H9)), ["vergleich"])
soll("wie gewohnt", arten(liste("Weiter, 9.10.", H10)), ["vergleich"])
soll("Meterangabe kein Build", arten(liste("Weiter, 9.11.", H11)), [])
G12 = "| 9.12 | Jerry | 12 | Gespräch | Schaden je Treffer | höher als in Build 290 | b |"
soll("Gespräch ebenso", arten(liste("Weiter, 9.1.", H1, G12)), ["vergleich"])
# 1524: Testbitte erst ab 4 Handypunkten
soll("Handypunkte zählen", cp.handypunkte(liste("Weiter, 9.1.", H1, B2, F3, H4, H5)), 2)  # 1672: H5 nur Aussehen
soll("Handy fett nummeriert", cp.handypunkte(liste("Weiter.", H1.replace("| 9.1 |", "| *9.1* |"))), 1)
soll("ohne Spalte Art", cp.handypunkte("# x\n| a | b |\n"), None)
soll("t295 hatte 2", cp.handypunkte(cp.git("show", "3f5e3c23a:docs/chefsache/ansehen/t295-sammelbuild.md")), 2)
# 1672 (Chef 18.11., 15:48 zu t299): Aussehen nie als Handypunkt
A1 = "| 9.13 | Tom | 13 | Handy | Hauptmenü: Wachsoldatin ansehen | Schild ganz, nichts abgeschnitten | Schild im Arm versunken |"
A2 = "| 9.14 | Tom | 14 | Handy | Hauptmenü wie 9.13 | kein heller Streifen zwischen Gürtel und Hand | heller Streifen |"
A3 = "| 9.15 | Tom | 15 | Handy | Ausrüstung: Umhang ablegen, wieder anlegen | nach Ablegen weg, nach Anlegen wieder zu sehen | bleibt sichtbar |"
A4 = "| 9.16 | Tom | 16 | Handy | im Dorf rennen | die Renntaste geht von selbst aus und wird matt | Taste bleibt hell |"
A5 = "| 9.17 | Spike | 17 | Handy | Wald | Bäume durchsichtig, über 31 Bilder/s | unter 31 Bilder/s |"
soll("Aussehen als Handy", arten(liste("Weiter, 9.13.", A1)), ["aussehen"])
soll("„zwischen“ ist kein Wischen", arten(liste("Weiter, 9.14.", A2)), ["aussehen"])
soll("Ablegen ist Bedienen", arten(liste("Weiter, 9.15.", A3)), [])
soll("Taste ist Bedienen", arten(liste("Weiter, 9.16.", A4)), [])
soll("Bildrate ist Gerät", arten(liste("Weiter, 9.17.", A5)), [])
soll("Aussehen zählt nicht als Handypunkt", cp.handypunkte(liste("Weiter.", A1, A2, A3, H1)), 2)
soll("t299 hatte 1 echten Handypunkt", cp.handypunkte(cp.git("show", "a17fb1d96:docs/chefsache/ansehen/t299-schlussbuild.md")), 1)
sys.exit(1 if fehl else 0)
