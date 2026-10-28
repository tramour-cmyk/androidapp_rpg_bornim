# 390a · Tests ohne Bild von der Grenze für Probeläufe ausnehmen?
Tom · 28.10., 09:46 · E Technik
Kurz: Testprogramme aus `godot/tests/` nicht als Probelauf zählen (A) oder so lassen (B)?

**Frage:** Ein Test ohne Bild startet das Spiel unsichtbar und prüft nur, ob die Abläufe stimmen, zum Beispiel ob Jorin nach dem Auftrag den Schlagbaum öffnet. Die Grenze von höchstens zwei Probeläufen je Vorlage (389) zählt solche Tests mit. Sollen Testprogramme frei sein?

**Votum Tom: A** („390a A“).

**Berührt:** 389 (Haken `tools/probelauf.py`), 390 (Funktionen ohne Bild: bei Tom Gespräche, Aufträge, Tagesablauf; bei Jerry Regeln).

## Begründung

Bei 390 entsteht nichts zum Ansehen. Ob die Abläufe in Godot stimmen, zeigt nur ein Test in Godot. Nach zwei Läufen sperrt der Haken jeden weiteren Test, bis zu einer Vorlage mit Bild, Film oder Datei. Eine Vorlage nur zum Freischalten wäre Lärm für dich.

## Sachverhalt (geprüft 28.10., 09:40–09:45)

- Der Haken zählt jeden Start `godot … --path` ohne `--import`, auch unsichtbar (`--headless`); Zählung im Zweig `probelaeufe`.
- Tom hat für 390 beide Läufe um 09:18 verbraucht (Sprachwahl). Gespräche und Aufträge (09:34) und der Tagesablauf (09:39) kamen danach. Godot hat sie noch nie ausgeführt. Geprüft sind nur die Schreibweise des Codes (Prüfprogramm `gdtoolkit`), die Texte gegen das alte Spiel (100 von 100 wortgleich) und der Code durch einen fremden Helfer.
- Der Build prüft vor dem Bauen nur, ob die Skripte laden, nicht ob Gespräche oder Tagesablauf stimmen.
- Jerry testet seine Regeln mit Testprogrammen in `godot/tests/` (Zweig `claude/jerry-348-kampf`); für 390 hat er bisher keinen Lauf gezählt.

## Auswertung

Stärkstes Gegenargument: Unsichtbare Läufe dienen auch der Bildarbeit. Zum Beispiel wurden bei 348.6 die Plätze der Dorftiere mit 4000 unsichtbaren Bildern eingestellt (c9c7363c0). Eine Ausnahme für alle unsichtbaren Läufe würde solche Schleifen wieder unbegrenzt machen, genau das soll 389 verhindern. Darum ist A eng gefasst: frei sind nur Testprogramme aus `godot/tests/`, die mit „bestanden“ oder „nicht bestanden“ enden und kein Bild schreiben. Alles andere zählt weiter.

## Folgerungen

- **A:** Perikles nimmt im Haken nur Läufe eines Testprogramms aus `godot/tests/` aus. Tom und Jerry testen die Funktionen von 390 in Godot, bevor sie in einen Build kommen; Diogenes sieht bei Gelegenheit nach, dass dort nur Tests liegen.
- **B:** so lassen. Die Funktionen von 390 kommen ohne Test in Godot in den Build; Fehler in Gesprächen oder im Tagesablauf zeigen sich erst am Handy.

## Stellungnahme Sokrates (28.10., 10:08)

- **Stärkstes Gegenargument:** Die Grenze „kein Bild“ lässt sich nicht sicher prüfen. Ein Test lädt echten Spielcode, `kampfort_lauf.gd` spielt den ganzen Kampfort durch. Ein Bildbefehl dort entginge jeder Prüfung der Testdatei. Ein Test in `godot/tests/` könnte so doch zur freien Bildschleife werden, und Diogenes sähe es erst „bei Gelegenheit“.
- **Widerspruch zu Entschiedenem:** keiner. Du hast „höchstens zwei Läufe“ gesagt (27.10., 23:55); Anlass waren vier Läufe für Dachziegel, also Bildarbeit. Zu 390 entsteht nichts zum Ansehen. Die Läufe freischalten ginge heute nur über eine Meldung mit Datei, also eine Vorlage nur zum Freischalten, oder über einen Einzelfall wie bei 348.13b. Beides umgeht den Zweck, statt ihm zu dienen. Geprüft: Jerrys Tests (`mars_regeln`, `mars_golden`, `kampfort_lauf`) enden mit bestanden oder nicht bestanden und speichern kein Bild.
- **Kosten:** eine kleine Änderung am Haken durch Perikles. Die Testläufe laufen am Rechner, Sekunden bis wenige Minuten, keine Zeit bei GitHub. Gespart werden Fehler, die sonst erst am Handy auffallen.
- **Empfehlung:** A, so eng, wie Tom es fasst (Testprogramm aus `godot/tests/`, endet mit bestanden oder nicht bestanden, schreibt kein Bild), und der Haken prüft selbst, was er prüfen kann: nur `--headless`, nur `-s res://tests/…`, kein Bildbefehl wie `save_png` in der Testdatei; Diogenes sieht wöchentlich nach statt „bei Gelegenheit“.

Antwort: …
