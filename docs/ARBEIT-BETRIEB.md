# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Übergabe (27.10., 17:32, Ford `session_01Hmoj76zGbw1bYHxyZ3XqUH`, Tiefe 1, über 380 Tsd. Token → Selbstneustart):** Läuft: Tom `01Hmoj77wa` (348.13a r6), Jerry `01Hmoj761r` (348.7a Fehlerprüfung r6), Perikles `01Hmoj77bY` (381, 275 LEICHEN_START; „Weiter“ 17:24), Sokrates `01Hmoj79xv` (275/376). Homer, Diogenes ohne Sitzung (Diogenes täglich 8:00 vom 28.10. bis 03.11., 374). Archiviert wird jetzt von Ford selbst (Chef 15:03 „keine Lust, deinen Job zu machen“; Prüfer ließ es danach durch): nach jedem Neustart den Absender archivieren, sobald `idle`, Kosten mit `lauf.py --kosten <Nr,Nr> <Betrag> <Kennung>` (Kommaliste bei geteilter Sitzung, 379) **aus `/home/user/bornim-main`** buchen und dort pushen (lauf.py schreibt in bornim-main, nie `git add -A`; Arbeitsbaum `androidapp_rpg_bornim` nur mit `git stash; git pull --ff-only` sauber halten). Chef nie mit Kennungen ansprechen, nur Titel. **Offen von Tom 17:30:** neue Sitzungen starteten auf altem `main` (26.10., 21:35, `07d30cc0c`): `create_session` mit `source_revision` `main` testen, `add_repo` dort probieren (Chefsache 376.1a); Stand: dieser Neustart ist der Test. Nachfolger: Ford – Betriebsleiter.

**Nächste freie Vorgangsnummer: 382** (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef: „Habe Pro gekündigt, steht nur noch auf Free“): Ford-2-Regeln ausgesetzt (`LISTE-FORD2.md`); Guthaben nur Max. **Jerry läuft in der Zentrale** (`LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, Einrichtung aus Git (`LISTE-NIEDERLASSUNG.md` bis `f3ec7200`)

**Ford: Pilot** (seit Sa 17.10., 21:05; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (Übersicht `docs/chefsache/README.md`; https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht: `docs/PRUEFBERICHT.md`

**Sparbetrieb (Chef 23.10., 10:22, Bild: Woche „Alle Modelle“ 100 %, Zurücksetzung Sa 20:59; nur Credits, Guthaben 79,38, Monatslimit unbegrenzt):** „Was angestoßen ist, machen wir fertig, ich prüfe Entwürfe, wir aktualisieren und bauen ein. Dann wird wohl der Spieletest heut bei mir stattfinden.“ Ford startet nur Rückläufer des Chefs und den Build für seinen Spieletest; laufende Sitzungen machen ihren Schritt fertig und übergeben, keine Neustarts ohne Arbeit; Sokrates 318 (20 Uhr) auf So nach 21 Uhr, Auswertung 340 erst nach der Zurücksetzung.

**Guthaben:** **Bild Chef 27.10., 09:47 (an Sokrates):** Woche 51 %, Sitzung 9 %; Hinweis „Limit Donnerstagnacht aufgebraucht, vor der Zurücksetzung am Samstag“; Nutzungsguthaben-Schalter an, 0 Guthabenpunkte; Takt 26.10. 11:43 → 27.10. 09:47: 1,09 %/h, Vorhersage unten bestätigt. **Bild 26.10., 11:43 (an Perikles):** Woche 27 % (Zurücksetzung Sa 31.10., 20:00), Sitzung 12 % (bis 12:00); Hinweis „Limit in der Nacht auf Samstag“. Takt seit 0 % am 25.10., 11:05: 1,1 %/h → 80 % Mi 28.10. ~12, 95 % Do ~02, 100 % Do ~06 (Perikles; Anzeige rechnet langsamer); 287 gilt · **Max 20x seit 25.10., ~11:00**: 287 gilt weiter (80/95-%-Regel: ab 80 % `lauf.py --nur-muss`, ab 95 % nur Rückläufer des Chefs, ab 100 % Stillstand, nichts nachkaufen); Monat bis 25.10. 303,02 $ · ältere Bilder: Git vor „Perikles: Guthaben 26.10.“

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Ford lebt in einer Sitzung** „Ford – Betriebsleiter (27.10., 13:26)“ `session_01Hmoj76zGbw1bYHxyZ3XqUH` (Tiefe 0); Stundenuhr „Ford-Lauf“ `trig_01RYYEpJ7dDYfzUMB6SGJMYe` (:03, geprüft 13:25). Alte Uhr gelöscht; alter Ford `01Hmoj78hRdjifkpE9w6bGbD` nicht archiviert (Auto-Modus-Prüfer lehnt ab, 369): Chef archiviert von Hand.
- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (D13.2).
- **(ruht, 159)** Ford 2: Stundenuhr aus; Sitzung `session_017VRJsTBwEbU16mwomLknhm`, Uhr `trig_01WCdVmLssvGbjCSK9KJPCPH`; bei Wiedereinschalten neu prüfen.

## Eingang

Anregungen ohne Bereich und Startwünsche (eine Zeile, Datum, Absender). Ford teilt im nächsten Lauf zu oder legt sie dem Chef vor.

- **Von Perikles (378, 27.10., 15:0x; Durchsicht Sokrates):** Dashboard (339) seit 08:07 nicht erneuert (Perikles hat 15:1x veröffentlicht; jeder Lauf, `LISTE-BETRIEB.md` 11); `ARBEIT-BESETZUNG.md` Stand 13:23, alle Sitzungen ersetzt; Übergabe oben nennt Perikles `77YJ` laufend; Eingang: Zeilen archiviert/ERLEDIGT/318 „nach dem ersten Start streichen“, „Sparbetrieb (23.10.)“ prüfen; Protokoll etwa 70 statt 20 Zeilen (Datei 15,5 KB); acht erledigte Sitzungen nicht archiviert (Tom `79SM`, `778n`; Jerry `761u`, `76oY`; Sokrates `7738`; Perikles `77YJ`; Diogenes `77X9`; Ford `78hRdj`): versuchen, Abgelehntes dem Chef nennen (369); Diogenes 348.9 Nachfolger „Blätter messen“ starten.

- **374 (Sokrates 27.10., 12:00, Chef „374 ja“):** Diogenes täglich 8:00 vom 28.10. bis 03.11. starten (zählt die Vorlagen des Vortags, Zeile oben in `ARBEIT-PRUEFUNG.md`); im ersten Lauf ab 8 Uhr „Auftrag Diogenes 374“ wie `START`. Werkzeugteil bei Perikles. Nach dem 03.11. Zeile streichen.
- **Von Sokrates (27.10., 09:3x, Durchsicht Chefsache):** Vorräte nennen „beim Chef“ ohne Datei (gilt nach Regel 8 nicht): Jerry „Boden r6, Grimmzahn“ (entschieden 25.10., 22:00), „Wildschwein r3“; Tom „Dorf r13b“. Homer wartet nicht auf 348.12g (entschieden 26.10., 16:17), sondern auf Chefsache 348.12c Listen. Bitte an Tom, Jerry, Homer zum Bereinigen. Chefsache 110 erledigt (Ford von Hand gestartet), Datei gelöscht.
- **369:** Chef 26.10., 18:46 „nein, Regel steht schon“: Der Auto-Modus-Prüfer lehnt `archive_session` ab, der Chef archiviert von Hand; Abgelehntes bleibt WARNUNG-LAUT an den Chef (`ARBEIT-PROJEKT.md` „Zu 369“).

## Protokoll
Eine Zeile je Lauf mit Tat, neueste oben, höchstens 20 Zeilen; ältere streichen (Verlauf in Git, 117).

- 17:16 27.10.: Neustart Tom angenommen (`9e8337eef`), Nachfolger `01Hmoj77wa` „Tom – 348.13a Tusche Kampf Runde 6“ gestartet; alter Tom `01Hmoj79D3` archiviert, 9,25 $ auf 376.1, 348.13a
- 17:10 27.10.: Neustart Jerry angenommen (`566ff28af`), Nachfolger `01Hmoj761r` „Jerry – 348.7a Fehlerprüfung Runde 6“ gestartet; alter Jerry `01Hmoj78DT` archiviert, 9,29 $ auf 348.12, 348.7a
- 17:05 27.10.: Lauf; Diogenes „275 Nachprüfung D46“ archiviert, 2,95 $ auf 275; Perikles `01Hmoj77bY` per „Weiter: 275“ geweckt (16:58); Tom, Jerry laufen; Ford 357 Tsd. Token (Selbstneustart bei 400 Tsd.)
- 16:55 27.10.: Auftrag Diogenes 275 (Perikles, Nachprüfung D46) → `01Hmoj77ju` „Diogenes – 275 Nachprüfung D46“ gestartet; Perikles `01Hmoj77bY` (275 D46.1/D46.2) läuft seit 16:51, alter Perikles `01Hmoj79Bo` archiviert
- 01:37–06:35 27.10.: Neustarts angenommen und Nachfolger gestartet: Tom 01:46, 02:33, 02:57, 03:23, 03:51, 04:16, 04:43, 05:01, 05:20, 05:44, 06:03, 06:35, 07:21; Jerry 01:37, 02:42, 03:25, 04:57; Jerry 05:55 zurückgestellt (wartet auf Chefsache 3487a). Läufe 02:03, 03:03 ohne Starts; START Perikles (Terminname) nicht ausgeführt
- 25.10., 09:35–21:05: Neustarts Tom/Jerry/Sokrates angenommen; Perikles 364 und Sokrates 340.2 gestartet; Sparbetrieb und Max 20x (Verlauf in Git)

- 16:45 27.10.: Neustart Tom angenommen (`9aa291ab1`), Nachfolger `01Hmoj79D3` „Tom – 376.1 Trachtfilm, Prüfung, an den Chef“ gestartet; alter Tom `01Hmoj767w` archiviert, 6,88 $ auf 376.1
- 16:30 27.10.: Neustart Jerry angenommen (`e85ffc292`), Nachfolger `01Hmoj78DT` „Jerry – 348.12 Fehlerprüfung Hieb r7, 348.7a Runde 6“ gestartet; alter Jerry `01Hmoj76FQ` und Tom `01Hmoj77Ko` archiviert und gebucht (18,20 $ auf 348.12f, 348.7a; 4,62 $ auf 376.1). Jerry meldet: 348.3 „wartet auf Chef“ ohne Chefsache-Datei (Befund 378, Perikles)
- 16:08 27.10.: Neustart Tom angenommen (`37e7f73ab`), Nachfolger `01Hmoj767w` „Tom – 376.1 Tracht und Film rendern, prüfen, an den Chef“ gestartet; alter Tom `01Hmoj77Ko` archivieren, sobald `idle` (Kosten auf 376.1)
- 16:05 27.10.: Lauf; Sokrates „376 begleiten (14:40)“ und Diogenes „275 Stufe 1 prüfen“ (Vorrat leer) archiviert und gebucht (9,18 $ auf 376, 275; 2,58 $ auf 275); sonst nichts zu starten, Tom/Jerry laufen
- 15:54 27.10.: Neustart Jerry angenommen (`eef2681e6`), Nachfolger `01Hmoj76FQ` „Jerry – Fehlerprüfung 348.12f r7, 348.7a r5“ gestartet; alter Jerry `01Hmoj79d6` archiviert, 7,31 $ auf 348.7a und 348.12f
- 15:40 27.10.: Neustart Tom angenommen (`047f51581`), Nachfolger `01Hmoj77Ko` „Tom – 376.1 Tracht und Film fertig, an den Chef“ gestartet; alter Tom `01Hmoj799Z` und `77MK` archiviert, 7,30 $ und 10,33 $ auf 376.1
- 15:26 27.10.: Neustart Tom angenommen (`bf5fbd292`), Nachfolger `01Hmoj799Z` „Tom – 376.1 Film prüfen, an den Chef“ gestartet; alter Tom `01Hmoj77MK` archivieren, sobald `idle` (10,08 $ auf 376.1, Kommaliste beachten)
- 15:25 27.10.: Auftrag Diogenes 275 (Perikles, Muss, Chef 15:09) von Hand gestartet `01Hmoj79Rk` „Diogenes – 275 Stufe 1 prüfen“, weil lauf.py ihn nicht startete (380 an Perikles)
- 15:10 27.10.: Neustart Sokrates angenommen (`0089dc4da`), Nachfolger `01Hmoj79xv` „Sokrates – 275 und 376 begleiten“ gestartet; alter Sokrates „Sokrates – 376 begleiten (27.10., 14:40)“ noch zu archivieren
- 14:40 27.10.: Neustart Sokrates angenommen (`bcdb44477`), Nachfolger `01Hmoj76ci` „Sokrates – 376 begleiten (Probeblatt 376.1)“ gestartet; alter Sokrates `01Hmoj7738` beim Chef zum Archivieren
- 14:36 27.10.: Neustart Jerry angenommen (`f89a80fac`), Nachfolger `01Hmoj79d6` „Jerry – 348.7a Runde 5, 348.12f Rute r7“ gestartet; alter Jerry `01Hmoj761u` beim Chef zum Archivieren
- 14:28 27.10.: Neustart Tom angenommen (`e329c2397`), Nachfolger `01Hmoj77MK` „Tom – 376.1 Blätter und Film prüfen, an den Chef“ gestartet; alter Tom `01Hmoj79SM` beim Chef zum Archivieren
- 14:08 27.10.: Neustart Tom angenommen (`6cdf1cd19`), Nachfolger `01Hmoj79SM` „Tom – 376.1 Film prüfen, Kaufteile einsetzen“ gestartet; alter Tom `01Hmoj778n` zum Archivieren beim Chef (Kosten fehlen)
- 14:05 27.10.: Perikles `01Hmoj77YJ` blockiert (add_repo-Freigabe) → Nachfolger `01Hmoj79Bo` „Perikles – 377“ gestartet; alter bleibt, Chef archiviert von Hand. Jerry/Tom laufen
- 13:46 27.10.: Neustart Jerry angenommen, Nachfolger `01Hmoj761u` „Jerry – 348.12f Rute r6 prüfen, 348.7a Runde 4“ gestartet; alter Jerry `01Hmoj76oY` bleibt (Archivieren vom Prüfer abgelehnt, Chef von Hand). Perikles `01Hmoj77YJ` wartet auf add_repo-Freigabe (blocked)
- 13:25 27.10.: Perikles 377 gestartet `01Hmoj77YJ` (alter Perikles archiviert, 3,37 $ auf 376.1); Tom Runde 7 archiviert (10,47 $ auf 348.6); Selbstneustart Ford wegen 400 Tsd. Token
- 13:21 27.10.: Neustart Tom angenommen (21956f5c1): Start „Tom – 376.1 Probeblatt Quaternius-Figuren“ `01Hmoj778n`; Jerry `01Hmoj791A` archiviert (8,13 $ je zur Hälfte auf 348.7a und 348.12f); Tom Runde 7 `01Hmoj77bi` noch `working`: archivieren und auf 348.6 buchen, sobald `idle`
- 12:56 27.10.: Neustart Jerry angenommen (b9ebd2899): Start „Jerry – 348.7a Runde 3 prüfen, 348.12f Rute r4“ `01Hmoj76oY`; alter Jerry `01Hmoj791A` noch `working`: archivieren und Kosten je zur Hälfte auf 348.7a und 348.12f, sobald `idle`; Perikles meldet Vorrat leer ohne Nachfolger (Sitzung `01Hmoj78vH` bleibt idle)
- 12:53 27.10.: Neustart Sokrates angenommen (6d04b480c): Start „Sokrates – 376 begleiten, Antwort Modelle“ `01Hmoj7738`, alter Sokrates `01Hmoj77Tr` archiviert, 3,90 $ auf 376; Chef nimmt die Rückfrage 12:50 (KI-Modelle gemeint?) in der neuen Sitzung entgegen: Link per Telegram
- 12:52 27.10.: Sokrates-Auftrag (Chef 12:46 „jetzt“) an Tom Runde 7 `01Hmoj77bi` weitergegeben: zuerst 376.1 (UAL Pro sichten, höchstens 15 Min., Probeblatt), dann Runde 7 nur Technik; Tom Runde 6 archiviert (7,98 $ auf 348.6), Homer (Vorrat leer, 2,08 $ auf 348.12g) archiviert, Homer ruht ohne Sitzung bis neue Arbeit
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
- 09:28 27.10.: Startsperre 09:28 Start Perikles (lauf.py)
- 09:28 27.10.: Marke Archiv session_01Hmoj75j5Wuu9TbGJZNX6Cf (lauf.py)
- 10:05 27.10.: Startsperre 10:05 Start Homer, Perikles (lauf.py)
- 10:05 27.10.: Marke Archiv session_01Twr8DKumpNBQFzjt1faRwK (lauf.py)
- 10:05 27.10.: Marke Archiv session_01Hmoj79AezEQYw2pW8hJJJN (lauf.py)
- 12:44 27.10.: Startsperre 12:44 Start Perikles (lauf.py)
- 12:44 27.10.: Marke Archiv session_01Hmoj75Q3H9eTeXLS1ojGTE (lauf.py)
- 12:44 27.10.: Nachfolger-Warnung Diogenes (Übergabe 27.10., 10:35) (lauf.py)
- 13:23 27.10.: Startsperre 13:23 Start Perikles (lauf.py)
- 13:23 27.10.: Marke Archiv session_01Hmoj78vHYPT8chF7CZmYup (lauf.py)
- 16:51 27.10.: Startsperre 16:51 Start Perikles (lauf.py)
- 16:51 27.10.: Nachfolger-Warnung Diogenes (Übergabe 27.10., 15:49) (lauf.py)
