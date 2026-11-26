# 1603: Krogg-Rechnung nach Entscheid B (Sokrates 23.11., 22:08), Lauf 23.11., 22:10

`python3 tools/sim444/rechnung_1603.py tools/sim444 200 0.82,0.6,0.4,0.3,0.2,0.1,0.05,0,1.0,1.2`

Krogg, N = 200 je Fall, Grenze 7 Punkte; groesste Abweichung von heute ueber 8 Herkuenfte x 6 Stufen

| Zusatz | Ring | groesste Abweichung | bei | heute → neu | haelt |
|---|---|---|---|---|---|
| 0.82 | nie | -51.5 | Klosterschüler 3 | 74.5 → 23.0 | nein |
| 0.82 | gut | +12.0 | Zauberlehrling 5 | 59.5 → 71.5 | nein |
| 0.82 | perfekt | +60.5 | Klosterschüler 2 | 19.5 → 80.0 | nein |
| 0.82 | halb gut | -29.0 | Klosterschüler 3 | 74.5 → 45.5 | nein |
| 0.60 | nie | -34.0 | Klosterschüler 3 | 74.5 → 40.5 | nein |
| 0.60 | gut | +16.0 | Zauberlehrling 5 | 59.5 → 75.5 | nein |
| 0.60 | perfekt | +60.5 | Klosterschüler 2 | 19.5 → 80.0 | nein |
| 0.60 | halb gut | -15.5 | Klosterschüler 3 | 74.5 → 59.0 | nein |
| 0.40 | nie | -29.5 | Klosterschüler 3 | 74.5 → 45.0 | nein |
| 0.40 | gut | +20.5 | Klosterschüler 2 | 19.5 → 40.0 | nein |
| 0.40 | perfekt | +60.5 | Klosterschüler 2 | 19.5 → 80.0 | nein |
| 0.40 | halb gut | -10.0 | Kräutersammler 6 | 80.5 → 70.5 | nein |
| 0.30 | nie | -17.5 | Klosterschüler 3 | 74.5 → 57.0 | nein |
| 0.30 | gut | +22.0 | Klosterschüler 2 | 19.5 → 41.5 | nein |
| 0.30 | perfekt | +60.5 | Klosterschüler 2 | 19.5 → 80.0 | nein |
| 0.30 | halb gut | -10.0 | Klosterschüler 3 | 74.5 → 64.5 | nein |
| 0.20 | nie | -16.5 | Klosterschüler 3 | 74.5 → 58.0 | nein |
| 0.20 | gut | +29.5 | Klosterschüler 2 | 19.5 → 49.0 | nein |
| 0.20 | perfekt | +60.5 | Klosterschüler 2 | 19.5 → 80.0 | nein |
| 0.20 | halb gut | +11.0 | Schmiedelehrling 5 | 69.0 → 80.0 | nein |
| 0.10 | nie | -9.5 | Herumtreiber 5 | 72.0 → 62.5 | nein |
| 0.10 | gut | +32.0 | Klosterschüler 2 | 19.5 → 51.5 | nein |
| 0.10 | perfekt | +60.5 | Klosterschüler 2 | 19.5 → 80.0 | nein |
| 0.10 | halb gut | +10.0 | Klosterschüler 2 | 19.5 → 29.5 | nein |
| 0.05 | nie | -4.0 | Kräutersammler 6 | 80.5 → 76.5 | ja |
| 0.05 | gut | +30.5 | Klosterschüler 2 | 19.5 → 50.0 | nein |
| 0.05 | perfekt | +60.5 | Klosterschüler 2 | 19.5 → 80.0 | nein |
| 0.05 | halb gut | +16.5 | Klosterschüler 2 | 19.5 → 36.0 | nein |
| 0.00 | nie | +0.0 | Wachsoldat 1 | 0.5 → 0.5 | ja |
| 0.00 | gut | +28.0 | Klosterschüler 2 | 19.5 → 47.5 | nein |
| 0.00 | perfekt | +60.5 | Klosterschüler 2 | 19.5 → 80.0 | nein |
| 0.00 | halb gut | +13.0 | Wachsoldat 3 | 49.5 → 62.5 | nein |
| 1.00 | nie | -57.0 | Klosterschüler 3 | 74.5 → 17.5 | nein |
| 1.00 | gut | +0.0 | Wachsoldat 1 | 0.5 → 0.5 | ja |
| 1.00 | perfekt | +60.5 | Klosterschüler 2 | 19.5 → 80.0 | nein |
| 1.00 | halb gut | -35.5 | Klosterschüler 3 | 74.5 → 39.0 | nein |
| 1.20 | nie | -62.5 | Klosterschüler 3 | 74.5 → 12.0 | nein |
| 1.20 | gut | -9.5 | Herumtreiber 5 | 72.0 → 62.5 | nein |
| 1.20 | perfekt | +60.5 | Klosterschüler 2 | 19.5 → 80.0 | nein |
| 1.20 | halb gut | -46.0 | Klosterschüler 3 | 74.5 → 28.5 | nein |

## Nach Entscheid C (Sokrates 24.11., 00:07), Lauf 24.11., 07:33, Stand nach Merge main

Maß: Ringannahme „halb gut“, Grenze 10 Punkte; gebaut Zusatz 0,3.

`GRENZE=10 python3 tools/sim444/rechnung_1603.py tools/sim444 200 0.3`

Krogg, N = 200 je Fall, Grenze 10 Punkte; groesste Abweichung von heute ueber 8 Herkuenfte x 6 Stufen

| Zusatz | Ring | groesste Abweichung | bei | heute → neu | haelt |
|---|---|---|---|---|---|
| 0.30 | nie | -25.0 | Klosterschüler 3 | 77.0 → 52.0 | nein |
| 0.30 | gut | +24.0 | Klosterschüler 2 | 17.0 → 41.0 | nein |
| 0.30 | perfekt | +63.5 | Klosterschüler 2 | 17.0 → 80.5 | nein |
| 0.30 | halb gut | -8.5 | Klosterschüler 3 | 77.0 → 68.5 | ja |

Halb gut −8,5 Punkte (Klosterschüler 3, 77,0 → 68,5 %): in der Spanne. Ohne Ring −25,0, Ring gut +24,0, perfekt +63,5 (Maß nach C nur
„halb gut“).

Gegenprobe N = 500 (Checkliste LISTE-MARS 4: unter 10 Punkten mindestens 500), `GRENZE=10 … 500 0.3`: halb gut +7,0
(Jägerkind 4, 34,4 → 41,4 %), ohne Ring −21,8, gut +24,8, perfekt +62,6. Halb gut in der Spanne.
