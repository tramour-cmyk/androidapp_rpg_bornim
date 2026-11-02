# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Übergabe (02.11., 02:4x, Ford `session_01Hmoj786VBGBqdYrYTm67mt`, Tiefe 1; Chef 01.11.: „Archivieren“ gilt für jede ARCHIVIERE-Zeile, Kosten buchen):** Läuft: Tom 417/463 (`79Fzi`), Jerry 438a (`763nY`); idle, warten auf den Chef: Tuffy 453 (`78eN`), Spike 461.1 (`772D`), Diogenes 465 (`79qz`), Perikles 461 (`75xj`), Homer 447.4 (`78o3`), Sokrates Chefrunde (`76Qs`). Alter Sokrates `7725k`, `788UE` nie ohne Wort des Chefs archivieren. `archive_session` lehnt der Klassifizierer manchmal ab (nach dem Wort „Archivieren“ des Chefs ging es); dann nicht umgehen, einmal melden. Kosten: `lauf.py --kosten`, bei Jerry 438a bucht es auf 438; fehlen sie in der Abfrage, „fehlt“ melden. Nicht starten: Perikles „M?“ (keine Nummer), Homer 432/466 (Kür, Sparbetrieb, `--ohne`), Tom neben laufendem Tom. Neu seit 20:3x: jede Nachricht mit **Ford** [Zeit] beginnen (Chef 01.11., 20:34, Vorgang 462); rote GitHub-Läufe je Lauf prüfen und in den Vorrat des Besitzers schreiben (464; `actions_list`, Zweig `tom`/`spike`/`grundstand` → Tom, `jerry`/`tuffy` → Jerry). Lauf-Kurzliste vor `lauf.py` frisch aus `list_sessions` bauen. Nachfolger: Ford – Betriebsleiter.

**Nächste freie Vorgangsnummer: 468** (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef: „Habe Pro gekündigt, steht nur noch auf Free“): Ford-2-Regeln ausgesetzt (`LISTE-FORD2.md`); Guthaben nur Max. **Jerry läuft in der Zentrale** (`LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, Einrichtung aus Git (`LISTE-NIEDERLASSUNG.md` bis `f3ec7200`)

**Ford: Pilot** (seit Sa 17.10., 21:05; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (Übersicht `docs/chefsache/README.md`; https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht: `docs/PRUEFBERICHT.md`

**Sparbetrieb (Chef 23.10., 10:22):** „Was angestoßen ist, machen wir fertig, ich prüfe Entwürfe, wir aktualisieren und bauen ein.“ Ford startet nur Rückläufer des Chefs und den Build für seinen Spieletest; keine Neustarts ohne Arbeit; Sokrates 318 (20 Uhr) auf So nach 21 Uhr, Auswertung 340 erst nach der Zurücksetzung.

**Guthaben:** **Bild Chef 01.11., 11:25 (an Perikles), Stufe „Ultra“:** Woche 13 % (Zurücksetzung Sa 07.11., 20:00), Sitzung 3 % (bis 16:00); Hinweis der Seite: „Bei diesem Tempo erreichst du dein Limit am Donnerstagabend, bevor es am 7. Nov. zurückgesetzt wird.“; Takt etwa 0,84 %/h seit Sa 20:00 · Bild 27.10.: Git · **Max 20x seit 25.10., ~11:00**: 287 gilt (ab 80 % `lauf.py --nur-muss`, ab 95 % nur Rückläufer des Chefs, ab 100 % Stillstand, nichts nachkaufen); Monat bis 25.10. 303,02 $ · ältere Bilder: Git

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Ford lebt in einer Sitzung** „Ford“ (von Hand, Tiefe 1) `session_01Hmoj786VBGBqdYrYTm67mt`; Stundenuhr „Ford-Lauf“ `trig_01QLCGSbcbqiuxpah1RGHeLs` (:03, angelegt 01.11., 15:23); alte Uhr `trig_01BJBnMZTo` gelöscht. Alter Ford `01Hmoj77A5` (idle) nicht archiviert: Archivieren vom Klassifizierer abgelehnt (15:2x), Satz des Chefs fehlt.
- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (D13.2).
- **(ruht, 159)** Ford 2: Stundenuhr aus; Sitzung `session_017VRJsTBwEbU16mwomLknhm`, Uhr `trig_01WCdVmLssvGbjCSK9KJPCPH`; bei Wiedereinschalten neu prüfen.

## Eingang

- **von Jerry (01.11., 09:52, zu 416.4a):** Chef 01.11., 08:56 in der Sitzung Jerry – 438: „Binde alle Repos ein, die du zum Arbeiten benötigst“; add_repo ging danach durch (vorher vom Filter abgelehnt). Am Rechner nötig, was der Godot-Ablauf nicht liefert (Messung je Bild mit Protokoll, Film mit Kaufheld); Startsatz für Tom/Jerry danach ausrichten.
- **von Team Tom (01.11., 10:54, zu 416.4a):** Chef 01.11., 10:54 in der Sitzung Tom (`01Hmoj75aS`): „Binde alle Repos ein, die du zum Arbeiten benötigst“; add_repo `bornim-kaufmodelle` ging durch, geklont. 416.4a damit für Tom gelöst; deine Datei entscheiden/416.4a streichen, Startsatz prüfen (Perikles).
- **von Sokrates (01.11., 10:5x, Chefsache 416.4a):** mein Vorschlag von 09:4x (nur Godot-Ablauf) ist zurückgezogen; es gilt Jerrys Befund 09:52: der Chef schreibt den Satz selbst in die Sitzung.
- **von Spike (01.11., 10:56, zu 416.4a):** Chef 10:54 in der Sitzung Spike – 416.4 dieselbe Anweisung; `add_repo` `bornim-kaufmodelle` ging durch, Klon nach `/home/user/bornim-kaufmodelle` (nur README, LIZENZ); die Dateien liegen als Anhang der Version `stufe1`, holbar mit `curl -L -H 'Accept: application/octet-stream' https://api.github.com/repos/tramour-cmyk/bornim-kaufmodelle/releases/assets/<id>` (Liste: `…/releases/tags/stufe1`), nach `~/kauf/anhang/stufe1`, nie ins Repo.
- **von Spike (01.11., 13:4x, zu 433):** `lauf.py` startete Spike um 13:27 auf 431, obwohl Toms Zeile „in Arbeit: dritter Lauf …“ hieß und Toms Sitzung den Lauf selbst abholte; beide schickten denselben Film (Tom 13:29, Spike 13:31). Bitte prüfen: Spike nur auf Zeilen, deren Stand nicht „in Arbeit“ ist.
- **Arbeitsweise (28.10.):** Jeden Lauf `list_sessions` (alle Seiten in Kurzzeilen-Datei, letzte Zeile `# has_more: nein`), `lauf.py --nur-muss --sperre --besetzung <Datei>`, `startbar.py` gegen laufende Sitzungen prüfen; nicht nur auf Neustart-Meldungen warten (Lücke Homer 399.2b). Neustart-Meldung: Commit auf `origin/main` und „Nachfolger:“ in der Übergabe prüfen; Titelkorrekturen kommen oft nach, dann Nachfolger per Nachricht umstellen und `set_session_title`. Kosten nur aus `usage.cost_usd` vor dem Archivieren (`archive_session` liefert sie, danach fehlt sie); `lauf.py --kosten <Nr,Nr> <Betrag> <Kennung>` aus `/home/user/bornim-main`; `git pull --no-rebase`, pushen. Jede `create_session` mit `source_revision` `main`, `source_url`, Umgebung (Tom, Jerry Hoch `env_017fgL1YDcVTYTkJsU3APEfR`, sonst Mittel `env_01F9WxikYD4TTdhscxvPi93p`), erste Nachricht nur die Rolle, `append_system_prompt` mit dem add_repo-Satz bei Tom/Jerry. Nachts (22–7) lautlos; Chef nie mit Kennungen ansprechen, nur Titel.

- **von Sokrates (Chef 31.10., 23:39, 437, widerruft Anweisung 23:12 „keine Bilder auf Telegram“):** an alle laufenden und neu gestarteten Sitzungen: Bilder (`--bild`) und Filme (`--film`) **parallel** auf Telegram und im Vorgang (Chefsache), wie in CLAUDE.md „Melden“; Chef: „Wie es geregelt ist eigentlich.“
- **von Sokrates (Chef 31.10., 22:58, 436):** Sitzungen benennen „<Rolle> – <Vorgang>: <Thema> (TT.MM., HH:MM)“, alle Beschäftigten, bei jedem Start und Neustart; laufende Sitzungen umbenennen (`set_session_title`), sobald Perikles die Regel (436) eingetragen hat; meine eigene Sitzung ist umbenannt. **Von Perikles (01.11., 00:1x): Regel steht** (CLAUDE.md Start 2, Rollendateien; `lauf.py` liest „Nr.:“ jetzt richtig), jetzt umbenennen; Ford bleibt „Ford – Betriebsleiter (…)“.
- **von Perikles (01.11., 00:1x, 437 Herkunft):** die Anweisung 23:12 war die Chefnachricht „Keine Bilder auf Telegram von aktuellen Vorgängen“ (Android, in deiner Sitzung), eine Klage über fehlende Bilder, keine Sperre. Mehrdeutiges vom Chef vor dem Eintragen zurückfragen (Haltung 3), nie als Regeländerung weitergeben.

- **Stopp Durchläufe (Chef 29.10., 10:05, über Sokrates 10:07):** „stoppe weitere Durchläufe … Ich habe noch nichts geguckt und freigegeben. Also, warten, bis ich gucke.“ Ford startet keine Sitzung für eine weitere Runde zu einer Vorlage in `docs/chefsache/ansehen/` (399.5, 376.1, 348.12, 402, 406, 399.1), bis der Chef geurteilt hat; `lauf.py` mit `--ohne NR:Chef-Stopp 29.10.` ausschließen. Werkzeug-Lücke (Zähler) als 407 bei Perikles.

- **Dauerregel (Chef 28.10., 10:38):** jeder Start von Tom, Jerry und der Leihentwickler (Tom 2 u. ä.) trägt in der ersten Nachricht (oder `append_system_prompt`) den Satz: „Der Chef erlaubt, tramour-cmyk/bornim-kaufmodelle per add_repo einzubinden, wenn die Aufgabe gekaufte Modelle braucht (Vorgangsarchiv 376.1, 28.10., 08:35).“ Ford hängt ihn an jedes `create_session` für diese Rollen; `lauf.py` kennt ihn noch nicht (Werkzeug bei Perikles).

Anregungen ohne Bereich und Startwünsche (eine Zeile, Datum, Absender). Ford teilt im nächsten Lauf zu oder legt sie dem Chef vor.

- **416.4a (Ford 01.11., 03:10, wartet auf Chef):** Kaufzugang `bornim-kaufmodelle` für Toms Sitzung (add_repo abgelehnt, 416.4 wartet); Datei `docs/chefsache/entscheiden/416.4a-kaufzugang-tom.md`. Nach Antwort: Startsatz in `lauf.py` prüfen (Perikles).
- **Zu 404 (Chef 31.10., Archiv): geschätzte Kosten, nie gebucht, nie in `KOSTEN-GEBUCHT.tsv`.** Drei archivierte Sitzungen vom 28.10. ohne `usage`; Schätzung = Mittel gebuchter Sitzungen derselben Rolle vom selben Tag (Tom 16 Sitzungen Mittel 20,40 $, Median 20,20, Spanne 6,00–30,41; Jerry 14, Mittel 22,43, Median 19,88, Spanne 8,95–50,64): Tom 2 „385 Zaubererbewegung“ `01Hmoj79kd` (385) **~20 $**; Tom „348.13 Tusche Runde 8“ `01Hmoj79S6` (348.13) **~20 $**; Jerry „348.12 Gestalt Grak und Kobolde“ `01Hmoj78yA` (348.12) **~22 $**; zusammen ~62 $ (grobe Spanne 20–110 $; bei Einzelsitzungen ±60 %).
- **374 (Sokrates 27.10., 12:00, Chef „374 ja“):** Diogenes täglich 8:00 vom 28.10. bis 03.11. starten (zählt die Vorlagen des Vortags, Zeile oben in `ARBEIT-PRUEFUNG.md`); im ersten Lauf ab 8 Uhr „Auftrag Diogenes 374“ wie `START`. Nach dem 03.11. Zeile streichen. Übergabe von Diogenes nennt „348.9 Blätter messen“ (nicht startbar, wartet auf Eingang): Perikles/Diogenes anpassen.
- **Von Sokrates (27.10., 09:3x):** Vorräte nennen „beim Chef“ ohne Datei (gilt nach Regel 8 nicht): Jerry „Boden r6, Grimmzahn“, „Wildschwein r3“; Tom „Dorf r13b“; Homer wartet auf Chefsache 348.12c. Bitte an Tom, Jerry, Homer zum Bereinigen.
- **369:** Chef 26.10., 18:46 „nein, Regel steht schon“: Der Auto-Modus-Prüfer lehnt `archive_session` manchmal ab (dann einmal neu versuchen); Abgelehntes bleibt WARNUNG-LAUT an den Chef (`ARBEIT-PROJEKT.md` „Zu 369“).

## Protokoll
Eine Zeile je Lauf mit Tat, neueste oben, höchstens 20 Zeilen; ältere streichen (Verlauf in Git, 117). Marken von `lauf.py` (Startsperre, Marke, Warnung) bleiben bis zur Aufräumung durch das Werkzeug.

- 08:21 01.11.: Neustart Jerry 0df217a41 angenommen: Nachfolger `01Hmoj77wY` „438 Prüferbefunde Wölfe“; alter Jerry `79d2` archiviert, 20,94 $ auf 403,406,438; Diogenes 374/434 `76ve` 08:05 gestartet; Sokrates (`7725`) per Nachricht auf 416.4a-Stellungnahme und D54 (422/427)
- 01:20 01.11.: Neustart Tom 8d9d896b5 angenommen: Nachfolger `01Hmoj76iH` „425 Testmenü Befunde“; alter Tom `7A2b` archiviert, Kosten **fehlen** (usage 0,30 $ unverändert seit 23:05, unplausibel für 3 h); Spike 425 `79S3` (01:04) sofort archiviert, Tom hatte 425 schon fertig (Lauf-Fehler: Stand „Chef“ kam erst 01:18 auf main) · Kosten **geschätzt 20 $** (Chef 01.11., 08:59: „Buche die Schätzung von 20 $“; Mittel Tom-Sitzungen 28.10., 404), gebucht auf 417 und 416.3 je 10 $; `usage` der Sitzung zeigte nur 0,30 $ (zählt nach Neustart des Arbeiters ab 0)
- 01:08 01.11.: Diogenes 443/443.1 (Perikles) gestartet und archiviert 2,68 $; Spike 416.9 archiviert 5,26 $, Spike 425 neu; Sokrates Stellungnahme 194.2 per Nachricht an die laufende Sitzung; Jerry-Nachfolger und Diogenes 374 weiter zurückgehalten (7:00/8:00)
- 00:08 01.11.: Selbstneustart Ford (Tiefe 6, Chefsache 110 `--laut` gesendet); Homer `01Hmoj771H` „430“, Perikles `01Hmoj76JN` „Stand zum Marktstart“, Spike `01Hmoj763K` „416.9“ gestartet; alter Spike `77yq` archiviert 9,21 $ auf 425; Jerry-Nachfolger bis 7:00 und Diogenes 374 bis 8:00 zurückgehalten; Sokrates-Desktop nicht archiviert
- 23:30 28.10.: Chef „Räum auf und buche Kosten“: Protokoll und Eingang gekürzt (Datei 18 → unter 15 KB), alter Ford 9,02 $ gebucht; drei Sitzungen ohne Kosten (Eingang).
- 22:07 28.10.: Perikles `01Hmoj77Hj` gestartet (400, Chef über Sokrates), alter Perikles `76yC` archiviert (3,05 $ auf 399). Ford-Lücke: Homer 399.2b (startbar seit 15:32, gestartet 19:06); jeden Lauf `startbar.py` gegen laufende Sitzungen prüfen.
- 21:27 31.10.: Marke Tagesbericht 31.10. (lauf.py)
- 21:27 31.10.: Marke Wächter 407 29.10. 10:05 (lauf.py)
- 22:12 31.10.: Marke Wächter 399.2 28.10. 12:34 (lauf.py)
- 22:18 31.10.: Marke Stellungnahme Sokrates 31.10. (lauf.py)
- 01:04 01.11.: Marke Stellungnahme Sokrates 01.11. (lauf.py)
- 02:04 01.11.: Marke Wächter 436 31.10. 22:58 (lauf.py)
- 07:03 01.11.: Marke Stellungnahme Sokrates 01.11. (lauf.py)
- 09:35 01.11.: Startsperre 09:35 Start Tom, Tuffy (lauf.py)
- 09:35 01.11.: Marke Archiv session_01Hmoj76r9gzqmymitAPFRzM (lauf.py)
- 09:35 01.11.: Marke Archiv session_01Hmoj76iHvA7sdceAF7G8xu (lauf.py)
- 09:35 01.11.: Marke Archiv session_01Hmoj76MhRcxfR5wtQBUWvM (lauf.py)
- 09:35 01.11.: Nachfolger-Warnung Diogenes (Übergabe 01.11., 08:19) (lauf.py)
- 10:03 01.11.: Startsperre 10:03 Start Homer, Perikles, Spike (lauf.py)
- 10:03 01.11.: Marke Archiv session_01Hmoj771HNBaV1MLATanNFh (lauf.py)
- 10:03 01.11.: Marke Archiv session_01Hmoj76JNjih3e8bDypbzLM (lauf.py)
- 10:52 01.11.: Startsperre 10:52 Start Homer (lauf.py)
- 10:52 01.11.: Marke Archiv session_01Hmoj78UPKAzZRiAoQaqqGf (lauf.py)
- 10:54 01.11.: Startsperre 10:54 Start Perikles (lauf.py)
- 10:54 01.11.: Marke Archiv session_01Hmoj79LZJEp4zYchmrpSq5 (lauf.py)
- 11:33 01.11.: Startsperre 11:33 Start Tom, Diogenes, Homer, Spike, Tuffy (lauf.py)
- 11:33 01.11.: Marke Archiv session_01Hmoj7725k4VV8sYVQzbjEf (lauf.py)
- 11:33 01.11.: Marke Archiv session_01Hmoj75aSrEfcUgJK1TdtXF (lauf.py)
- 11:33 01.11.: Marke Archiv session_01Hmoj76veooRHPFXzrNbmDh (lauf.py)
- 11:33 01.11.: Marke Archiv session_01Hmoj77Ri3TU93GFmiHPm1g (lauf.py)
- 11:33 01.11.: Marke Archiv session_01Hmoj78Tr4Xwwke3pCQ6Djg (lauf.py)
- 11:33 01.11.: Marke Archiv session_01Hmoj77nuFrNFqZ9hryD8sv (lauf.py)
- 11:33 01.11.: Nachfolger-Warnung Tom (Übergabe 01.11., 11:19) (lauf.py)
- 12:02 01.11.: Startsperre 12:02 Start Tom, Jerry, Homer, Perikles (lauf.py)
- 12:02 01.11.: Marke Archiv session_01Hmoj78fBw7YGLdEPi16NE4 (lauf.py)
- 12:02 01.11.: Marke Archiv session_01Hmoj78ic5EHpqP8XSFp1uk (lauf.py)
- 12:02 01.11.: Nachfolger-Warnung Diogenes (Übergabe 01.11., 11:49) (lauf.py)
- 12:04 01.11.: Marke Archiv-Warnung session_01Hmoj7725k4VV8sYVQzbjEf (lauf.py)
- 12:23 01.11.: Startsperre 12:23 Start Perikles, Spike (lauf.py)
- 12:23 01.11.: Marke Archiv session_01Hmoj77mtjttug7gy2vkMGw (lauf.py)
- 12:59 01.11.: Startsperre 12:59 Start Tom, Jerry, Homer, Perikles, Spike (lauf.py)
- 12:59 01.11.: Marke Archiv-Warnung session_01Hmoj78fBw7YGLdEPi16NE4 (lauf.py)
- 12:59 01.11.: Marke Archiv session_01Hmoj793shiZHbpTprrFuEf (lauf.py)
- 12:59 01.11.: Marke Archiv session_01Hmoj76CEuLaP52Vues8x4r (lauf.py)
- 12:59 01.11.: Nachfolger-Warnung Tom (Übergabe 01.11., 12:29) (lauf.py)
- 13:27 01.11.: Startsperre 13:27 Start Homer, Perikles, Spike, Tuffy (lauf.py)
- 13:27 01.11.: Marke Archiv session_01Hmoj75QreTNJ1SJBBwvqoE (lauf.py)
- 13:40 01.11.: Startsperre 13:40 Start Diogenes (lauf.py)
- 13:40 01.11.: Marke Archiv session_01Hmoj77LdCkeRk5o4ScWEC3 (lauf.py)
- 14:05 01.11.: Startsperre 14:05 Start Spike (lauf.py)
- 14:28 01.11.: Startsperre 14:28 Start Tom, Jerry, Perikles (lauf.py)
- 14:28 01.11.: Marke Archiv session_01Hmoj79PgK5YvxkM2AaUhNp (lauf.py)
- 14:28 01.11.: Marke Archiv session_01Hmoj76XrNEtedhDkbYxAKL (lauf.py)
- 14:28 01.11.: Marke Archiv session_01Hmoj795RxQjtYZCoyvS8Xo (lauf.py)
- 14:28 01.11.: Nachfolger-Warnung Diogenes (Übergabe 01.11., 13:49) (lauf.py)
- 15:05 01.11.: Startsperre 15:05 Start Perikles, Tuffy (lauf.py)
- 15:05 01.11.: Marke Wächter 457 01.11. 11:49 (lauf.py)
- 15:05 01.11.: Marke Archiv session_01Hmoj76yaRHkwz88v5f9Y8x (lauf.py)
- 15:41 01.11.: Startsperre 15:41 Start Perikles (lauf.py)
- 16:04 01.11.: Startsperre 16:04 Start Perikles, Spike (lauf.py)
- 16:04 01.11.: Marke Archiv session_01Hmoj76h41GHXWB93fuQoY2 (lauf.py)
- 20:29 01.11.: Startsperre 20:29 Start Tom, Homer, Perikles, Spike, Tuffy (lauf.py)
- 20:29 01.11.: Marke Archiv-Warnung session_01Hmoj76h41GHXWB93fuQoY2 (lauf.py)
- 20:29 01.11.: Marke Archiv session_01Hmoj75jkwVTekDz2J3BpQ5 (lauf.py)
- 20:29 01.11.: Marke Archiv session_01Hmoj79GPmpMxp1gC8dnHVY (lauf.py)
- 20:29 01.11.: Marke Archiv session_01Hmoj77VfBGxi3P8W9AxMeP (lauf.py)
- 20:29 01.11.: Marke Archiv session_01Hmoj77i7Y1xgebTmsmw7jo (lauf.py)
- 20:37 01.11.: Startsperre 20:37 Start Diogenes (lauf.py)
- 20:37 01.11.: Marke Archiv session_01Hmoj767cb5Yb7YgHPHEP1m (lauf.py)
- 21:04 01.11.: Startsperre 21:04 Start Jerry, Spike (lauf.py)
- 21:04 01.11.: Marke Archiv session_01Hmoj781ACpGwfwWp4ERY6K (lauf.py)
- 21:04 01.11.: Marke Archiv session_01Hmoj76tN9ZGtrauFQscNtm (lauf.py)
- 22:04 01.11.: Startsperre 22:04 Start Tom, Diogenes, Perikles, Tuffy (lauf.py)
- 22:04 01.11.: Marke Archiv session_01Hmoj79xJ7TcdWmhKGoPbWw (lauf.py)
- 22:04 01.11.: Marke Archiv session_01Hmoj7813G9wH1qB1mTUS4e (lauf.py)
- 22:04 01.11.: Marke Archiv session_01Hmoj75xjo1RLRDi5F7nzxU (lauf.py)
- 22:04 01.11.: Marke Archiv session_01Hmoj77mdcU4AngU6i87hj4 (lauf.py)
- 22:04 01.11.: Nachfolger-Warnung Diogenes (Übergabe 01.11., 20:49) (lauf.py)
