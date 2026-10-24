# Grafikweg: Engine, Grafikkerne, Modelle (348)

Sokrates, Stand 24.10., 17:56. Ergebnisse der Gespräche mit dem Chef vom 24.10. (16:43–17:55). Entscheidung offen in [Chefsache 348](chefsache/entscheiden/348-engine.md).

## Heute

- Keine Engine: Kotlin, Jetpack Compose. Regeln in `core`, getrennt von der Oberfläche.
- Held, Bäume und Boden werden **auf dem Prozessor Bildpunkt für Bildpunkt aus Formeln** berechnet (Held: Gerüst aus Gelenken, Oberfläche als Formel, `Sdf.kt`, `HeroFigure.kt`) und als fertige Bilder im Speicher gehalten. Die Grafikkerne legen heute nur diese fertigen Bilder auf den Schirm.
- Folgen: 24 s Zeichnen beim ersten Start, Speicher knapp (346: Absturz bei 509 von 512 MB). Höhere Auflösung (128 statt 64 je Kachel, 348.1) braucht viermal so viel Speicher und Zeit, geht so nicht aufs Handy.

## Was eine Engine bringt (libGDX, Godot)

- Fertig eingebaut: Zeichnen über die Grafikkerne, Kamera, Zoom, Bildschirmgrößen, Kachelkarten, vorne und hinten, Skelett-Animation mit Zwischenbildern, flüssiges Drehen, Licht und Schatten, Partikel, Kollision, Berührungen auslösen, Steuerung, Klang.
- **Mit fertigen Modellen rechnet die Engine die Zwischenbilder selbst** (normal 60 je Sekunde): Ruckeln und stufiges Drehen entfallen als eigene Arbeit. Ruckeln nur noch bei zu viel auf einmal, vor allem auf alten Handys (Feineinstellung).
- Unser Look (Tusche, Farben) über einen Zeichenfilter in der Engine; Vorlagen für Umrisslinien und gemalte Flächen gibt es.
- **Bedingung:** Modelle in einer Form, die die Engine kennt (3D mit Skelett, glTF). Unsere Formel-Figuren kann sie nicht lesen.
- Bleibt bei uns: Modelle, Schlüsselhaltungen je Bewegung, Look, Regeln, Werte, Texte, Geschichte.

## Modelle bauen: Blender

- **Geprüft 24.10., 17:54:** Blender 5.2 läuft in unserer Umgebung als Python-Modul, ohne Fenster, nur über Code. Testmodell angelegt, Skelett eingebaut, als glTF gespeichert, Bild gerechnet, in einer Minute. Kostenlos, frei auch für den Verkauf, Animation eingebaut.
- Chef 17:55: nichts kaufen, selbst entwickeln, mit sinnvollen Werkzeugen. Darum keine gekauften Modelle, keine Modell-Generatoren.
- Alternativen, verworfen: eigener Zeichner (nur Bilder, keine bewegbaren Modelle); Grundformen in Godot (Kisten, Mauern, keine Figuren); Klötzchen- oder Maßzeichnungsprogramme (falscher Stil oder nur mit Maus).

## Neues effektiv erstellen: Baukästen

- **Grundkörper Mensch mit einem Skelett:** neue Heldenklasse, neuer Dorfbewohner = Grundkörper plus Maße, Kleidung, Ausrüstung, Farben als kurze Beschreibung im Code. Bewegungen (Gehen, Schlagen, Sterben) einmal je Skelett, jede Figur kann sie sofort.
- **Baukasten Gebäude:** Wände, Dach, Tür, Fenster; neue Hütte = neue Zusammenstellung.
- **Tiere, Gegner:** je Körperbau ein Skelett (Vierbeiner, Spinne).

## Auflösung und Detailtiefe (Chef 18:00: „nittig“, lebendige Welt)

- In 3D gibt es keine feste Auflösung und keine Kachelgröße mehr; drei Stellschrauben, je Modell und je Teil wählbar:
  1. **Form** (Zahl der Flächen): Gesicht, Hände, Waffe fein; Stiefel gröber.
  2. **Oberfläche** (Bilder auf dem Modell, z. B. 512, 1024, 2048 Bildpunkte): Webung des Waffenrocks, Nähte, Ringe des Kettenhemds; dazu Reliefbild, das Ringe und Falten plastisch wirken lässt, ohne Flächen zu kosten.
  3. **Bildschirm**: Die Engine zeichnet in der Auflösung des Handys, also so scharf wie sein Bildschirm.
- **Detailstufen:** von jedem Modell eine feine und eine grobe Fassung; die Engine wechselt selbst je nach Nähe (Kampf nah fein, Gebietskarte grob). Godot kann das automatisch.
- Grenze ist der Speicher der Grafikkerne: Detailbogen je Figur (was fein, was grob), damit eine Szene mit vielen Leuten aufs Handy passt.
- *Gegenargument:* Zu viel Feinheit beißt sich mit dem gezeichneten Look (Tusche, Farbflächen); wie fein, ist eine Stilfrage für Chef und Homer.
- Im Versuch: Held mit Kettenhemd und Waffenrock in zwei Stufen (Kampf nah, Gebietskarte).

## Fehler

- Nimmt die Engine ab: Bewegung, Drehen, Zwischenbilder, Überdeckung, Kollision, Berührungen, Kamera, Bildschirmgrößen (die typischen Fehler heute).
- Bleibt bei uns: Fehler im Modell (Arm knickt falsch). Dagegen eine automatische Prüfung: jedes neue Modell in allen Bewegungen aus acht Richtungen rechnen und durchsehen lassen, bevor der Chef es sieht.
- Bleibt bei uns: Regeln, Werte, Texte.

## Wege und Gegenargumente

- **Grafikkerne ohne Engine:** unsere Formeln für die Grafikkerne neu schreiben (Shader), in der jetzigen App (Android 8 und neuer). Look bleibt, nichts im Speicher, Auflösung frei; Kosten: jede Figur neu, Fehler schwer zu finden, mehr Akku und Wärme.
- **Godot:** bequemste Animation, aber die Regeln müssen neu geschrieben werden (kein Kotlin), dabei entstehen neue Fehler.
- **libGDX:** Regeln in Kotlin bleiben, Animation weniger bequem.
- **Stärkstes Gegenargument insgesamt:** Umbau des ganzen Zeichnens, beide Teams, mehrere Wochen, gegen die oberste Direktive (Kapitel 1 zuerst); und ohne gute Modelle hilft keine Engine.

## Reihenfolge (Empfehlung Sokrates)

1. 348.1/348.2: Vergleichsbild alt und neu, Chef sagt „neu gefällt“ oder „weiter wie bisher“.
2. Versuch Modell: Held aus Grundkörper und Skelett in Blender, in unserem Look, Gehen und Drehen, kurzes Video an den Chef (etwa eine Sitzung). Klärt, ob die Modelle gut genug werden.
3. Fehlermessung 348: Anteil der Chef-Fehler aus zwei Wochen, die eine Engine verhindert hätte; dazu Umzugskosten.
4. Danach Wahl: Engine (libGDX oder Godot), Grafikkerne in der jetzigen App, oder weiter wie bisher.
