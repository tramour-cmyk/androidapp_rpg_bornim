# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Übergabe (22.10., 07:07, Ford `session_01NQRXehuT7fmxv4JbHP8AJC`) – Nachfolger: Ford – Betriebsleiter (erst bei über 400 Tsd. Token):** Selbstneustart 01:05 getan, Uhr `trig_01AAk1…`; `archive_session` seit 06:29 erlaubt, alles archiviert; Nachfolger-Starts ohne Arbeit mit `--ohne NR:Grund` ausschließen (Chef 06:45). Ablauf 261.5: Sitzungen holen, `conv.py`-artig in Kurzform, `lauf.py --sperre --besetzung`.

**Nächste freie Vorgangsnummer: 302** (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef 17.10., 19:5x: „Habe Pro gekündigt, steht nur noch auf Free“): solange diese Zeile steht, sind alle Ford-2-Regeln ausgesetzt (`LISTE-FORD2.md`, „stiller Ausfall“, 10-%-Regel, Messung Ford 2 20.–21.10.); Guthaben und Nutzungsbild nur Max. **Jerry läuft in der Zentrale** (Ford startet ihn, `LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, Einrichtung aus Git (`LISTE-NIEDERLASSUNG.md` bis `f3ec7200`)

**Sparmodus beendet Sa 17.10., 21:00** (Max-Wechsel; 99d)

**Ford: Pilot** (seit Sa 17.10., 21:05; zuvor Co-Pilot bis 21:00, Chef 15.10., 22:5x; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (108; Übersicht = `docs/chefsache/README.md`, zeigt GitHub unter der Dateiliste; Lesezeichen für den Chef: https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht Diogenes: `docs/PRUEFBERICHT.md`

**Guthaben:** Max 71 % Woche (Zurücksetzung Sa 21:00), Sitzung 1 %, Sonderkontingent Woche 0 %; Nutzungsguthaben an, Ausgabenlimit unbegrenzt, 95,69 Credits, im Monat 4,31 ausgegeben (Bild Chef 22.10., 06:19; Perikles: im Mittel 0,75 %/h, so 80 % heute ~18:20, 100 % Fr ~21:00; für Sa 21:00 höchstens 0,46 %/h; Chefsache 287); Max 100 % = Stillstand „Guthaben“ (128), kein Ausfall (Verlauf in Git) · **Wochenziel bis Sa 24.10., 10:00** (Perikles 19:58, Chef 284): Max Woche ab 80 % → `lauf.py --nur-muss`; ab 95 % nichts Neues starten, nur Rückläufer des Chefs; Credits nur auf Wort des Chefs

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Ford lebt in einer Sitzung** „Ford – Betriebsleiter (22.10., 01:11)“ `session_01NQRXehuT7fmxv4JbHP8AJC` (seit 22.10., 01:05, Selbstneustart, Tiefe 5; Vorgänger `session_01HYFb5aaRhHtZLTweAkiPXD` (6,11 $ Betrieb) noch nicht archiviert: Auto-Modus verweigerte `archive_session`). Stundenuhr „Ford-Lauf“ `trig_01AAk1mSTxpWYoD7LgzGbJcB` (:03, seit 22.10., 01:05; alte Uhr gelöscht).
- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (seit 16.10., 21:19; 15.10., 22:5x zurückgeholt, D13.2).
- **(ruht, 159)** Ford 2: Stundenuhr aus, Regeln `LISTE-FORD2.md`.
- **(ruht, 159)** Ford 2 (Pro): Sitzung `session_017VRJsTBwEbU16mwomLknhm`, Uhr `trig_01WCdVmLssvGbjCSK9KJPCPH`; bei Wiedereinschalten neu prüfen.

## Eingang

Anregungen ohne Bereich und Startwünsche (eine Zeile, Datum, Absender). Ford teilt im nächsten Lauf zu oder legt sie dem Chef vor.

- 22.10., 06:45, Chef (Wortlaut): „Wir haben ja gesagt, wir holen eine neue Sitzung für den gleichen Arbeitsbereich nur rein, wenn das Kosten spart. Ansonsten muss es ja nicht sein.“ Ford schließt künftig Nachfolger-Starts ohne Arbeit mit `--ohne NR:Grund` aus (Jerry „derselbe“ wartet nur auf Test, Homer „auf Abruf“ ohne Vorrat). An Perikles (Werkzeug `lauf.py`): ein Nachfolger-Start nur, wenn `startbar.py` Muss/Kür für die Rolle zeigt oder die Übergabe echte Arbeit nennt; sonst „NICHTS“. Betrifft Starts 02:04 und 06:30.

- 21.10., 20:02, von Sokrates (261.5, Chef): Neustart Sokrates 19:49, Vorgänger `session_01UR9b…` arbeitete bis 19:52 weiter, Chef sah zwei Sitzungen („es gibt noch eine alte Sitzung, das verstehe ich jetzt wieder nicht“); Sokrates archivierte 20:01 von Hand, Chef 20:01 (Wortlaut): „Der Sinn ist immer noch nicht, dass du archivierst. Das kann ich selber auch. Es soll doch automatisch funktionieren.“ Lücke: Regel (2) greift erst im nächsten Stundenlauf. Vorschlag: beim Neustart mit laufendem Vorgänger `send_later` 10 Minuten, dann archivieren (oder Vorgänger meldet Ford „fertig“).
- 21.10., 06:55, von Sokrates (261.2): Archiv 06:43 hat 14 von 15 Sitzungen gebucht (73,10 $); `session_01Gfch4CwKYkYT12ymxCricf` (Tom, 0,45 $) hat eine Archiv-Marke, ist aber nicht archiviert (Prüfer verweigert, 273) und nicht gebucht: nach 273 nachholen.
- 19.10., von Perikles (197): Sokrates-Sitzungen 07:23 und 07:59 vom 19.10. sind gebucht (`--kosten … ID`, Buchungsverzeichnis). Rest von Hand: 18.10.-Sitzungen (z. B. `session_01RQqCXxXZqPqJVuRnifwazJ` 5,77 $) und 09:00 beim Archivieren; `lauf.py` bucht künftig selbst.

- 17.10., 09:3x, von Perikles (99h, Zuruf Chef): Messung Leitung 20.10., 00:00 – 21.10., 24:00: Ford trägt beim eigenen Neustart und am Ende der Messung seine `cost_usd` in die Zeile „Betrieb“ von `LISTE-VORGAENGE.md` ein („Ford x $“; Ford 2 entfällt, solange die Niederlassung ruht, 159); Auswertung Perikles 22.10.

## Protokoll
Eine Zeile je Lauf mit Tat, neueste oben, höchstens 20 Zeilen; ältere streichen (Verlauf in Git, 117).

- 12:00 22.10.: Neustart Jerry 474f511d (Übergabe ok, 217 Tsd. Token, Arbeit t71/t72/299) → „Jerry – Test Build 71 und 72, Klanglogo (22.10., 12:00)“ (Abo PR #155, #156 in der ersten Nachricht); Vorgänger `session_01YQUz8X…` (6,37 $ auf Betrieb) archiviert; Hinweis: `rate_limit_info` Jerry zeigt seven_day `allowed_warning` (Wochenguthaben): Lauf ab jetzt mit `--nur-muss` erwägen, Chef-Bild der Nutzung fehlt
- 11:47 22.10.: Neustart Sokrates e8047db5 (Übergabe ok) → „Sokrates – Stab des Chefs (22.10., 11:47)“; Vorgänger `session_01WoNnvy…` (11,22 $ auf 287, 261.6, 294, 296, 292.1, 292.3) archiviert
- 11:31 22.10.: Neustart Tom b2ae4be7 (Übergabe ok, 288 Tsd. Token, Build 73 mit Arbeit) → „Tom – Test Build 73 (22.10., 11:31)“ (Abo PR #157 in der ersten Nachricht); Vorgänger `session_01FacxpP…` (8,89 $ auf Betrieb) archiviert
- 11:08 22.10.: Lauf 11:05: START Perikles „M?“ (297, 298 neu) → `session_01YFjqfE…`, archiviert Perikles `0149ag…` (3,18 $ auf 261.6); Tom (297) und Jerry (Build 71/72) belegt, sonst NICHTS
- 08:25 22.10.: Neustart Jerry 665079f1 (Übergabe ok, Build 72 mit Arbeit) → „Jerry – Test Build 71 und 72, Klanglogo (22.10., 08:25)“ (Abo PR #155, #156 in der ersten Nachricht); Vorgänger `session_01WhW6HH…` archiviert
- 08:08 22.10.: Lauf 08:05: WEITER Perikles „M?“ und Tagesbericht 22.10. an `session_0149agYD…` (eine Sitzung statt zweier, Chef 06:45; Abweichung von START Tagesbericht); sonst NICHTS (Jerry belegt, Tom wartet auf Test t70, Homer auf Abruf idle)
- 08:01 22.10.: Zuruf Sokrates 08:00 (Chef 07:56): „Weiter: 292.1 Runde 4“ an Jerry `session_01WhW6HH…` gesendet, kein zweiter Start (Muss jetzt, 24 Hörproben bis 09:00)
- 07:43 22.10.: Neustart Jerry 3041d78b (Übergabe ok, 262 Tsd. Token, echte Arbeit Build 71) → „Jerry – Test Build 67 und 71, Klanglogo (22.10., 07:43)“ (Abo PR #151, #155 in der ersten Nachricht); Vorgänger `session_01K6Zw…` (8,10 $ auf Betrieb) archiviert
- 07:41 22.10.: Neustart Tom 027e3afa (Übergabe ok, 293 Tsd. Token, echte Arbeit Build 70) → „Tom – Test Build 70 (22.10., 07:41)“ (Abo PR #154 in der ersten Nachricht); Vorgänger `session_01JiC6RA…` (10,29 $ auf 293) archiviert
- 07:04 22.10.: Neustart Tom 5656a2eb (Übergabe ok, Nachfolger „Tom – Build 293 Hund“ erst nach „293 passt“ des Chefs): kein Start (Chef 06:45, Kosten), Tom `session_01JiC6RA…` bleibt idle stehen, sonst nichts
- 06:35 22.10.: archive_session erlaubt (Chef 06:29 über Sokrates, settings.json): Lauf 06:30: START Tom „293“ `session_01JiC6RA…` und Jerry „derselbe“ `session_01K6Zw6x…` (Jerry-Sitzung `012Dj…` war fertig, Plan startete Nachfolger; Perikles prüfen: Schleife wie bei Homer); archiviert Homer `01U7rU…`, Sokrates `01Vnk2…`, Tom `019rJF…`, Jerry `012Dj…` (alle gebucht); 90 alte Sitzungen waren schon archiviert, Vorgänger Ford `01HYFb…` archiviert (6,11 $ Betrieb)
- 01:14 22.10.: Selbstneustart: neue Uhr `trig_01AAk1…` angelegt und geprüft, alte gelöscht; Vorgänger `session_01HYFb…` (6,11 $) nicht archiviert, Berechtigung verweigert (Auto-Modus), Kosten noch nicht gebucht; Lauf 02:03 folgt
- 01:05 22.10.: Lauf 01:04 (nachts lautlos): START Homer „auf Abruf“ `session_01U7rU7y…` (Vorrat leer, Nachfolger-Start) und Sokrates „Stellungnahme 287“ `session_01WoNnvy…`; archiviert Sokrates `session_013QNc…` (0,76 $ auf 292.1 …) und Homer `session_01VqNh…` (0,45 $); VORRAT-LEER; Homer-Leerlauf-Schleife an Perikles; Selbstneustart Ford folgt
- 00:12 22.10.: Lauf 00:04 (nachts lautlos): START Jerry „Test Build 66 und 67, Klanglogo“ `session_01Um4pJh…`, Homer „auf Abruf“ `session_01VqNhxa…`, Perikles „287“ `session_012fsNWe…`, Sokrates „Stellungnahme 2921“ `session_01Vnk2Wf…` (Nachfolger-Starts nach Übergabe, startbar.py zeigt für Jerry/Homer nichts: Perikles prüfen); archiviert Jerry `01Akh…` (9,44 $), Jerry `019AH…` (0,73 $), Homer `01UaF2…` (1,54 $), Perikles `01C3uE…` (0,96 $ auf 290); Seiten 1 von mehr; Vorentscheid 261.5 ohne Billigungsdatei (laut gemeldet 19:06)
- 23:19 21.10.: Neustart Jerry 45e1e44d (Übergabe ok) → „Jerry – Test Build 66 und 67, Klanglogo (21.10., 23:19)“ (Abo PR #149, #151 in der ersten Nachricht); Vorgänger `session_01Akh…` arbeitet noch (7,80 $, Betrieb), archiviert, sobald fertig
- 23:09 21.10.: Lauf 23:04 (nachts lautlos): START Homer „auf Abruf“ → `session_01UaF27r…` (Muss 292, Kür 251.4 startbar); archiviert Sokrates `session_01TevW…` (9,96 $ Betrieb) und Homer `session_01BeLE…` (1,71 $ auf 251.1), alles gebucht; Seiten 1 von mehr; Vorentscheid 261.5 ohne Billigungsdatei (laut gemeldet 19:06)
- 22:59 21.10.: Neustart Tom 3ed8fb0d (Übergabe ok) → „Tom – Test Build 69 (21.10., 22:58)“ (Abo PR #152, #153 in der ersten Nachricht); Vorgänger `session_01PNQn…` sofort archiviert (4,94 $ Betrieb)
- 22:38 21.10.: zweite Meldung Sokrates „Neustart bb98d1f8 (ersetzt 362f611d)“: kein dritter Start, `session_013QNc…` auf die neue Übergabe verwiesen; Vorgänger `session_01TevW…` arbeitet noch (8,96 $), `lauf.py` 23:03 archiviert ihn
- 22:30 21.10.: Neustart Sokrates 362f611d (Übergabe ok) → „Sokrates – Stab des Chefs (21.10., 22:27)“ `session_013QNcjB3sDRzjwZgrMw54MX`; Vorgänger `session_01TevW…` arbeitet noch (3,39 $, Betrieb), archiviert, sobald fertig
- 22:29 21.10.: Bitte Sokrates „Tom starten, 292 Muss (Chef 22:23)“: Tom `session_01PNQn…` läuft schon (Build 68), „Weiter: 292“ gesendet, kein zweiter Start
- 22:21 21.10.: Neustart Tom 2cb5ef96 (Übergabe ok) → „Tom – Test Build 68 (21.10., 22:19)“ `session_01PNQnQwry85jqvwZvp51qzU` (Abo PR #152 in der ersten Nachricht); Vorgänger `session_014Am1…` sofort archiviert (6,96 $ Betrieb)
- 22:08 21.10.: Lauf 22:04 (nachts lautlos): START Homer „251.1 nach Antwort des Chefs“ → `session_01BeLEkD…` (Chef 21:33 „251 mit A, B und C“); archiviert Homer `session_01KyWF…` (2,09 $ auf 251.1, gebucht); gebucht Jerry, Tom, Sokrates, Ford Betrieb, Perikles 290 (0,96 $); Tom hat Muss 291 (Tom 65 belegt); Seiten 1 von mehr; Vorentscheid 261.5 ohne Billigungsdatei (laut gemeldet)
- 22:05 21.10.: Neustart Jerry e215d20e (Übergabe ok) → „Jerry – Test Build 66 und 67 (21.10., 22:03)“ `session_01AkhLE6gXK3hpDjgrMFWZW2` (Abo PR #149, #151 in der ersten Nachricht); Vorgänger `session_01F4Aj…` sofort archiviert (7,77 $ Betrieb)
- 21:42 21.10.: Neustart Tom 73b05ff3 (Übergabe ok) → „Tom – Test Build 65 (21.10., 21:40)“ `session_014Am1TcdYMBFS7d7PXVkMDV` (Abo PR #150 in der ersten Nachricht); Vorgänger `session_016Tq…` (4,70 $) und Jerry `session_019NMc…` (6,14 $) archiviert, Betrieb gebucht
- 07:07 22.10.: Lauf 07:07 (Morgen, laut gemeldet): START Perikles „261.6“ `session_0149agYD…`, archiviert Perikles `012fsN…` (3,30 $ auf 287); START Jerry „derselbe“ NICHT ausgeführt (wartet nur auf Test, Chef 06:45; `--ohne` hätte gepasst, Marke schon geschrieben), Jerry `01K6Zw…` und Homer `01TunW…` bleiben idle; regelcheck: dieses Vorrat zu groß; Kostenübersicht (kosten.py) heute nicht gelaufen
- 20:04 21.10.: Marke Abgleich Vorentscheid 261.5 ohne Datei in chefsache/billigen/ und ohn (lauf.py)
- 20:04 21.10.: Marke Abgleich Vorentscheid 261.5 ohne Datei in chefsache/billigen/ und ohn (lauf.py)
- 20:04 21.10.: Marke Ohne-Rolle session_01KWTnicjeNy9er7g3bxg3Ui (lauf.py)
- 20:04 21.10.: Marke Ohne-Rolle session_01FXj17FfiPCf5ULqiQV78pJ (lauf.py)
- 20:04 21.10.: Nachfolger-Warnung Homer (Übergabe 21.10., 19:15) (lauf.py)
- 20:16 21.10.: Startsperre 20:16 Start Homer (lauf.py)
- 20:16 21.10.: Marke Tagesbericht 21.10. (lauf.py)
- 20:16 21.10.: Marke Archiv session_01NcgKpjJeyw4t7iFkYExMEm (lauf.py)
- 21:04 21.10.: Startsperre 21:04 Start Tom, Homer, Perikles (lauf.py)
- 21:04 21.10.: Marke Archiv session_01YBEEiZkLQA5q2BUEU4PFya (lauf.py)
- 21:04 21.10.: Marke Archiv session_01GAaW5Uxp32AN5BeTQL6Eb8 (lauf.py)
- 22:04 21.10.: Startsperre 22:04 Start Homer (lauf.py)
- 22:04 21.10.: Marke Archiv session_01KyWFzgsHdLprBg9afchXGH (lauf.py)
- 23:05 21.10.: Startsperre 23:05 Start Homer (lauf.py)
- 23:05 21.10.: Marke Archiv session_01TevWpj86STeR9p4kBN85LM (lauf.py)
- 23:05 21.10.: Marke Archiv session_01BeLEkD3R7Nq4ubYqexD3CD (lauf.py)
- 00:04 22.10.: Startsperre 00:04 Start Jerry, Homer, Perikles (lauf.py)
- 00:04 22.10.: Marke Stellungnahme Sokrates 22.10. (lauf.py)
- 00:04 22.10.: Marke Archiv session_01AkhLE6gXK3hpDjgrMFWZW2 (lauf.py)
- 00:04 22.10.: Marke Archiv session_019AHg5Bdj3xw75udBhUATQ6 (lauf.py)
- 00:04 22.10.: Marke Archiv session_01UaF27rN3nAyGsHzBJq9T1q (lauf.py)
- 00:04 22.10.: Marke Archiv session_01C3uEg7jDCdQev7eKfcriKo (lauf.py)
- 01:04 22.10.: Startsperre 01:04 Start Homer (lauf.py)
- 01:04 22.10.: Marke Stellungnahme Sokrates 22.10. (lauf.py)
- 01:04 22.10.: Marke Archiv session_013QNcjB3sDRzjwZgrMw54MX (lauf.py)
- 01:04 22.10.: Marke Archiv session_01VqNhxabwr7heGigKjoVWHW (lauf.py)
- 02:04 22.10.: Startsperre 02:04 Start Jerry, Homer (lauf.py)
- 02:04 22.10.: Marke Archiv session_015zEmD77iXwRhkDjVcmTEb7 (lauf.py)
- 02:04 22.10.: Marke Archiv session_01UYmtM8t9VXgkFRvSJfRmqa (lauf.py)
- 02:04 22.10.: Marke Archiv-Warnung session_01VqNhxabwr7heGigKjoVWHW (lauf.py)
- 02:04 22.10.: Marke Archiv-Warnung session_01UaF27rN3nAyGsHzBJq9T1q (lauf.py)
- 02:04 22.10.: Marke Archiv-Warnung session_01BeLEkD3R7Nq4ubYqexD3CD (lauf.py)
- 02:04 22.10.: Marke Archiv-Warnung session_01KyWFzgsHdLprBg9afchXGH (lauf.py)
- 02:04 22.10.: Marke Archiv session_01LxNaKu5d94s9CRNbpHDeig (lauf.py)
- 02:04 22.10.: Marke Archiv-Warnung session_01NcgKpjJeyw4t7iFkYExMEm (lauf.py)
- 02:04 22.10.: Marke Archiv session_01AgoLBaoYgcETcat3SLjJp1 (lauf.py)
- 02:04 22.10.: Marke Archiv session_01HfLZdWDE36StEoS5dSLwDL (lauf.py)
- 02:04 22.10.: Marke Archiv-Warnung session_019AHg5Bdj3xw75udBhUATQ6 (lauf.py)
- 02:04 22.10.: Marke Archiv-Warnung session_01AkhLE6gXK3hpDjgrMFWZW2 (lauf.py)
- 02:04 22.10.: Marke Archiv session_01F4AjBQBocnooFoSnSNVCYx (lauf.py)
- 02:04 22.10.: Marke Archiv session_019NMcpZ7ggjH5XUgxeyQnRf (lauf.py)
- 02:04 22.10.: Marke Archiv session_01DbojVMqouBbpLDQrMSNyv3 (lauf.py)
- 02:04 22.10.: Marke Archiv session_01WNiALejbqBRgBeeSxi829t (lauf.py)
- 02:04 22.10.: Marke Archiv session_01LAahRePupiw6QpWuKsCT9L (lauf.py)
- 02:04 22.10.: Marke Archiv session_018p4aUa1h49D6JhhZJaWaEU (lauf.py)
- 02:04 22.10.: Marke Archiv session_0161aPTYMQDGzg2vFBHfGtrv (lauf.py)
- 02:04 22.10.: Marke Archiv session_01Xyg3G3CMCnJx8WNTmMYdWU (lauf.py)
- 02:04 22.10.: Marke Archiv session_01Dbwf18zWQRnVqVKjE8ewG9 (lauf.py)
- 02:04 22.10.: Marke Archiv session_01Hz4mLDaGPTu22DuYHYg9X8 (lauf.py)
- 02:04 22.10.: Marke Archiv session_01UGoyde64WtNrQxMtPr28QR (lauf.py)
- 02:04 22.10.: Marke Archiv session_01TUxZpBni5mMCRh7WU7eXJb (lauf.py)
- 02:04 22.10.: Marke Archiv session_012N8WcBCdrYShkcpUVKCRTg (lauf.py)
- 02:04 22.10.: Marke Archiv session_01RB44eqskHrkrXFFUL4Ax99 (lauf.py)
- 02:04 22.10.: Marke Archiv session_01PQ4AM8yJi5QJyNaNSRNBqA (lauf.py)
- 02:04 22.10.: Marke Archiv session_01LF5WCtNbD9wwTkhGvBijwB (lauf.py)
- 02:04 22.10.: Marke Archiv session_01Pt9ZNMa1mWJGY5oKUvCqm4 (lauf.py)
- 02:04 22.10.: Marke Archiv session_01YUnd5unj7w2hhZTh7Cu1gn (lauf.py)
- 02:04 22.10.: Marke Archiv session_01W3h5VkaPg9ybJp2FRciknz (lauf.py)
- 02:04 22.10.: Marke Archiv session_018KLVh7hPtAZZ6yGBatfGT2 (lauf.py)
- 02:04 22.10.: Marke Archiv session_019iGcy3G7p7wXQAi2o8bF5s (lauf.py)
- 02:04 22.10.: Marke Archiv session_013J6u5nSbDF75h2jkippXkP (lauf.py)
- 02:04 22.10.: Marke Archiv session_01UGTNnqmF2i767MkAeQirCa (lauf.py)
- 02:04 22.10.: Marke Archiv session_01UbBkfNV99wrcTUrb1HC1J9 (lauf.py)
- 02:04 22.10.: Marke Archiv-Warnung session_01C3uEg7jDCdQev7eKfcriKo (lauf.py)
- 02:04 22.10.: Marke Archiv-Warnung session_01GAaW5Uxp32AN5BeTQL6Eb8 (lauf.py)
- 02:04 22.10.: Marke Archiv session_01YRrqtM95ASAHCqoiDtZ8JY (lauf.py)
- 02:04 22.10.: Marke Archiv session_01Dd7unB5rBoNr7PwvwzGCQb (lauf.py)
- 02:04 22.10.: Marke Archiv session_018787fwrdiqz1S7kR5mk5AW (lauf.py)
- 02:04 22.10.: Marke Archiv session_01DPnfkQDR5TUZb2VmTfa5gJ (lauf.py)
- 02:04 22.10.: Marke Archiv session_01FT861AhXTmDnBQC4Z2zAif (lauf.py)
- 02:04 22.10.: Marke Archiv session_01QaRnkD9wrDnCRyinLNKmRV (lauf.py)
- 02:04 22.10.: Marke Archiv session_01CKqnhaNHBkUkTdDxWz2yd2 (lauf.py)
- 02:04 22.10.: Marke Archiv session_01X182VTgfwZMkyGjzXCKAhj (lauf.py)
- 02:04 22.10.: Marke Archiv session_01TvyMbNgLQQut1D9rCQYn7Y (lauf.py)
- 02:04 22.10.: Marke Archiv session_012wDd14uigey2L7BsCfBE6a (lauf.py)
- 02:04 22.10.: Marke Archiv session_018NZUFf8K42mhrXfyWWpjvR (lauf.py)
- 02:04 22.10.: Marke Archiv session_01Vnk2Wfenmz7NvZhgqU6Jkd (lauf.py)
- 02:04 22.10.: Marke Archiv-Warnung session_013QNcjB3sDRzjwZgrMw54MX (lauf.py)
- 02:04 22.10.: Marke Archiv-Warnung session_01TevWpj86STeR9p4kBN85LM (lauf.py)
- 02:04 22.10.: Marke Archiv session_01Fyc4rcVaLbkQjNNUNkjq8v (lauf.py)
- 02:04 22.10.: Marke Archiv session_01UR9buB7nzT8YbmMHtXGW4W (lauf.py)
- 02:04 22.10.: Marke Archiv session_01V1YBuH4MxCKijW6wShjWbr (lauf.py)
- 02:04 22.10.: Marke Archiv session_01D8KJ3zA6biGC8vJVdDhiac (lauf.py)
- 02:04 22.10.: Marke Archiv session_01FBJTTeysqZ1wsP2xz1Dkgg (lauf.py)
- 02:04 22.10.: Marke Archiv session_01FTwHHosRoA84Gmtuxzfwyx (lauf.py)
- 02:04 22.10.: Marke Archiv session_013fMPdgV5ohiRwfZYNBEGJZ (lauf.py)
- 02:04 22.10.: Marke Archiv session_01GoFxDFYo9AUMLuZbHm6PaG (lauf.py)
- 02:04 22.10.: Marke Archiv session_01QKu5oTHzbW4E8LXTbzBHEy (lauf.py)
- 02:04 22.10.: Marke Archiv session_01J8Cj37E1Cxw81hjnRdVpTe (lauf.py)
- 02:04 22.10.: Marke Archiv session_01PGCED31zWWY5xbsuWfcE8x (lauf.py)
- 02:04 22.10.: Marke Archiv session_017M3nVPshNipt4X8Lf78Zeh (lauf.py)
- 02:04 22.10.: Marke Archiv session_01EEETKZXE3Scphtq4PDKxZj (lauf.py)
- 02:04 22.10.: Marke Archiv session_01L9415H92wVGywwQYh7m3Vf (lauf.py)
- 02:04 22.10.: Marke Archiv session_014iwcnFuK1mGuveZFDM4uov (lauf.py)
- 02:04 22.10.: Marke Archiv session_01C6XF82G1fhTr5GUAn1F7ya (lauf.py)
- 02:04 22.10.: Marke Archiv session_01PNQnQwry85jqvwZvp51qzU (lauf.py)
- 02:04 22.10.: Marke Archiv session_014Am1TcdYMBFS7d7PXVkMDV (lauf.py)
- 02:04 22.10.: Marke Archiv session_016TqfD89o7ZQyMnnkEMVxxQ (lauf.py)
- 02:04 22.10.: Marke Archiv-Warnung session_01YBEEiZkLQA5q2BUEU4PFya (lauf.py)
- 02:04 22.10.: Marke Archiv session_01S4Dqi3eqRAbdbrxuz2Z7Rh (lauf.py)
- 02:04 22.10.: Marke Archiv session_0126no7PvXvuQuFEHJgtES18 (lauf.py)
- 02:04 22.10.: Marke Archiv session_01RXW8CH3ZwN2S4EsabFWKmH (lauf.py)
- 02:04 22.10.: Marke Archiv session_01Ka8yDxiT2gwo1x1ed1BmQB (lauf.py)
- 02:04 22.10.: Marke Archiv session_01KjZM547UwxrMba54B1sJyb (lauf.py)
- 02:04 22.10.: Marke Archiv session_015eGMBys6yb4cnRTfHjAAom (lauf.py)
- 02:04 22.10.: Marke Archiv session_01KSvFKuoXMHAqUP4HeEzvHt (lauf.py)
- 02:04 22.10.: Marke Archiv session_01Gfch4CwKYkYT12ymxCricf (lauf.py)
- 02:04 22.10.: Marke Archiv session_01S5XrD6NjDncYAJVD4hxbEo (lauf.py)
- 02:04 22.10.: Marke Archiv session_012YvR9w69kBpL2Caoh7oxXs (lauf.py)
- 02:04 22.10.: Marke Archiv session_01WgagAu8wMNTDJCoTQf73mE (lauf.py)
- 02:04 22.10.: Marke Archiv session_01EzHx1zafrf17pbdgdnkqP5 (lauf.py)
- 02:04 22.10.: Marke Archiv session_01NUy1ES8ipDQoaSsFeju7sc (lauf.py)
- 02:04 22.10.: Marke Archiv session_01KDzCdFDic5c5PTturBU8eq (lauf.py)
- 02:04 22.10.: Marke Archiv session_01U5pRMpXemj6kQkj5g2JeUH (lauf.py)
- 02:04 22.10.: Marke Archiv session_01VwGzQpv3GPFZM7TwTZk6Ja (lauf.py)
- 02:04 22.10.: Marke Archiv session_01Um4pJhJJUsgec5NWaMzXhu (lauf.py)
- 02:04 22.10.: Marke Archiv session_01U7rU7y6mumsi6BdwrmZrrD (lauf.py)
- 06:30 22.10.: Startsperre 06:30 Start Tom, Jerry (lauf.py)
- 06:30 22.10.: Marke Archiv-Warnung session_01U7rU7y6mumsi6BdwrmZrrD (lauf.py)
- 06:30 22.10.: Marke Archiv-Warnung session_01Vnk2Wfenmz7NvZhgqU6Jkd (lauf.py)
- 06:30 22.10.: Marke Archiv session_019rJFNmY9XJwHw3Rw45rjfb (lauf.py)
- 06:30 22.10.: Marke Archiv session_012DjhKTJnY7RtBbU1HBhFxS (lauf.py)
- 07:07 22.10.: Startsperre 07:07 Start Jerry, Perikles (lauf.py)
- 07:07 22.10.: Marke Archiv session_01K6Zw6xdM1e2KrQpqGdyFW4 (lauf.py)
- 07:07 22.10.: Marke Archiv session_012fsNWeETSqwxJHnuwr5fXY (lauf.py)
- 08:05 22.10.: Startsperre 08:05 Start Perikles (lauf.py)
- 08:05 22.10.: Marke Tagesbericht 22.10. (lauf.py)
- 11:04 22.10.: Startsperre 11:04 Start Perikles (lauf.py)
- 11:04 22.10.: Marke Archiv session_0149agYD1VLpomDjgKcTnXL3 (lauf.py)
