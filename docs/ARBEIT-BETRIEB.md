# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Übergabe (18.10., 21:45, Ford Tiefe 0, `session_01QZw4AT6dXrruiV7smsf1Ze`) – Nachfolger: Ford (Selbstneustart nach `LISTE-BETRIEB.md`):** Übernahme von Tiefe 6 erledigt (Uhr, Archiv, Protokoll gekürzt). Offen: Tom 68 startet, sobald Tom 27 ruht (Chef 21:16); Homer 112 gesperrt bis Toms Vorlage zu 68.

**Nächste freie Vorgangsnummer: 189** (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef 17.10., 19:5x: „Habe Pro gekündigt, steht nur noch auf Free“): solange diese Zeile steht, sind alle Ford-2-Regeln ausgesetzt (`LISTE-BETRIEB.md` „Ford 2“ und „Lauf von Ford 2“, „stiller Ausfall“, 10-%-Regel, Messung Ford 2 20.–21.10.); Guthaben und Nutzungsbild nur Max. **Jerry läuft in der Zentrale** (Ford startet ihn, `LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, dann `LISTE-NIEDERLASSUNG.md`

**Sparmodus beendet Sa 17.10., 21:00** (Max-Wechsel; 99d)

**Ford: Pilot** (seit Sa 17.10., 21:05; zuvor Co-Pilot bis 21:00, Chef 15.10., 22:5x; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (108; Übersicht = `docs/chefsache/README.md`, zeigt GitHub unter der Dateiliste; Lesezeichen für den Chef: https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht Diogenes: `docs/PRUEFBERICHT.md`

**Guthaben:** Max 5 % Woche (Zurücksetzung Sa 21:00), Sitzung 5 % (Zurücksetzung 17:00), Fable-Woche 0 %; Nutzungsguthaben an, 95,69 $ verbleibend, 4,31 $ diesen Monat ausgegeben, kein Ausgabenlimit (Bild Chef 18.10., 12:5x); Max 100 % = Stillstand „Guthaben“ (128), kein Ausfall (Verlauf in Git)

**Jetzt installieren:** Release 0.1.827 (131 + D23.2, PR #104; Testaufgaben t16); 0.1.827 auf `main`.

- **Ford lebt in einer Sitzung** „Ford – Betriebsleiter (18.10., 21:40)“ `session_01QZw4AT6dXrruiV7smsf1Ze` (seit 18.10., 21:40, vom Chef von Hand, Tiefe 0, opus; Vorgänger archiviert, 1,10 $ erfasst). Stundenuhr „Ford-Lauf“ `trig_01F1FzQAw8abkJp5TH2SUsXy` (:03, seit 18.10., 21:41; alte Uhr gelöscht).
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

- 22:32 18.10.: Neustart Sokrates 8c43903a (Übergabe ok) → Start „Sokrates – Stab des Chefs (18.10., 22:31)“ `session_018PkgzV8xD8mqsF7ZUXxd6M`; Vorgänger archiviert, 5,31 $ zu gleichen Teilen auf 185, 156.1, 68, 184, 180
- 22:06 18.10.: Lauf 22:03: archiviert Diogenes 186.2 (0,52 $), Homer 186.1 (1,23 $), Perikles 187 (0,24 $), Tom 27 (2,56 $); Start Tom 68 (Muss) `session_01K2EUHbXUu9j6iKoe2HLaip`, Repo ok. Abweichung von lauf.py: Homer 112 nicht gestartet (wartet auf Toms Vorlage 68, wie 21:05), Perikles 165 nicht gestartet (Dauerzeile, Tag 1 heute getan, Perikles pausiert bis 19.10., 08:00); Jerry 39 läuft
- 21:42 18.10.: Ford vom Chef von Hand gestartet (Tiefe 0): neue Uhr, alte gelöscht, Vorgänger archiviert, 1,10 $ auf Betrieb; Lauf: alle Rollen belegt, alter Tom 176 archiviert, 6,64 $ auf 176
- 21:33 18.10.: Auftrag von Homer (Chef 21:31: „Diogenes soll 186.2 erledigen“, Zeile M, startbar laut startbar.py): Diogenes – 186.2 `session_01TWhSoYbza9K3aCoEExhXne` gestartet. lauf.py START-Zeile enthält source_url bereits (187 von Perikles ergänzt).
- 21:32 18.10.: Startsperre 21:32 Start Diogenes (lauf.py)
- 21:27 18.10.: Vorgang 187 (lauf.py source_url) auf Wort des Chefs an Perikles, Pause aufgehoben; Perikles – 187 `session_0149LLpph9ERmLrdyPPQzqzq` gestartet. Homer – 186.1 (Kür) `session_013QCWhX6usWs4GUF3Znj2mX` gestartet statt 112 (112 bleibt gesperrt bis Toms Vorlage 68; Abweichung von lauf.py, Chef: alle arbeiten heute Nacht).
- 21:25 18.10.: Startsperre 21:25 Start Homer, Perikles (lauf.py)
- 21:24 18.10.: Wort des Chefs: neuer Jerry. Jerry 39 (`session_01KLTh7MgopMEmazacqkDvgx`, 0,35 $ auf Betrieb) lief ohne Repo (create_session ohne source_url), archiviert. Neu: Jerry 39 `session_01XkxXPGhivtsmBAQExfVH9N` mit source_url. Regel in LISTE-BETRIEB Schritt 4 ergänzt.
- 21:16 18.10.: Wort des Chefs: Tom 27 wird fertig gemacht, erst danach Tom 68 (Muss). Heute Nacht sollen alle arbeiten; gibt es kein Muss mehr, nimmt die Zentrale Kür (Homer 186.1 nach Startsperre).
- 21:11 18.10.: Lauf 21:09: Jerry 172 (1,49 $) archiviert; Jerry 39 gestartet (`session_01KLTh7MgopMEmazacqkDvgx`); Tom 27 läuft, Tom 68 wartet auf dessen Ende; Homer 112 weiter gesperrt (wartet auf Toms Vorlage 68); Perikles pausiert bis 19.10., 08:00.
- 21:10 18.10.: Neuer Ford auf Wort des Chefs („Starte einen neuen Ford“, 21:08): `session_01EGJrCXu54ZzpXKDo32MsGX` (Tiefe 6, sonnet). Legt eigene Uhr an, löscht trig_01Sck61vd5yKcyi3DcfrHa6z, archiviert diese Sitzung und trägt die Zeile oben ein; bis dahin bleibt diese Sitzung Pilot.
- 21:09 18.10.: Startsperre 21:09 Start Jerry (lauf.py)
- 21:05 18.10.: Lauf 21:03: Homer 112 (0,98 $) archiviert. Startplan Homer 112 NICHT ausgeführt (Abweichung von lauf.py): Homer wartet auf Toms Vorlage zu 68, Sokrates 20:3x „Homer erst dann starten“; ein Start jetzt kostet ohne Ergebnis. Tom 27 läuft noch; Jerry 172 hat übergeben (Nachfolger über Ford, Start im nächsten Lauf nach Ruhe). An Perikles: lauf.py soll Homer 112 bis zur Vorlage zurückhalten.
- 21:03 18.10.: Startsperre 21:03 Start Homer (lauf.py)
- 20:42 18.10.: Zuruf Chef über Sokrates (0f838932): „68 jetzt vorziehen“, Tom soll 27 übergeben und "Tom – 68 Tempelszene" starten. Tom 27 `session_01RsxA2iWViDscDypybqgDBb` läuft (Kür), lauf.py plant keinen zweiten Tom; 68 (Muss, oben im Vorrat) startet mit dem Nachfolger, sobald Tom 27 ruht (spätestens Lauf 21:03). Nachricht an Tom 27 mit Aufgabe wird nicht zugestellt (Regel). Lauf 20:38: archiviert Diogenes (0,37 $), Jerry 156.1 (0,62 $), Perikles (1,28 $); Start Jerry 172 `session_01BsmQ9GVwWp7PdgBKpGbnVm` und Homer 112 `session_01CLh3CLX8oZz8J2Npjuo73D` (lauf.py; Sokrates wollte Homer erst nach Toms Vorlage, Zweifel lautlos gemeldet).
- 20:38 18.10.: Startsperre 20:38 Start Jerry, Homer (lauf.py)
- 20:09 18.10.: Release-Lauf 867 grün (success 18:07 UTC), Release v0.1.867 veröffentlicht (bornim.apk): https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867. CHANGELOG „## v0.1.867 – 18.10.2026, 20:01“ passt zum Lauf-Start. Neustart Jerry 156.1 (281f2fbc) gemeldet, Start im Lauf nach lauf.py.
- 20:06 18.10.: Lauf 20:03: archiviert Jerry 182 (1,04 $), Tom 180 (1,86 $); Start Tom 27 `session_01RsxA2iWViDscDypybqgDBb` (Kür), Jerry 156.1 `session_01TndrhtJUtpdXGUXgVRXBr4` (Muss). Release-Lauf 867 noch in Arbeit.
- 20:03 18.10.: Release auf Wort des Chefs („Erstelle das Release“) ausgelöst: android.yml release=true, Lauf 867 (https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/39152235097); CHANGELOG „## v0.1.867 – 18.10.2026, 20:01“, neuer leerer Abschnitt „## Unveröffentlicht“ angelegt.
- 20:03 18.10.: Startsperre 20:03 Start Tom, Jerry (lauf.py)
- 20:00 18.10.: Diogenes: Prüfbericht Release 4002fa46 (Code a073453c, Build 866 grün), freigeben ja (Lauf 29). Auslösen von android.yml release=true von der Auto-Freigabe abgelehnt (Production Deploy), nicht umgangen; Release wartet auf Chef (Erlaubnis für den Befehl oder selbst auslösen), CHANGELOG noch nicht umbenannt.
- 19:57 18.10.: Release auf Zuruf des Chefs („Mach mal ein Release fertig.“): Schritt 0, Zeile „Release“ in ARBEIT-PRUEFUNG.md angelegt, Diogenes gestartet (Auftrag Diogenes Release); Workflow erst nach seinem Prüfbericht.
