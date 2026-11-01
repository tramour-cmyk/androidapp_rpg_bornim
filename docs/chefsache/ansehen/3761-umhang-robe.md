# 376.1 · Umhang und Robe nachgebessert · Tom · 01.11., 22:2x

[Film von 01.11., 23:03](https://cdn.jsdelivr.net/gh/tramour-cmyk/androidapp_rpg_bornim@bilder/2026-11/01-2303-376.1-Tom.mp4) (eingetragen von meldung.sh, Tom)

[Film von 01.11., 22:18](https://cdn.jsdelivr.net/gh/tramour-cmyk/androidapp_rpg_bornim@bilder/2026-11/01-2218-376.1-Tom.mp4) (eingetragen von meldung.sh, Tom)

**Film 22:18 überholt, bitte nicht beurteilen:** der Prüfer fand danach einen roten Leiterstreifen hinten auf der Mitte des Umhangs (Gesäß bis Saum), einen dunklen Treppenfleck auf dem Oberschenkel der Frauenrobe und den Stiefelschaft hinten durch die Robe. Ursache: die Ausdünnung von Umhang und Robe lief nach dem Abwickeln der Textur, Dreiecke spannten über fremde Bildteile (Umhang 366 Dreiecke mit Rot, jetzt 0). Behoben, Schaft kürzer; zweiter Probelauf (d8c2e974b), neuer Film folgt. Weitere Befunde (mittel): Zacken an den Umhangkanten, Hände weiß, Robe blau wie Plastik, Beschriftung ohne „Normal“ und „Frau“.

Film per Telegram (24 s, Hochformat), wie im Spiel gezeichnet (Toon-Licht, Tusche, Wiese), ohne Waffen; noch kein Build. Ablauf `spike-probe-3761.yml`, Lauf 41346875230, Zweig `claude/spike-376-1-tracht`. Seite 1 Umhang des Wachsoldaten, Seite 2 Robe des Zauberlehrlings; je oben Mann, Mitte Frau (Schlank, Normal, Kräftig), unten Gehen. Ohne Rennen: Rennen A (416.4) kommt mit dem Grundstand 461.

**Ursachen** (nachgestellt mit `pruef_flecken.py`: Strahlen von der Kamera auf die fertige Figur, sechs Bewegungen, neun Blickrichtungen; Zahlen Bildpunkte zu 1 cm, vorher → nachher):
- **Farbstreifen im Umhang:** die hintere Bahn des Wappenrocks stach auf Gesäßhöhe 1–2 cm durch den Umhang. Unter dem Umhang sieht sie niemand: sie fällt weg. Wappenrock im Umhang sichtbar: 10 981 → 1.
- **Flecken in Robe und Umhang:** die Kleidung wurde auf das Dreiecksmaß der alten Figur (6000 für die ganze Figur) abgebaut; Umhang und Robe behielten je rund 450 Dreiecke, ihre zwei Lagen kreuzten sich. Jetzt ohne diesen Abbau, Umhang und Robe gleichmäßig ausgedünnt; die Figur hat 21 000 bis 33 000 Dreiecke (Waldläufer 32 000). Innenseite der Robe sichtbar: Mann 94 407 → 4 527, Frau 107 327 → 8 362.
- **Umhang nicht durchgängig:** beim Anpassen an den Kaufkörper wurden die zwei Lagen an Schultern und Hüfte getrennt verschoben und lagen dann übereinander; jetzt geht der Umhang als Ganzes. Innenseite des Umhangs von hinten: Mann 168 107 → 53 123, Frau 78 361 → 38 488; größter Fleck 1 097 → 503 und 996 → 193.
- **Knie durch die Robe:** die Waldläuferstiefel reichen bis unters Knie und stachen im Gehen 3–5 cm vorn durch die Robe; unter der Robe bleibt nur der Fuß. Stiefel durch die Robe: 12 273 → 1 520 (Rest beim Rennen, wenn der Fuß hinten hochschwingt).

**Stärkstes Gegenargument:** ganz weg ist es nicht: beim Rennen drückt das Bein noch durch den Umhang, und die Innenseite des Umhangs zeigt sich von hinten noch an einzelnen Stellen (ohne Stoffsimulation folgt der Umhang den Knochen); Wachsoldat und Zauberlehrling haben jetzt 21 500 bis 33 300 Dreiecke statt 18 700 (Waldläufer 31 800).

**Zu sagen:** „passt“ oder was anders sein soll.
