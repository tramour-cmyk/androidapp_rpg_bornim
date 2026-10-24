# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Übergabe (23.10., 19:10, Ford `session_01UHKjhahKyiA8xRfcNd6GmC`):** Läufe bis 19:05 erledigt; Sparbetrieb (Chef 10:22, bis Sa 24.10., 20:59: nur Rückläufer des Chefs und Build für den Spieltest); heute Tom 345 und Jerry 336 nach 336a gestartet (Chef 18:20/18:27); Dashboard jeden Lauf (`LISTE-BETRIEB.md` Schritt 11); Neustart-Wünsche der Teams nur ab 150 Tsd. Token und echter Arbeit annehmen, Wünsche „wartet auf Chef“ ablehnen oder Nachfolger zurückstellen (alte Sitzung archivieren); `lauf.py` startet Perikles für eine Zeile „M?“ ohne Nummer: auslassen; Sokrates läuft (heute zweimal gestartet). Warnung 261.5 (Vorentscheid ohne Datei) wartet auf Perikles. Nachfolger: Ford – Betriebsleiter (Selbstneustart: zuerst eigene Uhr, dann alte löschen, Vorgänger archivieren).

**Nächste freie Vorgangsnummer: 358** (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef: „Habe Pro gekündigt, steht nur noch auf Free“): Ford-2-Regeln ausgesetzt (`LISTE-FORD2.md`); Guthaben nur Max. **Jerry läuft in der Zentrale** (`LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, Einrichtung aus Git (`LISTE-NIEDERLASSUNG.md` bis `f3ec7200`)

**Ford: Pilot** (seit Sa 17.10., 21:05; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (Übersicht `docs/chefsache/README.md`; https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht: `docs/PRUEFBERICHT.md`

**Sparbetrieb (Chef 23.10., 10:22, Bild: Woche „Alle Modelle“ 100 %, Zurücksetzung Sa 20:59; nur Credits, Guthaben 79,38, Monatslimit unbegrenzt):** „Was angestoßen ist, machen wir fertig, ich prüfe Entwürfe, wir aktualisieren und bauen ein. Dann wird wohl der Spieletest heut bei mir stattfinden.“ Ford startet nur Rückläufer des Chefs und den Build für seinen Spieletest; laufende Sitzungen machen ihren Schritt fertig und übergeben, keine Neustarts ohne Arbeit; Sokrates 318 (20 Uhr) auf So nach 21 Uhr, Auswertung 340 erst nach der Zurücksetzung.

**Guthaben:** Bild Chef 24.10., 17:21 (über Sokrates): Wochenlimit aufgebraucht, Zurücksetzung 21:00; läuft über gekauftes Nutzungsguthaben, 54,03 $ übrig, Monat 248,62 $, kein Ausgabenlimit, Neuladen aus · davor: Max Woche voll seit 23.10., 10:1x (`seven_day` rejected, Sitzungen laufen über Credits, Chef laut gefragt); Zurücksetzung Sa 21:00; Nutzungsguthaben an, Monatslimit unbegrenzt, diesen Monat 4,31 Credits ausgegeben (Bild Chef 23.10., 07:16); Max 100 % = Stillstand „Guthaben“ (128) · **Wochenziel bis Sa 24.10., 10:00** (Perikles, Chef 284): Max Woche ab 80 % → `lauf.py --nur-muss`; ab 95 % nichts Neues starten, nur Rückläufer des Chefs; Credits nur auf Wort des Chefs

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Ford lebt in einer Sitzung** „Ford – Betriebsleiter (23.10., 19:10)“ `session_01LaCAodpq9x5Bex49yFuw6d` (seit 23.10., 19:05, Tiefe 4). Stundenuhr „Ford-Lauf“ `trig_01Tz1Jroo1fNYpLnuTQq9NWB` (:03).
- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (D13.2).
- **(ruht, 159)** Ford 2: Stundenuhr aus; Sitzung `session_017VRJsTBwEbU16mwomLknhm`, Uhr `trig_01WCdVmLssvGbjCSK9KJPCPH`; bei Wiedereinschalten neu prüfen.

## Eingang

Anregungen ohne Bereich und Startwünsche (eine Zeile, Datum, Absender). Ford teilt im nächsten Lauf zu oder legt sie dem Chef vor.

- **Von Chef über Sokrates (22.10., 22:21):** Build 79 (Tom und Jerry, 317) jetzt bauen, Chef testet heute noch. Danach arbeiten die Teams die Nacht durch weiter, was startbar ist; nicht wegen Guthaben anhalten (Wortlaut: „ob das Guthaben dann morgen Vormittag ausläuft … oder heute Nacht ausläuft … dann kann ich wenigstens den Build noch testen, morgen früh. Den nächsten vielleicht.“).
- **Von Sokrates (22.10., 22:3x, Chef 22:31 „schau dir Jerry 299 an“):** Jerry `session_01HrPPjrdAxzNbvs4JCyqJET` hat um 22:17 die Neustart-Bitte an die alte Ford-Sitzung `01XVKCPG` geschickt (Kennung aus dem Start, Ford seit 22:06 neu), „Ford inaktiv“ gefolgert und den Nachfolger `session_01F6KpuKLxZEqVZe86rVzKWJ` selbst gestartet; arbeitete danach weiter (320). Bitte alte Jerry-Sitzung archivieren; bei Fords Neustart die neue Kennung an laufende Sitzungen melden oder `@parent` meiden (Vorschlag, Perikles entscheidet). **Perikles 23.10., 07:4x:** kein Rundruf; Kennung vor dem Senden frisch lesen (`LISTE-RELEASE-NEUSTART.md` 1a). Offen für Ford: alte Jerry-Sitzung archivieren, dann Zeile streichen.
- **318, von Sokrates (22.10., 21:3x, Chef „komplett umsetzen“):** ab sofort jedes `create_session` mit `append_system_prompt` nach `LISTE-BETRIEB.md` (Zeile „Kennungen“); Antwortstil „Knapp“ steht in `.claude/settings.json`. Zeile nach dem ersten Start mit Anhang streichen.

## Protokoll
Eine Zeile je Lauf mit Tat, neueste oben, höchstens 20 Zeilen; ältere streichen (Verlauf in Git, 117).

- 18:36 24.10.: Chef 18:30 „Vorarbeiten laufen weiter“ (über Sokrates) 348.3: Start Tom `session_01RhoQQvfNqRL14rp7T9TX7V`; Jerry (`session_01PdxSp7pQi8GmvML1Eo9kPo`, wartet seit Do auf Chef zu 336) per „Weiter: 348.3“ angestoßen
- 18:20 24.10.: Chef „Dann ja zu 348“ (über Sokrates): Start Perikles 348 `session_01D2RVwqV4TWY1W8h6kbfT3e`; Perikles-Sitzung 26 fertig, archiviert (1,21 $ auf 26)
- 18:06 24.10.: Lauf: Start Perikles 26 (Durchspielbogen des Chefs in Vorgänge) `session_013GfBv7Df2tcxQKw9pWzyqM`; Jerry-Kür 349 im Sparbetrieb nicht gestartet
- 17:55 24.10.: Neustart-Wunsch Tom (183 Tsd. Token, 348.2 fertig) angenommen; alte Sitzung archiviert (6,05 $ auf 348); Nachfolger „Rückmeldung 348 und Build 85“ wartet auf Wort des Chefs
- 17:34 24.10.: Chef „Ich brauche Sokrates jetzt“: Start Sokrates „348 Engine, 26 Gegenprobe“ `session_01SG9iCnvKHqRbNpGQPM9j8J` (Pause aufgehoben)
- 17:36 24.10.: Chef wartet auf 348.2 (über Sokrates): Start Tom `session_01CQhLH4E5PkfSw4YTGPz2fp`; Sokrates-Neustart angenommen (216 Tsd. Token), alte Sitzung archiviert (7,39 $ auf 347), Nachfolger „348 Engine, 26 Gegenprobe“ startet nach der Pause ab 21:00
- 17:25 24.10.: Guthaben-Bild eingetragen (54,03 $ übrig)
- 17:17 24.10.: Neustart-Wunsch Tom (231 Tsd. Token, 348.1 fertig) angenommen; alte Sitzung archiviert (5,36 $ auf 348); Nachfolger „Build-Rückmeldung 85“ zurückgestellt bis Test des Chefs
- 17:08 24.10.: Lauf: Perikles 347.2 fertig, archiviert (6,26 $ auf 347); alte Perikles-Sitzung 10:15 archiviert (2,20 $); Seitenliste abgeschnitten, Dashboard ausgelassen
- 16:58 24.10.: Chef „jetzt“ 348.1 (über Sokrates): Start Tom `session_01SjbZEDA8KHxgYjkXzjLwRb`
- 16:50 24.10.: Chef: Perikles starten (Diogenes 347.1 fertig): Start Perikles 347.2 `session_018qKCWNst9vgqGKpbhTcPRH`; Diogenes-Sitzung archiviert (1,77 $ auf 347)
- 16:46 24.10.: Neustart-Wunsch Tom angenommen (231 Tsd. Token, Build 85 fertig); alte Sitzung archiviert (7,62 $ auf 346); Nachfolger „Build-Rückmeldung 85“ zurückgestellt bis Test des Chefs
- 16:38 24.10.: Chef 347 (Sokrates-Bitte): Start Diogenes 347.1 `session_01SMtfbQ4qoTGcHPxQpJ3C39`; Perikles 347.2 folgt nach Diogenes; Neustart Sokrates `session_01VTMH21n3GHA88hAogZ2csJ`, alte Sokrates-Sitzung archiviert (102,64 $ auf Betrieb); 21 Ford-Uhr-Weckrufe seit 23.10., 19:03 blieben unbearbeitet (Sitzung ruhte)
- 20:08 23.10.: Lauf: 16 fertige Sitzungen archiviert und gebucht (Plan 261.5); Tom (346) und Jerry (336 Vorlage) laufen, sonst nichts startbar; Seitenliste abgeschnitten (has_more), Dashboard ausgelassen
- 19:55 23.10.: Sokrates: Rückläufer 346 (Absturz, Muss): Start Tom `session_01NLqyWm7Wdep4EgmtnvJA2w`; Tom-Sitzung 19:05 archiviert (2,31 $ auf 345)
- 19:36 23.10.: Neustart-Wunsch Jerry (224 Tsd. Token, Arbeit) angenommen: Start „Jerry – 336 Vorlage“ `session_01PdxSp7pQi8GmvML1Eo9kPo`; alte Jerry-Sitzung archiviert (8,68 $ auf 336); alter Ford weiter offen
- 19:08 23.10.: Selbstneustart: neue Uhr angelegt und geprüft, alte gelöscht; alter Ford `01UHKjha` (13,17 $ auf Betrieb gebucht) nicht archiviert (`archive_session` vom Auto-Modus abgelehnt, Chef entscheidet)
- 19:08 23.10.: Lauf: Start Tom (345) und Jerry (336 nach 336a) → `session_019jqa9XZ1Gfiw7Q9RtQXn7b`, `session_01EpmjuAh8VpTGxZku47diYv`; Tom-Sitzung 17:23 archiviert (4,40 $); Perikles „M?“ ausgelassen; Dashboard Version 12
- 18:06 23.10.: Lauf: START Perikles „Vorgang M?“ ausgelassen (Zeile ohne Nummer, `startbar.py`: nichts startbar, Sparbetrieb); alte Perikles-Sitzung 10:15 archiviert; Dashboard aktualisiert
- 17:23 23.10.: Chef 17:22 „Build 83 ist freigegeben“ (schon 14:14): Start Tom „Rückmeldung Build 83/84“ → `session_013gtSvDFAitDXf4NFaF55n1` (Auftrag in der ersten Nachricht: PR #167 mergen, 320a beantwortet); Jerry wartet nur noch auf 336a
- 17:08 23.10.: Lauf: Vorrat leer gemeldet; Tom-Start (Rückmeldung Build 83/84) zurückgestellt, Chef hat nicht geantwortet; Dashboard aktualisiert
- 16:24 23.10.: Neustart Jerry (6d9d6f3f) angenommen: Sitzung 16:00 archiviert; Nachfolger „Jerry – 336 nach 336a (23.10.)“ erst starten, wenn der Chef 336a oder 320a beantwortet (Sparbetrieb)
- 16:08 23.10.: Neustart Tom (1b5a5b7c) angenommen: Sitzung 14:19 archiviert; Nachfolger „Tom – Rückmeldung Build 83/84“ erst starten, wenn der Chef zu Build 83 oder 84 etwas sagt (Sparbetrieb)
- 16:00 23.10.: Neustart Jerry (f6724090, 208 Tsd.; 336 Befunde, PR #167 Merge) → `session_01STVoLsJjmbMYUoiwWY6J5U`, Vorgänger archiviert (bucht der nächste Lauf)
- 15:52 23.10.: Lauf (Läufe 15:03 bis 15:50 durch Worker-Neustart ausgefallen): keine Starts; Dashboard aktualisiert
- 14:19 23.10.: Neustart Tom (f87c7aeb; Token-Angabe 0, 24 Minuten; 343 Muss, Build 84) → `session_01TN9bEkpkRKJcjysV6GZXAv`, Vorgänger archiviert (bucht der nächste Lauf)
- 14:09 23.10.: Neustart Jerry (84aa18ae, 290 Tsd.; 336 startbar) → `session_0167VgdEtWBxGCgERhqTiDPq`, Vorgänger archiviert (bucht der nächste Lauf)
- 13:57 23.10.: Start Tom (Chef 13:54: Build 82 freigegeben, Rückläufer) → `session_01UjGqjAUQcn5AainMhYmMBZ`; 336-Hinweis an Jerry; Dashboard Version 6
- 13:36 23.10.: Neustart Jerry (eab3220e) abgelehnt: 337 wartet auf Chef, nichts Startbares
- 00:04 23.10.: Startsperre 00:04 Start Tom, Homer, Perikles (lauf.py)
- 00:04 23.10.: Marke Archiv session_01Udxz2SwG5H12WbWCYL4TRi (lauf.py)
- 00:04 23.10.: Marke Archiv session_01FduiKKFHuYEj5rjFDCzzac (lauf.py)
- 01:04 23.10.: Startsperre 01:04 Start Homer, Perikles (lauf.py)
- 01:04 23.10.: Marke Archiv session_0116fn7EK5ATTBCZGN61tMn9 (lauf.py)
- 02:04 23.10.: Startsperre 02:04 Start Homer, Perikles (lauf.py)
- 03:04 23.10.: Startsperre 03:04 Start Tom, Jerry, Homer, Perikles (lauf.py)
- 03:04 23.10.: Marke Archiv session_011Rsj54oXZY5Ug8RBdJQqg9 (lauf.py)
- 03:04 23.10.: Marke Archiv session_011AUZcFZbmj64iZ6DUzLnsC (lauf.py)
- 03:04 23.10.: Marke Archiv session_01GpsPXA9DKhqY4PEWfQf28a (lauf.py)
- 04:04 23.10.: Startsperre 04:04 Start Tom, Jerry, Homer, Perikles (lauf.py)
- 07:35 23.10.: Startsperre 07:35 Start Jerry, Homer, Perikles (lauf.py)
- 07:35 23.10.: Marke Tagesbericht 23.10. (lauf.py)
- 07:35 23.10.: Marke Ohne-Rolle session_01MVwf98upKzrHSGwpfjZP54 (lauf.py)
- 08:04 23.10.: Startsperre 08:04 Start Jerry, Homer, Perikles (lauf.py)
- 08:04 23.10.: Marke Stellungnahme Sokrates 23.10. (lauf.py)
- 09:05 23.10.: Startsperre 09:05 Start Homer, Perikles (lauf.py)
- 09:05 23.10.: Marke Archiv session_01Luj9yM23c9mp9e3RvgSeHe (lauf.py)
- 09:05 23.10.: Startsperre 09:05 Start Perikles (lauf.py)
- 09:08 23.10.: Marke Mehrfach Tom (lauf.py)
- 09:42 23.10.: Marke Archiv session_01NpaCu5ehKMbseaA7Vun8m4 (lauf.py)
- 09:42 23.10.: Nachfolger-Warnung Homer (Übergabe 23.10., 09:13) (lauf.py)
- 09:48 23.10.: Startsperre 09:48 Start Diogenes, Homer (lauf.py)
- 10:14 23.10.: Startsperre 10:14 Start Homer (lauf.py)
- 10:14 23.10.: Marke Stellungnahme Sokrates 23.10. (lauf.py)
- 10:14 23.10.: Marke Archiv session_017bhmyMUx9kLbRrscsBbpNc (lauf.py)
- 11:04 23.10.: Nachfolger-Warnung Homer (Übergabe 23.10., 10:19) (lauf.py)
- 12:04 23.10.: Startsperre 12:04 Start Tom (lauf.py)
- 12:04 23.10.: Marke Archiv session_01Q2rLBU1xCkx9sB2edSSLQQ (lauf.py)
- 13:06 23.10.: Startsperre 13:06 Start Tom, Jerry (lauf.py)
- 13:06 23.10.: Marke Archiv session_012gsYaU3Vt23Nx6AV2f8dc2 (lauf.py)
- 13:55 23.10.: Startsperre 13:55 Start Tom (lauf.py)
- 17:06 23.10.: Startsperre 17:06 Start Tom (lauf.py)
- 17:06 23.10.: Nachfolger-Warnung Jerry (Übergabe 23.10., 16:26) (lauf.py)
- 18:04 23.10.: Startsperre 18:04 Start Perikles (lauf.py)
- 18:04 23.10.: Marke Archiv session_014DfnjGJvruciE9QhL4Uvfc (lauf.py)
- 19:04 23.10.: Startsperre 19:04 Start Tom, Jerry, Perikles (lauf.py)
- 19:04 23.10.: Marke Archiv session_013gtSvDFAitDXf4NFaF55n1 (lauf.py)
- 20:06 23.10.: Marke Archiv-Warnung session_017bhmyMUx9kLbRrscsBbpNc (lauf.py)
- 20:06 23.10.: Marke Archiv session_01EpmjuAh8VpTGxZku47diYv (lauf.py)
- 20:06 23.10.: Marke Archiv session_01STVoLsJjmbMYUoiwWY6J5U (lauf.py)
- 20:06 23.10.: Marke Archiv session_0167VgdEtWBxGCgERhqTiDPq (lauf.py)
- 20:06 23.10.: Marke Archiv session_01LGJKdfP19ZJd6xpyhBr6EQ (lauf.py)
- 20:06 23.10.: Marke Archiv-Warnung session_012gsYaU3Vt23Nx6AV2f8dc2 (lauf.py)
- 20:06 23.10.: Marke Archiv session_01Bi5GgBLhAVhNWKFFydfU3y (lauf.py)
- 20:06 23.10.: Marke Archiv session_01V7tidoyVMHw7r26qj6cs6R (lauf.py)
- 20:06 23.10.: Marke Archiv session_0132AN4zJxMUFqLCDFwco2Cp (lauf.py)
- 20:06 23.10.: Marke Archiv session_018sq2oAPqvb8KLrsu9FvrJn (lauf.py)
- 20:06 23.10.: Marke Archiv session_015xK1ojPuUwKNxz3sjksBcu (lauf.py)
- 20:06 23.10.: Marke Archiv session_019jqa9XZ1Gfiw7Q9RtQXn7b (lauf.py)
- 20:06 23.10.: Marke Archiv-Warnung session_013gtSvDFAitDXf4NFaF55n1 (lauf.py)
- 20:06 23.10.: Marke Archiv session_01TN9bEkpkRKJcjysV6GZXAv (lauf.py)
- 20:06 23.10.: Marke Archiv session_01UjGqjAUQcn5AainMhYmMBZ (lauf.py)
- 20:06 23.10.: Marke Archiv-Warnung session_01Q2rLBU1xCkx9sB2edSSLQQ (lauf.py)
- 20:06 23.10.: Marke Archiv session_013ic1nMDCc5fHbWvNbgTLBF (lauf.py)
- 20:06 23.10.: Marke Archiv session_011npSvheEFY5npMA43oPSsx (lauf.py)
- 17:04 24.10.: Marke Archiv-Warnung session_01EpmjuAh8VpTGxZku47diYv (lauf.py)
- 17:04 24.10.: Marke Archiv-Warnung session_01STVoLsJjmbMYUoiwWY6J5U (lauf.py)
- 17:04 24.10.: Marke Archiv-Warnung session_0167VgdEtWBxGCgERhqTiDPq (lauf.py)
- 17:04 24.10.: Marke Archiv-Warnung session_01LGJKdfP19ZJd6xpyhBr6EQ (lauf.py)
- 17:04 24.10.: Marke Archiv-Warnung session_01Bi5GgBLhAVhNWKFFydfU3y (lauf.py)
- 17:04 24.10.: Marke Archiv-Warnung session_01V7tidoyVMHw7r26qj6cs6R (lauf.py)
- 17:04 24.10.: Marke Archiv-Warnung session_0132AN4zJxMUFqLCDFwco2Cp (lauf.py)
- 17:04 24.10.: Marke Archiv-Warnung session_014DfnjGJvruciE9QhL4Uvfc (lauf.py)
- 17:04 24.10.: Marke Archiv-Warnung session_015xK1ojPuUwKNxz3sjksBcu (lauf.py)
- 17:04 24.10.: Marke Archiv session_01AwJJdK5ajPQjyyvVwMLpGs (lauf.py)
- 17:04 24.10.: Marke Archiv session_01NLqyWm7Wdep4EgmtnvJA2w (lauf.py)
- 17:04 24.10.: Marke Archiv-Warnung session_019jqa9XZ1Gfiw7Q9RtQXn7b (lauf.py)
- 17:04 24.10.: Marke Archiv-Warnung session_01TN9bEkpkRKJcjysV6GZXAv (lauf.py)
- 17:04 24.10.: Marke Archiv-Warnung session_01UjGqjAUQcn5AainMhYmMBZ (lauf.py)
- 17:04 24.10.: Marke Archiv-Warnung session_013ic1nMDCc5fHbWvNbgTLBF (lauf.py)
