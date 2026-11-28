# Prüfschema Startprompts (1989, Chef 23.11., 09:04)

Je Sitzungsart eine Stichprobe am Tag, nie dieselbe Art zweimal, bevor alle dran waren. Ist = erste Nachricht der Sitzung (`list_events`), Soll = `tools/lauf.py` `mit_kern`/`startblock` (1923, Chef 22.11., 11:09 „Startblock ja“).

## Soll-Punkte

- S1 Titel „<Rufname> – <Nr>: <Titel> (<Zeit>)“, erste Zeile „Dein Rufname: … (Rolle …)“.
- S2 Teile wörtlich: Kern laut `KERN_VON`, Fachprofil, Querprofile, die der Auftrag zulädt, „Zugang Kaufrepo“ laut `BRAUCHT_KAUFREPO`; Leitung: Kern Leitung und Gedächtnis.
- S3 Auftrag: jüngster Auftrag der Vorgangsdatei wörtlich, sieben Felder mit „Zurück“ (Disponent: kein Start ohne „Zurück“).
- S4 keine abgelaufenen oder befristeten Zusätze ohne „Zu <Nr>, bis erledigt“ (Fall 1963).
- S5 Schluss: Kaufrepo-Satz wörtlich (`KAUFREPO_SCHARF`).
- S6 Größe: Ladesumme der Art plus Auftrag bis 1,5 KB (Werkzeug etwa 2 KB).

## Raster (✓ erfüllt, ✗ verletzt, – nicht anwendbar)

| Art | Sitzung, Start | S1 | S2 | S3 | S4 | S5 | S6 | Befund |
|---|---|---|---|---|---|---|---|---|
| Leitung | Sokrates 23.11., 08:51 | ✓ | ✗ | – | ✓ | ✗ | ✓ | von Hand: Kern ja, Gedächtnis nicht im Text (Kern sagt „lesen“); Kaufrepo-Satz gekürzt |
| Prüfer | Xenia 23.11., 09:01 | ✓ | ✗ | ✗ | ✓ | ✗ | ✓ | von Hand: „Ladetext: lies …“ statt Text, „die dort genannten Querprofile“; Auftrag frei ohne Felder |
| Prüfer | Wanda 23.11., 08:55 | ✓ | ✗ | ✗ | ✓ | ✗ | ✓ | wie Xenia |
| Werkzeug | Yvonne 23.11., 09:05 | ✓ | ✗ | ✓ | ✓ | ? | ✓ | von Hand: „lies CLAUDE.md und Werkzeug.md“; Auftrag als Verweis auf Vorgangsdatei |
| Disponent | | | | | | | | offen |
| Arbeitsplaner | | | | | | | | offen |
| Tester | | | | | | | | offen |
| Wache | | | | | | | | offen (Routine ohne Kern) |
| Figur | Svea 23.11., 08:29 | | | | | | | offen (von Hand) |
| Welt, Kampf, Kataloge, Klang, Oberfläche, Regeln, Story, Technik | | | | | | | | offen |

## Ursache bisher

Alle zwölf Starts seit 07:55 sind Handstarts des Disponenten „nach Sokrates“ (`ARBEIT-BETRIEB.md`, Startsperren), nicht START-Zeilen von `lauf.py`; der Startblock (1923) greift dort nicht.
