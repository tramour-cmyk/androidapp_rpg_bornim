# Prüfwerkzeuge am Rechner (348.6, 348.13)

Alle nehmen den Arbeitsordner `S` als erstes Argument (Pfade in den `.sh` anpassen). Bilder nie selbst ansehen, nur messen; Urteil durch einen Helfer (blind).

- `rechner.sh`: Vulkan in Software, Blender 5.2.3 als Modul (`~/bl`), Godot 4.7.2 (`~/godot`), CC0-Pakete (`~/cc0`), ≈5 Min.
- `bau_alt_neu.sh`: Karten, tex/held3/rig einmal, `dorf.py` alt (Kopie in `$S/alt/blender348`) und neu, je ein Godot-Ordner `$S/godot_alt|neu`; Bilder mit `--tusche=$S/bild_<v>` (xvfb, `--resolution 1080x2340`), dazu `--ohneheld` und `--ohnetusche` für Masken.
- `saecke_paare.py`: Säcke finden über einen Lauf mit magentafarbenen Säcken (`$S/bild_mag`, Farbe in einer Kopie von `dorf.py` gesetzt), blinde Paare alt/neu in `$S/paare`, Schlüssel in `schluessel.txt`.
- `tusche_held.py <S> <bildordner> <band>`: Tusche am Umriss des Helden je Bildseite (links/rechts der Mitte): Tuschepunkte je Randpunkt und mittlere Abdunklung, Morgen gegen Abend.
- `tusche_breite.py <S> <bildordner>`: Breite der äußeren Umrisslinie des Helden links und rechts je Bildzeile (ohne Kopf und Füße), aus Bildern mit magentafarbener Tusche (Kopie von `tusche.gdshader`: `ALPHA = step(0.3, …)`, `ALBEDO` magenta). Genauer als `tusche_held.py`: dort zählt Tusche auf der hellen Lichtseite stärker (Abdunklung über 20), auf dunkler Kleidung im Schatten weniger. Den Schild (Bildseite rechts) mitdenken: Seitenvergleich nur Morgen gegen Abend je Seite.
- `zoom_blatt.py`, `zoom_ausschnitt.py`: Zoom-Blatt (nah, Grundansicht, weit) und Ausschnitt 2,6 m um den Helden (Lage aus dem Bild ohne Helden; weit stimmt die Maske noch nicht).
- `farbfehler.py <neu> <voll> [schwelle] [teile,…]` (mit `~/bl/bin/python -I`): je Fläche des abgebauten Netzes die Albedofarbe gegen das volle Netz (`DREIECKE=0`) am nächsten Punkt derselben Lage; Summe Fläche × Abweichung je Teil, schlimmste Flächen (`BOX=x0,x1,y0,y1,z0,z1` in cm, `ZEILEN=`). Ohne Bild, Sekunden. Kettenhemd (Ringmuster) und Knauf (Kappen im Griff) haben Grundrauschen: `voll voll` zum Vergleich.
