# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Übergabe (28.10., 23:58, Ford `session_01Hmoj76tScGGPZum5vs5UrG`, Tiefe 4, 400 Tsd. Token → Selbstneustart):** Läuft: Tom `01Hmoj76BK` „376.1 Köpfe, Haut, Robe“ (alter Tom `01Hmoj78mj` noch working, nach Neustart-Meldung 3ffad41ab: archivieren sobald idle, Kosten 376.1,399.5), Jerry `01Hmoj77So` „348.12 Grak nachbessern“, Perikles `01Hmoj77Hj` „400“, Sokrates `01Hmoj78Ck` „Chefrunde“ (idle), Homer `01Hmoj77EQ` (idle, Vorrat leer). Diogenes ab 29.10. täglich 8:00 bis 03.11. (374). Wochenlimit `allowed_warning` (bis Sa 31.10., 20:00): `lauf.py --nur-muss`. Arbeitsweise im Eingang. Nachfolger: Ford – Betriebsleiter.

**Nächste freie Vorgangsnummer: 417** (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef: „Habe Pro gekündigt, steht nur noch auf Free“): Ford-2-Regeln ausgesetzt (`LISTE-FORD2.md`); Guthaben nur Max. **Jerry läuft in der Zentrale** (`LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, Einrichtung aus Git (`LISTE-NIEDERLASSUNG.md` bis `f3ec7200`)

**Ford: Pilot** (seit Sa 17.10., 21:05; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (Übersicht `docs/chefsache/README.md`; https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht: `docs/PRUEFBERICHT.md`

**Sparbetrieb (Chef 23.10., 10:22):** „Was angestoßen ist, machen wir fertig, ich prüfe Entwürfe, wir aktualisieren und bauen ein.“ Ford startet nur Rückläufer des Chefs und den Build für seinen Spieletest; keine Neustarts ohne Arbeit; Sokrates 318 (20 Uhr) auf So nach 21 Uhr, Auswertung 340 erst nach der Zurücksetzung.

**Guthaben:** **Bild Chef 27.10., 09:47 (an Sokrates):** Woche 51 %, Sitzung 9 %; „Limit Donnerstagnacht aufgebraucht, vor der Zurücksetzung am Samstag“; Nutzungsguthaben-Schalter an, 0 Guthabenpunkte; Takt 1,09 %/h · **Max 20x seit 25.10., ~11:00**: 287 gilt (ab 80 % `lauf.py --nur-muss`, ab 95 % nur Rückläufer des Chefs, ab 100 % Stillstand, nichts nachkaufen); Monat bis 25.10. 303,02 $ · ältere Bilder: Git

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Ford lebt in einer Sitzung** „Ford – Betriebsleiter (28.10., 23:59)“ `session_01Hmoj7996yJhuNe5DcYpoqk` (Tiefe 5); Stundenuhr „Ford-Lauf“ `trig_01Kf2sLW1chKJPA2mLCU4Uay` (:03, geprüft 23:56), geht mit dem Selbstneustart auf den Nachfolger über. Alter Ford `01Hmoj76tS` archiviert 23:56.
- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (D13.2).
- **(ruht, 159)** Ford 2: Stundenuhr aus; Sitzung `session_017VRJsTBwEbU16mwomLknhm`, Uhr `trig_01WCdVmLssvGbjCSK9KJPCPH`; bei Wiedereinschalten neu prüfen.

## Eingang

- **Arbeitsweise (28.10.):** Jeden Lauf `list_sessions` (alle Seiten in Kurzzeilen-Datei, letzte Zeile `# has_more: nein`), `lauf.py --nur-muss --sperre --besetzung <Datei>`, `startbar.py` gegen laufende Sitzungen prüfen; nicht nur auf Neustart-Meldungen warten (Lücke Homer 399.2b). Neustart-Meldung: Commit auf `origin/main` und „Nachfolger:“ in der Übergabe prüfen; Titelkorrekturen kommen oft nach, dann Nachfolger per Nachricht umstellen und `set_session_title`. Kosten nur aus `usage.cost_usd` vor dem Archivieren (`archive_session` liefert sie, danach fehlt sie); `lauf.py --kosten <Nr,Nr> <Betrag> <Kennung>` aus `/home/user/bornim-main`; `git pull --no-rebase`, pushen. Jede `create_session` mit `source_revision` `main`, `source_url`, Umgebung (Tom, Jerry Hoch `env_017fgL1YDcVTYTkJsU3APEfR`, sonst Mittel `env_01F9WxikYD4TTdhscxvPi93p`), erste Nachricht nur die Rolle, `append_system_prompt` mit dem add_repo-Satz bei Tom/Jerry. Nachts (22–7) lautlos; Chef nie mit Kennungen ansprechen, nur Titel.

- **Stopp Durchläufe (Chef 29.10., 10:05, über Sokrates 10:07):** „stoppe weitere Durchläufe … Ich habe noch nichts geguckt und freigegeben. Also, warten, bis ich gucke.“ Ford startet keine Sitzung für eine weitere Runde zu einer Vorlage in `docs/chefsache/ansehen/` (399.5, 376.1, 348.12, 402, 406, 399.1), bis der Chef geurteilt hat; `lauf.py` mit `--ohne NR:Chef-Stopp 29.10.` ausschließen. Werkzeug-Lücke (Zähler) als 407 bei Perikles.

- **Dauerregel (Chef 28.10., 10:38):** jeder Start von Tom, Jerry und der Leihentwickler (Tom 2 u. ä.) trägt in der ersten Nachricht (oder `append_system_prompt`) den Satz: „Der Chef erlaubt, tramour-cmyk/bornim-kaufmodelle per add_repo einzubinden, wenn die Aufgabe gekaufte Modelle braucht (Vorgangsarchiv 376.1, 28.10., 08:35).“ Ford hängt ihn an jedes `create_session` für diese Rollen; `lauf.py` kennt ihn noch nicht (Werkzeug bei Perikles).

Anregungen ohne Bereich und Startwünsche (eine Zeile, Datum, Absender). Ford teilt im nächsten Lauf zu oder legt sie dem Chef vor.

- **404 (wartet auf Chef, `chefsache/entscheiden/404-kosten-schaetzung.md`):** schätzen oder „fehlt“ lassen. **Fehlende Kosten (28.10.):** Tom 2 „385 Zaubererbewegung“ `01Hmoj79kd` (Ordner 385), Jerry „348.12 Gestalt Grak und Kobolde“ `01Hmoj78yA` (348.12), Tom „348.13 Tusche Runde 8“ `01Hmoj79S6` (348.13): archiviert ohne Kostenangabe, `usage` im archivierten Datensatz leer; Kosten bleiben „fehlt“.
- **374 (Sokrates 27.10., 12:00, Chef „374 ja“):** Diogenes täglich 8:00 vom 28.10. bis 03.11. starten (zählt die Vorlagen des Vortags, Zeile oben in `ARBEIT-PRUEFUNG.md`); im ersten Lauf ab 8 Uhr „Auftrag Diogenes 374“ wie `START`. Nach dem 03.11. Zeile streichen. Übergabe von Diogenes nennt „348.9 Blätter messen“ (nicht startbar, wartet auf Eingang): Perikles/Diogenes anpassen.
- **Von Sokrates (27.10., 09:3x):** Vorräte nennen „beim Chef“ ohne Datei (gilt nach Regel 8 nicht): Jerry „Boden r6, Grimmzahn“, „Wildschwein r3“; Tom „Dorf r13b“; Homer wartet auf Chefsache 348.12c. Bitte an Tom, Jerry, Homer zum Bereinigen.
- **369:** Chef 26.10., 18:46 „nein, Regel steht schon“: Der Auto-Modus-Prüfer lehnt `archive_session` manchmal ab (dann einmal neu versuchen); Abgelehntes bleibt WARNUNG-LAUT an den Chef (`ARBEIT-PROJEKT.md` „Zu 369“).

## Protokoll
Eine Zeile je Lauf mit Tat, neueste oben, höchstens 20 Zeilen; ältere streichen (Verlauf in Git, 117). Marken von `lauf.py` (Startsperre, Marke, Warnung) bleiben bis zur Aufräumung durch das Werkzeug.

- 22:23–23:13 28.10.: Tom 7d5e21fac/f449ea4a9/e91b86781 Neustarts, Nachfolger `01Hmoj78mj` „376.1 Köpfe, Haut, Robe“ (Titel nach Korrekturen umgestellt); Jerry 96d840aae: Nachfolger `01Hmoj77So`; alte archiviert und gebucht: Tom `75YJ` 19,49 $ (399.1), Jerry `775u` 25,55 $ (399.2,399.2b,399.3), Tom `79nW` 19,45 $ (376.1)
- 16:35–21:41 28.10.: Neustarts Sokrates (alter `78fq` 23,05 $ auf 385,387,396a,397,398,399), Tom 9eabc83d1/fb048b94a/a12e99b0d/bc486f1d9 (Nachfolger je gestartet, alte archiviert: 28,01 + 13,76 + 25,48 + 16,58 $ auf 399.1 u. a.), Jerry 8aefbb7b1 (`77PX` 14,85 $ auf 399.3,399.2); Homer `01Hmoj77EQ` 19:06 (399.2b)
- 13:09–15:49 28.10.: Neustarts Jerry cf599b056 (alter `75RG` 19,91 $ auf 399.2,348.12; 14:43 zurückgestellt bis Chefantwort 348.12), Tom 971fcda1a (alter `76N4` 30,41 $ auf 399.1,390,397); Jerry `76aX` 27,93 $ (348.12,387,399.2); Diogenes `77nv` 0,79 $
- 17:35–19:54 27.10.: Ford-Selbstneustart; Neustarts angenommen: Sokrates 19:08, Tom 19:32, Jerry 19:40, Tom 19:54; Vorgang 382 an Perikles
- 01:37–06:35 27.10.: Neustarts angenommen und Nachfolger gestartet (Tom 13×, Jerry 4×); Jerry 05:55 zurückgestellt (wartet auf Chefsache 3487a)
- 25.10., 09:35–21:05: Neustarts Tom/Jerry/Sokrates angenommen; Perikles 364 und Sokrates 340.2 gestartet; Sparbetrieb und Max 20x (Verlauf in Git)

- 23:30 28.10.: Chef „Räum auf und buche Kosten“: Protokoll und Eingang gekürzt (Datei 18 → unter 15 KB), alter Ford 9,02 $ gebucht; drei Sitzungen ohne Kosten (Eingang).
- 22:07 28.10.: Perikles `01Hmoj77Hj` gestartet (400, Chef über Sokrates), alter Perikles `76yC` archiviert (3,05 $ auf 399). Ford-Lücke: Homer 399.2b (startbar seit 15:32, gestartet 19:06); jeden Lauf `startbar.py` gegen laufende Sitzungen prüfen.
- 00:05 28.10.: Marke Abgleich Vorentscheid 348.7 ohne Datei in chefsache/billigen/ und ohn (lauf.py)
- 00:05 28.10.: Marke Abgleich Vorentscheid 348.6 ohne Datei in chefsache/billigen/ und ohn (lauf.py)
- 03:04 28.10.: Marke Wächter 389 27.10. 23:55 (lauf.py)
- 07:05 28.10.: Nachfolger-Warnung Jerry (Übergabe 28.10., 06:35) (lauf.py)
- 08:05 28.10.: Marke Tagesbericht 28.10. (lauf.py)
- 09:05 28.10.: Marke Stellungnahme Sokrates 28.10. (lauf.py)
- 10:05 28.10.: Marke Stellungnahme Sokrates 28.10. (lauf.py)
- 12:36 28.10.: Startsperre 12:36 Start Perikles (lauf.py)
- 13:11 28.10.: Nachfolger-Warnung Diogenes (Übergabe 28.10., 12:19) (lauf.py)
- 22:09 28.10.: Marke Wächter 399.2 28.10. 12:34 (lauf.py)
- 23:57 28.10.: Startsperre 23:57 Start Perikles (lauf.py)
- 23:57 28.10.: Marke Archiv session_01Hmoj78mjLPT6PZaqKUninZ (lauf.py)
- 23:57 28.10.: Marke Archiv session_01Hmoj77Hj5um3BFGBKYLTet (lauf.py)
- 00:05 29.10.: Startsperre 00:05 Start Diogenes (lauf.py)
- 00:05 29.10.: Marke Stellungnahme Sokrates 29.10. (lauf.py)
- 00:05 29.10.: Marke Stellungnahme Sokrates 29.10. (lauf.py)
- 00:05 29.10.: Marke Abgleich Vorentscheid 383.1 ohne Datei in chefsache/billigen/ und ohn (lauf.py)
- 01:04 29.10.: Startsperre 01:04 Start Homer, Perikles (lauf.py)
- 01:04 29.10.: Marke Archiv session_01Hmoj78CkDLhCvXmQHdzaYa (lauf.py)
- 01:04 29.10.: Marke Archiv session_01Hmoj76BK5vdJyc6arYtcYr (lauf.py)
- 01:04 29.10.: Marke Archiv session_01Hmoj77EQQWjq6C98Pf9qhb (lauf.py)
- 01:04 29.10.: Marke Archiv session_01Hmoj76y2gSrrvMTYAnBSWJ (lauf.py)
- 07:06 29.10.: Startsperre 07:06 Start Jerry (lauf.py)
- 07:06 29.10.: Marke Archiv session_01Hmoj76ki21kJDZKro2ad6K (lauf.py)
- 07:06 29.10.: Nachfolger-Warnung Tom (Übergabe 29.10., 04:29) (lauf.py)
- 07:06 29.10.: Nachfolger-Warnung Jerry (Übergabe 29.10., 00:19) (lauf.py)
- 08:06 29.10.: Startsperre 08:06 Start Diogenes (lauf.py)
- 09:04 29.10.: Nachfolger-Warnung Jerry (Übergabe 29.10., 07:59) (lauf.py)
- 09:04 29.10.: Nachfolger-Warnung Diogenes (Übergabe 29.10., 08:19) (lauf.py)
