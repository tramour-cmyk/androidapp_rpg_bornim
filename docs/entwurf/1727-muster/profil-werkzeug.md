# 1727, Profil Werkzeug (Gesamtbild 5.3 Nr. 11; Fassung 1, Sokrates-Helfer 21.11., 20:19, ungeprüft)

Auftrag: Gesamtbild 5.3 Nr. 11 „Werkzeug, Fach, fehlt“ (Quelle `LISTE-BETRIEB.md`, Bauliste 7); Reihenfolge Schritt 2 vor dem Falltest (`reihenfolge.md`:11); Chef 21.11., 20:06: „Uns fehlen die restlichen Werkzeuge. Die müssen wir jetzt machen.“ Form wie `profil-technik.md` F12; neue Profile kurz (Archiv 20.11., 14:02).

Geladen von: Fachkraft mit Profil Werkzeug (Werkstatt Werkzeug; Firmenwerkzeuge in `tools/`, Haken, GitHub-Läufe), Arbeitsplaner und Prüfer bei Aufträgen dieser Art. Nicht hier: Build, Merge von Spielcode, Release (Profil Technik, Nr. 10); was jedes einzelne Werkzeug können muss (Bauliste 7.1, `werkzeuge.md`); was der Sockel trägt (Spielcode nur nach Test des Chefs, Verlauf, Keystore). **Gilt ab der Umstellung;** bis dahin bleiben `ROLLE-TECHNIK.md` und `CLAUDE.md`, und jedes Werkzeug bleibt rückwärtsverträglich (alte Rollennamen, Vorräte, Felder gehen weiter; Zu 1739, Archiv 20.11., 10:40).

Quellen: `CLAUDE.md` (Feste Regeln „Jeder Schritt“, „Notizen nur auf `main`“, Bekannte Fehler 334), `ROLLE-TECHNIK.md` (Haltung), Archiv 1311 (15.11., 19:13), 235 (b) (20.10.), 222.1 (19.10.), 1739 (Prüfung 20.11., 10:40), Gesamtbild 3.1 (G:329), 3.3 F2 (entschieden 21.11., 10:11), 4.4 (G:482), 6d, 7, 7.1, `build-kette.md` 4 (entschieden 19.11., 22:05), `ein-ausgang.md` (L-O11, L-U9), `werkzeuge.md` (Bestand). `LISTE-BETRIEB.md` ist Fords Handbuch und enthält keine Regel fürs Bauen von Werkzeugen; übernommen nur „Dateien nie von Hand kopieren“ als Fall (Abschnitt 4).

## Ein- und Ausgang (Raster `ein-ausgang.md`)

| Feld | Inhalt | Fundstelle |
|---|---|---|
| Auslöser | Der Disponent startet die Fachkraft (G:374); den Auftrag schreibt der Arbeitsplaner mit Profil Werkzeug unter „Beachte“ (G:417). Anlässe: Zeile der Bauliste 7.1 („Macher Profil Werkzeug“, Archiv 19.11., 22:05, 21:12, 11:44, 13:58), ein Werkzeug meldet einen Fehler (neuer Vorgang mit Profil Werkzeug statt umgehen, G:329; BG:10), Fund an einem Werkzeug (G:482) | G:374, 417, 329, 482 |
| Arbeit | Teil A; ein Auftrag | G:417 |
| Ende | „fertig“, „Frage“ oder „abgebrochen“ mit Commit, Fällen, Beleg (G:420); bei „fertig“ liegt das Werkzeug schon auf `main` (1311) | G:420; Archiv 1311 |
| Meldung | Rückmeldung als Zeile über `vorgang.py` an das Büro, Nachricht nur Wecker | 3.3 F2 Nr. 2, 5 |
| Nächster Empfänger | „fertig“ → Prüfer (3.3 F2), prüft am Stand von `main`; „nein“ → dieselbe Fachkraft (3.3 F2 Nr. 6); „ja“ → Büro schließt (S17, `signale.md`:25), kein Test des Chefs (1311: „Da braucht ihr mich doch nicht dafür“); ob es greift, zählt die Wochenzählung (6d, „jeden Vorgang im Bereich B auf ‚gebaut‘ prüfen“); „Frage“ → Büro (Disponent urteilt, 3.3 F2 Nr. 5) | 3.3 F2; SI:25; 1311; G 6d |

**Lücken aus `ein-ausgang.md`:** Zeile Profil Werkzeug (Auslöser, Meldung, Empfänger „steht nicht“): geschlossen durch das Raster oben. **L-O11** (Profil fehlt): für Werkzeug geschlossen mit diesem Text. **L-U9** („nach grünem Lauf sofort nach `main`“ gegen „‚Fertig‘ geht immer zuerst an den Prüfer“, G:334): geschlossen ohne Änderung von Entschiedenem: erst `main` (1311, PT Teil A), dann „fertig“ an den Prüfer, der danach prüft, wie 1311 es für Diogenes vorsah („prüft danach ‚greift‘“); G:334 ist Entwurf 3.1, das „fertig → Prüfer“ aus 3.3 F2 bleibt. **Offen, nicht hier:** „greift“ hängt an der Wochenzählung, deren Starter fehlt (L-O7); Weg „ja ohne Build“ allgemein (L-O22) ist für Werkzeuge durch 1311 entschieden, für anderes nicht.

## Aufbau

- **Profil Technik Teil A, Satz „Ein Werkzeug (nicht Spielcode) geht nach grünem Lauf sofort nach `main`.“** Der Kopf von PT F12 sagt „bis es steht, trägt Teil A die Regel 1311“. **Chefsache (ändert PT F12, Archiv 21.11., 15:15; genehmigte Profile nicht umschreiben, 20.11., 14:02):** Satz in PT streichen, sobald dieses Profil gilt (Regelbilanz). Ohne Wort bleibt er doppelt, unschädlich.
- **Notizen schreibende Werkzeuge:** `CLAUDE.md` nennt als Ausnahmen nur `vorgang.py` (275) und den Bildlink von `meldung.sh` (450); `lauf.py` schreibt aber Zähler, Besetzung, Protokoll (`LISTE-BETRIEB.md` 4). Teil A schickt ein neues schreibendes Werkzeug als „Frage“ zurück, statt eine Ausnahme zu erfinden; die Liste der Ausnahmen gehört mit der Umstellung in den Sockel- bzw. Werkzeugtext (offen).
- **Zuschnitt:** „Werkzeuge der Teams“ in E Technik oder B Werkzeuge ist offen (G 0b „Offen für Sa“); bis dahin lädt der Arbeitsplaner Profil Werkzeug für Firmenwerkzeuge (B Werkzeuge), Werkzeuge im Spielbau (Bauskripte, Blender) bleiben bei Profil Technik bzw. dem Fachprofil.
- **Auslöser im Profil Disponent:** der Satz „Meldet ein Werkzeug einen Fehler: neuer Vorgang mit Profil Werkzeug“ (G:329) steht nur im Entwurf 3.1 und wandert laut Archiv 21.11., 11:46 ins Profil Disponent (nicht geschrieben, L-O2); dort übernehmen.

## Teil A: Profil Werkzeug

```markdown
**Werkzeug.** Erst nachsehen, was es in `tools/` schon gibt und wie andere es lösen; Quelle in die Rückmeldung. Einen Fehler erst nachstellen (Test zeigt ihn rot), dann beheben. Werkzeug heißt ohne Spielinhalt, außerhalb der Spielcode-Pfade von `godot.yml`.

**Grenzen.** Notizen (`docs/`, `CLAUDE.md`) änderst du nur mit Edit/Write, nie per Bash-Skript. Soll ein Werkzeug Notizen schreiben (wie `vorgang.py`) oder etwas in `.claude/settings.json` eintragen: „Frage“ zurück; Erlaubnisse schreibt sich keine Sitzung selbst.

**Nach `main`.** Vor jedem Commit die Kerntests mit Exit-Code (`tools/t logik`). Nach grünem Lauf geht das Werkzeug sofort nach `main`, ohne Test des Chefs; dann „fertig“ mit dem Commit auf `main`. Der Prüfer prüft am Stand von `main` mit den Fällen des Auftrags; sein Nein bessert du dort nach.
```

## Teil B: Bauliste 7.1, Profil Arbeitsplaner

Keine neue Zeile in 7.1 (alle Werkzeuge, die dieses Profil braucht, stehen dort oder in `werkzeuge.md` A/B). Für den Text des Arbeitsplaners (G 4.1, Entwurf; künftig Profil Arbeitsplaner, L-O2), Punkt 4 „Beachte“, **neu:** „bei Firmenwerkzeugen (`tools/`, Haken, GitHub-Läufe) das Profil Werkzeug; Prüfart Prüfung mit Ausgabe“.

## Eigene Prüfung (20:19)

- **Größe** (UTF-8, Inhalt des Codeblocks Teil A, gemessen mit `wc -c`): Teil A 838 Byte (Ziel bis etwa 1.200); Teil B 104 Byte für den Text des Arbeitsplaners (Kern Arbeitsplaner, Entwurf, 2.375 → etwa 2.479 Byte; mit Teil B aus `profil-fremde-inhalte.md` etwa 2.543). Eine Fachkraft Werkzeug lädt Sockel 1.110 + Auftrag (bis etwa 2 KB) + 838, zusammen bis etwa 3,9 KB. Regelbilanz: fällt der Satz 1311 in PT Teil A (Chefsache oben), sinkt PT um etwa 75 Byte.
- **Quellen je Satz (Teil A):**
  1. „Erst nachsehen … wie andere es lösen; Quelle in die Rückmeldung“: `ROLLE-TECHNIK.md` Haltung („Erst nachsehen, wie andere es lösen (Chef 18.11., 09:53)“), Wortlaut wie PT Teil A; „was es in `tools/` schon gibt“: „Bestand zuerst“ (`ROLLE-ENTWICKLUNG.md`, gilt für Spike über den Verweis, `ROLLE-TECHNIK.md` „Ersetzt“).
  2. „Einen Fehler erst nachstellen …“: `CLAUDE.md` Bekannte Fehler (334); `ROLLE-TECHNIK.md` Haltung; PT Teil A.
  3. „Werkzeug heißt ohne Spielinhalt, außerhalb der Spielcode-Pfade von `godot.yml`“: Archiv 1311 („Werkzeug ohne Spielinhalt“); Build-Kette 4 („Spielcode-Pfade (Pfadfilter von `godot.yml`)“).
  4. „Notizen nur mit Edit/Write, nie per Bash-Skript“: `CLAUDE.md` „Notizen nur auf `main`“; Archiv 235 (b).
  5. „Soll ein Werkzeug Notizen schreiben … oder … `settings.json` …: ‚Frage‘ zurück; Erlaubnisse schreibt sich keine Sitzung selbst“: Ausnahmen nur benannt (`CLAUDE.md`, 275, 450); 235 (b) („eine Sitzung darf sich dort keine Erlaubnisse schreiben“); jede Änderung an `settings.json` hatte ein Wort des Chefs (222, 222.1, 797); „Frage“ als Ende der Fachkraft (G:420), Sockel 3. Ableitung, kein Entscheid: der Weg „Frage“ statt selbst.
  6. „Vor jedem Commit die Kerntests mit Exit-Code (`tools/t logik`)“: `CLAUDE.md` „Jeder Schritt“; Befehl wie PT Teil A (Nachprüfung 14:42 Befund 1).
  7. „Nach grünem Lauf sofort nach `main`, ohne Test des Chefs“: Archiv 1311; `CLAUDE.md` „Werkzeug nach grünem Lauf sofort (1311)“.
  8. „dann ‚fertig‘ mit dem Commit auf `main`“: G:420 (Ende mit Commit), 3.3 F2 („fertig“ → Prüfer).
  9. „Der Prüfer prüft am Stand von `main` mit den Fällen des Auftrags“: 1311 („prüft danach“); G:420 („Zahl der geprüften Fälle“).
  10. „sein Nein bessert du dort nach“: 3.3 F2 Nr. 6 („Nein des Prüfers an dieselbe Fachkraft“).
- **Fälle:**
  - 1311 selbst (Werkzeug wartete auf den nächsten Build, Chef: „Wenn ich nicht gefragt hätte, wäre wieder nichts passiert“): Satz 7 deckt ihn.
  - Buildzweig-Haken mit Muster `claude/build-\d+`, unbekannte Rolle lässt durch (`werkzeuge.md` A; Build-Kette 2 verlangt `\S+` und Anhalten): Satz 2 verlangt vor dem Umbau einen Test, der die Lücke rot zeigt.
  - Kerntest-Marke nur Warnung (`commit-pruefung.py`): Satz 6 gilt für die Fachkraft; die Sperre ist Bauliste 7.1 (Kerntest-Haken), nicht Profiltext.
  - 18.10. Zähler und Besetzung durch Kopieren von Hand überschrieben (`LISTE-BETRIEB.md` 4): Satz 4, 5.
  - 235 (b), Vorschlag `settings.json` 08:44 entfiel: Satz 5.
  - Werkzeug, das Spielcode-Pfade berührt (etwa ein Bauskript unter `godot/`): Satz 3 schickt es auf den Weg für Spielcode; ob Bauskripte außerhalb von `godot/` (`tools/blender348`) Werkzeug sind, entscheidet der Pfadfilter.
- **Nicht übernommen:** „nach jedem Push, der baut, ein Weckruf“ (`CLAUDE.md`; heutiger Brauch mit Uhr, im neuen Ablauf trägt die Rückmeldung an das Büro); „Firmenwerkzeuge als Kür“ (`ROLLE-TECHNIK.md` 3; Vorrang ist Sache des Disponenten); rückwärtsverträglich (1739; gilt nur bis zur Umstellung, darum im Kopf).
