# 1750 Ortsklang im Kampf: Beleg

Ute (Klang), 22.11., 19:44. Stand `c55217898`, Zweig `claude/klang-1750-ortsklang-kampf`.

**Regel** (`godot/klang/klang.gd` `_lage`, `ort_faktor`): Lage KARTE, KAMPF oder STILL. Im Kampf jede Schleife und jeder Einzellaut des Orts auf Kartenpegel × 0,5 (−6 dB), Vögel und Eule 0. Feuer und Fluss nach der Heldkachel bei Kampfbeginn. Menü (Baum angehalten): still. Nach dem Kampf mit den bisherigen Blendzeiten zurück (Wind 2 s, Feuer und Fluss 1 s je ganzem Anschwellen).

**Quelle Ducking:** uhiyama-lab.com, „Dynamic Music with Unity's Audio Mixer: Snapshots, Ducking, and Crossfades“, Stand 10.10.2026: im Kampfzustand die Kampfmusik hoch, die Umgebung („ambience“) runter.

## Pegeltabelle (`klang_test.gd`, Karte → Kampf)

| Ortsart | Ort | Tag | Nacht |
|---|---|---|---|
| OUTSIDE | Wald | Wind 0,30→0,15; Feuer 0,50→0,25; Fluss 0,236→0,118; Vogel 0,30→0 | dazu Eule 0,30→0; Grille 0,30→0,15 |
| OUTSIDE | Tiefer Wald | wie Wald, Wolf fern 0,32→0,16 (zufällig 0,22–0,32, halb) | dazu Grille 0,30→0,15 |
| OUTSIDE | Dorf | wie Wald, Vogel 0,30→0 | Grille 0,30→0,15 |
| CAVE | Höhle | Feuer 0,50→0,25; Tropfen 0,18→0,09; Berg 0,38→0,16 (zufällig, halb) | gleich |
| HALL | Tempel | Halle 0,30→0,15; Herd 0,50→0,25 | gleich |
| TAVERN | Schänke | Herd 0,50→0,25; Knarren 0,35→0,175 | gleich |
| ROOM | Kammer | Herd 0,50→0,25; Knarren 0,35→0,175 | gleich |

Dorftiere: Ziege meckert im Kampf halb so laut (0,241 = Hälfte des Kartenpegels). Menü: alle Schleifen 0, kein Einzellaut. Fünf Ortsarten, Tag und Nacht: `KLANG 0 Fehler`.

## Hörprobe

Wald am Fluss, Lagerfeuer 1 Kachel, Fluss 2 Kacheln, am Tag (`godot/tests/hoerprobe_1750.gd`, Movie Maker): 0–10 s Karte, 10 s Kampfbeginn, 10–25 s Kampf, 25 s Sieg, bis 35 s zurück.

| Zeit | Wind | Feuer | Fluss | Musik |
|---|---|---|---|---|
| 3–10 s Karte | 0,300 | 0,500 | 0,236 | Wald 0,60 |
| 11 s (Blende geht) | 0,108 | 0,179 | 0,085 | still |
| 12–25 s Kampf | 0,150 | 0,250 | 0,118 | Kampf 0,60 |
| 26 s nach dem Sieg | 0,285 | 0,500 | 0,236 | Sieg 0,20 |
| 27–35 s | 0,300 | 0,500 | 0,236 | Sieg 0,60 |
