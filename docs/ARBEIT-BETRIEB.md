# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Übergabe (21.10., 06:50, Ford `session_01JuPc2dWZ4zGCTrePMvLdPm`, Tiefe 3):** Selbstneustart getan (Uhr, Archiv, Kosten 4,94 $). Lauf 07:03 als erstes, dann 7-Uhr-Pflichten (Morgenmeldung, Tagesbericht Perikles 7:30). Ablauf 261.5: alle `list_sessions`-Seiten in eine Scratchpad-Datei (7 Felder, letzte Zeile `# has_more: nein`), dann `lauf.py --sperre --besetzung <Datei>`. START Homer „251.1“ nicht ausführen (Logo-Wahl). Tom `session_01Gfch4CwKYkYT12ymxCricf` nicht archivierbar (Prüfer).

**Nächste freie Vorgangsnummer: 276** (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef 17.10., 19:5x: „Habe Pro gekündigt, steht nur noch auf Free“): solange diese Zeile steht, sind alle Ford-2-Regeln ausgesetzt (`LISTE-BETRIEB.md` „Ford 2“ und „Lauf von Ford 2“, „stiller Ausfall“, 10-%-Regel, Messung Ford 2 20.–21.10.); Guthaben und Nutzungsbild nur Max. **Jerry läuft in der Zentrale** (Ford startet ihn, `LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, dann `LISTE-NIEDERLASSUNG.md`

**Sparmodus beendet Sa 17.10., 21:00** (Max-Wechsel; 99d)

**Ford: Pilot** (seit Sa 17.10., 21:05; zuvor Co-Pilot bis 21:00, Chef 15.10., 22:5x; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (108; Übersicht = `docs/chefsache/README.md`, zeigt GitHub unter der Dateiliste; Lesezeichen für den Chef: https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht Diogenes: `docs/PRUEFBERICHT.md`

**Guthaben:** Max 41 % Woche (Zurücksetzung Sa 20:59), Sitzung 39 % (Zurücksetzung 15:59), Fable-Woche 0 %; Nutzungsguthaben an, 95,69 Credits, im Monat 4,31 ausgegeben (Bild Chef 20.10., 15:17; Sokrates: Wochenschnitt 0,45 %/h reicht bis Sa, Takt seit 19.10. 0,8 %/h wäre Fr abends bei 100 %); Max 100 % = Stillstand „Guthaben“ (128), kein Ausfall (Verlauf in Git)

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Ford lebt in einer Sitzung** „Ford – Betriebsleiter (21.10., 06:49)“ `session_01JuPc2dWZ4zGCTrePMvLdPm` (seit 21.10., 06:49, Selbstneustart, Tiefe 3; Vorgänger `session_01BanaBSh5ndE9rkR6gz4TEx` archiviert, 4,94 $ auf Betrieb). Stundenuhr „Ford-Lauf“ `trig_01GoqgvxAEf6k8k1z7meQBTj` (:03, seit 21.10., 06:46; alte Uhr gelöscht).
- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (seit 16.10., 21:19; 15.10., 22:5x zurückgeholt, D13.2).
- **(ruht, 159)** Ford 2: Stundenuhr aus, Regeln `LISTE-BETRIEB.md` „Lauf von Ford 2“ (Verlauf in Git).
- **(ruht, 159)** Ford 2 (Pro): Sitzung `session_017VRJsTBwEbU16mwomLknhm`, Uhr `trig_01WCdVmLssvGbjCSK9KJPCPH`; bei Wiedereinschalten neu prüfen.

## Eingang

Anregungen ohne Bereich und Startwünsche (eine Zeile, Datum, Absender). Ford teilt im nächsten Lauf zu oder legt sie dem Chef vor.

- 21.10., 06:55, von Sokrates (261.2): Archiv 06:43 hat 14 von 15 Sitzungen gebucht (73,10 $); `session_01Gfch4CwKYkYT12ymxCricf` (Tom, 0,45 $) hat eine Archiv-Marke, ist aber nicht archiviert (Prüfer verweigert, 273) und nicht gebucht: nach 273 nachholen.
- 19.10., von Perikles (197): Sokrates-Sitzungen 07:23 und 07:59 vom 19.10. sind gebucht (`--kosten … ID`, Buchungsverzeichnis). Rest von Hand: 18.10.-Sitzungen (z. B. `session_01RQqCXxXZqPqJVuRnifwazJ` 5,77 $) und 09:00 beim Archivieren; `lauf.py` bucht künftig selbst.

- 17.10., 09:3x, von Perikles (99h, Zuruf Chef): Messung Leitung 20.10., 00:00 – 21.10., 24:00: Ford trägt beim eigenen Neustart und am Ende der Messung seine `cost_usd` in die Zeile „Betrieb“ von `LISTE-VORGAENGE.md` ein („Ford x $“; Ford 2 entfällt, solange die Niederlassung ruht, 159); Auswertung Perikles 22.10.

## Protokoll
Eine Zeile je Lauf mit Tat, neueste oben, höchstens 20 Zeilen; ältere streichen (Verlauf in Git, 117).

- 07:46 21.10.: Neustart Sokrates 51c29ef4 (Übergabe ok) → „Sokrates – Stab des Chefs (21.10., 07:45)“ `session_01FBJTTeysqZ1wsP2xz1Dkgg`; Vorgänger `session_01FTwHHosRoA84Gmtuxzfwyx` wird von `lauf.py` nach 60 Min Ruhe archiviert
- 07:45 21.10.: Lauf 07:40 (Bitte Sokrates 274): gestartet Perikles „274“ `session_01Dd7unB5rBoNr7PwvwzGCQb`, Tom „Build 53 Busch, Tempel, 267“ `session_015eGMBys6yb4cnRTfHjAAom`, Jerry „Build 53 nach Test Build 52“ `session_01UGoyde64WtNrQxMtPr28QR` (Abo PR #140 übergeben), Perikles Tagesbericht `session_01YRrqtM95ASAHCqoiDtZ8JY`; archiviert Jerry 012N8… (1,44 $ Betrieb), Perikles 261.4, Sokrates 01GoFx… (7,19 $); gebucht Sokrates 4,12 $, Perikles 10,66 $ (261.5); Abweichung: START Homer „251.1“ nicht ausgeführt, Tom `session_01Gfch4CwKYkYT12ymxCricf` nicht archiviert (Prüfer verweigert); Warnungen: 2 Sokrates-Sitzungen seit 06:41
- 07:08 21.10.: Lauf 07:03: gebucht Sokrates 1,82 + 4,26 $ (Betrieb), Jerry 5,11 $ (272), Tom 1,86 $ (269); nichts gestartet (Tom, Jerry, Perikles belegt, Diogenes nichts); Abweichung: START Homer „251.1“ nicht ausgeführt (Logo-Wahl); Tom `session_01Gfch4CwKYkYT12ymxCricf` nicht archiviert (Prüfer verweigerte schon, nicht wiederholt); Warnung: Jerry `session_012N8…` ohne Nummer im Titel, 1,44 $ nicht buchbar; 273/274 fehlen in LISTE-VORGAENGE.md (Perikles)
- 07:00 21.10.: Neustart Jerry 91e05b56 (Übergabe ok) → Nachfolger „Jerry – Build 53 nach Test Build 52“ lief schon (`session_012N8WcBCdrYShkcpUVKCRTg`), kein zweiter Start; Vorgänger `session_01TUxZpBni5mMCRh7WU7eXJb` wird nach 60 Min Ruhe archiviert
- 06:52 21.10.: Lauf 06:43 (261.5-Probe, 467 Zeilen, has_more nein): archiviert 14 (Diogenes 235, Jerry 249 ×2, Betrieb ×2 (44/43), 242.1, 242, 237, 37, MARS-36, Perikles 261.2/M?/Rückblick, Sokrates 017M3n…), Kosten gebucht; nicht archiviert: Tom `session_01Gfch4CwKYkYT12ymxCricf` (Prüfer verweigert, „Interfere With Workloads“); Abweichung: START Homer „251.1“ nicht ausgeführt; WARNUNG-LAUT Vorentscheid 261.5 ohne billigen-Datei gemeldet
- 06:50 21.10.: Selbstneustart Ford → `session_01JuPc2dWZ4zGCTrePMvLdPm`; neue Uhr `trig_01GoqgvxAEf6k8k1z7meQBTj`, alte gelöscht, Vorgänger archiviert (4,94 $ auf Betrieb)
- 06:44 21.10.: Lauf 06:41 vorgezogen auf Bitte Sokrates (269 Rückläufer): gestartet Tom „269“ `session_01KSvFKuoXMHAqUP4HeEzvHt`, Jerry „272“ `session_01TUxZpBni5mMCRh7WU7eXJb`; Abweichung: START Homer „251.1“ nicht ausgeführt; Liste nur neueste 8 Sitzungen (Seite abgeschnitten, Plan unvollständig)
- 06:20 21.10.: Neustart Sokrates ec7aefac (Übergabe ok) → „Sokrates – Stab des Chefs (21.10., 06:20)“ `session_013fMPdgV5ohiRwfZYNBEGJZ`; Vorgänger `session_01GoFxDFYo9AUMLuZbHm6PaG` archiviert `lauf.py` nach 60 Min Ruhe
- 06:20 21.10.: Lauf 06:17 vorgezogen auf Bitte Sokrates (Chef 06:15, 261.5): Perikles „261.5“ `session_018787fwrdiqz1S7kR5mk5AW` gestartet (Plan sagte „belegt“ durch 261.4-Sitzung, die fertig war, 114 Tsd. Token; Abweichung auf Bitte); archiviert Jerry 259 (6,16 $), Perikles 165 (0,53 $); Sokrates 017M3n… bleibt (Prüfer verweigert); Diogenes 261.5 erst nach Stand „gebaut“
- 06:05 21.10.: Lauf 06:03 (Läufe 03:03–05:03 ohne Tat): Perikles „261.4“ `session_01DPnfkQDR5TUZb2VmTfa5gJ` gestartet; Sokrates „Stellungnahme“ `session_01GoFxDFYo9AUMLuZbHm6PaG` vom Chef angesprochen (04:01, blockiert, fragt nach Archivierung alter Sitzungen); Sokrates 017M3n… (Chefsitzung) weiter nicht archiviert; Abweichung: START Homer „251.1“ nicht ausgeführt
- 02:08 21.10.: Lauf 02:03: nichts gestartet (Perikles 165 und 177M auf 23.10./22.10. geparkt, Sokrates Stellungnahme 259a erledigt); archiviert Sokrates (Nacht) 23:22 (0,92 $ auf 235); Sokrates 017M3n… (Chefsitzung) bleibt; Abweichung: START Homer „251.1“ nicht ausgeführt (wartet auf Logo-Wahl)
- 01:08 21.10.: Lauf 01:03: gestartet Perikles „165“ `session_01FT861AhXTmDnBQC4Z2zAif` (Termin 21.10. erreicht), Sokrates „Stellungnahme“ (259a) `session_01GoFxDFYo9AUMLuZbHm6PaG`; archiviert Jerry 137 (5,60 $), Sokrates 21:50 (5,64 $), Tom 267 (7,32 $); Sokrates 017M3n… (Chefsitzung) bleibt; Jerry 01RB44… hält Hindernis 259a; Abweichung: START Homer „251.1“ nicht ausgeführt
- 00:08 21.10.: Lauf 00:03: Diogenes „186.4“ `session_015zEmD77iXwRhkDjVcmTEb7` gestartet; archiviert Jerry 256 (10,22 $) und Tom 21:05 (10,56 $ Betrieb); Sokrates 017M3n… (Chefsitzung) nicht archiviert (Prüfer verweigerte am 23:10, 12-Std-Regel); Abweichung: START Sokrates „Stellungnahme“ (259a) nicht ausgeführt, Sokrates (Nacht) `session_01QKu5oTHzbW4E8LXTbzBHEy` läuft und hat die Nacht-Auslegung; START Homer „251.1“ und Perikles „M?“ nicht ausgeführt
- 23:38 20.10.: Neustart Tom 7a29fe40 (Übergabe ok) → „Tom – Build 53 Busch, Tempel, 267 (20.10., 23:37)“ `session_01Gfch4CwKYkYT12ymxCricf`; Vorgänger `session_01S5XrD6NjDncYAJVD4hxbEo` archiviert `lauf.py` nach 60 Min Ruhe
- 23:33 20.10.: Neustart Jerry 1a09b670 (Übergabe ok; startbar.py: Jerry nichts Startbares, Nachfolger nur zum Abo PR #140) → „Jerry – Build 53 nach Test Build 52 (20.10., 23:32)“ `session_012N8WcBCdrYShkcpUVKCRTg`; Vorgänger `session_01RB44eqskHrkrXFFUL4Ax99` archiviert `lauf.py` nach 60 Min Ruhe
- 23:22 20.10.: Neustart Sokrates c2f6a9b (Übergabe ok) → „Sokrates – Stab des Chefs (Nacht) (20.10., 23:22)“ `session_01QKu5oTHzbW4E8LXTbzBHEy`; Vorgänger `session_01J8Cj37E1Cxw81hjnRdVpTe` archiviert `lauf.py` nach 60 Min Ruhe
- 23:10 20.10.: Lauf 23:03: archiviert Jerry 01Pt9… und 01YUnd… (1,36 + 5,46 $ auf 249); Sokrates 017M3n… (Sitzung des Chefs, Desktop) Archivierung vom Berechtigungsprüfer verweigert, nicht wiederholt (nächster Lauf prüft, 197: 12 Std Ruhe); Abweichung: START Tom „Build 51 Rückmeldung und 267“ nicht ausgeführt (Nachfolger `session_01S5XrD6NjDncYAJVD4hxbEo` läuft seit 22:18, wartet auf Test des Chefs), START Homer „251.1“ und Perikles „M?“ nicht ausgeführt; Warnung: Tom 21:05 ohne Nummer im Titel, 10,56 $ auf Betrieb
- 23:07 20.10.: Neustart Jerry 22da52b9 (Übergabe ok) → „Jerry – 259 schwache Gegner, PR #140 abonnieren (20.10., 23:06)“ `session_01RB44eqskHrkrXFFUL4Ax99`; Vorgänger `session_01PQ4AM8yJi5QJyNaNSRNBqA` archiviert `lauf.py` nach 60 Min Ruhe (Uhrzeit der Zeile 23:10 darüber ist 23:05, Tippfehler)
- 22:34 20.10.: Neustart Jerry 5cbba7e6 (Übergabe ok; Hinweis „Kennung zeigt auf alten Ford“ geprüft, Kennung stimmt) → „Jerry – PR #137 zusammenführen, Rückläufer 19e (20.10., 22:33)“ `session_01PQ4AM8yJi5QJyNaNSRNBqA`; Vorgänger `session_01LF5WCtNbD9wwTkhGvBijwB` archiviert `lauf.py` nach 60 Min Ruhe
- 22:19 20.10.: Neustart Tom bbada03e (Übergabe ok) → „Tom – Build 51 Rückmeldung und 267 (20.10., 22:18)“ `session_01S5XrD6NjDncYAJVD4hxbEo` (Abo PR #139 in der ersten Nachricht); Vorgänger `session_012YvR9w69kBpL2Caoh7oxXs` archiviert `lauf.py` nach 60 Min Ruhe
- 22:06 20.10.: Lauf 22:03: Jerry „256“ `session_01LF5WCtNbD9wwTkhGvBijwB` gestartet; `lauf.py` bucht Sokrates 0,40 $ + 7,90 $ (Betrieb), Perikles 1,12 $ (261.2); Abweichung: START Homer „251.1“ (wartet auf Logo-Wahl) und Perikles „M?“ nicht ausgeführt; Warnung: Tom „Build 48 Rückmeldung“ ohne Vorgangsnummer im Titel, 0,81 $ nicht buchbar; Jerry 01YUnd… nicht archiviert (wartet auf Chef 249, 212)
- 21:55 20.10.: Selbstneustart Ford → `session_01BanaBSh5ndE9rkR6gz4TEx`; neue Uhr `trig_01RPBH6ZFaVPkxjVNU3GsUbA`, alte gelöscht, Vorgänger archiviert (6,95 $ auf Betrieb)
- 00:04 20.10.: Startsperre 00:04 Start Tom, Jerry, Perikles (lauf.py)
- 01:04 20.10.: Startsperre 01:04 Start Tom, Jerry (lauf.py)
- 07:07 20.10.: Startsperre 07:07 Start Tom, Jerry, Homer (lauf.py)
- 08:05 20.10.: Startsperre 08:05 Start Tom, Perikles (lauf.py)
- 08:05 20.10.: Marke Rückblick 20.10. (lauf.py)
- 10:04 20.10.: Startsperre 10:04 Start Jerry, Diogenes (lauf.py)
- 11:04 20.10.: Startsperre 11:04 Start Perikles (lauf.py)
- 12:07 20.10.: Startsperre 12:07 Start Tom, Perikles (lauf.py)
- 12:25 20.10.: Startsperre 12:25 Start Perikles (lauf.py)
- 13:05 20.10.: Startsperre 13:05 Start Perikles (lauf.py)
- 14:08 20.10.: Startsperre 14:08 Start Perikles (lauf.py)
- 14:2x 20.10.: Marke Tagesbericht 20.10. (Perikles läuft, 247.1)
- 15:06 20.10.: Startsperre 15:06 Start Tom, Homer, Perikles (lauf.py)
- 16:06 20.10.: Startsperre 16:06 Start Jerry, Homer, Perikles (lauf.py)
- 16:06 20.10.: Marke Stellungnahme Sokrates 20.10. (lauf.py)
- 17:04 20.10.: Startsperre 17:04 Start Homer, Perikles (lauf.py)
- 18:05 20.10.: Startsperre 18:05 Start Homer, Perikles (lauf.py)
- 19:04 20.10.: Startsperre 19:04 Start Tom, Homer, Perikles (lauf.py)
- 20:04 20.10.: Startsperre 20:04 Start Homer, Perikles (lauf.py)
- 21:05 20.10.: Startsperre 21:05 Start Tom, Homer, Perikles (lauf.py)
- 22:05 20.10.: Startsperre 22:05 Start Jerry, Homer, Perikles (lauf.py)
- 23:04 20.10.: Startsperre 23:04 Start Tom, Homer, Perikles (lauf.py)
- 00:04 21.10.: Startsperre 00:04 Start Diogenes, Homer, Perikles (lauf.py)
- 00:04 21.10.: Marke Stellungnahme Sokrates 21.10. (lauf.py)
- 01:04 21.10.: Startsperre 01:04 Start Homer, Perikles (lauf.py)
- 01:04 21.10.: Marke Stellungnahme Sokrates 21.10. (lauf.py)
- 02:04 21.10.: Startsperre 02:04 Start Homer (lauf.py)
- 03:04 21.10.: Startsperre 03:04 Start Homer (lauf.py)
- 04:04 21.10.: Startsperre 04:04 Start Homer (lauf.py)
- 05:03 21.10.: Startsperre 05:03 Start Homer (lauf.py)
- 06:04 21.10.: Startsperre 06:04 Start Homer, Perikles (lauf.py)
- 06:41 21.10.: Startsperre 06:41 Start Tom, Jerry, Homer (lauf.py)
- 06:41 21.10.: Marke Abgleich Vorentscheid 261.5 ohne Datei in chefsache/billigen/ und ohn (lauf.py)
- 06:41 21.10.: Marke Mehrfach Perikles (lauf.py)
- 06:41 21.10.: Marke Mehrfach Sokrates (lauf.py)
- 06:43 21.10.: Startsperre 06:43 Start Homer (lauf.py)
- 06:43 21.10.: Marke Archiv session_011Wa4ZjjitXkCK6D6Z9dPYX (lauf.py)
- 06:43 21.10.: Marke Archiv session_018KLVh7hPtAZZ6yGBatfGT2 (lauf.py)
- 06:43 21.10.: Marke Archiv session_019iGcy3G7p7wXQAi2o8bF5s (lauf.py)
- 06:43 21.10.: Marke Archiv session_01UGTNnqmF2i767MkAeQirCa (lauf.py)
- 06:43 21.10.: Marke Archiv session_01UbBkfNV99wrcTUrb1HC1J9 (lauf.py)
- 06:43 21.10.: Marke Archiv session_011NmzzqNotL73vXRVX59Gfe (lauf.py)
- 06:43 21.10.: Marke Archiv session_01BW6F55jH2ksgWXJ6ZAXZfQ (lauf.py)
- 06:43 21.10.: Marke Archiv session_01CGt1hVRCcDVc4Q4AWhutxf (lauf.py)
- 06:43 21.10.: Marke Archiv session_01WppNUrFQRJyAoo5vYziobf (lauf.py)
- 06:43 21.10.: Marke Archiv session_01MwbtvpaanxxTqUHi6pW8ft (lauf.py)
- 06:43 21.10.: Marke Archiv session_01QaRnkD9wrDnCRyinLNKmRV (lauf.py)
- 06:43 21.10.: Marke Archiv session_01A5ong1q9m9RZekWgTXF7YA (lauf.py)
- 06:43 21.10.: Marke Archiv session_01W8vSY1YAszG5Sbo3w3m4rg (lauf.py)
- 06:43 21.10.: Marke Archiv session_017M3nVPshNipt4X8Lf78Zeh (lauf.py)
- 06:43 21.10.: Marke Archiv session_01Gfch4CwKYkYT12ymxCricf (lauf.py)
- 06:43 21.10.: Marke Mehrfach Jerry (lauf.py)
- 07:05 21.10.: Startsperre 07:05 Start Homer (lauf.py)
- 07:40 21.10.: Startsperre 07:40 Start Tom, Jerry, Homer, Perikles (lauf.py)
- 07:40 21.10.: Marke Tagesbericht 21.10. (lauf.py)
- 07:40 21.10.: Marke Archiv session_012N8WcBCdrYShkcpUVKCRTg (lauf.py)
- 07:40 21.10.: Marke Archiv session_01DPnfkQDR5TUZb2VmTfa5gJ (lauf.py)
- 07:40 21.10.: Marke Archiv session_01GoFxDFYo9AUMLuZbHm6PaG (lauf.py)
- 07:40 21.10.: Marke Archiv-Warnung session_01Gfch4CwKYkYT12ymxCricf (lauf.py)
- 07:40 21.10.: Marke Mehrfach-Warnung Sokrates session_013fMPdgV5ohiRwfZYNBEGJZ (lauf.py)
- 07:40 21.10.: Marke Mehrfach Sokrates (lauf.py)
