# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Nächste freie Vorgangsnummer: 134** (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Sparmodus bis Sa 17.10., 21:00** (99d, `FIRMA.md` „Sparmodus“), **ausgesetzt Sa 17.10. 09:08–11:00 für die Zentrale** (Chef 17.10., 09:08: „Weck mal den Betrie bis auf die Niederlassung auf und lass mal probeweise alle so arbeiten, wie es sein soll. Ab 11100 Uhr gehst du wieder in den Sparmodus und lässt aktive Arbeitssitzungen ausklingen.“; „11100“ gelesen als 11:00): Ford Pilot, Starts nach Vorrang; ab 11:00 keine Starts, laufende Sitzungen beenden ihren Punkt

**Ford: Co-Pilot bis Sa 17.10., 21:00, danach Pilot** (Chef 15.10., 22:5x: „dann kriegt Ford die Stellung Co-Pilot … wieder zurückstellen … wenn wir wieder volles Guthaben haben“; der erste Lauf danach stellt selbst auf Pilot zurück, pusht, meldet lautlos; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (108; Übersicht = `docs/chefsache/README.md`, zeigt GitHub unter der Dateiliste; Lesezeichen für den Chef: https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht Diogenes: `docs/PRUEFBERICHT.md`

**Guthaben:** Max 91 % (Wechsel Sa 17.10. etwa 21:00, Sitzungslimit 8 %), Pro 49 % (Woche), 16.10., 21:2x (Bilder des Chefs über Perikles; Pro-Sitzungslimit voll bis etwa 23:30). Bis zum Max-Wechsel nur Laufendes zu Ende, keine neuen Starts in der Zentrale außer auf Zuruf des Chefs; Max 100 % vorher = Stillstand „Guthaben“ (128), kein Ausfall

**Jetzt installieren:** nichts. 0.1.750 abgenommen und auf `main` (PR #65, 15.10., 16:5x).

- **Ford lebt in einer Sitzung** „Ford – Betriebsleiter (17.10., 01:04)“ `session_01EshK4EhbFrGSCR6qeh3VYn` (seit 17.10., 01:04, Selbstneustart, Tiefe 6: kein weiterer Selbstneustart; Vorgänger `session_01XWRdGrGASFYbx6MMqjVV6Y` archiviert). Stundenuhr „Ford-Lauf“ `trig_01Y44JZv22h4mpFANruNYxH3` (:03, seit 01:04; alte Uhr `trig_01MHvLjkYXRb7JKbtriztn6a` gelöscht).
- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (seit 16.10., 21:19; 15.10., 22:5x zurückgeholt, D13.2).
- **Ford 2** (Pro) lebt in einer Sitzung „Ford 2 – Niederlassungsleiter (17.10., 03:34)“ `session_01Bgr3YihKQVLNAM59U56Cva` (seit 17.10., 03:34; Vorgänger `session_017Gzi9LijVCMaW5UJrzYaXZ` archiviert, 9,87 $). Stundenuhr „Ford-2-Stundenuhr“ `trig_01JVENqEgw8TKsZQXrJKHQn5` (:33, seit 03:34). Telegram auf Pro geht (Probe 06:43). Lehre: der Weiter-Haken lässt Jerry nach der Übergabe weiterarbeiten; vor dem Archivieren „nichts Neues anfangen“ schicken, sofort archivieren. Jerry pausiert bis Mo 19.10., 21:00; bis dahin Läufe ohne Tat, nichts schreiben. In der Sitzung nur „Ford 2 HH:MM ok“.

## Eingang

Anregungen ohne Bereich und Startwünsche (eine Zeile, Datum, Absender). Ford teilt im nächsten Lauf zu oder legt sie dem Chef vor.

- 17.10., 09:3x, von Perikles (99h, Zuruf Chef): Messung Leitung 20.10., 00:00 – 21.10., 24:00: Ford und Ford 2 tragen beim eigenen Neustart und am Ende der Messung ihre `cost_usd` in die Zeile „Betrieb“ von `LISTE-VORGAENGE.md` ein, getrennt „Ford x $ · Ford 2 y $“; Auswertung Perikles 22.10.
- 17.10., 00:0x, von Tom (62078f62): Nachfolger „Tom – 117 Verweise im Code“ erst nach Sa 17.10., 21:00 oder auf Zuruf starten (vorher #100 zusammenführen, Build 13 passt), dann Zeile streichen

## Kosten Ford 2

Messung abgeschlossen 16.10. (99f); Auswertung Perikles. Ab 17.10. erfassen Ford und Ford 2 Kosten je Vorgang in `LISTE-VORGAENGE.md` (124), hier keine neuen Zeilen.

- 16.10., 23:32: Pro-Sperre 21:30–23:30 (Jerry D3 Kampfgeheul bis dahin 3,12 $); Ford 2 ohne Neustart weiter, ca. 220 Tsd. Token Kontext
- 16.10., 20:40: Neustart Jerry D3 Kampfgeheul, Vorgänger (86) Kosten nicht ermittelbar; Pro meldet jetzt `five_hour` `allowed_warning` (zurück um 23:30)
- 16.10., 20:34: Stundenlauf ohne Tat (Jerry 86 seit 20:32); Ford 2 seit 18:34 3,53 $, 203 Tsd. Token Kontext, sieben Neustarts Jerry eingeschlossen; Pro weiter `allowed_warning`
- 16.10., 20:33: Neustart Jerry 86, Vorgänger (39) Kosten nicht ermittelbar (`get_session` ohne `usage`)
- 16.10., 19:56: Neustart Jerry 39, Vorgänger (Build 10, 59e) Kosten nicht ermittelbar (`get_session` ohne `usage`)
- 16.10., 19:46: Neustart Jerry 59e, Vorgänger (D3.8/D3.9) 6,25 $ (`usage.cost_usd`, 266 Tsd. Token Kontext); Build 10 wartet auf Chef, Meldung laut
- 16.10., 19:33: Stundenlauf ohne Tat (Jerry D3.8/D3.9 läuft); Ford 2 seit 18:34 2,08 $, 154 Tsd. Token Kontext, vier Neustarts Jerry eingeschlossen; Pro weiter `allowed_warning`
- 16.10., 19:29: Neustart Jerry D3.8/D3.9, Vorgänger (D3 Rest) Kosten nicht ermittelbar (`get_session` ohne `usage`); D3.10 Build 9 wartet auf Chef, Meldung laut
- 16.10., 19:17: Neustart Jerry D3 Rest, Vorgänger (24aa) 0,72 $ (`usage.cost_usd`, 99 Tsd. Token Kontext)
- 16.10., 19:16: Neustart Jerry 24aa, Vorgänger (120 prüfen) 2,49 $ (`usage.cost_usd`, 159 Tsd. Token Kontext); 120 wartet auf Chef, Meldung laut
- 16.10., 18:57: Neustart Jerry 120, Vorgänger (72.10 Bild prüfen) 4,83 $ (`usage.cost_usd`, 203 Tsd. Token Kontext)
- 16.10., 18:38: Neustart Jerry 72.10, Vorgänger 7,21 $ (`usage.cost_usd`, 254 Tsd. Token Kontext)
- 16.10., 18:36: Selbstneustart Ford 2; Vorgänger 5,81 $ (`usage.cost_usd`, 253 Tsd. Token Kontext); Jerry 72.10 läuft wieder
- 16.10., 18:34: Läufe 16:33/17:33 in der Pro-Sperre (zugestellt 18:33); Jerry 72.10 geweckt; Jerry 72.10 bisher 4,68 $; Selbstneustart Ford 2
- 16.10., 15:55: Neustart Jerry 72.10; Jerry 108a nach main kostete 1,62 $ (4 Minuten; Freigabeprüfung sperrte, 108a.1)
- 16.10., 15:51: Neustart Jerry 108a nach main; Jerry D1.14 kostete 4,09 $ (220 Tsd. Token Kontext)
- 16.10., 15:34: Stundenlauf ohne Tat (Jerry läuft, D1.14); Ford 2 seit 14:06 fünf Starts, 185 Tsd. Token Kontext; Pro weiter `allowed_warning`
- 16.10., 15:19: Neustart Jerry D1.14; Jerry 120 kostete 4,18 $ (211 Tsd. Token Kontext)
- 16.10., 14:58: Neustart Jerry 120; Jerry 18 kostete 2,10 $ (147 Tsd. Token Kontext); Weckruf trig_01GvuBVi… war schon weg
- 16.10., 14:42: Neustart Jerry 18; Jerry 108a kostete 4,99 $ (257 Tsd. Token Kontext)
- 16.10., 14:33: Stundenlauf ohne Tat (Jerry läuft, 108a, Sammelbuild 1 PR #88); Ford 2 seit 14:06 zwei Starts, Pro weiter `allowed_warning`
- 16.10., 14:20: Neustart Jerry 108a; Jerry 120 kostete 4,14 $ (216 Tsd. Token Kontext)
- 16.10., 14:08: Selbstneustart Ford 2; Vorgänger 9,20 $ (`usage.cost_usd`, 356 Tsd. Token Kontext)
- 16.10., 14:06: Neustart Jerry Idee 10; Jerry Raumklang kostete 4,38 $; Pro-Wochengrenze jetzt `allowed_warning`; 33 alte Pro-Sitzungen (8.–12.10.) auf Zuruf des Chefs archiviert
- 16.10., 13:45: Neustart Jerry Raumklang; Jerry 18 kostete 8,15 $ (326 Tsd. Token Kontext, über die Pro-Sperre hinweg)
- 16.10., 13:35: Läufe 11:33/12:33 fielen in die Pro-Sperre (zugestellt 13:34); Jerry 18 stand seit 10:36 („session limit“), geweckt statt neu gestartet; Ford 2 Tiefe 1
- 16.10., 10:34: Stundenlauf ohne Tat (Jerry läuft, 18); Ford 2 seit 08:48 4,38 $, 220 Tsd. Token Kontext, acht Neustarts Jerry eingeschlossen; Pro weiter `allowed_warning`
- 16.10., 10:26: Neustart Jerry 18; Jerry 30 kostete 2,38 $; Pro-Fünfstundengrenze meldet `allowed_warning` (Rücksetzung 13:20)
- 16.10., 10:19: Neustart Jerry 30; Jerry 53 kostete 3,87 $
- 16.10., 10:06: Neustart Jerry 53; Jerry 36.6: kein `usage` beim Archivieren; dessen Wecker „Jerry 36.6 Neustart prüfen“ gelöscht (Nachfolger läuft)
- 16.10., 09:41: Neustart Jerry 36.6; Jerry 51 kostete 3,29 $
- 16.10., 09:34: Stundenlauf ohne Tat (Jerry läuft, 51); Ford 2 (neue Sitzung seit 08:48) 2,48 $, 149 Tsd. Token Kontext, vier Neustarts Jerry eingeschlossen
- 16.10., 09:30: Neustart Jerry 51; Jerry 69c.1: `archive_session` lieferte kein `usage`, Kosten nicht ermittelbar
- 16.10., 09:18: Neustart Jerry 69c.1; Jerry 69c kostete 3,80 $
- 16.10., 09:05: Neustart Jerry 69c; Jerry 86.9 kostete 2,15 $
- 16.10., 08:59: Neustart Jerry 86.9; Jerry D6.4 kostete 3,90 $ (`usage.cost_usd` aus der Antwort von `archive_session`; späteres `get_session` liefert es nicht)
- 16.10., 08:49: Selbstneustart Ford 2; Vorgänger 5,52 $ (`usage.cost_usd`, 272 Tsd. Token Kontext); Jerry 84 und Jerry D3: `get_session` liefert nach dem Archivieren kein `usage`, Kosten nicht ermittelbar
- 16.10., 06:46: Einrichtung plus ein Start; ca. 127 Tsd. Token Kontext (`get_session` meldet `used_tokens` 0, Messung daher aus dem Sitzungszähler); Jerry D1.7 kostete 0,89 $, Jerry 72u 6,71 $, Jerry 95 4,25 $, Jerry 38 4,71 $, Jerry 40 4,16 $ (`usage.cost_usd` nach dem Archivieren; Jerrys Kosten, nicht Ford 2)
- 16.10., 08:33: Stundenlauf ohne Tat (Jerry läuft, 84); Ford 2 bisher ca. 245 Tsd. Token Kontext, sechs Starts Jerry eingeschlossen
- 16.10., 07:33: Stundenlauf ohne Tat (Jerry läuft); Ford 2 bisher ca. 185 Tsd. Token Kontext, drei Neustarts Jerry eingeschlossen

## Protokoll

Eine Zeile je Lauf mit Tat, neueste oben, höchstens 20 Zeilen; ältere streichen (Verlauf in Git, 117).

- 09:32 17.10.: Tom D23.2 bestätigt (c4a37c55), Zeile an Homer, archiviert (Kosten fehlt); Startsperre: 09:32 Start Tom (132 Spieldauer im Spielstand)
- 09:29 17.10.: Tom 13e fertig (7d811ddd), archiviert, 2,75 $ auf 13e; Startsperre: 09:29 Start Tom (D23 Garricks Hinweis, Kür, kein Muss startbar)
- 09:26 17.10.: Zuruf Chef an Perikles (09:2x): „Aufgaben Jerry für Testlauf hier für Probebetrieb bis 1100 mitübernehmen.“ → Startsperre: 09:26 Start Tom 2 (Übernahme Jerry D21, oberste startbare Zeile ohne Gerätetest)
- 09:10 17.10.: Perikles 106.1 Vermerke fertig (1e955644), archiviert, 0,88 $ auf 106; Nachfolger Tagesrückblick erst ab 18.10.; Startsperre: 09:10 Start Perikles (oberste startbare Kür, kein Muss startbar)
- 09:08 17.10.: Probebetrieb Zentrale bis 11:00 (Zuruf Chef); 112a damit erledigt (Homer jetzt); Startsperre: 09:08 Start Homer (112), 09:08 Start Perikles (106.1 Vermerke, dann Tagesrückblick), 09:08 Start Tom (13e), 09:08 Start Diogenes (38 D4.1 neu messen)
- 09:04 17.10.: Morgenmeldung laut (mit Bild-Bitte)
- 03:35 17.10.: Ford 2 neu (Selbstneustart), Uhr trig_01JVENqEgw8TKsZQXrJKHQn5, alte Uhr gelöscht, Vorgänger archiviert (9,87 $, 315 Tsd. Token) (Ford 2)
- 02:05 17.10.: Tom „Builds 8–13 nach main“ fertig (#101), archiviert, 2,87 $ zu gleichen Teilen auf 72.10, 86, D3, 129; Nachfolger 117 nach Sparmodus; sonst nichts
- 01:12 17.10.: Chef zu 129a: nur Hühner erledigt, 68 und 26 offen → Vorgangsarchiv, Toms 129, Datei gelöscht
- 01:06 17.10.: Idee Chef → 132 (Spieldauer im Spielstand, vierter Spielstand) an Tom (K, prüfen)
- 01:05 17.10.: Ford neu übernommen; Uhr trig_01Y44JZv22h4mpFANruNYxH3 angelegt und geprüft, alte Uhr trig_01MHvLjkYXRb7JKbtriztn6a gelöscht, alter Ford session_01XWRdGrGASFYbx6MMqjVV6Y archiviert ($3,96)
- 01:04 17.10.: Selbstneustart Ford (Haken-Erinnerung 2, ≈217 Tsd. Token) → session_01EshK4E… (Tiefe 6, kein weiterer Selbstneustart); Lauf: Tom Builds nach main läuft, sonst nichts
- 01:00 17.10.: Start Tom (Builds 8, 11, 12, 13 nach main: #68, #98, #99, #100; Zuruf Chef 01:00: „Tom, Builds nach main“)
- 01:00 17.10.: Chef: Build 13 passt (wörtlich in Toms 129); Rückfrage 129a (68, 26 mitgemeint?)
- 00:51 17.10.: Chef: Build 12 passt (wörtlich in Jerrys D3)
- 00:41 17.10.: Chef: Build 11 passt (wörtlich in Jerrys 86); 131 Laufen/Ausdauer bei Sokrates angelegt
- 00:35 17.10.: Chef: Build 8 passt (wörtlich in Jerrys 72.10); 130 Kampfgefühl (8.5) bei Sokrates angelegt
- 00:22 17.10.: Perikles 99g.2 fertig (5af1dd15), archiviert (3,48 $ auf 99); Nachfolger in den Eingang
- 00:17 17.10.: Start Perikles (99g.2 Kopf abgelöst; Zuruf Chef 00:17: „Perikles“, trotz Sparmodus)
- 00:02 17.10.: Tom 129 fertig (62078f62, PR #100, Build 13 zu testen; D21 erledigt), archiviert (4,17 $, je etwa 2,08 $ auf 129 und D21); Nachfolger in den Eingang
- 23:43 16.10.: Start Tom (129 Hühner; Zuruf Chef 23:43: „Tom“, trotz Sparmodus)
- 23:33 16.10.: Chef-Meldung Hühner auf gleichem Platz → 129 in Toms Vorrat (K)
- 23:41 16.10.: Jerry D3 Kampfgeheul fertig (PR #99, Build 12), archiviert; Pause bis Mo 19.10., 21:00, kein Nachfolger (Ford 2)
- 23:32 16.10.: Läufe 21:33/22:33 in der Pro-Sperre; Jerry D3 Kampfgeheul geweckt, soll Punkt beenden, danach Pause bis Mo 19.10., 21:00 (Ford 2)
- 23:10 16.10.: Ford neu (session_01XWRdGr…, Tiefe 5); Uhr trig_01MHvLjkYXRb7JKbtriztn6a angelegt und geprüft, alte Uhr trig_013eNWtEGr7bAJCFxhGY5WHk gelöscht, alter Ford session_01B3GyS2… archiviert (4,59 $)
- 23:10 16.10.: Perikles 106.1a fertig (57241d3d), archiviert (2,81 $, je 1,40 $ auf 106 und 99); Nachfolger in den Eingang. Selbstneustart Ford (Haken-Erinnerung 2, ≈231 Tsd. Token); offen: nur Ford 2/Jerry laut Besetzung, Eingang (Tom D21, Perikles 99g.2) nach Sa 21:00; Morgenmeldung Sa 9 Uhr
- 23:04 16.10.: Lauf: Diogenes 106.1 fertig, archiviert (5,31 $ auf 106); Perikles 106.1a läuft. Stillstand eingeteilt (Sparmodus Max bis Sa 21:00): Tom (Muss 4, A 1), Homer (Muss 2), keine Starts ohne Zuruf
- 22:55 16.10.: Start Perikles (106.1a, D22.1 zuerst; Chef 22:4x: „106.1a ja“; Auftrag von Diogenes, e5cacf45)
- 22:33 16.10.: Umbau 106.1 auf main (b37fff95), Perikles archiviert (10,75 $); Start Diogenes 106.1
- 22:2x 16.10.: Start Perikles – Umbau Rollen und Namen (vorgezogen von Sa 21:15; Chef 16.10., 22:2x: „Lege los! Godspeed.“ (100 $ Extra-Guthaben)); Vorgabe: ein Push am Ende; danach Diogenes Nachprüfung
