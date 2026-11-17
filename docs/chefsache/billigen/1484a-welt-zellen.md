# 1484a · Vorentscheid Welt in Zellen, Durchsicht nur nahe am Helden (Testbuild) billigen?
Sokrates · 18.11., 00:53 · E Technik · Vorentscheid in deiner Nachtvertretung (Chef 18.11., 00:04) zu Spikes Vorlage 17.11., 22:12
Kurz: Spike teilt Dorf und Wald in Stücke von etwa 12 m und rechnet die Durchsicht der Bäume nur nahe am Helden; Aussehen gleich; erst Testbuild und deine Messung am Tablet, dann `main`.

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/6661a205c (Spikes Messskript `godot/tests/welt_mess_1484.gd`)

**Frage:** Billigst du, dass Spike Weg A in einen Testbuild baut?

**Entschieden:** A. Sag „gebilligt“ oder „zurück“ (dann nichts gebaut, Zweig bleibt liegen) oder „B“ (nur Durchsicht nahe am Helden).

**Berührt:** 1484 (Tablet 10 Bilder/s in der Welt), 1484a; Modellbau `tools/blender348/v3/dorf.py`, Durchsicht `gebiet.gd`; Tom nur Abnahme „sieht gleich aus“.

**Begründung:** Oberste Direktive „ohne technische Fehler“: 10 Bilder/s im Flüsterwald sind ein Fehler. Kein Aussehen, keine Balance, kein Spielcode auf `main` ohne deinen Test; darum in der Vertretung entscheidbar.

**Sachverhalt:** Spikes Messung (Vorlage 22:12, in Git): Welt ein einziges Netz (Wald 444 Tsd. Dreiecke), nur 7–22 % davon im Bild; Zellen sparen 54–57 % der gezeichneten Dreiecke; Durchsicht läuft an allen Bäumen der Karte, kostet am Rechner 16 %. Kampf 25 Bilder/s bei 153 Tsd., Welt 10 bei 2,7 Mio. Dreiecken.

**Auswertung:** Stärkstes Gegenargument (Spike selbst): am Tablet halbierte „Schatten aus“ die Dreiecke, sparte aber nur 12 % Zeit; vielleicht liegt das Tablet nicht an den Dreiecken. Lösung: Prüfpunkt im Testbuild an denselben Stellen zusätzlich mit 3D-Auflösung 50 %; steigt dann die Bildrate stark, liegt es an der Füllrate, und der nächste Schritt ist ein anderer. B allein lässt das große Netz stehen, C ändert das Aussehen. Abgleich: Leitbild nicht berührt (Aussehen gleich), Block 2 Kampf (1605) nicht berührt.

**Folgerungen:** Spike baut A im Zweig, Bilder alt gegen neu an drei Stellen vor dem Build (Tom sieht mit), Testbuild mit Prüfpunkt „Wald 11/19 und Flüsterwald messen, auch mit 3D 50 %, Kopieren“.

**Umgesetzt:** offen (Spike).

**Rückbau:** Zweig nicht zusammenführen.

**Kosten:** etwa eine Sitzung, ein Modellbau (40 Minuten), ein Testbuild.

Antwort:
