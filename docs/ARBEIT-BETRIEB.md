# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Nächste freie Vorgangsnummer: 185** (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef 17.10., 19:5x: „Habe Pro gekündigt, steht nur noch auf Free“): solange diese Zeile steht, sind alle Ford-2-Regeln ausgesetzt (`LISTE-BETRIEB.md` „Ford 2“ und „Lauf von Ford 2“, „stiller Ausfall“, 10-%-Regel, Messung Ford 2 20.–21.10.); Guthaben und Nutzungsbild nur Max. **Jerry läuft in der Zentrale** (Ford startet ihn, `LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, dann `LISTE-NIEDERLASSUNG.md`

**Sparmodus beendet Sa 17.10., 21:00** (Max-Wechsel; 99d)

**Ford: Pilot** (seit Sa 17.10., 21:05; zuvor Co-Pilot bis 21:00, Chef 15.10., 22:5x; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (108; Übersicht = `docs/chefsache/README.md`, zeigt GitHub unter der Dateiliste; Lesezeichen für den Chef: https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht Diogenes: `docs/PRUEFBERICHT.md`

**Guthaben:** Max 5 % Woche (Zurücksetzung Sa 21:00), Sitzung 5 % (Zurücksetzung 17:00), Fable-Woche 0 %; Nutzungsguthaben an, 95,69 $ verbleibend, 4,31 $ diesen Monat ausgegeben, kein Ausgabenlimit (Bild Chef 18.10., 12:5x); Max 100 % = Stillstand „Guthaben“ (128), kein Ausfall (Verlauf in Git)

**Jetzt installieren:** Release 0.1.827 (131 + D23.2, PR #104; Testaufgaben t16); 0.1.827 auf `main`.

- **Ford lebt in einer Sitzung** „Ford – Betriebsleiter (18.10., 16:38)“ `session_012MDWDdi1a25NYMeFmLCtDu` (seit 18.10., 16:36, sonnet, Tiefe 5; Selbstneustart bei über 150 Tsd. Token, ab Tiefe 6 Chef bitten; Vorgänger archiviert, 1,41 $ erfasst). Stundenuhr „Ford-Lauf“ `trig_01Sck61vd5yKcyi3DcfrHa6z` (:03, seit 18.10., 16:37; alte Uhr gelöscht). Selbstneustart bis Tiefe 5 (110).
- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (seit 16.10., 21:19; 15.10., 22:5x zurückgeholt, D13.2).
- **(ruht, 159)** Ford 2: Stundenuhr aus, Regeln `LISTE-BETRIEB.md` „Lauf von Ford 2“ (Verlauf in Git).
- **(ruht, 159)** Ford 2 (Pro): Sitzung `session_017VRJsTBwEbU16mwomLknhm`, Uhr `trig_01WCdVmLssvGbjCSK9KJPCPH`; bei Wiedereinschalten neu prüfen.

## Eingang

Anregungen ohne Bereich und Startwünsche (eine Zeile, Datum, Absender). Ford teilt im nächsten Lauf zu oder legt sie dem Chef vor.

- 18.10., 11:1x, von Sokrates (167.6, Chef): Sitzung „Sokrates – Werkzeuge statt Sitzungen“ `session_01RQqCXxXZqPqJVuRnifwazJ` **nicht archivieren vor Mo 19.10., 07:30**: sie schreibt um 06:15 per Wecker den einmaligen Morgenbericht 19.10. (Dokumentwerkzeug nur dort); danach Zeile streichen
- 18.10., 13:2x, von Perikles (167.2, Antwort auf Fords Befund): erledigt, `lauf.py`/`kosten.py` nehmen jetzt eine Kurzzeile je Sitzung (`LISTE-BETRIEB.md` Schritt 3); beim nächsten Lauf benutzen, Fehler im Werkzeug melden
- 18.10., 10:4x, von Perikles (167.5, Chef): `tools/kosten.py` gebaut. Dein Lauf holt alle Seiten von `list_sessions` (`after_id`, `has_more`), speichert sie in Dateien im Scratchpad, ruft `python3 tools/kosten.py <Dateien>` und meldet Anteil Spiel in der Morgenmeldung; Handeinträge der Kosten in `LISTE-VORGAENGE.md` entfallen, wenn die Zahlen vollständig sind.
- 17.10., 22:4x, von Tom (162, Chef, Wortlaut): „Und eigentlich sollte das Ford alles klären, damit hier die Leute was zu tun haben.“ Bezug 139 (Tom wartet auf Homer). Vorschlag Tom: im Lauf je Team ohne Startbares prüfen, auf welche Zeile eines anderen es wartet, und diese anstoßen oder starten; Regel fasst Perikles (162)
- 17.10., 09:3x, von Perikles (99h, Zuruf Chef): Messung Leitung 20.10., 00:00 – 21.10., 24:00: Ford trägt beim eigenen Neustart und am Ende der Messung seine `cost_usd` in die Zeile „Betrieb“ von `LISTE-VORGAENGE.md` ein („Ford x $“; Ford 2 entfällt, solange die Niederlassung ruht, 159); Auswertung Perikles 22.10.
- 17.10., 00:0x, von Tom (62078f62): Nachfolger „Tom – 117 Verweise im Code“ erst nach Sa 17.10., 21:00 oder auf Zuruf starten (vorher #100 zusammenführen, Build 13 passt), dann Zeile streichen

## Protokoll
Eine Zeile je Lauf mit Tat, neueste oben, höchstens 20 Zeilen; ältere streichen (Verlauf in Git, 117).

- 14:43 18.10.: Neustart Tom fc4f2ee3 (Übergabe ok) → Start „Tom – 173 Met nach „zu viel geschlafen“ (18.10., 14:42)“ `session_01EWxiHaueyBeU8vcVi2mGw2`; Vorgänger archiviert, 1,23 $ auf 84.5
- 14:41 18.10.: Startsperre 14:41 Start Tom 173 (Neustart auf Meldung fc4f2ee3)
- 14:35 18.10.: Selbstneustart abgeschlossen (Uhr neu, alte gelöscht, Vorgänger archiviert, 1,35 $ auf Betrieb); die vier offenen Sitzungen (Perikles 169, 167.8, 143, Tom 114) ließen sich diesmal archivieren, Kosten 2,48/3,23/1,52/5,39 $ (kumuliert) eingetragen
- 14:31 18.10.: Selbstneustart Ford (186 Tsd. Token) → Start „Ford – Betriebsleiter (18.10., 14:31)“, Tiefe 2; offen für den Nachfolger: 4 nicht archivierte Sitzungen (siehe Zeile 14:06), Perikles 169 `session_01VrzfAacCJttsBBXRZVnjpP` prüfen
- 14:30 18.10.: Neustart Tom 494045f8 (Übergabe ok, auf main) → Start „Tom – 84.1/84.5 Build und Prüfliste (18.10., 14:30)“; Vorgänger archiviert, 8,44 $ auf 84.5
- 14:06 18.10.: Lauf 14:03: 23 fertige Sitzungen archiviert, Kosten eingetragen (fehlt: 72.10a.T, 72.10a.7, 134.2); Start Perikles 169 `session_01VrzfAacCJttsBBXRZVnjpP`. NICHT archiviert (Archivierung vom Berechtigungsprüfer verweigert): Perikles 169 `session_01VmwtQQamQbWpYy1LRMw8uj`, 167.8 `session_014AEdSXt5nPutSPNFAE8cVC`, 143 `session_01AmAx3KweorYfrWETsfopF9`, Tom 114 `session_01GDKhovGVHVtKvCzXLyP2XN`; Kosten dort offen. Zweifel an Start Perikles 169: Vorgänger meldete 169 „bis auf Archivierung LISTE-VORGAENGE erledigt“
- 13:58 18.10.: Neustart Tom b6a7a7ce (Übergabe ok, auf main) → Start „Tom – 84.5 Lichttrank mit Fackel (18.10., 13:58)“; Vorgänger archiviert, Kosten fehlt (170, 171)
- 13:45 18.10.: Selbstneustart abgeschlossen: Uhr `trig_01U6ffRSDCwgWdkqneKWafSx`, alte gelöscht, Vorgänger archiviert, 1,72 $ auf Betrieb
- 13:47 18.10.: Chef: „110 damit erledigt. Wechsel auf Sonnet!“ → Selbstneustart Ford auf sonnet, Mittel (Tiefe 1); neuer Ford übernimmt Uhr `trig_01YX5A7ufr1x8kfSx8NXbjGw` (löschen, eigene anlegen) und archiviert `session_0123vjnDfdTkTv2nqxitYKrm`
- 13:43 18.10.: Lauf mit `lauf.py` (Kurzzeilen, 167.2; Seiten bis 15.10. geholt, ältere nicht): Jerry 72.10a.8 (1,25 $), Perikles 169 (1,04 $) fertig, archiviert; Start Perikles `session_01EXkFZ41BNwKxWXT9h1zDai` (169), Jerry `session_011hqGLVvsgoy887svBaZi7J` (130.2a Kür). Zweifel an Perikles: 130.2a steht „gebaut, im nächsten Build“, Vorgänger meldete „nichts baubar“ → startbar zählt „gebaut“ als startbar
- 13:41 18.10.: Ford von Hand neu (110, Tiefe 0): neue Uhr, alte gelöscht, Vorgänger archiviert, 4,33 $ auf Betrieb; Chefsache 110 erledigt, Datei gelöscht
- 10:58 18.10.: Lauf auf Zuruf Perikles (167.7): Startsperre 10:58 Start Diogenes (167 Muss); Perikles läuft; Jerry 130.2/72.10a.T, Tom 62c nicht gestartet (Stand unklar/Kür, Prüfung 166.2); `kosten.py` noch nicht gelaufen
- 10:06 18.10.: Startsperre 10:06 Start Perikles (166.2 Muss, 167 Vorabprüfung); Homer 114 (0,56 $), Jerry (0,78 $), Diogenes 166.1 (0,62 $) fertig, archiviert; Tom/Jerry-Marken aus startbar.py unecht (166.2)
- 09:15 18.10.: Neustart Sokrates 0f2fa4ee (Übergabe ok) → Start `session_01RQqCXxXZqPqJVuRnifwazJ` (opus); Vorgänger archiviert, 5,60 $
- 09:11 18.10.: Gestartet Diogenes `session_01NqUs4xdQVRFz8jeG9iiDJM`, Jerry `session_01SbmX5RiHTUvNGjtdXeigo3`, Homer `session_01QWvSfxaFhv8v85bCqnQAGW`; Vorgänger Homer, Jerry, Perikles archiviert, Kosten auf 72.10a.T, 72.10a.7, 166
- 09:08 18.10.: Lauf mit `startbar.py` (166 Test): Homer, Jerry, Perikles fertig (Homer 2,18 $, Jerry 0,61 $, Perikles 0,57 $, vorerst nicht archiviert). Startsperre 09:08 Start Diogenes (166.1 Muss), Jerry (72.10a.T Kür), Homer (114 Kür). Befund an Perikles: 130.1 (steht „erledigt“), 26 (wartet auf Chef 13.5), 27 (erst mit 84.1) fälschlich startbar; Tom: nichts wirklich startbar
- 08:29 18.10.: Auftrag Sokrates (Chef, Vorgangsarchiv 166): Startsperre 08:29 Start Perikles (166 `tools/startbar.py`, Muss, jetzt des Chefs); Tom nach neuer Regel prüfen, bis `startbar.py` steht von Hand: nichts Startbares (139 Sammelbuild, 68/26 Chef, 134.2 Homer läuft)
- 08:27 18.10.: Start Homer `session_01NPnHfEDibdeJ211fb9MfXD` (opus) und Jerry `session_01AGnkaRLMnVc9FXf1GTfEa1` (sonnet), Mittel; erster Versuch ohne `source_url` (kein Repo) sofort archiviert, 0 $. Lehre: `create_session` immer mit `source_url`
- 08:24 18.10.: Chef: „Keiner hat Aufgaben, macht mal das, fangt damit an.“ Fehler Ford: 72.10a.T (Muss) bei Homer startbar übersehen, Stillstand Homer seit Übergabe 17.10., 22:26, Ursache Fehler. Startsperre 08:24 Start Homer (72.10a.T, dann Aufbereiten Ideenspeicher So); Startsperre 08:24 Start Jerry (72.10a.7/130.3 laut Übergabe, Chef-Zuruf); Tom: nichts Startbares (139 wartet Sammelbuild, 134.2 wartet auf Homer)
- 05:05 18.10.: Selbstneustart Ford (Tiefe 5): neue Uhr, alte gelöscht, Vorgänger archiviert, 0,78 $ auf Betrieb; nichts Startbares
- 21:05 17.10.: Lauf: Pilot gesetzt, Sparmodus vorbei; Diogenes 159 (0,96 $) und Perikles (2,21 $) archiviert, Kosten auf 159–161; 21:06 Start Jerry (Zeile 39, Muss; Tom: 131.1/151–153 warten auf Test t17, kein Muss startbar)
- 20:1x 17.10.: 160 Chef (Wortlaut): „160 alles bleibt so um Repo“ → gelesen als Empfehlung A (alles im Repo lassen, kein Dokument); an Perikles, Sokrates trägt ins Vorgangsarchiv ein
- 20:06 17.10.: Auftrag Diogenes 159 (von Perikles) → Start Diogenes `session_01BwT625woAk6JRDYekGDq65`
- 20:03 17.10.: Neustart Perikles abcc8249 (Übergabe ok, 158 entschieden) → Start „Perikles – 159 Niederlassung ruht“ `session_01CG5fMgY39mPnPxLMEJm29D`; Vorgänger archiviert, 1,26 $ auf 158. Hinweis: rate_limit_info Max „rejected“, Überschreitung an
- 19:04 17.10.: Lauf: Diogenes 158 fertig, archiviert, 0,64 $ auf 158; Perikles wartet auf Chef (Vorlage 158); Sparmodus, kein Start
- 18:35 17.10.: Auftrag Diogenes 158 (von Perikles, Zuruf Chef) → Start Diogenes `session_0125ub7cpD2AJ2frZ2e3poDy`
- 18:33 17.10.: Chef-Zuruf: Start Perikles 158 (Sparmodus, auf Zuruf) `session_01KsucyJdfuaygQrFPCS1aq4`; Diogenes folgt auf „Auftrag Diogenes 158“
- 18:31 17.10.: 157.1 Selbstneustart: Ford auf sonnet (Tiefe 1), neue Uhr, alte gelöscht, Vorgänger archiviert, 1,12 $ auf Betrieb; Sparmodus, kein Start
- 14:05 18.10.: Startsperre 14:05 Start Perikles (lauf.py)
- 15:06 18.10.: Lauf 15:03: Start Jerry 174 `session_01DWb6YomJ2QQnUWMPowyoHr`, Perikles 167.2 `session_01S4rgzXF3wCmJzW3oKP8HPf`; archiviert Jerry 130.2a (0,79 $), Perikles 169 (0,30 $); Homer 144 wartet auf Chef (146), Tom läuft
- 15:04 18.10.: Startsperre 15:04 Start Jerry, Perikles (lauf.py)

- 15:16 18.10.: Selbstneustart Ford (Tiefe 3), neue Uhr, alte gelöscht, Vorgänger idle, Archivieren abgelehnt (Auto-Modus), 1,44 $ auf Betrieb- 15:44 18.10.: Startsperre 15:44 Start Tom (Neustart-Meldung f46cd59f, Nachfolger 176)
- 15:46 18.10.: Neustart Tom 173 → Tom 176 `session_011HptwgX6wKCx5s4xMjHEvM` (Zweig claude/tom-173-met); alter Tom `session_01EWxiHaueyBeU8vcVi2mGw2` idle, nicht archiviert (Archivieren vom Auto-Modus abgelehnt), Kosten stehen offen
- 16:06 18.10.: Lauf 16:03: alter Tom (3,10 $ auf 173) und alter Ford (+0,48 $) sind archiviert (von außen); keine Starts: Tom 176, Jerry 174 (wird fertig), Perikles 167.2 laufen, Homer 144 wartet auf Chef (146)
- 16:14 18.10.: Startsperre 16:14 Start Perikles (Neustart-Meldung e4917d72, Nachfolger Wochenziel)

- 16:13 18.10.: Selbstneustart Ford (Tiefe 4), neue Uhr, alte Uhr und Wecker gelöscht, Vorgänger archiviert, 1,15 $ auf Betrieb
- 16:13 18.10.: Startsperre 16:13 Start Homer (lauf.py)
- 16:15 18.10.: Homer 144 archiviert (2,33 $ auf 144, Frage 146 vom Chef entschieden, kein Hindernis); Start Homer 84.1T `session_01DUUsHPG3ohfKwzLEKRrn1K`. Jerry 174 und Perikles 167.2 noch nicht 20 Min. ruhig, Nachholen 16:33
- 16:18 18.10.: Neustart Homer 84.1T (7e2ae911) → Homer 174.1 `session_016ZLFKiTxkjztswzGBTTx4V`; alter Homer archiviert, 1,03 $ auf 84.1
- 16:19 18.10.: Neustart-Meldung Homer 146 (ce42ec37, auf main, Nachfolger 174.1 ist Kür): kein Start von Hand, lauf.py entscheidet; Sitzung `session_016ZLFKiTxkjztswzGBTTx4V` läuft noch, Archivieren und Kosten (auf 146) im Lauf 16:23
- 16:24 18.10.: Startsperre 16:24 Start Jerry (lauf.py)
- 16:25 18.10.: Jerry 174 archiviert (0,82 $ auf 174); Start Jerry 154 `session_01AA7EASfWSHeD7Z5evFNRdh` (Zuruf Perikles/Chef, Vorgang 178). Homer 146 und Perikles 167.2 noch nicht lange genug ruhig, Archivieren im nächsten Lauf (Wecker 16:33)
- 16:36 18.10.: Lauf (Nachholen): keine Starts, keine Archivierung. Perikles 167.2 hat Hindernis (Chefsache 177), Homer 146 laut lauf.py belegt; beide bleiben bis zum Lauf 17:03
- 16:37 18.10.: Neustart Tom 176 (d35b50b4, Nachfolger 175) → Tom 175 `session_018phvnHP6WDdjK1vPyTokvc`; alter Tom `session_011HptwgX6wKCx5s4xMjHEvM` läuft noch (wartet auf Build 25, PR #115), Archivieren und Kosten (auf 176) im nächsten Lauf, sobald er ruht
- 16:38 18.10.: Selbstneustart Ford angestoßen: Nachfolger `session_012MDWDdi1a25NYMeFmLCtDu` (Tiefe 5) übernimmt Uhr, Archivieren dieser Sitzung und Eintrag oben
- 16:39 18.10.: Selbstneustart Ford abgeschlossen: neue Uhr trig_01Sck61vd5yKcyi3DcfrHa6z, alte gelöscht, Vorgänger archiviert (1,41 $ auf Betrieb), Tiefe 5.
- 16:41 18.10.: Lauf: keine Starts, keine Archivierung (lauf.py: Tom 175, Jerry 154, Homer 146, Perikles Wochenziel belegt; Perikles 167.2 Hindernis Chefsache 177). Alter Tom 176 `session_011HptwgX6wKCx5s4xMjHEvM` ruht, nicht von lauf.py geplant, bleibt bis Build 25 (PR #115); dann archivieren, 6,16 $ auf 176.
- 17:04 18.10.: Startsperre 17:04 Start Perikles (lauf.py)
- 17:06 18.10.: Lauf 17:04: Start Perikles 165 `session_0198graFzHsXkq7kMCbPVsCZ`; archiviert Homer 146 (1,18 $), Perikles Wochenziel (0,49 $ auf 25.10), Perikles 167.2 (2,96 $). Archivieren des alten Tom 176 `session_011HptwgX6wKCx5s4xMjHEvM` (PR #115 gemergt, Build 25 frei, 6,64 $ auf 176) von der Auto-Freigabe abgelehnt, nicht umgangen; Kosten noch nicht gebucht. Jerry 154 ruht, wartet auf Chef (Build 26).
- 17:21 18.10.: Zwischenlauf nach Neustartmeldung Tom 175 (720ce770, Nachfolger Tom – Build 27 nach Test, PR #116): Tom 175 noch `working`, lauf.py startet nichts; Start des Nachfolgers im Lauf nach Ruhe der Sitzung (spätestens 18:03). Perikles 165 und Jerry 154 ruhen, lauf.py archiviert noch nicht.
- 17:26 18.10.: Zwischenlauf: Neustart Jerry 154 gemeldet (40cea674, Nachfolger Jerry – Build 28, PR #117, Weckruf trig_017e3wLiqTwADtaVK4iFqmsK 15:32 UTC); Jerry noch `working`. Tom 175 ruht seit 17:19 (wartet auf Test Build 27), lauf.py führt beide noch als belegt: keine Starts. Nachfolger folgen im Lauf nach der Ruhezeit.
- 17:31 18.10.: Startsperre 17:31 Start Perikles (lauf.py)
- 17:33 18.10.: Lauf: Perikles 165 (0,32 $) archiviert, Neustart `session_01JM2qXBqNpLbp7YchU1BwnK` (Plan von lauf.py; Zweifel: Tag 1 war erledigt, Bilanz 23.10., Start wohl überflüssig, lautlos an Perikles). Tom 175 `working` trotz Neustartmeldung 414415be (Nachfolger „Tom – 180 Fackel im Laden“, PR #116): lauf.py plant keinen Start, Tom wartet auf Ruhe. Jerry 154 ruht, Nachfolger Build 28 ebenso von lauf.py nicht geplant.
- 18:03 18.10.: Startsperre 18:03 Start Tom, Jerry (lauf.py)
- 18:05 18.10.: Lauf 18:03: archiviert Jerry 154 (2,12 $), Perikles 165 (0,16 $), Tom 175 (7,07 $). Start Tom 176a `session_01VqH2jCAHPeX6GnkSCgwGU8` (Plan lauf.py; Tom 175 hatte "Tom – 180 Fackel im Laden" gewünscht, Reihenfolge liegt beim Vorrat), Jerry 182 `session_0165xbntoamCjv1BqR4PS3H6`. Perikles pausiert bis 19.10., 08:00. Ford-Kontext 189 Tsd. Token, Tiefe 5: kein Selbstneustart mehr, Chef gebeten.
- 18:20 18.10.: Tom 176a meldet Neustart 33d0f71f (PR #116 auf main); Nachfolger „Tom – 180 Fackel im Laden“ wartet auf Rückfrage 180a des Chefs, nicht starten, bis beantwortet. Archivieren der Tom-Sitzung folgt im Lauf 19:03 nach lauf.py.
- 18:51 18.10.: Startsperre 18:51 Start Tom (lauf.py)
