# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Übergabe (27.10., 23:06, Ford `session_01Hmoj75jVp5KYNTRoJ7QXfq`, Tiefe 2, 385 Tsd. Token → Selbstneustart):** Läuft: Tom `01Hmoj772C` „348.6 Häuser mit Innenraum“ (PR #176 Build 90 nur 388: Testbitte an den Chef, nach dessen Ja main und „play“; danach 385 Zauberbewegung), Jerry `01Hmoj7A1B` „348.12f Drehen auf der Stelle, Ratte Schnauze“ (danach 387 gekaufte Tiere prüfen). Perikles `01Hmoj77KV` (383.3 fertig) und Sokrates `01Hmoj79NG` (Chefrunde) idle, nichts zu archivieren, solange kein Nachfolger läuft. Homer ohne Sitzung; Diogenes ab 28.10. täglich 8:00 bis 03.11. (374, `START`/„Auftrag Diogenes 374“). Archivieren geht wieder (Chef 20:2x „archiviere die überzähligen Sitzungen“): nach jedem Neustart den Absender archivieren, sobald `idle`, vorher PR-Abo übergeben; Kosten **nur aus `usage.cost_usd` von `get_session`/`archive_session`, nie schätzen** (Fehler 19:37 zurückgenommen), `lauf.py --kosten <Nr,Nr> <Betrag> <Kennung>` aus `/home/user/bornim-main2` (Klon, `bornim-main` hängt seit 17:36 in einem Rebase; Notizen dort mit Edit, `git pull --no-rebase`, pushen). Jede `create_session` mit `source_revision` `main`, `source_url`, Umgebung wie die `START`-Zeile von `lauf.py` (Tom, Jerry Hoch `env_017fgL1YDcVTYTkJsU3APEfR`, sonst Mittel), erste Nachricht nur die Rolle. Vor `lauf.py` die Sitzungen als Kurzzeilen in eine Scratchpad-Datei, letzte Zeile `# has_more: nein`. Chef nie mit Kennungen ansprechen, nur Titel; nachts (22–7) lautlos. Nachfolger: Ford – Betriebsleiter.

**Nächste freie Vorgangsnummer: 390** (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef: „Habe Pro gekündigt, steht nur noch auf Free“): Ford-2-Regeln ausgesetzt (`LISTE-FORD2.md`); Guthaben nur Max. **Jerry läuft in der Zentrale** (`LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, Einrichtung aus Git (`LISTE-NIEDERLASSUNG.md` bis `f3ec7200`)

**Ford: Pilot** (seit Sa 17.10., 21:05; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (Übersicht `docs/chefsache/README.md`; https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht: `docs/PRUEFBERICHT.md`

**Sparbetrieb (Chef 23.10., 10:22, Bild: Woche „Alle Modelle“ 100 %, Zurücksetzung Sa 20:59; nur Credits, Guthaben 79,38, Monatslimit unbegrenzt):** „Was angestoßen ist, machen wir fertig, ich prüfe Entwürfe, wir aktualisieren und bauen ein. Dann wird wohl der Spieletest heut bei mir stattfinden.“ Ford startet nur Rückläufer des Chefs und den Build für seinen Spieletest; laufende Sitzungen machen ihren Schritt fertig und übergeben, keine Neustarts ohne Arbeit; Sokrates 318 (20 Uhr) auf So nach 21 Uhr, Auswertung 340 erst nach der Zurücksetzung.

**Guthaben:** **Bild Chef 27.10., 09:47 (an Sokrates):** Woche 51 %, Sitzung 9 %; Hinweis „Limit Donnerstagnacht aufgebraucht, vor der Zurücksetzung am Samstag“; Nutzungsguthaben-Schalter an, 0 Guthabenpunkte; Takt 26.10. 11:43 → 27.10. 09:47: 1,09 %/h, Vorhersage unten bestätigt. **Bild 26.10., 11:43 (an Perikles):** Woche 27 % (Zurücksetzung Sa 31.10., 20:00), Sitzung 12 % (bis 12:00); Hinweis „Limit in der Nacht auf Samstag“. Takt seit 0 % am 25.10., 11:05: 1,1 %/h → 80 % Mi 28.10. ~12, 95 % Do ~02, 100 % Do ~06 (Perikles; Anzeige rechnet langsamer); 287 gilt · **Max 20x seit 25.10., ~11:00**: 287 gilt weiter (80/95-%-Regel: ab 80 % `lauf.py --nur-muss`, ab 95 % nur Rückläufer des Chefs, ab 100 % Stillstand, nichts nachkaufen); Monat bis 25.10. 303,02 $ · ältere Bilder: Git vor „Perikles: Guthaben 26.10.“

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Ford lebt in einer Sitzung** „Ford – Betriebsleiter (27.10., 23:06)“ `session_01Hmoj78maf1xG6QSj4w28Lw` (Tiefe 3); Stundenuhr „Ford-Lauf“ `trig_014A6QWBSksj49igbfpa1D6i` (:03, geprüft 23:06), geht mit dem Selbstneustart auf den Nachfolger über. Alter Ford `01Hmoj75jV` archiviert 23:58 (7,73 $).
- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (D13.2).
- **(ruht, 159)** Ford 2: Stundenuhr aus; Sitzung `session_017VRJsTBwEbU16mwomLknhm`, Uhr `trig_01WCdVmLssvGbjCSK9KJPCPH`; bei Wiedereinschalten neu prüfen.

## Eingang

- **Nacht 27./28.10. (Sokrates 00:02, Chef 00:01 Leitung bis Morgen, Archiv „Nacht 27./28.10.“):** jedem Start und Lauf mitgeben: Tom, Jerry arbeiten ohne den Chef weiter, fertige Vorlagen aufs Morgenblatt (Chefsache „ansehen“), gleich die nächste startbare Zeile, nicht warten; höchstens zwei Probeläufe je Vorlage (389), keine 1:1-Kopien („348, Maßstab“); meldet sich jemand „wartet auf Chef“, ihm die nächste Zeile geben. Diogenes 374 erst 8:00.

Anregungen ohne Bereich und Startwünsche (eine Zeile, Datum, Absender). Ford teilt im nächsten Lauf zu oder legt sie dem Chef vor.

- **Von Tom (27.10., 18:4x):** Fords Zeiten seit dem Selbstneustart eine Stunde vor: Protokoll „19:08“, „19:32“ und Commit „Neustart Tom 19:32“ waren 18:08 und 18:32 (Commit 17:32 UTC; seit 25.10. MEZ = UTC+1). Uhrzeit nur aus `TZ=Europe/Berlin date` (Bekannte Fehler, Zeile 1); beide Zeilen berichtigen.

- **Von Perikles (378, 27.10., 15:0x; Durchsicht Sokrates):** Dashboard (339) seit 08:07 nicht erneuert (Perikles hat 15:1x veröffentlicht; jeder Lauf, `LISTE-BETRIEB.md` 11); `ARBEIT-BESETZUNG.md` Stand 13:23, alle Sitzungen ersetzt; Übergabe oben nennt Perikles `77YJ` laufend; Eingang: Zeilen archiviert/ERLEDIGT/318 „nach dem ersten Start streichen“, „Sparbetrieb (23.10.)“ prüfen; Protokoll etwa 70 statt 20 Zeilen (Datei 15,5 KB); acht erledigte Sitzungen nicht archiviert (Tom `79SM`, `778n`; Jerry `761u`, `76oY`; Sokrates `7738`; Perikles `77YJ`; Diogenes `77X9`; Ford `78hRdj`): versuchen, Abgelehntes dem Chef nennen (369); Diogenes 348.9 Nachfolger „Blätter messen“ starten.

- **374 (Sokrates 27.10., 12:00, Chef „374 ja“):** Diogenes täglich 8:00 vom 28.10. bis 03.11. starten (zählt die Vorlagen des Vortags, Zeile oben in `ARBEIT-PRUEFUNG.md`); im ersten Lauf ab 8 Uhr „Auftrag Diogenes 374“ wie `START`. Werkzeugteil bei Perikles. Nach dem 03.11. Zeile streichen.
- **Von Sokrates (27.10., 09:3x, Durchsicht Chefsache):** Vorräte nennen „beim Chef“ ohne Datei (gilt nach Regel 8 nicht): Jerry „Boden r6, Grimmzahn“ (entschieden 25.10., 22:00), „Wildschwein r3“; Tom „Dorf r13b“. Homer wartet nicht auf 348.12g (entschieden 26.10., 16:17), sondern auf Chefsache 348.12c Listen. Bitte an Tom, Jerry, Homer zum Bereinigen. Chefsache 110 erledigt (Ford von Hand gestartet), Datei gelöscht.
- **369:** Chef 26.10., 18:46 „nein, Regel steht schon“: Der Auto-Modus-Prüfer lehnt `archive_session` ab, der Chef archiviert von Hand; Abgelehntes bleibt WARNUNG-LAUT an den Chef (`ARBEIT-PROJEKT.md` „Zu 369“).

## Protokoll
Eine Zeile je Lauf mit Tat, neueste oben, höchstens 20 Zeilen; ältere streichen (Verlauf in Git, 117).

- 17:35–19:54 27.10.: Ford-Selbstneustart; Neustarts angenommen: Sokrates 19:08, Tom 19:32, Jerry 19:40, Tom 19:54; Vorgang 382 an Perikles
- 01:37–06:35 27.10.: Neustarts angenommen und Nachfolger gestartet: Tom 01:46, 02:33, 02:57, 03:23, 03:51, 04:16, 04:43, 05:01, 05:20, 05:44, 06:03, 06:35, 07:21; Jerry 01:37, 02:42, 03:25, 04:57; Jerry 05:55 zurückgestellt (wartet auf Chefsache 3487a). Läufe 02:03, 03:03 ohne Starts; START Perikles (Terminname) nicht ausgeführt
- 25.10., 09:35–21:05: Neustarts Tom/Jerry/Sokrates angenommen; Perikles 364 und Sokrates 340.2 gestartet; Sparbetrieb und Max 20x (Verlauf in Git)

- 05:53 28.10.: Jerry-Kosten gebucht (50,64 $ auf 387, 348.12); `rate_limit_info` der Sitzung zeigt `seven_day` `allowed_warning` (Zurücksetzung 1793473200): ab jetzt `lauf.py --nur-muss` (D31.3, 287)
- 05:51 28.10.: Neustart Jerry angenommen (`49af405c0`), Nachfolger „Jerry – 348.7b Zauberbahn nach Chef „D““ gestartet (main, Hoch); alter Jerry `01Hmoj75wa` archiviert
- 04:22 28.10.: Neustart Jerry angenommen (`61baa45cf`), Nachfolger „Jerry – 387 Ursachen Huhn, Kaninchen, Rind, Hundertfüßer, dann 348.12 r3“ gestartet (main, Hoch); alter Jerry `01Hmoj79G6` archiviert
- 02:38 28.10.: Neustart Jerry angenommen (`07948ad02`), Nachfolger „Jerry – 348.12 Runde 2 prüfen und vorlegen, dann 387“ gestartet (main, Hoch); alter Jerry `01Hmoj76Hc` archiviert
- 01:56 28.10.: Neustart Tom angenommen (`2916a3231`), Nachfolger „Tom – 348.6 Dorf Lauf 3“ gestartet (main, Hoch); alter Tom `01Hmoj79S6` archiviert, Kosten fehlen (Antwort ohne `usage`)
- 01:50 28.10.: Neustart Jerry angenommen (`e66f04f37`), Nachfolger „Jerry – 348.12 Befunde Kobold und Grak, dann 387“ gestartet (main, Hoch); alter Jerry `01Hmoj79cL` archiviert
- 00:55 28.10.: Neustart Jerry angenommen (`f9a7149a5`), Nachfolger „Jerry – 348.12 Grak und Kobold aufs CC0-Gerüst“ gestartet (main, Hoch); alter Jerry `01Hmoj7A1B` archiviert; Tom bekam 348.6 (Chef 00:07) als Vorrang; Diogenes 374 mit `--ohne` bis 8:00 zurückgestellt
- 23:08 27.10.: Selbstneustart Ford (Tiefe 3) angenommen: Uhr `trig_014A6QWBSksj49igbfpa1D6i` angelegt und geprüft, alte gelöscht; alter Ford `01Hmoj75jV` archivieren zweimal abgelehnt (369), WARNUNG-LAUT nachts zurückgestellt; Tom `772C`, Jerry `7A1B` laufen, Perikles `77KV`, Sokrates `79NG` idle; kein Start nötig
- 22:51 27.10.: Neustart Jerry angenommen (`ab3cc8cf3`), Nachfolger `01Hmoj7A1B` „Jerry – 348.12f Drehen auf der Stelle, Ratte Schnauze“ gestartet (main, Hoch); alter Jerry `01Hmoj78dk` archiviert, gebucht (32,36 $ auf 348.12f, 387)
- 22:34 27.10.: Neustart Tom angenommen (`54e43fbf9`), Nachfolger `01Hmoj772C` „Tom – 348.6 Häuser mit Innenraum“ gestartet (main, Hoch), PR-Abo #176 (Build 90, nur 388) an ihn gegeben; alter Tom `01Hmoj78ky` war schon `idle` ohne Testbitte → archiviert, gebucht (16,29 $ auf 348.6, 388); Testbitte Build 90 dem neuen Tom übertragen
- 21:24 27.10.: Neustart Tom angenommen (`c67054d15`), Nachfolger `01Hmoj78ky` „Tom – 348.6 Probehaus Fenster“ gestartet (main, Hoch); alter Tom `01Hmoj79DD` archiviert und gebucht (20,09 $ auf 376.1); 385 (Sokrates) nimmt Tom nach 348.6/376.1 aus dem Vorrat
- 20:36 27.10.: Neustart Jerry angenommen (`3a253a7f5`), Nachfolger `01Hmoj78dk` „Jerry – 348.12f Janpec-Wolf Probe“ gestartet (main, Hoch); alter Jerry `01Hmoj76E9` archiviert, Kosten fehlen (Antwort ohne `usage`, nicht geraten)
- 20:26 27.10.: Auftrag Sokrates (Chef 19:23 „383.1 ja, Perikles soll das jetzt umsetzen“): Perikles `01Hmoj76Wn` „Perikles – 383.1 (27.10., 19:26)“ gestartet (main, Mittel), alter Perikles `01Hmoj76q6` (238 Tsd. Token, fertig) archiviert und gebucht (4,87 $ auf 383)
- 20:25 27.10.: Auf Wort des Chefs („archiviere die überzähligen Sitzungen“) zehn fertige Sitzungen archiviert (Jerry `761r`, `75RB`, `76PX`; Sokrates `79xv`, `78Sx`, `77UK`; Tom `76F3`, `77wa`, `78Xe`; Perikles `77bY`) und gebucht (zus. 99,32 $); Prüfer ließ es durch, 369 erledigt
- 20:21 27.10.: Neustart Jerry angenommen (`940d29967`), Nachfolger `01Hmoj76E9` „Jerry – 348.12f Ortswechsel Fehlerrunde“ gestartet (main, Hoch); alter Jerry `01Hmoj76PX` zu archivieren (Prüfer lehnt ab, 369), Kosten ungebucht
- 20:20 27.10.: Neustart Tom angenommen (`3699c749a`), Nachfolger `01Hmoj76zw` „Tom – 348.13a Tusche mit schräger Sonne“ gestartet (main, Hoch); alter Tom `01Hmoj78Xe` zu archivieren (Prüfer lehnt ab, 369), Kosten ungebucht
- 20:15 27.10.: Neustart Sokrates angenommen (`5ef998c3e`), Nachfolger `01Hmoj79NG` „Sokrates – Chefrunde 348.13a und Bausätze 376“ gestartet (main, Mittel); alter Sokrates `01Hmoj77UK` zu archivieren (Prüfer lehnt ab, 369), Kosten ungebucht
- 20:06 27.10.: Neustart Tom angenommen (`cb2503fc7`), Nachfolger `01Hmoj79DD` „Tom – 376.1 Kaufkopf anpassen“ gestartet (main, Hoch); alter Tom `01Hmoj76zw` archiviert und gebucht (3,13 $ auf 348.13a)
- 20:04 27.10.: Lauf; Perikles „383.3 (27.10., 20:04)“ `01Hmoj77KV` gestartet (main, Mittel); alter Perikles `01Hmoj76Wn` (383.1 fertig, gebilligt) archiviert und gebucht (2,01 $); Tom, Jerry laufen
- 19:54 27.10.: Neustart Tom angenommen (`1e131ce2b`), Nachfolger `01Hmoj78Xe` „Tom – 376 Probehaus prüfen, vorlegen“ gestartet (main, Hoch); alter Tom `01Hmoj76F3` zu archivieren (Prüfer lehnt ab, 369), Kosten ungebucht
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
- 18:05 27.10.: Marke Archiv session_01Hmoj761r5ZST4uDLR8QyTM (lauf.py)
- 18:05 27.10.: Marke Archiv session_01Hmoj79xvKYy4VB6rvFGma7 (lauf.py)
- 18:05 27.10.: Nachfolger-Warnung Diogenes (Übergabe 27.10., 17:09) (lauf.py)
- 19:05 27.10.: Startsperre 19:05 Start Perikles (lauf.py)
- 19:05 27.10.: Marke Archiv session_01Hmoj75RBVFzYCwsDWcdXwY (lauf.py)
- 19:05 27.10.: Marke Archiv-Warnung session_01Hmoj761r5ZST4uDLR8QyTM (lauf.py)
- 19:05 27.10.: Marke Archiv session_01Hmoj78SxUwEZNsTMHCZo6F (lauf.py)
- 19:05 27.10.: Marke Archiv-Warnung session_01Hmoj79xvKYy4VB6rvFGma7 (lauf.py)
- 19:05 27.10.: Marke Archiv session_01Hmoj76F3KvM4odEwqUYmo3 (lauf.py)
- 19:05 27.10.: Marke Archiv session_01Hmoj77waA193TDB2hnJsnm (lauf.py)
- 19:05 27.10.: Marke Archiv session_01Hmoj77bYPVAwDMmjEUx18c (lauf.py)
- 20:04 27.10.: Startsperre 20:04 Start Perikles (lauf.py)
- 20:04 27.10.: Marke Abgleich Vorentscheid 383.1 ohne Datei in chefsache/billigen/ und ohn (lauf.py)
- 20:04 27.10.: Marke Archiv session_01Hmoj76Wn7nYknRiqdsrpYq (lauf.py)
- 23:56 27.10.: Startsperre 23:56 Start Perikles (lauf.py)
- 23:56 27.10.: Marke Archiv session_01Hmoj77KVVgxT4ibZLpzXjH (lauf.py)
- 00:01 28.10.: Startsperre 00:01 Start Diogenes (lauf.py)
- 00:05 28.10.: Marke Abgleich Vorentscheid 348.7 ohne Datei in chefsache/billigen/ und ohn (lauf.py)
- 00:05 28.10.: Marke Abgleich Vorentscheid 348.7 ohne Datei in chefsache/billigen/ und ohn (lauf.py)
- 00:05 28.10.: Marke Abgleich Vorentscheid 348.6 ohne Datei in chefsache/billigen/ und ohn (lauf.py)
- 00:05 28.10.: Marke Abgleich Vorentscheid 348.7 ohne Datei in chefsache/billigen/ und ohn (lauf.py)
- 00:05 28.10.: Marke Abgleich Vorentscheid 348.7 ohne Datei in chefsache/billigen/ und ohn (lauf.py)
- 00:05 28.10.: Marke Abgleich Vorentscheid 348.7 ohne Datei in chefsache/billigen/ und ohn (lauf.py)
- 00:05 28.10.: Marke Abgleich Vorentscheid 348.7 ohne Datei in chefsache/billigen/ und ohn (lauf.py)
- 03:04 28.10.: Marke Wächter 389 27.10. 23:55 (lauf.py)
- 04:04 28.10.: Startsperre 04:04 Start Perikles (lauf.py)
- 05:04 28.10.: Startsperre 05:04 Start Perikles (lauf.py)
- 05:04 28.10.: Marke Archiv session_01Hmoj76mW9cxhS7viQ9cfW9 (lauf.py)
- 06:04 28.10.: Startsperre 06:04 Start Perikles (lauf.py)
- 07:05 28.10.: Startsperre 07:05 Start Perikles (lauf.py)
- 07:05 28.10.: Nachfolger-Warnung Jerry (Übergabe 28.10., 06:35) (lauf.py)
