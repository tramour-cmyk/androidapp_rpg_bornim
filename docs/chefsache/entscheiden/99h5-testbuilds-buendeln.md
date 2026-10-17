# 99h.5 · Testbuilds zum Durchspielen bündeln: wie?
Perikles · 17.10., 10:5x · berührt 78a (Sammelbuild), 102 (Nummern aufsteigend), 118 (Übernahme)
Kurz: Empfehlung: je Team ein Durchspielbuild mit bis zu 6 Punkten, Prüfliste als ein Weg durchs Spiel; Tom und Jerry weiter getrennt

**Frage.** Dein Wortlaut: „auch die Testbuilds für mich zum Durchspielen dann so zusammenbauen, dass mehrere Sachen auf einmal getestet werden können.“ Heute gilt: Sammelbuild höchstens 4 Punkte, Zweig lebt höchstens 1 Tag, nie Tom und Jerry in einem Build (`LISTE-BAUEN-TESTEN.md`). Was soll sich ändern?

**Empfehlung (A).**
1. **Erst sammeln, dann bitten:** ein Team bittet um Test, wenn 3 Punkte fertig sind oder der älteste 2 Tage wartet; sagst du „jetzt“, sofort.
2. **Größer:** Sammelbuild bis 6 Punkte, Zweig lebt bis 2 Tage (ersetzt 4 und 1 Tag, keine neue Regel, 90a). Fällt ein Punkt durch, fliegt nur er per `git revert` heraus.
3. **Prüfliste als Weg:** Punkte in der Reihenfolge, in der du im Spiel auf sie triffst (Ort, Spielstand), ein Durchgang statt einzelner Abschnitte.
4. **Tom und Jerry bleiben getrennt;** Jerrys Build kommt mit der nächsten Nummer gleich danach, beide in einem Durchspielen.

**Stärkstes Gegenargument.** Größere Bündel warten länger auf `main`, ein Fehler im Build (Absturz) hält alle Punkte auf, und die Ursache ist schwerer zu finden; die Teams laufen länger auf alten Zweigen (mehr Zusammenführung). Dagegen: Kerntests und Standbilder fangen das meiste vorher, ein Punkt fliegt einzeln heraus.

**Alternative (B):** ein gemeinsamer Build beider Teams (Tom führt zusammen). Ein Gerät, eine Nummer, aber gemischte Ursachen bei Fehlern und Arbeit über beide Teams; nicht empfohlen.
