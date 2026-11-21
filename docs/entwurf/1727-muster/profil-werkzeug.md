# 1727, Profil Werkzeug (Gesamtbild 5.3 Nr. 11; Fassung 7, Sokrates 21.11., 22:39, Befunde Nachprüfung 22:30 eingearbeitet, Nachprüfung offen; Teil A 1.104 → 1.104 Byte; ganze Datei 19.198 → 20.547 Byte nach Messregel: ohne Kopfzeile, ohne Leerzeile, ohne letztes Zeilenende) · Fassung 8 (Sokrates 21.11., 22:51, Nachprüfung 22:47): Ladesumme mit „Stand 43b57854c“, „F7 (22:39)“; Teil A unverändert 1.104; ganze Datei 20.547 → 20.971 Byte (Messregel) · Fassung 9 (Sokrates 21.11., 22:5x, Konsolidierung): :24 Profil Disponent F9 (1794); Teil A 1.103 Byte (Messregel; vorher mit Zeilenende 1.104); Ladesumme Arbeitsplaner mit Kern Büro 680 = 5.449; ganze Datei 20.971 → 21.621 Byte (Messregel)

Auftrag: Gesamtbild 5.3 Nr. 11 „Werkzeug, Fach, fehlt“ (Quelle `LISTE-BETRIEB.md`, Bauliste 7); Reihenfolge Schritt 2 vor dem Falltest (`reihenfolge.md`:11); Chef 21.11., 20:06: „Uns fehlen die restlichen Werkzeuge. Die müssen wir jetzt machen.“ Form wie `profil-technik.md` F12; neue Profile kurz (Archiv 20.11., 14:02).

Geladen von: Fachkraft mit Profil Werkzeug (Werkstatt Werkzeug; Firmenwerkzeuge außerhalb der Spielcode-Pfade von `godot.yml`: Teile von `tools/`, Haken, GitHub-Läufe außer `godot.yml`), Arbeitsplaner und Prüfer bei Aufträgen dieser Art. Nicht hier: Build, Merge von Spielcode, Release (Profil Technik, Nr. 10); was jedes einzelne Werkzeug können muss (Bauliste 7.1, `werkzeuge.md`); was der Sockel trägt (Spielcode nur nach Test des Chefs, Verlauf, Keystore). **Gilt ab der Umstellung;** bis dahin bleiben `ROLLE-TECHNIK.md` und `CLAUDE.md`, und jedes Werkzeug bleibt rückwärtsverträglich (alte Rollennamen, Vorräte, Felder gehen weiter; Zu 1739, Archiv 20.11., 10:40; dessen „bauen weiter“ ersetzt 21.11., 20:06, die Verträglichkeit nicht).

Quellen: `CLAUDE.md` (Feste Regeln „Jeder Schritt“, „Notizen nur auf `main`“, Bekannte Fehler 334), `ROLLE-TECHNIK.md` (Haltung), Archiv 1311 (15.11., 19:13), 235 (b) (20.10.), 222.1 (19.10.), 1739 (Prüfung 20.11., 10:40), Gesamtbild 3.1 (G:329), 3.3 F2 (entschieden 21.11., 10:11), 4.4 (G:482), 6d, 7, 7.1, `build-kette.md` 4 (entschieden 19.11., 22:05), `ein-ausgang.md` (L-O11, L-U9), `werkzeuge.md` (Bestand). `LISTE-BETRIEB.md` ist Fords Handbuch und enthält keine Regel fürs Bauen von Werkzeugen; übernommen nur „Dateien nie von Hand kopieren“ als Fall (Abschnitt 4).

## Ein- und Ausgang (Raster `ein-ausgang.md`)

| Feld | Inhalt | Fundstelle |
|---|---|---|
| Auslöser | Der Disponent startet die Fachkraft (G:374); den Auftrag schreibt der Arbeitsplaner mit Profil Werkzeug unter „Beachte“ (G:417). Anlässe: Zeile der Bauliste 7.1 („Macher Profil Werkzeug“, Archiv 19.11., 22:05, 21:12, 11:44, 13:58), ein Werkzeug meldet einen Fehler (neuer Vorgang mit Profil Werkzeug statt umgehen, G:329; BG:10), Fund an einem Werkzeug (G:482) | G:374, 417, 329, 482 |
| Arbeit | Teil A; ein Auftrag | G:417 |
| Ende | „fertig“, „Frage“ oder „abgebrochen“ mit Commit, Fällen, Beleg (G:420); bei „fertig“ liegt das Werkzeug schon auf `main` (1311) | G:420; Archiv 1311 |
| Meldung | Rückmeldung als Zeile über `vorgang.py` an das Büro, Nachricht nur Wecker | 3.3 F2 Nr. 2, 5 |
| Nächster Empfänger | „fertig“ → Prüfer (G:334, Entwurf 3.1; 3.3 F2 Nr. 5 gibt nur „nach dem ersten Wort die nächste Zeile“), prüft am Stand von `main`; „nein“ → dieselbe Fachkraft (3.3 F2 Nr. 6); „ja“ → Büro schließt (S17, `signale.md`:25), kein Test des Chefs (1311: „Da braucht ihr mich doch nicht dafür“); **Lücke:** `rueckmeldung.py` Funktion `weitergabe` (Zweig „ja“, an `main` 1e38d1a2d) gibt „ja“ des Prüfers heute ohne Ausnahme als Testbitte an den Chef („an den Chef vorlegen (Testbitte)“), Ausnahme Werkzeug fehlt: Vorgang 1790 (Spike); ob es greift, zählt die Wochenzählung (6d, „jeden Vorgang im Bereich B auf ‚gebaut‘ prüfen“); „Frage“ → über `vorgang.py` an Sokrates (C, VA 21.11., 14:37; `rueckmeldung.py` Funktion `eintragen`, Zweig „steckt fest“, „Frage“, „wirkt nein“ → Sokrates, 1e38d1a2d), Kauf und Lizenz im Gespräch mit dem Chef, im Zweifel Chefsache (VA 20:52) | G:334; 3.3 F2; SI:25; 1311; G 6d; VA 14:37 C, 20:52 |

**Lücken aus `ein-ausgang.md`:** Zeile Profil Werkzeug (Auslöser, Meldung, Empfänger „steht nicht“): geschlossen durch das Raster oben. **L-O11** (Profil fehlt): für Werkzeug geschlossen mit diesem Text. **L-U9** („nach grünem Lauf sofort nach `main`“ gegen „‚Fertig‘ geht immer zuerst an den Prüfer“, G:334): **Vorschlag, nicht geschlossen:** erst `main` (1311 entschieden, PT Teil A), dann „fertig“ an den Prüfer, der am Stand von `main` prüft. G:334 ist Entwurf 3.1; „fertig → Prüfer“ steht in 3.3 nur in der ersetzten Fassung 1 (Nr. 2). 1311 „prüft danach ‚greift‘“ meint den Betrieb (Diogenes), nicht die Prüfung eines Auftrags; darauf stütze ich nichts. Gilt, wenn der Kern Büro (3.1) so entschieden wird. **Offen, nicht hier:** „greift“ hängt an der Wochenzählung, deren Starter mit 1766 gebaut ist, scharf erst mit `tools/1727-SCHARF` (`startbar.py`:175–182, L-O7); Weg „ja ohne Build“ allgemein (L-O22) ist für Werkzeuge durch 1311 entschieden, für anderes nicht.

## Aufbau

- **Profil Technik Teil A, Satz „Ein Werkzeug (nicht Spielcode) geht nach grünem Lauf sofort nach `main`.“** bleibt (1727a zurückgezogen, 21:18; `sammelvorlage.md`:7): Profil Werkzeug gilt nur für Firmenwerkzeuge, der Satz 1311 in Profil Technik trägt die Werkzeuge im Spielbau.
- **Profil Disponent F9:** Ausnahme 1311 als Vorschlag in :20, Perikles prüft (1794).
- **Notizen schreibende Werkzeuge:** `CLAUDE.md` nennt als Ausnahmen nur `vorgang.py` (275) und den Bildlink von `meldung.sh` (450); `lauf.py` schreibt aber Zähler, Besetzung, Protokoll (`LISTE-BETRIEB.md` 4). Teil A schickt ein schreibendes Werkzeug, das die Bauliste 7.1 nicht so nennt, als „Frage“ zurück, statt eine Ausnahme zu erfinden. Damit die Werkzeuge von 1727 selbst nicht jedes Mal „Frage“ werden, kommt die Liste der Notizschreiber vor der Umstellung in 7.1 (Teil B).
- **Zuschnitt:** „Werkzeuge der Teams“ in E Technik oder B Werkzeuge ist offen (G 0b „Offen für Sa“); bis dahin lädt der Arbeitsplaner Profil Werkzeug für Firmenwerkzeuge (B Werkzeuge), Werkzeuge im Spielbau (Bauskripte, Blender) bleiben bei Profil Technik bzw. dem Fachprofil.
- **Auslöser im Kern Büro:** der Satz „Meldet ein Werkzeug einen Fehler: neuer Vorgang mit Profil Werkzeug“ (G:329, Entwurf 3.1) steht in der Gegenüberstellung F3 in der Spalte Kern Büro (`buero-gegenueberstellung.md`:10, Zeile „Werkzeuge“; Kern Büro schmal, Archiv 21.11., 11:46, auf BG F3 entschieden); dort übernehmen. Profil Disponent F9 (`profil-disponent.md`:28) führt ihn auch; ein Ort: Kern Büro, Streichen im Disponent als Nachtrag beim Besitzer (Vorgang 1773).

## Teil A: Profil Werkzeug

```markdown
**Werkzeug.** Erst nachsehen, was es in `tools/` schon gibt und wie andere es lösen; Quelle in die Rückmeldung. Einen Fehler erst nachstellen (Test zeigt ihn rot), dann beheben. Werkzeug heißt ohne Spielinhalt, außerhalb der Spielcode-Pfade von `godot.yml`, kein Bau-, Probe- oder Release-Lauf.

**Grenzen.** Notizen (`docs/`, `CLAUDE.md`, `CHANGELOG.md`) änderst du nur mit Edit/Write, nie per Bash-Skript. Soll ein Werkzeug Notizen schreiben und steht das nicht in der Bauliste 7.1, oder braucht es eine Erlaubnis in `.claude/settings.json`: „Frage“ zurück. Haken trägst du ein, wenn die Bauliste ihn nennt; Erlaubnisse schreibt sich keine Sitzung selbst.

**Nach `main`.** Vor jedem Code-Commit die Kerntests mit Exit-Code (`tools/t logik`) und der Test des Werkzeugs; fehlt er, schreibst du ihn zuerst und trägst ihn in `werkzeuge.yml` ein, nötigenfalls mit Pfad. Sind beide grün, geht das Werkzeug sofort nach `main`, ohne Test des Chefs; dann „fertig“ mit dem Commit auf `main`. Der Prüfer prüft am Stand von `main` mit den Fällen des Auftrags; sein Nein bessert du dort nach.
```

## Teil B: Bauliste 7.1, Profil Arbeitsplaner

**Neu in 7.1** (beim Zusammenführen, nicht jetzt in G einfügen, sonst verschieben sich die G-Zeilenverweise): „Notizschreiber: `vorgang.py`, `rueckmeldung.py`, `uebergabe.py`, `chefwort.py`, `lauf.py` (Zähler, Besetzung, Protokoll), `zug-index.yml` mit `zug-index.py` (`chefsache/README.md`), `tagesbericht.py` (`ARBEIT-TAGESBERICHT.md`), `startbar.py` („wartet auf“ in `LISTE-VORGAENGE.md`), `kostenbericht.py` (`LISTE-KOSTEN.md`), `vorratspruefung.py`, `bereichslisten.py`, `auftrag.py` (`docs/vorgang/<Nr>.md`), `gegenstaende.py` (`LISTE-GEGENSTAENDE.md`), `regelwerte.py` (`LISTE-REGELWERTE.md`), `rollenspiegel.sh` (`LISTE-ROLLENSPIEGEL.md`, `LISTE-IDEEN.md`), `lehren.py` (`LISTE-LEHREN.md`, `lehren.py`:2–3, :17, :115, :165; aufgerufen aus `rueckmeldung.py` Funktion `haupt`, `lehren.roh_aus_rueckmeldung`, 1e38d1a2d), Bildlink von `meldung.sh`“. Sonst keine neue Zeile (die Werkzeuge stehen in `werkzeuge.md` A/B). **Text des Arbeitsplaners: entschieden 1727f (Chef 21.11., 21:33); eingebaut in `kern-arbeitsplaner.md` (84061cd95).** Punkt 4 „Beachte“, Wortlaut wie Vorlage: „bei Firmenwerkzeugen außerhalb der Spielcode-Pfade von `godot.yml` das Profil Werkzeug“.

## Eigene Prüfung (20:19)

- **Größe Fassung 1, überholt (gültig: letzter Abschnitt)** (UTF-8, Inhalt des Codeblocks Teil A, gemessen mit `wc -c`): Teil A 838 Byte (Ziel bis etwa 1.200); Teil B 104 Byte für den Text des Arbeitsplaners (Kern Arbeitsplaner, Entwurf, 2.375 → etwa 2.479 Byte; mit Teil B aus `profil-fremde-inhalte.md` etwa 2.543). Eine Fachkraft Werkzeug lädt Sockel 1.110 + Auftrag (bis etwa 2 KB) + 838, zusammen bis etwa 3,9 KB.
- **Quellen je Satz (Teil A):**
  1. „Erst nachsehen … wie andere es lösen; Quelle in die Rückmeldung“: `ROLLE-TECHNIK.md` Haltung („Erst nachsehen, wie andere es lösen (Chef 18.11., 09:53)“), Wortlaut wie PT Teil A; „was es in `tools/` schon gibt“: „Bestand zuerst“ (`ROLLE-ENTWICKLUNG.md`, gilt für Spike über den Verweis, `ROLLE-TECHNIK.md` „Ersetzt“).
  2. „Einen Fehler erst nachstellen …“: `CLAUDE.md` Bekannte Fehler (334); `ROLLE-TECHNIK.md` Haltung; PT Teil A.
  3. „Werkzeug heißt ohne Spielinhalt, außerhalb der Spielcode-Pfade von `godot.yml`, kein Bau-, Probe- oder Release-Lauf“: Archiv 1311 („Werkzeug ohne Spielinhalt“); Build-Kette 4 („Spielcode-Pfade (Pfadfilter von `godot.yml`)“); Bau-, Probe- und Release-Läufe (`godot-schluessel.yml`, `godot-kampf.yml`, `release-notes.yml`, `tom-probe.yml`, `spike-probe-4552.yml`) gehören zu Build und Release (Kopf „Nicht hier“, Profil Technik).
  4. „Notizen nur mit Edit/Write, nie per Bash-Skript“: `CLAUDE.md` „Notizen nur auf `main`“; Archiv 235 (b).
  5. „Soll ein Werkzeug Notizen schreiben und steht das nicht in der Bauliste 7.1, oder braucht es eine Erlaubnis …: ‚Frage‘ zurück. Haken trägst du ein, wenn die Bauliste ihn nennt; Erlaubnisse schreibt sich keine Sitzung selbst“: Ausnahmen nur benannt (`CLAUDE.md`, 275, 450); 235 (b) verbietet nur Erlaubnisse („eine Sitzung darf sich dort keine Erlaubnisse schreiben“); Haken kamen ohne eigenes Chefwort nach Auftrag (c315ec551, a18704b54, 15933d1ff; 222.1; Kerntest-Haken an Jerry, Archiv 21.11., 20:20); „Frage“ als Ende der Fachkraft (G:420), Sockel 3. Ableitung, kein Entscheid.
  5a. `CHANGELOG.md` gehört zu den Notizen (`CLAUDE.md` „Notizen nur auf `main`“).
  6. „Vor jedem Code-Commit die Kerntests mit Exit-Code (`tools/t logik`) und der Test des Werkzeugs; fehlt er, schreibst du ihn zuerst“: `CLAUDE.md` „Jeder Schritt“; Befehl wie PT Teil A (Nachprüfung 14:42 Befund 1); Test des Werkzeugs: `tools/t logik` prüft nur Godot-Logik (`tools/t`:10–18), viele Werkzeuge haben keinen Test (`neustart-haken.py`, `commit-pruefung.py`, `buildzweig-haken.py`, `startsperre-haken.py`, `notiz.sh`); „Test zuerst“ folgt Bekannte Fehler 334 (Ursache im Test nachstellen) und dem Bauweg von 1760–1772 (je Werkzeug `*_test.py`).
  7. „Nach grünem Lauf sofort nach `main`, ohne Test des Chefs“: Archiv 1311; `CLAUDE.md` „Werkzeug nach grünem Lauf sofort (1311)“.
  8. „dann ‚fertig‘ mit dem Commit auf `main`“: G:420 (Ende mit Commit), 3.3 F2 („fertig“ → Prüfer).
  9. „Der Prüfer prüft am Stand von `main` mit den Fällen des Auftrags“: G:334 (Entwurf 3.1, „Fertig“ zuerst an den Prüfer) mit dem L-U9-Vorschlag oben; G:420 („Zahl der geprüften Fälle“). 1311 nicht als Quelle (meint den Betrieb).
  10. „sein Nein bessert du dort nach“: 3.3 F2 Nr. 6 („Nein des Prüfers an dieselbe Fachkraft“).
- **Fälle:**
  - 1311 selbst (Werkzeug wartete auf den nächsten Build, Chef: „Wenn ich nicht gefragt hätte, wäre wieder nichts passiert“): Satz 7 deckt ihn.
  - Buildzweig-Haken mit Muster `claude/build-\d+`, unbekannte Rolle lässt durch (`werkzeuge.md` A; Build-Kette 2 verlangt `\S+` und Anhalten): Satz 2 verlangt vor dem Umbau einen Test, der die Lücke rot zeigt.
  - Kerntest-Haken (`commit-pruefung.py`:202–205, seit 1765) hält nur Code-Commits unter `godot/` an; ein Commit nur unter `tools/` läuft ohne Haken durch: dort trägt Satz 6 allein (Test des Werkzeugs vor dem Commit).
  - 18.10. Zähler und Besetzung durch Kopieren von Hand überschrieben (`LISTE-BETRIEB.md` 4): Satz 4, 5.
  - 235 (b), Vorschlag `settings.json` 08:44 entfiel: Satz 5.
  - Werkzeug, das Spielcode-Pfade berührt (etwa ein Bauskript unter `godot/`): Satz 3 schickt es auf den Weg für Spielcode; ob Bauskripte außerhalb von `godot/` (`tools/blender348`) Werkzeug sind, entscheidet der Pfadfilter.
- **Nicht übernommen:** „nach jedem Push, der baut, ein Weckruf“ (`CLAUDE.md`; heutiger Brauch mit Uhr, im neuen Ablauf trägt die Rückmeldung an das Büro); „Firmenwerkzeuge als Kür“ (`ROLLE-TECHNIK.md` 3; Vorrang ist Sache des Disponenten); rückwärtsverträglich (1739; gilt nur bis zur Umstellung, darum im Kopf).

## Gegenprüfung 20:23 (frischer Helfer, Fassung 1), mein Wort und Einarbeitung in Fassung 2

1 `settings.json` hält jeden Haken an (gegen 20:20, 222.1, drei Haken-Commits): **stimmt**, Satz 5 nur Erlaubnisse → Frage, Haken nach Bauliste · 2 „Notizen schreiben wie `vorgang.py`“ trifft gewollte Schreiber: **stimmt**, „nicht in 7.1 → Frage“ · 3 G:329 gehört in den Kern Büro (BG F3:10), nicht ins Profil Disponent: **stimmt**, Aufbau berichtigt · 4 L-U9 auf „3.3 F2“ gestützt, steht dort nicht: **stimmt**, L-U9 jetzt Vorschlag, offen mit Kern Büro · 5 `tools/` teils Spielcode-Pfad (`godot.yml`:9): **stimmt**, Kopf und Teil B „außerhalb der Spielcode-Pfade“ · 6 Form (1739 ohne Ersatz 20:06, `CHANGELOG.md`, Prüfart Punkt 6, C bei „Frage“): **stimmt**, alle eingearbeitet. Teil A danach 937 Byte (vorher 838).

## Nachprüfung 20:43 (frischer Helfer, Fassung 2), mein Wort und Einarbeitung in Fassung 3

Querbefund G-Zeilen um 3 verschoben (meine drei Zeilen in 0.1): **stimmt**, Zeilen 20:44 wieder heraus, Gesamtbild wie vor 20:37; Größen stehen nur hier · Kopfzeit: **stimmt**, Form · 1 Ausnahme 1311 fehlt im Profil Disponent: **stimmt**, Nachtrag Vorgang 1773 (Perikles) · 2 Werkzeugfehler-Satz an zwei Orten: **stimmt**, ein Ort Kern Büro (BG F3, 11:46), Streichen im Disponent mit 1773 · 3 Satz 9 auf 1311: **stimmt**, Quelle G:334 · 4 Teil B ändert Abgenommenes, L-O2 falsch: **stimmt**, Gesprächspunkt, Verweis RF:14, EA Zeile 23 · 5 grüner Lauf prüft kein Werkzeug: **stimmt**, Test des Werkzeugs dazu · 6 `godot.yml` ist Spielcode-Pfad: **stimmt**, Kopf „außer `godot.yml`“ · 7 Code-Commit: **stimmt** · 8 Chefsache ohne Träger: **stimmt**, Träger Sokrates (Sammelvorlage) · 9 Größe: **stimmt**, siehe unten · 10 G:418: **stimmt**, Prüfart G:419.

Größe Fassung 3 (`wc -c`, Codeblock Teil A): 994 Byte; Teil B 87 + 36 Byte. Ladesumme Fachkraft: Sockel 1.110 + Auftrag bis etwa 2 KB + 994, bis etwa 4,1 KB.

## Nachprüfung 20:54 (frischer Helfer, Fassung 3), mein Wort und Einarbeitung in Fassung 4

1 „Frage“ geht nach C an Sokrates, nicht an den Disponenten: **stimmt**, Raster nach C und VA 20:52 · 2 viele Werkzeuge ohne Test, Quelle fehlt: **stimmt**, „fehlt er, schreibst du ihn zuerst“, Quelle Satz 6 · 3 Bau-, Probe-, Release-Läufe fielen unter Werkzeug: **stimmt**, in Teil A ausgenommen · 4 Werkzeuge von 1727 schreiben Notizen ohne 7.1: **stimmt**, Liste der Notizschreiber in Teil B für 7.1 · 5 „Sammelvorlage“ ohne Träger: **stimmt**, Zeile „Zu 1727, Sammelvorlage“ in `ARBEIT-BERATUNG.md` · 6 Prüfart-Satz ändert nichts: **stimmt**, gestrichen · 7 Fall Kerntest-Marke veraltet: **stimmt**, neu nach `commit-pruefung.py` · 8 alte Größen: **stimmt**, als überholt gekennzeichnet.

Größe Fassung 4 (`wc -c`, Codeblock Teil A): 1.041 Byte. Ladesumme Fachkraft bis etwa 4,2 KB.

## Nachprüfung 21:03 (frischer Helfer, Fassung 4), mein Wort, eingearbeitet (Fassung 4a)

1 Liste der Notizschreiber unvollständig: **stimmt**, ergänzt (`tagesbericht.py`, `startbar.py`, `kostenbericht.py`, `vorratspruefung.py`, `bereichslisten.py`, `zug-index.py`) · 2 Satz unter „Beachte“ ohne Träger: **stimmt**, Sammelvorlage Nr. 10 · 3 neuer Test läuft nie auf `main`: **stimmt**, „trägst ihn in `werkzeuge.yml` ein“ · Form (Kopfzeit, `KERNTEST_CODE`): **stimmt**, Form. Teil A 1.080 Byte. Nachprüfung der Fassung 4a offen.

## Nachprüfung 21:15, mein Wort (frischer Helfer, Fassung 4a an `dcbb29a98`; Teil A 1.080 Byte stimmt), eingearbeitet in Fassung 5

Votum Prüfer: vorlegbar nach 1. Mein Wort (Sokrates 21:17): alle **stimmt**.
1 Notizschreiber fehlen `auftrag.py` (:52–56), `gegenstaende.py` (:18, :168), `regelwerte.py` (:21, :306), `rollenspiegel.sh` (:88, :92–99), oder Satz 5 auf „neu schreibend“ (Fehler): **stimmt, eingearbeitet**, die vier in die Liste Teil B (Zeilen an `main` gleich) · 2 `rueckmeldung.py`:87–88 → :91–92: **stimmt, eingearbeitet**, an `main` jetzt :122–123 · 3 L-U9 überholt, Starter Wochenzählung gebaut 1766 (`startbar.py`:178–183): **stimmt, eingearbeitet**, an `main` :175–182, scharf mit `tools/1727-SCHARF` · 4 `werkzeuge.yml` Pfadfilter nur oberste Ebene (:7–8): **stimmt, eingearbeitet**, Teil A „nötigenfalls mit Pfad“ (Filter an `main` :8) · 5 „Beachte“ in Teil B „bis zum Zuschnitt“: **stimmt, eingearbeitet** · 6 Kopfzeile 4a: **stimmt, eingearbeitet**, Fassung 5 mit Größe. Teil A 1.104 Byte. Nachprüfung der Fassung 5 offen.

## Nachprüfung 22:20, mein Wort

Mein Wort (Sokrates): alle **stimmt**. Grundsatz: 1727f (21:33) ist entschieden und eingebaut, nicht mehr Gesprächspunkt.
1 Aufbau und Regelbilanz führen die zurückgezogene Chefsache 1727a weiter: **stimmt, eingearbeitet**, Aufbau „Satz 1311 in Profil Technik bleibt (1727a zurückgezogen, 21:18)“, Regelbilanz in der Größe Fassung 1 gestrichen · 2 Teil B „Gesprächspunkt“ und „bis zum Zuschnitt“ gegen 1727f: **stimmt, eingearbeitet**, „entschieden 1727f, 21:33; eingebaut in `kern-arbeitsplaner.md` (84061cd95)“, Wortlaut wie Vorlage · 3 Notizschreiber ohne `tools/lehren.py`: **stimmt, eingearbeitet**, in die Liste Teil B (`LISTE-LEHREN.md`; `lehren.py`:2–3, :17, :115, :165; Aufruf `rueckmeldung.py`:178–182, an `main` geprüft) · 4 Raster „ja → kein Test des Chefs“, aber `rueckmeldung.py`:89 gibt „ja“ als Testbitte an den Chef: **stimmt, eingearbeitet**, als Lücke im Raster mit Vorgang 1790 (Spike) · 5 Ladesumme fehlt: **stimmt, eingearbeitet**, unten.

Größe Fassung 6 (`wc -c`, Codeblock Teil A): 1.104 Byte (unverändert). Ladesumme Fachkraft: Sockel 1.110 + Auftrag bis etwa 2 KB + 1.104, bis etwa 4,2 KB. Arbeitsplaner mit diesem Profil: Sockel 1.110 + Kern Arbeitsplaner 2.556 + Teil A 1.104 = 4.770 Byte. Nachprüfung der Fassung 6 offen.

## Nachprüfung 22:29/22:30, mein Wort

Mein Wort (Sokrates): alle **stimmt**. 1 `rueckmeldung.py`-Zeilen: **stimmt, eingearbeitet**, mit Funktionsname und Commit 1e38d1a2d: Testbitte bei „ja“ (`weitergabe`), Weitergabe an Sokrates (`eintragen`), Aufruf `lehren` (`haupt`) · 2 Fassung Profil Disponent: **stimmt, eingearbeitet**, „F7 (22:39)“ (aktuelle Fassung) an beiden Stellen · 3 Ladesumme Arbeitsplaner ohne Kern Büro: **stimmt, eingearbeitet**: der Arbeitsplaner gehört zum Büro und lädt Kern Büro (`uebergabekette.md` Nr. 1 „Büro: Kern Büro (Gemeinsames), Profil Disponent, Profil Arbeitsplaner“; Archiv 21.11., 11:46 „Kern Büro schmal“: Kern Büro bleibt, „alles andere Profil Disponent bzw. Arbeitsplaner“). Kern Büro heute `kern-buero.md` 2.351 Byte (Messregel, herausgezogene Fassung 3.1; der schmale Kern, etwa 0,5 KB, ist noch nicht geschrieben).

Größe Fassung 7: Teil A 1.104 Byte (unverändert). Ladesumme Arbeitsplaner mit diesem Profil: Sockel 1.110 + Kern Büro 2.351 (Stand 43b57854c) + Kern Arbeitsplaner 2.556 + Teil A 1.104 = 7.121 Byte; mit schmalem Kern Büro (etwa 500) etwa 5,3 KB.

## Nachprüfung 22:47, mein Wort

Mein Wort (Sokrates): alle **stimmt**. Ladesumme Arbeitsplaner: **stimmt, eingearbeitet**, Kern Büro 2.351 Byte nach Messregel mit „Stand 43b57854c“ (der schmale Kern Büro ist in Arbeit, noch nicht an `main`); Summe 7.121 Byte unverändert · Fassung Profil Disponent: **stimmt, eingearbeitet**, „F7 (22:39)“ statt „22:3x“. Teil A unverändert 1.104 Byte.

Größe Fassung 9: Teil A 1.103 Byte (Messregel; vorher mit Zeilenende 1.104). Ladesumme Arbeitsplaner mit diesem Profil: Sockel 1.110 + Kern Büro 680 (`kern-buero.md` Fassung 2, Ladetext bis „## Verlauf“, Messregel, Stand 8c4da3b8d) + Kern Arbeitsplaner 2.556 + Teil A 1.103 = 5.449 Byte (ohne Kern Büro 4.769). Ladesumme Fachkraft: Sockel 1.110 + Auftrag bis etwa 2 KB + 1.103, bis etwa 4,2 KB.

## Konsolidierung 22:5x, mein Wort

Mein Wort (Sokrates), Fassung 9: **stimmt, eingearbeitet**. :24 Profil Disponent auf F9 („Ausnahme 1311 als Vorschlag in :20, Perikles prüft (1794)“; vorher F7, 1773); :27 „F7“ → „F9“ (Satz :28 dort unverändert) · Teil A nach Messregel 1.103 statt 1.104 (vorher mit Zeilenende) · Ladesumme Arbeitsplaner mit schmalem Kern Büro 680 Byte (Stand 8c4da3b8d): 7.121 → 5.449 Byte.
