# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Übergabe (23.10., 09:10, Ford `session_01DR5yt9gmTFwF5haWcakQAa`):** Läufe bis 09:07 erledigt (Morgenmeldung 07:05 gesendet; Perikles 338 gestartet; Jerry 337, Tom Build 82 laufen). Neustart-Wünsche der Teams nur ab 150 Tsd. Token und echter Arbeit annehmen: Übergabe-Datei prüfen (Tom und Jerry überschreiten die Grenze oft schon nach 15 Minuten, ihre Haken-Angabe stimmte bisher). Homer-START ohne Muss/Kür auslassen. Nachfolger: Ford – Betriebsleiter (Selbstneustart: zuerst eigene Uhr, dann alte löschen, Vorgänger archivieren).

**Nächste freie Vorgangsnummer: 344** (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef: „Habe Pro gekündigt, steht nur noch auf Free“): Ford-2-Regeln ausgesetzt (`LISTE-FORD2.md`); Guthaben nur Max. **Jerry läuft in der Zentrale** (`LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, Einrichtung aus Git (`LISTE-NIEDERLASSUNG.md` bis `f3ec7200`)

**Ford: Pilot** (seit Sa 17.10., 21:05; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (Übersicht `docs/chefsache/README.md`; https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht: `docs/PRUEFBERICHT.md`

**Sparbetrieb (Chef 23.10., 10:22, Bild: Woche „Alle Modelle“ 100 %, Zurücksetzung Sa 20:59; nur Credits, Guthaben 79,38, Monatslimit unbegrenzt):** „Was angestoßen ist, machen wir fertig, ich prüfe Entwürfe, wir aktualisieren und bauen ein. Dann wird wohl der Spieletest heut bei mir stattfinden.“ Ford startet nur Rückläufer des Chefs und den Build für seinen Spieletest; laufende Sitzungen machen ihren Schritt fertig und übergeben, keine Neustarts ohne Arbeit; Sokrates 318 (20 Uhr) auf So nach 21 Uhr, Auswertung 340 erst nach der Zurücksetzung.

**Guthaben:** Max Woche voll seit 23.10., 10:1x (`seven_day` rejected, Sitzungen laufen über Credits, Chef laut gefragt); Zurücksetzung Sa 21:00; Nutzungsguthaben an, Monatslimit unbegrenzt, diesen Monat 4,31 Credits ausgegeben (Bild Chef 23.10., 07:16); Max 100 % = Stillstand „Guthaben“ (128) · **Wochenziel bis Sa 24.10., 10:00** (Perikles, Chef 284): Max Woche ab 80 % → `lauf.py --nur-muss`; ab 95 % nichts Neues starten, nur Rückläufer des Chefs; Credits nur auf Wort des Chefs

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Ford lebt in einer Sitzung** „Ford – Betriebsleiter (23.10., 09:11)“ `session_01UHKjhahKyiA8xRfcNd6GmC` (seit 23.10., 09:07, Tiefe 3). Stundenuhr „Ford-Lauf“ `trig_01WVB9DEhEzUVK5a5iiM8MZN` (:03).
- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (D13.2).
- **(ruht, 159)** Ford 2: Stundenuhr aus; Sitzung `session_017VRJsTBwEbU16mwomLknhm`, Uhr `trig_01WCdVmLssvGbjCSK9KJPCPH`; bei Wiedereinschalten neu prüfen.

## Eingang

Anregungen ohne Bereich und Startwünsche (eine Zeile, Datum, Absender). Ford teilt im nächsten Lauf zu oder legt sie dem Chef vor.

- **Von Chef über Sokrates (22.10., 22:21):** Build 79 (Tom und Jerry, 317) jetzt bauen, Chef testet heute noch. Danach arbeiten die Teams die Nacht durch weiter, was startbar ist; nicht wegen Guthaben anhalten (Wortlaut: „ob das Guthaben dann morgen Vormittag ausläuft … oder heute Nacht ausläuft … dann kann ich wenigstens den Build noch testen, morgen früh. Den nächsten vielleicht.“).
- **Von Sokrates (22.10., 22:3x, Chef 22:31 „schau dir Jerry 299 an“):** Jerry `session_01HrPPjrdAxzNbvs4JCyqJET` hat um 22:17 die Neustart-Bitte an die alte Ford-Sitzung `01XVKCPG` geschickt (Kennung aus dem Start, Ford seit 22:06 neu), „Ford inaktiv“ gefolgert und den Nachfolger `session_01F6KpuKLxZEqVZe86rVzKWJ` selbst gestartet; arbeitete danach weiter (320). Bitte alte Jerry-Sitzung archivieren; bei Fords Neustart die neue Kennung an laufende Sitzungen melden oder `@parent` meiden (Vorschlag, Perikles entscheidet). **Perikles 23.10., 07:4x:** kein Rundruf; Kennung vor dem Senden frisch lesen (`LISTE-RELEASE-NEUSTART.md` 1a). Offen für Ford: alte Jerry-Sitzung archivieren, dann Zeile streichen.
- **318, von Sokrates (22.10., 21:3x, Chef „komplett umsetzen“):** ab sofort jedes `create_session` mit `append_system_prompt` nach `LISTE-BETRIEB.md` (Zeile „Kennungen“); Antwortstil „Knapp“ steht in `.claude/settings.json`. Zeile nach dem ersten Start mit Anhang streichen.

## Protokoll
Eine Zeile je Lauf mit Tat, neueste oben, höchstens 20 Zeilen; ältere streichen (Verlauf in Git, 117).

- 16:00 23.10.: Neustart Jerry (f6724090, 208 Tsd.; 336 Befunde, PR #167 Merge) → `session_01STVoLsJjmbMYUoiwWY6J5U`, Vorgänger archiviert (bucht der nächste Lauf)
- 15:52 23.10.: Lauf (Läufe 15:03 bis 15:50 durch Worker-Neustart ausgefallen): keine Starts; Dashboard aktualisiert
- 14:19 23.10.: Neustart Tom (f87c7aeb; Token-Angabe 0, 24 Minuten; 343 Muss, Build 84) → `session_01TN9bEkpkRKJcjysV6GZXAv`, Vorgänger archiviert (bucht der nächste Lauf)
- 14:09 23.10.: Neustart Jerry (84aa18ae, 290 Tsd.; 336 startbar) → `session_0167VgdEtWBxGCgERhqTiDPq`, Vorgänger archiviert (bucht der nächste Lauf)
- 13:57 23.10.: Start Tom (Chef 13:54: Build 82 freigegeben, Rückläufer) → `session_01UjGqjAUQcn5AainMhYmMBZ`; 336-Hinweis an Jerry; Dashboard Version 6
- 13:36 23.10.: Neustart Jerry (eab3220e) abgelehnt: 337 wartet auf Chef, nichts Startbares
- 13:08 23.10.: Lauf: Start Jerry (Chef 12:54 zu 320) → `session_01LGJKdfP19ZJd6xpyhBr6EQ`, Vorgänger archiviert (6,58 $, gebucht); Tom-Start weiter zurückgestellt (keine Chefantwort zu Build 82/83); Dashboard Version 5
- 12:37 23.10.: Neustart Jerry (96ae0683) abgelehnt: 19 Minuten alt, nichts Startbares (320/337 warten auf Chef)
- 12:17 23.10.: Neustart Jerry (7b4cb142, 220 Tsd.; 333 Rückläufer) → `session_012gsYaU3Vt23Nx6AV2f8dc2`, Vorgänger archiviert (6,72 $, bucht der nächste Lauf)
- 12:05 23.10.: Lauf: Start Tom ausgelassen (Sparbetrieb, Chef hat zu Build 82/83 nicht geantwortet), alte Tom-Sitzung archiviert (7,48 $, gebucht); Dashboard Version 4
- 11:31 23.10.: Neustart Jerry (8acaa99d, 238 Tsd.; 320 Rückläufer) → `session_01Bi5GgBLhAVhNWKFFydfU3y`, Vorgänger archiviert (6,95 $, bucht der nächste Lauf); Dashboard 11:05 veröffentlicht (Version 3)
- 11:00 23.10.: Neustart Tom (1f449e01) angenommen, Nachfolger „Tom – Rückläufer Build 82/83“ im Sparbetrieb erst starten, wenn der Chef zu Build 82 oder 83 antwortet; alte Tom-Sitzung `session_01Q2rLBU1xCkx9sB2edSSLQQ` bleibt bis dahin stehen
- 10:54 23.10.: Neustart Jerry (2ccdd792, 222 Tsd.; 320/337 Rückläufer) → `session_01V7tidoyVMHw7r26qj6cs6R`, Vorgänger archiviert (6,01 $, bucht der nächste Lauf)
- 10:30 23.10.: Neustart Tom (d84a769b, 198 Tsd.; Build 83 für den Spieltest) → `session_01Q2rLBU1xCkx9sB2edSSLQQ`, Vorgänger archiviert (4,23 $, bucht der nächste Lauf)
- 10:25 23.10.: Sparbetrieb (Chef 10:22) eingetragen, an laufende Sitzungen gegeben
- 10:17 23.10.: Start Homer (326 Bildprüfung, Wunsch Tom) → `session_01F5PU1q8rrocH8cRv2fNEan`, alte Homer-Sitzung archiviert (2,79 $); Sokrates-Start (Stellungnahme) sofort zurückgenommen: alte Sitzung war beim Start schon wieder `working` (Liste 10:14 zeigte idle), die Doppelsitzung archiviert
- 10:15 23.10.: Neustart Perikles (455ed45d, 205 Tsd.) → `session_014DfnjGJvruciE9QhL4Uvfc`, Vorgänger archiviert (4,43 $, bucht der nächste Lauf)
- 10:14 23.10.: Neustart Jerry (22da5cc6; Token-Angabe 0, Wunsch nach 30 Minuten, angenommen wegen 320) → `session_0132AN4zJxMUFqLCDFwco2Cp`, Vorgänger archiviert (Kosten fehlen, bucht der nächste Lauf)
- 10:13 23.10.: Neustart Tom (290 Tsd., 75d5f09c) → `session_013ic1nMDCc5fHbWvNbgTLBF`, Vorgänger archiviert (2,93 $); Hinweis: `rate_limit_info` aller Sitzungen: seven_day „rejected“, isUsingOverage true (Woche voll, läuft über Credits), Chef laut gemeldet
- 10:04 23.10.: Neustart Perikles (322 Tsd., d83b911ca) → `session_015xK1ojPuUwKNxz3sjksBcu`, Vorgänger archiviert (10,91 $, bucht der nächste Lauf); 340 verteilt, Diogenes gestartet
- 09:43 23.10.: Neustart Jerry (248 Tsd., bd164a7a) → `session_018sq2oAPqvb8KLrsu9FvrJn`, Vorgänger archiviert (7,24 $ auf 337); Neustart Sokrates abgelehnt (Pause bis 20 Uhr); Tom-Sitzung 07:59 archiviert
- 09:09 23.10.: Selbstneustart: neuer Ford `session_01UHKjhahKyiA8xRfcNd6GmC`, neue Uhr `trig_01WVB9DEhEzUVK5a5iiM8MZN`; alte Uhr gelöscht, Vorgänger archiviert (8,32 $ auf Betrieb)
- 13:05 22.10.: Startsperre 13:05 Start Tom, Homer (lauf.py)
- 13:05 22.10.: Marke Archiv session_01TunWgrQE1FUQJbBkEasBfz (lauf.py)
- 14:05 22.10.: Startsperre 14:05 Start Homer (lauf.py)
- 14:05 22.10.: Marke Archiv session_012tH1XaNx3qQvwsDLsn9Qhg (lauf.py)
- 14:10 22.10.: Startsperre 14:10 Start Jerry, Perikles (lauf.py)
- 14:10 22.10.: Marke Archiv session_01YFjqfEtMYXjGkEE4zk9C58 (lauf.py)
- 15:05 22.10.: Startsperre 15:05 Start Homer (lauf.py)
- 15:05 22.10.: Marke Archiv session_01913noNMv4YQxbAFh59C6zt (lauf.py)
- 15:42 22.10.: Startsperre 15:42 Start Homer (lauf.py)
- 15:42 22.10.: Marke Archiv session_011hMK47oADncsuN92LPNRKZ (lauf.py)
- 16:04 22.10.: Startsperre 16:04 Start Homer (lauf.py)
- 17:05 22.10.: Startsperre 17:05 Start Homer (lauf.py)
- 18:04 22.10.: Marke Abgleich Vorentscheid 261.5 ohne Datei in chefsache/billigen/ und ohn (lauf.py)
- 18:04 22.10.: Marke Abgleich Vorentscheid 261.5 ohne Datei in chefsache/billigen/ und ohn (lauf.py)
- 18:04 22.10.: Marke Ohne-Rolle session_01FXj17FfiPCf5ULqiQV78pJ (lauf.py)
- 19:04 22.10.: Startsperre 19:04 Start Homer, Perikles (lauf.py)
- 19:04 22.10.: Marke Tagesbericht 22.10. (lauf.py)
- 19:04 22.10.: Marke Stellungnahme Sokrates 22.10. (lauf.py)
- 19:04 22.10.: Marke Archiv session_011BgcCjmDvYH7gEQmcTymVC (lauf.py)
- 19:04 22.10.: Marke Archiv session_01THFzkUZZzi1cUVEXqz9qLp (lauf.py)
- 20:04 22.10.: Startsperre 20:04 Start Tom, Homer (lauf.py)
- 20:04 22.10.: Marke Archiv session_01Fkpwe6sNhRvecX3yiNTqVP (lauf.py)
- 21:03 22.10.: Startsperre 21:03 Start Tom, Homer (lauf.py)
- 22:04 22.10.: Startsperre 22:04 Start Tom, Homer, Perikles (lauf.py)
- 22:04 22.10.: Marke Archiv session_01XQZZMQmJf2hD3HWUXCXbSd (lauf.py)
- 22:04 22.10.: Marke Archiv session_01UcKLSoBrD2uJuNx17oik6n (lauf.py)
- 22:06 22.10.: Startsperre 22:06 Start Homer (lauf.py)
- 23:04 22.10.: Startsperre 23:04 Start Homer, Perikles (lauf.py)
- 23:04 22.10.: Marke Archiv session_01HrPPjrdAxzNbvs4JCyqJET (lauf.py)
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
