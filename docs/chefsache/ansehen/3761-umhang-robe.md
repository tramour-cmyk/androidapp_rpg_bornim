# 376.1 · Umhang und Robe nachgebessert · Tom · 01.11., 23:0x

[Film von 01.11., 23:03](https://cdn.jsdelivr.net/gh/tramour-cmyk/androidapp_rpg_bornim@bilder/2026-11/01-2303-376.1-Tom.mp4) (eingetragen von meldung.sh, Tom)

[Film von 01.11., 22:18](https://cdn.jsdelivr.net/gh/tramour-cmyk/androidapp_rpg_bornim@bilder/2026-11/01-2218-376.1-Tom.mp4) (eingetragen von meldung.sh, Tom)

**Bitte den Film 23:03 beurteilen; 22:18 ist überholt.** Der Prüfer fand in 22:18 einen roten Streifen hinten auf der Mitte des Umhangs, einen dunklen Fleck auf dem Oberschenkel der Frauenrobe und den Stiefelschaft hinten durch die Robe. Ursache: Umhang und Robe wurden erst nach dem Abwickeln der Textur ausgedünnt, Dreiecke spannten über fremde Bildteile (Umhang 366 Dreiecke mit Rot, jetzt 0). Behoben, Stiefelschaft unter der Robe kürzer. Weitere Befunde aus 22:18 (mittel), nicht behoben: Zacken an den Umhangkanten, Hände weiß, Robe blau wie Plastik, Beschriftung ohne „Normal“ und „Frau“.

Film per Telegram (24 s, Hochformat), wie im Spiel gezeichnet (Toon-Licht, Tusche, Wiese), ohne Waffen; noch kein Build. Ablauf `spike-probe-3761.yml`, Lauf 41352257565 (d8c2e974b), Zweig `claude/spike-376-1-tracht`. Seite 1 Umhang des Wachsoldaten, Seite 2 Robe des Zauberlehrlings; je oben Mann, Mitte Frau (Schlank, Normal, Kräftig), unten Gehen. Ohne Rennen: Rennen A (416.4) kommt mit dem Grundstand 461.

**Ursachen** (nachgestellt mit `pruef_flecken.py`: Strahlen von der Kamera auf die fertige Figur, sechs Bewegungen, neun Blickrichtungen; Zahlen Bildpunkte zu 1 cm, vorher → nachher):
- **Farbstreifen im Umhang:** die hintere Bahn des Wappenrocks stach auf Gesäßhöhe 1–2 cm durch den Umhang. Unter dem Umhang sieht sie niemand: sie fällt weg. Wappenrock im Umhang sichtbar: 10 981 → 1.
- **Flecken in Robe und Umhang:** die Kleidung wurde auf das Dreiecksmaß der alten Figur (6000 für die ganze Figur) abgebaut; Umhang und Robe behielten je rund 450 Dreiecke, ihre zwei Lagen kreuzten sich. Jetzt ohne diesen Abbau, Umhang und Robe gleichmäßig ausgedünnt; die Figur hat 21 000 bis 33 000 Dreiecke (Waldläufer 32 000). Innenseite der Robe sichtbar: Mann 94 407 → 4 527, Frau 107 327 → 8 362.
- **Umhang nicht durchgängig:** beim Anpassen an den Kaufkörper wurden die zwei Lagen an Schultern und Hüfte getrennt verschoben und lagen dann übereinander; jetzt geht der Umhang als Ganzes. Innenseite des Umhangs von hinten: Mann 168 107 → 53 123, Frau 78 361 → 38 488; größter Fleck 1 097 → 503 und 996 → 193.
- **Knie durch die Robe:** die Waldläuferstiefel reichen bis unters Knie und stachen im Gehen 3–5 cm vorn durch die Robe; unter der Robe bleibt nur der Fuß. Stiefel durch die Robe: 12 273 → 1 520 (Rest beim Rennen, wenn der Fuß hinten hochschwingt).

**Stärkstes Gegenargument:** ganz weg ist es nicht: beim Rennen drückt das Bein noch durch den Umhang, und die Innenseite des Umhangs zeigt sich von hinten noch an einzelnen Stellen (ohne Stoffsimulation folgt der Umhang den Knochen); Wachsoldat und Zauberlehrling haben jetzt 21 500 bis 33 300 Dreiecke statt 18 700 (Waldläufer 31 800).

**Zu sagen:** „passt“ oder was anders sein soll.

**Prüferbefund zum Film 23:03 (nach dem Versand, 23:0x):**
- Behoben: roter Streifen hinten im Umhang; Knie, Löcher in Brust und Hüfte der Robe (12,0 s, 18,0 s).
- Bleibt: roter Ärmel schneidet seitlich durch den Umhang (Oberarm, Ellbogen; 3,5 s Profil, 5,0 und 6,0 s Rücken, alle Felder); 6,0 s Frau schlank weißgraues Stück an der rechten Schulter durch den Umhang.
- Bleibt: Stiefel samt Schaft ragt beim Gehen hinten aus der Robe, Saum geht nicht mit (14,0 s, 18,0 s).
- Teils: dunkle Flecken auf Oberschenkel und Saum der Frauenrobe (12,0 s, schlank, normal), keine Treppenkante.
- Hände der Wache weiß, Robe einheitlich blau; Beschriftung ohne „Normal“ und „Frau“ an den Feldern.
- 0,0 s Wache Frau schlank: Kerbe im Kettenhemd neben dem Wappenrock; 14,0 s Robe Frau: Unterarm durch den Gürtel, heller Flicken an der Hüfte. Kein schwarzes Dreieck am Hals gesehen.
