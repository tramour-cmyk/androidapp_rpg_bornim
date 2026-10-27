# Testgeräte und Messwerte

Geräteangaben, die Tester über „Kopieren“ im Systemmenü schicken (388). Je Meldung Datum, Ort im Spiel und Wortlaut der Angaben. Nutzen: die Godot-Fassung muss auf diesen Geräten flüssig laufen (Alt-Fassung ist zu, Archiv 27.10., 22:17).

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

## Tester 1, gleiches Gerät, dritte Messung, Ort nicht genannt (Chef 27.10., 23:35)

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
