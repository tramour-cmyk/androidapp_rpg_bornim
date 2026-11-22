# 1727h–k · Nachprüfung 5 (frischer Prüfer, 22.11., 09:11; an `f71f12d51`, Kopie `e00cc9c69`)

Byte, Summen, Zählung Lauf 3, Aufbau nach MUSTER: stimmt. Offen, nicht eingearbeitet (Sokrates-Nachfolger):

**1727h**
1. Fehler: „1763 wirkt erst ganz mit 1800“ und „der nächste Start wird nicht angehalten (1800)“ überholt; 1800 gebaut an der Kopie (`e00cc9c69`, Liste Zeile 320; Diogenes 09:09: greift). 1798 gebaut (`2f37b6fed`), offen 1899.
2. Lücke: gebaut ist höchstens ein Arbeitsplaner insgesamt (`AUFTRAG_PLANER = 1`), nicht je Fachprofil; 137 Zeilen ohne Auftrag, Lauf stündlich → Tage bis alle Aufträge stehen. Den Wert fragt keine Vorlage, obwohl `docs/vorgang/1893.md` sagt, Sokrates legt ihn 10:00 vor.
3. Fehler: Bedingung 8 „Laufbremse ohne Wert“ falsch; ohne Wert ist nur `HOECHSTDAUER_MIN`; Laufbremse gebaut in `probelauf.py` (`hoechstdauer-1774.md`:5, :15).
4. Lücke: 1781 Kaufrepo-Satz mit Probe vor der Umstellung (Archiv 21.11., 21:38) fehlt in den Bedingungen.
5. Lücke: Anhang „ersetzt“ an 11:17, 14:37, 19.11., 19:37 nur für den Teil Umschaltbedingung (Vorbild 235 „Teil a“); zu 19:37 fehlt, welche Teile der Bauliste 7.1 ungebaut bleiben (`1727-gesamtbild.md`:914–924).
6. Lücke: Folgerungen „Spike Bedingungen 1 bis 4“ ohne 6 (`settings.json`, 1859); Gedächtnis der Leitung (Bedingung 2) schreibt Sokrates.

**1727i**
1. Lücke: `gepusht-haken.py` sperrt nicht, er erinnert einmal und lässt beim zweiten Beenden durch (`tools/gepusht-haken.py`:4–5). Ob das die „Sperre“ aus 19.11., 13:58 ist, entscheidet der Chef; Vorlage sagt es nicht (gilt auch 1727j V2, 1727k).
2. Lücke: „4 Fragen fürs Gespräch“ zählt A1 mit, in 1727j steht A1 nur „zur Kenntnis“ (auch 1727h).

**1727j**
1. Fehler: Frage 14 schon entschieden: Archiv 20.11., 07:47 (Zeile 60) „Fachprofil je Werkstatt-Block, Marktstart ohne“; nur als Bestätigung, offen nur Block 9.
2. Fehler: Frage 10 „Größe prüft schon `vorlage_pruefen.py`“ falsch; die Bildgrenze 60 KB prüft `startwarnung.py`:99–102.
3. Lücke: Frage 8 weicht ab von 18.11., 23:15 „Lass mal heute Nacht nicht zu viel laufen“ (Archiv Zeile 96); nennen.
4. Lücke: V4 „dein Wort 18.11., 21:37 … in einem Auftrag“ ist Lesart; Archiv Zeile 112: „erst Widerspruch Messung gegen Bild nachstellen, dann ein Bild …“.

**1727k**
1. Lücke: sagen, dass „alles gepusht?“ nur erinnert (siehe 1727i Nr. 1), weil daraus „Zeile 7 fällt“ folgt.

Nicht prüfbar: Schätzungen aus Spike 08:23; Meldung „grün“ zu 1893 steht aus; ob `rufname.py`, `zug-index.py`, `tagesbericht.py`, `abgleich.py` an der neuen Liste richtig ausgeben.
