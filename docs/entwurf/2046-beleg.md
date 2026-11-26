# 2046 Beleg: Testausgabe vorher/nachher (Nachlieferung zu 2046-Ü5, Prüfer Wanda 26.11., 11:56)

Am Rechner mit Kaufmodellen (`python3 tools/godot/bau_am_rechner.py --cache --laden`, Kaufrepo stufe1), je Test genau der Befehl aus `.github/workflows/godot.yml` „Skripte pruefen“ (:705 stehen_973, :720 biss_1284 mit SEED 7, 9, 13, :727 tausch_1041), gefiltert mit dem grep von dort. Vorher = a8bbc2abf (Zweig nach Merge main, vor 2046), nachher = 711f2be7f (Spitze). Lauf 26.11., 11:58–12:01.

## biss_1284, vorher

```
SCRIPT ERROR: Invalid assignment of property or key 'biss_verdeckt' with value of type 'bool' on a base object of type 'Node3D (figur.gd)'.
SCRIPT ERROR: Invalid access to property or key 'biss_verdeckt' on a base object of type 'Node3D (figur.gd)'.
SCRIPT ERROR: Invalid access to property or key 'biss_verdeckt' on a base object of type 'Node3D (figur.gd)'.
BISS1284 FEHLER RATS/FIGHTER wolf1 an hero, Treffer (Bild 99): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Gehen", "Stehen", "Lefzen", "Gehen", "Stehen", "Lefzen", "Stehen", "Lefze
BISS1284 FEHLER RATS/FIGHTER wolf3 an hero, daneben (Bild 272): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Gehen", "Stehen", "Lefzen", "Stehen", "Lefzen", "Stehen"] – Der Angriff von Riesenratte 3 geht an Ansgar vorbei.
BISS1284 FEHLER RATS/FIGHTER wolf2 an hero, daneben (Bild 593): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Ausweichen links", "Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Ausweichen links", "Stehen", "Gehen", "Stehen", "Lef
BISS1284 FEHLER RATS/FIGHTER wolf1 an hero, Treffer (Bild 873): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Lefzen", "Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Lefzen", "Stehen"] – Riesenratte 1 trifft Ansgar: 1 Schaden.
BISS1284 FEHLER RATS/FIGHTER wolf3 an hero, daneben (Bild 1032): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Lefzen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Lefzen"] – Der Angriff von Riesenratte 3 geht an Ansgar vor
BISS1284 FEHLER RATS/FIGHTER wolf1 an hero, Treffer (Bild 1473): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Lefzen", "Stehen", "Lefzen", "Stehen"] – Riesenratte 1 trifft Ansgar:
BISS1284 FEHLER RATS/FIGHTER wolf3 an hero, daneben (Bild 1627): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Lefzen", "Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Treffer", "Stehen", "Lefzen"] – Riesenratte 3 verfehlt Ansg
BISS1284 FEHLER RATS/FIGHTER wolf1 an hero, Treffer (Bild 2087): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Lefzen", "Stehen", "Ausweichen", "Stehen"] – Riesenratte 1 trifft Ans
BISS1284 FEHLER RATS/FIGHTER wolf2 an hero, Treffer (Bild 1252): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Ausweichen links", "Stehen", "Lefzen", "Stehen", "Tod", ""] – Riesenr
BISS1284 FEHLER RATS/FIGHTER wolf3 an hero, daneben (Bild 2241): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Lefzen", "Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Tod", ""] – Riesenratte 3 zielt auf Ansgar, doch daneben.
BISS1284 FEHLER RATS/FIGHTER wolf1 an hero, Treffer (Bild 2672): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Treffer", "Stehen", "Tod", ""] – Riesenratte 1 trifft Ansgar: 1 Schad
BISS1284 FEHLER RATS/CLERIC wolf1 an hero, Treffer (Bild 99): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Lefzen", "Stehen", "Lefzen", "Stehen", "Lefzen"] – Riesenratte 1 landet 
BISS1284 FEHLER RATS/CLERIC wolf3 an hero, daneben (Bild 269): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Gehen", "Stehen", "Lefzen", "Stehen", "Lefzen", "Stehen", "Lefzen"] – Der Angriff von Riesenratte 3 geht an Osgar vorbei.
BISS1284 FEHLER RATS/CLERIC wolf2 an merc, daneben (Bild 622): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Ausweichen links", "Stehen", "Lefzen", "Stehen", "Treffer", "Stehen"] –
BISS1284 FEHLER RATS/CLERIC wolf1 an hero, Treffer (Bild 856): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Lefzen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Lefzen", "Stehen", "Lefzen", "Stehen"] – Riesenratte 1 trifft Osgar: 2 
BISS1284 FEHLER RATS/CLERIC wolf3 an hero, daneben (Bild 1010): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Lefzen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Lefzen", "Stehen", "Lefzen", "Stehen"] – Der Angriff von Riesenratte 3
BISS1284 FEHLER RATS/CLERIC wolf1 an hero, Treffer (Bild 1591): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Lefzen", "Stehen", "Lefzen", "Stehen"] – Riesenratte 1 trifft Osgar: 2
BISS1284 FEHLER RATS/CLERIC wolf2 an merc, daneben (Bild 1268): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Tod", ""] – Riesenratte 2 zielt auf Brakka, doch daneben.
BISS1284 FEHLER RATS/CLERIC wolf3 an hero, daneben (Bild 1745): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Treffer", "Stehen", "Tod", ""] – Der Angriff von Riesenratte 3 geht an
BISS1284 FEHLER RATS/CLERIC wolf1 an hero, Treffer (Bild 2208): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Treffer", "Stehen", "Tod", ""] – Riesenratte 1 landet einen Treffer be
BISS1284 20 Angriffe, 20 Fehler
BISS1284 FEHLER RATS/FIGHTER wolf3 an hero, daneben (Bild 99): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Gehen", "Stehen", "Lefzen", "Stehen", "Lefzen", "Stehen", "Gehen", "Stehen", "Lefzen", "Treffer", "Stehen", "Lefzen"] – Rie
BISS1284 FEHLER RATS/FIGHTER wolf1 an hero, daneben (Bild 308): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Lefzen", "Stehen", "Treffer", "Stehen", "Gehen", "Stehen", "Rennen", "St
BISS1284 FEHLER RATS/FIGHTER wolf2 an hero, Treffer (Bild 483): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Lefzen", "Stehen", "Lefzen", "Stehen"] – Riesenratte 2 trifft Ansgar: 
BISS1284 FEHLER RATS/FIGHTER wolf3 an hero, daneben (Bild 864): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Lefzen", "Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Lefzen", "Stehen"] – Riesenratte 3 verfehlt Ansgar.
BISS1284 FEHLER RATS/FIGHTER wolf2 an hero, daneben (Bild 1235): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Ausweichen links", "Stehen", "Lefzen", "Stehen"] – Riesenratte 2 verf
BISS1284 FEHLER RATS/FIGHTER wolf3 an hero, daneben (Bild 1642): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Lefzen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Ausweichen zurück", "Stehen"] – Riesenratte 3 verfehlt Ans
BISS1284 FEHLER RATS/FIGHTER wolf2 an hero, daneben (Bild 1796): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Ausweichen links", "Stehen", "Lefzen", "Stehen"] – Riesenratte 2 ziel
BISS1284 FEHLER RATS/FIGHTER wolf3 an hero, Treffer (Bild 2107): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Lefzen", "Ausweichen links", "Stehen"] – Riesenratte 3 landet einen T
BISS1284 FEHLER RATS/FIGHTER wolf2 an hero, Treffer (Bild 2276): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Treffer", "Stehen", "Lefzen", "Stehen"] – Riesenratte 2 erwischt Ansg
BISS1284 FEHLER RATS/FIGHTER wolf1 an hero, daneben (Bild 1071): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Lefzen", "Stehen", "Rennen", "Biss", "Gehen", "Stehen", "Lefzen", "Stehen", "Tod", ""] – Der Angriff von Riesenratte 1 geht an Ansgar vorbei.
BISS1284 FEHLER RATS/FIGHTER wolf3 an hero, daneben (Bild 2633): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Tod", ""] – Der Angriff von Riesenratte 3 geht an Ansgar vorbei.
BISS1284 FEHLER RATS/FIGHTER wolf2 an hero, daneben (Bild 2787): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Gehen", "Stehen", "Lefzen", "Stehen", "Lefzen", "Stehen", "Tod", ""] – Riesenratte 2 zielt auf Ansgar, doch daneben.
BISS1284 FEHLER RATS/CLERIC wolf3 an hero, daneben (Bild 99): OHNE BISS, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Rennen", "Gehen", "Stehen", "Lefzen", "Stehen", "Lefzen"] – Riesenratte 3 zielt auf O
BISS1284 FEHLER RATS/CLERIC wolf2 an merc, Treffer (Bild 573): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Lefzen", "Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Lefzen", "Stehen", "Lefzen", "Stehen"] – Riesenratte 2 erwisc
BISS1284 FEHLER RATS/CLERIC wolf1 an hero, daneben (Bild 233): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Treffer", "Stehen", "Lefzen", "Tod", ""] – Der Angriff von Riesenratte 
BISS1284 FEHLER RATS/CLERIC wolf3 an hero, daneben (Bild 905): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Lefzen", "Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Tod", ""] – Riesenratte 3 verfehlt Osgar.
BISS1284 FEHLER RATS/CLERIC wolf2 an merc, Treffer (Bild 1296): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Treffer", "Stehen", "Tod", ""] – Riesenratte 2 trifft Brakka: 1 Schade
BISS1284 17 Angriffe, 17 Fehler
BISS1284 FEHLER RATS/FIGHTER wolf1 an hero, daneben (Bild 99): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Lefzen", "Stehen", "Lefzen", "Stehen"] – Der Angriff von Riesenratte 1 
BISS1284 FEHLER RATS/FIGHTER wolf3 an hero, Treffer (Bild 641): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Gehen", "Stehen", "Lefzen", "Stehen", "Lefzen", "Ausweichen links", "Stehen"] – Riesenratte 3 erwischt Ansgar: 2 Schaden.
BISS1284 FEHLER RATS/FIGHTER wolf1 an hero, daneben (Bild 898): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Lefzen", "Stehen"] – Riesenratte 1 zielt auf Ansgar, doch daneben.
BISS1284 FEHLER RATS/FIGHTER wolf3 an hero, Treffer (Bild 1271): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Gehen", "Stehen", "Lefzen", "Stehen", "Lefzen", "Ausweichen links", "Stehen"] – Riesenratte 3 landet einen Treffer bei An
BISS1284 FEHLER RATS/FIGHTER wolf1 an hero, Treffer (Bild 1428): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Ausweichen links", "Stehen", "Lefzen"] – Riesenratte 1 trifft Ansgar:
BISS1284 FEHLER RATS/FIGHTER wolf1 an hero, Treffer (Bild 1893): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Lefzen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Treffer", "Stehen"] – Riesenratte 1 landet einen Treffer bei Ansgar: 
BISS1284 FEHLER RATS/FIGHTER wolf2 an hero, daneben (Bild 477): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Gehen", "Stehen", "Lefzen", "Stehen", "Lefzen", "Stehen", "Tod", ""] –
BISS1284 FEHLER RATS/FIGHTER wolf3 an hero, daneben (Bild 1737): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Lefzen", "Rennen", "Biss", "Gehen", "Stehen", "Lefzen", "Tod", ""] – Riesenratte 3 verfehlt Ansgar.
BISS1284 FEHLER RATS/FIGHTER wolf1 an hero, Treffer (Bild 2310): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Tod", ""] – Riesenratte 1 trifft Ansgar: 1 Schaden.
BISS1284 FEHLER RATS/CLERIC wolf1 an hero, Treffer (Bild 99): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Lefzen", "Stehen", "Lefzen", "Stehen"] – Riesenratte 1 erwischt Osgar: 2
BISS1284 FEHLER RATS/CLERIC wolf2 an merc, Treffer (Bild 486): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Lefzen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Treffer", "Stehen", "Lefzen"] – Riesenratte 2 trifft Brakka: 
BISS1284 FEHLER RATS/CLERIC wolf1 an hero, daneben (Bild 786): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Lefzen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Lefzen", "Stehen"] – Riesenratte 1 zielt auf Osgar, doch dane
BISS1284 FEHLER RATS/CLERIC wolf2 an merc, Treffer (Bild 1200): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Lefzen", "Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Ausweichen links", "Stehen", "Ausweichen links"] – Riesenrat
BISS1284 FEHLER RATS/CLERIC wolf1 an hero, daneben (Bild 1354): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Lefzen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Lefzen"] – Riesenratte 1 verfehlt Osgar.
BISS1284 FEHLER RATS/CLERIC wolf1 an hero, Treffer (Bild 1853): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Lefzen", "Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Lefzen", "Treffer", "Stehen"] – Riesenratte 1 landet einen T
BISS1284 FEHLER RATS/CLERIC wolf3 an hero, Treffer (Bild 652): OHNE BISS, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Lefzen", "Stehen", "Tod", ""] – Riesenratte 3 landet einen Treffer bei Osgar: 2 Scha
BISS1284 FEHLER RATS/CLERIC wolf2 an merc, Treffer (Bild 1686): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Ausweichen links", "Stehen", "Rennen", "Biss", "Gehen", "Stehen", "Lefzen", "Stehen", "Tod", ""] – Riesenratte 2 trifft Brakka: 1 Schaden.
BISS1284 FEHLER RATS/CLERIC wolf1 an hero, Treffer (Bild 2236): Biss, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Tod", ""] – Riesenratte 1 trifft Osgar: 2 Schaden.
BISS1284 18 Angriffe, 18 Fehler
… SCRIPT ERROR insgesamt 1217 Zeilen
```

## biss_1284, nachher

```
BISS1284 FEHLER RATS/CLERIC wolf3 an hero, daneben (Bild 269): Biss, Lücke der Zähne 0.78 m (Körper 0.78, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Rennen", "Biss", "Gehen", "Stehen", "Lefzen", "Stehen", "Lefzen", "Stehen", "Lefzen"] – Der Angriff von Riesenratte 3 geht an Osgar vorbei.
BISS1284 20 Angriffe, 1 Fehler
BISS1284 FEHLER RATS/CLERIC wolf3 an hero, daneben (Bild 99): OHNE BISS, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Rennen", "Gehen", "Stehen", "Lefzen", "Stehen", "Lefzen"] – Riesenratte 3 zielt auf O
BISS1284 17 Angriffe, 1 Fehler
BISS1284 FEHLER RATS/CLERIC wolf3 an hero, Treffer (Bild 652): OHNE BISS, Lücke der Zähne inf m (Körper inf, Schild inf), verdeckt 0 %, Bewegungen ["Stehen", "Ausweichen zurück", "Stehen", "Lefzen", "Stehen", "Lefzen", "Stehen", "Tod", ""] – Riesenratte 3 landet einen Treffer bei Osgar: 2 Scha
BISS1284 18 Angriffe, 1 Fehler
```

## tausch_1041, vorher

```
hero: los Bild 57, an Bild 78 (0.73 s), Weg 1.50 m, 2.05 m/s, Tempo höchstens 1.00-fach der Schritte, Knick höchstens 0°
merc: los Bild 3, an Bild 199 (6.57 s), Weg 1.03 m, 0.16 m/s, Tempo höchstens 1.57-fach der Schritte, Knick höchstens 112°
FEHLER merc geht eckig (Knick 112°)
FEHLER nicht zugleich los (54 Bilder auseinander)
FEHLER nicht zugleich an (121 Bilder auseinander)
FEHLER Tempo ungleich (2.05 gegen 0.16 m/s)
Abstand Held–Söldner kleinster 0.56 m
FEHLER zu nah (unter 0.60 m)
TAUSCH1041 5 Fehler
```

## tausch_1041, nachher

```
hero: los Bild 57, an Bild 78 (0.73 s), Weg 1.50 m, 2.05 m/s, Tempo höchstens 1.00-fach der Schritte, Knick höchstens 0°
merc: los Bild 3, an Bild 199 (6.57 s), Weg 1.03 m, 0.16 m/s, Tempo höchstens 1.57-fach der Schritte, Knick höchstens 0°
Abstand Held–Söldner kleinster 0.56 m
FEHLER zu nah (unter 0.60 m)
TAUSCH1041 1 Fehler
```

## stehen_973, vorher

```
  WOLVES Seed 1: Tod ja, 0 Bilder mit Bewegung ohne Grund 
  WOLVES Seed 2: Tod ja, 0 Bilder mit Bewegung ohne Grund 
  WOLVES Seed 3: Tod ja, 0 Bilder mit Bewegung ohne Grund 
  WOLVES Seed 4: Tod ja, 0 Bilder mit Bewegung ohne Grund 
  GOBLINS Seed 1: Tod ja, 0 Bilder mit Bewegung ohne Grund 
  GOBLINS Seed 2: Tod ja, 0 Bilder mit Bewegung ohne Grund 
  GOBLINS Seed 3: Tod ja, 0 Bilder mit Bewegung ohne Grund 
  GOBLINS Seed 4: Tod ja, 1 Bilder mit Bewegung ohne Grund bei 44.0 s: gob2 rückt 0.49 m ohne neuen Platz ((1, 0)), Meldung <null> von gob3: Goblin 3 zielt auf Ansgar, doch daneben.
STEHEN973 1
```

## stehen_973, nachher

```
  WOLVES Seed 1: Tod ja, 0 Bilder mit Bewegung ohne Grund 
  WOLVES Seed 2: Tod ja, 0 Bilder mit Bewegung ohne Grund 
  WOLVES Seed 3: Tod ja, 0 Bilder mit Bewegung ohne Grund 
  WOLVES Seed 4: Tod ja, 0 Bilder mit Bewegung ohne Grund 
  GOBLINS Seed 1: Tod ja, 0 Bilder mit Bewegung ohne Grund 
  GOBLINS Seed 2: Tod ja, 0 Bilder mit Bewegung ohne Grund 
  GOBLINS Seed 3: Tod ja, 0 Bilder mit Bewegung ohne Grund 
  GOBLINS Seed 4: Tod ja, 0 Bilder mit Bewegung ohne Grund 
STEHEN973 0
```

## stehen_973, nachher an 3659d4e41 (Nachbesserung zu 2046-Ü10: ein Seitschritt je Zug)

```
  WOLVES Seed 1: Tod ja, 0 Bilder mit Bewegung ohne Grund 
  WOLVES Seed 2: Tod ja, 0 Bilder mit Bewegung ohne Grund 
  WOLVES Seed 3: Tod ja, 0 Bilder mit Bewegung ohne Grund 
  WOLVES Seed 4: Tod ja, 0 Bilder mit Bewegung ohne Grund 
  GOBLINS Seed 1: Tod ja, 0 Bilder mit Bewegung ohne Grund 
  GOBLINS Seed 2: Tod ja, 0 Bilder mit Bewegung ohne Grund 
  GOBLINS Seed 3: Tod ja, 0 Bilder mit Bewegung ohne Grund 
  GOBLINS Seed 4: Tod ja, 0 Bilder mit Bewegung ohne Grund 
STEHEN973 0
```

## stehen_973, nachher an 55feee192 (Hinweis 2046-Ü14: leerer actor kein neuer Zug)

```
  WOLVES Seed 1: Tod ja, 0 Bilder mit Bewegung ohne Grund 
  WOLVES Seed 2: Tod ja, 0 Bilder mit Bewegung ohne Grund 
  WOLVES Seed 3: Tod ja, 0 Bilder mit Bewegung ohne Grund 
  WOLVES Seed 4: Tod ja, 0 Bilder mit Bewegung ohne Grund 
  GOBLINS Seed 1: Tod ja, 0 Bilder mit Bewegung ohne Grund 
  GOBLINS Seed 2: Tod ja, 0 Bilder mit Bewegung ohne Grund 
  GOBLINS Seed 3: Tod ja, 0 Bilder mit Bewegung ohne Grund 
  GOBLINS Seed 4: Tod ja, 0 Bilder mit Bewegung ohne Grund 
STEHEN973 0
```
