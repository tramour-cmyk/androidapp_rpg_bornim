# 1603: sollbild_784 STRENG=1, Ausgabe Zweig und main (24.11., 11:29 und 11:31)

Mit Kaufmodellen (`bau_am_rechner.py --cache --laden`), `MESS=1603 STRENG=1 godot --headless -s res://tests/sollbild_784.gd`.
Zweig `arne/1603-ansagen` an 1a51f61db, main an efbeabc7e; beide Exit 18, dieselben 18 Stellen (Held, Söldner, Wege der Wölfe), Zeiten höchstens 0,1 s auseinander.

## Zweig 1a51f61db

```
ÜBER runde          130.1 s (Soll 14.6) Runde 1 bei 145.1 s
ÜBER held_angriff    18.2 s (Soll 2.4) Held bei 145.1 s
ÜBER wolf_zug        30.3 s (Soll 3.4) Wolf 1 bei 163.3 s
ÜBER wolf_zug        35.9 s (Soll 3.4) Wolf 3 bei 193.5 s
ÜBER wolf_zug        29.9 s (Soll 3.4) Wolf 2 bei 229.4 s
ÜBER soeldner        10.6 s (Soll 2.0) Söldner bei 259.3 s
ÜBER held_aufstehen   5.3 s (Soll 3.5) Held bei 269.9 s
ÜBER warten         106.6 s (Soll 12.2) Runde 1 bei 145.1 s
ÜBER zurechtruecken   3.0 s (Soll 1.0) Wolf 2 bei 152.2 s
ÜBER zurechtruecken   2.7 s (Soll 1.0) Wolf 2 bei 164.2 s
ÜBER wolf_hin         2.1 s (Soll 0.6) Wolf 1 bei 168.5 s
ÜBER wolf_zurueck     2.5 s (Soll 0.8) Wolf 1 bei 177.4 s
ÜBER zurechtruecken   4.6 s (Soll 1.0) Wolf 3 bei 175.8 s
ÜBER wolf_hin         2.3 s (Soll 0.6) Wolf 3 bei 198.8 s
ÜBER wolf_zurueck     2.5 s (Soll 0.8) Wolf 3 bei 208.0 s
ÜBER zurechtruecken   4.5 s (Soll 1.0) Wolf 1 bei 206.5 s
ÜBER wolf_hin         0.8 s (Soll 0.6) Wolf 2 bei 234.7 s
ÜBER wolf_zurueck     2.5 s (Soll 0.8) Wolf 2 bei 242.4 s
SOLLBILD784 18 über dem Maß
```

## main efbeabc7e

```
ÜBER runde          130.1 s (Soll 14.6) Runde 1 bei 145.3 s
ÜBER held_angriff    18.1 s (Soll 2.4) Held bei 145.3 s
ÜBER wolf_zug        30.3 s (Soll 3.4) Wolf 1 bei 163.4 s
ÜBER wolf_zug        35.9 s (Soll 3.4) Wolf 3 bei 193.7 s
ÜBER wolf_zug        29.9 s (Soll 3.4) Wolf 2 bei 229.6 s
ÜBER soeldner        10.5 s (Soll 2.0) Söldner bei 259.5 s
ÜBER held_aufstehen   5.3 s (Soll 3.5) Held bei 270.0 s
ÜBER warten         106.6 s (Soll 12.2) Runde 1 bei 145.3 s
ÜBER zurechtruecken   3.0 s (Soll 1.0) Wolf 2 bei 152.3 s
ÜBER zurechtruecken   2.7 s (Soll 1.0) Wolf 2 bei 164.3 s
ÜBER wolf_hin         2.0 s (Soll 0.6) Wolf 1 bei 168.6 s
ÜBER wolf_zurueck     2.5 s (Soll 0.8) Wolf 1 bei 177.6 s
ÜBER zurechtruecken   4.5 s (Soll 1.0) Wolf 3 bei 176.1 s
ÜBER wolf_hin         2.3 s (Soll 0.6) Wolf 3 bei 199.0 s
ÜBER wolf_zurueck     2.5 s (Soll 0.8) Wolf 3 bei 208.2 s
ÜBER zurechtruecken   4.5 s (Soll 1.0) Wolf 1 bei 206.7 s
ÜBER wolf_hin         0.8 s (Soll 0.6) Wolf 2 bei 234.9 s
ÜBER wolf_zurueck     2.5 s (Soll 0.8) Wolf 2 bei 242.6 s
SOLLBILD784 18 über dem Maß
```
