# Testgeräte und Messwerte

Geräteangaben, die Tester über „Kopieren“ im Systemmenü schicken (388). Je Meldung Datum, Ort im Spiel und Wortlaut der Angaben. Nutzen: die Godot-Fassung muss auf diesen Geräten flüssig laufen (Alt-Fassung ist zu, Archiv 27.10., 22:17).

## Tester 1, Samsung Galaxy A22 5G (Chef 27.10., 23:25, „Von erwähntem Tester, bei dem es ruckelt“; Ort: Mitte des Marktplatzes)

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

Lesart (Sokrates, ohne Nachstellen): untere Mittelklasse (Mali-G57 mit 2 Kernen, 3,6 GB). Die Speicherbereinigung bremst nicht (0 ms anhaltend). Die Pausen von etwa 0,5 s fallen zusammen mit dem Zeichnen von Held, Leuten und Atmen; der Held ist erst nach 42 s ganz gezeichnet. Das spricht für teures Zeichnen der Figuren auf der Grafik, nicht für Speichernot. Gemeldet war das Ruckeln in den Hütten; diese Messung ist vom Marktplatz. Auswertung und Folgerung für Godot: Tom (388).
