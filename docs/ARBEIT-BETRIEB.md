# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Übergabe (24.10., 21:35, Ford `session_01LaCAodpq9x5Bex49yFuw6d`):** Läufe bis 21:32 erledigt; Sparbetrieb vorbei (Sa 21:00; Guthaben: gekauftes Nutzungsguthaben, 54,03 $ Stand 17:21); laufen: Homer 352.1, Tom 358, Jerry 351, Sokrates 348.4; Perikles und Diogenes nichts Startbares; Neustart-Wünsche der Teams ab 150 Tsd. Token und echter Arbeit annehmen, Nachfolger mit Wartebedingung (Test/Wort des Chefs) zurückstellen, alte Sitzung archivieren und Kosten buchen; Dashboard jeden Lauf (Schritt 11) wurde in den letzten Läufen ausgelassen: nachholen; `list_sessions` hat `has_more`: nur erste Seite gelesen, `lauf.py` warnt, ARCHIVIERE-Zeilen alter Sitzungen sind meist schon ausgeführt; Frage des Chefs offen: Tom 338.1, wer liest den englischen Text Korrektur (Homer oder Chef). Nachfolger: Ford – Betriebsleiter.

**Nächste freie Vorgangsnummer: 361** (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef: „Habe Pro gekündigt, steht nur noch auf Free“): Ford-2-Regeln ausgesetzt (`LISTE-FORD2.md`); Guthaben nur Max. **Jerry läuft in der Zentrale** (`LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, Einrichtung aus Git (`LISTE-NIEDERLASSUNG.md` bis `f3ec7200`)

**Ford: Pilot** (seit Sa 17.10., 21:05; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (Übersicht `docs/chefsache/README.md`; https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht: `docs/PRUEFBERICHT.md`

**Sparbetrieb (Chef 23.10., 10:22, Bild: Woche „Alle Modelle“ 100 %, Zurücksetzung Sa 20:59; nur Credits, Guthaben 79,38, Monatslimit unbegrenzt):** „Was angestoßen ist, machen wir fertig, ich prüfe Entwürfe, wir aktualisieren und bauen ein. Dann wird wohl der Spieletest heut bei mir stattfinden.“ Ford startet nur Rückläufer des Chefs und den Build für seinen Spieletest; laufende Sitzungen machen ihren Schritt fertig und übergeben, keine Neustarts ohne Arbeit; Sokrates 318 (20 Uhr) auf So nach 21 Uhr, Auswertung 340 erst nach der Zurücksetzung.

**Guthaben:** Bild Chef 24.10., 17:21 (über Sokrates): Wochenlimit aufgebraucht, Zurücksetzung 21:00; läuft über gekauftes Nutzungsguthaben, 54,03 $ übrig, Monat 248,62 $, kein Ausgabenlimit, Neuladen aus · davor: Max Woche voll seit 23.10., 10:1x (`seven_day` rejected, Sitzungen laufen über Credits, Chef laut gefragt); Zurücksetzung Sa 21:00; Nutzungsguthaben an, Monatslimit unbegrenzt, diesen Monat 4,31 Credits ausgegeben (Bild Chef 23.10., 07:16); Max 100 % = Stillstand „Guthaben“ (128) · **Wochenziel bis Sa 24.10., 10:00** (Perikles, Chef 284): Max Woche ab 80 % → `lauf.py --nur-muss`; ab 95 % nichts Neues starten, nur Rückläufer des Chefs; Credits nur auf Wort des Chefs

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Ford lebt in einer Sitzung** „Ford – Betriebsleiter (24.10., 21:36)“ `session_01PTiHPVr2tbyeoc6ZVUaBXB` (seit 24.10., 21:29, Tiefe 5). Stundenuhr „Ford-Lauf“ `trig_01BuhgCyjJdohQrcWgwqRhqN` (:03).
- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (D13.2).
- **(ruht, 159)** Ford 2: Stundenuhr aus; Sitzung `session_017VRJsTBwEbU16mwomLknhm`, Uhr `trig_01WCdVmLssvGbjCSK9KJPCPH`; bei Wiedereinschalten neu prüfen.

## Eingang

Anregungen ohne Bereich und Startwünsche (eine Zeile, Datum, Absender). Ford teilt im nächsten Lauf zu oder legt sie dem Chef vor.

- **360, von Perikles (24.10., 21:4x, Chef 21:35 „lauter Klone … aufräumen“):** fünf alte Sitzungen von Hand archiviert (Homer 326, Homer Umrüstzeilen, Homer 279, Diogenes 340, Diogenes 21.10.; Kosten gebucht, 279 +2,33 $). Ursache 1 behoben: Titel „Homer, …“ galt als ohne Rolle (`kosten.py`). Ursache 2 für Ford: `lauf.py` plante ARCHIVIERE für Homer 326 und Diogenes 21.10. längst, ausgeführt wurde es nie; bitte jede ARCHIVIERE-Zeile ausführen und alle Seiten bis `has_more` falsch lesen. Zeile streichen, wenn gelesen.
- **Von Chef über Sokrates (22.10., 22:21):** Build 79 (Tom und Jerry, 317) jetzt bauen, Chef testet heute noch. Danach arbeiten die Teams die Nacht durch weiter, was startbar ist; nicht wegen Guthaben anhalten (Wortlaut: „ob das Guthaben dann morgen Vormittag ausläuft … oder heute Nacht ausläuft … dann kann ich wenigstens den Build noch testen, morgen früh. Den nächsten vielleicht.“).
- **Von Sokrates (22.10., 22:3x, Chef 22:31 „schau dir Jerry 299 an“):** Jerry `session_01HrPPjrdAxzNbvs4JCyqJET` hat um 22:17 die Neustart-Bitte an die alte Ford-Sitzung `01XVKCPG` geschickt (Kennung aus dem Start, Ford seit 22:06 neu), „Ford inaktiv“ gefolgert und den Nachfolger `session_01F6KpuKLxZEqVZe86rVzKWJ` selbst gestartet; arbeitete danach weiter (320). Bitte alte Jerry-Sitzung archivieren; bei Fords Neustart die neue Kennung an laufende Sitzungen melden oder `@parent` meiden (Vorschlag, Perikles entscheidet). **Perikles 23.10., 07:4x:** kein Rundruf; Kennung vor dem Senden frisch lesen (`LISTE-RELEASE-NEUSTART.md` 1a). Offen für Ford: alte Jerry-Sitzung archivieren, dann Zeile streichen.
- **318, von Sokrates (22.10., 21:3x, Chef „komplett umsetzen“):** ab sofort jedes `create_session` mit `append_system_prompt` nach `LISTE-BETRIEB.md` (Zeile „Kennungen“); Antwortstil „Knapp“ steht in `.claude/settings.json`. Zeile nach dem ersten Start mit Anhang streichen.

## Protokoll
Eine Zeile je Lauf mit Tat, neueste oben, höchstens 20 Zeilen; ältere streichen (Verlauf in Git, 117).

- 21:32 24.10.: Neustart Sokrates (239 Tsd. Token) angenommen: Start „348.4 Held und Dorf in Godot“ `session_01UswNFZVaGXQi2Kmg8wS7Cm`; alte Sitzung archiviert (6,28 $ auf 348)
- 21:44 24.10.: Neustart Homer angenommen (228 Tsd. Token): Start „338.1a Englisch Korrektur“ `session_01QtQz79R8opV1nvRDidxxLz`; alte Sitzung archiviert (13,05 $ auf 352.1)
- 21:36 24.10.: Neustart Jerry angenommen (277 Tsd. Token): Start „354 Neufassung, Build 87“ `session_018UkkMKn7r4f2X5qjim4ZfG`; alte Sitzung archiviert (12,10 $ auf 351)
- 21:31 24.10.: Selbstneustart Ford (395 Tsd. Token): neue Uhr `trig_01BuhgCy…`, alte gelöscht, Vorgänger `01LaCAod` archiviert (10,72 $ auf Betrieb)
- 21:21 24.10.: Neustart Tom angenommen (258 Tsd. Token): Start Tom 358 (Ruckeln nach Build 85, Chef über Jerry) `session_01NUbzwK1pY6hkFUtM1sKFP3`; alte Sitzung archiviert (8,39 $ auf 348)
- 21:09 24.10.: Lauf: Sparbetrieb vorbei (Sa 21:00); Start Homer 352.1 `session_01GUPpht91vJvHhEEQUjypZb`; Tom (348.3) und Jerry (351) laufen
- 21:06 24.10.: Chef „Versuch es noch einmal“: alter Ford `01UHKjha` archiviert; Start Sokrates „348 Grafikweg“ `session_01XBin739SnhFn33DDUC1BZg` (Pause 21:00 vorbei); alte Sokrates-Sitzung archiviert (20,69 $ auf 348)
- 19:02 24.10.: Sokrates-Neustart gemeldet (844518c12, Nachfolger „348 Grafikweg, Entwürfe und Fehlermessung“): Pause bis 21:00 (Chef 18:42), Start im Lauf ab 21:03; alte Sitzung `session_01SG9iCnvKHqRbNpGQPM9j8J` bis dahin offen
- 18:51 24.10.: Neustart-Wunsch Jerry (289 Tsd. Token, 351-Fix, 348.3 erledigt) angenommen: Start Jerry 351 `session_01KefbZnpNKgq1Pz6cMrJoVF`; alte Sitzung archiviert (12,14 $ auf 336)
- 18:36 24.10.: Chef 18:30 „Vorarbeiten laufen weiter“ (über Sokrates) 348.3: Start Tom `session_01RhoQQvfNqRL14rp7T9TX7V`; Jerry (`session_01PdxSp7pQi8GmvML1Eo9kPo`, wartet seit Do auf Chef zu 336) per „Weiter: 348.3“ angestoßen
- 18:20 24.10.: Chef „Dann ja zu 348“ (über Sokrates): Start Perikles 348 `session_01D2RVwqV4TWY1W8h6kbfT3e`; Perikles-Sitzung 26 fertig, archiviert (1,21 $ auf 26)
- 18:06 24.10.: Lauf: Start Perikles 26 (Durchspielbogen des Chefs in Vorgänge) `session_013GfBv7Df2tcxQKw9pWzyqM`; Jerry-Kür 349 im Sparbetrieb nicht gestartet
- 17:55 24.10.: Neustart-Wunsch Tom (183 Tsd. Token, 348.2 fertig) angenommen; alte Sitzung archiviert (6,05 $ auf 348); Nachfolger „Rückmeldung 348 und Build 85“ wartet auf Wort des Chefs
- 17:36 24.10.: Chef wartet auf 348.2 (über Sokrates): Start Tom `session_01CQhLH4E5PkfSw4YTGPz2fp`; Sokrates-Neustart angenommen (216 Tsd. Token), alte Sitzung archiviert (7,39 $ auf 347), Nachfolger „348 Engine, 26 Gegenprobe“ startet nach der Pause ab 21:00
- 17:34 24.10.: Chef „Ich brauche Sokrates jetzt“: Start Sokrates „348 Engine, 26 Gegenprobe“ `session_01SG9iCnvKHqRbNpGQPM9j8J` (Pause aufgehoben)
- 17:25 24.10.: Guthaben-Bild eingetragen (54,03 $ übrig)
- 17:17 24.10.: Neustart-Wunsch Tom (231 Tsd. Token, 348.1 fertig) angenommen; alte Sitzung archiviert (5,36 $ auf 348); Nachfolger „Build-Rückmeldung 85“ zurückgestellt bis Test des Chefs
- 17:08 24.10.: Lauf: Perikles 347.2 fertig, archiviert (6,26 $ auf 347); alte Perikles-Sitzung 10:15 archiviert (2,20 $); Seitenliste abgeschnitten, Dashboard ausgelassen
- 16:58 24.10.: Chef „jetzt“ 348.1 (über Sokrates): Start Tom `session_01SjbZEDA8KHxgYjkXzjLwRb`
- 16:50 24.10.: Chef: Perikles starten (Diogenes 347.1 fertig): Start Perikles 347.2 `session_018qKCWNst9vgqGKpbhTcPRH`; Diogenes-Sitzung archiviert (1,77 $ auf 347)
- 16:46 24.10.: Neustart-Wunsch Tom angenommen (231 Tsd. Token, Build 85 fertig); alte Sitzung archiviert (7,62 $ auf 346); Nachfolger „Build-Rückmeldung 85“ zurückgestellt bis Test des Chefs
- 16:38 24.10.: Chef 347 (Sokrates-Bitte): Start Diogenes 347.1 `session_01SMtfbQ4qoTGcHPxQpJ3C39`; Perikles 347.2 folgt nach Diogenes; Neustart Sokrates `session_01VTMH21n3GHA88hAogZ2csJ`, alte Sokrates-Sitzung archiviert (102,64 $ auf Betrieb); 21 Ford-Uhr-Weckrufe seit 23.10., 19:03 blieben unbearbeitet (Sitzung ruhte)
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
- 21:30 24.10.: Marke Abgleich Vorentscheid 261.5 ohne Datei in chefsache/billigen/ und ohn (lauf.py)
- 21:30 24.10.: Marke Abgleich Vorentscheid 261.5 ohne Datei in chefsache/billigen/ und ohn (lauf.py)
