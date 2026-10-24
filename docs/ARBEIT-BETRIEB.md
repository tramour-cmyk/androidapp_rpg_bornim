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

- **Von Chef über Sokrates (22.10., 22:21):** Build 79 (Tom und Jerry, 317) jetzt bauen, Chef testet heute noch. Danach arbeiten die Teams die Nacht durch weiter, was startbar ist; nicht wegen Guthaben anhalten (Wortlaut: „ob das Guthaben dann morgen Vormittag ausläuft … oder heute Nacht ausläuft … dann kann ich wenigstens den Build noch testen, morgen früh. Den nächsten vielleicht.“).
- **Von Sokrates (22.10., 22:3x, Chef 22:31 „schau dir Jerry 299 an“):** Jerry `session_01HrPPjrdAxzNbvs4JCyqJET` hat um 22:17 die Neustart-Bitte an die alte Ford-Sitzung `01XVKCPG` geschickt (Kennung aus dem Start, Ford seit 22:06 neu), „Ford inaktiv“ gefolgert und den Nachfolger `session_01F6KpuKLxZEqVZe86rVzKWJ` selbst gestartet; arbeitete danach weiter (320). Bitte alte Jerry-Sitzung archivieren; bei Fords Neustart die neue Kennung an laufende Sitzungen melden oder `@parent` meiden (Vorschlag, Perikles entscheidet). **Perikles 23.10., 07:4x:** kein Rundruf; Kennung vor dem Senden frisch lesen (`LISTE-RELEASE-NEUSTART.md` 1a). Offen für Ford: alte Jerry-Sitzung archivieren, dann Zeile streichen.
- **318, von Sokrates (22.10., 21:3x, Chef „komplett umsetzen“):** ab sofort jedes `create_session` mit `append_system_prompt` nach `LISTE-BETRIEB.md` (Zeile „Kennungen“); Antwortstil „Knapp“ steht in `.claude/settings.json`. Zeile nach dem ersten Start mit Anhang streichen.

## Protokoll
Eine Zeile je Lauf mit Tat, neueste oben, höchstens 20 Zeilen; ältere streichen (Verlauf in Git, 117).

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
- 23:07 24.10.: Neustart-Wunsch Sokrates (b9b243f63) abgelehnt: 123 Tsd. Token, Grenze 150 Tsd.
- 23:05 24.10.: Lauf: Start Perikles „M? entscheiden“ (190.8, offene M?-Zeilen)
- 22:42 24.10.: Neustart Jerry angenommen (218 Tsd. Token): Start „354 Haltezeit, 38 Messung“ `session_015j6X1x5CBisknNqJTmfJRz`; alte Sitzung archiviert (8,86 $ auf 354)
- 22:25 24.10.: Chef „Starte Sokrates“: Start „348.4 Probe am Handy auswerten“ `session_01PeWFfcPupSrACKfTFYWMRK`
- 22:14 24.10.: Neustart Sokrates angenommen (248 Tsd. Token): Nachfolger „348.4 Probe am Handy auswerten“ wartet auf den Test des Chefs (`ansehen/t348-probe-godot.md`), nicht gestartet; alte Sitzung archiviert (7,88 $ auf 348.4; Übergabe nennt zusätzlich 26, 252, 142, ungeteilt)
- 22:07 24.10.: Neustart Perikles angenommen (196 Tsd. Token): Nachfolger „Stand zum Marktstart (25.10.)“ startet erst 25.10. (Lauf nach 7:30); alte Sitzung archiviert (4,37 $ auf 348)
- 22:05 24.10.: Lauf: nichts zu starten (alle Rollen belegt, Diogenes nichts Startbares); Warnung 261.5 „Vorentscheid ohne Datei“ zum zweiten Mal (Archivzeile Zeile 69 nennt „gebilligt“, vermutlich Prüfmuster; Perikles)
- 22:03 24.10.: 360 gelesen: alle 21 Seiten `list_sessions` gelesen (ca. 520 Sitzungen), außer den laufenden nur Ford-Wache offen, keine Klone; ARCHIVIERE-Zeilen künftig immer ausführen
- 21:58 24.10.: Neustart Jerry angenommen (Token nicht lesbar, Build 87 als PR #171 fertig): Start „Build 87 Test, 354 Sätze“ `session_0131AKGzVxGdQzKQESXT2BHb`; alte Sitzung archiviert (Kosten fehlen)
- 21:53 24.10.: Neustart-Wunsch Homer (d2f3b7165) abgelehnt: Sitzung 10 Minuten alt, unter 150 Tsd. Token, Nachfolger wartet auf Chefwort (252.1)
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
