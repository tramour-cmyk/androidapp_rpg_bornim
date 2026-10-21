# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Übergabe (21.10., 18:31, Ford `session_01HYFb5aaRhHtZLTweAkiPXD`, Tiefe 4):** Selbstneustart erledigt (Uhr `trig_01Sz4d…`, Vorgänger archiviert). Lauf 19:03 als erstes: alle `list_sessions`-Seiten in eine Scratchpad-Datei (7 Felder, letzte Zeile `# has_more: nein`), `lauf.py --sperre --besetzung <Datei>`, jede Zeile so ausführen, wie `lauf.py` sie ausgibt (261.5, Perikles 18:31); Abweichung nur mit `--ohne NR:Grund` und Meldung an Perikles. Sokrates `session_01FBJTTeysqZ1wsP2xz1Dkgg` erst nach 19:05 archivieren (Erinnerung 251.2 um 19:00). Tom `session_01Gfch4CwKYkYT12ymxCricf` nicht archivierbar (Prüfer). Datei kürzen (über 15 KB).

**Nächste freie Vorgangsnummer: 290** (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef 17.10., 19:5x: „Habe Pro gekündigt, steht nur noch auf Free“): solange diese Zeile steht, sind alle Ford-2-Regeln ausgesetzt (`LISTE-FORD2.md`, „stiller Ausfall“, 10-%-Regel, Messung Ford 2 20.–21.10.); Guthaben und Nutzungsbild nur Max. **Jerry läuft in der Zentrale** (Ford startet ihn, `LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, Einrichtung aus Git (`LISTE-NIEDERLASSUNG.md` bis `f3ec7200`)

**Sparmodus beendet Sa 17.10., 21:00** (Max-Wechsel; 99d)

**Ford: Pilot** (seit Sa 17.10., 21:05; zuvor Co-Pilot bis 21:00, Chef 15.10., 22:5x; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (108; Übersicht = `docs/chefsache/README.md`, zeigt GitHub unter der Dateiliste; Lesezeichen für den Chef: https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht Diogenes: `docs/PRUEFBERICHT.md`

**Guthaben:** Max 59 % Woche (Zurücksetzung Sa 21:00), Sitzung 11 % (Zurücksetzung 16:59), Sonderkontingent Woche 0 %; Nutzungsguthaben an, Ausgabenlimit unbegrenzt, 95,69 Credits, im Monat 4,31 ausgegeben, seit gestern nichts (Bild Chef 21.10., 15:25; Sokrates: seit 20.10. 0,75 %/h, so Fr gegen 22:00 bei 100 %; für Sa 21:00 höchstens 0,53 %/h, also rund 30 % weniger); Max 100 % = Stillstand „Guthaben“ (128), kein Ausfall (Verlauf in Git) · **Wochenziel bis Sa 24.10., 10:00** (Perikles 19:58, Chef 284): Max Woche ab 80 % → `lauf.py --nur-muss`; ab 95 % nichts Neues starten, nur Rückläufer des Chefs; Credits nur auf Wort des Chefs

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Ford lebt in einer Sitzung** „Ford – Betriebsleiter (21.10., 18:16)“ `session_01HYFb5aaRhHtZLTweAkiPXD` (seit 21.10., 18:12, Selbstneustart, Tiefe 4; Vorgänger `session_01JuPc2dWZ4zGCTrePMvLdPm` archiviert, 13,45 $ auf Betrieb). Stundenuhr „Ford-Lauf“ `trig_01Sz4dx8Nf2bbhFnSTbiDJZE` (:03, seit 21.10., 18:12; alte Uhr gelöscht).
- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (seit 16.10., 21:19; 15.10., 22:5x zurückgeholt, D13.2).
- **(ruht, 159)** Ford 2: Stundenuhr aus, Regeln `LISTE-FORD2.md`.
- **(ruht, 159)** Ford 2 (Pro): Sitzung `session_017VRJsTBwEbU16mwomLknhm`, Uhr `trig_01WCdVmLssvGbjCSK9KJPCPH`; bei Wiedereinschalten neu prüfen.

## Eingang

Anregungen ohne Bereich und Startwünsche (eine Zeile, Datum, Absender). Ford teilt im nächsten Lauf zu oder legt sie dem Chef vor.

- 21.10., 20:02, von Sokrates (261.5, Chef): Neustart Sokrates 19:49, Vorgänger `session_01UR9b…` arbeitete bis 19:52 weiter, Chef sah zwei Sitzungen („es gibt noch eine alte Sitzung, das verstehe ich jetzt wieder nicht“); Sokrates archivierte 20:01 von Hand, Chef 20:01 (Wortlaut): „Der Sinn ist immer noch nicht, dass du archivierst. Das kann ich selber auch. Es soll doch automatisch funktionieren.“ Lücke: Regel (2) greift erst im nächsten Stundenlauf. Vorschlag: beim Neustart mit laufendem Vorgänger `send_later` 10 Minuten, dann archivieren (oder Vorgänger meldet Ford „fertig“).
- 21.10., 06:55, von Sokrates (261.2): Archiv 06:43 hat 14 von 15 Sitzungen gebucht (73,10 $); `session_01Gfch4CwKYkYT12ymxCricf` (Tom, 0,45 $) hat eine Archiv-Marke, ist aber nicht archiviert (Prüfer verweigert, 273) und nicht gebucht: nach 273 nachholen.
- 19.10., von Perikles (197): Sokrates-Sitzungen 07:23 und 07:59 vom 19.10. sind gebucht (`--kosten … ID`, Buchungsverzeichnis). Rest von Hand: 18.10.-Sitzungen (z. B. `session_01RQqCXxXZqPqJVuRnifwazJ` 5,77 $) und 09:00 beim Archivieren; `lauf.py` bucht künftig selbst.

- 17.10., 09:3x, von Perikles (99h, Zuruf Chef): Messung Leitung 20.10., 00:00 – 21.10., 24:00: Ford trägt beim eigenen Neustart und am Ende der Messung seine `cost_usd` in die Zeile „Betrieb“ von `LISTE-VORGAENGE.md` ein („Ford x $“; Ford 2 entfällt, solange die Niederlassung ruht, 159); Auswertung Perikles 22.10.

## Protokoll
Eine Zeile je Lauf mit Tat, neueste oben, höchstens 20 Zeilen; ältere streichen (Verlauf in Git, 117).

- 20:19 21.10.: Zuruf Chef 20:16 („Homer soll die Logos überarbeiten, jetzt“): Wortlaut in `ARBEIT-KREATIV.md`; Lauf: START Homer „251.3“ → `session_01LxNaKu5d94s9CRNbpHDeig`; archiviert Homer `session_01NcgK…` (1,85 $ auf 251). Homer `session_01FXj1…` (226 Tsd. Token, wartet auf Chef 267.1T) bleibt
- 20:07 21.10.: Lauf 20:04: nichts gestartet, nichts zu archivieren (Sokrates `session_01UR9b…` schon archiviert); gebucht Sokrates/Jerry/Tom/Ford Betrieb, Homer 279 5,05 $, Perikles 8,46 $ (261.5); Warnung: Homer-Sitzung `session_01FXj1…` umbenannt in „Homer, 279 Kampftexte“ (keine Rolle im Titel, bleibt stehen), Homer-Nachfolger 251.1 wartet auf 251.2, Vorentscheid 261.5 ohne Billigungsdatei (schon laut gemeldet); nur 1 Seite (bis 20.10.)
- 19:49 21.10.: Neustart Sokrates 26d30805 (Übergabe ok) → „Sokrates – Stab des Chefs (21.10., 19:48)“ `session_01Fyc4rcVaLbkQjNNUNkjq8v`; Vorgänger `session_01UR9b…` läuft noch (3,67 $, Kosten auf 261.5, 251), archiviert, sobald fertig
- 19:45 21.10.: Neustart Jerry 25c655d7 (Übergabe ok) → „Jerry – Test Build 63 (21.10., 19:44)“ `session_01DbojVMqouBbpLDQrMSNyv3` (Abo PR #148 in der ersten Nachricht); Vorgänger `session_01WNiA…` sofort archiviert (3,54 $ auf 249)
- 19:09 21.10.: Neustart Jerry 6f6a1048 (Übergabe ok) → „Jerry – Test Build 63 (21.10., 19:07)“ `session_01WNiALejbqBRgBeeSxi829t` (Abo PR #148 in der ersten Nachricht); Vorgänger `session_01LAahRe…` sofort archiviert (9,81 $ auf 61; need_input betraf nur diesen Start)
- 19:06 21.10.: Lauf 19:04: START Homer „279“ → `session_01FXj17FfiPCf5ULqiQV78pJ`; archiviert Sokrates `session_01FBJT…` (7,85 $ auf 261.5) und Tom `session_01S4Dq…` (5,63 $ Betrieb); Seiten nur 3 von mehr (bis 16.10., Rest archiviert), Warnung „abgeschnitten“ bewusst; Warnungen: Homer-Nachfolger 251.1 nicht startbar (wartet auf 251.2), Vorentscheid 261.5 ohne Billigungsdatei (laut); Tom `session_01Gfch…` nicht archiviert (Prüfer)
- 18:32 21.10.: Satz „START nicht ausführen“ aus der Übergabe gestrichen (Perikles 261.5); ab jetzt jede Zeile von `lauf.py` ausführen
- 18:30 21.10.: Bitte Perikles/Chef: Sokrates `session_01V1YB…` (idle, completed, keine Frage) archiviert, 7,57 $ auf 261
- 18:23 21.10.: Jerry `session_018p4a…` archiviert (fertig, 1,22 $ Betrieb)
- 18:21 21.10.: zweite Meldung Jerry „Neustart 164c5cfa (ersetzt 48664692)“: kein dritter Start, neue Jerry-Sitzung `session_01LAahRe…` auf die aktualisierte Übergabe verwiesen
- 18:19 21.10.: Neustart Jerry 48664692 (Übergabe ok) → „Jerry – t61 und MARS-Rückläufer (21.10., 18:19)“ `session_01LAahRePupiw6QpWuKsCT9L` (Abo PR #146 in der ersten Nachricht); Vorgänger `session_018p4aUa1h49D6JhhZJaWaEU` (1,22 $, läuft noch) wird von `lauf.py` archiviert, sobald fertig
- 18:14 21.10.: Neustart Sokrates ac152946 (Übergabe ok) → „Sokrates – Stab des Chefs (21.10., 18:11)“ `session_01UR9buB7nzT8YbmMHtXGW4W`; Vorgänger `session_01V1YBuH4MxCKijW6wShjWbr` archiviert der nächste Lauf (261.5 Wartezeit)
- 18:13 21.10.: Selbstneustart Ford (Tiefe 4): neue Uhr `trig_01Sz4d…`, alte gelöscht, Vorgänger archiviert (13,45 $ Betrieb); Lauf 19:03 folgt
- 18:12 21.10.: Lauf 18:07 (neue Regel 261.5 Wartezeit, `lauf.py` archiviert Vorgänger sofort): archiviert Jerry `0161aP…` (7,69 $ auf 58) und `Xyg3G3…` (2,72 $), Perikles Tagesbericht, Sokrates `D8KJ3z…`, Tom `0126no…`/`RXW8CH…` (Kosten schon gebucht); WEITER an Tom Test Build 62 „Weiter: 282“ gesendet; Abweichung: ARCHIVIERE Sokrates `session_01FBJT…` nicht vor 19:05, START Jerry „Test Build 61“ (Sitzung `session_018p4a…` besteht, idle), START Homer „251.1“ und WEITER Perikles „M?“ nicht ausgeführt; Tom `session_01Gfch4CwKYkYT12ymxCricf` nicht archiviert (Prüfer)
- 17:29 21.10.: Neustart Tom 1684132a (Übergabe ok) → „Tom – Test Build 62 (21.10., 17:28)“ `session_01YBEEiZkLQA5q2BUEU4PFya` (Abo PR #145, #147 in der ersten Nachricht); Vorgänger `session_01S4Dqi3eqRAbdbrxuz2Z7Rh` wird archiviert, sobald `lauf.py` es plant (261.5 Wartezeit)
- 17:15 21.10.: Bitte Sokrates (Chef fragt): Perikles „261.5 Wartezeit“ `session_01GAaW5Uxp32AN5BeTQL6Eb8` gestartet (der START „Perikles M?“ von 17:06 war Muss 261.5; startbar.py bestätigt); Regel neu (Vorgangsarchiv 261.5, Wartezeit): alte Sitzung archivieren, sobald der Nachfolger läuft, ohne 60 Min; `lauf.py` setzt Perikles um
- 17:10 21.10.: Lauf 17:06: nichts gestartet; archiviert Tom `session_01Ka8y…` (6,00 $ Betrieb, schon gebucht); gebucht u. a. Ford (mich) 11,23 $, Tom 267.1 5,34 + 4,73 $, Jerry 58 7,69 $; Abweichung: ARCHIVIERE Sokrates `session_01FBJT…` bis 19:05 nicht, START Homer „251.1“ und START Perikles „M?“ nicht ausgeführt; Tom `session_01Gfch4CwKYkYT12ymxCricf` nicht archiviert (Prüfer); mehrere Vorgänger-Sitzungen (Jerry, Tom, Sokrates) warten auf 60 Min Ruhe
- 16:55 21.10.: Neustart Jerry 065b3001 (Übergabe ok) → „Jerry – Test Build 61 (21.10., 16:54)“ `session_018p4aUa1h49D6JhhZJaWaEU` (Abo PR #146 in der ersten Nachricht); Vorgänger `session_0161aPTYMQDGzg2vFBHfGtrv` wird von `lauf.py` nach 60 Min Ruhe archiviert
- 16:54 21.10.: Neustart Tom af8bc86d (Übergabe ok) → „Tom – Test Build 60 (21.10., 16:53)“ `session_01S4Dqi3eqRAbdbrxuz2Z7Rh` (Abo PR #145, t60 in der ersten Nachricht); Vorgänger `session_0126no7PvXvuQuFEHJgtES18` wird von `lauf.py` nach 60 Min Ruhe archiviert
- 16:26 21.10.: Neustart Tom dc74a6d1 (Übergabe ok) → „Tom – 267 (21.10., 16:25)“ `session_0126no7PvXvuQuFEHJgtES18` (Abo PR #144 in der ersten Nachricht); Vorgänger `session_01RXW8CH3ZwN2S4EsabFWKmH` wird von `lauf.py` nach 60 Min Ruhe archiviert
- 16:24 21.10.: Neustart Sokrates 2864a633 (Übergabe ok) → „Sokrates – Stab des Chefs (21.10., 16:23)“ `session_01V1YBuH4MxCKijW6wShjWbr`; Vorgänger `session_01D8KJ3zA6biGC8vJVdDhiac` wird von `lauf.py` nach 60 Min Ruhe archiviert; `session_01FBJT…` weiter nicht vor 19:05
- 20:04 21.10.: Marke Abgleich Vorentscheid 261.5 ohne Datei in chefsache/billigen/ und ohn (lauf.py)
- 20:04 21.10.: Marke Abgleich Vorentscheid 261.5 ohne Datei in chefsache/billigen/ und ohn (lauf.py)
- 20:04 21.10.: Marke Ohne-Rolle session_01KWTnicjeNy9er7g3bxg3Ui (lauf.py)
- 20:04 21.10.: Marke Ohne-Rolle session_01FXj17FfiPCf5ULqiQV78pJ (lauf.py)
- 20:04 21.10.: Nachfolger-Warnung Homer (Übergabe 21.10., 19:15) (lauf.py)
- 20:16 21.10.: Startsperre 20:16 Start Homer (lauf.py)
- 20:16 21.10.: Marke Tagesbericht 21.10. (lauf.py)
- 20:16 21.10.: Marke Archiv session_01NcgKpjJeyw4t7iFkYExMEm (lauf.py)
