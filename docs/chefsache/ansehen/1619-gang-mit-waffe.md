# 1619 · Gang mit Waffe: Beine aus dem Gehen statt Trippeln

Spike · 18.11., 08:52 · aus deinem Wort 07:29 zu Film 458.3 („warum der Held gar so stakst … sah gar nicht mehr so nach Gehen aus. Vielleicht lag das an Tempo“)
Kurz: Zwei Ursachen nachgestellt: der Wiesenfilm 458.3 schob den Helden zu langsam (Füße rutschten), und im Spiel trippelt das Gehen der Waffenpakete mit 4,1 beziehungsweise 3,6 Schritten je Sekunde. Neu: Beine aus dem Gehen ohne Waffe, Arme aus dem Paket. Ein Film im Dorf, je Waffe bisher und neu.

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/0c2e3cd5f (Messung `gang_mess_1619.gd`; LOGIK 192 gut; `tragen_pakete_417` mit denselben 5 Fehlern wie vorher, Abstände der Waffe zum Körper gleich)

**Film:** Dorf wie im Spiel (Tusche, Spielkamera nah), der Kämpfer geht im Spieltempo 2,13 m/s hin und her: Langschwert bisher, Langschwert neu, Großaxt bisher, Großaxt neu, je 3 s; oben links Waffe, Fassung und Schritte je Sekunde. Das dunkle Dach unten gehört zur Kamera, nicht zur Frage.

**Befund:**
- Film 458.3 (Wiese): er schob den Helden mit 1,08 m/s, die Bewegung ist seit 416.4 auf 2,13 m/s umgetaktet. Die Beine traten doppelt so schnell, wie er vorankam: Füße rutschten, er trat halb auf der Stelle. Nur im Film.
- Im Spiel: die Gehbewegungen der Waffenpakete haben kurze Schritte (Langschwert 0,52 m, Großaxt 0,58 m). Auf das Spieltempo umgetaktet: 4,1 beziehungsweise 3,6 Schritte je Sekunde. Gehen ohne Waffe: 3,1 bei 0,69 m. Alte Kotlin-Fassung: 1,84 bei 1,16 m (ein Umlauf über 2 Kacheln, `MapFigure.kt` 158).

**Neu:** wie beim Rennen mit Waffe (417a, dein Wort 02.11.): Beine und Rumpf aus dem Gehen ohne Waffe, Arme mit der Waffe aus dem Paket, im Tritt. Mit jeder Waffe 3,1 Schritte je Sekunde; die Waffe sitzt wie bisher in der Faust.

**Offen:** Auch 3,1 Schritte je Sekunde sind flott, weil das Gehtempo hoch ist (1,84 Kacheln je Sekunde wie alt, dort aber mit gezeichnetem langem Schritt). Langsamer gehen wäre Spielgefühl, deine Wahl; nicht hier gebaut. Prüfpunkte selbst geprüft: Held ganz sichtbar, Waffe in der Faust, kein Gleiten.

👍 neu in den Sammelbuild · 👎 so lassen
