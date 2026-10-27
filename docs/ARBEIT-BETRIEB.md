# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Übergabe (27.10., 09:30, Ford `session_01Hmoj78hRdjifkpE9w6bGbD`, Tiefe 0, vom Chef von Hand gestartet, 110):** Uhr übernommen, alter Ford und Sokrates-Nachtvertretung archiviert und gebucht, Perikles 371 gestartet (`01Hmoj79Ae`), Perikles alt archiviert. Läuft: Tom `01Hmoj77aE`, Jerry `01Hmoj79qo`. Jerry-Nachfolger 348.7a erst nach Antwort auf 3487a. Offen: Homer `01Twr8` (idle, wartet auf Chefsache 348.12g, einzige Homer-Sitzung). Selbstneustart ab 400 Tsd. Token möglich (Tiefe 0). Nachfolger: Ford – Betriebsleiter.

**Nächste freie Vorgangsnummer: 377** (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef: „Habe Pro gekündigt, steht nur noch auf Free“): Ford-2-Regeln ausgesetzt (`LISTE-FORD2.md`); Guthaben nur Max. **Jerry läuft in der Zentrale** (`LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, Einrichtung aus Git (`LISTE-NIEDERLASSUNG.md` bis `f3ec7200`)

**Ford: Pilot** (seit Sa 17.10., 21:05; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (Übersicht `docs/chefsache/README.md`; https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht: `docs/PRUEFBERICHT.md`

**Sparbetrieb (Chef 23.10., 10:22, Bild: Woche „Alle Modelle“ 100 %, Zurücksetzung Sa 20:59; nur Credits, Guthaben 79,38, Monatslimit unbegrenzt):** „Was angestoßen ist, machen wir fertig, ich prüfe Entwürfe, wir aktualisieren und bauen ein. Dann wird wohl der Spieletest heut bei mir stattfinden.“ Ford startet nur Rückläufer des Chefs und den Build für seinen Spieletest; laufende Sitzungen machen ihren Schritt fertig und übergeben, keine Neustarts ohne Arbeit; Sokrates 318 (20 Uhr) auf So nach 21 Uhr, Auswertung 340 erst nach der Zurücksetzung.

**Guthaben:** **Bild Chef 27.10., 09:47 (an Sokrates):** Woche 51 %, Sitzung 9 %; Hinweis „Limit Donnerstagnacht aufgebraucht, vor der Zurücksetzung am Samstag“; Nutzungsguthaben-Schalter an, 0 Guthabenpunkte; Takt 26.10. 11:43 → 27.10. 09:47: 1,09 %/h, Vorhersage unten bestätigt. **Bild 26.10., 11:43 (an Perikles):** Woche 27 % (Zurücksetzung Sa 31.10., 20:00), Sitzung 12 % (bis 12:00); Hinweis „Limit in der Nacht auf Samstag“. Takt seit 0 % am 25.10., 11:05: 1,1 %/h → 80 % Mi 28.10. ~12, 95 % Do ~02, 100 % Do ~06 (Perikles; Anzeige rechnet langsamer); 287 gilt · **Max 20x seit 25.10., ~11:00**: 287 gilt weiter (80/95-%-Regel: ab 80 % `lauf.py --nur-muss`, ab 95 % nur Rückläufer des Chefs, ab 100 % Stillstand, nichts nachkaufen); Monat bis 25.10. 303,02 $ · ältere Bilder: Git vor „Perikles: Guthaben 26.10.“

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Ford lebt in einer Sitzung** „Ford – Betriebsleiter (27.10., 09:26)“ `session_01Hmoj78hRdjifkpE9w6bGbD` (seit 27.10., 09:26, Tiefe 0). Stundenuhr „Ford-Lauf“ `trig_019gmvMzPaYQMy1h2x6h1ZXk` (:03). Alle alten Ford-Sitzungen archiviert.
- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (D13.2).
- **(ruht, 159)** Ford 2: Stundenuhr aus; Sitzung `session_017VRJsTBwEbU16mwomLknhm`, Uhr `trig_01WCdVmLssvGbjCSK9KJPCPH`; bei Wiedereinschalten neu prüfen.

## Eingang

Anregungen ohne Bereich und Startwünsche (eine Zeile, Datum, Absender). Ford teilt im nächsten Lauf zu oder legt sie dem Chef vor.

- **374 (Sokrates 27.10., 12:00, Chef „374 ja“):** Diogenes täglich 8:00 vom 28.10. bis 03.11. starten (zählt die Vorlagen des Vortags, Zeile oben in `ARBEIT-PRUEFUNG.md`); im ersten Lauf ab 8 Uhr „Auftrag Diogenes 374“ wie `START`. Werkzeugteil bei Perikles. Nach dem 03.11. Zeile streichen.
- **Von Sokrates (27.10., 09:3x, Durchsicht Chefsache):** Vorräte nennen „beim Chef“ ohne Datei (gilt nach Regel 8 nicht): Jerry „Boden r6, Grimmzahn“ (entschieden 25.10., 22:00), „Wildschwein r3“; Tom „Dorf r13b“. Homer wartet nicht auf 348.12g (entschieden 26.10., 16:17), sondern auf Chefsache 348.12c Listen. Bitte an Tom, Jerry, Homer zum Bereinigen. Chefsache 110 erledigt (Ford von Hand gestartet), Datei gelöscht.
- **Von Sokrates (27.10., 09:1x, Chef 09:06 „1000 Sitzungen links stehen, die nicht archiviert sind“):** 33 alte Sitzungen archiviert (Tom, Jerry der Nacht, Ford `01Rxj`, `01Ays`, Sokrates, Diogenes, Perikles alt); im Auto-Modus 2 von 35 Aufrufen abgelehnt, beim zweiten Versuch durch. Offen: Homer `01Twr8` (wartet auf Eingabe), Perikles `01Hmoj75j5`. Kosten der Nacht bucht `lauf.py` (GEBUCHT). Nachtvertretung beendet. Folge: Vorgang 371.
- **369:** Chef 26.10., 18:46 „nein, Regel steht schon“: Der Auto-Modus-Prüfer lehnt `archive_session` ab, der Chef archiviert von Hand; Abgelehntes bleibt WARNUNG-LAUT an den Chef (`ARBEIT-PROJEKT.md` „Zu 369“).
- **ERLEDIGT 12:00 (Ford hat 373 an Tom, Jerry, Homer, Diogenes, Sokrates per Nachricht weitergegeben; Besitzer passen ihre Zeilen an):** An Ford (Perikles 27.10., 11:5x, 373): bitte an Tom, Jerry, Homer, Diogenes weitergeben (laufende per Nachricht): über Aussehen und Bewegung urteilt nur der Chef; vor dem Versand genau eine Fehlerprüfung mit Zahlen, Befund im Begleittext; Diogenes misst nebenher als Hinweis, kein Tor; Homer gibt vor dem Bau vor, urteilt danach nicht; Sokrates urteilt nachts nicht mehr; Videos auf den Zweig `bilder`. Wortlaut `ROLLE-ENTWICKLUNG.md` „Aussehen urteilt nur der Chef“. Ersetzt den Hinweis „jedes Blatt vor dem Chef zu Diogenes“ (10:30). Veraltete Zeilen nennen, die die Besitzer anpassen: `ARBEIT-KREATIV.md` 348.9 („jeden Modellentwurf vor dem Chef“, Nachfolger „Homer – 348.9 Modellentwürfe“ nicht starten); `ARBEIT-PRUEFUNG.md` 348.9 („geht nicht zum Chef“, „zurück ans Team“); `ARBEIT-TEAM-TOM.md` „Zu 348.6, Dorf“ („Blätter zuerst an Diogenes“); `ARBEIT-TEAM-JERRY.md` („vor Telegram an Diogenes“); `ARBEIT-BERATUNG.md` 348 („nachts Urteil statt Chef, 362“; Rückfrage 373a beim Chef). Werkzeugfehler `lauf.py` aus diesem Eingang jetzt als 375 bei Perikles.
- **348.7a (Ford 27.10., 08:17):** „Jerry – 348.7a nach Chefwort 3D oder flach“ erst starten, wenn der Chef `3487a-flugbahn` beantwortet hat (**beantwortet 09:38: „3D, Effekte als Tafeln“, Archiv; startbar**, Sokrates); Jerry läuft inzwischen mit 348.7 Riesenfledermaus (`01Hmoj79q`, Perikles).
- **318, von Sokrates (22.10., 21:3x, Chef „komplett umsetzen“):** ab sofort jedes `create_session` mit `append_system_prompt` nach `LISTE-BETRIEB.md` (Zeile „Kennungen“); Antwortstil „Knapp“ steht in `.claude/settings.json`. Zeile nach dem ersten Start mit Anhang streichen.

## Protokoll
Eine Zeile je Lauf mit Tat, neueste oben, höchstens 20 Zeilen; ältere streichen (Verlauf in Git, 117).

- 01:37–06:35 27.10.: Neustarts angenommen und Nachfolger gestartet: Tom 01:46, 02:33, 02:57, 03:23, 03:51, 04:16, 04:43, 05:01, 05:20, 05:44, 06:03, 06:35, 07:21; Jerry 01:37, 02:42, 03:25, 04:57; Jerry 05:55 zurückgestellt (wartet auf Chefsache 3487a). Läufe 02:03, 03:03 ohne Starts; START Perikles (Terminname) nicht ausgeführt
- 25.10., 09:35–21:05: Neustarts Tom/Jerry/Sokrates angenommen; Perikles 364 und Sokrates 340.2 gestartet; Sparbetrieb und Max 20x (Verlauf in Git)

- 12:40 27.10.: Neustart Sokrates (da8ce85, ersetzt 4bc277ace; Chef hatte den archivierten Sokrates wieder geöffnet): keine neue Sitzung, laufende `01Hmoj77Tr` per „Weiter: 376 Häuser und Markt an Tom“; Sokrates alt erneut archiviert, Differenz auf 376 gebucht (gesamt 6,54 $)
- 12:24 27.10.: Jerry alt archiviert (6,93 $ → 3,47 auf 348.12f, 3,46 auf 348.7a); Neustart Sokrates angenommen (4bc277ace): Start „Sokrates – 376 Häuser offen, Ergebnis 376.1 begleiten“ `01Hmoj77Tr`, alter Sokrates archiviert, 4,39 $ auf 376. Offen für den Chef (Sokrates alt): 376.1 wartet auf seine Meldung „Upload fertig“, wer sie bekommt, trägt sie bei Perikles ein
- 12:11 27.10.: Neustart Jerry angenommen (62525911c auf main): Start „Jerry – 348.12f Rute r3 vorlegen, 348.7a Runde 3“ `01Hmoj791A`; alter Jerry `01Hmoj78j8` (1,38 $ bis jetzt, zu je 1/2 auf 348.12f und 348.7a) noch `working`: archivieren und buchen, sobald `idle`
- 12:10 27.10.: Tom Runde 5 und Sokrates alt archiviert und gebucht (11,28 $ auf 348.6; 8,78 $ zu je 2,93 auf 373, 374, 376); zweite Neustart-Meldung Tom (ab02891c1, gleicher Nachfolger Runde 6) nicht neu gestartet, Runde 6 läuft schon
- 12:08 27.10.: Neustart Tom angenommen (c4f86ec7c auf main): Start „Tom – 348.6 Kampfbewegungen Runde 6“ `01Hmoj79fQ`; offen zum Archivieren, sobald `idle`: Tom Runde 5 `01Hmoj776m` und Sokrates alt `01Hmoj77Kr` (8,37 $; beide noch `working`)
- 12:07 27.10.: Neustart Sokrates angenommen (5a4134d03 auf main): Start „Sokrates – 376 Outfits prüfen“ `01Hmoj77AV`; alter Sokrates `01Hmoj77Kr` (8,37 $, zu je 1/3 auf 373, 374, 376) noch `working`: archivieren und buchen, sobald `idle`
- 12:01 27.10.: Neustart Perikles (91e5d6870) angenommen: Nachfolger heißt jetzt „374 und 375 Werkzeug“; keine zweite Sitzung, die schon laufende `01Hmoj75Q3` per Nachricht „Weiter: 374 und 375“ erweitert; alter Perikles archiviert, 8,79 $ auf 373 gebucht
- 12:00 27.10.: Auftrag 374 (Diogenes täglich 8:00, 28.10.–03.11.) von Sokrates angenommen, in den Eingang gelegt
- 12:00 27.10.: Neustart Perikles angenommen (1ead5e6d2 auf main): Start „Perikles – 375 Werkzeugfehler lauf.py“ `01Hmoj75Q3`; 373 an fünf laufende Sitzungen weitergegeben; alter Perikles (2,88 $) wird nach `idle` archiviert
- 11:52 27.10.: Neustart Jerry angenommen (912fd21f3 auf main): Start „Jerry – 348.12f Rute und 348.7a Runde 2 prüfen“ `01Hmoj78j8`, alter Jerry erst nach `idle` archiviert, 9,28 $ zu gleichen Teilen auf 348.7a und 348.12f gebucht
- 11:37 27.10.: Neustart Tom angenommen (f1003eb12 auf main): Start „Tom – 348.6 Kampfbewegungen Runde 5“ `01Hmoj776m`, alter Tom archiviert, 10,61 $ gebucht; Runde 3 (9,05 $) nachgebucht. Lehre: Jerry-Sitzungen, die noch `working` waren, lieferten beim Archivieren keine Kosten und stehen „failed“ (2 Sitzungen, Kosten fehlen): erst archivieren, wenn die Sitzung `idle` ist
- 11:04 27.10.: Lauf; START Diogenes nicht ausgeführt (`--ohne 348.9`: Diogenes hat um 10:34 alle sieben Blätter gemessen, kein neues Blatt gemeldet; Nachfolger-Titel von `lauf.py` zerlegt, siehe Eingang); Homer/Perikles nichts Startbares; Tom, Jerry laufen
- 11:00 27.10.: Neustart Tom angenommen (b608d45e2 auf main): Start „Tom – 348.6 Kampfbewegungen Runde 4“ `01Hmoj767p`, alter Tom archiviert, Kosten fehlen (keine Zahl geliefert)
- 10:42 27.10.: Neustart Jerry angenommen (638e7a6e5 auf main): Start „Jerry – 348.7a Geschosse in 3D, Prüfung“ `01Hmoj77dR`, alter Jerry archiviert, Kosten fehlen (keine Zahl geliefert)
- 10:31 27.10.: Neustart Sokrates angenommen (b07e0442a auf main): Start „Sokrates – auf Zuruf (27.10., 10:31)“ `01Hmoj77Kr`, alter Sokrates archiviert, 6,75 $ zu je 0,96 auf die sieben Nummern der Übergabe gebucht
- 10:29 27.10.: Auftrag Diogenes 348.9 (Sokrates) angenommen: Start „Diogenes – 348.9 Fledermaus r4d messen“ `01Hmoj77X9`; Hinweis „jedes Blatt vor dem Chef als Zeile bei Diogenes“ an Tom/Jerry konnte nicht in deren Vorrat (beide über 15 KB, Commit-Prüfung hält an): an Perikles
- 10:22 27.10.: Neustart Tom angenommen (eb41ad25c auf main): Start „Tom – 348.6 Kampfbewegungen Runde 3“ `01Hmoj76AA`, alter Tom archiviert, 10,70 $ gebucht
- 10:05 27.10.: Lauf; Start Homer-Nachfolger (Übergabe, 348.12c erledigt, `--ohne` griff nicht beim Nachfolger) `01Hmoj782P` und Perikles 338a `01Hmoj75Sn`; alte Homer und Perikles archiviert, 2,21 $ und 1,25 $ gebucht. Tom/Jerry/Sokrates laufen
- 09:46 27.10.: Neustart Jerry angenommen (66a981053 auf main): Start „Jerry – 348.7a Geschosse in 3D“ `01Hmoj77Zu` (Chef hat 3487a entschieden); alter Jerry archiviert, Kosten fehlen (Sitzung lieferte keine Zahl)
- 09:40 27.10.: Neustart Tom angenommen (d0908c130 auf main): Start „Tom – 348.6 Kampfbewegungen Runde 2“ `01Hmoj75zb`, alter Tom archiviert, 9,86 $ gebucht
- 09:31 27.10.: Sokrates auf Zuruf des Chefs gestartet `01Hmoj78Yk`; 09:28 Perikles 371 `01Hmoj79Ae`; neuer Ford (Tiefe 0) übernimmt Uhr
- 09:08 27.10.: Neustart Jerry angenommen (b86e4d044 auf main, Nachfolger in Übergabe): Start „Jerry – 348.7 Riesenfledermaus Runde 4 (27.10., 09:08)“
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
- 09:28 27.10.: Startsperre 09:28 Start Perikles (lauf.py)
- 09:28 27.10.: Marke Archiv session_01Hmoj75j5Wuu9TbGJZNX6Cf (lauf.py)
- 10:05 27.10.: Startsperre 10:05 Start Homer, Perikles (lauf.py)
- 10:05 27.10.: Marke Archiv session_01Twr8DKumpNBQFzjt1faRwK (lauf.py)
- 10:05 27.10.: Marke Archiv session_01Hmoj79AezEQYw2pW8hJJJN (lauf.py)
