# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Übergabe (20.10., 12:05, Ford Tiefe 0, `session_01F4vwHpXuCBa9be1s148bMd`) – Nachfolger: Ford – Betriebsleiter (Selbstneustart, ~380 Tsd. Token):** Lauf 12:04 nicht gemacht, gleich als erstes ausführen. Offen: alte Jerry-Sitzung `session_01CGt1hVRCcDVc4Q4AWhutxf` ab 13 Uhr archivieren, Kosten auf 240/241/242 (vorher prüfen, ob dort eine Frage des Chefs kam, 238). Perikles-Sitzungen `session_01W8vSY1YAszG5Sbo3w3m4rg` (wartet auf Chef 234) und `session_01JWGv4gqaqds5EB62PETeEZ` (238, 236); Diogenes `session_011Wa4ZjjitXkCK6D6Z9dPYX` wartet auf „ja“ 235; Jerry-Build-36/37-Sitzungen (blocked, Chef) nicht archivieren. Bekannte Abweichungen von `lauf.py`: Nachfolger, die nur auf Test des Chefs warten, nicht doppelt starten; Tagesrückblick erst ab 8 Uhr. Lehre 238: vor dem Archivieren auf Neustart prüfen, ob der Chef in der Sitzung gerade testet; im Zweifel bis zum nächsten Lauf offen lassen. `list_sessions` über einen kleinen Helfer (Agent) in Kurzzeilen schreiben lassen spart Platz. **Immer `lauf.py` und `startbar.py` aus `/home/user/bornim-main` rufen.**

**Nächste freie Vorgangsnummer: 250** (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef 17.10., 19:5x: „Habe Pro gekündigt, steht nur noch auf Free“): solange diese Zeile steht, sind alle Ford-2-Regeln ausgesetzt (`LISTE-BETRIEB.md` „Ford 2“ und „Lauf von Ford 2“, „stiller Ausfall“, 10-%-Regel, Messung Ford 2 20.–21.10.); Guthaben und Nutzungsbild nur Max. **Jerry läuft in der Zentrale** (Ford startet ihn, `LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, dann `LISTE-NIEDERLASSUNG.md`

**Sparmodus beendet Sa 17.10., 21:00** (Max-Wechsel; 99d)

**Ford: Pilot** (seit Sa 17.10., 21:05; zuvor Co-Pilot bis 21:00, Chef 15.10., 22:5x; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (108; Übersicht = `docs/chefsache/README.md`, zeigt GitHub unter der Dateiliste; Lesezeichen für den Chef: https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht Diogenes: `docs/PRUEFBERICHT.md`

**Guthaben:** Max 19 % Woche (Zurücksetzung Sa 21:00), Sitzung 24 % (Zurücksetzung 13:00), Fable-Woche 0 %; Nutzungsguthaben an, 95,69 $ verbleibend (Bild Chef 19.10., 11:34, „auf Kurs“); Max 100 % = Stillstand „Guthaben“ (128), kein Ausfall (Verlauf in Git)

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Ford lebt in einer Sitzung** „Ford – Betriebsleiter (20.10., 12:05)“ `session_019CVd49qePmGoF12ubt39RM` (seit 20.10., 12:05, Selbstneustart, Tiefe 1; Vorgänger `session_01F4vwHpXuCBa9be1s148bMd` archiviert, 16,61 $ auf Betrieb). Stundenuhr „Ford-Lauf“ `trig_01NsNw2R6aDi4H2ea3SvnUvK` (:03, seit 20.10., 12:06; alte Uhr gelöscht).
- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (seit 16.10., 21:19; 15.10., 22:5x zurückgeholt, D13.2).
- **(ruht, 159)** Ford 2: Stundenuhr aus, Regeln `LISTE-BETRIEB.md` „Lauf von Ford 2“ (Verlauf in Git).
- **(ruht, 159)** Ford 2 (Pro): Sitzung `session_017VRJsTBwEbU16mwomLknhm`, Uhr `trig_01WCdVmLssvGbjCSK9KJPCPH`; bei Wiedereinschalten neu prüfen.

## Eingang

Anregungen ohne Bereich und Startwünsche (eine Zeile, Datum, Absender). Ford teilt im nächsten Lauf zu oder legt sie dem Chef vor.

- 19.10., von Perikles (197): Sokrates-Sitzungen 07:23 und 07:59 vom 19.10. sind gebucht (`--kosten … ID`, Buchungsverzeichnis). Rest von Hand: 18.10.-Sitzungen (z. B. `session_01RQqCXxXZqPqJVuRnifwazJ` 5,77 $) und 09:00 beim Archivieren; `lauf.py` bucht künftig selbst.

- 17.10., 09:3x, von Perikles (99h, Zuruf Chef): Messung Leitung 20.10., 00:00 – 21.10., 24:00: Ford trägt beim eigenen Neustart und am Ende der Messung seine `cost_usd` in die Zeile „Betrieb“ von `LISTE-VORGAENGE.md` ein („Ford x $“; Ford 2 entfällt, solange die Niederlassung ruht, 159); Auswertung Perikles 22.10.

## Protokoll
Eine Zeile je Lauf mit Tat, neueste oben, höchstens 20 Zeilen; ältere streichen (Verlauf in Git, 117).

- 13:34 20.10.: Neustart Jerry f316d339 (Übergabe ok) → „Jerry – Build 43 Test, Build 44 (20.10., 13:34)“ `session_01UbBkfNV99wrcTUrb1HC1J9`; Vorgänger `session_011NmzzqNotL73vXRVX59Gfe` archiviert `lauf.py` nach 60 Min Ruhe
- 13:31 20.10.: Neustart Sokrates 9ece7355 (Übergabe ok) → „Sokrates – Stab des Chefs (20.10., 13:31)“ `session_01C6XF82G1fhTr5GUAn1F7ya`; Vorgänger `session_0114bkoqREyU63N9oGeBqRFg` archiviert `lauf.py` nach 60 Min Ruhe. Hinweis 247.1 (Perikles-Tagesbericht 7:30, Morgenmeldung eine Zeile) liegt im Vorrat Perikles, bis dahin Morgenmeldung wie bisher
- 13:07 20.10.: Lauf 13:03: nichts gestartet; Abweichung: START Perikles „90“ nicht ausgeführt (Tagesrückblick 20.10. lief 08:05); Altsitzungen Sokrates/Jerry ruhen noch keine 60 Min, `lauf.py` archiviert
- 12:50 20.10.: Neustart Jerry fbb2aec2 (Übergabe ok) → „Jerry – Build 43 nach 242.1 (20.10., 12:50)“ `session_011NmzzqNotL73vXRVX59Gfe`; Vorgänger `session_01BW6F55jH2ksgWXJ6ZAXZfQ` archiviert `lauf.py` nach 60 Min Ruhe (Chef antwortet zu 242.1 in der neuen Sitzung)
- 12:33 20.10.: Neustart Sokrates 66f5a852 (Übergabe ok) → „Sokrates – Stab des Chefs, 246 (20.10., 12:33)“ `session_0114bkoqREyU63N9oGeBqRFg`; Vorgänger `session_01VtoyaniswWybdk3fVtkFku` archiviert `lauf.py` nach 60 Min Ruhe
- 12:26 20.10.: Lauf 12:25: Perikles „M?“ `session_01A5ong1q9m9RZekWgTXF7YA` gestartet; Perikles 238/236 archiviert, 0,57 $ auf 238; Tom 245 (Kür, Sokrates 12:27) wartet: Tom 239 `session_0168taJjYnvKVdkM1TkA1DcZ` idle seit 12:22, Hindernis Chefsache 239, `lauf.py` startet nach 60 Min Ruhe
- 12:15 20.10.: Neustart Sokrates 8f31a01 (Übergabe ok) → „Sokrates – Stab des Chefs, 235 (20.10., 12:15)“ `session_01VtoyaniswWybdk3fVtkFku`; Vorgänger `session_01CSPPMpEyUitFRxFTurw5Gx` archiviert `lauf.py` nach 60 Min Ruhe
- 12:07 20.10.: Selbstneustart (Ford `session_019CVd49qePmGoF12ubt39RM`, Vorgänger archiviert, 16,61 $ auf Betrieb); Lauf 12:04: Tom „239“ gestartet; Abweichung: START Perikles „90“ nicht ausgeführt (Tagesrückblick 20.10. lief 08:05, Perikles-Sitzung `session_01JWGv4gqaqds5EB62PETeEZ` idle seit 10:07, nicht doppelt); Jerry-Vorgänger `session_01CGt1hVRCcDVc4Q4AWhutxf` weiter offen (Hindernis 242/229.3)
- 12:01 20.10.: Neustart Jerry f0d0d39a (Übergabe ok) → „Jerry – Build 43, 242, 19e“ `session_01BW6F55jH2ksgWXJ6ZAXZfQ`; Vorgänger `session_01CGt1hVRCcDVc4Q4AWhutxf` bleibt bis zum nächsten Lauf offen (238: Chef testet B42), dann archivieren
- 11:06 20.10.: Lauf 11:04: Perikles „238 und 236“ `session_01JWGv4gqaqds5EB62PETeEZ` gestartet (238: mein Archivieren 10:58 verlor eine Frage des Chefs an Jerry); Diogenes 149.1 archiviert, 0,71 $
- 10:58 20.10.: Neustart Jerry 8b148cf (Übergabe ok) → „Jerry – Build 42 Test, 237, 229.3, 231“ `session_01CGt1hVRCcDVc4Q4AWhutxf`; Vorgänger archiviert, 4,31 $ auf 211
- 10:05 20.10.: Lauf 10:04: Abweichung: START Jerry „Build 42 Test und 231“ nicht ausgeführt (Jerry `session_01Ea6wh87MKh8cLxdjFqSx7Z` wartet auf Test Build 42 des Chefs, kein zweiter Jerry); Diogenes 149.1 gestartet (235-Diogenes wartet auf „ja“ des Chefs); Sokrates, Perikles warten auf Eingabe
- 09:08 20.10.: Neustart Sokrates 83d8b45 (Übergabe ok) → „Sokrates – Stab des Chefs, 235“ `session_01CSPPMpEyUitFRxFTurw5Gx`; Vorgänger archiviert, 6,46 $ auf 211/231/232/233/235
- 09:07 20.10.: Lauf 09:05: Tom „Sammelbuild 40er“ archiviert (nichts startbar), 0,67 $ auf 215; Eingang D36.5 (Notizkopie im Merge, Abbild mit altem `main`) als 236 an Perikles; Diogenes 235, Perikles, Jerry, Sokrates laufen
- 08:53 20.10.: Auftrag Diogenes 235 (Sokrates, Chef 08:52 „sofort“): Diogenes – 235 `session_011Wa4ZjjitXkCK6D6Z9dPYX` gestartet; Diogenes Widersprüche archiviert, 1,06 $ auf 167
- 08:06 20.10.: Lauf 08:05: Tom „Sammelbuild 40er“ `session_015mhdt55CT2GbP1Ub3DG2oB` und Perikles „Tagesrückblick 20.10.“ (dazu M? 234, 232, 233, 211.14) `session_01W8vSY1YAszG5Sbo3w3m4rg` gestartet; Homer 230 (1,05 $ auf 230) und Tom 39 (2,24 $ auf 215, statt „Betrieb“ aus lauf.py) archiviert
- 07:55 20.10.: Neustart Jerry 2e46cb6 (Übergabe ok) → „Jerry – Builds 40/41 abschließen, Build 42“ `session_01Ea6wh87MKh8cLxdjFqSx7Z`; Vorgänger archiviert, 6,60 $ auf 211 (ohne „Kosten auf:“); Merge Build 41 braucht direktes Wort des Chefs in der Jerry-Sitzung (laut gemeldet)
- 07:50 20.10.: Wort des Chefs („Starte Diogenes wegen Regelprüfung (dein Küreintrag)“): Diogenes „Widersprüche prüfen“ `session_01GtoUAxHyCMeqh2731Zj6C9` gestartet
- 07:10 20.10.: Neustart Sokrates 3a204e3a (Übergabe ok) → `session_01MBRcQZ7YqjDt7yXd2TpAHy`; Vorgänger archiviert, 4,65 $ auf 211/215/230
- 07:08 20.10.: Morgenlauf: Tom „Rückläufer Build 39“ `session_01P5zgGgawc4SKHp4yWboxLT`, Jerry „Builds 40 und 41 betreuen“ `session_01HoSL4JHDbgeUZHnficound`, Homer 230 `session_01XWkqDyCsZxfQBkX3ospxxw` gestartet; Sokrates 18.10. archiviert (9,14 $ war schon gebucht, 197.1); Perikles 90/185 mit `--ohne` bis 8 Uhr bzw. Morgenmeldung; Kosten Woche 297 $ (Spiel 56 %), 17.–19.10.: Ford 32,54 / 34,49 / 21,00 $ (185)
- 06:04 20.10.: Uhr an; nichts Neues seit 02:04
- 02:05 20.10.: Lauf 02:04: keine Sitzung läuft, alles wartet auf Tests des Chefs (39–41) → Uhr aus (99h), einmalig „Uhr an“ `trig_01JNivX62oZi4nQeFZqLmoAB` 06:03
- 01:05 20.10.: Lauf 01:03: Perikles 165 archiviert, 0,42 $; Perikles 90/185 mit `--ohne` ausgeschlossen (Tagesrückblick ab 8 Uhr; 185 braucht Tageskosten der Morgenmeldung); Abweichung: START Tom „Rückläufer Build 39“ und Jerry „Builds 40 und 41 betreuen“ nicht ausgeführt (Builds 39–41 warten auf Test des Chefs, Sitzung hätte nichts zu tun)
- 00:18 20.10.: Neustart-Meldung Jerry fd4e6a28 (Commit auf main): Builds 40/41 warten auf Test des Chefs, 211.14 danach, kein Nachfolger jetzt (Start beim Rückläufer); Sitzung archiviert, 11,22 $ auf 211
- 00:05 20.10.: Abweichung vom Plan lauf.py: START Jerry nicht ausgeführt (Jerry läuft, `session_01Vp3bXB8wsbynvYnA79b5pA`; Titel „Jerry, 211.13 …“ mit Komma statt Gedankenstrich, lauf.py erkennt die Rolle nicht); START Tom „Rückläufer Build 39“ nicht ausgeführt (Build 39 wartet auf Test des Chefs, kein Rückläufer). Perikles 165 gestartet
- 23:34 19.10.: Neustart-Meldung Tom c9f43f34 (Commit auf main): Build 39 wartet auf Test des Chefs, Nachfolger „Rückläufer Build 39“ erst bei Rückläufer; alte Sitzung archiviert, 4,41 $ auf 215
- 23:33 19.10.: Neustart Jerry 5c8288dc (Übergabe ok) → „Jerry – 211.13 Umbau Kampfbild Schritt 2“ `session_01Vp3bXB8wsbynvYnA79b5pA`; Vorgänger archiviert, 4,04 $ auf 211/219.4/223
- 23:18 19.10.: Ford neu (vom Chef, Tiefe 0): Uhr `trig_01Bsfd8PXEifCsCUBYDwFcTM`, alte Uhr gelöscht, Vorgänger archiviert, 4,60 $ auf Betrieb
- 23:17 19.10.: Neustart Jerry 0409cb34 (Übergabe ok, Muss jetzt laut Chef 23:13) → „Jerry – 211.13 Umbau Kampfbild“ `session_01SQCGtsRJFM3kKG3YXkjdyX`; Vorgänger archiviert, 5,19 $ gebucht auf 211
- 23:01 19.10.: Neustart Sokrates b6b597d5 (Übergabe ok) → `session_01DKmAMx96Cn5nCLG5gx5v3q`; Vorgänger archiviert, 5,43 $ gebucht auf 211/229/222/215
- 22:51 19.10.: Sokrates-Bitte (Chef 22:48, 211.12): „Jerry – 211.12 Waldbild“ `session_01VCLAtRoNBWe398wVGmqELx` gestartet; Jerry 22:08 archiviert, 5,75 $ gebucht auf 211/219.4/229
- 22:32 19.10.: zweite Neustart-Meldung Jerry fbab57b6 (ersetzt 842cd5a1): wieder kein Nachfolger (211 wartet auf Wahl des Chefs), Sitzung bleibt offen
- 22:30 19.10.: Neustart-Meldung Jerry 842cd5a1 (Commit auf main): kein Nachfolger, Jerry wartet auf Wahl des Chefs (211); Sitzung `session_01LAxf8Yzxu2z32viW8k52pT` bleibt offen (Hindernis Chefsache), Kosten erst beim Archivieren
- 22:09 19.10.: Neustart Jerry 29de2166 (Übergabe ok) → „Jerry – 211.11 Perspektive“ `session_01LAxf8Yzxu2z32viW8k52pT` (startbar.py zeigt 211.11 nicht, Chef-Vorrang 22:05); Vorgänger archiviert, 9,70 $ gebucht auf 211/219
- 22:04 19.10.: Lauf 22:03: Homer 219.4T (0,93 $) archiviert und gebucht; Tom „Rückläufer Build 38“ `session_01KtWwotzKwRhLED4w6QbEZH` gestartet (Nachfolger-Übergabe); Vorrat leer lautlos gemeldet
- 21:57 19.10.: Neustart Tom a62a9a6f (Commit auf main): alte Sitzung archiviert, 9,71 $ gebucht auf 68/224; kein Nachfolger gestartet (Tom nichts Startbar, Build 38 wartet auf Test des Chefs), lauf.py startet bei Rückläufer
- 21:51 19.10.: Neustart Sokrates 38f23525 (Übergabe ok) → `session_01M2a1ZSmjLwec5REXY3HD3x`; Vorgänger archiviert, 5,93 $ gebucht auf 224/68/211/229/45
- 21:25 19.10.: Neustart-Meldung Jerry 23a9c3d2 (Commit auf main): kein Nachfolger, Jerry hat nichts Startbares und „Jerry – Build 37“ `session_01WppNUrFQRJyAoo5vYziobf` wartet schon; Jerry 211 bleibt offen (Chefsache), Kosten erst beim Archivieren
- 20:50 19.10.: Neustart-Meldung Tom 66df2259 (Übergabe ok, Commit auf main): kein Nachfolger gestartet, Tom hat nichts Startbares (68/224 warten auf Chef); alte Tom-Sitzung bleibt offen (Hindernis: Chefsache), Kosten erst beim Archivieren
- 20:46 19.10.: Neustart Sokrates a2c5f3e2 (Übergabe ok) → `session_01CPqZ8cnCKrDxheRJHMCTmQ`; Vorgänger archiviert, 3,84 $ gebucht auf 211/224/219
- 20:45 19.10.: Sokrates-Bitte Homer 219.4T: gestartet `session_01FzE6b7J98pzBDi1UGSUuqS`; Tom 68, Jerry 211 laufen
- 20:36 19.10.: Sokrates-Bitte „Tom 224.1, Jerry 211.9 starten“: Jerry 211 gestartet `session_01RBQz4JSa1GrwnkAgru2VfN` (Build-37-Jerry wartet auf Chef 212, bleibt); Tom läuft (68 Bildserie, 20:18), kein zweiter Tom
- 20:19 19.10.: Neustart Tom 5ea58d27 (Übergabe ok) → „Tom – 68 Bildserie Tempel“ `session_01P1hTotcqYpGGP2nSpjt15H`; Vorgänger archiviert, 12,36 $ gebucht auf 68/224/227
- 20:11 19.10.: Neustart Jerry 02a8fd80 (Übergabe ok) → „Jerry – Build 37“ `session_01WppNUrFQRJyAoo5vYziobf`; Vorgänger archiviert, 4,91 $ gebucht auf 223/211
- 20:05 19.10.: Lauf 20:03: Homer 225 (2,17 $) und Perikles 228 (0,26 $) fertig (Vorrat leer), archiviert und gebucht; Tom 68, Jerry 211 und Sokrates laufen; „Stillstand Perikles“ = bekannter Fehlalarm (M?)
- 20:03 19.10.: Neustart Sokrates cb14bdae (Übergabe ok) → `session_01Y7frZ2CVfFXv9og1C6TLFQ`; Vorgänger archiviert, 7,50 $ gebucht auf 223, 219T.1, 225, 226, 227, 211, 228, 68
- 19:11 19.10.: Neustart Jerry 57d85691 (Übergabe ok) → „Jerry – 211 Beschriftung“ `session_013piwdWT17oxLFJceZdqBj5`; Vorgänger archiviert, 9,36 $ gebucht auf 223/211
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
