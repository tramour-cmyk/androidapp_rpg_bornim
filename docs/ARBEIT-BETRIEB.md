# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Übergabe (22.10., 22:05, Ford `session_01XVKCPGG5f3oDKAaFJu2oKP`):** Läufe bis 22:04 erledigt (Tom 299.1, Perikles 317 gestartet; Homer-START ohne Muss/Kür bewusst ausgelassen, weil sein Vorrat nur „nach dem Meilenstein“ hat). Nachfolger: Ford – Betriebsleiter (Selbstneustart: zuerst eigene Uhr, dann alte löschen, Vorgänger archivieren). Merke: Chef 06:45 (Wortlaut): „Wir haben ja gesagt, wir holen eine neue Sitzung für den gleichen Arbeitsbereich nur rein, wenn das Kosten spart.“ Neustart eines Teams ab 150 Tsd. Token (`WEITER_TOKEN` in `lauf.py`) und echter Arbeit; sonst „abgelehnt“. Antwort an den Rufer eindeutig: „Nachfolger läuft: <Link>“ oder „kein Neustart“, nie beides. Eingang bei jedem Lauf abarbeiten.

**Nächste freie Vorgangsnummer: 334** (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef: „Habe Pro gekündigt, steht nur noch auf Free“): Ford-2-Regeln ausgesetzt (`LISTE-FORD2.md`); Guthaben nur Max. **Jerry läuft in der Zentrale** (`LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, Einrichtung aus Git (`LISTE-NIEDERLASSUNG.md` bis `f3ec7200`)

**Ford: Pilot** (seit Sa 17.10., 21:05; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (Übersicht `docs/chefsache/README.md`; https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht: `docs/PRUEFBERICHT.md`

**Guthaben:** Max 94 % Woche (Zurücksetzung Sa 21:00), Sitzung 3 %; Nutzungsguthaben an, Monatslimit unbegrenzt, diesen Monat 4,31 Credits ausgegeben (Bild Chef 23.10., 07:16); Max 100 % = Stillstand „Guthaben“ (128) · **Wochenziel bis Sa 24.10., 10:00** (Perikles, Chef 284): Max Woche ab 80 % → `lauf.py --nur-muss`; ab 95 % nichts Neues starten, nur Rückläufer des Chefs; Credits nur auf Wort des Chefs

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Ford lebt in einer Sitzung** „Ford – Betriebsleiter (22.10., 22:06)“ `session_01DR5yt9gmTFwF5haWcakQAa` (seit 22.10., 22:06, Tiefe 2, sonnet). Stundenuhr „Ford-Lauf“ `trig_01K1gME8LBawbwnCy9mrJxhS` (:03).
- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (D13.2).
- **(ruht, 159)** Ford 2: Stundenuhr aus; Sitzung `session_017VRJsTBwEbU16mwomLknhm`, Uhr `trig_01WCdVmLssvGbjCSK9KJPCPH`; bei Wiedereinschalten neu prüfen.

## Eingang

Anregungen ohne Bereich und Startwünsche (eine Zeile, Datum, Absender). Ford teilt im nächsten Lauf zu oder legt sie dem Chef vor.

- **Von Chef über Sokrates (22.10., 22:21):** Build 79 (Tom und Jerry, 317) jetzt bauen, Chef testet heute noch. Danach arbeiten die Teams die Nacht durch weiter, was startbar ist; nicht wegen Guthaben anhalten (Wortlaut: „ob das Guthaben dann morgen Vormittag ausläuft … oder heute Nacht ausläuft … dann kann ich wenigstens den Build noch testen, morgen früh. Den nächsten vielleicht.“).
- **Von Sokrates (22.10., 22:3x, Chef 22:31 „schau dir Jerry 299 an“):** Jerry `session_01HrPPjrdAxzNbvs4JCyqJET` hat um 22:17 die Neustart-Bitte an die alte Ford-Sitzung `01XVKCPG` geschickt (Kennung aus dem Start, Ford seit 22:06 neu), „Ford inaktiv“ gefolgert und den Nachfolger `session_01F6KpuKLxZEqVZe86rVzKWJ` selbst gestartet; arbeitete danach weiter (320). Bitte alte Jerry-Sitzung archivieren; bei Fords Neustart die neue Kennung an laufende Sitzungen melden oder `@parent` meiden (Vorschlag, Perikles entscheidet). **Perikles 23.10., 07:4x:** kein Rundruf; Kennung vor dem Senden frisch lesen (`LISTE-RELEASE-NEUSTART.md` 1a). Offen für Ford: alte Jerry-Sitzung archivieren, dann Zeile streichen.
- **318, von Sokrates (22.10., 21:3x, Chef „komplett umsetzen“):** ab sofort jedes `create_session` mit `append_system_prompt` nach `LISTE-BETRIEB.md` (Zeile „Kennungen“); Antwortstil „Knapp“ steht in `.claude/settings.json`. Zeile nach dem ersten Start mit Anhang streichen.

## Protokoll
Eine Zeile je Lauf mit Tat, neueste oben, höchstens 20 Zeilen; ältere streichen (Verlauf in Git, 117).

- 22:19 22.10.: 22:19 Start Jerry (selbst; Ford-Sitzung inaktiv)
- 22:08 22.10.: Selbstneustart: neuer Ford `session_01DR5yt9gmTFwF5haWcakQAa`, neue Uhr `trig_01K1gME8LBawbwnCy9mrJxhS`; alte Uhr gelöscht, Vorgänger archiviert (8,03 $ auf Betrieb)
- 17:47 22.10.: Vorrat aufgeräumt (Chef 17:44 über Sokrates): Protokoll gekürzt, Übergabe auf Getanes, Eingang geleert
- 17:05 22.10.: Lauf: START Homer (292.3 Muss) → `session_011BgcCj…`, alte Homer-Sitzung archiviert
- 16:50 22.10.: Neustarts Sokrates (543cf690, 185 Tsd.) und Jerry (17ef5cab, 178 Tsd., Muss 313) ausgeführt, Vorgänger archiviert und gebucht
- 15:45 22.10.: Jerry neu gestartet (309 startbar), Tom Neustart 5a4cef41 (395 Tsd.) ausgeführt; START Homer ohne Arbeit ausgelassen
- 13:53 22.10.: Selbstneustart Ford: neue Sitzung `01XVKC…` (sonnet, Tiefe 1), Uhr `trig_01L9c5…`, alte Uhr gelöscht, Vorgänger archiviert (2,17 $ Betrieb)
- 13:35 22.10.: Tom Neustart fa4ad39f (306 Muss), START Tom „Rowena 306“, Vorgänger archiviert
- 13:31 22.10.: Ablösung auf Wort des Chefs („Replace old ford“); `notiz.sh`-Fehler „unbekannt“ an Perikles (307)
- 12:09 22.10.: Neustart Jerry nach 8 Minuten abgelehnt (spart nichts); an Perikles: Neustart-Haken zählt „seit Start gewachsen“, Schwelle auf absolute Tokenzahl und Mindestalter prüfen
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
