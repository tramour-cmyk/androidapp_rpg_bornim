# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Übergabe (25.10., 02:06, Ford `session_014pMJy1VvWx3AoH5fsv49d3`):** Uhr umgezogen, Vorgänger archiviert, Lauf 02:03 geplant. Altes Spiel ruht (Umzug Godot, `LISTE-UMZUG-348.md`). `list_sessions` Seite 1 (25) hat alle nicht archivierten; Ford-Wache `session_01EjSztWBEfCSuvh2gg2pRrC` selbst anhängen. Tiefe 6: kein Selbstneustart; bei ca. 400 Tsd. Token einmal `--laut` „Chef: Ford bitte von Hand starten (Tiefe 6)“ und Datei 110 in `chefsache/entscheiden/`. Nachfolger: Ford – Betriebsleiter.

**Nächste freie Vorgangsnummer: 362** (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef: „Habe Pro gekündigt, steht nur noch auf Free“): Ford-2-Regeln ausgesetzt (`LISTE-FORD2.md`); Guthaben nur Max. **Jerry läuft in der Zentrale** (`LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, Einrichtung aus Git (`LISTE-NIEDERLASSUNG.md` bis `f3ec7200`)

**Ford: Pilot** (seit Sa 17.10., 21:05; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (Übersicht `docs/chefsache/README.md`; https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht: `docs/PRUEFBERICHT.md`

**Sparbetrieb (Chef 23.10., 10:22, Bild: Woche „Alle Modelle“ 100 %, Zurücksetzung Sa 20:59; nur Credits, Guthaben 79,38, Monatslimit unbegrenzt):** „Was angestoßen ist, machen wir fertig, ich prüfe Entwürfe, wir aktualisieren und bauen ein. Dann wird wohl der Spieletest heut bei mir stattfinden.“ Ford startet nur Rückläufer des Chefs und den Build für seinen Spieletest; laufende Sitzungen machen ihren Schritt fertig und übergeben, keine Neustarts ohne Arbeit; Sokrates 318 (20 Uhr) auf So nach 21 Uhr, Auswertung 340 erst nach der Zurücksetzung.

**Guthaben:** Bild Chef 25.10., 06:54 (an Perikles): Sitzung 11 %, Woche „Alle Modelle“ 25 % (Zurücksetzung Sa 31.10., 19:59), Nutzungsguthaben an, 0 Punkte; Ziel höchstens etwa 11 % je Tag (Perikles, Wochenziel), also `--nur-muss` bleibt, bis der Verbrauch darunter liegt · Bild Chef 24.10., 17:21 (über Sokrates): Wochenlimit aufgebraucht, Zurücksetzung 21:00; läuft über gekauftes Nutzungsguthaben, 54,03 $ übrig, Monat 248,62 $, kein Ausgabenlimit, Neuladen aus · davor: Max Woche voll seit 23.10., 10:1x (`seven_day` rejected, Sitzungen laufen über Credits, Chef laut gefragt); Zurücksetzung Sa 21:00; Nutzungsguthaben an, Monatslimit unbegrenzt, diesen Monat 4,31 Credits ausgegeben (Bild Chef 23.10., 07:16); Max 100 % = Stillstand „Guthaben“ (128) · **Wochenziel bis Sa 24.10., 10:00** (Perikles, Chef 284): Max Woche ab 80 % → `lauf.py --nur-muss`; ab 95 % nichts Neues starten, nur Rückläufer des Chefs; Credits nur auf Wort des Chefs

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

- 07:03 25.10.: Neustart Sokrates (238 Tsd.) mit Wartebedingung (Chefsache 361 Sichtkegel): kein Start, alte Sitzung archiviert (10,11 $ auf 348.5); Nachfolger „Umzug 348 begleiten“ startet erst nach Antwort des Chefs
- 06:59 25.10.: Neustart Jerry angenommen (214 Tsd., Übergabe auf main): Start „348.7 Kampfort Godot 10" `session_01NEiqBbKYnmQ5Gcjd8S6SCD`; alte archiviert (6,18 $ auf 348.7)
- 06:56 25.10.: Neustart Tom angenommen (205 Tsd., Übergabe auf main): Start „Umzug Godot 10" `session_01WdjmNvBbDxMFuMmF6TnJtk`; alte archiviert (5,38 $ auf 348.6). Guthaben: `seven_day` allowed_warning (Zurücksetzung Sa 31.10., 21:00) → ab nächstem Lauf `--nur-muss`
- 06:24 25.10.: Neustart Jerry angenommen (Token nicht lesbar, 61 Min Arbeit, Übergabe auf main): Start „348.7 Kampfort Godot 9" `session_019Aecf6JDyDEL34hu7RGZ3G`; alte archiviert (Kosten fehlen)
- 06:16 25.10.: Neustart Tom angenommen (Token nicht lesbar, Übergabe auf main): Start „Umzug Godot 9" `session_01RTfCzDt59xd6AHn5XqU5Pj`; alte archiviert (Kosten fehlen)
- 05:39 25.10.: Neustart Tom angenommen (299 Tsd., Übergabe auf main): Start „Umzug Godot 8" `session_01TS4M47TVBdYtggJWjaZ9j3`; alte archiviert (10,68 $ auf 348.6)
- 05:22 25.10.: Neustart Jerry angenommen (245 Tsd., Übergabe auf main): Start „348.7 Kampfort Godot 8" `session_0156yUu6QateoVJnT93wQrAV`; alte archiviert (6,61 $ auf 348.7)
- 04:54 25.10.: Neustart Jerry angenommen (244 Tsd., Übergabe auf main): Start „348.7 Kampfort Godot 7" `session_01NMoLT1QrmYAE1HgXDjWDoj`; alte archiviert (7,26 $ auf 348.7)
- 04:50 25.10.: Neustart Tom angenommen (231 Tsd., Übergabe auf main): Start „Umzug Godot 7" `session_01KN6z3N3ciVdThqEts5ogbb`; alte archiviert (5,91 $ auf 348.6)
- 04:32 25.10.: Neustart Jerry angenommen (241 Tsd., Übergabe auf main): Start „348.7 Kampfort Godot 6" `session_01L9ooAJsZ3HKoHLbqcYT69Z`; alte archiviert (6,56 $ auf 348.7)
- 04:16 25.10.: Neustart Tom angenommen (Token nicht lesbar, Übergabe auf main): Start „Umzug Godot 6" `session_01XEkKYvohsVvwdToDqyjaB4`; alte archiviert (Kosten fehlen)
- 03:56 25.10.: Neustart Jerry angenommen (291 Tsd., Übergabe auf main): Start „348.7 Kampfort Godot 5" `session_01WcNybnBdvA6hSjv4DDXviW`; alte archiviert (9,60 $ auf 348.7)
- 03:29 25.10.: Neustart Tom angenommen (284 Tsd., Übergabe auf main): Start „Umzug Godot 5" `session_01KbMdXB89v5ipRLRoEXYAA7`; alte archiviert (10,71 $ auf 348.6)
- 02:55 25.10.: Neustart Tom angenommen (Token nicht lesbar, Übergabe auf main): Start „Umzug Godot 2“ `session_01QKpFrCV6DCLdzSPRu3pLdW`; alte Sitzung archiviert (Kosten fehlen)
- 02:53 25.10. (Winterzeit): Neustart Tom (218 Tsd.) und Jerry (285 Tsd.) angenommen, Übergaben auf main: Start „Umzug Godot 4" `session_01XkDaUr5dMJ6oCpnbjjvnah`, „348.7 Kampfort Godot 4" `session_01T9ws9tQ7ynWSwgNjdHbfAv`; alte archiviert (8,51 $ auf 348.6, 8,38 $ auf 348.7)
- 02:48 25.10.: Neustart Jerry angenommen (Token nicht lesbar, Übergabe auf main): Start „348.7 Kampfort Godot 2“ `session_01Dz4p7fgS8xUQ1dbUAjM3N7`; alte Sitzung archiviert (Kosten fehlen). Neustart Sokrates 02:27 abgelehnt (127 Tsd., Nachfolger wartet auf Test t3485)
- 02:34 25.10. (Winterzeit): Neustart Jerry angenommen (220 Tsd. Token, Übergabe auf main): Start „348.7 Kampfort Godot 3" `session_01T8UypmYrWTQWBxJhAgGBiX`; alte Sitzung archiviert (8,53 $ auf 348.7)
- 02:17 25.10. (Winterzeit): Neustart Tom angenommen (281 Tsd. Token, Übergabe auf main): Start „Umzug Godot 3" `session_016eg6bKZexpJ3qxfJ4m4kRj`; alte Sitzung archiviert (12,29 $ auf 348.6)
- 02:06 25.10.: Selbstneustart Ford (Tiefe 6): neue Uhr, alte gelöscht, Vorgänger archiviert (8,59 $ auf Betrieb). Tom, Jerry, Sokrates, Perikles am 5-h-Limit gescheitert (01:28, Zurücksetzung 02:00): Start Tom 348.6, Jerry 348.7, Perikles Umzugsplan, Sokrates WEITER
- 01:26 25.10.: Pause aufgehoben (Sokrates): Start Tom „348.6 Umzug Godot Fundament“ `session_01KPFibE4FrKUrJYCanecbhZ`, Jerry „348.7 Umzug Godot Kampfort“ `session_01HtyNuzwonMvzxLfJjvrKYC`; alte Sitzungen archiviert (Kosten 4,92 $ auf 342 und 3,46 $ auf Betrieb von `lauf.py` gebucht)
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
