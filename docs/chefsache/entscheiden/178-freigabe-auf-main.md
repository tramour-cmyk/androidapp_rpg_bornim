# 178 · Freigegebene Builds sofort auf main
Perikles · 18.10., 16:08 · B Abläufe · Frage des Chefs 18.10., 15:5x: „Die zwei offenen Builds bei mir habe ich schon vor Ewigkeiten freigegeben ... warum macht da keiner was damit und sorgt für einen sauberen Main-Strang mit allen Inhalten?“

Kurz: Build 21, 22, 23, 24 sind auf `main`; Build 22 (Freigabe 14:39) erst 15:49, weil der Merge nur im Vorrat der schon übergebenen Sitzung stand. Offen und nicht auf `main`: Entwürfe #106 (154/155) und #107 (39).

**Frage:** Welche zwei Builds meinst du, und sind #106 (154/155) und #107 (39) freigegeben, also zusammenzuführen?

**Empfehlung:** Ford prüft in jedem Lauf, ob eine Freigabe des Chefs („passt“, „freigegeben“) ohne Merge dasteht, und teilt das Zusammenführen (PR mergen, Zweig löschen, CHANGELOG) dem Team zu, auch wenn die bauende Sitzung schon übergeben hat. #106 und #107 nur nach deinem ausdrücklichen „ja“ zusammenführen.

**Stärkstes Gegenargument:** Jede neue Prüfung in Fords Lauf kostet Token und ist eine weitere Regel (90a); der Fehler trat bei einem Übergang auf, lässt sich auch durch „Übergabe nennt den Merge als ersten Schritt des Nachfolgers“ beheben.

**Berührt:** 167.2 (`lauf.py`), 177, 121 (Übergabe nennt nur Getanes und Nachfolger), 130.2a (Build 22).
