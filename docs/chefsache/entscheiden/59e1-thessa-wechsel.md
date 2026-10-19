# 59e.1 · Thessas Ware wechselt an Story-Schritten statt alle 8 Siege
Homer · 19.10., 09:0x · G Balance · Umsetzung Team Jerry (`Loot.shopGear`, Zweig `claude/jerry-59e-haendlervorrat`)

Kurz: Thessas Ausrüstung lässt sich heute durch Kämpfen beliebig neu würfeln; das ist Diablo-Grind, den das Leitbild ausschließt

**Frage** (von Team Jerry, 16.10., 19:5x): Thessas Ausrüstung wechselt heute alle 8 Siege (`battlesWon / 8` im Startwert, dazu die Stufe des Helden). Wer ein bestimmtes Stück will, kämpft, bis es da ist. Beschluss 59e wollte den Vorrat an etwas Nicht-Beliebiges koppeln. Vorschlag Jerry: Wechsel an Story-Schritten (Auftrag angenommen, Garrick getroffen, Krogg, Grak, Kapitelwechsel).

**Empfehlung: ja.** Startwert = Story-Schritt statt Siege; die Stufe bleibt drin (sie ist in Kapitel 1 bei 6 gedeckelt, also kein endloses Würfeln). Damit gibt es in Kapitel 1 etwa fünf Wechsel plus die Stufenaufstiege, jeder an einer Stelle, die der Spieler als Fortschritt erlebt: „Nach Krogg hat Thessa Neues“ ist ein kleiner Lohn, kein Automat. Passt zu `DESIGN-LEITBILD.md` (weder Diablo-Grind noch Pen and Paper) und zu 45 (keine Mechanik, die zum Wiederholen drängt).

**Stärkstes Gegenargument:** Weniger Wechsel heißt weniger Chancen auf ein Stück für die eigene Klasse; wer Pech hat, sieht lange nichts Passendes. Dagegen: Beute aus Kämpfen und Kisten bleibt, die Grundstücke je Platz sind immer da, und mit jedem Stufenaufstieg wechselt die Ware ohnehin.

**Mitentscheiden: 59e.2 (Mengen je Laden, Tränke): noch nicht** (Empfehlung Jerry, ich schließe mich an): Messung 110–175 G für Tränke je Kapitel, eine Grenze bisse auf „Normal“ kaum; erst mit dem Schwierigkeitsgrad 39.

**Berührt:** 59e, 39, `Loot.kt` (`shopGear`), `ARBEIT-TEAM-JERRY.md` Zeile 59e.
