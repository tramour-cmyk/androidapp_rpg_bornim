# Technik · Build 301 · Höhlenwasser · PR folgt
E Welt · Technik (Mara), Welt (Silke: 1566) · 23.11., 07:58 · APK folgt

Build 301 aus `main` mit `claude/emil-1566-hoehlenwasser` bis 209997b5a, nur 1566 (Auftrag Sokrates 23.11., 07:50, keine weiteren Zweige). Vier Prüfpunkte zu 1566 (Sokrates 08:05, übermittelt vom Disponenten 08:06).

Verglichen (alt gegen neu): Blutzahnhöhle, Teich in vier Kameradrehungen, oben alt, unten neu (`docs/chefsache/bilder/1566-hoehlenwasser-drehungen.webp`, Mobile/Vulkan, Kit).

Im Bau geprüft: Teich ohne Eigenlicht (1566, `teich_1566`).

Fackel: `neben=` wirkt nur im Probekampf (`testmodus.gd` 784, `lage_probe`); in der Welt legt der Chef sie im Weg ab (Schritt in 301.1) und für 301.4 wieder an. „Nie gesehen“ stellt die Lage her (`unerkundet=cave`, `testmodus.gd` 922). Schwarz wird das Wasser, wo die Nebelkarte schwarz ist: nie gesehen oder gesehen außer Sicht (209997b5a, `wasser_kit.gdshaderinc`).

Ein Weg: über Build 300 installieren; Menü → System → Grafik auf Mittel; Zeile 301.1 → „Lage herstellen“, Fackel ablegen, 301.1 am Startpunkt, 301.2 und 301.3 an der dunklen Stelle 7/13, Fackel anlegen, 301.4 auf dem Rückweg.

| # | Team | Nr. | Art | Wo und wie | Passt | Falsch |
|---|---|---|---|---|---|---|
| 301.1 | Welt | 1566 | Handy | Grafik Mittel (Menü → System → Grafik auf Mittel). Zeile 301.1 → „Lage herstellen“ (Blutzahnhöhle, Westflügel 2/11, Höhle unerkundet; die hohe Wand steht zwischen dir und dem Teich, der Teich ist noch nie gesehen). Fackel ablegen: Menü → Ausrüstung → Nebenhand antippen → „Ablegen“ (die Lage gibt Vorräte mit zwei Fackeln; trägt der Held keine, weiter). Am Startpunkt die Kamera zweimal ein Stück drehen (nach links, dann nach rechts) | hinter der Wand ist dort, wo der Teich liegt, alles schwarz; kein Schimmer, kein Glanz | Wasser schimmert oder glänzt durch die Wand, in einer der Drehungen |
| 301.2 | Welt | 1566 | Handy | Von 301.1: drei Schritte nach rechts, durch die Lücke in der Wand nach unten, zwei nach rechts (7/13, vier Felder von beiden Leuchtpilzen); der Teich liegt jetzt in Sicht. Kamera einmal ganz herumdrehen | der Teich ist als Wasserfläche zu sehen, dunkel wie der Boden, in jeder Drehung | der Teich bleibt schwarz wie hinter der Wand, oder er leuchtet hell türkis, in irgendeiner Drehung |
| 301.3 | Welt | 1566 | Handy | Stelle aus 301.2: das Ufer des Teichs ansehen. Eine dünne helle Randlinie ist bekannter Rest (Chef 06:40 „1566 B“, Kür 1979), kein Fehler | höchstens eine dünne Linie am Ufer | ein breiter heller Saum oder die ganze Fläche hell |
| 301.4 | Welt | 1566 | Handy | Fackel anlegen: Menü → Ausrüstung → Nebenhand antippen → die Fackel wählen. Zurück durch die Lücke zum Leuchtpilz am Startpunkt (3/11) | die Leuchtpilze leuchten; um den Helden ist der Boden im Fackelschein hell; Wände und Boden sind zu sehen | Leuchtpilze dunkel, kein Fackelschein, oder Boden und Wände schwarz, wo Licht hinfällt |

## Lagen

- 301.1: station=Krogg ort=cave:2:11:RIGHT ruhig unerkundet=cave vorraete
