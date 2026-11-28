# 1727 · Falltest Lauf 3 (22.11., ab 07:15): Fälle

Nur die Fälle, die in Lauf 2 nach Nachprüfung 2 „teilweise“ oder „nicht“ waren, P6 mit neuem Soll und die Kette Rückläufer (K2) mit V4. Soll: `../falltest-faelle-22-11.md` (P6 neu 22.11., 07:09). Ladetexte fest und schreibgeschützt im Scratchpad dieser Sitzung, Ordner `lt3/` (Sockel mit V2 1.129, Kern Leitung mit V1 Fassung 3 2.962, Kern Büro 680, Profil Disponent F14 3.761, Kern Arbeitsplaner mit V3 und V4 2.753, Kern Abnahme 1.567, Profil Prüfer F7 2.730; Prüfsummen in `ergebnis.md`). Repo nur lesend (`/home/user/bornim-main`).

Zeichen: „Zeile“ = Übergabezeile über `vorgang.py` (offen, angenommen, erledigt); Chefworte wörtlich mit Zeit. Bilder und Filme gibt es im Test nicht als Datei; was du siehst, steht unter „Beleg zeigt“. Du führst keinen Schreibbefehl aus; du schreibst genau, was du tätest, mit Befehlen, und was du zurückmeldest.

## Stufe 1

### Leitung (Sockel + Kern Leitung)

L10 (Kette K3.6). Zweite offene Zeile „steckt fest“ an dich zu 1694 (Stab durch die Knöchel) nach dem zweiten Versuch, den du freigegeben hattest („ein Versuch, Griffpunkt je Waffe“): „steckt fest: wieder rot, 610 von 1540, Commit `d8dce68a2`, versucht: Griffpunkt je Waffe.“ Bisher in der Vorgangsdatei: erstes „steckt fest“ 752 von 1540, Commit `04bf8ffc1`; zwei Fachkraft-Läufe, Kosten laut Kopf der Vorgangsdatei 11,40 $.

### Büro / Disponent (Sockel + Kern Büro + Profil Disponent)

D1. Archiv: „1784 A: heute Nacht höchstens acht weitere Spike-Starts an 1739, spätestens 03:00; Ford startet von Hand nur, wenn die letzte Übergabe einen Commit unter `tools/` oder `.github/` nennt.“ (Ford = heute der Disponent.) Start 4/8: der Startsperre-Haken meldet „Nachtstopp“. In der Liste steht schon 1792 (Spike, startbar): „Nachtstopp-Haken kennt keine vom Chef entschiedene Ausnahme“.

D3. Rückmeldung „fertig“ zu einem Werkzeug-Vorgang (Bereich B Werkzeuge, kein Spielinhalt): „Lauf grün, Geprüft an: `a1b2c3d`“. Eine Stunde später ist `a1b2c3d` nicht auf `main`; du siehst es beim ersten Wecker nach der Rückmeldung.

D4. Chef 23:15: „Lass mal heute Nacht nicht zu viel laufen, dass wir vielleicht morgen früh noch Luft haben.“ Um 01:10 wird eine Kür-Zeile startbar (`lauf.py` gibt START aus). Eine Fachkraft läuft noch an einem Muss.

D5. Zwei offene Zeilen „Frage“ an Sokrates (Lauffreigabe), offen seit 22:44 und 23:08; Sokrates läuft nicht. Es ist 23:10.

D9 (Kette K2.3). Offene Zeile an die Fachkraft (Profil Figur) zu 1535 (Rückläufer, Fund des Chefs); gleichzeitig offen: eine Zeile mit Eilt zu 1801 und eine gewöhnliche Muss-Zeile zu 1270. `vorgang.py offen` listet 1535 vor 1801.

### Büro / Arbeitsplaner (Sockel + Kern Büro + Kern Arbeitsplaner)

Wo ein Auftrag verlangt ist: schreibe ihn vollständig in `<Fall>.auftrag.md` in diesem Ordner und prüfe ihn mit `python3 tools/vorgang.py auftrag <Nr> --datei <Pfad> --pruefen` (nur prüfen); steht die Nummer nicht in der Liste, nimm 1694.

A1. Chefwort 18.11., 17:01 zu 1694 (Stab durch die Knöchel): „Als Systemlösung, genau. Jetzt sind wir nämlich wieder mal so weit damit, dass wir Sachzusammenhänge erkennen und deswegen auch Lösungen suchen und nicht ständig einzeln rumflicken.“

A3. Build-Auftrag mit Prüfpunkten liegt dir zum Ausarbeiten vor: „299.1 Handy: Hauptmenü, Wachsoldatin mit Schild ansehen“, „299.2 Handy: Fläche vor dem Schild“, „299.3 Handy: Kampf gegen den Wolf, Ausweichen nach links antippen“.

A5. Chefwort aus der Spracherkennung, vom Haken in die Vorgangsdatei 1727 getragen, 21.11., 15:15: „Ja, soweit alles klar. Profiltechnik-Jahr zu 535 Jahren“ (Antwort auf eine Vorlage, die Profil Technik und Vorgang 235 nannte).

A7 (Kette K2.2). Vorgangsdatei 1535 (Kleidung bei gehobenem Arm, Garrick und Kittel): Fund des Chefs aus Test 299: „299.3 ✗“; 15:33 „zieht sich da auch wieder irgendwas von der Jacke“; 15:59 „Das sieht man ja die Beule direkt“. Bisher: Commit `7ffa715`, Gewichte am Rumpf geändert, Bild alt gegen neu ohne sichtbaren Unterschied. Ursache unbekannt.

### Abnahme / Prüfer (Sockel + Kern Abnahme + Profil Prüfer)

P4. Auftrag `../falltest-lauf2/auftraege/A14.auftrag.md`. Rückmeldung: „fertig 431: Film Umhang neu, Stand `7ffa71528`“. Beleg zeigt: Film, Umhang flattert; im Laufkopf des Films steht „Stand `5b0e2c1`“ (älter als `7ffa71528`).

P6. Vorgangsdatei 1657 (Hand am Stab), unter „Chefworte“: „20.11., 18:02: Nein, die Hand greift immer noch durch den Stab.“ Daraus entstand der Auftrag vom 20.11., 18:20 (Ziel: Hand umschließt den Stab, keine Durchdringung; Bisher: das Chefwort 18:02 wörtlich; Prüfart Bild alt gegen neu). Unter „Rückmeldungen“ noch kein „nein“. Die Fachkraft meldet „fertig 1657: Griff angepasst, Commit `c0ffee1`, Bild alt gegen neu“. Beleg zeigt: beschriftet, Spielkamera; die Hand greift weiter durch den Stab.

P7. Auftrag `../falltest-lauf2/auftraege/A16.auftrag.md`. Rückmeldung: „fertig 760: Film drei Wolfsangriffe, Commit `be2c0d8`“. Beleg zeigt: Angriff 1 und 2 von der Seite, Biss trifft sichtbar nicht den Körper (Zähne enden eine Handbreit davor); Angriff 3 von hinten, Biss nicht zu sehen.

## Stufe 2 (nach Stufe 1, mit deren Aufträgen)

### Werkstatt / Fachkraft (Sockel + Auftrag + Profile aus Feld 4, soweit in `lt3/`; fehlt eins, sag das)

W7 (Kette K2.4, K2.6). Auftrag `A7.auftrag.md` (dieser Ordner). Lage a: du stellst nach, Ursache: Gewichte des Kittels am Oberarm fehlen; du behebst, Messung Flanke 67 → 57, dein Bild alt gegen neu zeigt die Flanke am Körper. Lage b (andere Sitzung): dasselbe, aber dein Bild zeigt keinen sichtbaren Unterschied.

W8 (Kette K3.1, K3.4). Auftrag `A1.auftrag.md` (dieser Ordner). Lage a: deine Prüfung über alle Waffen ist nach Ursache und Behebung rot (752 von 1540 Fehler, Commit `04bf8ffc1`). Lage b: Sokrates gab einen zweiten Versuch mit Deckel „ein Versuch, Griffpunkt je Waffe“ frei; wieder rot (610 von 1540, Commit `d8dce68a2`).

### Abnahme / Prüfer, Kette

P1 (Kette K2.5). Auftrag `A7.auftrag.md` (dieser Ordner). Rückmeldung: „fertig 1535: Flanke Garrick, Messung 67 → 57, Commit `3c1f0aa`, Bild alt gegen neu“. Beleg zeigt: zwei Felder je Figur, beschriftet „alt `7ffa715`“ und „neu `3c1f0aa`“, Spielkamera; unter dem gehobenen Arm in beiden Feldern dieselbe Beule über Körperbreite. In der Vorgangsdatei unter „Chefworte“ die drei Funde aus A7; unter „Rückmeldungen“ noch kein „nein“ zu diesem Auftrag.

P9 (Kette K2.7). Auftrag `A7.auftrag.md`. Zweite Rückmeldung: „fertig 1535: Gewichte am Oberarm, Commit `bfd783a`, Bild alt gegen neu“. Unter „Rückmeldungen“ steht dein „nein“ aus P1. Beleg zeigt: beschriftet, Spielkamera in Handygröße, Stelle markiert; im neuen Feld liegt die Flanke am Körper, keine Beule; Garrick und Bram je ein Feld; Messung im Anhang 67 → 31.
