# 348.13b · Tusche auch nach Fackeln und Feuer, nicht nur nach der Sonne?
Sokrates · 28.10., 07:59 · G Aussehen
Kurz: Soll die Tusche außer der Sonne auch Fackeln, Lagerfeuer und Fenster berücksichtigen?

**Frage:** Heute richtet sich die Tusche nur nach einer Lichtquelle, der Sonne. Fackeln, Lagerfeuer und leuchtende Fenster ändern die Linien nicht. Soll sich die Tusche nahe einer Flamme auch nach ihr richten (Seite zur Flamme dünn, abgewandte kräftig)?

**Votum Sokrates: noch nicht** („348.13b noch nicht“); erst messen, was es auf dem Testhandy kostet.

**Berührt:** 348.13 (Tusche nach Licht), 348.13a (Kampf), 348.6 (Dorf nachts), 388 (Testgerät A22).

## Begründung

Je Bildpunkt müsste der Shader dann mehrere Lichter prüfen. Das A22 des Testers (2 Grafikkerne) schafft schon die alte Fassung kaum; Tom nennt in seiner Auswertung 388 die Tusche als einen der teuren Teile.

## Sachverhalt (Code, 28.10.)

- Dorf (`claude/tom-348-fundament`, `tusche.gdshader`): Tusche nach der Sonnenrichtung (`licht_dir`), seit 26.10.
- Kampf (`claude/jerry-348-kampf`): noch die alte Tusche vom 25.10., nur nach Helligkeit. Die Tusche nach Licht für den Kampf steckt erst in Toms Probe (348.13a, Runde 9 auf dem Morgenblatt) und geht nach deinem Ja an Jerry.
- Keine der beiden Fassungen kennt Punktlichter (Fackel, Feuer, Fenster).

## Auswertung

Stärkstes Gegenargument: Nachts sind Fackeln und Feuer das Licht, das man sieht; eine Tusche, die sie nicht kennt, kann dann falsch wirken. Dagegen: erst Tag und Kampf sauber nach der Sonne, dann nachts an einem Bild prüfen, ob es überhaupt auffällt.

## Folgerungen

- „noch nicht“: Tusche bleibt bei der Sonne; Tom zeigt mit dem Dorf ein Nachtbild, dann neu fragen.
- „ja“: Tom baut Punktlichter in die Tusche (zuerst Dorf), misst die Kosten auf einem schwachen Gerät, legt Bild und Messwert vor.

Antwort: …
