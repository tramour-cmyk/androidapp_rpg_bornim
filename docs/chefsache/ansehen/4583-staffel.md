# 458.3 · Waffenformen nach Stufe und Seltenheit · Spike · 02.11., 06:5x

[Film von 02.11., 06:52](https://cdn.jsdelivr.net/gh/tramour-cmyk/androidapp_rpg_bornim@bilder/2026-11/02-0652-458.3-Spike.mp4) (eingetragen von meldung.sh, Spike)

Film per Telegram (44 s, Hochformat): 18 Waffenarten im Raster 3 × 6, drehend, wie im Kampf gezeichnet (Toon, Tusche nach Licht, Schatten). Teil 1 (0–20 s) zählt Stufe 1 bis 20 hoch, jede Art wechselt auf die Form, die ab dieser Stufe gilt (alle gewöhnlich). Teil 2 (20–32 s): die Formen von Stufe 1 durch die sechs Seltenheiten. Teil 3 (32–44 s): die Formen von Stufe 20 durch die sechs Seltenheiten. Alle Stücke sind auf Zellhöhe gebracht; die Länge am Helden setzt das Spiel (417). Ablauf `spike-probe-4583.yml`, Lauf 41395186552 (Probelauf 2 von 2), Zweig `claude/spike-458-3-staffel`.

## Staffel je Waffenart (Archiv 458.3: schlicht unten, aufwendig oben)

Anker ist am schlichtesten (wenige Flächen, eine Farbe je Teil), Avramania mittel, Omie fein bemalt. Danach die Reihenfolge. Die Stufen stehen nur in der Datendatei (`tools/gegenstaende/gegenstaende.json`, Spalte `formen`) und sind dort mit einer Zahl zu ändern.

| Waffenart | ab Stufe 1 | Wechsel | Wechsel |
|---|---|---|---|
| Dolch | Anker Dagger | 5: Avramania Dagger | 11: Omie Dagger |
| Kurzschwert | Avramania Shortsword | 8: Omie Shortsword | – |
| Langschwert | Anker Sword | 5: Avramania Arming Sword | 11: Omie Long Sword |
| Krummsäbel | Anker Falchion | 5: Anker Messer | 11: Omie Scimitar |
| Handbeil | Anker Axe | 5: Avramania Handaxe | 11: Omie Hand Axe |
| Streitaxt | Anker Battle Axe | 8: Omie Battle Axe | – |
| Großaxt | Anker Two handed Axe | 5: Anker Bardiche | 11: Omie Greataxe |
| Streitkolben | Anker Mace | 8: Avramania Mace | – |
| Morgenstern | Anker Spiked Club | 5: Anker Spiked Mace | 11: Omie Mace (Stachelkugel) |
| Kriegshammer | Anker Hammer | 8: Omie War Hammer | 15: Omie War Pick |
| Zweihandhammer | Anker Two-Handed Hammer | 8: Anker Warhammer | – |
| Speer | Anker Spear | 5: Avramania Spear | 11: Omie Spear |
| Hellebarde | Anker Halberd | 5: Anker Polearm | 11: Omie Halberd |
| Magierstab | Avramania Staff | 8: Omie Staff Magic | – |
| Kurzbogen | Anker Recurve Bow | 8: Omie Bow | – |
| Langbogen | Anker Long Bow | – (keine zweite im Bestand) | – |
| Armbrust | Anker Crossbow | 8: Omie Crossbow | – |
| Zweihänder | Anker Greatsword | 5: Anker Claymore | 11: Anker Two-Handed Sword |

Wechsel bei 5 liegt noch in Kapitel 1 (Grenze Stufe 6), damit Laden und Beute dort nicht nur eine Form zeigen; der zweite bei 11. Avramania Kurzbogen und Armbrust sind flache Karten (80 Dreiecke) ohne Körper und fallen weg. Nicht im Bestand und darum ohne Staffel: Kampfstab (bleibt unser Netz aus `waffen.py`), Zauberstab, Rapier (Eigenbau). Einzelstücke (Klinge von Bornim, Flüsterklinge, Morgenröte) bekommen ihre eigene Form erst in einer eigenen Runde.

## Seltenheit (dieselbe Form, anderes Material und Zeichen)

Jede Fläche des Pakets bekommt nach ihrer Farbe eine Klasse (Metall, Beschlag, Holz, Leder, Stein und Schmuck) und dann unsere Farbe; die Zeichnung des Pakets (Maserung, Kratzer) bleibt als Helligkeit. Die alten Paketfarben sind damit ganz weg.

| Seltenheit | Material | Zeichen |
|---|---|---|
| gewöhnlich | Eisen, rohes Holz, Rindsleder | schlicht |
| ungewöhnlich | Stahl, gebeiztes Holz | rote Wicklung, geschwärzte Beschläge |
| selten | blanker Stahl, dunkles Holz, Schwarzleder | Messingbeschläge, nachtblauer Stein |
| sehr selten | brünierter Stahl, Schwarzholz | Messing, glimmt violett |
| episch | Schwarzstahl, Ochsenblutleder | Goldbeschläge, glimmt orange |
| göttlich | Silberstahl | Gold, glimmt golden |

Gold erst ab episch (Signatur: Gold einziger Glanz). Glimmen schwach, Klinge leiser als Stein; Runen und Funken kommen mit der Effektprobe 415.

## Geprüft

461 geprüft (Helfer vor dem Versand, Tor 461a): A1 Toon-Stufen ja, A2 Tusche auf der Schattenseite kräftiger ja, A3 Linie auch an den kantigen Anker-Stücken ja, G1 alles im Bild, keine Zelle leer ja, G3 kein gegenderter Text ja. E7 (Formen nach Stufe, Seltenheit über Material und Zeichen, unsere Farben) ist das, worüber du urteilst.

**Bekannte Fehler im Film (Befund Helfer, Ursache gefunden):**
- **Sieben Schwerter stehen auf dem Kopf** (Griff oben): Dolch (Anker, Avramania), Kurzschwert (Avramania), Krummsäbel (Anker Messer), Langschwert (Avramania), Zweihänder (Anker Claymore, Anker Two-Handed Sword). Ursache: Die Lage wurde nach der Metallfläche bestimmt, und Parierstange plus Knauf haben unten mehr Fläche als die schmale Klinge oben. Behoben im Zweig (3905956bf, „Lage zuerst nach dem Griff“), wirkt im nächsten Lauf.
- Einzelne Stiele noch grau oder oliv statt braun: Kurzbogen (Anker Recurve, Wurfarme grau), Speer und Handbeil (Avramania), Hellebarde (Anker Polearm).
- Göttlich: Klingen zum Teil fast reinweiß, kaum Abstufung (Krummsäbel, Kurzschwert, Streitaxt).
- Dünne lange Waffen (Speer, Zweihänder, Langbogen, Hellebarde) sind von der Kante nur ein Strich; die Zellen drehen deshalb versetzt.

**Stärkstes Gegenargument:** Anker unten heißt, dass der Spieler in Kapitel 1 die schlichtesten Stücke sieht, gerade dort, wo der erste Eindruck entsteht. Ausweg: Wechsel früher (z. B. Avramania ab 1, Omie ab 7) oder Anker nur bei Arten, die es sonst nicht gibt.

**Zu sagen:** „Staffel so“, oder je Art eine Änderung (z. B. „Dolch Omie ab 7“, „Morgenstern als Flegel“); zur Seltenheit „so“ oder welche Stufe anders aussehen soll. Offen außerdem: ersetzt die Staffel unsere Netze aus `waffen.py` (Dolch, Kurzschwert, Langschwert, Krummsäbel, Handbeil, Speer, Kurzbogen), wie hier vorgeschlagen?
