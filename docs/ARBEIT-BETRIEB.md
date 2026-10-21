# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Übergabe (21.10., 06:50, Ford `session_01JuPc2dWZ4zGCTrePMvLdPm`, Tiefe 3):** Selbstneustart getan (Uhr, Archiv, Kosten 4,94 $). Lauf 07:03 als erstes, dann 7-Uhr-Pflichten (Morgenmeldung, Tagesbericht Perikles 7:30). Ablauf 261.5: alle `list_sessions`-Seiten in eine Scratchpad-Datei (7 Felder, letzte Zeile `# has_more: nein`), dann `lauf.py --sperre --besetzung <Datei>`. START Homer „251.1“ nicht ausführen (Logo-Wahl). Tom `session_01Gfch4CwKYkYT12ymxCricf` nicht archivierbar (Prüfer). Sokrates `session_01FBJTTeysqZ1wsP2xz1Dkgg` nicht vor 19:05 archivieren (Erinnerung 251.2 um 19:00). START Tom „Test Build 56“ und Homer „251.1“ nicht ausführen (Sitzung besteht bzw. wartet).

**Nächste freie Vorgangsnummer: 282** (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef 17.10., 19:5x: „Habe Pro gekündigt, steht nur noch auf Free“): solange diese Zeile steht, sind alle Ford-2-Regeln ausgesetzt (`LISTE-FORD2.md`, „stiller Ausfall“, 10-%-Regel, Messung Ford 2 20.–21.10.); Guthaben und Nutzungsbild nur Max. **Jerry läuft in der Zentrale** (Ford startet ihn, `LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, Einrichtung aus Git (`LISTE-NIEDERLASSUNG.md` bis `f3ec7200`)

**Sparmodus beendet Sa 17.10., 21:00** (Max-Wechsel; 99d)

**Ford: Pilot** (seit Sa 17.10., 21:05; zuvor Co-Pilot bis 21:00, Chef 15.10., 22:5x; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (108; Übersicht = `docs/chefsache/README.md`, zeigt GitHub unter der Dateiliste; Lesezeichen für den Chef: https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht Diogenes: `docs/PRUEFBERICHT.md`

**Guthaben:** Max 59 % Woche (Zurücksetzung Sa 21:00), Sitzung 11 % (Zurücksetzung 16:59), Sonderkontingent Woche 0 %; Nutzungsguthaben an, Ausgabenlimit unbegrenzt, 95,69 Credits, im Monat 4,31 ausgegeben, seit gestern nichts (Bild Chef 21.10., 15:25; Sokrates: seit 20.10. 0,75 %/h, so Fr gegen 22:00 bei 100 %; für Sa 21:00 höchstens 0,53 %/h, also rund 30 % weniger); Max 100 % = Stillstand „Guthaben“ (128), kein Ausfall (Verlauf in Git)

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Ford lebt in einer Sitzung** „Ford – Betriebsleiter (21.10., 06:49)“ `session_01JuPc2dWZ4zGCTrePMvLdPm` (seit 21.10., 06:49, Selbstneustart, Tiefe 3; Vorgänger `session_01BanaBSh5ndE9rkR6gz4TEx` archiviert, 4,94 $ auf Betrieb). Stundenuhr „Ford-Lauf“ `trig_01GoqgvxAEf6k8k1z7meQBTj` (:03, seit 21.10., 06:46; alte Uhr gelöscht).
- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (seit 16.10., 21:19; 15.10., 22:5x zurückgeholt, D13.2).
- **(ruht, 159)** Ford 2: Stundenuhr aus, Regeln `LISTE-FORD2.md`.
- **(ruht, 159)** Ford 2 (Pro): Sitzung `session_017VRJsTBwEbU16mwomLknhm`, Uhr `trig_01WCdVmLssvGbjCSK9KJPCPH`; bei Wiedereinschalten neu prüfen.

## Eingang

Anregungen ohne Bereich und Startwünsche (eine Zeile, Datum, Absender). Ford teilt im nächsten Lauf zu oder legt sie dem Chef vor.

- 21.10., 06:55, von Sokrates (261.2): Archiv 06:43 hat 14 von 15 Sitzungen gebucht (73,10 $); `session_01Gfch4CwKYkYT12ymxCricf` (Tom, 0,45 $) hat eine Archiv-Marke, ist aber nicht archiviert (Prüfer verweigert, 273) und nicht gebucht: nach 273 nachholen.
- 19.10., von Perikles (197): Sokrates-Sitzungen 07:23 und 07:59 vom 19.10. sind gebucht (`--kosten … ID`, Buchungsverzeichnis). Rest von Hand: 18.10.-Sitzungen (z. B. `session_01RQqCXxXZqPqJVuRnifwazJ` 5,77 $) und 09:00 beim Archivieren; `lauf.py` bucht künftig selbst.

- 17.10., 09:3x, von Perikles (99h, Zuruf Chef): Messung Leitung 20.10., 00:00 – 21.10., 24:00: Ford trägt beim eigenen Neustart und am Ende der Messung seine `cost_usd` in die Zeile „Betrieb“ von `LISTE-VORGAENGE.md` ein („Ford x $“; Ford 2 entfällt, solange die Niederlassung ruht, 159); Auswertung Perikles 22.10.

## Protokoll
Eine Zeile je Lauf mit Tat, neueste oben, höchstens 20 Zeilen; ältere streichen (Verlauf in Git, 117).

- 17:29 21.10.: Neustart Tom 1684132a (Übergabe ok) → „Tom – Test Build 62 (21.10., 17:28)“ `session_01YBEEiZkLQA5q2BUEU4PFya` (Abo PR #145, #147 in der ersten Nachricht); Vorgänger `session_01S4Dqi3eqRAbdbrxuz2Z7Rh` wird archiviert, sobald `lauf.py` es plant (261.5 Wartezeit)
- 17:15 21.10.: Bitte Sokrates (Chef fragt): Perikles „261.5 Wartezeit“ `session_01GAaW5Uxp32AN5BeTQL6Eb8` gestartet (der START „Perikles M?“ von 17:06 war Muss 261.5; startbar.py bestätigt); Regel neu (Vorgangsarchiv 261.5, Wartezeit): alte Sitzung archivieren, sobald der Nachfolger läuft, ohne 60 Min; `lauf.py` setzt Perikles um
- 17:10 21.10.: Lauf 17:06: nichts gestartet; archiviert Tom `session_01Ka8y…` (6,00 $ Betrieb, schon gebucht); gebucht u. a. Ford (mich) 11,23 $, Tom 267.1 5,34 + 4,73 $, Jerry 58 7,69 $; Abweichung: ARCHIVIERE Sokrates `session_01FBJT…` bis 19:05 nicht, START Homer „251.1“ und START Perikles „M?“ nicht ausgeführt; Tom `session_01Gfch4CwKYkYT12ymxCricf` nicht archiviert (Prüfer); mehrere Vorgänger-Sitzungen (Jerry, Tom, Sokrates) warten auf 60 Min Ruhe
- 16:55 21.10.: Neustart Jerry 065b3001 (Übergabe ok) → „Jerry – Test Build 61 (21.10., 16:54)“ `session_018p4aUa1h49D6JhhZJaWaEU` (Abo PR #146 in der ersten Nachricht); Vorgänger `session_0161aPTYMQDGzg2vFBHfGtrv` wird von `lauf.py` nach 60 Min Ruhe archiviert
- 16:54 21.10.: Neustart Tom af8bc86d (Übergabe ok) → „Tom – Test Build 60 (21.10., 16:53)“ `session_01S4Dqi3eqRAbdbrxuz2Z7Rh` (Abo PR #145, t60 in der ersten Nachricht); Vorgänger `session_0126no7PvXvuQuFEHJgtES18` wird von `lauf.py` nach 60 Min Ruhe archiviert
- 16:26 21.10.: Neustart Tom dc74a6d1 (Übergabe ok) → „Tom – 267 (21.10., 16:25)“ `session_0126no7PvXvuQuFEHJgtES18` (Abo PR #144 in der ersten Nachricht); Vorgänger `session_01RXW8CH3ZwN2S4EsabFWKmH` wird von `lauf.py` nach 60 Min Ruhe archiviert
- 16:24 21.10.: Neustart Sokrates 2864a633 (Übergabe ok) → „Sokrates – Stab des Chefs (21.10., 16:23)“ `session_01V1YBuH4MxCKijW6wShjWbr`; Vorgänger `session_01D8KJ3zA6biGC8vJVdDhiac` wird von `lauf.py` nach 60 Min Ruhe archiviert; `session_01FBJT…` weiter nicht vor 19:05
- 16:22 21.10.: Neustart Jerry 18fdec9a (Übergabe ok) → „Jerry – Rückläufer t58 (21.10., 16:21)“ `session_0161aPTYMQDGzg2vFBHfGtrv`; Vorgänger `session_01Xyg3G3CMCnJx8WNTmMYdWU` wird von `lauf.py` nach 60 Min Ruhe archiviert
- 16:15 21.10.: Lauf 16:11 (Wecker 7 Min verspätet): nichts gestartet; archiviert Jerry `session_01Dbwf…` (7,92 $ Betrieb); gebucht Tom 6,00 $, Sokrates 5,04 $ (Betrieb); Abweichung: ARCHIVIERE Sokrates `session_01FBJT…` bis 19:05 nicht, START Homer „251.1“ und START Perikles „M?“ nicht ausgeführt; Tom `session_01Gfch4CwKYkYT12ymxCricf` nicht archiviert (Prüfer)
- 16:03 21.10.: Neustart Tom 9153dc5d (Übergabe ok) → „Tom – 267 (21.10., 16:02)“ `session_01RXW8CH3ZwN2S4EsabFWKmH` (Abo PR #142, #144 in der ersten Nachricht); Vorgänger `session_01Ka8yDxiT2gwo1x1ed1BmQB` wird von `lauf.py` nach 60 Min Ruhe archiviert; START Tom „Test Build 57“ im Plan ab jetzt erledigt
- 15:10 21.10.: Lauf 15:06: nichts gestartet, nichts archiviert; gebucht Jerry 1,40 + 7,92 $, Sokrates 1,16 $ (Betrieb); Abweichung: ARCHIVIERE Sokrates `session_01FBJT…` bis 19:05 nicht (Erinnerung 251.2; WARNUNG-LAUT dazu erwartet), START Tom „Test Build 57“ (Sitzung besteht) und START Homer „251.1“ nicht ausgeführt; Tom `session_01Gfch4CwKYkYT12ymxCricf` nicht archiviert (Prüfer)
- 14:50 21.10.: Neustart Jerry d6bec986 (Übergabe ok) → „Jerry – Test Build 58 (21.10., 14:49)“ `session_01Xyg3G3CMCnJx8WNTmMYdWU` (Abo PR #143 und APK-Link t58 in der ersten Nachricht); Vorgänger `session_01Dbwf18zWQRnVqVKjE8ewG9` wird von `lauf.py` nach 60 Min Ruhe archiviert
- 14:12 21.10.: Lauf 14:06: nichts gestartet; archiviert Tom `session_01KjZM…` (5,05 $ Betrieb; Plan sagte ÜBERTRAGE, letzte Nachricht ohne Frage, nur Test Build 57 wartet auf Chef); Abweichung: ARCHIVIERE Sokrates `session_01FBJT…` nicht ausgeführt (bis 19:05, Erinnerung 251.2), START Tom „Test Build 57“ (Sitzung `session_01Ka8y…` besteht) und START Homer „251.1“ nicht ausgeführt; Tom `session_01Gfch4CwKYkYT12ymxCricf` nicht archiviert (Prüfer)
- 13:10 21.10.: Lauf 13:08: nichts gestartet, nichts archiviert; gebucht Tom 0,62 $, Sokrates 0,37 + 6,47 $ (Betrieb); Abweichung: START Homer „251.1“ nicht ausgeführt; Tom `session_01Gfch4CwKYkYT12ymxCricf` nicht archiviert (Prüfer); Sokrates `session_01FBJT…` bleibt bis 19:05
- 12:53 21.10.: Neustart Tom 6c328d2d (Übergabe ok) → „Tom – Test Build 57 (21.10., 12:52)“ `session_01Ka8yDxiT2gwo1x1ed1BmQB` (Abo PR #142 in der ersten Nachricht); Vorgänger `session_01KjZM547UwxrMba54B1sJyb` wird von `lauf.py` nach 60 Min Ruhe archiviert
- 12:37 21.10.: Neustart Sokrates 6c9160b0 (Übergabe ok) → „Sokrates – Stab des Chefs (21.10., 12:36)“ `session_01D8KJ3zA6biGC8vJVdDhiac`; Vorgänger `session_01FBJTTeysqZ1wsP2xz1Dkgg` **nicht vor 19:05 archivieren** (Bitte Sokrates: um 19:00 schickt sie die Erinnerung 251.2, `trig_01AP17WWu3nNzaeuhVsqQToh`); ARCHIVIERE-Zeile dafür bis dahin nicht ausführen
- 12:13 21.10.: Lauf 12:09: nichts gestartet; archiviert Jerry 53 `session_01Hz4m…` (13,54 $ Betrieb) und Tom `session_015eGM…` (6,45 $ auf 267), Kosten schon gebucht; Abweichung: START Tom „Test Build 56“ (Sitzung `session_01KjZM…` besteht, idle) und START Homer „251.1“ nicht ausgeführt; Tom `session_01Gfch4CwKYkYT12ymxCricf` nicht archiviert (Prüfer)
- 11:10 21.10.: Lauf 11:05: nichts gestartet; gebucht Tom 6,45 $ (267), Jerry 13,54 $, Tom/Jerry Betrieb je unter 1 $; Abweichung: START Tom „Test Build 56“ nicht ausgeführt (Sitzung `session_01KjZM…` gleichen Titels besteht, wartet auf Test, idle), START Homer „251.1“ nicht ausgeführt (251 wartet auf Chef, 251.1 wartet); Tom `session_01Gfch4CwKYkYT12ymxCricf` nicht archiviert (Prüfer); Sokrates `session_01FBJT…` blocked seit 08:41; Vorgänger Jerry 53 / Tom 015eG… archiviert der nächste Lauf nach 60 Min
- 10:24 21.10.: Neustart Tom 615fc616 (Übergabe ok) → „Tom – Test Build 56 (21.10., 10:23)“ `session_01KjZM547UwxrMba54B1sJyb` (Abo PR #142 in der ersten Nachricht); Vorgänger `session_015eGMBys6yb4cnRTfHjAAom` wird von `lauf.py` nach 60 Min Ruhe archiviert
- 10:16 21.10.: Neustart Jerry 81e67dd (Übergabe ok) → „Jerry – Test Build 55 (21.10., 10:15)“ `session_01Dbwf18zWQRnVqVKjE8ewG9` (Abo PR #143 in der ersten Nachricht); Vorgänger `session_01Hz4mLDaGPTu22DuYHYg9X8` wird von `lauf.py` nach 60 Min Ruhe archiviert
- 10:12 21.10.: Lauf 10:06: nichts gestartet (Tom, Jerry belegt, Diogenes nichts Startbares); archiviert Jerry 01UGoy… (7,06 $ Betrieb), Perikles 274 (14,01 $); gebucht Sokrates 4,69 $; Abweichung: START Homer „251.1“ (Homer 251 läuft, 251.1 wartet) und START Perikles „M?“ (kein echter Vorgang, wie bisher) nicht ausgeführt; Tom `session_01Gfch4CwKYkYT12ymxCricf` nicht archiviert (Prüfer); Warnungen: 276 (Perikles), 278 (Tom) fehlen in LISTE-VORGAENGE.md; Vorentscheid 261.5 ohne billigen-Datei (schon laut gemeldet)
- 09:12 21.10.: Lauf 09:06: nichts gestartet (Tom, Jerry belegt; Perikles, Diogenes nichts Startbares); gebucht u. a. Perikles 274 14,01 $, Diogenes 5,44 $, Jerry 7,06 $; archiviert Sokrates 01FTwH… (5,37 $ auf 274,275); Abweichung: START Homer „251.1“ nicht ausgeführt (Homer 251 läuft, 251.1 wartet; Plan bleibt falsch, Übergabe in ARBEIT-KREATIV.md nennt noch „Nachfolger 251.1“); Tom `session_01Gfch4CwKYkYT12ymxCricf` nicht archiviert (Prüfer); WARNUNG-LAUT Vorentscheid 261.5 ohne billigen-Datei gemeldet; 276 fehlt in LISTE-VORGAENGE.md
- 08:53 21.10.: Neustart Jerry 7eebafd6 (Übergabe ok) → „Jerry – Test Build 53 (21.10., 08:52)“ `session_01Hz4mLDaGPTu22DuYHYg9X8` (Abo PR #141 in der ersten Nachricht); Vorgänger `session_01UGoyde64WtNrQxMtPr28QR` wird von `lauf.py` nach 60 Min Ruhe archiviert
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
- 08:05 21.10.: Startsperre 08:05 Start Homer (lauf.py)
- 08:05 21.10.: Marke Archiv session_015zEmD77iXwRhkDjVcmTEb7 (lauf.py)
- 08:05 21.10.: Marke Archiv session_01TUxZpBni5mMCRh7WU7eXJb (lauf.py)
- 08:05 21.10.: Marke Archiv session_018787fwrdiqz1S7kR5mk5AW (lauf.py)
- 08:05 21.10.: Marke Archiv session_013fMPdgV5ohiRwfZYNBEGJZ (lauf.py)
- 08:05 21.10.: Marke Archiv session_01KSvFKuoXMHAqUP4HeEzvHt (lauf.py)
- 08:05 21.10.: Marke Mehrfach-Warnung Perikles session_01Dd7unB5rBoNr7PwvwzGCQb (lauf.py)
- 08:05 21.10.: Marke Mehrfach Perikles (lauf.py)
- 08:05 21.10.: Marke Mehrfach-Warnung Sokrates session_01FTwHHosRoA84Gmtuxzfwyx (lauf.py)
- 09:06 21.10.: Startsperre 09:06 Start Homer (lauf.py)
- 09:06 21.10.: Marke Archiv session_01FTwHHosRoA84Gmtuxzfwyx (lauf.py)
- 09:06 21.10.: Marke Mehrfach-Warnung Jerry session_01UGoyde64WtNrQxMtPr28QR (lauf.py)
- 09:06 21.10.: Marke Mehrfach Jerry (lauf.py)
- 09:06 21.10.: Marke Mehrfach Perikles (lauf.py)
- 10:06 21.10.: Startsperre 10:06 Start Homer, Perikles (lauf.py)
- 10:06 21.10.: Marke Archiv session_01UGoyde64WtNrQxMtPr28QR (lauf.py)
- 10:06 21.10.: Marke Archiv session_01Dd7unB5rBoNr7PwvwzGCQb (lauf.py)
- 11:05 21.10.: Startsperre 11:05 Start Tom, Homer (lauf.py)
- 11:05 21.10.: Marke Mehrfach-Warnung Jerry session_01Hz4mLDaGPTu22DuYHYg9X8 (lauf.py)
- 11:05 21.10.: Marke Mehrfach Jerry (lauf.py)
- 11:05 21.10.: Marke Mehrfach Tom (lauf.py)
- 12:09 21.10.: Startsperre 12:09 Start Tom, Homer (lauf.py)
- 12:09 21.10.: Marke Archiv session_01Hz4mLDaGPTu22DuYHYg9X8 (lauf.py)
- 12:09 21.10.: Marke Archiv session_015eGMBys6yb4cnRTfHjAAom (lauf.py)
- 13:08 21.10.: Startsperre 13:08 Start Homer (lauf.py)
- 13:08 21.10.: Marke Mehrfach Sokrates (lauf.py)
- 13:08 21.10.: Marke Mehrfach-Warnung Tom session_01KjZM547UwxrMba54B1sJyb (lauf.py)
- 13:08 21.10.: Marke Mehrfach Tom (lauf.py)
- 14:06 21.10.: Startsperre 14:06 Start Tom, Homer (lauf.py)
- 14:06 21.10.: Marke Archiv session_01FBJTTeysqZ1wsP2xz1Dkgg (lauf.py)
- 14:06 21.10.: Marke Archiv session_01KjZM547UwxrMba54B1sJyb (lauf.py)
- 15:06 21.10.: Startsperre 15:06 Start Tom, Homer (lauf.py)
- 15:06 21.10.: Marke Archiv-Warnung session_01FBJTTeysqZ1wsP2xz1Dkgg (lauf.py)
- 15:06 21.10.: Marke Mehrfach Jerry (lauf.py)
- 16:11 21.10.: Startsperre 16:11 Start Homer, Perikles (lauf.py)
- 16:11 21.10.: Marke Archiv session_01Dbwf18zWQRnVqVKjE8ewG9 (lauf.py)
- 16:11 21.10.: Marke Mehrfach Tom (lauf.py)
- 17:07 21.10.: Startsperre 17:07 Start Homer, Perikles (lauf.py)
- 17:07 21.10.: Marke Archiv session_01Ka8yDxiT2gwo1x1ed1BmQB (lauf.py)
- 17:07 21.10.: Marke Mehrfach-Warnung Jerry session_01Xyg3G3CMCnJx8WNTmMYdWU (lauf.py)
- 17:07 21.10.: Marke Mehrfach Jerry (lauf.py)
- 17:07 21.10.: Marke Mehrfach Sokrates (lauf.py)
- 17:07 21.10.: Marke Mehrfach-Warnung Tom session_01RXW8CH3ZwN2S4EsabFWKmH (lauf.py)
- 17:07 21.10.: Marke Mehrfach Tom (lauf.py)
