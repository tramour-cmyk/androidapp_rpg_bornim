# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Übergabe (25.10., 02:06, Ford `session_014pMJy1VvWx3AoH5fsv49d3`):** Uhr umgezogen, Vorgänger archiviert, Lauf 02:03 geplant. Altes Spiel ruht (Umzug Godot, `LISTE-UMZUG-348.md`). `list_sessions` Seite 1 (25) hat alle nicht archivierten; Ford-Wache `session_01EjSztWBEfCSuvh2gg2pRrC` selbst anhängen. Tiefe 6: kein Selbstneustart; bei ca. 400 Tsd. Token einmal `--laut` „Chef: Ford bitte von Hand starten (Tiefe 6)“ und Datei 110 in `chefsache/entscheiden/`. Nachfolger: Ford – Betriebsleiter.

**Nächste freie Vorgangsnummer: 361** (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef: „Habe Pro gekündigt, steht nur noch auf Free“): Ford-2-Regeln ausgesetzt (`LISTE-FORD2.md`); Guthaben nur Max. **Jerry läuft in der Zentrale** (`LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, Einrichtung aus Git (`LISTE-NIEDERLASSUNG.md` bis `f3ec7200`)

**Ford: Pilot** (seit Sa 17.10., 21:05; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (Übersicht `docs/chefsache/README.md`; https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht: `docs/PRUEFBERICHT.md`

**Sparbetrieb (Chef 23.10., 10:22, Bild: Woche „Alle Modelle“ 100 %, Zurücksetzung Sa 20:59; nur Credits, Guthaben 79,38, Monatslimit unbegrenzt):** „Was angestoßen ist, machen wir fertig, ich prüfe Entwürfe, wir aktualisieren und bauen ein. Dann wird wohl der Spieletest heut bei mir stattfinden.“ Ford startet nur Rückläufer des Chefs und den Build für seinen Spieletest; laufende Sitzungen machen ihren Schritt fertig und übergeben, keine Neustarts ohne Arbeit; Sokrates 318 (20 Uhr) auf So nach 21 Uhr, Auswertung 340 erst nach der Zurücksetzung.

**Guthaben:** Bild Chef 24.10., 17:21 (über Sokrates): Wochenlimit aufgebraucht, Zurücksetzung 21:00; läuft über gekauftes Nutzungsguthaben, 54,03 $ übrig, Monat 248,62 $, kein Ausgabenlimit, Neuladen aus · davor: Max Woche voll seit 23.10., 10:1x (`seven_day` rejected, Sitzungen laufen über Credits, Chef laut gefragt); Zurücksetzung Sa 21:00; Nutzungsguthaben an, Monatslimit unbegrenzt, diesen Monat 4,31 Credits ausgegeben (Bild Chef 23.10., 07:16); Max 100 % = Stillstand „Guthaben“ (128) · **Wochenziel bis Sa 24.10., 10:00** (Perikles, Chef 284): Max Woche ab 80 % → `lauf.py --nur-muss`; ab 95 % nichts Neues starten, nur Rückläufer des Chefs; Credits nur auf Wort des Chefs

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Ford lebt in einer Sitzung** „Ford – Betriebsleiter (25.10., 02:06)“ `session_014pMJy1VvWx3AoH5fsv49d3` (seit 25.10., 02:04, Tiefe 6). Stundenuhr „Ford-Lauf“ `trig_0136mvn98vkcyPJVfVJsbsfp` (:03).
- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (D13.2).
- **(ruht, 159)** Ford 2: Stundenuhr aus; Sitzung `session_017VRJsTBwEbU16mwomLknhm`, Uhr `trig_01WCdVmLssvGbjCSK9KJPCPH`; bei Wiedereinschalten neu prüfen.

## Eingang

Anregungen ohne Bereich und Startwünsche (eine Zeile, Datum, Absender). Ford teilt im nächsten Lauf zu oder legt sie dem Chef vor.

- **Von Chef über Sokrates (22.10., 22:21):** Build 79 (Tom und Jerry, 317) jetzt bauen, Chef testet heute noch. Danach arbeiten die Teams die Nacht durch weiter, was startbar ist; nicht wegen Guthaben anhalten (Wortlaut: „ob das Guthaben dann morgen Vormittag ausläuft … oder heute Nacht ausläuft … dann kann ich wenigstens den Build noch testen, morgen früh. Den nächsten vielleicht.“).
- **Von Sokrates (22.10., 22:3x, Chef 22:31 „schau dir Jerry 299 an“):** Jerry `session_01HrPPjrdAxzNbvs4JCyqJET` hat um 22:17 die Neustart-Bitte an die alte Ford-Sitzung `01XVKCPG` geschickt (Kennung aus dem Start, Ford seit 22:06 neu), „Ford inaktiv“ gefolgert und den Nachfolger `session_01F6KpuKLxZEqVZe86rVzKWJ` selbst gestartet; arbeitete danach weiter (320). Bitte alte Jerry-Sitzung archivieren; bei Fords Neustart die neue Kennung an laufende Sitzungen melden oder `@parent` meiden (Vorschlag, Perikles entscheidet). **Perikles 23.10., 07:4x:** kein Rundruf; Kennung vor dem Senden frisch lesen (`LISTE-RELEASE-NEUSTART.md` 1a). Offen für Ford: alte Jerry-Sitzung archivieren, dann Zeile streichen.
- **318, von Sokrates (22.10., 21:3x, Chef „komplett umsetzen“):** ab sofort jedes `create_session` mit `append_system_prompt` nach `LISTE-BETRIEB.md` (Zeile „Kennungen“); Antwortstil „Knapp“ steht in `.claude/settings.json`. Zeile nach dem ersten Start mit Anhang streichen.

## Protokoll
Eine Zeile je Lauf mit Tat, neueste oben, höchstens 20 Zeilen; ältere streichen (Verlauf in Git, 117).

- 02:55 25.10.: Neustart Tom angenommen (Token nicht lesbar, Übergabe auf main): Start „Umzug Godot 2“ `session_01QKpFrCV6DCLdzSPRu3pLdW`; alte Sitzung archiviert (Kosten fehlen)
- 02:53 25.10. (Winterzeit): Neustart Tom (218 Tsd.) und Jerry (285 Tsd.) angenommen, Übergaben auf main: Start „Umzug Godot 4" `session_01XkDaUr5dMJ6oCpnbjjvnah`, „348.7 Kampfort Godot 4" `session_01T9ws9tQ7ynWSwgNjdHbfAv`; alte archiviert (8,51 $ auf 348.6, 8,38 $ auf 348.7)
- 02:48 25.10.: Neustart Jerry angenommen (Token nicht lesbar, Übergabe auf main): Start „348.7 Kampfort Godot 2“ `session_01Dz4p7fgS8xUQ1dbUAjM3N7`; alte Sitzung archiviert (Kosten fehlen). Neustart Sokrates 02:27 abgelehnt (127 Tsd., Nachfolger wartet auf Test t3485)
- 02:34 25.10. (Winterzeit): Neustart Jerry angenommen (220 Tsd. Token, Übergabe auf main): Start „348.7 Kampfort Godot 3" `session_01T8UypmYrWTQWBxJhAgGBiX`; alte Sitzung archiviert (8,53 $ auf 348.7)
- 02:17 25.10. (Winterzeit): Neustart Tom angenommen (281 Tsd. Token, Übergabe auf main): Start „Umzug Godot 3" `session_016eg6bKZexpJ3qxfJ4m4kRj`; alte Sitzung archiviert (12,29 $ auf 348.6)
- 02:06 25.10.: Selbstneustart Ford (Tiefe 6): neue Uhr, alte gelöscht, Vorgänger archiviert (8,59 $ auf Betrieb). Tom, Jerry, Sokrates, Perikles am 5-h-Limit gescheitert (01:28, Zurücksetzung 02:00): Start Tom 348.6, Jerry 348.7, Perikles Umzugsplan, Sokrates WEITER
- 01:26 25.10.: Pause aufgehoben (Sokrates): Start Tom „348.6 Umzug Godot Fundament“ `session_01KPFibE4FrKUrJYCanecbhZ`, Jerry „348.7 Umzug Godot Kampfort“ `session_01HtyNuzwonMvzxLfJjvrKYC`; alte Sitzungen archiviert (Kosten 4,92 $ auf 342 und 3,46 $ auf Betrieb von `lauf.py` gebucht)
- 01:23 25.10.: Neustart Sokrates angenommen (239 Tsd. Token, Chef 01:19 „Vertreter“ im Vorgangsarchiv geprüft): Start „Vertretung Nacht, Umzug 348“ `session_01KCxc8hNNVcDSo9r43JBPZr`; alte Sitzung archiviert (7,67 $ auf 348.5); Pause Tom/Jerry von Sokrates aufgehoben (348.6–348.8)
- 01:11 25.10.: Pause bis 26.10. für Tom und Jerry (Sokrates 01:05: Chef 01:04 „ja“ zu Rückfrage 348 (2)–(4), geprüft im Vorgangsarchiv „348, Umstieg“ und Chefsache 348): altes Spiel ruht außer 142; laufende Sitzungen informiert
- 01:05 25.10.: Lauf: Start Perikles „Stand zum Marktstart“ `session_017cTdPrKuSbrTrsKDaj9A78`, alte Sitzung archiviert (4,33 $ auf Betrieb); Homer weiter mit 344.2 (WEITER)
- 00:54 25.10.: Neustart Jerry angenommen (Token nicht lesbar, 296.2 Rest und 344.2 gebaut): Start „Build 89“ `session_01BtqZrvTYuTwh1YFW53gzRx`; alte Sitzung archiviert (Kosten fehlen)
- 00:09 25.10.: Neustart Tom angenommen (189 Tsd. Token): Start „342 Termine marktreif“ `session_01XgFMVL92byAL5U7poWV3Gj`; alte Sitzung archiviert (7,19 $ auf 353); offene Frage „Probe 4 in den nächsten Build?“ steht als Chefsache 353a
- 00:06 25.10.: Neustart Jerry angenommen (321 Tsd. Token, Build 88 auf `main`): Start „296.2 MARS Rest“ `session_01Stfe1kAxYdSK3EbTpCtU5L`; alte Sitzung archiviert (10,79 $ auf 296.2)
- 00:05 25.10.: Start Homer „296.2“ `session_01VKihdGjdGCWLW3KURkrYPc` (Nachfolger 302 wartet auf Tom); alte Homer-Sitzung archiviert (10,78 $ schon auf 338.1a); Jerry-Wunsch (c46b5f36a) offen: Token-Zahl erfragt
- 00:01 25.10.: Start Sokrates „348.5 Probe am Handy auswerten“ `session_01LRzaQwzyGohvsrgmAKj2qV` (Wartebedingung weg: Rückläufer des Chefs 23:59 über Perikles)
- 23:37 24.10.: Neustart Jerry angenommen (2. Wunsch, jetzt echte Arbeit 296.2): Start „296.2 MARS spielnötig, Build 88“ `session_01JNJcQ3fHnYzPNUfKays6Jz` (übernimmt Abo PR #172); alte Sitzung archiviert (Kosten fehlen)
- 23:36 24.10.: Neustart-Wunsch Jerry (b1a99ce82) abgelehnt: Sitzung 26 Minuten alt, Nachfolger wartet auf Test Build 88, Abo PR #172 bliebe sonst ohne Sitzung
- 23:34 24.10.: Neustart Sokrates angenommen (382 Tsd. Token): Nachfolger „348.5 Probe am Handy auswerten“ wartet auf Test des Chefs (`ansehen/t3485-texturprobe.md`), nicht gestartet; alte Sitzung archiviert (17,64 $ auf 348.5)
- 23:17 24.10.: Neustart Tom angenommen (213 Tsd. Token): Start „353 Sicht im tiefen Wald“ `session_01ArmsUwvdCeApJRGkVNFqgL`; alte Sitzung archiviert (5,68 $ auf 359)
- 23:09 24.10.: Neustart Jerry angenommen (232 Tsd. Token): Start „Build 88 Test, 356.1 Lyra“ `session_011ijt2aLFDuYoHwivryTihD`; alte Sitzung archiviert (7,99 $ auf 38)
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
