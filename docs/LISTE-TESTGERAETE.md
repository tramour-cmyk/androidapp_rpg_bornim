# Testgeräte und Messwerte

Geräteangaben, die Tester über „Kopieren“ im Systemmenü schicken (388). Je Meldung Datum, Ort im Spiel und Wortlaut der Angaben. Nutzen: die Godot-Fassung muss auf diesen Geräten flüssig laufen (Alt-Fassung ist zu, Archiv 27.10., 22:17).

## Chef, Samsung Galaxy A56 (SM-A566B, obere Mittelklasse; Probe-App 623, Flüsterwald, 08.11., 19:49)

```
Version: 0.348.306
Gerät: SM-A566B
System: Android 37.A566BXXUEDZJ1
Grafik: Samsung Xclipse 540 (Unknown), mobile
Bildschirm: 1080 × 2340, 450 dpi
Speicher: 171 MB
Prozessorkerne: 8
Ort: forest 7/18
Bilder je Sekunde: 31 im Schnitt der letzten 600, langsamstes 1 %: 43 ms
Längste Bildpause seit dem Start: 150 ms (forest 5/17)
Blende: bereit nach –, längste Bildpause –; danach 10 s: längste 32 ms, über 50 ms: 0
Ladezeit je Ort: forest 2551 ms
Kampfort bereit nach: –
Grafikspeicher: 505 MB, Zeichenaufrufe: 347, Dreiecke: 2052k
Rand oben (Kamera): 92, beim Start 92; sichere Fläche [P: (0, 92), S: (1080, 2248)], Fenster (1080, 2340), Ausschnitt [[P: (506.0, 24.0), S: (68.0, 68.0)]]
Schrift: Faktor des Handys 1.00, Dichte 2.812, Breite 384 dp
Letzte Fehlermeldungen: keine
```

Dazu (Chef, Fotos 19:32, 19:36, mit allen Proben an): Dorfbach 33 Bilder/s, Grafik 1793 MB; Flüsterwald am Teich 25 Bilder/s (95 % unter 41,7 ms), Grafik 2006 MB. Lesart (Sokrates): ohne Fehler, keine Pause über 50 ms in 10 s; welche Proben bei diesen Angaben an waren, ist offen (Grafik 505 MB statt 2 GB).

## Chef, A56, Build 286 (0.348.473), Messweg 1270.1, Kompatibilitäts-Renderer (15.11., 12:02–12:09)

Grafik: „ANGLE ((Samsung Xclipse 540) on Vulkan 1.3.304), gl_compatibility“ (am 08.11. „mobile“; Ursache Knopf der Strahlprobe oder Vulkan-Rückfall, offen). Fünf Texte des Chefs, Auszug:

| Schritt | Bilder/s (langsamstes 1 %) | Laden | Zeichenaufrufe, Dreiecke |
|---|---|---|---|
| Dorf 19/16 | 25 (50 ms) | 5106 ms | 551, 2604k |
| Wald 9/10 | 24 (45 ms) | 2651 ms, Blende bereit 8,0 s | 425, 2959k |
| Kampf 1 (Späher, Teich), 106 s | 12 (93 ms), 1244 Bilder über 50 ms | Kampfort bereit 1,2 s | höchstens 222, 351k, 546 MB |
| Kampf 2 (Ratte, Lichtung), 131 s | 12 (93 ms), 1576 Bilder über 50 ms | Kampfort bereit 0,7 s | höchstens 200, 330k, 533 MB |
| Höhle 17/14 | 51 (24 ms) | 2160 ms, Blende bereit 7,2 s | 908, 307k |

Lesart (Spike): Laden des Kampfs kalt 1,2 s, warm 0,7 s, also kein Engpass; der Kampf läuft mit halb so vielen Zeichenaufrufen und einem Achtel der Dreiecke der Welt bei der halben Bildrate, das spricht für teure Bildpunkte (Shader, Nachbearbeitung, Auflösung), nicht für Geometrie. Vergleich im Renderer „mobile“ folgt.

## Chef, A56, Build 286, Messweg 1270.1, Renderer „mobile“ (15.11., 12:20–)

Nach „Renderer wechseln“ (Strahlprobe 415) und Neustart: „Grafik: Samsung Xclipse 540 (Unknown), mobile“; Ursache des Kompatibilitäts-Renderers war also der Knopf, kein Vulkan-Rückfall.

| Schritt | Bilder/s (langsamstes 1 %) | Laden | Zeichenaufrufe, Dreiecke |
|---|---|---|---|
| Höhle 7/16 | 63 (23 ms) | 3390 ms | 394, 188k |
| Wald 10/27 (Text 12:24) | 18 im Schnitt der letzten 600, samt Kampf (65 ms) | 3665 ms, Blende bereit 12,7 s | 362, 2934k, 570 MB |
| Kampf 1 (Skelett, Steinkreis), 63 s | 18 (74 ms), 1089 Bilder über 50 ms, längste Pause 137 ms | Kampfort bereit 3,0 s (kalt) | höchstens 200, 337k, 666 MB |
| Kampf 2 (Fledermaus, Steinkreis), 47 s (Text 12:30) | 20 (66 ms), 588 Bilder über 50 ms, längste Pause 180 ms | Kampfort bereit 0,9 s (warm) | höchstens 184, 2917k (?), 642 MB |

Lesart (Spike): „mobile“ gegen Kompatibilität: Höhle 63 statt 51, Kampf 18 statt 12 Bilder/s, aber kalter Kampfort 3,0 statt 1,2 s und Wald 3,7 statt 2,7 s Laden (Vulkan baut Shader beim ersten Gebrauch, dagegen 1270.3). Kampf bleibt der langsamste Ort: 200 Zeichenaufrufe und 337k Dreiecke bei 18 Bilder/s heißt teure Bildpunkte, nicht Geometrie. Grundwert A56 (A22 entfällt, Chef 12:30): Kampf 18 bis 20 Bilder/s, Kampfort kalt 3,0 s, warm 0,9 s; die 2,1 s Unterschied sind Aufbau beim ersten Gebrauch (Ziel 1270.3), die 0,9 s Laden der Figuren und des Orts (Ziel 1270.2). Offen: Kampf 2 zeigt höchstens 2917k Dreiecke statt 337k, wohl ein Bild mit der Welt dahinter (Blende); nicht nachgestellt.

## Chef, A56, Build 298 (0.348.559), Renderer „mobile“ (18.11., 14:22, nach dem Goblin-Kampf im Wald; 1664)

```
Version: 0.348.559
Gerät: SM-A566B
Grafik: Samsung Xclipse 540 (Unknown), mobile
Speicher: 263 MB
Ort: temple 4/3
Bilder je Sekunde: 59 im Schnitt der letzten 600, langsamstes 1 %: 40 ms
Längste Bildpause seit dem Start: 150 ms (village 28/6)
Blende: bereit nach 6.6 s, längste Bildpause 150 ms; danach 10 s: längste 33 ms, über 50 ms: 0
Ladezeit je Ort: cave 3038 ms, Erschaffung Tipp 314 ms, inn 1185 ms, village 2852 ms, elder 678 ms, shop 743 ms, temple 521 ms, forest 3863 ms
Kampfort bereit nach: 2.3 s
Letzter Kampf (GOBLINS, steinkreis): 42 s, Bilder je Sekunde 40 im Schnitt, langsamstes 1 %: 34 ms, längste Bildpause 142 ms, über 50 ms: 6; höchstens 193 Zeichenaufrufe, 133k Dreiecke, Grafikspeicher 1057 MB
Grafikstufe: Niedrig (Wahl Automatisch), Sonnenschatten 1024 px, 3D 70 %
Grafikspeicher: 951 MB, Zeichenaufrufe: 497, Dreiecke: 156k
Letzte Fehlermeldungen: keine
```
Lesart (Sokrates, ungeprüft am Gerät): Kampf 40 statt 18 bis 20 Bilder/s (Grundwert 15.11.). Auffällig: das Einmessen wählt am A56 „Niedrig“ (3D 70 %, Schatten 1024), also sieht der Chef auf seinem Hauptgerät die schwächste Stufe; Grafikspeicher 951–1057 MB statt 505 MB (08.11.). Beides an Spike zu 1270.6, 1270.7.

## Chef, Samsung Galaxy Tab A9+ (SM-X210, Adreno 619, Android 36), Build 286 (0.348.473), Renderer „mobile“ (16.11., 20:20, „Testspiel auf dem Tablet“; 1484)

Bildschirm 1200 × 1920, 240 dpi, Schrift Faktor 1.09, Breite 800 dp, Rand oben 0; Speicher 197/187 MB; keine Fehlermeldungen. Zwei Texte des Chefs, Auszug:

| Schritt | Bilder/s (langsamstes 1 %) | Laden | Zeichenaufrufe, Dreiecke, Grafik |
|---|---|---|---|
| Dorf 23/7 | 9 (147 ms) | 10638 ms (kalt) | 458, 2531k, 759 MB |
| Wald 6/27 | 10 im Schnitt der letzten 600 (124 ms) | Dorf 5750, Ältester 1800, Wald 6554 ms; Blende bereit 14,7 s, danach 10 s: 25 Bilder über 50 ms | 417, 2940k, 594 MB |
| Kampf (Ratte, Lichtung), 119 s | 10 (117 ms), 1192 Bilder über 50 ms, längste Pause 147 ms | Kampfort bereit 17,8 s | höchstens 146, 359k, 665 MB |

Lesart (Sokrates, nicht nachgestellt): gleicher Build wie A56 am 15.11., dort Dorf 25, Wald 24, Kampf 18–20 („mobile“); das Tablet liegt bei etwa 40 % davon, im Kampf mit 146 Zeichenaufrufen und 359k Dreiecken ebenso langsam wie in der Welt: teure Bildpunkte (Adreno 619 gegen Xclipse 540, ähnlich viele Bildpunkte), wie Spike am A56 las. Kampfort 17,8 s gegen 3,0 s am A56. Build 286 hat noch keine Grafikstufen (698, ab Build 292); erst darauf messen. Der Chef wollte Build 293 installieren (Link Lauf 524, richtig); am Gerät lief trotzdem 286 (1485).

**Build 293 (0.348.524), 16.11., 20:56, Gerätetext des Chefs:** Grafikstufe Automatisch wählt **Niedrig** (Sonnenschatten 1024 px, 3D 70 %). Wald 9/12: 10 Bilder/s im Schnitt der letzten 600, langsamstes 1 % 118 ms, längste Pause 148 ms; Blende danach 10 s: längste 131 ms, 113 über 50 ms; Laden Wald 7409 ms; 409 Zeichenaufrufe, **2997k Dreiecke**, 615 MB Grafik, Speicher 227 MB; keine Fehlermeldungen. Lesart (Sokrates, nicht nachgestellt): gegen Build 286 (Wald 10 Bilder/s, 124 ms, 417 Aufrufe, 2940k Dreiecke) bringt Niedrig mit 3D 70 % (etwa halb so viele Bildpunkte) nichts; damit trägt die Lesart „teure Bildpunkte“ oben nicht. Niedrig senkt weder Dreiecke noch Zeichenaufrufe; Verdacht Dreiecke (3 Mio. auch auf Niedrig) oder Prozessor. Ursache Spike (1484).

**Version 0.348.524 mit „Kampf messen“ (806), 17.11., 21:29, Gerätetext des Chefs („Zu 1484“), Grafikstufe Niedrig (Automatisch), Sonnenschatten 1024 px, 3D 70 %:** Ort forest 11/19, 22 Bilder/s im Schnitt der letzten 600, langsamstes 1 % 108 ms, längste Pause 150 ms (forest 9/12); Blende danach 10 s: längste 114 ms, 13 über 50 ms; Laden Wald 2639 ms; Kampfort bereit 3,6 s. Letzter Kampf (Goblins, Lichtung) 98 s: 25 Bilder/s, langsamstes 1 % 67 ms, längste Pause 148 ms, 132 über 50 ms, höchstens 195 Aufrufe, 153k Dreiecke, 706 MB. Kampf messen (Bild / GPU / CPU in ms, Bilder/s): alles an 44/43/1 (23); ohne unser Gras 44/43/1 (−1 ms, 23); ohne Tusche 47/37/2 (+2, 21); ohne Schatten 56/48/2 (+11, 18); ohne Kantenglättung 47/40/1 (+3, 21); 3D 75 % 36/33/1 (−9, 28); ohne Bäume und Boden 31/28/1 (−13, 32); ohne Bäume 41/40/1 (−4, 25); ohne Boden 33/31/1 (−12, 31); Schattenkarte halb 44/43/1 (0, 23); Schatten bis 20 m 44/43/1 (0, 23); ohne Figuren 42/41/1 (−2, 24); ohne Kampfschirm 42/41/1 (−2, 24); alles aus 11/6/0 (−33, 90). Danach Grafikspeicher 682 MB, 387 Aufrufe, 2680k Dreiecke; Speicher 265 MB; keine Fehlermeldungen.
Dazu 6 Fotos (21:31), Flüsterwald, Leiste „Bilder/s“, Testschalter nacheinander aus: keiner 10 Bilder/s (100,2 ms, 95 % unter 101,4; Grafikzeit 99,1; 204 Aufrufe, 2729k Dreiecke); Tusche 10 (Grafik 95,3; 198, 2717k); + Tusche nach Lampen 10 (96,6 ms; Grafik 95,3; 206, 2717k); + Nebel 11 (96,4 ms; Grafik 94,6; Rechenzeit 2,2; 208, 2729k); + Schatten 11 (94,1 ms; Grafik 86,7; Rechenzeit 2,0; 148, 1376k); Speicher 241 MB, Grafik 625 MB, Bildschirm 90 Hz. Lesart (Sokrates, nicht nachgestellt): die Welt hängt an der Grafik, nicht an Dreiecken, Aufrufen oder den vier Schaltern; im Kampf kostet der Boden am meisten (−12 ms), Schatten aus macht langsamer. Ursache Spike.

## Samsung Galaxy A22 5G (SM-A226B, Mali-G57 MC2, Android 33), Build 286 (0.348.473), Renderer „mobile“ (Chef 16.11., 21:03, Gerätetext ohne Wort; 1484)

Gasthaus (inn 8/2): 18 Bilder/s im Schnitt der letzten 600, langsamstes 1 % 125 ms, längste Pause 145 ms (Erschaffung); Blende danach 10 s: längste 141 ms, 109 über 50 ms; Laden Erschaffung Tipp 793 ms, Gasthaus 3023 ms; 411 Zeichenaufrufe, 381k Dreiecke, 431 MB Grafik, Speicher 138 MB; Bildschirm 1080 × 2408, 450 dpi, Rand oben 65 (Kameraloch); keine Fehlermeldungen. Lesart (Sokrates, nicht nachgestellt): Build 286 hat keine Grafikstufen (erst ab 292). Im kleinen Gasthaus nur 381k Dreiecke, aber etwa so viele Zeichenaufrufe wie das Tablet im Wald (409–417); dort zehnmal so viele Dreiecke. Verdacht neben Dreiecken: Zahl der Zeichenaufrufe (Prozessor) oder Bildpunkte (2,6 Mio. Bildpunkte). Messung auf Build 293 fehlt.

Zweiter Text (21:04), Dorf (village 6/6), gleicher Build: 11 Bilder/s im Schnitt der letzten 184, langsamstes 1 % 142 ms, längste Pause 148 ms; **Blende bereit nach 29,0 s** (längste Pause 145 ms), danach 10 s: längste 148 ms, 8 über 50 ms; **Laden Dorf 14738 ms**, Gasthaus 4846 ms; 470 Zeichenaufrufe, 2650k Dreiecke, 784 MB Grafik, Speicher 193 MB; keine Fehlermeldungen. Lesart: Gasthaus 381k Dreiecke 18 Bilder/s, Dorf 2650k 11 Bilder/s; beides zu langsam, das Dorf lädt fast 15 s und braucht bis zur fertigen Blende 29 s (Tablet Dorf kalt 10,6 s).

## Tester 1, Samsung Galaxy A22 5G (Chef 27.10., 23:25, „Von erwähnten Tester, bei dem es ruckelt“; Ort: Mitte des Marktplatzes)

```
App: 0.1.1037 (1038, release)
Gerät: samsung SM-A226B (a22x)
Android: 13 (API 33)
Prozessor: Mediatek MT6833V/NZA, 8 Kerne, 2× 2,2 GHz + 6× 2,0 GHz, arm64-v8a/armeabi-v7a/armeabi
Grafik: Mali-G57 MC2 (OpenGL ES 3.2 v1.r32p1-01eac0.f20ecd5cf326048879c2d906512e687e)
Arbeitsspeicher: 3631 MB, frei 1284 MB
App-Grenze: 256 MB, groß 512 MB, Heap max 512 MB
Bildschirm: 1080×2408 px, 450 dpi, 384 dp schmal, 90 Hz
Energie: Stromsparen aus, Wärme normal
Blende: bereit nach 7,9 s (erschienen nach 9,8 s, Held 6,8 s, Boden 0,3 s, Leute 7,9 s), längste Bildpause in der Blende 511 ms
Danach 10 s: längste Bildpause 478 ms, über 50 ms: 8
Langsame Bilder während: Held 8, Leute 8, Atmen 8, nichts 0
Speicherbereinigung danach: 55, davon anhaltend 0 (0 ms)
Held ganz gezeichnet nach 41,9 s
Kampf bereit: Eröffnung –, Held –, Gegner –
```

Lesart (Sokrates, ohne Nachstellen): untere Mittelklasse (Mali-G57 mit 2 Kernen, 3,6 GB). Die Speicherbereinigung bremst nicht (0 ms anhaltend). Die Pausen von etwa 0,5 s fallen zusammen mit dem Zeichnen von Held, Leuten und Atmen. Das spricht für teures Zeichnen der Figuren auf der Grafik, nicht für Speichernot. Auswertung und Folgerung für Godot: Tom (388).

## Tester 1, gleiches Gerät, im Starterhaus (Chef 27.10., 23:29)

```
App: 0.1.1037 (1038, release)
Arbeitsspeicher: 3631 MB, frei 1027 MB
Blende: bereit nach 2,2 s (Held 0,0 s, Boden 0,0 s, Leute 2,2 s), längste Bildpause in der Blende 344 ms
Danach 10 s: längste Bildpause 421 ms, über 50 ms: 28
Langsame Bilder während: Atmen 28, Leute 26, Kampf 2, nichts 0
Speicherbereinigung danach: 23, davon anhaltend 0 (0 ms)
Held ganz gezeichnet nach 41,9 s
Kampf bereit: Eröffnung –, Held –, Gegner –
```
(übrige Zeilen wie oben)

Lesart (Sokrates, ohne Nachstellen): Im Haus mehr als dreimal so viele lange Bilder wie auf dem Markt (28 statt 8 in 10 s), alle während „Atmen“ und fast alle während „Leute“; Speicher wieder ohne Bremse. Verdacht: die Atembewegung der Figuren im Innenraum. „Held ganz gezeichnet nach 41,9 s“ ist in beiden Messungen gleich, also wohl ein Wert seit dem Start, nicht je Ort.

## Tester 1, gleiches Gerät, dritte Messung, Flüsterwald nach Kampf mit Skelett (Chef 27.10., 23:35)

```
App: 0.1.1037 (1038, release)
Arbeitsspeicher: 3631 MB, frei 981 MB
Blende: bereit nach 3,5 s (Held 0,1 s, Boden 0,1 s, Leute 3,5 s), längste Bildpause in der Blende 111 ms
Danach 10 s: längste Bildpause 356 ms, über 50 ms: 10
Langsame Bilder während: Leute 10, Atmen 10, nichts 0
Speicherbereinigung danach: 67, davon anhaltend 1 (458 ms)
Held ganz gezeichnet nach 0,4 s (gespeichert)
Kampf bereit: Eröffnung 0,7 s, Held 0,8 s, Gegner 3,6 s
Vorgezeichnet: Held 313/313 (gespeichert), Gegner skeleton 14 (nicht fertig), gewartet 2,1 s, Gegner nahe 9,1 s, Speicher 512 MB, geräumt 0×, belegt jetzt 235 MB
```
(übrige Zeilen wie oben)

Lesart (Sokrates, ohne Nachstellen): wieder alle langen Bilder während „Leute“ und „Atmen“. Neu: einmal hält die Speicherbereinigung das Spiel 458 ms an. Der Kampf ist schnell bereit, nur der Gegner (Skelett) braucht 3,6 s und war beim Start noch nicht fertig vorgezeichnet.

## Auswertung 388 (Tom, 28.10.; nach dem Code, nicht am Gerät nachgestellt)

- **Ursache in der Alt-Fassung (Verdacht, aus dem Code):** „Leute“ und „Atmen“ heißt: der Prozessor malt Bilder der Figuren (je Blickrichtung, Haltung, Atemzug) im Hintergrund (`MapRest.Shelf`, `MapFolk`, `SdfRender`). Der A22 hat nur zwei schnelle Kerne; malt der Hintergrund, fehlt dem Bildaufbau Rechenzeit. Jede lange Pause fiel in eine Malzeit („nichts 0“). Im Haus stehen die Figuren groß und nah, ihre Bilder sind größer. Die Ablage ist begrenzt, alte Bilder fliegen heraus und werden neu gemalt; deshalb hört das Malen nicht auf (28 von 28).
- **Für Godot:** Dort zeichnet die Grafikkarte die Figuren als Modelle mit Knochen, ohne Bilder im Voraus; diese Ursache fällt weg, ebenso das Vorzeichnen des Skeletts. Neue Gefahr auf dem Mali-G57 MC2 (2 Kerne) bei 1080×2408 und 90 Hz: die Zahl der Bildpunkte. Teuer sind Tusche, Schatten und halb durchsichtige Häuser. Folgerung: Godot auf einem Gerät dieser Klasse messen, bevor es zu Testern geht. Mittel dafür: Auflösung 0,75, `gl_compatibility`, wenige Schattenwerfer, Bildrate fest 30 oder 60 statt 90.
