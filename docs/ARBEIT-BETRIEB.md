# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Übergabe (22.10., 17:47, Ford `session_01XVKCPGG5f3oDKAaFJu2oKP`):** Vorrat aufgeräumt (Chef 17:44 über Sokrates), Eingang leer. Nachfolger: keiner (Selbstneustart ab 400 Tsd. Token). Merke: Chef 06:45 (Wortlaut): „Wir haben ja gesagt, wir holen eine neue Sitzung für den gleichen Arbeitsbereich nur rein, wenn das Kosten spart.“ Neustart eines Teams ab 150 Tsd. Token (`WEITER_TOKEN` in `lauf.py`) und echter Arbeit; sonst „abgelehnt“. Antwort an den Rufer eindeutig: „Nachfolger läuft: <Link>“ oder „kein Neustart“, nie beides. Eingang bei jedem Lauf abarbeiten.

**Nächste freie Vorgangsnummer: 316** (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef: „Habe Pro gekündigt, steht nur noch auf Free“): Ford-2-Regeln ausgesetzt (`LISTE-FORD2.md`); Guthaben nur Max. **Jerry läuft in der Zentrale** (`LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, Einrichtung aus Git (`LISTE-NIEDERLASSUNG.md` bis `f3ec7200`)

**Ford: Pilot** (seit Sa 17.10., 21:05; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (Übersicht `docs/chefsache/README.md`; https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht: `docs/PRUEFBERICHT.md`

**Guthaben:** Max 77 % Woche (Zurücksetzung Sa 20:59), Sitzung 27 % (Bild Chef 22.10., 12:45); Max 100 % = Stillstand „Guthaben“ (128) · **Wochenziel bis Sa 24.10., 10:00** (Perikles, Chef 284): Max Woche ab 80 % → `lauf.py --nur-muss`; ab 95 % nichts Neues starten, nur Rückläufer des Chefs; Credits nur auf Wort des Chefs

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Ford lebt in einer Sitzung** „Ford – Betriebsleiter (22.10., 13:52)“ `session_01XVKCPGG5f3oDKAaFJu2oKP` (seit 22.10., 13:52, Tiefe 1, sonnet). Stundenuhr „Ford-Lauf“ `trig_01L9c5f7fVkHkNafiHkKT6Zb` (:03).
- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (D13.2).
- **(ruht, 159)** Ford 2: Stundenuhr aus; Sitzung `session_017VRJsTBwEbU16mwomLknhm`, Uhr `trig_01WCdVmLssvGbjCSK9KJPCPH`; bei Wiedereinschalten neu prüfen.

## Eingang

Anregungen ohne Bereich und Startwünsche (eine Zeile, Datum, Absender). Ford teilt im nächsten Lauf zu oder legt sie dem Chef vor.

## Protokoll
Eine Zeile je Lauf mit Tat, neueste oben, höchstens 20 Zeilen; ältere streichen (Verlauf in Git, 117).

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
