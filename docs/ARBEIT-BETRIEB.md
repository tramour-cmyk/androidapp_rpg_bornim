# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Regeln für Ford bis Sa 14.11., 20:00 (Chef 07:09/07:18/07:19, Ford 08:13):** Archivieren und Kosten dauerhaft in `ROLLE-BETRIEB.md` (1110); alle Rollen in Hoch (`lauf.py` kann es seit 901, Umgebung `env_017fgL1YDcVTYTkJsU3APEfR`; Prüfen im START); ohne `--nur-muss`; Teampausen aufgehoben. `lauf.py` immer aus `/home/user/bornim-main/tools` rufen, nie aus dem Arbeitskopf ohne `git pull` (rechnet mit altem Stand). Dauerausschluss siehe Übergabe unten. Nachfolger: Ford – Betriebsleiter

**Nächste freie Vorgangsnummer: 1504** (zuletzt 1503 Sokrates 17.11. 00:05:46 7f8e) (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef: „Habe Pro gekündigt, steht nur noch auf Free“): Ford 2 entfällt (650.1, Chef 08.11., 13:36; Regeln in `alt/LISTE-FORD2.md`), Niederlassung bleibt als Gedanke; Guthaben nur Max. **Jerry läuft in der Zentrale** (`LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, Einrichtung aus Git (`LISTE-NIEDERLASSUNG.md` bis `f3ec7200`)

**Ford: Pilot** (seit Sa 17.10., 21:05; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (Übersicht `docs/chefsache/README.md`; https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht: `docs/PRUEFBERICHT.md`

**Alle Sperren aufgehoben (Chef 07.11., 20:2x):** alle Rollen startbar; Vorrang Fehler aus den Tests des Chefs (wiederholte zuerst, 620.1). Es gelten weiter: 621 A (eine Probe je Aussehen-Thema), 488 (Aussehen eingefroren bis zum Durchspielen), 287 nach dem nächsten Bild des Guthabens.

**Guthaben:** **Chef 16.11., 21:30 (an Perikles, Chat):** „Aktuell 50 Prozent Wochemverbrauch. Wir machen weiter ohne Einschränkungen.“; seit 12:13 (37 %) 1,4 %/h, seit Zurücksetzung Sa 14.11., 20:00 (angenommen, nächste Sa 21.11., 20:00) 49,5 h ≈ 1,0 %/h, tragbar für den Rest ≈ 0,42 %/h; bei 1,4 %/h 80 % (287) Di 17.11. ≈ 19:00, 100 % Mi 18.11. ≈ 09:00; 287 bleibt, bis der Chef anderes sagt; vorher (13.11.) Woche 66 %, ältere Bilder in Git; Limit-Reset „Kostenlos zurücksetzen“ (läuft ab 9. März) verfügbar, Reserve; Nutzungsguthaben an, 0 Credits · **Max 20x seit 25.10., ~11:00**: 287 gilt (ab 80 % `lauf.py --nur-muss`, ab 95 % nur Rückläufer des Chefs, ab 100 % Stillstand, nichts nachkaufen); Monat bis 25.10. 303,02 $ · ältere Bilder (bis 06.11.): Git · 13.11., 15:00: Sitzungsdaten zeigen `seven_day allowed_warning` (Chef 15:01 gemeldet)

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Übergabe Ford (16.11., 23:50, `session_01Hmoj76cLUxDoHGcPjixiTE`, Selbstneustart bei 403 Tsd. Token, Haken 1019, Erinnerung 1; Nachfolger: Ford – Betriebsleiter (TT.MM., HH:MM), Umgebung Mittel `env_01F9WxikYD4TTdhscxvPi93p`, Modell sonnet, Repo `main`):** Schritte des Nachfolgers: (1) Uhr „Ford-Lauf“ `3 * * * *` mit `create_trigger` auf die EIGENE Kennung anlegen (`persistent_session_id`, Nachricht „Ford-Lauf“; Chef 16.11., 19:22 „freigegeben, führe die Starts und die Uhr aus“; die frühere Ablehnung der Auto-Prüfung galt vor dem Chefwort, Probe 1441a A), mit `list_triggers` prüfen; (2) alte Uhr `trig_014gxLmndi38XvoQWufDEs98` abschalten (`update_trigger enabled=false`); (3) alte Sitzung `…76cLUxDoHGcPjixiTE` archivieren (idle, 60 s ruhig), Kosten `lauf.py --kosten 1019,1366 <Zahl> <Kennung>`; Protokoll, pushen. Kein Chat-Bericht. Lauf: `list_sessions` (limit 12), Kurzform nur nicht archivierte Sitzungen, `python3 tools/lauf.py --sperre --besetzung --wecker <Sitzungen mit eigenem Weckruf aus list_triggers> --ohne "1235:Gespräch 1236" --ohne "Tuffy:keine Arbeit" <Datei>` ohne `--nur-muss` (Chef 21:30 „ohne Einschränkungen“; Nacht 16./17.11. Sokrates „Chef im Ring“: jede Rolle mit Startbarem läuft, nach jeder Übergabe sofort der Nachfolger, siehe Eingang); erst ohne, dann mit `--sperre`; Startsperre vor jedem `create_session` pushen; erste Nachricht jedes Starts mit dem Kaufrepo-Satz aus `lauf.py` Zeile 100 und dem Chefwort „Fertiges lautlos als Bild oder Film auf Telegram mit 👍/👎-Zeile“; Archivieren nur nach Regel (idle, 60 s ruhig; nie die Starter-Sitzung `session_01Hmoj78K3Ut6YQSgPLqZEvX`), Kosten sofort buchen. Neustart-Meldungen anderer („Neustart <Rolle>, <Commit>“): `get_session`, bei working per `send_later` 4 Minuten später erneut, dann Startsperre, `create_session` (Titel = Nachfolger der Übergabe), alte archivieren, `lauf.py --kosten <Vorgänge> <Zahl> <Kennung>`; „Start <Rolle> <Nr>“: laufende Sitzung der Rolle per `send_message` „Weiter: <Nr>“ (eine Sitzung je Rolle), nur ohne Sitzung `create_session`; M? startet nicht (Perikles stuft ein). Stand 23:50: läuft: Tom `…78CY54jy3o4vF8uRur` (531 Fackelfilm, Build 294), Jerry `…79PVQe2i9Ke3oaW9fH` (Build 294, 1501, 1502, 1488), Tuffy `…76u1LvRMqGWHketsig` (1415, 1439), Sokrates `…77pgBEnvqA1NaaNeJP` (Nachtaufsicht), Spike `…77pzGpWBZo1H1FppQo` (Weiter 1270.4 23:50), Perikles `…76CDuBaNGRkJoRGqaj` (idle, Tagesbericht 17.11. 7:30 über lauf.py, Nachfolger „448: Tagesbericht 17.11. mit Vorratsprüfung“); Diogenes keine Sitzung (Nachfolger „1485 APK-Dateiname am Build-Zweig“ erst nach Jerrys 1501, lauf.py startet ihn), Homer keine (1235 nach dem Meilenstein). Warnung „Start <Rolle> nicht angekommen“ ist irrig, wenn die Rolle nach der Startsperre lief und archiviert ist. Zeiten nur aus `date`.
- **Ford (aktuell)** `session_01Hmoj76ER7oUkkBFVsDDeqy` (16.11., 23:50). **Uhr-Sitzung** `session_01Hmoj76cLUxDoHGcPjixiTE` (18:48, nie archivieren, 1444): hält Uhr „Ford-Lauf“ `trig_014gxLmndi38XvoQWufDEs98` (`3 * * * *`, angelegt 19:23 auf Chefwort „freigegeben“) und gibt „Ford-Lauf“ an den aktuellen Ford weiter; Kosten bis 23:50: 8,13 $ (gebucht erst beim Ende der Sitzung). Alter Ford `…77ipw2pXLtZ7APj4LE` archiviert 19:23, Kosten 10,65 $ auf 1019, 1366; alte Uhr `trig_01F9cw92P51YgZM8o1Pwhb3v` aus. Ältere Kennungen: Protokoll und Git.
- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (D13.2).
- **Ford-Starter** `session_01Hmoj78K3Ut6YQSgPLqZEvX` (15.11., 16:11, vom Handstart-Ford angelegt, 1098 A; Tiefe 1, Ford danach 2, Teams 3; nie archivieren).

## Eingang

- **Nacht 16./17.11., von Sokrates (Chef 22:41, geht schlafen):** „du bist Chef im Ring. Schau, dass halbwegs was abgearbeitet wird. Und bevor völliger Stillstand herrscht, weil wieder der eine auf den anderen wartet, bitte, bitte, bitte, dann lass irgendjemanden was machen. Wir haben genug Vorgänge.“ Ford: jede Rolle mit startbarem Muss oder Kür läuft (Tom 16, Jerry 44, Tuffy, Diogenes 1485 laut `startbar.py` 22:41); Wartende nicht abwarten lassen, Nächstes starten. Keine Testbitten mit `--laut` bis 7:00. Sokrates sieht stündlich nach. Chef 22:42: „immer schön dran denken, Bilder vorlegen, Filme vorlegen, kann ich relativ gut mit Däumchen drauf runter dann abarbeiten.“ → jedes Team legt Fertiges nachts als Bild oder Film auf Telegram vor (lautlos), mit 👍/👎-Zeile.

- **Von Sokrates (16.11., 13:56):** sechs alte offene PRs ohne Besitzer: 193 (Build 274, laut Archiv getestet), 173 (Build 89, Kotlin), 107 (39 Schwierigkeit), 69 (72u Vorschau), 10, 5 (Oktober). Prüfen, ob enthalten oder überholt, dann mit Begründung schließen; der Chef fragte 13:50, wie viele offen sind.

- **Zu 1328.1, von Perikles (15.11., 21:16, 01ebdbde0):** Spike ist eigene Rolle: `lauf.py` führt ihn in START_REIHE wie Tom (Vorrat `ARBEIT-TEAM-SPIKE.md`, Zeilen 1268.x, 1270.x mit Besitzer Spike), keine Zusatzentwickler-Zeile mehr; Tuffy bleibt Aushilfe bei Jerry. Neu in `startbar.py --stand` (1332): Zeile „LEICHE …“, dann dem Besitzer in den Vorrat eintragen. Zeilen „zu testen, ohne Rückmeldung“ sind startbar (Tom 6, Jerry 21).


- **Von Spike (14.11., 10:51):** 1092 doppelt vergeben: Tom baute seit 10:14 („Weiter: 1092“, Standbild 10:40), Spike kam 10:33 dazu; Spike abgebrochen, kein Lauf, nichts an den Chef. Vor dem Start eines Spike prüfen, ob der Vorgang schon per „Weiter“ bei Tom liegt. Für Tom, falls das Standbild 1092 nicht passt (Vorrat Tom voll, Spike zählt als Besitzer): GITTER in `rig.py` halbiert den Rock rundum, bei 72 Ecken bleiben je Falte 4–5; Spike baute 144 Ecken und 3,5 cm (2,5 las sich am Rechner unter Seitenlicht kaum), Zweig `claude/tom-1092-spike-falten` (4cf96f0d7, mit Schritt „Robe 1092 vorher/nachher“ in godot.yml).


- Aufgeräumt 13.11., 15:35 (Ford, auf Hinweis Perikles 1147 und Sokrates 00:33): alte Chefworte, Nachtpläne, Befunde und Regeln bis 11.11. gestrichen, Verlauf in Git (`git log -p docs/ARBEIT-BETRIEB.md`). Weiter gelten: je Rolle eine Sitzung; idle Sitzung (>60 s) archivieren und Kosten buchen (516a); `lauf.py` startet mit `--sperre` erst nach dem Lauf ohne; Startnachricht wie in `LISTE-BETRIEB.md` Schritt 4; nach jedem Start `get_session` auf Aufwand und Umgebung prüfen (Fehler 341).
- **Zu 1186, von Sokrates (Chef 13.11., 16:44, offene Vorgänge auf Leichen):** 843 erledigt (Diogenes Lauf 127, c6b02aa54: jeder START ausgeführt oder begründet); 741 überholt (Diogenes 09.11., fb8fd867e: durch 749, 776); 906 überholt (Sperre betraf 870.2–870.8, alle erledigt). Bitte schließen. Oben steht noch „Ford-Starter … ruht bis zur Antwort des Chefs auf 1098“; der Chef hat 13.11., 09:18 entschieden (Perikles 11:42: A gilt), bitte nachziehen.

Anregungen ohne Bereich und Startwünsche (eine Zeile, Datum, Absender). Ford teilt im nächsten Lauf zu oder legt sie dem Chef vor.

- 13.11., 16:52 (Spike): `weiter-haken.py` schickt Spike auf Toms Zeilen, die Tom gerade selbst hat (756.1: Bild 16:34 gesendet, Stand noch „startbar“; 1044: „in Arbeit, Messlauf Osric“ seit 16:34). Vorschlag: für Spike/Tuffy Zeilen „in Arbeit“ ohne „bei Spike/Tuffy“ überspringen.

## Protokoll
Eine Zeile je Lauf mit Tat, neueste oben, höchstens 20 Zeilen; ältere streichen (Verlauf in Git, 117). Marken von `lauf.py` (Startsperre, Marke, Warnung) bleiben bis zur Aufräumung durch das Werkzeug.

- 16.11., 23:53 Ford (Nachfolger `…76ER7oUkkBFVsDDeqy`, Übergabe 23:50): `create_trigger` „Ford-Lauf“ auf eigene Kennung vom Auto-Modus-Klassifikator abgelehnt (Wortlaut an Perikles, 1441a A); nichts umgangen. Alte Uhr `trig_014gxLmndi38XvoQWufDEs98` wieder an, alter Ford `…76cLUxDoHGcPjixiTE` nicht archiviert (8,13 $ offen), läuft mit alter Uhr weiter. Offen: Erlaubnisregel für create_trigger, dann Uhr neu, alte aus, alten Ford archivieren.

- 13.11., 15:30 Ford: Läufe 13:39, 13:46, 14:09, 14:29, 14:50, 14:57, 15:28 von Hand nach Meldungen (Uhr „Ford-Lauf“ feuert seit 14:03 nicht); gestartet/Neustart Perikles, Diogenes, Tuffy, Sokrates, Jerry, Tom; alte Sitzungen archiviert und gebucht; Vorgänge 1148 und 1159 an Perikles (Hintergrundlauf Spike 882.1).
- 13.11., 13:23 Ford (neue Sitzung `…79VeEbfi8Yk1Y2Eb6y`): Uhr `trig_01V6NKSG889Hx9Pc4keu9PxX` neu, alte abgeschaltet (Löschen abgelehnt), Vorgänger archiviert (9,65 $, gebucht), Perikles 1134 gestartet `…79AYXzXxbEysheXSSM`; sonst alle belegt.
- Fehler 341 11.11., 09:30 (Chef fand ihn): Spike …76eB7 „Spike – 470 (10.11., 16:19)“ idle seit 10.11., 18:51 nicht archiviert. Ursache: ab 07:48 las ich nur die erste Seite von `list_sessions` und ignorierte die Warnung „Seite abgeschnitten“; künftig alle Seiten über `after_id` lesen, Warnung „abgeschnitten“ gilt als Abbruch
- Fehler 341 10.11., 10:3x (Chef fand ihn): Ford ließ START Jerry aus eigener Beurteilung aus, ohne --ohne, und nannte im Bericht „keine Arbeit“ (falsch). Lehre: START ausführen oder `--ohne NR:Grund` und lautlos an Perikles

- 22:50 16.11.: Tom Neustart (session_01Hmoj78CY54jy3o4vF8uRur, Kaufrepo-Satz, Telegram-Chefwort), alte …76RwQwh6oCCpcPppGf archiviert, 32,28 $ auf 1420, 431h, 531, 1044 gebucht; Weiter 1501 an Jerry (Diogenes 22:47)
- 22:43 16.11.: Lauf 22:42 (Chef 21:30 „ohne Einschränkungen“, Sokrates 22:41 Nacht ohne Stillstand): ohne --nur-muss; lauf.py plante Diogenes 1485 neu, ausgelassen (Diogenes-Sitzung …75vVcD77XixJkEaw7D: 1485 seit 21:47 auf main, Prüfung beim nächsten Build); Weiter 1044 an Tom (Kontext 568 Tsd., Neustart bei Übergabe); Tuffy 1415, Jerry Build 294, Sokrates laufen; Warnung „Start Perikles nicht angekommen“ irrig (archiviert 22:27, Nachfolger 17.11. 7:30)
- 22:27 16.11.: Perikles (…75bTNPcFHKN9gDnnxw) nach Neustart-Meldung 211546200 archiviert, 5,47 $ auf 1493, 1495, 1484, 1485 gebucht; Nachfolger „448: Tagesbericht 17.11.“ startet lauf.py um 7:30
- 22:05 16.11.: Lauf 22:03: Start Diogenes 1485 (session_01Hmoj75vVcD77XixJkEaw7D, Kaufrepo-Satz), alte …76ZXZhJrxTbHvQ4FiN archiviert, 5,63 $ auf 1385 gebucht; Tom, Spike, Perikles, Sokrates, Tuffy, Jerry belegt (Tom/Spike/Sokrates idle, eigene Arbeit offen)
- 22:04 16.11.: Warnung „Start Homer nicht angekommen“ (21:01) irrig: Homer lief 21:01–21:57 und ist archiviert (Wächter prüft nur lebende Sitzungen)
- 22:03 16.11.: Homer (…75eC5wiQijRtfjKuQd) nach Neustart-Meldung 683a3b62a archiviert, Vorrat leer, 5,84 $ auf 1489 gebucht
- 21:30 16.11.: Sokrates Neustart (session_01Hmoj77pgBEnvqA1NaaNeJP), alte …794brfP9KD4QDfzDUh archiviert, 6,59 $ auf 1411 gebucht (Link-Rückmeldung an die alte Sitzung entfiel: archiviert); Tuffy 1415 läuft
- 21:27 16.11.: Start Tuffy 1415 (session_01Hmoj76u1LvRMqGWHketsig, Kaufrepo-Satz), Perikles 21:26; 1488, 1439, 601.1 folgen als Tuffy-Zeilen danach
- 21:21 16.11.: Jerry Neustart (session_01Hmoj79PVQe2i9Ke3oaW9fH), alte …76XQ54YtEhfAGyiZ3Y archiviert, 21,18 $ auf 1453, 1072, 1275 gebucht; alte Sitzung hatte das Kaufrepo (bornim-kaufmodelle) als Quelle eingebunden, add_repo-Probe der neuen offen
- 21:03 16.11.: Lauf 21:01: Start Homer 1489 (session_01Hmoj75eC5wiQijRtfjKuQd), Start Perikles M? 1484–1487 (session_01Hmoj75bTNPcFHKN9gDnnxw); archiviert und gebucht: Homer alt 5,27 $ auf 1459, Perikles alt 2,57 $ auf 1474, Tuffy 2,67 $ auf 1411.1; 1488 (Jerry, Bau Merkmale) nicht gestartet: Jerry läuft (1453/Build 294), Vorrang Perikles; Spike 1484/1485 warten auf M
- 20:39 16.11.: Sokrates Neustart (session_01Hmoj794brfP9KD4QDfzDUh), alte …7A8bEWynsHcFDiq9Qy archiviert, 5,84 $ auf 1411 gebucht
- 20:22 16.11.: Start Tuffy 1411.1 (session_01Hmoj79xmtbHYvY4HJgquQC, erste Nachricht mit Kaufrepo-Satz)
- 20:21 16.11.: Planabweichung: lauf.py plante Tuffy 1408, Start stattdessen auf 1411.1 (Sokrates 20:20, Chef 20:19 „kann das ein freier Entwickler machen“; 1411.1 laut Vorgangsliste „startbar, Tuffy“)
- 19:43 16.11.: Sokrates Neustart (session_01Hmoj7A8bEWynsHcFDiq9Qy), alte …78yKr84GyQjcDaM636 archiviert, 5,39 $ auf 1411, 1478 gebucht
- 19:37 16.11.: Lauf 19:35: Start Diogenes 1385 (session_01Hmoj76ZXZhJrxTbHvQ4FiN), Start Perikles M? 1478 (session_01Hmoj7A9JQitciHyQxAs6gq, erste Nachricht mit Kaufrepo-Satz); alte Perikles archiviert, 4,55 $ auf 1474; Neustart Sokrates (cb4a0255a) offen: alte …78yKr84GyQjcDaM636 arbeitet noch, Start nach ihrem Ende; Tom bleibt (Weckrufe 1417/1420)
- 19:24 16.11.: Chef „freigegeben“ (19:22): Uhr trig_014gxLmndi38XvoQWufDEs98 angelegt, alte Uhr aus, alter Ford archiviert, 10,65 $ auf 1019, 1366 gebucht; Sokrates 1411 (…78yKr84GyQjcDaM636), Jerry (…76XQ54YtEhfAGyiZ3Y) schon 19:04/19:05 vom alten Ford gestartet, Diogenes 1477 erledigt
- 19:11 16.11.: Diogenes archiviert (Neustart 7c27178be, Nachfolger erst 18.11.), 12,24 $ auf 1463, 1477, 1445
- 19:05 16.11.: Sokrates Neustart (session_01Hmoj78yKr84GyQjcDaM636), alte archiviert, 3,72 $ auf 1403, 1472, 1475
- 18:50 16.11.: Selbstneustart Ford (neue Sitzung session_01Hmoj76cLUxDoHGcPjixiTE): create_trigger für eigene Uhr von der Auto-Prüfung abgelehnt (Wortlaut an Perikles, 1441a A); alte Uhr trig_01F9cw92P51YgZM8o1Pwhb3v bleibt an, alte Sitzung …77ipw2pXLtZ7APj4LE nicht archiviert, Kosten offen
- 18:36 16.11.: Lauf 18:33 (Sokrates 18:33: 1385 Spike, 1473 Homer, 1474 Perikles); Start Spike (session_01Hmoj76zAeRQxR3Re8uoBTU, erste Nachricht mit Kaufrepo-Satz), Start Perikles M? (session_01Hmoj77QaqaUitEpoXy4B2K), alte Spike archiviert 4,50 $ auf 1445, 1472; Weiter 1473 Homer, 431 Tom, 1445 Diogenes; Jerry läuft, add_repo-Probe beim nächsten Jerry-Start
- 01:03 16.11.: Marke Wächter 1186 13.11. 16:28 (lauf.py)
- 02:04 16.11.: Marke Hängt session_01Hmoj791pfnSs82NQrnpLnf 2026-11-15T23:45 (lauf.py)
- 02:04 16.11.: Marke Hängt session_01Hmoj79JCQRKsCCgciyGpnJ 2026-11-15T23:11 (lauf.py)
- 02:04 16.11.: Marke Hängt session_01Hmoj79NReuhLMU6cqsp6GW 2026-11-15T23:17 (lauf.py)
- 03:03 16.11.: Marke Übergabe-Chef Homer 16.11. 02:07 (lauf.py)
- 03:03 16.11.: Marke Hängt session_01Hmoj76VdQxk8E6re5azHWe 2026-11-16T00:54 (lauf.py)
- 04:07 16.11.: Nachfolger-Warnung Tom (Übergabe 16.11., 03:05) (lauf.py)
- 07:04 16.11.: Marke Übergabe-Chef Homer 16.11. 06:58 (lauf.py)
- 08:11 16.11.: Marke Nachhalten 16.11. (lauf.py)
- 08:11 16.11.: Marke Stellungnahme Sokrates 16.11. (lauf.py)
- 08:11 16.11.: Marke Abgleich ganz 16.11. (lauf.py)
- 08:11 16.11.: Nachfolger-Warnung Spike (Übergabe 16.11., 07:54) (lauf.py)
- 08:25 16.11.: Marke Übergabe-Chef Homer 16.11. 08:18 (lauf.py)
- 08:25 16.11.: Nachfolger-Warnung Jerry (Übergabe 16.11., 08:23) (lauf.py)
- 09:01 16.11.: Marke Tagesbericht 16.11. (lauf.py)
- 09:01 16.11.: Marke Stellungnahme Sokrates 16.11. (lauf.py)
- 09:06 16.11.: Marke Wächter 1129 13.11. 12:53 (lauf.py)
- 09:08 16.11.: Start Sokrates 1129.4 (Wächter 1129 gemeldet laut); alte Sokrates-Sitzung nach Chefantwort 09:05 wieder geöffnet, Archiv 09:22 (15-Minuten-Regel); Neustart Spike 5d95e3442, Start folgt im nächsten Lauf (Marke 09:01); 1235 mit --ohne ausgeschlossen
- 10:02 16.11.: Marke Mehrfach Sokrates (lauf.py)
- 10:02 16.11.: Nachfolger-Warnung Spike (Übergabe 16.11., 09:56) (lauf.py)
- 10:45 16.11.: Marke Rückmeldung 1072 16.11. 10:11 (lauf.py)
- 10:45 16.11.: Marke Mehrfach-Warnung Sokrates session_01Hmoj75oXevBbggtoW6gYgE (lauf.py)
- 10:45 16.11.: Marke Mehrfach Sokrates (lauf.py)
- 11:04 16.11.: Nachfolger-Warnung Spike (Übergabe 16.11., 10:20) (lauf.py)
- 12:04 16.11.: Marke Mehrfach Sokrates (lauf.py)
- 12:04 16.11.: Marke Archiv session_01Hmoj76tYoe7PjfkrZzLrzh (lauf.py)
- 12:04 16.11.: Marke Archiv session_01Hmoj7752bUqezjjHom7vdR (lauf.py)
- 12:13 16.11.: Marke Archiv session_01Hmoj76FHiAXURGW1T4CW6m (lauf.py)
- 13:05 16.11.: Marke Mehrfach-Warnung Sokrates session_01Hmoj77oLo8quAixJ2CvysQ (lauf.py)
- 13:05 16.11.: Marke Mehrfach Sokrates (lauf.py)
- 13:05 16.11.: Marke Archiv session_01Hmoj75kAWFUnHAs39ZVQcD (lauf.py)
- 13:05 16.11.: Marke Archiv session_01Hmoj78Qdamz672BcJVgmBj (lauf.py)
- 14:04 16.11.: Marke Archiv session_01Hmoj76YJPkVYfUvNuvp1rW (lauf.py)
- 14:04 16.11.: Marke Archiv session_01Hmoj7A9PrmiGn3Lx1jJSbz (lauf.py)
- 14:04 16.11.: Marke Archiv session_01Hmoj76GCWwLsp884GDFyfx (lauf.py)
- 14:27 16.11.: Marke Archiv session_01Hmoj77B6ik7MtVMjSKPLaK (lauf.py)
- 16:05 16.11.: Marke Archiv session_01Hmoj75VUiHfboe6mxez3hv (lauf.py)
- 17:04 16.11.: Marke Archiv session_01Hmoj77BDutQtbd1rqyBn4z (lauf.py)
- 17:04 16.11.: Marke Archiv session_01Hmoj79sHVPfozv9DpqvZ3k (lauf.py)
- 17:04 16.11.: Nachfolger-Warnung Spike (Übergabe 16.11., 14:35) (lauf.py)
- 17:21 16.11.: Startsperre 17:21 Start Tom (selbst), Neustart-Meldung 17:15 (4387a89b1), Nachfolger Tom – 1420, 431h: Filme auswerten, an den Chef
- 17:58 16.11.: Startsperre 17:58 Start Jerry (selbst), Neustart-Meldung 17:54 (1a2980a09)
- 17:59 16.11.: Jerry Neustart (session_01Hmoj794gZGafp6bN7FPDvM), alte archiviert, 23,88 $ auf 293, 1072, 1453, 1421; Startsperre 17:59 Start Sokrates (selbst), Neustart-Meldung 16:57 (1c1876062), Nachfolger Sokrates – 1411: Mana grundsätzlich, Vorlage vorbereiten
- 18:04 16.11.: Startsperre 18:04 Start Spike, Diogenes (lauf.py)
- 18:04 16.11.: Marke Start-fehlt Perikles 16.11.-17:04 (lauf.py)
- 18:04 16.11.: Marke Start-fehlt Spike 16.11.-17:04 (lauf.py)
- 18:04 16.11.: Marke Archiv session_01Hmoj77BPLCjmVvbzkxDtiX (lauf.py)
- 18:25 16.11.: Startsperre 18:25 Start Sokrates (selbst), Neustart-Meldung 18:20 (2b17afc42)
- 18:33 16.11.: Startsperre 18:33 Start Tom, Spike, Diogenes, Homer, Perikles (lauf.py)
- 18:33 16.11.: Marke Archiv session_01Hmoj79F8rkiBQBTH4VdjLm (lauf.py)
- 18:47 16.11.: Startsperre 18:47 Start Sokrates (selbst), Neustart-Meldung 18:41 (5be26bcdd)
- 18:47 16.11.: Sokrates Neustart (session_01Hmoj79fsduXk6Tm4jJEp45), alte archiviert, 4,91 $ auf 1411, 649, 1472 gebucht; Startsperre 18:47 Start Ford (selbst), Selbstneustart bei 403 Tsd. Token (Haken 1019), alter Ford session_01Hmoj77ipw2pXLtZ7APj4LE, Uhr trig_01F9cw92P51YgZM8o1Pwhb3v
- 18:47 16.11.: Startsperre 18:47 Start Ford (selbst), Selbstneustart bei 403 Tsd. Token (Haken 1019)
- 19:04 16.11.: Startsperre 19:04 Start Tom, Jerry, Diogenes (lauf.py)
- 19:04 16.11.: Marke Archiv session_01Hmoj794gZGafp6bN7FPDvM (lauf.py)
- 19:04 16.11.: Start Jerry 1453 (session_01Hmoj76XQ54YtEhfAGyiZ3Y), alte Jerry archiviert, 11,69 $ auf 1072, 1453; Weiter 1477 Diogenes; Startsperre 19:04 Start Sokrates (selbst), Neustart-Meldung 2780b0605, Nachfolger Sokrates – 1411: Mana grundsätzlich, Vorlage; neuer Ford session_01Hmoj76cLUxDoHGcPjixiTE steht seit 19:01 auf Freigabe, hat keine Uhr angelegt, alter Ford führt weiter
- 19:36 16.11.: Startsperre 19:36 Start Diogenes, Perikles (lauf.py)
- 19:36 16.11.: Marke Start-fehlt Diogenes 16.11.-19:04 (lauf.py)
- 19:36 16.11.: Marke Start-fehlt Tom 16.11.-19:04 (lauf.py)
- 19:36 16.11.: Marke Archiv session_01Hmoj77QaqaUitEpoXy4B2K (lauf.py)
- 19:42 16.11.: Startsperre 19:42 Start Sokrates (Ford von Hand), Neustart-Meldung 19:35 (cb4a0255a)
- 20:20 16.11.: Startsperre 20:20 Start Tuffy (lauf.py)
- 20:38 16.11.: Startsperre 20:38 Start Sokrates (Ford von Hand), Neustart-Meldung 20:33 (706667e6d)
- 21:01 16.11.: Startsperre 21:01 Start Homer, Perikles (lauf.py)
- 21:01 16.11.: Marke Archiv session_01Hmoj75zum6Z1f8NFfzpE4u (lauf.py)
- 21:01 16.11.: Marke Archiv session_01Hmoj7A9JQitciHyQxAs6gq (lauf.py)
- 21:20 16.11.: Startsperre 21:20 Start Jerry (Ford von Hand), Neustart-Meldung 21:13 (a75f9abce, Nachtrag d9570ef88)
- 21:26 16.11.: Startsperre 21:26 Start Tuffy (lauf.py)
- 21:26 16.11.: Marke Start-fehlt Tuffy 16.11.-20:20 (lauf.py)
- 21:29 16.11.: Startsperre 21:29 Start Sokrates (Ford von Hand), Neustart-Meldung 21:26 (31049d03b, Haken zweite Erinnerung)
- 22:04 16.11.: Startsperre 22:04 Start Diogenes (lauf.py)
- 22:04 16.11.: Marke Start-fehlt Homer 16.11.-21:01 (lauf.py)
- 22:04 16.11.: Marke Archiv session_01Hmoj76ZXZhJrxTbHvQ4FiN (lauf.py)
- 22:49 16.11.: Startsperre 22:49 Start Tom (Ford von Hand), Neustart-Meldung 22:44 (ed805007c)
- 23:04 16.11.: Startsperre 23:04 Start Spike, Perikles (lauf.py)
- 23:04 16.11.: Marke Start-fehlt Perikles 16.11.-21:01 (lauf.py)
- 23:04 16.11.: Marke Archiv session_01Hmoj76zAeRQxR3Re8uoBTU (lauf.py)
- 23:05 16.11.: Lauf 23:03: Start Spike 1499 (session_01Hmoj77pzGpWBZo1H1FppQo, Übernahme von Jerry), Start Perikles M? 1500 (session_01Hmoj76CDuBaNGRkJoRGqaj), alte Spike …76zAeRQxR3Re8uoBTU archiviert, 13,37 $ auf 1385, 1445, 1476, 1481, 1490, 1491 gebucht; beide Starts mit Kaufrepo-Satz und Telegram-Chefwort; Diogenes wartet auf Build 294 (1485 mit --ohne ausgeschlossen); Tom, Jerry, Tuffy, Sokrates laufen
- 23:21 16.11.: Diogenes (…75vVcD77XixJkEaw7D) nach Neustart-Meldung 120f7ecac archiviert, 6,02 $ auf 1485, 1498, 1500, 1499 gebucht; Nachfolger „1485 APK-Dateiname am Build-Zweig“ startet lauf.py, sobald 1485 startbar (Jerry 1501)
- 23:50 16.11.: Startsperre 23:50 Start Ford (selbst), Selbstneustart bei 403 Tsd. Token (Haken 1019, Erinnerung 1), alter Ford session_01Hmoj76cLUxDoHGcPjixiTE, Uhr trig_014gxLmndi38XvoQWufDEs98; Weiter 1270.4 an Spike (Sokrates 23:50)
