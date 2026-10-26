# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Übergabe (26.10., 16:40, Ford `session_01AyscMQYxPRGvhJzpxGd5pR`, Tiefe 4, bei 392 Tsd. Token):** Selbstneustart; Läufe bis 16:03 erledigt, Neustarts Tom/Jerry/Sokrates gebucht. Läuft: Tom `session_01GC1Ue16aB26wjCPzdBh74X`, Jerry `session_01JbGmkuZ2zQm5ZmPKetfTSK`, Sokrates `session_01BfRnNnmzY7HzeUfBHzogsP`, Homer 348.12g `session_01Twr8DKumpNBQFzjt1faRwK`, Perikles 348.12d `session_01Fntj2e4N2uaSrBSdjEPSUm`, Diogenes Goblin-CC0 r1 `session_012krqNNsR29bFno54yfBJu1` (nach Ende archivieren, Kosten auf 348.9). Offen: Chef-Antwort, ob die alte Sokrates-Sitzung `session_017XDYAMk2XGjr9uKDP9iZHq` archiviert werden darf (Filter lehnte ab; Kosten 9,60 $, davon 8,76 $ auf 348 gebucht); Kosten fehlen (kein usage): Perikles Wochenziel, Tom 14:10, Jerry 12:12/13:45/14:32 und mehr; Perikles Stand zum Marktstart 27.10. 7:30 über `lauf.py`. Nachfolger: Ford – Betriebsleiter.

**Nächste freie Vorgangsnummer: 371** (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef: „Habe Pro gekündigt, steht nur noch auf Free“): Ford-2-Regeln ausgesetzt (`LISTE-FORD2.md`); Guthaben nur Max. **Jerry läuft in der Zentrale** (`LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, Einrichtung aus Git (`LISTE-NIEDERLASSUNG.md` bis `f3ec7200`)

**Ford: Pilot** (seit Sa 17.10., 21:05; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (Übersicht `docs/chefsache/README.md`; https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht: `docs/PRUEFBERICHT.md`

**Sparbetrieb (Chef 23.10., 10:22, Bild: Woche „Alle Modelle“ 100 %, Zurücksetzung Sa 20:59; nur Credits, Guthaben 79,38, Monatslimit unbegrenzt):** „Was angestoßen ist, machen wir fertig, ich prüfe Entwürfe, wir aktualisieren und bauen ein. Dann wird wohl der Spieletest heut bei mir stattfinden.“ Ford startet nur Rückläufer des Chefs und den Build für seinen Spieletest; laufende Sitzungen machen ihren Schritt fertig und übergeben, keine Neustarts ohne Arbeit; Sokrates 318 (20 Uhr) auf So nach 21 Uhr, Auswertung 340 erst nach der Zurücksetzung.

**Guthaben:** **Bild Chef 26.10., 11:43 (an Perikles):** Woche 27 % (Zurücksetzung Sa 31.10., 20:00), Sitzung 12 % (bis 12:00); Hinweis „Limit in der Nacht auf Samstag“. Takt seit 0 % am 25.10., 11:05: 1,1 %/h → 80 % Mi 28.10. ~12, 95 % Do ~02, 100 % Do ~06 (Perikles; Anzeige rechnet langsamer); 287 gilt · **Max 20x seit 25.10., ~11:00** (Bild Chef 11:05, Web): Woche 0 %, Sitzung 0 % (bis 16:00), Zurücksetzung Sa 31.10., 20:00, Nutzungsguthaben 0 $ an; 287 gilt weiter (80/95-%-Regel: ab 80 % `lauf.py --nur-muss`, ab 95 % nur Rückläufer des Chefs, ab 100 % Stillstand, nichts nachkaufen); Monat bis 25.10. 303,02 $ · ältere Bilder (23.–25.10.): Git vor „Perikles: Guthaben 26.10.“

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Ford lebt in einer Sitzung** „Ford – Betriebsleiter (26.10., 16:40)“ `session_01RxjVWgHtAySkDQkjFTYRpN` (seit 26.10., 16:36, Tiefe 5). Stundenuhr „Ford-Lauf“ `trig_01EfPPkDsQ8sZFcxuxjgfDdD` (:03). Alter Ford `session_01AyscMQYxPRGvhJzpxGd5pR` (7,91 $ auf Betrieb gebucht) steht idle: `archive_session` vom Klassifizierer abgelehnt.
- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (D13.2).
- **(ruht, 159)** Ford 2: Stundenuhr aus; Sitzung `session_017VRJsTBwEbU16mwomLknhm`, Uhr `trig_01WCdVmLssvGbjCSK9KJPCPH`; bei Wiedereinschalten neu prüfen.

## Eingang

Anregungen ohne Bereich und Startwünsche (eine Zeile, Datum, Absender). Ford teilt im nächsten Lauf zu oder legt sie dem Chef vor.

- **369 (Ford 26.10.):** Chef 18:46 „nein, Regel steht schon“ (Archiv): Chef archiviert die drei von Hand; Ursache bei Perikles; Ford meldet Perikles den Wortlaut der nächsten Ablehnung.
- **Von Chef über Sokrates (22.10., 22:21):** Build 79 (Tom und Jerry, 317) jetzt bauen, Chef testet heute noch. Danach arbeiten die Teams die Nacht durch weiter, was startbar ist; nicht wegen Guthaben anhalten (Wortlaut: „ob das Guthaben dann morgen Vormittag ausläuft … oder heute Nacht ausläuft … dann kann ich wenigstens den Build noch testen, morgen früh. Den nächsten vielleicht.“).
- **Von Sokrates (22.10., 22:3x, Chef 22:31 „schau dir Jerry 299 an“):** Jerry `session_01HrPPjrdAxzNbvs4JCyqJET` hat um 22:17 die Neustart-Bitte an die alte Ford-Sitzung `01XVKCPG` geschickt (Kennung aus dem Start, Ford seit 22:06 neu), „Ford inaktiv“ gefolgert und den Nachfolger `session_01F6KpuKLxZEqVZe86rVzKWJ` selbst gestartet; arbeitete danach weiter (320). Bitte alte Jerry-Sitzung archivieren; bei Fords Neustart die neue Kennung an laufende Sitzungen melden oder `@parent` meiden (Vorschlag, Perikles entscheidet). **Perikles 23.10., 07:4x:** kein Rundruf; Kennung vor dem Senden frisch lesen (`LISTE-RELEASE-NEUSTART.md` 1a). Offen für Ford: alte Jerry-Sitzung archivieren, dann Zeile streichen.
- **Werkzeugfehler `lauf.py`, an Perikles (Ford 25.10.):** Zahl nach „Godot“, „Runde“, „Lauf“, „Brücke“ zählt nicht mehr als Vorgang (Perikles 26.10.). Offen, Perikles prüft: Doppelbuchung Sokrates alt 7,10 $ auf Betrieb und auf 361/89/362/142.
- **318, von Sokrates (22.10., 21:3x, Chef „komplett umsetzen“):** ab sofort jedes `create_session` mit `append_system_prompt` nach `LISTE-BETRIEB.md` (Zeile „Kennungen“); Antwortstil „Knapp“ steht in `.claude/settings.json`. Zeile nach dem ersten Start mit Anhang streichen.

## Protokoll
Eine Zeile je Lauf mit Tat, neueste oben, höchstens 20 Zeilen; ältere streichen (Verlauf in Git, 117).

- 21:05 25.10.: Neustart Jerry angenommen (35ae76b44 auf main, Nachfolger in Übergabe): Start „Jerry – 348.7 Goblin-Späher Godot 37 (25.10., 21:05)“
- 12:30 25.10.: Neustart Sokrates angenommen (242 Tsd., Übergabe auf main): Start „Sokrates – 252 Webseite“ `session_019bZp2HJbpfC6NHSJd5NASK`; alte archiviert (6,35 $ auf 340.2)
- 12:29 25.10.: Auftrag über Sokrates (Chef 12:24 entschied 348.9): Start „Diogenes – 348.9“ `session_01MB66tbqYyMipmruX982SXv`, „Homer – 348.9“ `session_018G9aKPLrnvQspQVHEm1kLZ` (beide per Lauf), „Perikles – 348.9 Meilenstein Godot“ `session_018Bf1F8yyFZ7K4YQA3nqosD` (von Hand wegen vollem Vorrat, Auftrag in der ersten Nachricht); Perikles 364 (fertig, idle) archiviert (2,41 $ gebucht); Tom Runde 11 läuft schon
- 12:24 25.10.: Neustart Jerry angenommen (193 Tsd., Übergabe auf main): Start „Jerry – 348.7 Kampfort Godot 21“ `session_019gtGXEkcAqe8a4XHYfQoKz`; alte archiviert (5,68 $ auf 348.7)
- 12:18 25.10.: Neustart Tom angenommen (203 Tsd., Übergabe auf main): Start „Tom – 348.6 Runde 11“ `session_01X3N8kVd6Kbvfrs1VdKQ4Dp`; alte archiviert (6,50 $ auf 348.6)
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
- 12:27 25.10.: Startsperre 12:27 Start Diogenes, Homer (lauf.py)
- 16:53 25.10.: Nachfolger-Warnung Diogenes (Übergabe 25.10., 16:30) (lauf.py)
- 16:53 25.10.: Nachfolger-Warnung Homer (Übergabe 25.10., 13:30) (lauf.py)
- 16:53 25.10.: Startsperre 16:53 Start Tom, Jerry (lauf.py)
- 17:21 25.10.: Startsperre 17:21 Start Tom (lauf.py)
- 17:25 25.10.: Startsperre 17:25 Start Jerry (lauf.py)
- 17:45 25.10.: Startsperre 17:45 Start Tom (lauf.py)
- 17:46 25.10.: Startsperre 17:46 Start Jerry (lauf.py)
- 18:13 25.10.: Startsperre 18:13 Start Jerry (lauf.py)
- 18:36 25.10.: Startsperre 18:36 Start Jerry (lauf.py)
- 18:42 25.10.: Startsperre 18:42 Start Tom, Homer (lauf.py)
- 18:42 25.10.: Marke Archiv session_01ALTocmozNXduAEAmoW2i7j (lauf.py)
- 18:56 25.10.: Startsperre 18:56 Start Diogenes (lauf.py)
- 18:56 25.10.: Marke Archiv session_019QEpVzCgLNC9i971rFHxWT (lauf.py)
- 19:03 25.10.: Marke Mehrfach Sokrates (lauf.py)
- 19:05 25.10.: Startsperre 19:05 Start Jerry (lauf.py)
- 19:44 25.10.: Startsperre 19:44 Start Jerry, Homer (lauf.py)
- 19:44 25.10.: Marke Mehrfach-Warnung Sokrates session_014Wejb8FbHS3oiaSLEPJe4p (lauf.py)
- 19:44 25.10.: Marke Mehrfach Sokrates (lauf.py)
- 19:44 25.10.: Marke Archiv session_011Nkem1w8gQKWoqQWdvKrky (lauf.py)
- 19:44 25.10.: Nachfolger-Warnung Diogenes (Übergabe 25.10., 19:09) (lauf.py)
- 19:44 25.10.: Nachfolger-Warnung Homer (Übergabe 25.10., 19:02) (lauf.py)
- 19:59 25.10.: Startsperre 19:59 Start Tom (lauf.py)
- 20:14 25.10.: Startsperre 20:14 Start Jerry (lauf.py)
- 20:37 25.10.: Startsperre 20:37 Start Jerry (lauf.py)
- 07:04 26.10.: Startsperre 07:04 Start Perikles (lauf.py)
- 07:04 26.10.: Marke Abgleich Vorentscheid 348.6 ohne Datei in chefsache/billigen/ und ohn (lauf.py)
- 07:04 26.10.: Marke Abgleich Vorentscheid-Bremse (194.1): 8 ungebilligt, 0 älter als 7 Ta (lauf.py)
- 07:04 26.10.: Nachfolger-Warnung Jerry (Übergabe 26.10., 06:09) (lauf.py)
- 07:04 26.10.: Nachfolger-Warnung Diogenes (Übergabe 26.10., 03:29) (lauf.py)
- 07:04 26.10.: Nachfolger-Warnung Homer (Übergabe 25.10., 23:40) (lauf.py)
- 13:20 26.10.: Startsperre 13:20 Start Homer, Perikles (lauf.py)
- 13:20 26.10.: Marke Wochenstart 26.10. Perikles (lauf.py)
- 13:20 26.10.: Marke Wochenstart 26.10. Diogenes (lauf.py)
- 13:20 26.10.: Marke Abgleich Vorentscheid 348.7 ohne Datei in chefsache/billigen/ und ohn (lauf.py)
- 13:20 26.10.: Marke Abgleich Vorentscheid 348.7 ohne Datei in chefsache/billigen/ und ohn (lauf.py)
- 13:20 26.10.: Marke Abgleich Vorentscheid 348.7 ohne Datei in chefsache/billigen/ und ohn (lauf.py)
- 13:20 26.10.: Marke Abgleich Vorentscheid 348.7 ohne Datei in chefsache/billigen/ und ohn (lauf.py)
- 13:20 26.10.: Marke Abgleich Vorentscheid 348.7 ohne Datei in chefsache/billigen/ und ohn (lauf.py)
- 13:20 26.10.: Marke Abgleich Vorentscheid 348.7 ohne Datei in chefsache/billigen/ und ohn (lauf.py)
- 13:20 26.10.: Nachfolger-Warnung Diogenes (Übergabe 26.10., 12:59) (lauf.py)
- 17:08 26.10.: Startsperre 17:08 Start Homer, Perikles (lauf.py)
- 17:08 26.10.: Marke Archiv session_014acpRTD2zqs5v5gG2FPKZa (lauf.py)
- 17:08 26.10.: Marke Archiv session_01VZXaQiuXmQD89uCD1tVnz6 (lauf.py)
- 17:08 26.10.: Marke Archiv session_017XDYAMk2XGjr9uKDP9iZHq (lauf.py)
- 17:08 26.10.: Marke Archiv session_01GC1Ue16aB26wjCPzdBh74X (lauf.py)
- 17:08 26.10.: Marke Archiv session_01Twr8DKumpNBQFzjt1faRwK (lauf.py)
- 17:08 26.10.: Marke Archiv session_01Fntj2e4N2uaSrBSdjEPSUm (lauf.py)
- 17:08 26.10.: Nachfolger-Warnung Diogenes (Übergabe 26.10., 15:19) (lauf.py)
- 17:08 26.10.: Nachfolger-Warnung Homer (Übergabe 26.10., 13:30) (lauf.py)
- 18:04 26.10.: Startsperre 18:04 Start Perikles (lauf.py)
- 18:04 26.10.: Marke Stellungnahme Sokrates 26.10. (lauf.py)
- 18:04 26.10.: Marke Archiv-Warnung session_01Twr8DKumpNBQFzjt1faRwK (lauf.py)
- 18:04 26.10.: Marke Archiv session_018GuUHApUmyWeHtvE7fKgKa (lauf.py)
- 18:04 26.10.: Marke Archiv session_01C3n2kdSsuAiAjyC2GD1nya (lauf.py)
- 18:04 26.10.: Marke Archiv session_017QLcyf7WWRHPSqk5SnFsR3 (lauf.py)
- 18:04 26.10.: Marke Archiv session_01QHGWL2DcVp789G3ipi4wqq (lauf.py)
- 19:04 26.10.: Startsperre 19:04 Start Perikles (lauf.py)
- 19:04 26.10.: Marke Archiv session_01JH1i2rwb36CzFSxfvReq6f (lauf.py)
- 19:04 26.10.: Marke Archiv session_01Lst3MYNyzGL4SM1JXMLZu9 (lauf.py)
- 19:04 26.10.: Marke Archiv session_015DumnbusHh8mGLi1rjqfnt (lauf.py)
- 19:04 26.10.: Marke Archiv session_01Gh9rnpMGBPr3ipFHLQkMFS (lauf.py)
- 19:04 26.10.: Nachfolger-Warnung Homer (Übergabe 26.10., 17:18) (lauf.py)
