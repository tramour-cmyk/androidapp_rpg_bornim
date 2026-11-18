# Tom, Jerry und Spike · Build 300 · Sammelbuild: Bildrate 30 und Messung, Welt in Zellen, Grafik Hoch und Neuaufbau nach der Wahl, Goblins, Teich, Wenden · [PR 221](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/221)
E Technik · Spike (Handy 1270.6, 1484a, 1669, 1670, 1645; Bild 1669, 1630), Jerry (Handy 760; Bild 1566, Film 1664; ohne Prüfpunkt 455.2, 1652, 1698), Tom (Film 1406; zur Kenntnis 1663) · 18.11., 16:25 · APK folgt

Sammelbuild aus `main` mit `claude/spike-1270.6-messbuild` (1270.6 samt 1645), `claude/spike-1630-hoehlenlicht` (1630), `claude/spike-1484a-zellen` (1484a, Vorentscheid Sammelbuild), 1670 (1670a A, auf dem Buildzweig), `claude/jerry-1664-goblin-gleiten` (1664, mit 844), `claude/jerry-1566-hoehlenwasser` (1566, Rückläufer t298.5), `claude/jerry-455-2-groesse` (455.2, nur Blender-Bauskripte und Größenfilm), `claude/jerry-1652-osric` (1652, nur Prüfwerkzeug), `claude/tom-1406-wenden` (1406), `claude/tom-1663-wirkung` (1663, am Bild gebilligt 14:42). Nicht dabei: 458.3, 1619, 1621 (Bild offen), 1613 (Termin 21.11.).

Zur Kenntnis, ohne Prüfpunkt: Beutel und Fenster eines Tranks zeigen die Wirkung wie im Laden (1663).

Bekannt, schon gemeldet, noch drin: Streitkolben und Kriegshammer haben am Helden noch kein Modell (1665, wartet auf 458.3).

Verglichen (alt gegen neu): Einmessen in Build 299 (A56 auf Niedrig bei 59 Bilder/s, Gerätetext 14:22); Wald 9/12 und 11/19 vor und nach den Zellen (Bilder 1484a, gebilligt); alt `WorldScreen.kt` 2706, `MapLight.kt` 383 (Höhle immer dunkel, 1630).

Ein Weg: Spiel fortsetzen, die Einmess-Blende kommt einmal (300.1), Flüsterwald und Wald messen (300.2, 300.3), Grafik auf Hoch und Höhle (300.4), Probekampf und zurück (300.5). Bilder und Filme (300.6–300.10) kommen einzeln auf Telegram.

Im Bau geprüft: Bildrate fest 30, Ziel des Einmessens nach dem Takt, alte Messung gilt nicht (1270.6, `grafik_698`); Neuaufbau nach der Grafikwahl (1670, `grafik_698`); Schattenkarte nach dem Kampf wie die Grafikstufe (1645, `grafik_698`); Zellen und Durchsicht nahe am Helden (1484a, `zellen_1484a`); Tusche nach Fackeln in der Höhle auch am Tag (1630, `funke_677`); Goblinhieb mit Gehbewegung (1664, `hieb_844`); Teich ohne Eigenlicht (1566, `teich_1566`); Wende ab 135 Grad mit Turn180 (1406, `wende180_1406`); Wirkung in Laden, Beutel und Fenster (1663, `laden_582`).

| # | Team | Nr. | Art | Wo und wie | Passt | Falsch |
|---|---|---|---|---|---|---|
| 300.1 | Spike | 1270.6 | Handy | Spiel fortsetzen: die Einmess-Blende „Die Feder wird angesetzt.“ kommt einmal; danach Testmenü → Bildrate an, die Zeile „Stufe …, 3D …, Takt 30, Renderer …“ ablesen und „Kopieren“ | auf dem A56 Stufe Mittel oder Hoch, Takt 30 | wieder Niedrig, Takt nicht 30, oder die Blende kommt bei jedem Start |
| 300.2 | Spike | 1270.6 | Handy | Zeile 300.2 → „Lage herstellen“ (Tiefer Flüsterwald 9/12, Mittag), Bildrate „Kopieren“; Testmenü → „3D halb“ an, wieder „Kopieren“; „Renderer“ auf Kompatibilität, App neu starten, gleiche Lage, „Kopieren“, Renderer zurück auf Mobile. Tablet wahlweise | drei Messzeilen kopiert, mit „3D 50 %“ und „Renderer Kompatibilität“ darin | Absturz, oder „3D halb“ bzw. Renderer ändert nichts in der Zeile |
| 300.3 | Spike | 1484a | Handy | Zeile 300.3 → „Lage herstellen“ (Wald 11/19, Mittag), Testmenü → „Takt“ auf frei, ein paar Schritte gehen, Bildrate „Kopieren“ | am A56 über 31 Bilder/s (Grundwert Wald, `LISTE-TESTGERAETE.md`) | 31 Bilder/s oder weniger |
| 300.4 | Spike | 1670, 1669 | Handy | Menü → System → „Grafik“ kurz antippen, bis „Hoch“ steht, Menü schließen; dann Zeile 300.4 → „Lage herstellen“ (Höhle am Mittag, Vorräte), Fackel anlegen, zur Halle gehen, Bildrate „Kopieren“ | nach dem Schließen blendet das Bild kurz ab und der Ort baut sich neu, ohne Neustart; Messzeile „Stufe Hoch“, in der Höhle 30 Bilder/s | kein Abblenden und erst nach Neustart anders, oder in der Höhle unter 25 Bilder/s |
| 300.5 | Spike | 1645 | Handy | Bildrate an der Stelle aus 300.4 merken; Zeile 300.5 → „Lage herstellen“ (Probekampf gegen Goblins), Kampf beenden, zurück in die Welt, Bildrate ablesen | Bilder/s wie vor dem Kampf | nach dem Kampf deutlich weniger Bilder/s |
| 300.6 | Spike | 1669, 1630 | Bild | Höhle am Mittag, Grafik Hoch, Held mit Fackel und Leuchtfunke im Gang; Spielkamera, Handygröße | Fackeln glühen, Wände werfen Schatten, Tuschelinien folgen dem Fackellicht | kein Glühen, keine Schatten, Linien wie bei Tageslicht |
| 300.7 | Spike | 1669 | Bild | Dorf am Brunnen, 20 Uhr, Grafik Hoch; Spielkamera, Handygröße | Rauch aus den Schornsteinen, Lichtinseln unter den Lampen | kein Rauch, keine Lichtinseln |
| 300.8 | Jerry | 1566 | Bild | Blutzahnhöhle, Teich unten links ohne Licht in der Nähe, alt (Build 298) gegen neu [Bild von 18.11., 16:35](https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/bilder/2026-11/18-1634-t300.8-Jerry.png) | der Teich ist dunkel wie der Boden | der Teich leuchtet hell türkis |
| 300.9 | Jerry | 1664, 1669 | Film | Probekampf gegen Goblins, Grafik Hoch, bis 15 s [Film von 18.11., 18:11](https://cdn.jsdelivr.net/gh/tramour-cmyk/androidapp_rpg_bornim@film/20261118-181135-t300.9/2026-11/18-1811-t300.9-Jerry.mp4) | Goblins gehen mit Schritten heran und schlagen zu; Nebel und Staub am Kampfort, Treffer mit Effekt | Goblins gleiten, kein Nebel, kein Treffereffekt |
| 300.10 | Tom | 1406 | Film | Dorf am Schlagbaum, Jorin dreht am Ende seines Wegs um, bis 15 s | eine halbe Drehung in einem Zug mit Schritten | zwei Viertelwenden oder Rutschen auf der Stelle |
| 300.11 | Jerry | 760 | Handy | Rückläufer t298.7: Zeile 300.11 → „Lage herstellen“ (Probekampf Wölfe, ein Wolf springt dich sicher an); auf „Anspringen!“ warten | trifft der Sprung, landet der Wolf am Helden und seine Zähne sind am Körper, wenn das Blut spritzt; dann zurück auf seinen Platz | er landet zu kurz, die Zähne bleiben vor dem Helden |

## Lagen

- 300.2: ort=deep_forest:9:12:DOWN uhr=12:00
- 300.3: ort=forest:11:19:DOWN uhr=12:00
- 300.4: station=Krogg uhr=12:00 vorraete
- 300.5: probe=GOBLINS
- 300.11: probe=WOLVES zug=pounce

Gegengelesen: Sokrates 18.11., 16:18 (zuerst die Art, dann der Inhalt; Chef 15:48 zu t299, 1672). 300.1 stimmt (Ablauf und Messung am Gerät). 300.2 stimmt. 300.3 Einwand: Handy nur für die Bildrate; „Bäume durchsichtig, keine Lücken“ ist Aussehen, als Bild (oder auf das gebilligte Bild 1484a verweisen) aus Passt/Falsch streichen. 300.4 Einwand: Handy nur für „Bild flüssig bei Hoch in der Höhle“ (Bildrate kopieren); Glühen, Schatten, Tuschelinien sind Aussehen → Bild an den Chef. 300.5 Einwand: Aussehen → Bild (1673). 300.6 Einwand: Gehbewegung, Nebel, Treffereffekt sind Bewegung → Film (bis 15 s), keine Handyzeile. 300.7 stimmt. 300.8 Einwand: Aussehen → Bild (1673). 300.9 Einwand: Wende ist Bewegung → Film. 300.10 Einwand: Chef hat 1663 am Bild gebilligt (14:42, Archiv) → keine Handyzeile, höchstens „Kleinkram“ zur Kenntnis. Kopf: Einwand, „Grafikwahl … Art der Abhilfe offen“ ist überholt, 1670a A (Chef 15:37): Ort hinter der Blende neu laden. Nach den Einwänden echte Handypunkte: 300.1, 300.2, 300.3, 300.4, 300.7 (5, Bitte zulässig).
Einwände eingearbeitet (Spike 18.11., 16:25): Aussehen und Bewegung als Bild oder Film (300.6–300.10, alte Nummern in Sokrates' Zeile: 300.4 → 300.4 und 300.6, 300.5 → 300.8, 300.6 → 300.9, 300.7 → 300.5, 300.8 → 300.7, 300.9 → 300.10), 1663 zur Kenntnis; 1670 (1670a A) gebaut und in 300.4 geprüft.
