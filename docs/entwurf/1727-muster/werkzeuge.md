# 1727, Werkzeuge: ändern, neu, entfällt (Fassung 4, nach Nachprüfung 20:22, mit Fundstellen-Raster)

Chef 21.11., 15:39: „dann brauchen wir noch eine Übersicht, welche Werkzeuge wir aktualisieren müssen … Und zwar komplett, was wir alles brauchen, neu.“ Rahmen: umgeschaltet wird erst nach Falltest und grünen Werkzeugen (VA „Schleifen und Hänger“ 21.11., 14:37); Werkzeuge nebenher (VA „Gesamtbetrachtung und Reihenfolge“ 21.11., 11:17; RF:18).

**Quellen** (Stand `main` 21.11., 20:29, `c616a909d`; in Fassung 4 neu genannte Zeilen in `tools/` nach diesem Stand, seit der Nachprüfung 20:22 verschoben durch 1762 `34de71832` und 1763 `17623dce7`; ältere Angaben nach ihrem Prüfstand; Kürzel, Zahl = Zeile): G = `docs/entwurf/1727-gesamtbild.md` (7 = G:901–911, Bauliste 7.1 = G:913–923) · VA = `docs/VORGANGSARCHIV.md`, genannt nach Eintragsname mit Datum und Uhrzeit (Zeilen wandern) · BER = `docs/ARBEIT-BERATUNG.md` · in `1727-muster/`: PP = `prozesspruefung-21-11.md`, RF = `reihenfolge.md`, GB = `gesamtbetrachtung.md`, BG = `buero-gegenueberstellung.md`, FB = `fehlerbuch.md`, SI = `signale.md`, BK = `build-kette.md`, PT = `profil-technik.md`, EA = `ein-ausgang.md`, AB = `ablauf.md`, KP = `katalog-pruefung.md`, P20 = `pruefung-20-11.md`, P20A = `pruefung-20-11-abend.md` · Bestand: `tools/<Datei>:Zeile`, `.claude/settings.json` (S), `.github/workflows/` · Vorgänge (`docs/LISTE-VORGAENGE.md`): Spike 1739, 1742, 1760 („gebaut, Geprüft an: b40f2d8b2“), 1738, 1732, 1751, 1749, 1762 („gebaut, Geprüft an: 34de71832“), 1763 („gebaut, Geprüft an: 17623dce7“), 1764, 1766; **Jerry 1765** (Chef 21.11., 20:20 „Jerry, ja“: Build-Werkzeug, Kerntest-Haken, „dazu ganz commit-pruefung.py, godot.yml, buildzweig-haken.py (aus 1739)“); Perikles 1767 (Texte Büro/Routinen, gebaut).

Lesart: „vor Umstellung“ = Bedingung „jedes Werkzeug grün“ (RF:18, VA „Schleifen und Hänger“ 21.11., 14:37); „ja“ nur mit Beleg, sonst „Vorschlag“ oder „unbelegt“. „1739 (7.1)“ = 1739 verweist auf die Bauliste („Liste Gesamtbild 7.1“), nennt die Zeile nicht selbst. G:502 ist ein „Gedanke Sokrates 21:03, ungeprüft, offen“: was nur auf G:502 steht, gilt als Vorschlag.

Zahlen: A 40, B 16, C 24, D 41 Einträge. Gezählt wird je Zeile (A, B, C) bzw. je genannter Datei, Ordner oder Workflow (D); der Sammelposten „übrige `*_test.py`“ zählt nicht mit (folgen ihrem Werkzeug). Prüfnetz für Vollständigkeit: Anhang „Fundstellen-Raster“.

## A Ändern (40)

| Werkzeug | kann heute | muss künftig zusätzlich/anders | wegen | vor Umstellung? | Vorgang |
|---|---|---|---|---|---|
| `tools/lauf.py` | START, WEITER, ARCHIVIERE, Kosten, Besetzung, Tagesbericht, Stillstand, Nachfolger aus den Vorräten (`lauf.py`:9–70); Rollen fest (`:133`, `:164`); Sokrates „nie“ gestartet (`:56`); Archivschutz nur 60 s (`:782`), 15 Minuten nicht gefunden; Bremse Vorentscheide gebaut (`abgleich.py`:9, :43–74, Aufruf `lauf.py`:1007–1011); Wochentermine (Wochenzählung, Ideenspeicher) legt `startbar.py`:162–180 `WOCHENTERMINE` an, `lauf.py`:680 startet; Kern der Rollendatei in jede START-Zeile (`kern`, `mit_kern` `:101–128`, 1683); Marke „Lauf läuft bis“ oben im Vorrat hält Start und Archiv an (`lauf_laeuft` `:397–440`, 1148); `MODELL` je Rolle (`:133`) | 7.1: Takt, Prüfer, Rückläufer 1./2. Nein, Eilt vor Muss vor Kür, Themenblöcke, Doppelstart, Folgeauftrag an dieselbe Fachkraft, Schutz 15 Min., laut ab 3 roten Läufen, kein Start ohne „Zurück“; dazu **C** Sokrates starten bei „steckt fest“, „Frage“, „wirkt nein“; **Laufbremse**; **Höchstdauer je Auftrag** auch bei `working`; Starter Wochenzählung, Ideenlauf umbauen (Rolle → Bereich/Sokrates bewertet, L-T5), Rundblick neu; Leistungsstufe Mittel/Hoch; Nachfolger nicht mehr aus Vorräten; Rufname im Titel; Zeitmarke je Lauf für den Herzschlag (B); Kern aus dem Profil statt aus `ROLLE-*.md`; „Lauf läuft bis“ aus Vorgangsdatei oder Besetzung statt Vorrat; Modell nach Leistungsstufe je Auftrag statt `MODELL` je Rolle | G:919; VA „Schleifen und Hänger“ 21.11., 14:37 (C); G:911, VA „Laufbremse und Richtung“ 19.11., 13:02 (Laufbremse); VA „Dollar-Freigabe weg“ 20.11., 08:19, EA L-O17; EA L-T5, L-O7, L-T7, L-O15; G:441 (nach 1742); PP:23; VA „Rufname je Sitzung“ 20.11., 07:57; AB:24 (Herzschlag) | ja: Kern Büro gilt erst, wenn 7.1 gebaut (VA „Kern Büro schlank“ 19.11., 19:37); C entschieden (VA „Schleifen und Hänger“ 21.11., 14:37) | 1739 (7.1); C 1763 gebaut (`17623dce7`, `sokrates_zeilen` `:507–528`, Aufruf `:1129`); Laufbremse, Höchstdauer, Starter 1766; Zeitmarke 1764; Ideenlauf-Umbau: **Vorgang fehlt** |
| `tools/vorgang.py` | lesen, `neu`, `stand`, `warte`, `setze`, `klasse M\|K`, `rang`, `ordnen`, `fertig`, `greift`, `bautest`, `build`, `pruefen` (`vorgang.py`:4–36); Wächter legt „Systemlösung?“ für Sokrates an (`:477`); `--hilfe` „nichts gefunden“ (Aufruf 15:43); **Übergabezeilen gebaut** (1760, `b40f2d8b2`: `uebergabe`, `annehmen`, `verlaengern`, `erledigt`, `freigeben`, `offen` über `uebergabe.py`, `:35–38`, `:789–790`); **Rückmeldung und Obergrenzen A/B gebaut** (1763, `17623dce7`: `vorgang.py rueckmeldung` über `rueckmeldung.py`, `:41–43`, `:793–794`); `chefwort` (1762, `:39–40`); liest die Vorräte: Übergabe-Zeile im Vorrat für die Fertig-Sperre 1143 (`rest_offen` `:252–272`), „Zu NR“-Absätze bei `fertig` (`:299`), `zu_absatz` (`:587`), Ansicht je Nummer (`:726`), Pause in der Ansicht (`:742`); Leerlauf-Warnung 1604 siehe C | 7.1: `--hilfe`, `auftrag <Nr>` (Felder, Pflicht „Zurück“, etwa 2 KB), `schliessen` mit Grund, Vorgangsdatei, Fund des Chefs markieren, ab 4. Eilt Hinweis, Wächter auf jedes Nein und jeden Fund, Lehrenbuch (`auftrag` sucht nach Bereich, Treffer in die Vorgangsdatei, `lehre suche`, roh anhängen, zuordnen mit Sperre, Wirkungsvergleich), „wartet auf“ leeren; Rest zu Übergabezeilen: „nächste Zeile nach erstem Wort“ (in `uebergabe.py` nicht gefunden); Vorrats-Leseorte auf die Vorgangsdatei (Übergabe, „Zu NR“, Pause); Chefwort fremder Sitzung eintragen; Obergrenzen **A** und **B** gebaut (1763, siehe links); Klasse Eilt; Katalog fester Werte (Herkunft, Art Probe/Recherche); Wächter-Zeile an den Disponenten; Sperre Rangfolge Belege; „Nachfolger:“ über `vorgang.py`; `--rolle` → Bereich/Profil | G:920; G:371–376, VA „Übergabekette“ 21.11., 10:11; VA „Schleifen und Hänger“ 21.11., 14:37; VA „Stufen Eilt, Muss, Kür“ 19.11., 11:44; G:97, KP:46; VA „Systemrunde fällt“ 20.11., 10:27; VA „Rangfolge der Belege“ 19.11., 21:12; PP:29 Nr. 4; P20:8 | ja (VA „Kern Büro schlank“ 19.11., 19:37, VA „Übergabekette“ 21.11., 10:11); Lehrenbuch-Teile: offen (VA „Lehrenbuch“ 21.11., 14:19: wer sucht, trägt ein, gibt vor) | 1739 (7.1); Übergabe 1760 gebaut (`b40f2d8b2`); Querschnitt 1751; A/B 1763 gebaut (`17623dce7`); Chefwort 1762 gebaut (`34de71832`); Katalog, Lehrenbuch, Vorrats-Leseorte: **Vorgang fehlt** |
| `tools/uebergabe.py` (neu, 1760) | Übergabezeile mit Quittung und Frist in `docs/vorgang/<Nr>.md`; Empfänger `AN` ist eine Rolle (Kopf `:4–13`); Kennungen frisch aus `ARBEIT-BESETZUNG.md`, Spalte 1 = Rolle (`besetzung` `:157–166`); ohne Sitzung „Start über den Disponenten (Ford)“ (`:182`) | `AN` als Bereich/Rufname/Arbeitsplaner statt Rolle; Besetzung nach Rufname; Text ohne „(Ford)“ | 0c, G:128 (Rollen fallen); VA „Rufname je Sitzung“ 20.11., 07:57; G:502 (Besetzung bleibt) | Vorschlag ja (sonst weckt die Übergabe keine Rufnamen-Sitzung) | 1760 (Rest); 1739 („Rollennamen in tools/“) |
| `tools/rueckmeldung.py` (neu, 1763, Raster) | Rückmeldung wörtlich in die Vorgangsdatei, Obergrenzen A/B, Zeile an Sokrates bei „steckt fest“, „Frage“, „wirkt nein“ (Kopf `:1–15`); `SOKRATES = "Sokrates"` (`:25`); Aufruf `--sitzung ROLLE` (`:5`) | `--sitzung` mit Rufname statt Rolle; Sokrates bleibt (C) | 0c, G:128; VA „Rufname je Sitzung“ 20.11., 07:57 | Vorschlag (mit den Rufnamen, Schritt 3) | 1739 („Rollennamen in tools/“) |
| `tools/meldung.sh` | lautlos/laut, Bild, Film; **nachts nie laut besteht** (`meldung.sh`:105–107); Bildvergleich-Wächter (`:57`); Bild nur mit Chefsache-Datei (`:152`) | Telegram-Regel vor der ersten Meldung je Sitzung; Rufname mit Vorgang im Namen; Zeile „enthält alle früheren Builds: ja“ (liefert das Build-Werkzeug) | VA „Sockel acht Zeilen“ 19.11., 13:58; G:921; VA „Rufname je Sitzung“ 20.11., 07:57; BK 6 | ja (7.1, VA „Kern Büro schlank“ 19.11., 19:37) | 1739 (7.1); Zeile „enthält alle früheren Builds“ 1765 (Jerry) |
| `tools/commit-pruefung.py` | pre-commit in Notiz- und Arbeitskopie (`notiz.sh`:91); Kerntest-Marke nur **Warnung** (`commit-pruefung.py`:201–209, 388); „Gegengelesen: <Rolle>“ und „nie das eigene Team“ (`:565–571`) | Code-Commit ohne grünen Kerntest hält an, für jede Fachkraft mit Code; Spielcode-Pfade auf `main` nur über Buildzweig; Rollennamen; „Gegengelesen“ und „nie das eigene Team“ umbauen (Rufname bzw. Bereich statt Rolle und Team); Vorratsprüfung und ROLLE-Obergrenze siehe C | G:922; PT:49; BK 4, G:923; P20:8 | ja (7.1) | 1765 (Jerry), ganze Datei samt Gegengelesen-Umbau und C-Teilen (aus 1739) |
| `tools/buildzweig-haken.py` | Muster `claude/build-\d+` (`:13`, `:73`); unbekannte Rolle lässt durch; Besitzer Spike (`:2–5`) | Muster `claude/build-\S+`, unbekannte Rolle hält an; „Spike“ → Build-Macher | BK 2; PT:33; G:923 | ja (7.1) | 1765 (Jerry, aus 1739) |
| `.github/workflows/godot.yml` | baut nur `claude/tom-348-**`, `jerry-348-**`, `build-**` (`godot.yml`:8); holt `waffen.py` vom Teamzweig `claude/jerry-348-kampf`, wenn sie im Zweig fehlt (`:357–359`, `:387`; Raster); Handstart-Felder mit Rollennamen in der Beschreibung (`:16–41`) | Kerntestlauf auf `main` nach jedem Merge; Zweigmuster ohne Teamnamen (Vorschlag: Zweig je Vorgang, G 0a); Vorschlag: `waffen.py` nur aus dem eigenen Stand (liegt auf `main` unter `tools/blender348/`), sonst hängt der Bau am alten Teamzweig; Beschreibungen ohne Rollennamen (nur Text) | BK 4; G:923 „Lauf auf `main` fehlt“ | ja (7.1) | 1765 (Jerry), ganze Datei samt Zweigmuster (aus 1739) |
| `.github/workflows/godot-kampf.yml` | Regeltest MARS nur auf `claude/jerry-348-**` (`godot-kampf.yml`:7) | Zweigmuster ohne Teamnamen wie `godot.yml` | wie `godot.yml` (G 0a); Rollen fallen (0c, G:128) | Vorschlag ja (sonst läuft der Regeltest auf keinem neuen Zweig) | **Vorgang fehlt** (7.1 nennt nur den Lauf auf `main`) |
| `.github/workflows/tom-probe.yml` | Probefilm nur auf `claude/tom-431-**`, `tom-416-4-**`, `tom-376-1-heldin` (`tom-probe.yml`:8); Handstart | Zweigmuster ohne Teamnamen oder Handstart allein | Rollen fallen (0c, G:128); nicht stilllegen, weil 431 offen (Tom, startbar) | Vorschlag (Handstart bleibt nutzbar) | **Vorgang fehlt** |
| `.github/workflows/spike-probe-4552.yml` | Größenfilm nur auf `claude/spike-455-2-**` (`spike-probe-4552.yml`:9); Handstart | Zweigmuster ohne Teamnamen oder Handstart allein | Rollen fallen (0c, G:128); nicht stilllegen, weil 455.2 offen (Jerry, „zu testen“) | Vorschlag (Handstart bleibt nutzbar) | **Vorgang fehlt** |
| `tools/neustart-haken.py` | Uhr-Haken; Größenbremse 200/300 Tsd., Sokrates 400/500; liest „Ford (aktuell)“ (`:78–86`) und „Nie archivieren“ (`:182–189`) aus `ARBEIT-BETRIEB.md`; erkennt die Rolle an `ROLLEN` (`:75`, Treffer `:128–130`); Ford ohne Erinnerung und Sperre (`:233`, `:325`); ab der Sperre frei: Vorräte `ARBEIT-*` (`FREI_DATEI` `:265`, `:302`); ruft seit 1762 `chefwort.haken()` (`:9`, `:217–218`); Vorrats-Größenwarnung siehe C | Bremse schrumpfen auf Sperre ohne Erinnerungstext, misst auch Folgeaufträge; Fachkraft etwa 100 Tsd.; Grenzen nach Profil statt Rolle (`ROLLEN` → Rufname/Profil); Leseorte ohne `ARBEIT-BETRIEB.md`; Sperr-Ausnahme auf die Vorgangsdatei statt `ARBEIT-*`; Ford-Ausnahme → Disponent | G:905–906; G:373 (3.3 F2 Nr. 4); 0c, G:128; G:502 (Vorräte → Vorgangsdateien, Vorschlag) | Vorschlag ja („bei Umsetzung“, G:906) | **Vorgang fehlt** (1537 baute Erinnerung und Sperre an jedem Werkzeugaufruf, 1520; Umbau fehlt) |
| `tools/startbar.py` | Startbares je Rolle (`BESITZER`), Automatik A, Klassen M/K/M?; liest die Vorräte für „Pause bis“/„Halt nur für“ (`:6–8`, `:34`, `:960`, `:1117–1160`), `VORRAT["Ford"]` = `ARBEIT-BETRIEB.md` (`:34`); legt „Zusammenführen“ bei Sokrates an (`:402–413`) | Reihenfolge Fund des Chefs, Eilt, Engpass, Wiederholer, Alter, Fristen je Stufe, Themenblock-Reihenfolge, Eingangszeit; Besitzer → Bereich/Profil; „wartet auf“ vererbt Klasse bleibt; Pause/Halt aus den Vorräten fällt mit den Vorräten; „Zusammenführen“ bei Sokrates fällt mit der Build-Kette bzw. 235 | BG Zeile „Vorrang“; VA „Stufen Eilt, Muss, Kür“ 19.11., 11:44; G:470 (4.4); VA „Profil Technik; 235 ersetzt“ 21.11., 15:15 | ja (rechnet Vorrang für `lauf.py`) | 1739 („Rollennamen in tools/“) |
| `tools/notiz.sh` | Rolle aus `ROLLE-BETRIEB.md`, sonst „unbekannt“ (`:17–21`); Startwarnungen, Rollenspiegel (`:85`) | Modell und Aufwand beim Start; Rufname/Profil statt Rolle; Rollenspiegel-Aufruf weg | VA „Startmeldung mit Modell und Aufwand“ 20.11., 13:13; 1742; VA „Rufname je Sitzung“ 20.11., 07:57; VA „340 Rollenspiegel und 621 A Probelauf fallen“ 19.11., 10:53 | Vorschlag ja (ohne Rollendatei kein Name) | 1742; 1739 |
| `tools/startsperre-haken.py` | lässt `create_session` nur nach Startsperre je Rolle im Protokoll von `ARBEIT-BETRIEB.md` durch; liest `HOCH_BIS` aus `lauf.py` (`:71`), Aufwand je Rolle (`:10–11`, `:82`); Nachtsperre 1643 nach Rolle im Titel (`:87–96`) | Sperre bleibt (Starts beim Disponenten), Ort ohne `ARBEIT-BETRIEB.md`-Protokoll, Rufname statt Rolle; Aufwandsprüfung → „Leistungsstufe je Auftrag“; Nachtsperre ohne Rolle im Titel | G:374 (3.3 F2 Nr. 5); G:502 („Protokoll fällt“); G:441 (Leistungsstufe) | Vorschlag ja (Protokoll fällt laut G:502, ungeprüft) | 1739 (Rollennamen); Quelle `ARBEIT-BETRIEB.md`: **Vorgang fehlt** |
| `tools/kosten.py` | Kosten je Rolle aus dem Sitzungstitel (`kosten.py`:58) | Kosten nach Bereich und Profil | P20:8; G:469 (4.4) | ja (Titel ohne Rolle) | 1739 („Kosten in drei Teilen“) |
| `tools/kostenbericht.py` | je Bereich, Teilbereich, Tag, Woche; Ford, `ARBEIT-BETRIEB.md` | drei Teile Spiel (E, G), Qualität (Q), Verwaltung (B, M); Qualitätskosten Prüfen gegen Nacharbeit | VA „Qualität eigener Kostenteil“ 20.11., 09:45; G 6d Nr. 6 | unbelegt (Wochenzählung braucht es) | 1739 |
| `tools/tagesbericht.py` | zehn Zahlen nach `ARBEIT-TAGESBERICHT.md`, Rest von Hand Perikles | Routine Tagesbericht (Sitzung nur Wertungssätze); Wochenguthaben; Vorschlag: Testbitte-Erinnerung nach 5 Tagen, Vorgang ohne Auftrag nach 1 Tag (Fristen sind Annahmen, AB:3) | G:484; VA „Dollar-Freigabe weg“ 20.11., 08:19; AB:19; AB:9 | unbelegt; Text fehlt (EA L-O8) | **Vorgang fehlt** |
| `tools/bereiche.py` | 16 Bereiche | „E Kataloge“, „G Regeln“ mit der Umsetzung; Lehrenbuch sucht nach Bereich | VA „Bereich und Fachprofil Kataloge“ 20.11., 08:21; VA „Teilbereich G Regeln“ 20.11., 09:27; FB:17 | ja (Katalog, Lehrensuche) | **Vorgang fehlt** |
| `tools/startwarnung.py` | Warnung mit festem Besitzer je Rolle, nach 6 h Vorgang; Stand in `startwarnung-stand.json` (`:22`); schreibt den Vorgangszähler in `ARBEIT-BETRIEB.md` (`:197`, `:245`) | Besitzer → Disponent bzw. Bereich | 0c, G:128 (Rollen fallen); P20:8 | Vorschlag ja | 1739 (Rollennamen); Quelle `ARBEIT-BETRIEB.md`: **Vorgang fehlt** |
| `tools/rotbuch.py` | rote Tests 48 h, Wiederholer als Vorgang beim Besitzer; Besitzer aus dem Commit-Betreff (Tom, Jerry, Spike, sonst Ford; `:25`, `:120–132`) | Anlegen nach Bereich statt Rolle; Besitzer mit Rufnamen umbauen | P20:8; EA L-T6 (Muster) | Vorschlag ja | 1739 |
| `tools/regelcheck.py` | Regelabgleich; `--kurz` Pflegefehler der Vorräte | Vorratsprüfung entfällt; Vorgangsdatei prüfen | G:484 („Vorgangsdatei prüft das Werkzeug“) | unbelegt | **Vorgang fehlt** |
| `tools/nachtstarts.py` | zählt Startsperren der Nacht („Start <Rolle>“) aus `ARBEIT-BETRIEB.md` | Quelle ohne Protokoll; Vorschlag: aufgehen in Wiederwecken-Grenze (EA L-S2) | G:502 | unbelegt | 1739 (Rollennamen); Quelle `ARBEIT-BETRIEB.md`: **Vorgang fehlt** |
| `tools/chef_fund.py` | Fund des Chefs am Titel „Von Chef …“ | aus Feld „Herkunft“ lesen | G:920 (Fund markieren); KP:10 | Vorschlag | 1739 (7.1) |
| `tools/dashboard.py` | Muss je Rolle, Guthaben aus `ARBEIT-BETRIEB.md` | je Themenblock; Guthaben aus Tagesbericht | G:502 (Guthaben → Tagesbericht) | nein (Anzeige) | 1739 (Rollennamen); Quelle `ARBEIT-BETRIEB.md`: **Vorgang fehlt** |
| `tools/check-env.sh` | prüft `docs/ARBEIT-TEAM-TOM.md` (`:24`) | Verweis tauschen (Vorrat fällt) | 0c, G:128 | ja, sonst „Projektdateien unvollständig“ | **Vorgang fehlt** |
| `tools/weiter-haken.py` | Stop-Haken, liest Übergabe im Vorrat (`:5`, `:22`, `:48`) | siehe C; Vorschlag: Umbau zum Ende-Haken | G:111; EA L-O14 | unbelegt | **Vorgang fehlt** |
| `tools/zug-index.py` | „Wer wofür“ aus „## Rollen“ in `CLAUDE.md` (`:341–353`); feste Rollennamen (`:41`, `:224`); Abschnitt „Offen je Rolle“ (`:329`) | „Wer wofür“ aus Profilen bzw. Bereichen (Rollentabelle fällt); Namenslisten ohne Rollen; „Offen je Rolle“ → je Bereich/Themenblock | G:500 (Rollentabelle `CLAUDE.md` fällt); 0c, G:128 | Vorschlag ja (Chefsache-Übersicht zeigt sonst alte Rollen) | 1739 („Rollennamen in tools/“) |
| `.github/workflows/zug-index.yml` | Auslöser `docs/ARBEIT-*.md` (`zug-index.yml`:18); „Offen je Rolle“ stündlich (`:5`, `:19`, `:59`) | Auslöser Vorgangsdateien statt Vorräte; Abschnittsname wie `zug-index.py` | G:502 (Vorräte → Vorgangsdateien, Vorschlag); 0c | Vorschlag | **Vorgang fehlt** |
| `tools/ueberblick.py` | Themenblöcke (`:23`); feste `ROLLEN_REIHE` (`:165`); Sortierung „jetzt“, Muss, Kür, dann Rang beim Besitzer (Kopf `:9–12`) | Eilt einsortieren; Rang nach Bereich/Themenblock statt Besitzer; Rollenreihe weg | VA „Stufen Eilt, Muss, Kür“ 19.11., 11:44; 0c, G:128 | Vorschlag ja (Überblick steht in der Chefsache) | 1739 („Rollennamen in tools/“) |
| `tools/pruefliste.py` | Prüfliste `t<n>-….md` → JSON für den Reiter „Test“ (`:2–8`), Spalte Team (`:4`) | Grundlage für den Testbitte-Schreiber (B); Spalte Team → Bereich/Rufname; Vermerk: Spalte Team trifft Spielcode (`godot/skripte/pruefliste.gd`:218, `godot/tests/pruefliste_1020.gd`:30–32): Spielcode, Test des Chefs vor `main` | AB:19 (A13 nennt `pruefliste.py`); 0c | wie Testbitte-Schreiber | **Vorgang fehlt** (wie Testbitte-Schreiber) |
| `.claude/settings.json` | Haken: Start, Uhr, Größe, Buildzweig, Startsperre, Probelauf, Freigabe; Stop-Haken `weiter-haken.py`, `zug-haken.py` (`:67–81`); `deny` Force-Push (nur Präfix, `:19–21`); `autoMode.environment` (`:25–33`, Sätze `:27–31`): Billigung „in … `docs/ARBEIT-*.md`“ (`:27`), Ford archiviert stündlich (`:28`), Ford startet, sendet, archiviert, Trigger „Ford-Lauf“/„Ford-Wache“ (`:29`), Tom und Jerry laden Godot (`:31`) | neu eintragen: Haken D, Kerntest-Sperre, Stop „gepusht?“, ggf. Ende-Haken, Sperre Keystore; Probelauf-Haken und `weiter-haken.py` (C) austragen; `autoMode.environment`: Ford → Disponent, Tom/Jerry → Fachkräfte mit Godot, Billigung in Vorgangsdatei/Vorgangsarchiv statt `ARBEIT-*.md` | VA „Schleifen und Hänger“ 21.11., 14:37, D; G:922; G:908–909; VA „340 Rollenspiegel und 621 A Probelauf fallen“ 19.11., 10:53 | ja für D, Kerntest (VA „Schleifen und Hänger“ 21.11., 14:37, 7.1) | **Vorgang fehlt** (Schreiben braucht Chef: VA „797, add_repo im Auto-Modus“ 09.11., 21:38; VA „222.1“ 19.10., 17:04 und „222“ 19.10., 16:29; VA „235“ 20.10., 16:22, (b) „eine Sitzung darf sich dort keine Erlaubnisse schreiben“) |
| `tools/projektplan.py` | Tafel, Perikles übernimmt sie montags mit dem Wochenziel (`:5`) | ohne Wochenziel; Reihenfolge der Themenblöcke | VA „Wochenziel fällt weg“ 19.11., 17:44 | nein | **Vorgang fehlt**; siehe C |
| `tools/abgleich.py` | Abgleich der Notizen, nur WARNUNG-Zeilen; Bremse Vorentscheide (`:9`, `:43–74`); Besitzer aus `startbar.zeilen_liste()` (`:25`, `:29`); „Ford trägt jede WARNUNG ein“ (`:2`) | Besitzer → Bereich/Rufname; Eintragen ohne Ford (Disponent bzw. Bereich) | 0c, G:128 (Rollen fallen); P20:8 | Vorschlag ja (liest die Vorgangsliste über `startbar.py`) | 1739 („Rollennamen in tools/“) |
| `tools/zug-haken.py` | Stop-Haken, zählt nur (Anhalten seit 822 ab, `:2`); `--summe <Rolle>` (`:18`); Hinweis `vorgang.py --rolle <Rolle>` (`:251`) | `--summe` nach Rufname/Profil; Hinweis mit Bereich/Profil statt `--rolle`; Kopf siehe „Offen“ unter D | 0c, G:128; P20:8 | Vorschlag | 1739 („Rollennamen in tools/“) |
| `tools/figurenpruefung.py` (aus D, Raster) | Option `--homer` „nur die Namenswidersprüche (Liste für Homer, 1473)“ (`:7`, `:288`); Sperrklinke mit `figurenpruefung_bekannt.txt` | Option nach Inhalt benennen (etwa `--namen`), alter Name als Rückweg | 0c, G:128 (Rollen fallen) | nein (Option läuft weiter; kein Workflow ruft `--homer`) | **Vorgang fehlt** (Vorschlag: 1739 „Rollennamen in tools/“) |
| `tools/vorlage_pruefen.py` (aus D, Raster) | Torprüfung `entscheiden/`; Ausgabetext `STATT` „über den Vorrang Perikles, über Abläufe Sokrates per Vorentscheid“ (`:56`, ausgegeben `:81`, `:83`); Torprüfung über `probelauf.py` siehe C | Ausgabetext auf die neue Zuständigkeit (Bereich, Disponent, Sokrates) | 0c, G:128 (Rollen fallen) | nein (nur Text), mit dem Umschalt-Commit | **Vorgang fehlt** |
| `tools/gegenstaende.py` (aus D, Raster) | Ausgabetext der erzeugten Übersicht „Wer füllt: Jerry …; Tom …; Homer …“ (`:111–112`), Feldtext „(Homer)“ (`:35`) | Zuständigkeit nach Bereich statt Rolle | 0c, G:128 | nein (nur Text) | **Vorgang fehlt** |
| `tools/laufnachweis.py` (aus D, Raster) | Ausgabe „Grün im Lauf bestätigt Diogenes (1128.3)“ (`:270`) | Prüfer statt Diogenes | 0c, G:128 | nein (nur Text) | **Vorgang fehlt** |
| `tools/pruefbogen/chefbogen_pdf.py` (aus D, Raster) | Bogen für den Chef: „Perikles macht daraus die Vorgänge“ (`:107`) | Empfänger nach neuer Ordnung (Arbeitsplaner) | 0c, G:128 | nein (nur Text; trifft den Chef, darum vor dem nächsten Bogen) | **Vorgang fehlt** |

## B Neu (16)

| Werkzeug | kann heute | muss künftig | wegen | vor Umstellung? | Vorgang |
|---|---|---|---|---|---|
| **Haken D** (Chefwort aus fremder Sitzung) | — | Chefnachricht wörtlich mit Zeit über `vorgang.py` in die Vorgangsdatei, offene Zeile an den Arbeitsplaner (Vorschlag: bei „gut“ an den Disponenten, EA L-U15; Chefsache, ändert PT F12) | VA „Schleifen und Hänger“ 21.11., 14:37, D; G:376; PT:40–41 | ja (Kette 1 reißt sonst, EA „Wege“ 1) | 1762 (EA L-O3): **gebaut** `34de71832` (`tools/chefwort.py`, `vorgang.py chefwort`, Aufruf aus `neustart-haken.py`), scharf erst mit Datei `tools/1727-SCHARF` im Umschalt-Commit; Liste noch „startbar“; erkennt fremde Sitzungen an `ROLLEN` (`chefwort.py`:31) und liest die Besetzung über `uebergabe.py` (`:127`): mit den Rufnamen umbauen |
| **Herzschlag / Wache** | — | GitHub-Zeitplan prüft Zeitmarke von `lauf.py`, älter als 2 h → Telegram; Wache: „du bist dran“, Sitzung hängt, 3 rote Läufe; startet ein Werkzeug, nicht das Büro | AB:24; SI:28 S18; G:474–475; EA L-T1, L-O9 | Vorschlag ja (EA L-T1 „Pflicht“) | 1764 |
| **Build-Werkzeug** | — (Teile von Hand, PT:11) | Spitze `claude/build-<n>` gegen Auftrag; Pfadvergleich getestete Spitze gegen Merge, sonst Kerntests auf dem Merge; `merge-base --is-ancestor` früherer Builds; Zeile „enthält alle früheren Builds“; je gebilligtem Vorgang Commits auf `main` und nicht zurückgenommen (1566); Revert je Vorgang bei „Freigabe mit Einschränkungen“ (PT:39, 41); „verworfen“ als feste Archivzeile (PT:36) | G:923; BK 2, 4–6; PT:35–37, 48; VA „Profil Technik; 235 ersetzt“ 21.11., 15:15 | ja laut 7.1; bis dahin von Hand möglich (PT:11) | 1765 (Jerry); 1739 (7.1) |
| **GitHub-Regel** gegen Force-Push und Löschen der Buildzweige | — | Regel auf GitHub; stellt der Chef ein, der Build-Macher prüft vorher | PT:33; VA „Profil Technik; 235 ersetzt“ 21.11., 15:15 | unbelegt (PT:33 nennt keinen Zeitpunkt) | **Vorgang fehlt** (Einstellung des Chefs) |
| **Testbitte-Schreiber** (A13) | — | Testbitte aus dem Build-Auftrag als `chefsache/ansehen/t<n>.md` und Telegram; Grundlage `pruefliste.py` (A) | VA „Testbitte auch als Datei“ 19.11., 22:04; AB:19; G:136 | ja (Regel „Testbitten stellen die Teams“ fällt, 0c) | **Vorgang fehlt**, nicht in 7.1 |
| **Build-Auftrag B<n>** aus der Warteschlange | — | Auftrag mit Commit je Vorgang (Einfrieren); Auslöser „wann ein Build“ | BK 1; EA L-O5 (Vorschlag), L-O4; G:113 „in die Bauliste aufnehmen“ | Vorschlag; Regel entscheidet der Chef (SI:28) | **Vorgang fehlt** |
| **Rufnamen** | — | Vorname je Sitzung, Alphabet je Tag, nicht doppelt, ohne Spielfiguren und alte Rollen; Titel, Besetzung, Meldung | VA „Rufnamen im Alphabet“ 20.11., 08:04, VA „Rufname je Sitzung“ 20.11., 07:57; RF:13 (Sperrliste) | ja (Rollennamen fallen mit Umsetzung, VA „Rufname je Sitzung“ 20.11., 07:57) | 1739 („Rufnamen“) |
| **Umzug „Zu <Nr>“** → Vorgangsdateien | — | rund 210 Absätze aus zehn Vorräten in `docs/vorgang/<Nr>.md` | G:502; RF:10; P20A:11 | Vorschlag ja („Teil von Schritt 1 vor dem Falltest“, G:502, Gedanke ungeprüft) | **Vorgang fehlt** |
| **Umstellung Vorgangsliste** (wie `umstellung2752/`) | — | Besitzer Rolle → Bereich/Profil, Klasse Eilt, Katalogwerte, Rückweg `git revert` | BER:11 („Vorgänge unter Rollennamen auf Bereich umziehen“); RF:13; VA „Bereich und Themenblock“ 20.11., 07:47 | ja | **Vorgang fehlt** |
| **Größen- und Ladesummen-Skript** | — | Byte je Sockel, Kern, Profil, Summe je Sitzung, vorher/nachher | RF:7; VA „Kerne nicht aufblähen, Größe nennen“ 20.11., 16:49 | ja (Schritt 1) | **Vorgang fehlt** |
| **Lehrenbuch** `docs/LISTE-LEHREN.md` + Funktionen | — (Datei fehlt) | Datei anlegen; Funktionen in `vorgang.py` (Tabelle A) | VA „Lehrenbuch“ 21.11., 14:19; FB:16–40 | offen (VA „Lehrenbuch“ 21.11., 14:19: wer sucht, trägt ein, gibt vor); bis Werkzeug von Hand (FB:19) | **Vorgang fehlt** |
| **Ende-Haken** | — | meldet am Ende jeder Fachkraft-, Prüfer-, Arbeitsplaner-Sitzung dem Büro, auch nach Absturz | G:111 (Votum, nicht entschieden); G 0a Offen (4); EA L-O14 | unbelegt (nicht entschieden) | **Vorgang fehlt** |
| **Stop-Haken „alles gepusht?“** | — | hält Sitzungsende mit Ungepushtem an; dann fällt Sockel Zeile 7 | G:909; G:185 | nein (Sockel 7 trägt vorläufig, G:146) | **Vorgang fehlt** |
| **Sperre Keystore, Zugangsdaten, Force-Push, `main`** | Teil: S `deny` Force-Push (nur Präfix); `.gitignore` nur `local.properties` (G:908) | PreToolUse-Sperre; dann fällt Sockel Zeile 8 | G:908; G:186 | nein (Sockel 8 trägt vorläufig, G:146) | **Vorgang fehlt** |
| **Durchspielen ohne Handy** (Tester) | — | Godot ohne Bildschirm mit Skriptsteuerung, Durchspielbogen | G:861; P20:10 | nein (EA L-O13 geschlossen) | 1738 |
| **Stop-Haken Sokrates** „Votum ohne Gegengeprüft“ | — | Nachricht mit „Votum“ ohne Zeile „Gegengeprüft:“ hält an | Chef 19.11., 21:25 (Titel 1732); Wortliste RF:13, BER:11 | nein (nicht 1727-Pflicht) | 1732 |

Nicht als Werkzeug: 1749 (Präfix je Katalog für Wortschlüssel, Kür, „nichts bauen“): Frage zur Klärung, berührt später `bereiche.py`/Katalog; keine Zeile vor der Umstellung.

**Lücken aus EA ohne eigene Zeile:**
- **L-S1** („Beleg fehlt“ ohne Grenze): Vorschlag, das dritte „Beleg fehlt“ je Auftrag als Nein zu zählen (EA:57) → Zählung in `vorgang.py` (Obergrenze A/B) bzw. `lauf.py` (Laufbremse); nicht entschieden.
- **L-U14** („ruht“ mit Pflichtdatum): `startbar.py` kennt „ruht“ mit Datum im Feld (startbar:585, 658, 822), kein Pflichtdatum; Pflichtdatum in `vorgang.py stand` nur, wenn entschieden (Annahme AB:3, EA:69).
- **L-O6** (fremder Commit, zweites Rot): Vorschlag „Vorgänge zurück in die Warteschlange“ (EA:79) → Build-Werkzeug; nicht entschieden.
- **L-O16** (Frage an den Chef ohne Erinnerung): Vorschlag Erinnerung im Tagesbericht (`tagesbericht.py`), Antwort als offene Zeile an den Arbeitsplaner über Haken D (EA:89); Wiederaufnahme selbst macht `startbar.py` schon (startbar:588–590, 658).

## C Entfällt oder wird stillgelegt (24)

| Werkzeug, Teil | setzt voraus | Beleg |
|---|---|---|
| `tools/rollenspiegel.sh` | Rollen, 340 | VA „340 Rollenspiegel und 621 A Probelauf fallen“ 19.11., 10:53 („bei Umsetzung streichen“) |
| `tools/pflegehinweis.py` | Rollenspiegel-Zeilen | VA „340 Rollenspiegel und 621 A Probelauf fallen“ 19.11., 10:53 |
| `startbar.py` Spiegelzeilen (`LISTE-ROLLENSPIEGEL.md`, `:305`, `:793–808`) mit `startbar_spiegel_test.py` | 340 Rollenspiegel | VA „340 Rollenspiegel und 621 A Probelauf fallen“ 19.11., 10:53 |
| `startbar.py` Rollenspiegel-Wochentermine (`:168–170`) | 340 Rollenspiegel | VA „340 Rollenspiegel und 621 A Probelauf fallen“ 19.11., 10:53 |
| `lauf.py` Mittwochsrunde Rollenspiegel (`:27`, `:198–199`, `:945`, `:959`, `:1120–1138`) mit `lauf_spiegel_test.py` | 340, 1461 | VA „340 Rollenspiegel und 621 A Probelauf fallen“ 19.11., 10:53 |
| `startbar.py` Wochentermine „Perikles Wochenziel“ (`:165`) und „Perikles Haken-Frage Abnahmeliste als ansehen/-Datei (720)“ (`:167`) | Wochenziel, Perikles (Haken-Frage: Vorschlag, mit der Wochenzählung an Prüfer bzw. Routine, falls weiter gewollt) | VA „Wochenziel fällt weg“ 19.11., 17:44 |
| `tools/probelauf.py` und drei Haken in S, mit `probelauf_frei_test.py`, `probelauf_mess_test.py`, `probelauf_messfrage_test.py` | 621 A Probelauf | VA „340 Rollenspiegel und 621 A Probelauf fallen“ 19.11., 10:53; Ersatz Laufbremse in `lauf.py` (VA „Laufbremse und Richtung“ 19.11., 13:02) |
| Figurenstand-Sperre 513.1 in `probelauf.py` (`:1016–1042`) mit `tools/figurenstand.tsv` (nur von ihr gelesen) | fällt mit `probelauf.py` | VA „340 Rollenspiegel und 621 A Probelauf fallen“ 19.11., 10:53 streicht nur 621 A und 340, nicht 513 B (VA „513 B, ein Figurenstand und Mängel jetzt“ 03.11., 15:56): **Ersatz offen, Chefsache** |
| Torprüfung der Vorlagen über `probelauf.py` (`vorlage_pruefen.py`:8, `probelauf.py`:1056) | fällt mit `probelauf.py` | **Ersatz offen, Chefsache**; `vorlage_pruefen.py` selbst bleibt (D, `zug-index.py`:238) |
| `tools/vorratspruefung.py` | Vorräte, Perikles 1425 | G:484 („fällt mit den Vorräten“) |
| `commit-pruefung.py` Vorräte nach Besitzer und Größe (`:23`, `:29`, `:420–442`, `:640`, `:678`) | Vorräte | 0c (Vorräte fallen); G:484 |
| `commit-pruefung.py` ROLLE-*.md-Obergrenze (`:13`, `OBERGRENZE` `:187–188`) | Rollendateien | 0c, G:128 (Rollen fallen) |
| `startbar.py` Übernahme Tom↔Jerry 1364 (`:1183–1226`) mit `uebernahme_test.py` | Teams Tom, Jerry, Spike | G:130, G:498 („fällt; Disponent teilt jeden Auftrag zu“) |
| `vorgang.py` Leerlauf-Warnung 1604 „Spike/Tuffy ohne Muss“ (`:415–445`, `_muss_startbar`, `leere_entwickler`, `leer_text`; liest Pause aus den Vorräten) | Teams, Übernahme 1364, Zusatzentwickler | G:130, G:498 (Disponent teilt jeden Auftrag zu); 0c, G:128 |
| Zusatzentwickler Tuffy (`startbar.py`:37 `ZUSATZ`; `lauf.py`:38–41, :166, :401, Start des Zusatzentwicklers `:989–1031`; Test in `vorgang_last_test.py`) | Teams, Zusatzentwickler | 0c, G:128 (Rollen fallen) |
| `neustart-haken.py` Vorrats-Größenwarnung beim Start (`BESITZER_VORRAT` `:391–393`, `start` `:396–412`) | Vorräte, feste Besitzer je Vorrat | 0c (Vorräte fallen); G:484 („fällt mit den Vorräten“, wie `vorratspruefung.py`) |
| `lauf.py` „Kosten auf“ aus der Übergabe in `ARBEIT-BERATUNG.md` (`uebergabe_stand`, `kosten_auf` `:481–499`, 197) | Vorrat Sokrates | 0c (Vorräte fallen); Ersatz unbelegt (Vorschlag: Feld im Auftrag bzw. Vorgangsdatei) |
| `lauf.py` Nachfolger aus „Übergabe … Nachfolger:“ | Vorräte | `lauf.py`:57–61; PP:23 |
| `lauf.py` Freigabe ab 40 $ (Kostenzeile für Perikles), dazu Dollar-Schwelle in `startbar.py` (`:849–870`) mit `kostenschwelle_test.py` | 1538 | `lauf.py`:346–348; VA „Dollar-Freigabe weg“ 20.11., 08:19 |
| `lauf.py` „M? entscheiden“ für Perikles | Perikles, Wochenziel | `lauf.py`:53; G 0c; VA „Wochenziel fällt weg“ 19.11., 17:44 |
| `lauf.py` „Stillstand lösen“ und `TAGESBERICHT` an Perikles | Rolle Perikles | `lauf.py`:26, 54; G:484, G:486 (an Disponent bzw. Routine) |
| `lauf.py` ÜBERTRAGE in Vorrat | Vorräte | `lauf.py`:15; unbelegt, wohin (Vorschlag: Vorgangsdatei) |
| `weiter-haken.py` in heutiger Form | Übergabe im Vorrat | `weiter-haken.py`:5, 22; 0c (Vorräte fallen); Vorschlag Ende-Haken |
| `projektplan.py` Wochenziel-Tafel | Wochenziel, Perikles montags | `projektplan.py`:5; VA „Wochenziel fällt weg“ 19.11., 17:44 (Vorschlag: Zahlen je Block liefert `ueberblick.py`) |

Vorschlag (G:502, Gedanke ungeprüft): mittelbar fallen mit `ARBEIT-BETRIEB.md` (Zähler → Werkzeug, Protokoll fällt) die Leseorte in `lauf.py` (auch Schutz 1531, `:677`), `vorgang.py neu` (Vorgangszähler, Kopf `:10–11`, `:355`, `:448`), `neustart-haken.py` („Ford (aktuell)“ `:78–86`, „Nie archivieren“ `:182–189`), `startwarnung.py` (Zähler `:197`, `:245`), `startsperre-haken.py`, `nachtstarts.py`, `dashboard.py`, `kostenbericht.py`, `tagesbericht.py` (Tabelle A), `commit-pruefung.py` (`:7`), `regelcheck.py` (`:56`), `startbar.py` (`:34`), `weiter-haken.py` (`:93–101`); `ARBEIT-BESETZUNG.md` bleibt (G:502, G:473).

## D Bleibt unverändert (Nachweis „komplett“, 41)

25 Dateien: `alt_bilder.sh`, `art_weg_test.py`, `bereichslisten.py`, `bildmass.py`, `bildrate.py`, `bildvergleich.py`, `figuren.py`, `figurenpruefung_bekannt.txt` (Daten der Sperrklinke, auch in `godot.yml`:71, `godot-kampf.yml`:35; das Werkzeug selbst jetzt A), `freigabe-haken.py`, `glossar.py`, `hakenzahl.py`, `inhalt.py`, `kernregeln.txt`, `laufzeiten.py`, `menues_512b_blatt.py`, `namenpruefung.py`, `nummer_wort.py`, `reaktionen.py`, `regelwerte.py`, `setup-session.sh`, `story.sh`, `t` (Datei, Shellskript), `varianten504.py`, `vgl348.py`, `vorgangskosten.py`. 13 Ordner: `blender348`, `dinge`, `entwurf`, `gegenstaende`, `godot`, `karten`, `klang`, `pruef348`, `pruefbogen` (ohne `chefbogen_pdf.py`, A), `runner`, `schrift`, `sim444`, `umstellung2752` (Altlast 275.2, nur Vorlage: Rollennamen in `startbar_alt.py`:23, `umstellen.py`:16 bleiben, wird nicht ausgeführt). 3 Workflows: `godot-schluessel.yml`, `release-notes.yml`, `webseite.yml`.

Nicht gezählt: übrige `*_test.py` (folgen ihrem Werkzeug; `probelauf_*_test.py`, `startbar_spiegel_test.py`, `kostenschwelle_test.py`, `lauf_spiegel_test.py`, `uebernahme_test.py` siehe C); Datendatei `startwarnung-stand.json` folgt `startwarnung.py` (A), `figurenstand.tsv` fällt mit 513.1 (C). Aus D nach A verschoben (Raster): `figurenpruefung.py`, `gegenstaende.py`, `laufnachweis.py`, `vorlage_pruefen.py`, `pruefbogen/chefbogen_pdf.py`. Rollennamen nur in Kommentaren bzw. Herkunftsangaben (Begründung je Datei im Anhang): kein Umbau nötig, unbelegt ob P20:8 („rund 45“) sie mitzählt.

Offen: `zug-haken.py` (jetzt A) beschreibt im Kopf noch die Chefsache-Pflicht für Fragen und Empfehlungen (`:5–9`), gegen VA „Chefsache nur, wenn der Chef etwas tun kann“ (19.11., 13:02); das Anhalten ist seit 822 abgeschaltet (`:2`, `:213`), ob Kopf und Zählung angepasst werden, ist **offen**.

## Reihenfolge des Baus (Vorschlag)

1. **Grundlage Daten:** `bereiche.py` (Kataloge, Regeln) → Umstellungswerkzeug Vorgangsliste (Bereich statt Rolle, Eilt, Katalog) nur bauen und an einer Kopie testen; die Liste selbst stellt erst der Umschalt-Commit (Schritt 8) um, sonst brechen `startbar.py`, `lauf.py`, `abgleich.py`, `rotbuch.py`, `regelcheck.py` (275.2 kein Parallelbetrieb, `umstellung2752/README.md`:3) → `vorgang.py` Vorgangsdatei, `auftrag`, `schliessen`, `--hilfe`; Größen- und Ladesummen-Skript (RF:7). Alles andere liest diese Felder.
2. **Rest der Übergabe** in `vorgang.py`: Leseorte der Vorräte (Übergabe, „Zu NR“, Pause) auf die Vorgangsdatei, „nächste Zeile nach erstem Wort“, `uebergabe.py` auf Rufname/Bereich. Gebaut: Übergabezeilen (1760, `b40f2d8b2`, Test `uebergabe_test.py`), Obergrenzen A/B und C (1763, `17623dce7`, Test `rueckmeldung_test.py`), Haken D (1762, `34de71832`).
3. **Rufnamen** in einem Schritt: Werkzeug, Titel, Besetzung, Meldung; dazu die Rollennamen in `rotbuch.py`, `abgleich.py`, `zug-haken.py`, `zug-index.py`, `ueberblick.py`, `startwarnung.py`, `uebergabe.py`, `chefwort.py`, `neustart-haken.py` (`ROLLEN`, Ford-Ausnahme), `settings.json` `autoMode.environment` (Chef); Ausgabetexte (`vorlage_pruefen.py`, `gegenstaende.py`, `laufnachweis.py`, `chefbogen_pdf.py`, `figurenpruefung.py --homer`) mit dem Umschalt-Commit.
4. **`lauf.py`** auf Übergabezeilen, Klasse Eilt, C, Laufbremse, Höchstdauer, Routinen-Starter, Zeitmarke für den Herzschlag; dazu `startbar.py`, `startsperre-haken.py`, `kosten.py`, `notiz.sh` (1742).
5. **Haken:** D, Kerntest-Sperre, Buildzweig-Muster, Größenbremse; Eintrag in S.
6. **Build-Kette:** Build-Auftrag, Build-Werkzeug, `godot.yml` auf `main`, Teamzweig-Workflows (`godot-kampf.yml`, `tom-probe.yml`, `spike-probe-4552.yml`), Testbitte-Schreiber, `meldung.sh`-Zeilen.
7. **Wachen und Berichte:** Herzschlag/Wache (liest die Zeitmarke aus Schritt 4), `tagesbericht.py`, `kostenbericht.py`, Lehrenbuch-Funktionen.
8. **Umschalt-Commit:** Umstellung Vorgangsliste, Umzug „Zu <Nr>“, `check-env.sh`-Verweis und Stilllegung (C).
Gegenargument: Umzug und Liste früher, damit Werkzeuge an echten Daten testen; Abhilfe: an einer Kopie wie `umstellung2752/README.md`. Rückwärtsverträglich bis zum Umschalten (BER Zu 1739; `ARBEIT-TEAM-SPIKE.md`:6).

## Abgleich mit Bauliste 7.1

**In 7.1, aber anders als dort:** `meldung.sh` „nachts nie laut“ steht als nicht gebaut (G:921), ist aber gebaut (`meldung.sh`:107). `vorgang.py` „Akte `docs/akte/<Nr>.md`“ (G:920) ist veraltet: „Vorgangsdatei `docs/vorgang/<Nr>.md`“ seit VA „Bisher und Vorgangsdatei“ (19.11., 22:39). „Schutz 15 Minuten prüfen“: im Code nur 60 s gefunden (`lauf.py`:782); dazu gilt eine laufende Sitzung (WORKING/BLOCKED, ruhig unter 60 Minuten) als geschützt (`:718`), Sitzungen unter „Nie archivieren“ ganz (1531, `:677`, `:781`). Force-Push (G:908, Sperre in B): S `deny` (`:19–21`) fängt nur das Präfix `git push --force`/`-f`/`--force-with-lease`; `--force` hinten (`git push origin main --force`) und `+refspec` (`git push origin +main`) gehen durch.

**In A/B, fehlt in 7.1:** Haken D (**gebaut** `34de71832`, scharf mit Umschaltung), C in `lauf.py` (**gebaut** `17623dce7`) (EA L-O3) · Herzschlag/Wache (EA L-T1, L-O9) · Übergabezeilen 1760 in `vorgang.py` (PP:25; **gebaut** `b40f2d8b2`, offen nur der Rest, Schritt 2) · Obergrenzen A/B (**gebaut** `17623dce7`) · Laufbremse, Höchstdauer (nur in 7, G:911; Bremse Vorentscheide schon gebaut, `abgleich.py`:43–74) · Größenbremse (nur in 7, G:906) · Stop-Haken, Sperre Keystore (nur in 7, G:908–909) · GitHub-Regel Buildzweige (PT:33) · Testbitte-Schreiber A13 mit `pruefliste.py` · Build-Auftrag und „wann ein Build“ (G:113 verlangt die Zeile) · Rufnamen (RF:18 „auch Rufnamen“; in 1739) · Routinen-Starter umbauen (Wochenzählung, Ideenlauf), Rundblick neu · Ende-Haken (EA L-O14) · `startbar.py`, `notiz.sh` (1742), `startsperre-haken.py`, `kosten.py`/`kostenbericht.py`, `zug-index.py`, `ueberblick.py` (in 1739, nicht in 7.1) · Workflows mit Teamzweigen (`godot-kampf.yml`, `tom-probe.yml`, `spike-probe-4552.yml`), `zug-index.yml` · `tagesbericht.py`, `bereiche.py`, Umstellung Vorgangsliste, Umzug „Zu <Nr>“, Größenskript · `uebergabe.py` auf Rufnamen, `neustart-haken.py` (`ROLLEN`, Ford-Ausnahme, Sperr-Ausnahme `ARBEIT-*`), Vorrats-Leseorte in `vorgang.py` und `lauf.py` (Kern, „Lauf läuft bis“, `MODELL`), `autoMode.environment` in S · Ausgabetexte aus dem Raster (`vorlage_pruefen.py`, `gegenstaende.py`, `laufnachweis.py`, `chefbogen_pdf.py`, `figurenpruefung.py`) · Stilllegungen C (dazu neu: Vorrats-Größenwarnung, Leerlauf-Warnung 1604, „Kosten auf“).

**In 7.1, fehlt in A/B:** keine.

## Gegenprüfung 15:50, Wort Sokrates

Alle Befunde **stimmt**, eingearbeitet (Liste 1–13).

Nicht bestätigt bzw. abweichend: 9 „VA „235“ (b) falsch“: VA „235“ (20.10., 16:22), (b) enthält „eine Sitzung darf sich dort keine Erlaubnisse schreiben (Diogenes)“ und trägt den Satz mit; 797 steht unter VA „797, add_repo im Auto-Modus“ (09.11., 21:38), 222.1/222 unter VA „222.1“ (19.10., 17:04) und „222“ (19.10., 16:29), alle drei als Beleg eingetragen. 13 „Archivzeile verworfen (PT:35)“: steht auf PT:36; Revert je Vorgang auf PT:39 und PT:41. 5 Vorgangszähler: Kopf `vorgang.py`:10–11 (nicht nur :10); zusätzlich gefunden: `startwarnung.py` schreibt den Zähler (`:197`, `:245`). 12 Force-Push „geht durch“: aus der Präfixform der Regeln `Bash(git push --force:*)` abgeleitet, nicht ausprobiert. Ordner `t` in D ist eine Datei, nicht umbenannt.

## Nachprüfung 20:13, Wort Sokrates

Alle 13 Befunde und Einordnungen **stimmt**, eingearbeitet.

Nicht bestätigt bzw. abweichend:
- 3 Übernahme 1364 „G:923“: G:923 ist die Zeile Build-Werkzeug und nennt keine Übernahme; Beleg ersetzt durch G:130 und G:498 („fällt; Disponent teilt jeden Auftrag zu“).
- 3 Tuffy „`lauf_zweige_test.py`“: die Datei enthält „Tuffy“ nicht (nur Jerry-Zweige); Tuffy steht in `vorgang_last_test.py` und zusätzlich in `lauf.py`:38–41, :166, :401, eingetragen.
- D→A `abgleich.py` „`startbar.BESITZER`“: nicht gefunden; der Besitzer kommt aus `startbar.zeilen_liste()` (`:25`, `:29`), so eingetragen. „Ford trägt ein“ bestätigt (`:2`).
- 2 `WOCHENTERMINE` „:162–180“: Liste `:164–173`, davor Kommentar `:162–163`, Abfrage `:175–181`; Spanne stehen gelassen.
- 11 VA-Zeilen: alle durch Eintragsnamen mit Datum und Uhrzeit ersetzt. Dabei gefunden: das frühere „VA:65“ (Chefsache nur, wenn …, 19.11., 13:02) stand schon in Fassung 2 eine Zeile daneben (im Stand 15:16 Zeile 64; jetzt 65, weil seit 15:40 der Eintrag 20:06 „Teams nur fertigmachen, Werkzeuge jetzt“ oben steht).
- `umstellung2752`: nicht nach C, sondern Vermerk „nur Vorlage“ in D, weil B und die Reihenfolge `umstellung2752/README.md` als Muster nennen.

## Nachprüfung 20:22, Wort Sokrates

Alle 10 Befunde **stimmt**, eingearbeitet; Vollständigkeit ab jetzt über das Fundstellen-Raster.

Nicht bestätigt bzw. abweichend:
- 1 „Schritt 2 nur noch Obergrenzen A/B (1763) und Rest“: seit 20:27 ist auch 1763 gebaut (`17623dce7`, Liste „gebaut“: Rückmeldung, Obergrenzen A/B, C in `lauf.py`), seit 20:22 Haken D 1762 (`34de71832`); Schritt 2 heißt darum nur noch „Rest der Übergabe“, A, B, D und `lauf.py` entsprechend.
- 2 `uebergabe.py` „:135–160“: seit 1763 verschoben, jetzt `besetzung` `:157–166`, „Disponenten (Ford)“ `:182`.
- 4 `autoMode.environment` „:27–31“: stimmt für die vier Sätze; die Liste reicht `:25–33` (`:26` `$defaults`, `:32` add_repo ohne Rollenbezug, bleibt).
- 5 Zeilen in `neustart-haken.py` seit 1762 (+7 Zeilen, Aufruf `chefwort`) verschoben: `ROLLEN` `:75` (nicht :74), Treffer `:128–130`, Ford-Ausnahme `:233`, `:325`, `FREI_DATEI` `:265`, `:302`, `BESITZER_VORRAT` `:391–393`, `start` `:396–412`.
- 6 `vorgang.py` „„Zu NR“ :265, Fertig-Sperre 1143 :294“: :265 las die Übergabe-Zeile im Vorrat (`**Übergabe`), und zwar innerhalb der Fertig-Sperre 1143 (`rest_offen`); „Zu NR“ steht bei `fertig` (damals :294). Nach 1763 (+3 Zeilen): `rest_offen` `:252–272`, `fertig` `:299`, `zu_absatz` `:587`, Ansicht `:726`, Pause `:742`, 1604 `:415–445`.
- 7 `lauf.py` „Kern :100–110“: `kern` `:101–118` und `mit_kern` `:121–128`; „Lauf läuft bis :398–402“ ist nur der Kopf von `lauf_laeuft` (`:397–440`).
- 10 Tuffy „`lauf.py`:960–1004“: :960 ist die START-Zeile des Regelstarts, der Zusatzentwickler beginnt `:962` (Kommentar 433); nach 1763 `:989–1031`.
- Neu durch das Raster, nicht unter den 10 Befunden: `godot.yml` holt `waffen.py` vom Teamzweig `claude/jerry-348-kampf` (A); `rueckmeldung.py` (1763) und `chefwort.py` (1762) nennen Rollen (A bzw. B); fünf Ausgabetexte mit Zuständigkeit einer Rolle aus D nach A.

## Anhang: Fundstellen-Raster (grep, Stand `c616a909d`)

Befehl (aus der Wurzel der Arbeitskopie; zählt Trefferzeilen je Datei):

```
{ find tools -type f \( -name '*.py' -o -name '*.sh' -o -path tools/t \) ! -name '*_test.py' ! -path '*/__pycache__/*'
  echo .claude/settings.json; ls .github/workflows/*.yml; } | sort | while read f; do
  a=$(rg -c -w -e Ford -e Perikles -e Homer -e Diogenes -e Spike -e Tuffy -e Tom -e Jerry -e Sokrates "$f" || echo 0)
  b=$(rg -c -e 'ARBEIT-' -e 'BESETZUNG' -e 'ROLLE-' -e '## Rollen' -e 'claude/(tom|jerry|spike|tuffy)' "$f" || echo 0)
  echo "$f $a $b"; done
```

Ohne Datendateien heißt: nur `*.py`, `*.sh` und `tools/t`; nicht gezählt `*.md`, `*.json`, `*.txt`, `*.csv`, `*.tsv`, Bilder, `*.pyc`, `*.pdf` (Daten folgen ihrem Werkzeug, siehe D). Geprüft 250 Dateien (241 in `tools/`, `settings.json`, 8 Workflows), 120 mit Treffern.

Spalten: N = Treffer Namen, V = Treffer Vorrat/Besetzung/Rolle/Teamzweig, Teil = Einordnung in diesem Entwurf.

| Datei | N | V | Teil | Abweichung |
|---|---|---|---|---|
| `.claude/settings.json` | 3 | 1 | A | keine (Befund 4 eingearbeitet) |
| `.github/workflows/godot-kampf.yml` | 3 | 8 | A | keine |
| `.github/workflows/godot.yml` | 149 | 16 | A | Raster: Abruf `waffen.py` vom Teamzweig nachgetragen; Namen sonst in Beschreibungen und Kommentaren |
| `.github/workflows/spike-probe-4552.yml` | 1 | 1 | A | keine |
| `.github/workflows/tom-probe.yml` | 3 | 1 | A | keine |
| `.github/workflows/zug-index.yml` | 0 | 1 | A | keine |
| `tools/abgleich.py` | 1 | 0 | A | keine |
| `tools/bereiche.py` | 2 | 0 | A | keine (Namen in Bereichsbeschreibungen „Diogenes“, „Ford“ `:26–27`, gehen mit dem Umbau) |
| `tools/bildvergleich.py` | 1 | 0 | D | nur Kopf („über Sokrates“) → D ok |
| `tools/buildzweig-haken.py` | 9 | 2 | A | keine |
| `tools/check-env.sh` | 0 | 1 | A | keine |
| `tools/chef_fund.py` | 2 | 0 | A | keine |
| `tools/chefwort.py` | 2 | 1 | B (Haken D) | neu seit 20:22 (1762); `ROLLEN`, Besetzung nachgetragen |
| `tools/commit-pruefung.py` | 20 | 13 | A, C | keine |
| `tools/dashboard.py` | 2 | 1 | A | keine |
| `tools/figurenpruefung.py` | 2 | 0 | A (aus D) | Option `--homer` ist Bedienung, kein Kommentar → A |
| `tools/freigabe-haken.py` | 1 | 0 | D | nur Kopf („damit Diogenes sieht“) → D ok |
| `tools/gegenstaende.py` | 5 | 0 | A (aus D) | Ausgabetext der Übersicht nennt Zuständigkeit (`:111–112`) → A |
| `tools/hakenzahl.py` | 1 | 0 | D | nur Kopf (Aufruf-Hinweis) → D ok |
| `tools/kosten.py` | 9 | 0 | A | keine |
| `tools/kostenbericht.py` | 12 | 2 | A | keine |
| `tools/lauf.py` | 197 | 33 | A, C | Befund 7 eingearbeitet (Kern, „Lauf läuft bis“, `MODELL` A; „Kosten auf“ C) |
| `tools/laufnachweis.py` | 4 | 0 | A (aus D) | Ausgabe „bestätigt Diogenes“ (`:270`) → A; Rest Kommentare |
| `tools/meldung.sh` | 4 | 3 | A | keine |
| `tools/nachtstarts.py` | 2 | 2 | A | keine |
| `tools/neustart-haken.py` | 28 | 13 | A, C | Befund 5 eingearbeitet |
| `tools/notiz.sh` | 3 | 3 | A | keine |
| `tools/nummer_wort.py` | 1 | 0 | D | nur Kopf → D ok |
| `tools/pflegehinweis.py` | 4 | 10 | C | keine |
| `tools/probelauf.py` | 30 | 4 | C | keine |
| `tools/projektplan.py` | 1 | 0 | A, C | keine |
| `tools/pruefbogen/chefbogen_pdf.py` | 1 | 0 | A (aus D) | Text auf dem Bogen für den Chef „Perikles macht daraus die Vorgänge“ → A |
| `tools/pruefliste.py` | 2 | 0 | A | keine (Namen nur in Kommentaren; A wegen Spalte Team) |
| `tools/reaktionen.py` | 1 | 0 | D | nur Kopf → D ok |
| `tools/regelcheck.py` | 13 | 17 | A | keine |
| `tools/rollenspiegel.sh` | 6 | 1 | C | keine |
| `tools/rotbuch.py` | 12 | 0 | A | keine |
| `tools/rueckmeldung.py` | 5 | 0 | A | neu seit 20:27 (1763), nachgetragen |
| `tools/startbar.py` | 95 | 9 | A, C | Befund 8 eingearbeitet |
| `tools/startsperre-haken.py` | 6 | 4 | A | keine |
| `tools/startwarnung.py` | 14 | 11 | A | keine |
| `tools/story.sh` | 0 | 1 | D | nur Aufruf-Kommentar („Gelesen bis“ aus `ARBEIT-KREATIV.md`) → D ok |
| `tools/tagesbericht.py` | 9 | 7 | A | keine |
| `tools/ueberblick.py` | 13 | 4 | A | keine |
| `tools/uebergabe.py` | 1 | 4 | A | Befund 2 eingearbeitet |
| `tools/varianten504.py` | 1 | 0 | D | nur Kopf → D ok |
| `tools/vorgang.py` | 40 | 10 | A, C | Befund 6 eingearbeitet |
| `tools/vorgangskosten.py` | 1 | 0 | D | nur Kopf (Beispiel „Jerry 1,26 $“) → D ok |
| `tools/vorlage_pruefen.py` | 1 | 0 | A (aus D), C (Torprüfung) | Ausgabetext `STATT` nennt Perikles und Sokrates als Zuständige → A |
| `tools/vorratspruefung.py` | 12 | 4 | C | keine |
| `tools/weiter-haken.py` | 9 | 2 | A, C | keine |
| `tools/zug-haken.py` | 2 | 0 | A | keine |
| `tools/zug-index.py` | 8 | 2 | A | keine |
| Ordner `tools/blender348` (102 Dateien, 53 mit Treffern) | 136 | 0 | D | nur Kommentare und Herkunft in Prüffilm-Titeln (`v3/voelker_film.py` „(Jerry)“, „Homer: …“) → D ok |
| Ordner `tools/godot` (8, davon 4) | 19 | 0 | D | nur Kommentare → D ok |
| Ordner `tools/klang` (28, davon 1) | 1 | 0 | D | nur Kopf → D ok |
| Ordner `tools/pruef348` (23, davon 3) | 0 | 3 | D | Handskripte 348 holen feste Altzweige (`claude/jerry-348-kampf`, Kommentar `claude/tom-376-1-figuren`); laufen, solange die Zweige stehen (kein Löschen) → D ok, Altlast |
| Ordner `tools/pruefbogen` (3, davon 1) | 1 | 0 | D bis auf `chefbogen_pdf.py` (A) | siehe Zeile oben |
| Ordner `tools/sim444` (7, davon 4) | 7 | 1 | D | Köpfe und ein Berichtskopf mit Herkunft „Tuffy (Team Jerry) für Sokrates“, Zweig als Quellangabe (`sim.py`:1269–1270) → D ok |
| Ordner `tools/umstellung2752` (2, davon 2) | 34 | 5 | D | Vorlage, wird nicht ausgeführt (siehe D) → D ok |
| Ordner `dinge`, `entwurf`, `karten`, `runner`, `schrift` (8 Dateien) | 0 | 0 | D | – |
| 14 Dateien obere Ebene ohne Treffer (`alt_bilder.sh`, `bereichslisten.py`, `bildmass.py`, `bildrate.py`, `figuren.py`, `glossar.py`, `inhalt.py`, `laufzeiten.py`, `menues_512b_blatt.py`, `namenpruefung.py`, `regelwerte.py`, `setup-session.sh`, `t`, `vgl348.py`) und 3 Workflows (`godot-schluessel.yml`, `release-notes.yml`, `webseite.yml`) | 0 | 0 | D | – |

Ergebnis: jede Datei mit Treffern steht in A, B, C oder D; in D bleiben nur Dateien mit Treffern in Kommentaren, Köpfen oder Herkunftsangaben und die Vorlage `umstellung2752`. Aus D verschoben: `figurenpruefung.py`, `gegenstaende.py`, `laufnachweis.py`, `vorlage_pruefen.py`, `pruefbogen/chefbogen_pdf.py` (A). Neu aufgenommen: `uebergabe.py`, `rueckmeldung.py` (A), `chefwort.py` (B, Haken D). Grenze des Rasters: Namen in anderer Schreibung (Kleinschreibung wie `--homer` nur zufällig über den Kopf gefunden, `tuffy` in Zweignamen nur über das zweite Muster) und Rollen ohne Namen (etwa „Betriebsleiter“) fängt es nicht; der Bauer wiederholt es nach jedem Werkzeug-Commit.
