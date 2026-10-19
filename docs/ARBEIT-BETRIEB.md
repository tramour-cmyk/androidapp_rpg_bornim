# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Übergabe (19.10., 11:08, Ford Tiefe 1, `session_01L9C8Lvz4HDeBiLfbWmcCM1`) – Nachfolger: Ford – Betriebsleiter (Selbstneustart, ~390 Tsd. Token):** Lauf 11:04 getan: gestartet Diogenes 192.5b, Homer 201T, Perikles „M? entscheiden“; archiviert und gebucht Diogenes 99g.1, Homer 72.10a.8T, Perikles 192 Rest, Sokrates 07:59 (4,65 $ je 1,55 auf 194, 197, 59e). Offen: Sokrates 07:23 (need_input) und 09:00 (6,21 $, Kosten noch nicht gebucht, „Kosten auf:“ klären) nicht archiviert; Jerry 140 (Titel ohne Vorgangsnummer, 7,66 $) läuft/idle, Kosten auf 140; Tom nichts Startbares (wartet auf Test Build 31/32); Wochenzählung erst 26.10., Tagesrückblick ab 20.10. (Schritt 11). **Immer `python3 tools/lauf.py` und `startbar.py` aus `/home/user/bornim-main` rufen** (nie aus der Arbeitskopie); vor dem Archivieren `connection_status` prüfen (Chef sprach mit Perikles 190.9, 19.10.); Kurzzeile mit created_at (`list_sessions` mit `limit` 8 reicht, Ausgabe ist groß); Zuruf des Chefs an eine laufende Sitzung geht per `send_message` (zugestellt, funktioniert).

**Nächste freie Vorgangsnummer: 212** (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef 17.10., 19:5x: „Habe Pro gekündigt, steht nur noch auf Free“): solange diese Zeile steht, sind alle Ford-2-Regeln ausgesetzt (`LISTE-BETRIEB.md` „Ford 2“ und „Lauf von Ford 2“, „stiller Ausfall“, 10-%-Regel, Messung Ford 2 20.–21.10.); Guthaben und Nutzungsbild nur Max. **Jerry läuft in der Zentrale** (Ford startet ihn, `LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, dann `LISTE-NIEDERLASSUNG.md`

**Sparmodus beendet Sa 17.10., 21:00** (Max-Wechsel; 99d)

**Ford: Pilot** (seit Sa 17.10., 21:05; zuvor Co-Pilot bis 21:00, Chef 15.10., 22:5x; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (108; Übersicht = `docs/chefsache/README.md`, zeigt GitHub unter der Dateiliste; Lesezeichen für den Chef: https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht Diogenes: `docs/PRUEFBERICHT.md`

**Guthaben:** Max 19 % Woche (Zurücksetzung Sa 21:00), Sitzung 24 % (Zurücksetzung 13:00), Fable-Woche 0 %; Nutzungsguthaben an, 95,69 $ verbleibend (Bild Chef 19.10., 11:34, „auf Kurs“); Max 100 % = Stillstand „Guthaben“ (128), kein Ausfall (Verlauf in Git)

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Ford lebt in einer Sitzung** „Ford – Betriebsleiter (19.10., 11:09)“ `session_01B5fs5xfkCny8UFpwnmgKVb` (seit 19.10., 11:06, Selbstneustart, Tiefe 2, sonnet; Vorgänger `session_01L9C8Lvz4HDeBiLfbWmcCM1` archiviert, 4,56 $ auf Betrieb). Stundenuhr „Ford-Lauf“ `trig_01W5W9nFhZpNw383eEGWbueZ` (:03, seit 19.10., 11:06; alte Uhr gelöscht).
- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (seit 16.10., 21:19; 15.10., 22:5x zurückgeholt, D13.2).
- **(ruht, 159)** Ford 2: Stundenuhr aus, Regeln `LISTE-BETRIEB.md` „Lauf von Ford 2“ (Verlauf in Git).
- **(ruht, 159)** Ford 2 (Pro): Sitzung `session_017VRJsTBwEbU16mwomLknhm`, Uhr `trig_01WCdVmLssvGbjCSK9KJPCPH`; bei Wiedereinschalten neu prüfen.

## Eingang

Anregungen ohne Bereich und Startwünsche (eine Zeile, Datum, Absender). Ford teilt im nächsten Lauf zu oder legt sie dem Chef vor.

- 19.10., von Perikles (197): Sokrates-Sitzungen 07:23 und 07:59 vom 19.10. sind gebucht (`--kosten … ID`, Buchungsverzeichnis). Rest von Hand: 18.10.-Sitzungen (z. B. `session_01RQqCXxXZqPqJVuRnifwazJ` 5,77 $) und 09:00 beim Archivieren; `lauf.py` bucht künftig selbst.

- 18.10., 22:4x, von Perikles (185, Chef „erst messen“): Selbstneustart jetzt erst ab 400.000 Token (`LISTE-BETRIEB.md`). Morgenlauf 20.10.: Ford-Zeile aus `kosten.py --tag 19.10.`, `--tag 18.10.` und `--tag 17.10.` (dieselben Seiten) in die Morgenmeldung, Zeile streichen
- 17.10., 09:3x, von Perikles (99h, Zuruf Chef): Messung Leitung 20.10., 00:00 – 21.10., 24:00: Ford trägt beim eigenen Neustart und am Ende der Messung seine `cost_usd` in die Zeile „Betrieb“ von `LISTE-VORGAENGE.md` ein („Ford x $“; Ford 2 entfällt, solange die Niederlassung ruht, 159); Auswertung Perikles 22.10.

## Protokoll
Eine Zeile je Lauf mit Tat, neueste oben, höchstens 20 Zeilen; ältere streichen (Verlauf in Git, 117).

- 06:05 19.10.: Uhr an (06:04); Selbstneustart Ford (380 Tsd. Token, vor dem Morgenlauf)
- 03:05 19.10.: Lauf 03:04: Tom D29.3 fertig (Vorrat leer), archiviert, 5,70 $ auf 71. Nichts startbar (Jerry nur Kür nach dem Meilenstein, startbar meldet „gebaut“ fälschlich), keine Sitzung läuft → Uhr aus (99h), einmalig „Uhr an“ `trig_014HbkYfaTXeFCY7nvbB3U6S` 06:03
- 01:51 19.10.: Neustart Tom ba0968f4 (Übergabe ok) → „Tom – D29.3 Rest Hund, Wind“ `session_017DByak5Nw5nM6pAAt2kqdM` (Kür); Vorgänger archiviert, 4,03 $ auf 71
- 01:19 19.10.: Neustart Tom 03f68f54 (Übergabe ok) → „Tom – D29.3 Rest Dorf-Kleinleben“ `session_01Gx1mNn8rdC8Ar87KzsAxFc` (Kür); Vorgänger archiviert, 4,39 $ auf 71 (D29 ohne eigene Zeile, Befund aus 71)
- 01:05 19.10.: Lauf 01:03: Tom 68 archiviert (3,44 $; Build 32 wartet auf Chef, t32); Start Tom D29.3 (Kür, Übergabe) `session_0141urGZK264Me7eiMbEJJes`, Repo ok. Abweichung wie 00:03: Jerry 72.10a.9 nicht (gebaut), Perikles 185 nicht archiviert (Sitzung des Chefs)
- 00:05 19.10.: Lauf 00:03: Homer 112 archiviert (1,16 $); Start Tom 68 (Muss, Bild 3) `session_01WK7d6gjHH5ppcA2YCSyFtL`, Repo ok. Abweichung: Jerry 72.10a.9 nicht gestartet (Zeile „gebaut“, startbar irrt, an Perikles); Perikles 185 (Sitzung des Chefs) nicht archiviert; Diogenes 71 wartet auf Chef 186.3
- 23:41 18.10.: Neustart Jerry 579c4948: Vorgänger 72.10a.11 archiviert, 2,57 $ auf 72.10a.11. Nachfolger „72u.1 Kampfort“ NICHT gestartet (Abweichung): Wochenziel nimmt 72u aus („nicht diese Woche“, Neues nach dem Meilenstein), drei Kür-Zweige (.8 in Build 31, .9, .11) warten auf Test 31; Jerry ohne Sitzung, bis der Chef „jetzt“ sagt oder Muss kommt
- 23:33 18.10.: Neustart Jerry 137f4294 (Übergabe ok) → „Jerry – 72.10a.11“ `session_01DTRfTer63VDKn6t2Rge5Zt`; Build 31 grün, Testbitte gemeldet; Vorgänger 72.10a.9 archiviert, Kosten fehlt. Befund an Perikles: startbar führt 72.10a.9 trotz „gebaut“ als startbar
- 23:23 18.10.: Neustart Jerry 316f4b41 (Übergabe ok) → „Jerry – 72.10a.9“ `session_01VBgBUhPbjVCbpaRnLoXwXv` (zuerst PR #120 Build 31); Vorgänger archiviert, 4,85 $ zu gleichen Teilen auf 72.10a.8, 172
- 23:08 18.10.: Neustart Jerry → „Jerry – 72.10a.8“ `session_01LPhxWDpxrW3qWNL1iycH2u` (Kür; Neustart-Meldung 3601406c, Übergabe ok; Chef 21:12 „heute Nacht sollen alle arbeiten“). Zweifel an Perikles: Wochenziel nennt Kampfprobe 72.10 „nicht diese Woche“, startbar führt 72.10a.8 als Kür. Vorgänger D21.J archiviert, 1,27 $ auf D21
- 23:05 18.10.: Lauf 23:03: archiviert Jerry 39 (2,58 $), Tom 68 (6,77 $, wartet auf Homer); Start Jerry D21.J (Muss) `session_01YEaFuTAgebdk5iwf7fLx7x`, Homer 112 (Muss, Vorlage Tom da) `session_01ReGNXXjtWQb7NEsUxaKxHG`, Diogenes 71 (Kür, Chef über Sokrates) `session_01HasosfJmMQT5LwzUisaQWW`; Repo ok. Perikles 185 (vom Chef von Hand gestartet) nicht archiviert: Sitzung des Chefs
- 22:40 18.10.: Vorrat abgeglichen (Chef 22:32): Eingang 167.2, 167.5 (Regel in Schritt 1/3), 162 (Regel in `ROLLE-BETRIEB.md`), Tom 117 (Zeile bei Tom nicht mehr da) gestrichen; „Jetzt installieren“ auf 0.1.867; Übergabe neu
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
- 07:04 19.10.: Startsperre 07:04 Start Tom, Jerry (lauf.py)
- 07:05 19.10.: Abweichung vom Plan lauf.py: START Tom (D29.3) und Jerry (72.10a.9) nicht ausgeführt, beide Zeilen „gebaut“ (kein Startbares, startbar.py-Fehlmeldung 72.10a.9, schon an Perikles); ARCHIVIERE Perikles 185 nicht ausgeführt (Sitzung des Chefs). Startsperre 07:04 gegenstandslos.
- 07:15 19.10.: Startsperre 07:15 Start Jerry, Perikles (lauf.py)
- 07:23 19.10.: Startmarke 07:23 Start Sokrates (Neustart d84aabe4, Übergabe geprüft)
- 08:00 19.10.: Startmarke 08:00 Start Sokrates (Neustart 5c52e856, Titel „130 Gefühl MARS vorbereiten“); alter Sokrates session_01FJZv4AiwTA4SiE9UQxexus bleibt (194 Frage an Chef, Hindernis)
- 08:04 19.10.: Startsperre 08:04 Start Tom, Jerry, Homer, Perikles (lauf.py)
- 08:06 19.10.: Lauf 08:04: Homer 84.1T.1 (M, Vorentscheid Perikles) und Perikles 190.9 gestartet; Perikles 190 archiviert, 1,23 $ auf 190. Nicht ausgeführt: START Tom D29.3, Jerry 72.10a.9 (beide „gebaut“, nichts zu tun), ARCHIVIERE Perikles 185 (Sitzung des Chefs, Frage an Chef offen). Wochenstart heute ohne Start: Wochenzählung erstmals 26.10., Tagesrückblick ab 20.10. Kurzzeile braucht created_at (190.7), jetzt enthalten.

- 08:13 19.10.: Perikles 185 (`session_01Jpnob59NbQfWwnYFMZUQfA`) auf Wort des Chefs („185 muss archiviert werden“) archiviert; 2,10 $ standen schon in Zeile 185, nicht doppelt gebucht. Lehre: „Sitzung des Chefs“ aus der Übergabe nicht ungeprüft glauben; alte Sitzung derselben Rolle mit neuerer daneben = archivieren (eine Rolle, eine aktive Sitzung).
- 08:14 19.10.: Startsperre 08:14 Start Jerry, Diogenes (lauf.py)

- 08:16 19.10.: Diogenes zuvor nicht gestartet (Fehler Ford): `lauf.py` lief 07:04 und 08:04 aus der alten Arbeitskopie `androidapp_rpg_bornim/tools/` mit veralteter Regel („186.3 wartet auf Chef“ sperrte Diogenes, 190 hatte das behoben). Ab jetzt immer `python3 tools/lauf.py`/`startbar.py` aus `/home/user/bornim-main`. Nachgeholt 08:14: Diogenes 71 (alter Lauf archiviert, 2,01 $ auf 71) und Jerry 86 gestartet. Die früheren Abweichungen (Tom D29.3, Jerry 72.10a.9 nicht gestartet) bleiben richtig, aber aus falschem Grund geprüft: Zeilen sind „gebaut“.- 08:18 19.10.: Startmarke 08:18 Start Diogenes 192.5 (M, Sokrates 08:2x); Diogenes 71 (08:14, session_016rfLUfmJgd1XFgsxjfT8Ne) wird dafür archiviert, Kosten auf 71.
- 08:48 19.10.: Startsperre 08:48 Start Tom, Jerry, Diogenes, Homer (lauf.py)
- 08:50 19.10.: Perikles-Start auf Bitte Sokrates/Chef 195: eine Sitzung für alle Muss (D31.1–D31.3, 190.10, 190.8, 191, 192); alte Sitzungen Diogenes 192.5, Homer 84.1T.1, Perikles 190.9, Jerry 86 (alle fertig, Übergabe/Antwort auf main) vor dem Nachfolger archiviert.
- 08:53 19.10.: Korrektur auf Sokrates (08:4x): Perikles 190.9 (session_01VwxEYH59stnxtKbcnww61i), mit dem der Chef sprach, war von mir 08:48 archiviert, wieder geöffnet (unarchive); der 08:50 neu gestartete Perikles (session_016GhZPkyNa55KqxLe7iqgQh) archiviert (keine Kosten). 0,30 $ auf 190.9 sind schon gebucht, beim endgültigen Archivieren nur die Differenz. Lehre: vor dem Archivieren einer „fertigen“ Sitzung prüfen, ob der Chef sie gerade benutzt (connection_status connected, updated_at).
- 09:00 19.10.: Startmarke 09:00 Start Sokrates (Neustart fe14dc21, „Stab des Chefs“, 194); Sokrates 07:59 (130) übergibt, bleibt bis zu seiner Fertigmeldung.
- 10:04 19.10.: Startsperre 10:04 Start Jerry, Diogenes, Homer, Perikles (lauf.py)
- 10:06 19.10.: Lauf 10:04: archiviert Diogenes 190.9b, Homer 99g.1, Jerry 134.3, Perikles 190.9 (disconnected, Übergabe da; Differenz 1,84 $), Tom 84.1T.1; gestartet Jerry 140, Diogenes 99g.1, Homer 72.10a.8T, Perikles 192 Rest/191 Rest. Tom nichts Startbares. Sokrates 07:23/07:59/09:00 bleiben (194, Chef im Gespräch; Titel ohne Vorgangsnummer, Kosten nicht buchbar).
- 10:19 19.10.: Zuruf Chef (10:16, über Sokrates): 194.1 Trockenlauf an Diogenes; Nachricht an laufenden Diogenes 99g.1 (session_012Zx3BKTs4ghhJRMG3v3sXJ) zugestellt. Sokrates-Sitzungen von Hand buchen bis 197 (Perikles) steht: 22:31 (18.10.) 9,14 $, 07:23 4,10 $, 07:59 1,92 $, 09:00 laufend; keine davon archiviert, nicht gebucht.
- 10:41 19.10.: Startmarke 10:41 Start Sokrates (Neustart 2f7f82b1, „Stab des Chefs“, Kosten auf 194, 197, 59e); Sokrates 09:00 übergibt, nicht archiviert (197 bucht).
- 11:05 19.10.: Startsperre 11:05 Start Diogenes, Homer, Perikles (lauf.py)
- 11:08 19.10.: Lauf 11:04 siehe Übergabe; Selbstneustart Ford folgt (Token).
- 12:04 19.10.: Startsperre 12:04 Start Tom, Jerry, Homer, Perikles (lauf.py)
