# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Übergabe (25.10., 08:10, Ford `session_01GMB8XX3Lj2V3eoBqPTsjgV`, Tiefe 0):** Chef hat Ford von Hand gestartet (110 erledigt, Datei gestrichen); Uhr umgezogen, Vorgänger archiviert (6,84 $ auf Betrieb). Altes Spiel ruht (Umzug Godot, `LISTE-UMZUG-348.md`). `list_sessions` Seite 1 hat alle nicht archivierten; Ford-Wache `session_01EjSztWBEfCSuvh2gg2pRrC` selbst anhängen. Tiefe 0: Selbstneustart bei 400 Tsd. Token möglich (bis Tiefe 5). Nachfolger: Ford – Betriebsleiter.

**Nächste freie Vorgangsnummer: 365** (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef: „Habe Pro gekündigt, steht nur noch auf Free“): Ford-2-Regeln ausgesetzt (`LISTE-FORD2.md`); Guthaben nur Max. **Jerry läuft in der Zentrale** (`LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, Einrichtung aus Git (`LISTE-NIEDERLASSUNG.md` bis `f3ec7200`)

**Ford: Pilot** (seit Sa 17.10., 21:05; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (Übersicht `docs/chefsache/README.md`; https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht: `docs/PRUEFBERICHT.md`

**Sparbetrieb (Chef 23.10., 10:22, Bild: Woche „Alle Modelle“ 100 %, Zurücksetzung Sa 20:59; nur Credits, Guthaben 79,38, Monatslimit unbegrenzt):** „Was angestoßen ist, machen wir fertig, ich prüfe Entwürfe, wir aktualisieren und bauen ein. Dann wird wohl der Spieletest heut bei mir stattfinden.“ Ford startet nur Rückläufer des Chefs und den Build für seinen Spieletest; laufende Sitzungen machen ihren Schritt fertig und übergeben, keine Neustarts ohne Arbeit; Sokrates 318 (20 Uhr) auf So nach 21 Uhr, Auswertung 340 erst nach der Zurücksetzung.

**Guthaben:** **Max 20x seit 25.10., ~11:00** (Bild Chef 11:05, Web): Woche 0 %, Sitzung 0 % (bis 16:00), Zurücksetzung Sa 31.10., 20:00, Nutzungsguthaben 0 $ an; 287 gilt weiter (80/95-%-Regel) · Bild Chef 25.10., 10:24 (an Sokrates): Sitzung 73 % (bis 11:00), Woche 33 % (Sa 31.10., 20:00), Hinweis „Limit morgen Nachmittag“; Nutzungsguthaben 0 $, Monat 303,02 $, Neuladen aus; Takt 2,3 %/h → 80 % Mo ~07, 95 % Mo ~13, 100 % Mo ~15:30 · Bild Chef 25.10., 06:54 (an Perikles): Sitzung 11 %, Woche „Alle Modelle“ 25 % (Zurücksetzung Sa 31.10., 19:59), Nutzungsguthaben an, 0 Punkte; es gilt 287 (22.10.: nicht sparen, 80 %/95 %-Regel, ab 100 % Stillstand, nichts nachkaufen); Perikles' Tagesgrenze 11 % zurückgenommen 25.10., 07:5x (361 durch 287 entschieden) · Bild Chef 24.10., 17:21 (über Sokrates): Wochenlimit aufgebraucht, Zurücksetzung 21:00; läuft über gekauftes Nutzungsguthaben, 54,03 $ übrig, Monat 248,62 $, kein Ausgabenlimit, Neuladen aus · davor: Max Woche voll seit 23.10., 10:1x (`seven_day` rejected, Sitzungen laufen über Credits, Chef laut gefragt); Zurücksetzung Sa 21:00; Nutzungsguthaben an, Monatslimit unbegrenzt, diesen Monat 4,31 Credits ausgegeben (Bild Chef 23.10., 07:16); Max 100 % = Stillstand „Guthaben“ (128) · **Wochenziel bis Sa 24.10., 10:00** (Perikles, Chef 284): Max Woche ab 80 % → `lauf.py --nur-muss`; ab 95 % nichts Neues starten, nur Rückläufer des Chefs; Credits nur auf Wort des Chefs

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Ford lebt in einer Sitzung** „Ford – Betriebsleiter (25.10., 08:07)“ `session_01GMB8XX3Lj2V3eoBqPTsjgV` (seit 25.10., 08:07, Tiefe 0). Stundenuhr „Ford-Lauf“ `trig_01MaYbuycPKEo2xSxdVv5Hjh` (:03).
- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (D13.2).
- **(ruht, 159)** Ford 2: Stundenuhr aus; Sitzung `session_017VRJsTBwEbU16mwomLknhm`, Uhr `trig_01WCdVmLssvGbjCSK9KJPCPH`; bei Wiedereinschalten neu prüfen.

## Eingang

Anregungen ohne Bereich und Startwünsche (eine Zeile, Datum, Absender). Ford teilt im nächsten Lauf zu oder legt sie dem Chef vor.

- **Werkzeugfehler `meldung.sh`, von Tom (25.10., 09:31):** `--bild` mit `--laut` sendet nie: `--laut` setzt „⚠ “ vor den Text, danach findet die Prüfung 363 die Vorgangsnummer am Textanfang nicht. Umgehung: Bild lautlos, dann kurzer Text mit `--laut`. Vorschlag: Nummer vor dem Voranstellen lesen.

- **Von Chef über Sokrates (22.10., 22:21):** Build 79 (Tom und Jerry, 317) jetzt bauen, Chef testet heute noch. Danach arbeiten die Teams die Nacht durch weiter, was startbar ist; nicht wegen Guthaben anhalten (Wortlaut: „ob das Guthaben dann morgen Vormittag ausläuft … oder heute Nacht ausläuft … dann kann ich wenigstens den Build noch testen, morgen früh. Den nächsten vielleicht.“).
- **Von Sokrates (22.10., 22:3x, Chef 22:31 „schau dir Jerry 299 an“):** Jerry `session_01HrPPjrdAxzNbvs4JCyqJET` hat um 22:17 die Neustart-Bitte an die alte Ford-Sitzung `01XVKCPG` geschickt (Kennung aus dem Start, Ford seit 22:06 neu), „Ford inaktiv“ gefolgert und den Nachfolger `session_01F6KpuKLxZEqVZe86rVzKWJ` selbst gestartet; arbeitete danach weiter (320). Bitte alte Jerry-Sitzung archivieren; bei Fords Neustart die neue Kennung an laufende Sitzungen melden oder `@parent` meiden (Vorschlag, Perikles entscheidet). **Perikles 23.10., 07:4x:** kein Rundruf; Kennung vor dem Senden frisch lesen (`LISTE-RELEASE-NEUSTART.md` 1a). Offen für Ford: alte Jerry-Sitzung archivieren, dann Zeile streichen.
- **Werkzeugfehler `lauf.py`, an Perikles (Ford 25.10.):** `--sperre` nimmt die erste Zahl im Sitzungstitel als Vorgang („Tom – Umzug Godot 12“ buchte 3,67 $ auf Archiv-Vorgang 12; Ford berichtigte). Perikles entscheidet, ob das Werkzeug die Zahl nach „Godot“ ignoriert; bis dahin Titel „Tom – 348.6 Umzug Godot n“. Zweite Doppelbuchung: Sokrates alt 7,10 $ auf Betrieb und auf 361/89/362/142.
- **318, von Sokrates (22.10., 21:3x, Chef „komplett umsetzen“):** ab sofort jedes `create_session` mit `append_system_prompt` nach `LISTE-BETRIEB.md` (Zeile „Kennungen“); Antwortstil „Knapp“ steht in `.claude/settings.json`. Zeile nach dem ersten Start mit Anhang streichen.

## Protokoll
Eine Zeile je Lauf mit Tat, neueste oben, höchstens 20 Zeilen; ältere streichen (Verlauf in Git, 117).

- 12:07 25.10.: Lauf 12:03: keine Starts (Sokrates 340.2, Jerry 20, Tom laufen/warten auf Chef 348.6, 142.1); Perikles 364 fertig (idle seit 10:17, Console verlangt Ziel-SDK 36), kein ARCHIVIERE vom Plan; Dashboard aktualisiert
- 12:03 25.10.: Neustart Sokrates angenommen (447 Tsd., Übergabe auf main; Sperre 10:28 vom Chef 12:00 aufgehoben, aus Übergabe gestrichen): Start „Sokrates – 340.2 Rollenspiegel-Werkzeug“ `session_016YT2xcv8iuvvgZC7svBtS6`; alte archiviert (15,08 $ gesamt, auf 318)
- 11:43 25.10.: Neustart Jerry angenommen (194 Tsd., Übergabe auf main): Start „Jerry – 348.7 Kampfort Godot 20“ `session_01LpXZFenpMhKj6qamEbFPX6`; alte archiviert (6,15 $ auf 348.7)
- 11:36 25.10.: Neustart Tom angenommen (245 Tsd., Übergabe auf main): Start „Tom – 348.6 Umzug Godot (25.10., 11:35)“ `session_013nKDK5LhaVvSe2ReUxtAGW`; alte archiviert (9,04 $ auf 348.6)
- 11:08 25.10.: Auftrag Chef 11:05 (über Sokrates, nach Wechsel auf Max 20x): „Feuer frei aus allen Rohren“ = alles Startbare sofort starten, Muss vor Kür, jede Rolle nur einmal, altes Spiel ruht, 80/95-%-Regel auf 20x-Limit. Geprüft: Tom 17, Jerry 19, Perikles 364 laufen; Homer, Diogenes nichts Startbares; Sokrates läuft (gesperrt)
- 11:06 25.10.: Lauf 11:03: Start „Perikles – 364“ `session_01YXpzW9hnxG9bgx4KWtS9pp` (Muss 364 von Chef 10:20); Tom 17, Jerry 19, Sokrates 318 (gesperrt) laufen; Tom 16 Kosten fehlen
- 11:03 25.10.: Neustart Jerry angenommen (209 Tsd., Übergabe auf main; Frage an den Chef in Chefsache 3487): Start „Jerry – 348.7 Kampfort Godot 19“ `session_012T3YUjSUyL57haMxwGxYSs`; alte archiviert (6,32 $ auf 348.7)
- 10:54 25.10.: Neustart Tom angenommen (Token nicht lesbar, Übergabe auf main; Fragen an den Chef als Dateien in der Chefsache): Start „Tom – 348.6 Umzug Godot 17“ `session_01WmwZPgf6NbEZgsdBgRF1qr`; alte archiviert (Kosten fehlen, lauf.py bucht beim nächsten Lauf)
- 10:37 25.10.: Neustart Jerry angenommen (211 Tsd., Übergabe auf main): Start „Jerry – 348.7 Kampfort Godot 18“ `session_01HggnHdHMAfANiEzbYfg2WV`; alte archiviert (6,13 $ auf 348.7); Weckruf Lauf 48 der alten Sitzung entfällt, Nachfolger prüft selbst
- 10:19 25.10.: Neustart Tom angenommen (197 Tsd., Übergabe auf main): Start „Tom – 348.6 Umzug Godot 16“ `session_01KbRa6ALchkdjkMdx8X3E4o`; alte archiviert (6,02 $ auf 348.6)
- 10:09 25.10.: Neustart Jerry angenommen (217 Tsd., Übergabe auf main): Start „Jerry – 348.7 Kampfort Godot 17“ `session_014SgF1QUnoEjttXQhHAMA9G`; alte archiviert (9,71 $ auf 348.7)
- 10:06 25.10.: Lauf 10:03: keine Starts (Tom 15, Jerry 16, Sokrates 318 laufen), Dashboard aktualisiert; Sokrates „Bilder Dorf und Wölfe“ 5,33 $ von lauf.py nochmals auf Betrieb gebucht (Doppelbuchung, siehe Eingang)
- 09:53 25.10.: Neustart Tom angenommen (199 Tsd., Übergabe auf main): Start „Tom – 348.6 Umzug Godot 15“ `session_01CN7z2bpKgJ5DG2bjBtdR7j`; alte archiviert (5,29 $ auf 348.6)
- 09:35 25.10.: Neustart Tom angenommen (235 Tsd., Übergabe auf main): Start „Tom – 348.6 Umzug Godot 14“ `session_01MdBVh4ZRzKuFW7CfdUJdGK`; alte archiviert (7,70 $ auf 348.6); Weckruf der alten Sitzung war schon weg
- 09:26 25.10.: Neustart Sokrates angenommen (206 Tsd., Übergabe auf main): Start „Sokrates – 318 messen“ `session_0181vCupxSiHbkBCSuMSGUiw`; alte archiviert (5,33 $: 1,72 Betrieb durch lauf.py, Rest je 1,80 auf 348.7 und 340)
- 09:16 25.10.: Neustart Tom angenommen (223 Tsd., Übergabe auf main): Start „Tom – Umzug Godot 13“ `session_01BQ2Yr4wQrYR7yB8ZX1XchD`; alte archiviert (5,50 $ auf 348.6; lauf.py hatte 3,67 $ fälschlich auf Archiv-Vorgang 12 gebucht, zurückgenommen, Perikles gemeldet)
- 09:12 25.10.: Neustart Jerry angenommen (160 Tsd., Übergabe auf main): Start „Jerry – 348.7 Kampfort Godot 16“ `session_01CxK3XKfgKotGqMkyKCJqGr`; alte archiviert (2,68 $ auf 348.7)
- 09:05 25.10.: Lauf 09:03: keine Starts (Tom 12, Jerry 15, Sokrates laufen). Morgenmeldung laut, Dashboard v27, WARNUNG-LAUT Homer-Übergabe gemeldet. Hinweis: lauf.py buchte Sokrates alt (7,10 $) zusätzlich auf Betrieb, obwohl 4×1,78 $ schon auf 361/89/362/142 stehen (Doppelbuchung 7,10 $)
- 09:00 25.10.: Neustart Sokrates angenommen (233 Tsd., Übergabe auf main): Start „Sokrates – Bilder Dorf und Wölfe“ `session_01PcvgEPaKUDwmE9t48ewvit`; alte archiviert (8,42 $ auf 142)
- 08:46 25.10.: Neustart Jerry angenommen (Token nicht lesbar, Übergabe auf main): Start „Jerry – 348.7 Kampfort Godot 15“ `session_0177967f6HkXiRV52vGC4TXi`; alte archiviert (Kosten fehlen)
- 08:30 25.10.: Neustart Jerry angenommen (225 Tsd., Übergabe auf main): Start „Jerry – 348.7 Kampfort Godot 14“ `session_018da4mPCqYW6VD51xqMvwrp`; alte archiviert (5,10 $ auf 348.7)
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
- 23:03 24.10.: Startsperre 23:03 Start Perikles (lauf.py)
- 23:03 24.10.: Nachfolger-Warnung Homer (Übergabe 24.10., 22:06) (lauf.py)
- 00:03 25.10.: Startsperre 00:03 Start Homer (lauf.py)
- 00:03 25.10.: Marke Archiv session_01QtQz79R8opV1nvRDidxxLz (lauf.py)
- 01:03 25.10.: Startsperre 01:03 Start Homer, Perikles (lauf.py)
- 01:03 25.10.: Marke Archiv session_017vWMYLY4ypmQQnXsUUQAmX (lauf.py)
- 01:03 25.10.: Nachfolger-Warnung Homer (Übergabe 25.10., 00:06) (lauf.py)
- 02:05 25.10.: Startsperre 02:05 Start Tom, Jerry, Perikles (lauf.py)
- 02:05 25.10.: Marke Stellungnahme Sokrates 25.10. (lauf.py)
- 02:05 25.10.: Marke Archiv session_01KPFibE4FrKUrJYCanecbhZ (lauf.py)
- 02:05 25.10.: Marke Archiv session_01HtyNuzwonMvzxLfJjvrKYC (lauf.py)
- 02:05 25.10.: Marke Archiv session_017cTdPrKuSbrTrsKDaj9A78 (lauf.py)
- 02:05 25.10.: Nachfolger-Warnung Homer (Übergabe 25.10., 01:08) (lauf.py)
- 07:04 25.10.: Marke Stellungnahme Sokrates 25.10. (lauf.py)
- 11:04 25.10.: Startsperre 11:04 Start Perikles (lauf.py)
