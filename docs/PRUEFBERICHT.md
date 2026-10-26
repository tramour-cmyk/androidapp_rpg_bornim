# Prüfbericht Diogenes

Befunde von Diogenes (`ROLLE-PRUEFUNG.md`, Aufbau in `LISTE-PRUEFUNG.md` „Prüfbericht“). Jeder Befund ist ein **Verdacht**, bis der Zuständige ihn bestätigt; Vermerke („bestätigt“, „behoben“, „verworfen“ mit Grund) schreibt er unter den Befund. Neuester Lauf oben. Nur Läufe mit offenen Befunden; abgeschlossene Läufe ins [Prüfbericht-Archiv](PRUEFBERICHT-ARCHIV.md) (Lauf 22–39, 41; 274).

## Wochenzählung (QM, 106.1; nur Zahlen, Bewertung Perikles)

| Kennzahl | 18.–24.10. (gezählt 26.10., 00:5x) | Quelle |
|---|---|---|
| Kosten je Bereich (Liste) | 1703,90 $: B 789,02 (davon Zeile „Betrieb“ 564,16) · E 607,59 · G 171,54 · Q 92,36 · M 21,45; ohne Bereichsbuchstaben der Liste: D 10,33, A 5,50, O 4,85, F 1,26 | `LISTE-VORGAENGE.md` + `-ARCHIV.md`, `62ca83ee8` → `b17da0aea`; ein Teil kann vom 17.10. stammen |
| Anteil Muss | 43 % (735,66 $); ohne „Betrieb“ 65 %; M? 114,67, K 125,71, „–“ 727,86 | Spalte „Kl.“ |
| Kosten je Rolle, Anteil Spiel | 1813,92 $ (370 Sitzungen, 20 ohne Kosten): Jerry 543 (30 %), Sokrates 489 (27 %), Tom 383 (21 %), Ford 156 (9 %), Perikles 118 (7 %), Homer 102 (6 %), Diogenes 23 (1 %); **Anteil Spiel 57 %** (Stufe 50 %) | `kosten.py`, Starttag der Sitzung |
| Guthaben Max | Woche 5 % (18.10.) → 41 % (20.10.) → 77 % (22.10., 12:45) → 94 % (23.10., 07:16) → 100 % 23.10., 10:1x; danach Credits 79,38 → 54,03 $ (24.10., 17:21); 80/95 % genau: fehlt | „Guthaben:“ in `ARBEIT-BETRIEB.md` (Git); Monatsangabe 4,31 → 248,62 $ passt nicht zum Rückgang 41,66 $ (Nachkauf nicht eingetragen) |
| Wochenziel / Meilenstein | Wochenziel nein (38 offen, 39 wartet; erledigt 13e, 112/68, 26); Pflicht Block (a) 3 von 4 offen; marktreif 5 von 6 Blöcken gelb | `LISTE-ABNAHME-KAPITEL1.md` |
| Testrunden Chef, Rückläufer | 63 Builds (19–87) im CHANGELOG; Rückläufer 6 (Build 81: 1, 82: 3, 83: 1, 84: 1; Feld erst ab 81) | `CHANGELOG.md`; 101 Löschungen in `ansehen/` |
| Ersparte Fragen (Vorentscheid) | 3 (59e.1, 84.1T.1, 261.5), alle gebilligt | `VORGANGSARCHIV.md` |
| Stillstand | Fehler: Homer 8,4 h (bis 18.10., 08:24); Guthaben: 0 Zeilen (ab 23.10. über Credits) | Protokoll `ARBEIT-BETRIEB.md` |
| „von Team“ an Homer > 1 Tag | 0 | `ARBEIT-KREATIV.md` |
| Empfehlungen Sokrates (17./18.10.) noch gültig | 11 von 13, 2 teilweise abgelöst (167 durch 192.4; 99h.6 durch 261.5) | `VORGANGSARCHIV.md` |
| Verwerfquote Diogenes | 0 von 49 (D26.1–D41.5), 2 teilweise (D29.1, D29.4) | Prüfbericht, Archiv |
| Erst der Chef am Gerät | 6 (Rückläufer) | `CHANGELOG.md` |
| Perikles Z3 / Z4 / Z6 | Z3 1 (23.10., 13e); Z4 14 neue Chefsache-Dateien: 11 ja, 1 ja, aber (186), 1 anders (287), 1 unklar (234); Z6 nein, Muss 43 % | `ARBEIT-PROJEKT.md`, `git log --diff-filter=A`; Zielvereinbarung erst seit 23.10. |
| Z5 Anteil Tom, Jerry, Homer | 57 % | wie Kosten je Rolle |

## Offen für den Chef

**149 Probewoche Ford (Lauf 45):** Entscheidung über Ford: Aufwand „Niedrig“ oder stärkeres Modell. Grundlage sind die Zahlen von Lauf 45. Dort steht auch, dass am Sa 24.10. die Morgenmeldung ausfiel (Grund: Guthaben). (D4.1 am 26.10. ins Archiv, Lauf 23.)

## Lauf 45 · Auftrag 149/156 (Probewoche Ford; Tom gegen Jerry; Woche 18.–24.10., gezählt 26.10., 01:0x, fremder Helfer, nur Zahlen)

**Ford (149):**
- **Unterbliebene Starts nach 149.1 (ab 20.10., 10:04):** 0 bei 31 geprüften Zeilen „nichts zu starten“.
  - 5 Abweichungen mit Grund: 3 wegen Sparbetrieb, 1 wegen Logo-Wahl Homer über 25 Läufe.
  - 2 davon unsicher: 23.10., 18:06 Tom 345, ein Rückläufer, obwohl der Sparbetrieb Rückläufer erlaubt; 21.10., 00:03 Perikles 165.
  - Vorher (Lauf 37/38) 1 unterbliebener Start (D37.1, 17.10.).
  - Von Ford selbst gemeldet: 18.10., 08:24 Homer 72.10a.T übersehen; 19.10., 08:16 Diogenes nicht gestartet.
- **Doppelte Sitzungen einer Rolle, Überschneidung über 15 Minuten:** 19 Paare.
  - Nicht erlaubt: 3, Homer 22.10., 17:05; 23.10., 04:04 und 09:07. Grund: der Titel „Homer, 279“ wurde als „ohne Rolle“ gelesen (Mechanik, behoben 360).
  - Unsicher: 4 Jerry-Starts am 19.10.
  - Die übrigen sind Ablösungen nach der 60-Minuten-Regel oder Sitzungen des Chefs.
- **Fehlende Kosten:** 19 Sitzungen ohne `cost_usd`; 8 Protokollzeilen „Kosten fehlen“.
  - 5 Sitzungen mit Kosten nicht gebucht (19,13 $; Ford 2, Perikles 1, Tom 2).
- **Verpasste Meldung:** 1 belegt, Sa 24.10., 9 Uhr.
  - Von 23.10., 19:03 bis 24.10., 16:31 fielen 21 Läufe aus (Wochenlimit, Credits leer); die Wache lief in dieselbe Grenze.
  - Übrige Tage: ohne Telegram-Verlauf nicht belegbar.
- **Abweichungen und nicht ausgeführte Plan-Schritte (276):** 56 Zeilen, etwa 22 Fälle, fast alle in Schritt 4 von `LISTE-BETRIEB.md`.
  - Urteil: 12, darunter Homer 251.1 über 26 Zeilen, Sokrates `01FBJT` nicht archiviert, Jerry „derselbe“ 22.10.
  - Mechanik: 8, darunter Perikles „M?“ ohne Nummer über 13 Zeilen, `startbar.py`-Fehler „gebaut“, gleicher Titel besteht, Archivieren verweigert, Seitenliste abgeschnitten.
  - Dazu 1 Fall regelgerecht und der Ausfall durch Guthaben.

**Tom gegen Jerry (156):**
- **Rückläufer:** Tom 23, Jerry 43, aus 22 und 32 eigenen Builds plus 9 gemeinsamen Builds (79–87).
- **Regelverstöße, soweit belegt:** je 2.
- **Befunde Diogenes:** Tom 2, Jerry 3.
- **Kosten der Woche:** Tom 383 $, Jerry 543 $.
- **Kosten je Rückläufer:** Tom 16,65 $, Jerry 12,62 $.
- **Kosten je Build:** Tom 17,41 $, Jerry 16,96 $.
- **Schwelle Archiv 156:**
  - Rückläufer: **überschritten**, 43 gegen 1,5 × 23 = 34,5.
  - Regelverstöße: nicht überschritten, 2 gegen „mehr als 2“.
- Ursache je Rückläufer (Modell oder Auftrag): fehlt, das CHANGELOG nennt nur den Befund. Auswertung Perikles.

**Nicht geprüft:**
- Morgenmeldungen außer 24.10. (Telegram nicht lesbar).
- Ruhende Sitzungen außerhalb der Besetzung.
- Builds 88/89.
- Sitzungen vor 17.10., 17:05.

Teamzuordnung über PR-Zweig bzw. Besitzer des Vorgangs.

## Lauf 44 · Auftrag 270 (Perikles und Diogenes auf dem großen Modell, Probe 21.10., 06:26 bis 26.10.; gezählt 26.10., 00:3x)

Nur Zahlen, Bewertung Perikles (Archiv 270). Vorher = 18.–20.10. (kleines Modell, laut `configured_model`), nachher = 21.–25.10. (großes Modell; 21.10. vor 06:26 enthalten, wo vermerkt).
- **Kosten** (`kosten.py` über `list_sessions` bis 17.10. zurück; Tag = Starttag der Sitzung): Perikles vorher 14,72 / 7,20 / 7,25 $ (Schnitt 9,7 $/Tag, 32 Sitzungen), nachher 36,37 (darin 261.4/261.5 noch klein) / 14,04 / 22,39 / 16,18 / 13,31 $ (Schnitt 20,5 $/Tag, ohne 21.10. 16,5 $; 27 Sitzungen). Diogenes vorher 5,03 / 2,85 / 3,61 $ (3,8 $/Tag), nachher 7,63 / 0 / 1,74 / 1,77 / 29,57 $; 25.10. ist 348.9 Blätter messen (neuer Auftrag, Chef 12:24), ohne diesen Tag 2,8 $/Tag. Zum Vergleich alle Rollen: vorher 239 $/Tag, nachher 367 $/Tag (25.10.: 737 $).
- **Umbauten am Ablauf je Tag** (Commits an `CLAUDE.md`, `ROLLE-*`, `LISTE-BETRIEB/-RELEASE-NEUSTART/-PRUEFUNG`, `tools/*.py|sh`, `.claude/`, ohne Chefsache-Verzeichnis; Rolle aus der Sitzungskennung im Commit): Perikles 29 / 22 / 8 → 21 (4 vor 06:26) / 8 / 7 / 5 / 5; Sokrates 4 / 7 / 9 → 9 / 5 / 0 / 1 / 4; Diogenes, Ford, Homer zusammen 6 → 0.
- **Nachträglich gefundene Fehler in Regeln und Werkzeugen:** vorher 26 Befunde Diogenes (D27 5, D28 6, D31 5, D33 4, D35 1, D36 5; Läufe 27–36), vom Chef zuerst gefunden nicht gezählt (Z3 erst seit 341, 23.10.). Nachher 10 Befunde Diogenes (D40.1–5 auf 261.5, gebaut 05:5x noch klein; D41.1–5 auf 274) und Lauf 42 A–C (Plan 347, vor dem Bau), dazu **4 vom Chef zuerst gefunden:** Höhle 13e als offen geführt (23.10., 10:14), Kürzel im Stand zum Marktstart (25.10., 00:36), Chefsache 361 trotz 287 (25.10., 07:55), Stempelprüfung ließ Antworten doppelt erscheinen (24.10., 21:16, `zug-haken.py`). Beim Vergleich beachten: seit 167.3 (18.10.) prüft Diogenes Abläufe nur auf Anlass.
- **Nicht gezählt:** vor 18.10. gestartete Sitzungen (Kosten am Starttag); 33 Sitzungen ohne `cost_usd` (meist laufende); Niederlassung nicht lesbar; Regelfehler ohne Spur in Commits oder Befunden.

## Lauf 43 · Auftrag 366 (Prüfbogen für Tester, `tools/pruefbogen/`, gegen `main` `face0b5c` = AAB 142.1; 25.10., 19:01)

**Nutzbar nach vier Änderungen, sonst nicht** (fremder Helfer bestätigt alle Befunde am Code):
- **D43.1 Geräteangaben:** „Menü → System → Test → Gerät zeigen …“ gibt es für Fremde nicht: „Test“ ist ein eigener Reiter, nur im Testmodus (7× aufs Logo im Hauptmenü, `App.kt` 258, `MenuScreen.kt` 117), und ein Schummelmenü (Teleport, Beute). Ersetzen durch „Handymodell und Android-Version (Einstellungen → Über das Telefon)“.
- **D43.2 Schwierigkeit:** „Gewählte Klasse und Schwierigkeit“; eine Schwierigkeitswahl gibt es nicht (nur Klasse, `CreateScreen.kt`). „Schwierigkeit“ streichen.
- **D43.3 Rückweg fehlt:** nirgends, wohin der ausgefüllte Bogen geht (z. B. kontakt@bornwire.de), und dass das PDF am Gerät ausfüllbar ist (106 Felder, geprüft) oder gedruckt werden kann.
- **D43.4 „bisheriger Kampf“** (Teil M, M7): ein Neuling kennt keinen; „der normale Kampf in der Welt“.
- Klein: Spiel sagt „Auftrag“, Bogen „Quest“ (A4, D); Bogen nur Deutsch, Webseite DE/EN.

Stimmt: Version/Build (Menü → System oben), MARS-Weg (System → „MARS“ → Regelseite → Probekampf), Ring, Ansagen, Kampfbericht; PDF entspricht `bogen.md`, 4 Seiten. Für den Godot-Stand gelten alle Menüwege neu. Ändern: Besitzer des Bogens, PDF mit `bogen_pdf.py` neu bauen. Nicht geprüft: Bogen am Handy im PDF-Programm ausgefüllt.

## Lauf 42 · Auftrag 347.1 (Gegenprüfung `tools/regeltreue/PLAN-347.md`, 24.10., 16:4x)

Umsetzbar, aber **vor dem Einschalten ändern:**
- **A Messweg (Punkt 1):** `list_events` liefert Zeit, Text und `usage` (Kontextgröße), ist aber teuer: Probe 15 Ereignisse ≈ 9 Tsd. Token (Signaturen, doppelte Werkzeugeingaben) für 7 Antwortteile. Stündlich alle Sitzungen in Fords Kontext frisst mehr, als das Paket spart. Besser: Zähler-Haken (Paket 3.4) schreibt lokal; vor Übergabe oder Neustart schreibt die Sitzung eine Summenzeile nach `main` (ein Schritt im Neustart-Ablauf, `LISTE-RELEASE-NEUSTART.md`); Kontextgröße zusätzlich aus `list_sessions` (`used_tokens`, hat `lauf.py` schon); `list_events` nur als Stichprobe. Basis (Punkt 7) rückwirkend aus Stichproben 21.–24.10., dann gilt „ab sofort alles“ (Chef 16:30) ohne Wartezeit.
- **B Stempelprüfung (5a) in `zug-haken.py`:** (1) Der Haken hält nur einmal an (`stop_hook_active`): Stempel- und Chefsache-Prüfung in einem Block mit gemeinsamem Grund, sonst hebt eine die andere auf. (2) Bezugszeit: `neustart-haken.py` sagt „so stempeln“ mit der Zeit beim Prompt, der Stop-Haken vergleicht mit Zugende; jeder Zug über 2 Minuten (Builds, Prüfungen) würde fälschlich angehalten. Gelten lassen: Stempel zwischen Prompt-Uhr (im Zustand unter `/tmp` mitschreiben) und Zugende plus 2 Minuten. (3) Geprüft wird nur der letzte Text (`last_assistant_message`); steht der Stempel in einem früheren Zwischentext, fehlt er dort: Fehlen nicht anhalten, nur falsche Zeit. (4) Mitternacht und Datum mitrechnen. (5) `zug-haken.py` läuft aus `bornim-main`, ein Fehler trifft sofort alle Sitzungen: vorher an einem echten Verlauf testen. Beleg, dass die Prüfung nötig ist: Diogenes stempelte heute 16:38 bei Uhr 16:34.
- **C Pause (Punkt 6):** widerspricht `CLAUDE.md` („Pause bis … Ford startet dann nicht“) und `lauf.py` Z. 386 (NICHTS bei Pause vor dem Nachfolger). Alle drei zugleich ändern; Neustart trotz Pause nur als Ablösung einer Sitzung, die ohnehin arbeitet, nie neue Arbeit (Pausen wegen Guthaben).
- **Beim Bau beachten:** (D) `neustart-haken.py`, `notiz.sh` und `settings.json` laufen aus dem Arbeitszweig (`$CLAUDE_PROJECT_DIR`), nicht aus `main`: Punkte 2 und 3 wirken erst in Sitzungen, deren Zweig `main` danach enthält; Messbeginn je Sitzung festhalten. (E) Kernregel-Zeile nur ein Wortlaut an einem Ort (beide Werkzeuge lesen ihn), nicht `hook-prompt.sh` zusätzlich; „kein Zwischenstand“ auf den Chat begrenzen, sonst Widerspruch zu `CLAUDE.md` 9 (Standzeile etwa alle 5 Minuten in Telegram). (F) 5b: Paket sagt „Diogenes trägt montags ein“, Diogenes ändert nichts: Perikles trägt ein, Diogenes schlägt in der Wochenzählung vor. Regelbilanz: 7 neue Zeilen (5 aus 5b, 2 aus dem Paket), gestrichen nur der Zeitstempel-Satz; die Paketzeile „Entschuldigung“ doppelt Haltung 5 und den Antwortstil, streichen. (G) Telegram länger: `CLAUDE.md` 9 „je Thema eine Zeile“ mitändern; über 4096 Zeichen (bei `--bild` 1024) sendet `meldung.sh` nicht, meldet nur Fehler. (H) Punkt 4: Befehle laufen am heutigen Stand (Vorrat Tom 4,1 statt 10,9 KB, Jerry 5,6 statt 11,2; Stil 2,1 KB; Änderungshistorie 1,9 KB; Ford-Zeile da). Risiken: „Zu <Nr>“ ist Platzhalter; drei Einträge der Änderungshistorie decken nur Build 82–84; Abschnittsnamen („## Einzelheiten“, „## Auf einen Blick“, „## Signatur“) werden Anker, Umbenennen lädt still alles oder nichts → `regelcheck.py` prüft die Anker; Stil nur kurz ist wieder eine Textregel: Stil-Rückläufer je Woche mitzählen.
- **Messbarkeit:** „Dauergelaber“ vorab festlegen: Wörter der letzten Antwort je Zug, je Rolle, Sokrates getrennt; Ziel als Zahl (z. B. Median −30 %), sonst Eindruck. „Kennt die Uhr“: Anteil Stempel über 2 Minuten daneben, je Rolle.

## Lauf 40 · Auftrag 261.5 (Archivregel, Prüfung des Ergebnisses; Stand `98ba4b9b`, Chef 21.10., 06:15)

Geprüft: Diff `b9ad0757..98ba4b9b` (`lauf.py`, `kosten.py`, `ROLLE-BETRIEB.md`, `LISTE-BETRIEB.md`, Fords Übergabe) gegen Vorgangsarchiv 261.4, 261.4 Regel, 261.5. **Verfahren:** (a) Wegwerf-Kopie von `tools/` und `docs/` (nichts auf `main` geändert), Kurzzeilen-Szenarien: zwei Homer (alte mit Frage), zwei Sokrates, Sitzung ohne Rolle, zwei Tom, Diogenes mit Muss und 50 / 150 Tsd. Token oder Frage offen; Marken „Archiv“ und „Mehrfach“ von Hand 60 Minuten alt gesetzt; (b) Lauf gegen die **echten** 40 neuesten Sitzungen von 06:25 (`list_sessions`, Kurzzeilen mit created_at und used_tokens).
**Besteht:** ÜBERTRAGE vor ARCHIVIERE bei offener Frage; Frage hält nichts mehr; eine Sitzung je Bereich bleibt stehen; Sitzung ohne Rolle: eine Warnung, Marke nur mit `--sperre`; Mehrfach- und „nicht ausgeführt“-Prüfung schlagen mit 60 Minuten alter Marke an; WEITER unter 100 Tsd. Token und 60 Minuten, sonst START (auch bei Frage); Fords Übergabe und `ROLLE-BETRIEB.md` stimmen mit dem Code überein (`lauf.py` archiviert nie). Echte Liste: 5 offene Jerry-Sitzungen → 4 ARCHIVIERE (2 mit ÜBERTRAGE), dazu Homer 1, Perikles 1, Sokrates 1; Tom (eine Sitzung) bleibt.
**Befunde:**
1. **D40.1 (hoch): Satz 3 greift praktisch nie.** Von 40 echten Sitzungen liegt **eine** unter 100 Tsd. Token (Tom, 92.825); frisch gestartet steht Sokrates nach 6 Minuten bei 100.161, kurze Arbeiten enden bei 102 bis 127 Tsd. WEITER trifft damit fast nie, es wird weiter gestartet und archiviert: die Absicht des Chefs („kann ich in die alte noch was reinarbeiten, weil es günstiger ist“) wird nicht umgesetzt. Schwelle messen und anheben (bei 150 Tsd. wären es 16 von 40, davon 10 noch offen) oder als Zuwachs seit dem Start rechnen; **Kosten gegen kalte Zwischenablage abwägen: Perikles, Zahl in `LISTE-BETRIEB.md`.**
2. **D40.2 (mittel): „nicht ausgeführt“ meldet jeden Lauf laut, ohne Ende.** `alt` nimmt jede Marke ab 30 Minuten Alter, nichts begrenzt die Wiederholung. Real: Sokrates `017M3n…` (Sitzung des Chefs am Rechner) hat Ford am 20.10., 23:10 und 21.10., 06:20 nicht archivieren dürfen (Berechtigungsprüfer verweigert); der Plan von 06:25 setzt sie wieder auf ARCHIVIERE → ab dem nächsten Lauf stündlich WARNUNG-LAUT, unlösbar. Vorschlag: einmal je Sitzung warnen (eigene Marke „Archiv-Warnung <id>“); Sitzungen, die Ford nicht archivieren darf, als allgemeine Ausnahme benennen (Chef entscheidet: Archivieren am Rechner selbst oder Berechtigung).
3. **D40.3 (gering):** Sokrates ohne „Kosten auf:“ in der Übergabe wird jetzt stumm als „Betrieb“ gebucht und archiviert; vorher WARNUNG und kein Archivieren (197). Satz 4 sagt „bleibt eigene Regel“: Warnung wieder einbauen.
4. **D40.4 (gering): PR-Abo nur in Prosa.** `lauf.py` kennt keine Abos, Ford hat keine Datenquelle; Titel wie „Jerry – PR #137 …“, „259 … PR #140 abonniert“ zeigen, dass es vorkommt. Billig: steht „PR #“ im Titel, vor ARCHIVIERE eine Zeile „PR-Abo prüfen, an die neuere Sitzung übergeben“.
5. **D40.5 (gering): Alt-Reste.** `ARBEIT-PROJEKT.md` Zeile 261.3 samt „Zu 261.3“ („eine ruhende Sitzung bleibt offen, Probe bis 27.10.“) widerspricht 261.5 und fällt; `docs/chefsache/README.md` führt 261.3 noch so; in Fords Übergabe steht „Tom ‚Build 48 Rückmeldung‘ hält PR #136“, die Sitzung ist archiviert.
**Nicht geprüft:** ob Ford `WEITER` per `send_message` in der Praxis zugestellt bekommt (die Plattform lehnte Aufgaben an gestartete Sitzungen früher ab; Rückfall START ist eingebaut); Fords Ausführung der Zeilen (das ist die Beobachtung nach der Umsetzung).
**Vermerk Perikles (21.10.):** D40.1–D40.5 umgesetzt (Übergabe 261.5 in `ARBEIT-PROJEKT.md`); offen bleibt die Beobachtung, ob Ford ARCHIVIERE ausführt (261.5 bis 24.10.).

## Kosten

Je Lauf eine Zeile, neueste oben; ältere im Archiv.
