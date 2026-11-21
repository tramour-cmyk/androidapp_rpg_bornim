# 1727, Werkzeuge: ändern, neu, entfällt (Entwurf, Sokrates-Helfer 21.11.)

Chef 21.11., 15:39: „dann brauchen wir noch eine Übersicht, welche Werkzeuge wir aktualisieren müssen … Und zwar komplett, was wir alles brauchen, neu.“ Rahmen: umgeschaltet wird erst nach Falltest und grünen Werkzeugen (VA:6, 21.11., 14:37); Werkzeuge nebenher (VA:10, 11:17; RF:18).

**Quellen** (Stand `main` 21.11., 15:40; Kürzel, Zahl = Zeile): G = `docs/entwurf/1727-gesamtbild.md` (7 = G:901–911, Bauliste 7.1 = G:913–923) · VA = `docs/VORGANGSARCHIV.md` · BER = `docs/ARBEIT-BERATUNG.md` · in `1727-muster/`: PP = `prozesspruefung-21-11.md`, RF = `reihenfolge.md`, GB = `gesamtbetrachtung.md`, BG = `buero-gegenueberstellung.md`, FB = `fehlerbuch.md`, SI = `signale.md`, BK = `build-kette.md`, PT = `profil-technik.md`, EA = `ein-ausgang.md`, AB = `ablauf.md`, KP = `katalog-pruefung.md`, P20 = `pruefung-20-11.md`, P20A = `pruefung-20-11-abend.md` · Bestand: `tools/<Datei>:Zeile`, `.claude/settings.json` (S), `.github/workflows/` · Vorgänge: `vorgang.py --rolle Spike` (1739, 1742, 1760, 1738, 1732, 1751).

Lesart: „vor Umstellung“ = Bedingung „jedes Werkzeug grün“ (RF:18, VA:6); „ja“ nur mit Beleg, sonst „Vorschlag“ oder „unbelegt“. „1739 (7.1)“ = 1739 verweist auf die Bauliste („Liste Gesamtbild 7.1“), nennt die Zeile nicht selbst.

## A Ändern (24)

| Werkzeug | kann heute | muss künftig zusätzlich/anders | wegen | vor Umstellung? | Vorgang |
|---|---|---|---|---|---|
| `tools/lauf.py` | START, WEITER, ARCHIVIERE, Kosten, Besetzung, Tagesbericht, Stillstand, Nachfolger aus den Vorräten (`lauf.py`:9–70); Rollen fest (`:133`, `:164`); Sokrates „nie“ gestartet (`:56`); Archivschutz nur 60 s (`:782`), 15 Minuten nicht gefunden | 7.1: Takt, Prüfer, Rückläufer 1./2. Nein, Eilt vor Muss vor Kür, Themenblöcke, Doppelstart, Folgeauftrag an dieselbe Fachkraft, Schutz 15 Min., laut ab 3 roten Läufen, kein Start ohne „Zurück“; dazu **C** Sokrates starten bei „steckt fest“, „Frage“, „wirkt nein“; **Laufbremse**; **Höchstdauer je Auftrag** auch bei `working`; Starter Wochenzählung, Rundblick, Ideenlauf; Leistungsstufe Mittel/Hoch; Nachfolger nicht mehr aus Vorräten; Rufname im Titel | G:919; VA:6 (C); G:911, VA:63 (Laufbremse); VA:36, EA L-O17; EA L-O7, L-T7, L-O15; G:441 (nach 1742); PP:23; VA:40 | ja: Kern Büro gilt erst, wenn 7.1 gebaut (VA:53); C entschieden (VA:6) | 1739 (7.1); C, Laufbremse, Höchstdauer, Starter: **fehlt** |
| `tools/vorgang.py` | lesen, `neu`, `stand`, `warte`, `setze`, `klasse M\|K`, `rang`, `ordnen`, `fertig`, `greift`, `bautest`, `build`, `pruefen` (`vorgang.py`:4–36); Wächter legt „Systemlösung?“ für Sokrates an (`:477`); `--hilfe` „nichts gefunden“ (Aufruf 15:43) | 7.1: `--hilfe`, `auftrag <Nr>` (Felder, Pflicht „Zurück“, etwa 2 KB), `schliessen` mit Grund, Vorgangsdatei, Fund des Chefs markieren, ab 4. Eilt Hinweis, Wächter auf jedes Nein und jeden Fund, Lehrenbuch (`auftrag` sucht nach Bereich, Treffer in die Vorgangsdatei, `lehre suche`, roh anhängen, zuordnen mit Sperre, Wirkungsvergleich), „wartet auf“ leeren; dazu **Übergabezeilen** offen/angenommen mit Frist/erledigt, Kennung frisch, nächste Zeile nach erstem Wort; Chefwort fremder Sitzung eintragen; Obergrenze **A** (2. „nein, Auftrag“ oder 3. abgelehnter Auftrag → ruht, Chefsache) und **B**; Klasse Eilt; Katalog fester Werte (Herkunft, Art Probe/Recherche); Wächter-Zeile an den Disponenten; Sperre Rangfolge Belege; „Nachfolger:“ über `vorgang.py`; `--rolle` → Bereich/Profil | G:920; G:371–376, VA:11; VA:6; VA:66; G:97, KP:46; VA:31; VA:52; PP:29 Nr. 4; P20:8 | ja (VA:53, VA:11) | 1739 (7.1); Übergabe 1760; Querschnitt 1751; A/B, Katalog, Lehrenbuch: **fehlt** eigener |
| `tools/meldung.sh` | lautlos/laut, Bild, Film; **nachts nie laut besteht** (`meldung.sh`:105–107); Bildvergleich-Wächter (`:57`); Bild nur mit Chefsache-Datei (`:152`) | Telegram-Regel vor der ersten Meldung je Sitzung; Rufname mit Vorgang im Namen; Zeile „enthält alle früheren Builds: ja“ (liefert das Build-Werkzeug) | VA:61 (19.11., 13:58); G:921; VA:40; BK 6 | ja (7.1, VA:53) | 1739 (7.1) |
| `tools/commit-pruefung.py` | pre-commit in Notiz- und Arbeitskopie (`notiz.sh`:91); Kerntest-Marke nur **Warnung** (`commit-pruefung.py`:201–209, 388) | Code-Commit ohne grünen Kerntest hält an, für jede Fachkraft mit Code; Spielcode-Pfade auf `main` nur über Buildzweig; Rollennamen | G:922; PT:49; BK 4, G:923; P20:8 | ja (7.1) | 1739 (7.1) |
| `tools/buildzweig-haken.py` | Muster `claude/build-\d+` (`:13`, `:73`); unbekannte Rolle lässt durch; Besitzer Spike (`:2–5`) | Muster `claude/build-\S+`, unbekannte Rolle hält an; „Spike“ → Build-Macher | BK 2; PT:33; G:923 | ja (7.1) | 1739 (7.1) |
| `.github/workflows/godot.yml` | baut nur `claude/tom-348-**`, `jerry-348-**`, `build-**` (`godot.yml`:8) | Kerntestlauf auf `main` nach jedem Merge; Zweigmuster ohne Teamnamen (Vorschlag: Zweig je Vorgang, G 0a) | BK 4; G:923 „Lauf auf `main` fehlt“ | ja (7.1) | 1739 (7.1) |
| `tools/neustart-haken.py` | Uhr-Haken; Größenbremse 200/300 Tsd., Sokrates 400/500 | Bremse schrumpfen auf Sperre ohne Erinnerungstext, misst auch Folgeaufträge; Fachkraft etwa 100 Tsd.; Grenzen nach Profil statt Rolle | G:905–906; G:373 (3.3 F2 Nr. 4) | Vorschlag ja („bei Umsetzung“, G:906) | **fehlt** (1760 misst nur die Grenze) |
| `tools/startbar.py` | Startbares je Rolle (`BESITZER`), Automatik A, Klassen M/K/M? | Reihenfolge Fund des Chefs, Eilt, Themenblock-Reihenfolge, Eingangszeit; Besitzer → Bereich/Profil; „wartet auf“ vererbt Klasse bleibt | BG Zeile „Vorrang“; VA:66; G:470 (4.4) | ja (rechnet Vorrang für `lauf.py`) | 1739 („Rollennamen in tools/“) |
| `tools/notiz.sh` | Rolle aus `ROLLE-BETRIEB.md`, sonst „unbekannt“ (`:17–21`); Startwarnungen, Rollenspiegel (`:85`) | Modell und Aufwand beim Start; Rufname/Profil statt Rolle; Rollenspiegel-Aufruf weg | VA:26; 1742; VA:40; VA:67 | Vorschlag ja (ohne Rollendatei kein Name) | 1742; 1739 |
| `tools/startsperre-haken.py` | lässt `create_session` nur nach Startsperre je Rolle im Protokoll von `ARBEIT-BETRIEB.md` durch | Sperre bleibt (Starts beim Disponenten), Ort ohne `ARBEIT-BETRIEB.md`-Protokoll, Rufname statt Rolle | G:374 (3.3 F2 Nr. 5); G:502 („Protokoll fällt“) | ja (Protokoll fällt) | 1739 |
| `tools/kosten.py` | Kosten je Rolle aus dem Sitzungstitel (`kosten.py`:58) | Kosten nach Bereich und Profil | P20:8; G:469 (4.4) | ja (Titel ohne Rolle) | 1739 („Kosten in drei Teilen“) |
| `tools/kostenbericht.py` | je Bereich, Teilbereich, Tag, Woche; Ford, `ARBEIT-BETRIEB.md` | drei Teile Spiel (E, G), Qualität (Q), Verwaltung (B, M); Qualitätskosten Prüfen gegen Nacharbeit | VA:32; G 6d Nr. 6 | unbelegt (Wochenzählung braucht es) | 1739 |
| `tools/tagesbericht.py` | zehn Zahlen nach `ARBEIT-TAGESBERICHT.md`, Rest von Hand Perikles | Routine Tagesbericht (Sitzung nur Wertungssätze); Wochenguthaben; Testbitte-Erinnerung nach 5 Tagen; Vorgang ohne Auftrag nach 1 Tag | G:484; VA:36; AB:19; AB:9 | unbelegt; Text fehlt (EA L-O8) | **fehlt** |
| `tools/bereiche.py` | 16 Bereiche | „E Kataloge“, „G Regeln“ mit der Umsetzung; Lehrenbuch sucht nach Bereich | VA:35; VA:34; FB:17 | ja (Katalog, Lehrensuche) | **fehlt** |
| `tools/startwarnung.py` | Warnung mit festem Besitzer je Rolle, nach 6 h Vorgang | Besitzer → Disponent bzw. Bereich | 0c, G:128 (Rollen fallen); P20:8 | Vorschlag ja | 1739 |
| `tools/rotbuch.py` | rote Tests 48 h, Wiederholer als Vorgang beim Besitzer (Ford, Spike) | Anlegen nach Bereich statt Rolle | P20:8; EA L-T6 (Muster) | Vorschlag ja | 1739 |
| `tools/regelcheck.py` | Regelabgleich; `--kurz` Pflegefehler der Vorräte | Vorratsprüfung entfällt; Vorgangsdatei prüfen | G:484 („Vorgangsdatei prüft das Werkzeug“) | unbelegt | **fehlt** |
| `tools/nachtstarts.py` | zählt Startsperren der Nacht aus `ARBEIT-BETRIEB.md` | Quelle ohne Protokoll; Vorschlag: aufgehen in Wiederwecken-Grenze (EA L-S2) | G:502 | unbelegt | **fehlt** |
| `tools/chef_fund.py` | Fund des Chefs am Titel „Von Chef …“ | aus Feld „Herkunft“ lesen | G:920 (Fund markieren); KP:10 | Vorschlag | 1739 (7.1) |
| `tools/dashboard.py` | Muss je Rolle, Guthaben aus `ARBEIT-BETRIEB.md` | je Themenblock; Guthaben aus Tagesbericht | G:502 (Guthaben → Tagesbericht) | nein (Anzeige) | **fehlt** |
| `tools/check-env.sh` | prüft `docs/ARBEIT-TEAM-TOM.md` (`:24`) | Verweis tauschen (Vorrat fällt) | 0c, G:128 | ja, sonst „Projektdateien unvollständig“ | **fehlt** |
| `tools/weiter-haken.py` | Stop-Haken, liest Übergabe im Vorrat (`:5`, `:22`, `:48`) | siehe C; Vorschlag: Umbau zum Ende-Haken | G:111; EA L-O14 | unbelegt | **fehlt** |
| `.claude/settings.json` | Haken: Start, Uhr, Größe, Buildzweig, Startsperre, Probelauf, Freigabe; `deny` Force-Push | neu eintragen: Haken D, Kerntest-Sperre, Stop „gepusht?“, ggf. Ende-Haken, Sperre Keystore; Probelauf-Haken austragen | VA:6 D; G:922; G:908–909; VA:67 | ja für D, Kerntest (VA:6, 7.1) | **fehlt** (Schreiben braucht Chef, VA:1490 b) |
| `tools/projektplan.py` | Tafel, Perikles übernimmt sie montags mit dem Wochenziel (`:5`) | ohne Wochenziel; Reihenfolge der Themenblöcke | VA:55 | nein | **fehlt**; siehe C |

## B Neu (14)

| Werkzeug | kann heute | muss künftig | wegen | vor Umstellung? | Vorgang |
|---|---|---|---|---|---|
| **Haken D** (Chefwort aus fremder Sitzung) | — | Chefnachricht wörtlich mit Zeit über `vorgang.py` in die Vorgangsdatei, offene Zeile an den Arbeitsplaner (bei „gut“ an den Disponenten, EA L-U15) | VA:6 D; G:376; PT:40–41 | ja (Kette 1 reißt sonst, EA „Wege“ 1) | **fehlt** (EA L-O3) |
| **Herzschlag / Wache** | — | GitHub-Zeitplan prüft Zeitmarke von `lauf.py`, älter als 2 h → Telegram; Wache: „du bist dran“, Sitzung hängt, 3 rote Läufe; startet ein Werkzeug, nicht das Büro | AB:24; SI:28 S18; G:474–475; EA L-T1, L-O9 | Vorschlag ja (EA L-T1 „Pflicht“) | **fehlt** |
| **Build-Werkzeug** | — (Teile von Hand, PT:11) | Spitze `claude/build-<n>` gegen Auftrag; Pfadvergleich getestete Spitze gegen Merge, sonst Kerntests auf dem Merge; `merge-base --is-ancestor` früherer Builds; Zeile „enthält alle früheren Builds“; je gebilligtem Vorgang Commits auf `main` und nicht zurückgenommen (1566) | G:923; BK 2, 4–6; PT:35–37, 48 | ja laut 7.1; bis dahin von Hand möglich (PT:11) | 1739 (7.1) |
| **Testbitte-Schreiber** (A13) | — | Testbitte aus dem Build-Auftrag als `chefsache/ansehen/t<n>.md` und Telegram | VA:51 (19.11., 22:04); AB:19; G:136 | ja (Regel „Testbitten stellen die Teams“ fällt, 0c) | **fehlt**, nicht in 7.1 |
| **Build-Auftrag B<n>** aus der Warteschlange | — | Auftrag mit Commit je Vorgang (Einfrieren); Auslöser „wann ein Build“ | BK 1; EA L-O5 (Vorschlag), L-O4; G:113 „in die Bauliste aufnehmen“ | Vorschlag; Regel entscheidet der Chef (SI:28) | **fehlt** |
| **Rufnamen** | — | Vorname je Sitzung, Alphabet je Tag, nicht doppelt, ohne Spielfiguren und alte Rollen; Titel, Besetzung, Meldung | VA:39, VA:40; RF:13 (Sperrliste) | ja (Rollennamen fallen mit Umsetzung, VA:40) | 1739 („Rufnamen“) |
| **Umzug „Zu <Nr>“** → Vorgangsdateien | — | rund 210 Absätze aus zehn Vorräten in `docs/vorgang/<Nr>.md` | G:502; RF:10; P20A:11 | ja („Teil von Schritt 1 vor dem Falltest“, G:502) | **fehlt** |
| **Umstellung Vorgangsliste** (wie `umstellung2752/`) | — | Besitzer Rolle → Bereich/Profil, Klasse Eilt, Katalogwerte, Rückweg `git revert` | BER:11 („Vorgänge unter Rollennamen auf Bereich umziehen“); RF:13; VA:43 | ja | **fehlt** |
| **Größen- und Ladesummen-Skript** | — | Byte je Sockel, Kern, Profil, Summe je Sitzung, vorher/nachher | RF:7; VA:18 | ja (Schritt 1) | **fehlt** |
| **Lehrenbuch** `docs/LISTE-LEHREN.md` + Funktionen | — (Datei fehlt) | Datei anlegen; Funktionen in `vorgang.py` (Tabelle A) | VA:7; FB:16–40 | Vorschlag ja (bis Werkzeug: von Hand, FB:19) | **fehlt** |
| **Ende-Haken** | — | meldet am Ende jeder Fachkraft-, Prüfer-, Arbeitsplaner-Sitzung dem Büro, auch nach Absturz | G:111 (Votum, nicht entschieden); G 0a Offen (4); EA L-O14 | unbelegt (nicht entschieden) | **fehlt** |
| **Stop-Haken „alles gepusht?“** | — | hält Sitzungsende mit Ungepushtem an; dann fällt Sockel Zeile 7 | G:909; G:185 | nein (Sockel 7 trägt vorläufig, G:146) | **fehlt** |
| **Sperre Keystore, Zugangsdaten, Force-Push, `main`** | Teil: S `deny` Force-Push; `.gitignore` nur `local.properties` (G:908) | PreToolUse-Sperre; dann fällt Sockel Zeile 8 | G:908; G:186 | nein (Sockel 8 trägt vorläufig, G:146) | **fehlt** |
| **Durchspielen ohne Handy** (Tester) | — | Godot ohne Bildschirm mit Skriptsteuerung, Durchspielbogen | G:861; P20:10 | nein (EA L-O13 geschlossen) | 1738 |

Am Rand, nicht 1727-Pflicht: Stop-Haken Sokrates „Votum ohne Gegengeprüft“ (1732; Wortliste in RF:13, BER:11).

## C Entfällt oder wird stillgelegt (11)

| Werkzeug, Teil | setzt voraus | Beleg |
|---|---|---|
| `tools/rollenspiegel.sh` | Rollen, 340 | VA:67 („bei Umsetzung streichen“) |
| `tools/pflegehinweis.py` | Rollenspiegel-Zeilen | VA:67 |
| `tools/probelauf.py` und drei Haken in S | 621 A Probelauf | VA:67; Ersatz Laufbremse in `lauf.py` (VA:63) |
| `tools/vorratspruefung.py` | Vorräte, Perikles 1425 | G:484 („fällt mit den Vorräten“) |
| `lauf.py` Nachfolger aus „Übergabe … Nachfolger:“ | Vorräte | `lauf.py`:57–61; PP:23 |
| `lauf.py` Freigabe ab 40 $ (Kostenzeile für Perikles) | 1538 | `lauf.py`:346–348; VA:36 |
| `lauf.py` „M? entscheiden“ für Perikles | Perikles, Wochenziel | `lauf.py`:53; G 0c; VA:55 |
| `lauf.py` „Stillstand lösen“ und `TAGESBERICHT` an Perikles | Rolle Perikles | `lauf.py`:26, 54; G:484, G:486 (an Disponent bzw. Routine) |
| `lauf.py` ÜBERTRAGE in Vorrat | Vorräte | `lauf.py`:15; unbelegt, wohin (Vorschlag: Vorgangsdatei) |
| `weiter-haken.py` in heutiger Form | Übergabe im Vorrat | `weiter-haken.py`:5, 22; 0c (Vorräte fallen); Vorschlag Ende-Haken |
| `projektplan.py` Wochenziel-Tafel | Wochenziel, Perikles montags | `projektplan.py`:5; VA:55 (Vorschlag: Zahlen je Block liefert `ueberblick.py`) |

Mittelbar fallen mit `ARBEIT-BETRIEB.md` (Zähler → Werkzeug, Protokoll fällt, G:502) die Leseorte in `lauf.py`, `startsperre-haken.py`, `nachtstarts.py`, `dashboard.py`, `kostenbericht.py`, `tagesbericht.py` (Tabelle A); `ARBEIT-BESETZUNG.md` bleibt (G:502, G:473).

## D Bleibt unverändert (Nachweis „komplett“)

`abgleich.py`, `alt_bilder.sh`, `art_weg_test.py`, `bereichslisten.py`, `bildmass.py`, `bildrate.py`, `bildvergleich.py`, `figuren.py`, `figurenpruefung.py`, `freigabe-haken.py`, `gegenstaende.py`, `glossar.py`, `hakenzahl.py`, `inhalt.py`, `kernregeln.txt`, `laufnachweis.py`, `laufzeiten.py`, `menues_512b_blatt.py`, `namenpruefung.py`, `nummer_wort.py`, `pruefliste.py`, `reaktionen.py`, `regelwerte.py`, `setup-session.sh`, `story.sh`, `ueberblick.py` (Themenblöcke schon, `:23`), `varianten504.py`, `vgl348.py`, `vorgangskosten.py`, `vorlage_pruefen.py`, `zug-haken.py`, `zug-index.py`, Ordner `blender348`, `dinge`, `entwurf`, `gegenstaende`, `godot`, `karten`, `klang`, `pruef348`, `pruefbogen`, `runner`, `schrift`, `sim444`, `t`, `umstellung2752` (Altlast 275.2), alle `*_test.py` (folgen ihrem Werkzeug); Workflows `godot-kampf.yml`, `godot-schluessel.yml`, `release-notes.yml`, `spike-probe-4552.yml`, `tom-probe.yml`, `webseite.yml`, `zug-index.yml`. Rollennamen nur in Kommentaren (z. B. `laufnachweis.py` „Diogenes“, `freigabe-haken.py`): kein Umbau nötig, unbelegt ob P20:8 („rund 45“) sie mitzählt.

## Reihenfolge des Baus (Vorschlag)

1. **Grundlage Daten:** `bereiche.py` (Kataloge, Regeln) → Umstellung Vorgangsliste (Bereich statt Rolle, Eilt, Katalog) → `vorgang.py` Vorgangsdatei, `auftrag`, `schliessen`, `--hilfe`. Alles andere liest diese Felder.
2. **Übergabe 1760** in `vorgang.py` (Zeilen, Frist, Sperre wie Zähler) mit Test aus G:377, dann Obergrenzen A/B.
3. **`lauf.py`** auf Übergabezeilen, Klasse Eilt, Rufnamen, C, Laufbremse, Höchstdauer, Routinen-Starter; dazu `startbar.py`, `startsperre-haken.py`, `kosten.py`, `notiz.sh` (1742).
4. **Haken:** D, Kerntest-Sperre, Buildzweig-Muster, Größenbremse; Eintrag in S.
5. **Build-Kette:** Build-Auftrag, Build-Werkzeug, `godot.yml` auf `main`, Testbitte-Schreiber, `meldung.sh`-Zeilen.
6. **Wachen und Berichte:** Herzschlag/Wache, `tagesbericht.py`, `kostenbericht.py`, Lehrenbuch-Funktionen.
7. **Umzug „Zu <Nr>“** und Stilllegung (C) im Umschalt-Commit.
Gegenargument: Umzug und Liste früher, damit Werkzeuge an echten Daten testen; Abhilfe: an einer Kopie wie `umstellung2752/README.md`. Rückwärtsverträglich bis zum Umschalten (BER Zu 1739; `ARBEIT-TEAM-SPIKE.md`:6).

## Abgleich mit Bauliste 7.1

**In 7.1, aber anders als dort:** `meldung.sh` „nachts nie laut“ steht als nicht gebaut (G:921), ist aber gebaut (`meldung.sh`:107). `vorgang.py` „Akte `docs/akte/<Nr>.md`“ (G:920) ist veraltet: „Vorgangsdatei `docs/vorgang/<Nr>.md`“ seit VA:48 (19.11., 22:39). „Schutz 15 Minuten prüfen“: im Code nur 60 s gefunden (`lauf.py`:782).

**In A/B, fehlt in 7.1:** Haken D, C in `lauf.py` (EA L-O3) · Herzschlag/Wache (EA L-T1, L-O9) · Übergabezeilen 1760 in `vorgang.py` (PP:25) · Obergrenzen A/B · Laufbremse, Höchstdauer (nur in 7, G:911) · Größenbremse (nur in 7, G:906) · Stop-Haken, Sperre Keystore (nur in 7, G:908–909) · Testbitte-Schreiber A13 · Build-Auftrag und „wann ein Build“ (G:113 verlangt die Zeile) · Rufnamen (RF:18 „auch Rufnamen“; in 1739) · Routinen-Starter Wochenzählung, Rundblick, Ideenlauf · Ende-Haken (EA L-O14) · `startbar.py`, `notiz.sh` (1742), `startsperre-haken.py`, `kosten.py`/`kostenbericht.py` (in 1739, nicht in 7.1) · `tagesbericht.py`, `bereiche.py`, Umstellung Vorgangsliste, Umzug „Zu <Nr>“, Größenskript · Stilllegungen C.

**In 7.1, fehlt in A/B:** keine.
