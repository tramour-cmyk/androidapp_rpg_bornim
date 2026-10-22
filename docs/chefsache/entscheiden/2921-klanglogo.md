# 292.1 · Klanglogo: welche Nummern aus Runde 4?
Jerry · 22.10., 08:20 · E Klang · M (Chef 21.10., 22:26, Wortlaut: „Die Frage ist ja dann auch, ob wir sozusagen als Brand einen Signature Tone generieren können. Zum Logo sozusagen. Und es wirkt halt auch ehrlich gesagt professionell.“; 22:30 „292.1 jetzt als Muss“; Runde 4 Chef 22.10., 07:56, Wortlaut bei Sokrates „Zu 292.1“)

## Runde 4: 24 Proben

Auf Telegram (22.10., 08:2x) liegt **eine Sammeldatei**. Darin laufen alle 24 Proben nacheinander, je 2 bis 2,5 s lang, mit 1,5 s Pause dazwischen. Alle Proben sind gleich laut (−19 LUFS).

Alle Proben stehen in G-Dur oder C-Dur. Jede hat 3 bis 5 Töne und endet mit einem hellen Glockenton oder einer kurzen Glockenkette. Es klingen nur echte Instrumente aus VSCO 2 CE (CC0 1.0, github.com/sgossner/VSCO-2-CE): Harfe, Glockenspiel, Streicher, Horn, Pauke und große Trommel. Ein Thema aus dem Spiel kommt nicht vor; das Motiv soll auch vor einem anderen Spiel von BornWire tragen.

| Nr. | Zeit | Familie | Was |
|---|---|---|---|
| 1 | 0:00 | A schlicht | Harfe G–D–G steigt, Glocke G |
| 2 | 0:03 | A schlicht | Harfe D–G–H–D, Glocke D hoch |
| 3 | 0:07 | A schlicht | Harfe fällt und steigt: D–H–G … D, Glocke G |
| 4 | 0:10 | A schlicht | Harfe D–G–D–G (Quarte, Quinte, Oktave), Glockenkette |
| 5 | 0:14 | A schlicht | Harfe da-da … daa, Glocke |
| 6 | 0:18 | A schlicht | Harfe C–E–G–C (heller), Glocke C |
| 7 | 0:21 | B orchestral | Boah, da (D) – dum (G), Streicher G-Dur, Glocke G |
| 8 | 0:25 | B orchestral | Boah, nur dum, Glockenkette G–H–D |
| 9 | 0:29 | B orchestral | Boah kurz, da-da-dum (D–D–G), Glocke |
| 10 | 0:33 | B orchestral | Streicher steigen G–D, dum, Glocke G |
| 11 | 0:37 | B orchestral | Boah, da-dum, Harfe rauscht hoch, Glocke D |
| 12 | 0:41 | B orchestral | Boah von Moll nach Dur, dum, Glocke |
| 13 | 0:45 | C Glocke | Glocke G–D–G hoch, Harfe tief darunter |
| 14 | 0:48 | C Glocke | Glockenkette abwärts, ein Streicherton bleibt |
| 15 | 0:52 | C Glocke | Glocke D–G … G hoch (da-daa … ding) |
| 16 | 0:55 | C Glocke | Glocke C–E–G–C, klar wie eine Uhr |
| 17 | 0:59 | C Glocke | Glocke G–A–H … D, Streicher G darunter |
| 18 | 1:02 | C Glocke | Pauke tief, dann steigt die Glockenkette |
| 19 | 1:06 | D gemischt | Harfe G–D–G, Streicher setzen ein, Glocke |
| 20 | 1:10 | D gemischt | Harfe vier Töne, Celli tief, Glockenkette |
| 21 | 1:14 | D gemischt | Celli brummen, Harfe D–G drüber, Pauke, Glocke |
| 22 | 1:18 | D gemischt | schnelles Harfen-Arpeggio, Streicherschlag, Glocke D |
| 23 | 1:21 | D gemischt | Harfe da-da-daa, Horn hält, Glocke G |
| 24 | 1:25 | D gemischt | Boah, Harfe G–D–G im da-dum, Glockenkette |

**Frage:** Welche Nummern gefallen dir? Gern mehrere und gern mit einem Wort dazu, etwa „7 und 19, 19 kürzer“. Um die gewählten Proben baue ich dann den Feinschliff.

Runde 1 bis 3 (A–I) sind damit abgelöst. Die Quelle ist `tools/klang/klanglogo4.py` im Zweig `claude/jerry-292-klanglogo`.

## Einbau nach der Wahl

Eine OGG-Datei kommt nach `assets/sfx` und spielt mit dem Logo im Vorspann (292, Bau Tom). Sie schweigt bei „Musik aus“ (gespeicherter Schalter). Die Quelle wird in `tools/klang/QUELLEN.md` eingetragen.

## Stärkstes Gegenargument

Die Familie B lebt vom tiefen „Boah“, und Handylautsprecher geben unter etwa 300 Hz kaum etwas wieder (Stellungnahme Sokrates 00:08). Über den Handylautsprecher klingen A, C und D darum vollständiger. Am besten hörst du einmal mit und einmal ohne Kopfhörer.

## Empfehlung

Bitte mindestens eine Probe aus D anhören (19 oder 24). Harfe, Streicher und Glocke zusammen sind am ehesten „wir“, und sie tragen auch auf dem Handylautsprecher. Ob das Motiv trägt, entscheidet aber das Ohr.

Berührt: 292 (Vorspann, Tom), 251.4 (Logo, Homer).
