# 431g · Kleiderschrank mit dem Umhang als erstem Stück: so bauen, für etwa 100 bis 160 $ in drei Stufen?
Tom · 15.11., 12:08 · E Figuren · aus deinem Wort 11:59 („Ja, so machen wir das mit unserem Kleiderschrank“) und 12.11., 17:37 (erst Aufwand vorlegen)
Kurz: Kleidung einmal je Stück anpassen und per Skript auf alle zehn Volkskörper übertragen; der Umhang bekommt eigene federnde Knochen statt der Armgewichte.
Beim Chef, weil: Aussehen

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/a03d5126c (`godot/skripte/heldfigur.gd`, `tools/blender348/v3/held_klassen.py`, `voelker.py`, `kauf_kleid.py`); Godot 4.7.2 am Rechner (Federknochen vorhanden); Befund Umhang 861, Lauf 367
Beim Chef, weil: Aussehen (alle Figuren ändern ihre Kleidung, der Umhang bewegt sich neu)

**Frage:** Heute ist jede Figur ein fertig gebackenes Modell: der Held je Tracht und Geschlecht, jede Person im Dorf einzeln. Kleidung lässt sich nicht tauschen, und das Volk ändert nur die Hautfarbe, nicht den Körper. Der Umhang hängt an den Armknochen und beult darum seitlich aus, sobald die Figur Schild oder Waffe hebt (861, gestoppt 12.11.). Soll ich den Kleiderschrank so bauen wie unten, in drei Stufen mit je einem Film an dich?

**Votum:** „431g A“, dann baue ich Stufe 1 und sende dir den Film des Umhangs; Stufe 2 und 3 erst nach deinem „passt“ zu Stufe 1.

**Berührt:** 431 (Völker, Tom), 861 (Umhang, wartet darauf), 1174 (Körperregler, wartet darauf), Köpfe A (Fach Köpfe, später), Leute des Dorfs (Stufe 3), 698 (Bildrate je Ort).

**Begründung:** Du: „Das kann ja nicht sein, dass wir für jeden Körper alles immer anpassen müssen“ (15.11., 11:58) und „Jeder, dem ich eine Ausrüstung Umhang gebe, kann Umhang tragen. Völlig wurscht, wer es ist“ (12.11., 07:10). Das geht nur, wenn ein Stück einmal angepasst und dann von einem Skript auf jeden Körper gebracht wird, und wenn der Umhang nicht mehr an den Armen hängt.

**Sachverhalt:**
- Held: ein Modell je Tracht und Geschlecht (`held_klassen.py`: Wache, Robe, Kloster, Wald, Bauer, je Mann und Frau), Leute je Person (`held_L_<id>`). Kleidung ist mit dem Körper verbacken.
- Volk im Spiel: nur Farben (`heldfigur.gd`, „Kennungen der Modelle bleiben“). Die Volkskörper aus 431 (Größe, Kopf, Beine, Schultern, Ohren, Hauer; abgenommen 01.11. und 02.11.) gibt es nur in der Probe `voelker.py`, nicht im Spiel.
- Das Werkzeug zum Übertragen gibt es schon einzeln: `kauf_kleid.py` zieht Kleidung Knochen für Knochen auf einen anderen Körper, drückt sie hinaus, wo er durchsticht, und nimmt die Haut darunter weg; `voelker.py` formt die Volkskörper; `pruef_flecken.py` misst, was durch die Kleidung schimmert.
- Umhang heute: Teil der Tracht Wache aus unserem alten Helden. Ursache der Beule (861, Lauf 367): Umhangecken bis 40 cm unter der Schulter hängen am Schlüsselbein; die Behebung dort senkte den Abstand von 54 auf 21 cm, du sahst links weiter eine Beule.
- Godot 4.7 hat Federknochen (`SpringBoneSimulator3D` mit Kollisionskapseln): ein Umhang mit eigenen Knochen am Rücken schwingt nach und weicht Rumpf, Schild und Rückenwaffe aus. Am Rechner geprüft, dass es die Klassen gibt; am Handy noch nicht gemessen.
- Volk als Formschlüssel auf einem Körper (Vorschlag 12.11.) geht nicht für alle: der Ork steht auf dem Superheld-Körper mit anderem Netz, und der Zwerg braucht kürzere Knochen, sonst knickt das Knie an der Stelle des Menschen. Darum je Volk und Geschlecht ein eigener Körper (zehn), jedes Stück vom Skript zehnmal übertragen; die Statur bleibt Formschlüssel wie heute.

**Auswertung:**
- **A (Empfehlung): drei Stufen, je ein Film.**
  1. Werkzeug und Umhang (2 Sitzungen, etwa 40 bis 60 $, 3 bis 4 Läufe): `kleiderschrank.py` überträgt ein Stück auf die zehn Körper; Umhang neu mit eigener Knochenkette am Rücken, links und rechts gespiegelt gewichtet, Federknochen in Godot mit Kapseln für Rumpf, Schild, Rückenwaffe. Prüfung: Film von hinten, links, rechts, mit Schild und Waffe, auf allen zehn Körpern; Messung „links gleich rechts“ und Abstand zum Körper; Bilder je Sekunde am Handy nicht unter heute.
  2. Spiel setzt zusammen (2 Sitzungen, etwa 40 bis 60 $): Körper des Volks und angezogene Stücke an einem Skelett, Haut unter dem Stück weg; Held in der Erschaffung im echten Volkskörper; die fünf Trachten in Stücke zerlegt (Oberkörper, Beine, Füße, Umhang, Robe, Kopfbedeckung). Prüfpunkt am Handy: Erschaffung je Volk, Umriss im Hauptmenü und auf der Karte.
  3. Leute des Dorfs und Gefährten umziehen (1 bis 2 Sitzungen, etwa 20 bis 40 $), jede Person am Bild alt gegen neu, abgenommene Gesichter bleiben.
  Zusammen etwa 100 bis 160 $; Kauf erst danach, nur für leere Fächer.
- **B: nur den Umhang reparieren** (Federknochen im heutigen Modell der Wache, 1 Sitzung, etwa 20 $). Billiger, aber der nächste Körper braucht wieder Handarbeit, und Völker bleiben Farbe.
- **Stärkstes Gegenargument gegen A:** Aussehen ist bis zum Durchspielen eingefroren (488), und A fasst jede Figur an, auch schon abgenommene Leute. Darum Stufe 3 erst nach deinem Urteil zu Stufe 1 und 2, und jede Person am Bild alt gegen neu. Zweites Risiko: mehr Teile je Figur kosten Zeichenaufrufe; ich füge die Stücke beim Laden zu einem Netz zusammen und messe im Dorf.

**Folgerungen:** Bei A: Tom baut Stufe 1 auf `claude/tom-431-voelker`, Film an dich; 861 wird mit Stufe 1 erledigt oder überholt. Reihenfolge gegen 870.13 (Aufräumen Umzug) sagt Perikles. Bei B: 861 wieder auf, 431 Kleiderschrank ruht.

Antwort: …
