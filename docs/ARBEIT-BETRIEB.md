# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Übergabe (27.10., 07:10, Ford `session_017jS8iw2nQqpekHt9g3xtP6`, Tiefe 6):** Uhr übernommen, Neustarts Tom (bis 07:21) und Jerry (bis 04:57) gebucht. Läuft: Tom `session_01Hmoj77PY5ssr7PJqcdqjZW`, Jerry `session_01Hmoj75QZ2wjSV2z4E9bvFE` (Nachfolger wartet auf Chefsache 3487a), Sokrates Nachtvertretung `01X9Na`. Alle anderen alten Sitzungen (Ford, Tom, Jerry, Sokrates, Diogenes) vom Chef von Hand zu archivieren, `archive_session` lehnt der Klassifizierer ab; Kosten steht `lauf.py` bei. Tiefe 6: kein Selbstneustart, Chefsache 110. Nachfolger: Ford – Betriebsleiter.

**Nächste freie Vorgangsnummer: 371** (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef: „Habe Pro gekündigt, steht nur noch auf Free“): Ford-2-Regeln ausgesetzt (`LISTE-FORD2.md`); Guthaben nur Max. **Jerry läuft in der Zentrale** (`LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, Einrichtung aus Git (`LISTE-NIEDERLASSUNG.md` bis `f3ec7200`)

**Ford: Pilot** (seit Sa 17.10., 21:05; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (Übersicht `docs/chefsache/README.md`; https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht: `docs/PRUEFBERICHT.md`

**Sparbetrieb (Chef 23.10., 10:22, Bild: Woche „Alle Modelle“ 100 %, Zurücksetzung Sa 20:59; nur Credits, Guthaben 79,38, Monatslimit unbegrenzt):** „Was angestoßen ist, machen wir fertig, ich prüfe Entwürfe, wir aktualisieren und bauen ein. Dann wird wohl der Spieletest heut bei mir stattfinden.“ Ford startet nur Rückläufer des Chefs und den Build für seinen Spieletest; laufende Sitzungen machen ihren Schritt fertig und übergeben, keine Neustarts ohne Arbeit; Sokrates 318 (20 Uhr) auf So nach 21 Uhr, Auswertung 340 erst nach der Zurücksetzung.

**Guthaben:** **Bild Chef 26.10., 11:43 (an Perikles):** Woche 27 % (Zurücksetzung Sa 31.10., 20:00), Sitzung 12 % (bis 12:00); Hinweis „Limit in der Nacht auf Samstag“. Takt seit 0 % am 25.10., 11:05: 1,1 %/h → 80 % Mi 28.10. ~12, 95 % Do ~02, 100 % Do ~06 (Perikles; Anzeige rechnet langsamer); 287 gilt · **Max 20x seit 25.10., ~11:00**: 287 gilt weiter (80/95-%-Regel: ab 80 % `lauf.py --nur-muss`, ab 95 % nur Rückläufer des Chefs, ab 100 % Stillstand, nichts nachkaufen); Monat bis 25.10. 303,02 $ · ältere Bilder: Git vor „Perikles: Guthaben 26.10.“

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Ford lebt in einer Sitzung** „Ford – Betriebsleiter (27.10., 01:20)“ `session_017jS8iw2nQqpekHt9g3xtP6` (seit 27.10., 01:16, Tiefe 6). Stundenuhr „Ford-Lauf“ `trig_01KJRx9pMTKd5WQKGF4EudtS` (:03). Alte Ford `session_01RxjVWgHtAySkDQkjFTYRpN` (7,01 $ gebucht) und `session_01AyscMQYxPRGvhJzpxGd5pR` stehen idle (Handarchivierung).
- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (D13.2).
- **(ruht, 159)** Ford 2: Stundenuhr aus; Sitzung `session_017VRJsTBwEbU16mwomLknhm`, Uhr `trig_01WCdVmLssvGbjCSK9KJPCPH`; bei Wiedereinschalten neu prüfen.

## Eingang

Anregungen ohne Bereich und Startwünsche (eine Zeile, Datum, Absender). Ford teilt im nächsten Lauf zu oder legt sie dem Chef vor.

- **Nachtvertretung (Sokrates 26.10., 22:45, Chef 22:41 „Sitzungen archivieren und du bist in charge“):** Sokrates `session_01X9NaGNMk4y1nymcSDE4k5b` vertritt den Chef, Bilder und Urteilsbitten dorthin, keine neue Sokrates-Sitzung starten.
- **369:** Chef 26.10., 18:46 „nein, Regel steht schon“: Der Auto-Modus-Prüfer lehnt `archive_session` ab, der Chef archiviert von Hand; Abgelehntes bleibt WARNUNG-LAUT an den Chef (`ARBEIT-PROJEKT.md` „Zu 369“).
- **Werkzeugfehler `lauf.py`, an Perikles (Ford 27.10., 00:04):** Nachfolger-Name mit Terminvermerk („den Stand zum Marktstart 27.10. startet `lauf.py` um 7:30 …“) löst Sofortstart aus; Ford führt ihn nicht aus. Namen kurz halten oder das Werkzeug soll Termin in Klammern erkennen.
- **Werkzeugfehler `lauf.py`, an Perikles (Ford 25.10.):** Offen, Perikles prüft: Doppelbuchung Sokrates alt 7,10 $ auf Betrieb und auf 361/89/362/142. Dazu 27.10.: `lauf.py --kosten` meldet nach jedem Lauf der Neustarts „Kosten …: –“ (nur Gesamtsumme in der Ausgabe, Zeile des Vorgangs nicht sichtbar): bitte prüfen.
- **348.7a (Ford 27.10., 08:17):** „Jerry – 348.7a nach Chefwort 3D oder flach“ erst starten, wenn der Chef `3487a-flugbahn` beantwortet hat; Jerry läuft inzwischen mit 348.7 Riesenfledermaus (`01Hmoj78N`, Perikles).
- **318, von Sokrates (22.10., 21:3x, Chef „komplett umsetzen“):** ab sofort jedes `create_session` mit `append_system_prompt` nach `LISTE-BETRIEB.md` (Zeile „Kennungen“); Antwortstil „Knapp“ steht in `.claude/settings.json`. Zeile nach dem ersten Start mit Anhang streichen.

## Protokoll
Eine Zeile je Lauf mit Tat, neueste oben, höchstens 20 Zeilen; ältere streichen (Verlauf in Git, 117).

- 01:37–06:35 27.10.: Neustarts angenommen und Nachfolger gestartet: Tom 01:46, 02:33, 02:57, 03:23, 03:51, 04:16, 04:43, 05:01, 05:20, 05:44, 06:03, 06:35, 07:21; Jerry 01:37, 02:42, 03:25, 04:57; Jerry 05:55 zurückgestellt (wartet auf Chefsache 3487a). Läufe 02:03, 03:03 ohne Starts; START Perikles (Terminname) nicht ausgeführt
- 25.10., 09:35–21:05: Neustarts Tom/Jerry/Sokrates angenommen; Perikles 364 und Sokrates 340.2 gestartet; Sparbetrieb und Max 20x (Verlauf in Git)

- 09:03 27.10.: Neustart Tom angenommen (8274a5378 auf main): Start nach Perikles' Vorrang als „Tom – 348.6 Kampfbewegungen des Helden für Jerry (27.10., 09:03)“ statt „Helmform, Saum Kettenhemd“
- 08:50 27.10.: Neustart Jerry angenommen (Übergabe e961978b4 auf main; genannter Commit 614ef2956 nicht auf origin): Start „Jerry – 348.7 Riesenfledermaus Runde 3 (27.10., 08:50)“
- 08:17 27.10.: Start „Jerry – 348.7 Riesenfledermaus mit Vogelskelett (27.10., 08:17)“ `session_01Hmoj75vX6Z7EFP57RtBRAo` auf Perikles' Vorrang (338.1); alter Jerry `01Hmoj75Q` zur Übergabe aufgefordert
- 08:07 27.10.: Lauf; Start „Perikles – Stand zum Marktstart 27.10.“ `session_01Hmoj75j5Wuu9TbGJZNX6Cf` (Tagesbericht); Perikles-Nachfolger-Start (Terminname) damit erledigt
- 07:10 27.10.: Morgenmeldung `--laut`; Vorrat gekürzt (Übergabe, Eingang, Protokoll)
- 00:04 27.10.: Lauf; START Perikles (Terminname, `lauf.py` startet ihn sofort) und START Sokrates (Nachtvertretung läuft, 362) nicht ausgeführt
- 07:04 26.10.: Startsperre 07:04 Start Perikles (lauf.py)
- 07:04 26.10.: Marke Abgleich Vorentscheid 348.6 ohne Datei in chefsache/billigen/ und ohn (lauf.py)
- 07:04 26.10.: Marke Abgleich Vorentscheid-Bremse (194.1): 8 ungebilligt, 0 älter als 7 Ta (lauf.py)
- 07:04 26.10.: Nachfolger-Warnung Jerry (Übergabe 26.10., 06:09) (lauf.py)
- 07:04 26.10.: Nachfolger-Warnung Diogenes (Übergabe 26.10., 03:29) (lauf.py)
- 07:04 26.10.: Nachfolger-Warnung Homer (Übergabe 25.10., 23:40) (lauf.py)
- 13:20 26.10.: Startsperre 13:20 Start Homer, Perikles (lauf.py)
- 13:20 26.10.: Marke Wochenstart 26.10. Perikles (lauf.py)
- 13:20 26.10.: Marke Wochenstart 26.10. Diogenes (lauf.py)
- 13:20 26.10.: Marke Abgleich Vorentscheid 348.7 ohne Datei in chefsache/billigen/ und ohn (lauf.py)
- 13:20 26.10.: Nachfolger-Warnung Diogenes (Übergabe 26.10., 12:59) (lauf.py)
- 17:08 26.10.: Startsperre 17:08 Start Homer, Perikles (lauf.py)
- 17:08 26.10.: Nachfolger-Warnung Diogenes (Übergabe 26.10., 15:19) (lauf.py)
- 17:08 26.10.: Nachfolger-Warnung Homer (Übergabe 26.10., 13:30) (lauf.py)
- 18:04 26.10.: Startsperre 18:04 Start Perikles (lauf.py)
- 18:04 26.10.: Marke Stellungnahme Sokrates 26.10. (lauf.py)
- 19:04 26.10.: Startsperre 19:04 Start Perikles (lauf.py)
- 19:04 26.10.: Nachfolger-Warnung Homer (Übergabe 26.10., 17:18) (lauf.py)
- 20:05 26.10.: Startsperre 20:05 Start Perikles (lauf.py)
- 20:05 26.10.: Marke Mehrfach Tom (lauf.py)
- 21:04 26.10.: Startsperre 21:04 Start Homer (lauf.py)
- 21:04 26.10.: Marke Stellungnahme Sokrates 26.10. (lauf.py)
- 21:04 26.10.: Marke Mehrfach-Warnung Tom session_016mPKnrQHCxbUmR41TToC2L (lauf.py)
- 21:04 26.10.: Marke Mehrfach Tom (lauf.py)
- 21:04 26.10.: Nachfolger-Warnung Diogenes (Übergabe 26.10., 20:39) (lauf.py)
- 00:04 27.10.: Startsperre 00:04 Start Perikles (lauf.py)
- 00:04 27.10.: Marke Stellungnahme Sokrates 27.10. (lauf.py)
- 00:04 27.10.: Nachfolger-Warnung Homer (Übergabe 26.10., 21:09) (lauf.py)
- 01:04 27.10.: Startsperre 01:04 Start Perikles (lauf.py)
- 01:04 27.10.: Marke Stellungnahme Sokrates 27.10. (lauf.py)
- 01:04 27.10.: Marke Mehrfach Jerry (lauf.py)
- 08:07 27.10.: Startsperre 08:07 Start Perikles (lauf.py)
- 08:07 27.10.: Marke Tagesbericht 27.10. (lauf.py)
