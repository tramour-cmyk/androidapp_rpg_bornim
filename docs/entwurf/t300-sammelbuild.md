# Tom, Jerry und Spike · Build 300 · Sammelbuild: Bildrate 30 und Messung, Welt in Zellen, Grafik Hoch, Goblins, Teich, Wenden, Trankwirkung · PR folgt
E Technik · Spike (Handy 1270.6, 1484a, 1669, 1630, 1645), Jerry (Handy 1664, 1566; ohne Prüfpunkt 455.2), Tom (Handy 1406, 1663) · 18.11., 15:45 · APK folgt

Sammelbuild aus `main` mit `claude/spike-1270.6-messbuild` (1270.6 samt 1645), `claude/spike-1630-hoehlenlicht` (1630), `claude/spike-1484a-zellen` (1484a, Vorentscheid Sammelbuild), `claude/jerry-1664-goblin-gleiten` (1664, mit 844), `claude/jerry-1566-hoehlenwasser` (1566, Rückläufer t298.5), `claude/jerry-455-2-groesse` (455.2, nur Blender-Bauskripte und Größenfilm, ohne Prüfpunkt), `claude/tom-1406-wenden` (1406), `claude/tom-1663-wirkung` (1663). Build 299 ist im Test und bleibt zu. Nicht dabei: 458.3, 1619, 1621 (Zweihändergriff offen), 1613 (Termin 21.11.).

Bekannt, schon gemeldet, noch drin: Grafikwahl wirkt erst am nächsten Ort (1670, Art der Abhilfe offen); Streitkolben und Kriegshammer haben am Helden noch kein Modell (1665, wartet auf 458.3).

Verglichen (alt gegen neu): Einmessen in Build 299 (A56 auf Niedrig bei 59 Bilder/s, Gerätetext 14:22); Wald 9/12 und 11/19 vor und nach den Zellen (Bilder 1484a, `ansehen/1484a-zellen-alt-neu.md`); alt `WorldScreen.kt` 2706, `MapLight.kt` 383 (Höhle immer dunkel, 1630).

Ein Weg: Spiel fortsetzen, die Einmess-Blende kommt einmal (300.1), Wald und Flüsterwald messen (300.2, 300.3), Grafik auf Hoch (300.4–300.7, mit Goblins 300.6 und Teich 300.5), Dorf (300.8, 300.9), Tasche (300.10).

Im Bau geprüft: Bildrate fest 30, Ziel des Einmessens nach dem Takt, alte Messung gilt nicht (1270.6, `grafik_698`); Schattenkarte nach dem Kampf wie die Grafikstufe (1645, `grafik_698`); Zellen und Durchsicht nahe am Helden (1484a, `zellen_1484a`); Tusche nach Fackeln in der Höhle auch am Tag (1630, `funke_677`); Goblinhieb mit Gehbewegung (1664, `hieb_844`); Teich ohne Eigenlicht (1566, `teich_1566`); Wende ab 135 Grad mit Turn180 (1406, `wende180_1406`); Kurzzeile der Wirkung in Laden, Beutel und Fenster (1663, `laden_582`).

| # | Team | Nr. | Art | Wo und wie | Passt | Falsch |
|---|---|---|---|---|---|---|
| 300.1 | Spike | 1270.6 | Handy | Spiel fortsetzen: die Einmess-Blende „Die Feder wird angesetzt.“ kommt einmal; danach Testmenü → Bildrate an, die Zeile „Stufe …, 3D …, Takt 30, Renderer …“ ablesen und „Kopieren“ | auf dem A56 Stufe Mittel oder Hoch, Takt 30, das Bild läuft gleichmäßig | wieder Niedrig, Takt nicht 30, oder die Blende kommt bei jedem Start |
| 300.2 | Spike | 1270.6 | Handy | Zeile 300.2 → „Lage herstellen“ (Tiefer Flüsterwald 9/12, Mittag), Bildrate ablesen und „Kopieren“; Testmenü → „3D halb“ an, wieder „Kopieren“; „Renderer“ auf Kompatibilität, App neu starten, gleiche Lage, „Kopieren“, Renderer zurück auf Mobile. Tablet wahlweise | drei Messzeilen kopiert, mit „3D 50 %“ und „Renderer Kompatibilität“ darin | Absturz, oder „3D halb“ bzw. Renderer ändert nichts in der Zeile |
| 300.3 | Spike | 1484a | Handy | Zeile 300.3 → „Lage herstellen“ (Wald 11/19, Mittag), Testmenü → „Takt“ auf frei, ein paar Schritte zwischen den Bäumen gehen, Bildrate „Kopieren“ | Bäume nahe am Helden und zwischen Held und Kamera durchsichtig, weiter weg deckend, keine Lücken im Wald; am A56 über 31 Bilder/s (Grundwert Wald, `LISTE-TESTGERAETE.md`) | Lücken oder fehlende Bäume, oder 31 Bilder/s oder weniger |
| 300.4 | Spike | 1669, 1630 | Handy | Menü → System → „Grafik“ kurz antippen, bis „Hoch“ steht; Zeile 300.4 → „Lage herstellen“ (Höhle am Mittag, Vorräte); Fackel anlegen, Leuchtfunke trinken, durch den Gang zur Halle gehen | Fackeln an der Wand und deine Fackel glühen, Wände werfen Schatten, die Tuschelinien folgen dem Fackellicht wie nachts, Bild flüssig | kein Glühen, keine Schatten an den Wänden, Linien wie bei Tageslicht |
| 300.5 | Jerry | 1566 | Handy | in derselben Lage zum Teich unten links in der Höhle gehen, Fackel ablegen, dann wieder anlegen | der Teich ist ohne Licht dunkel wie der Boden, nur im Pilz- oder Fackellicht zu sehen | der Teich leuchtet hell türkis im Dunkeln |
| 300.6 | Jerry | 1664 | Handy | Zeile 300.6 → „Lage herstellen“ (Probekampf gegen Goblins, Grafik Hoch bleibt) | die Goblins gehen mit Schritten heran und schlagen zu, Nebel und Staub am Kampfort, Treffer mit Effekt | Goblins gleiten ohne Gehbewegung, oder kein Nebel und kein Treffereffekt |
| 300.7 | Spike | 1645 | Handy | nach dem Kampf aus 300.6 zurück in die Welt, Bildrate ablesen | Bilder/s wie vor dem Kampf | nach dem Kampf deutlich weniger Bilder/s |
| 300.8 | Spike | 1669 | Handy | Zeile 300.8 → „Lage herstellen“ (Dorf am Brunnen, 20 Uhr) | Rauch aus den Schornsteinen, Lichtinseln unter den Lampen, Fenster und Fackeln glühen | kein Rauch, keine Lichtinseln |
| 300.9 | Tom | 1406 | Handy | Zeile 300.9 → „Lage herstellen“ (Dorf am Schlagbaum, Mittag); Jorin vor dir einige Male bis ans Ende seines Wegs zusehen | er dreht sich am Ende in einem Zug mit Schritten um | er dreht sich in zwei Viertelwenden oder rutscht auf der Stelle herum |
| 300.10 | Tom | 1663 | Handy | Menü → Tasche: einen Heiltrank antippen, dann sein Fenster öffnen | in der Zeile und im Fenster steht die Wirkung („heilt … Leben“) | keine Angabe zur Wirkung |

## Lagen

- 300.2: ort=deep_forest:9:12:DOWN uhr=12:00
- 300.3: ort=forest:11:19:DOWN uhr=12:00
- 300.4: station=Krogg uhr=12:00 vorraete
- 300.6: probe=GOBLINS
- 300.8: ort=village:19:13:DOWN uhr=20:00
- 300.9: ort=village:17:5:UP uhr=12:00

Gegengelesen: Sokrates 18.11., 16:18 (zuerst die Art, dann der Inhalt; Chef 15:48 zu t299, 1672). 300.1 stimmt (Ablauf und Messung am Gerät). 300.2 stimmt. 300.3 Einwand: Handy nur für die Bildrate; „Bäume durchsichtig, keine Lücken“ ist Aussehen, als Bild (oder auf das gebilligte Bild 1484a verweisen) aus Passt/Falsch streichen. 300.4 Einwand: Handy nur für „Bild flüssig bei Hoch in der Höhle“ (Bildrate kopieren); Glühen, Schatten, Tuschelinien sind Aussehen → Bild an den Chef. 300.5 Einwand: Aussehen → Bild (1673). 300.6 Einwand: Gehbewegung, Nebel, Treffereffekt sind Bewegung → Film (bis 15 s), keine Handyzeile. 300.7 stimmt. 300.8 Einwand: Aussehen → Bild (1673). 300.9 Einwand: Wende ist Bewegung → Film. 300.10 Einwand: Chef hat 1663 am Bild gebilligt (14:42, Archiv) → keine Handyzeile, höchstens „Kleinkram“ zur Kenntnis. Kopf: Einwand, „Grafikwahl … Art der Abhilfe offen“ ist überholt, 1670a A (Chef 15:37): Ort hinter der Blende neu laden. Nach den Einwänden echte Handypunkte: 300.1, 300.2, 300.3, 300.4, 300.7 (5, Bitte zulässig).
