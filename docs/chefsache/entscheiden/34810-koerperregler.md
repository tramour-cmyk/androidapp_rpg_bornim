# 348.10 · Körperregler je Figur · Sokrates · 25.10., 16:36

**Frage** (Chef 16:33 zu Leute Entwurf 1): Bizeps, Bierbauch, große Brust, starke Oberschenkel mit dünnen Waden: geht das über Parameter oder braucht es je Figur ein neues Modell?

**Votum:** ja, Tom gibt in der nächsten Leute-Runde fünf bis sechs Einzelregler (Brust, Bauch, Oberarm, Unterarm, Oberschenkel, Wade; links/rechts getrennt möglich) nach `leute.json`; benutzt nur, wo der Charakter es braucht, und deutlich übertrieben.

**Berührt:** Team Tom (348.6, `tools/blender348/v3/held3.py`, `leute.json`); Jerry nur, wenn Menschenähnliche (Monster) dieselben Regler wollen.

## Begründung

- Kein neues Modell nötig: `held3.py` baut jede Figur aus einem Gelenkgraph mit Umfang je Punkt (Becken, Taille, Bauch, Brust, Schulter, Oberarm, Ellbogen, Unterarm, Hüfte, Oberschenkel, Knie, Wade, Knöchel); Haut, Kleidung und Knochengerüst entstehen daraus und passen sich an.
- Heute nur Statur in vier Stufen für den ganzen Körper (schlank 0,84, mittel 1, kräftig 1,2, zwerg 1,36), dazu Geschlecht, Größe, Kind, Kleidung, Farben, Bart, Haar, Alter, Gesichtswerte.
- Aufwand etwa 20 Zeilen; Bewegungen unverändert.

## Stärkstes Gegenargument

Auf dem Handy sind die Figuren klein: Tom sah in Runde 2 ±10 % Statur nicht, erst +20/−16 %. Feine Unterschiede (dünne Waden) sieht man auf der Gebietskarte nicht, nur im Dialogbild oder am Kampfort; ein Bierbauch wirkt erst bei etwa +40 %. Darum Regler nur sparsam und kräftig einsetzen.

## Folgerung

„ja“: Zeile an Tom (348.6, nächste Leute-Runde). „nein“ oder „noch nicht“: bleibt bei vier Staturen.
