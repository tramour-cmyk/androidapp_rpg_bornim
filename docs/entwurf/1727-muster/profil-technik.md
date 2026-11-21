# 1727, Profil Technik (Gesamtbild 5.3 Nr. 10; Fassung 12, Sokrates 21.11., 15:12)

Auftrag Chef 21.11., 14:37: „Dann lass doch mal das Profil Technik erstellen, von dem wir so viel reden … Leg mal vor, check selbst, lass es gegenchecken und dann lass es mich sehen.“

Geladen von: Fachkraft mit Profil Technik (Technik, Grafik, Leistung; Build-Macher), Arbeitsplaner und Prüfer bei Aufträgen dieser Art. Nicht hier: Firmenwerkzeuge im Einzelnen (Profil Werkzeug, Nr. 11; bis es steht, trägt Teil A die Regel 1311); wann ein Build fällig ist (Grobablauf 3.19.1) und wer den Build-Macher startet: Disponent. Was der Sockel trägt (Keystore, Zugangsdaten, App-Kennung, Verlauf, Spielcode nur nach Test), steht hier nicht. **Gilt ab der Umstellung;** bis dahin bleiben Checkliste und `ROLLE-TECHNIK.md` wie sie sind.

Quellen: `ROLLE-TECHNIK.md` (Haltung, Aufgaben 2 und 3), `LISTE-CHECK-BUILD-TEST.md` (einzige Stelle für Build und Test, 903 B), `LISTE-BAUEN-TESTEN.md`, `LISTE-TECHNIK-PRAXIS.md` (1270.5), `LISTE-RELEASE-NEUSTART.md`, `1727-muster/build-kette.md` (entschieden 19.11., 22:05: „Build Kette so, aber in großen Test am Samstag abend ebenfalls prüfen“), Gesamtbetrachtung (Prüfpunkt, entschieden 21.11., 11:17), Archiv 21.11., 14:37 D (Haken trägt Chefwort in die Vorgangsdatei).

## Aufbau

- **Build-Kette 1–7 kommt in die Checkliste** (Teil B), nicht ins Profil; „Spike“ heißt dort künftig „Build-Macher“. Was dort „Werkzeug“ heißt, steht als Zeile „Build-Werkzeug“ in der Bauliste 7.1 (Gesamtbild); bis es gebaut ist, prüft der Build-Macher von Hand. Ihr Fall Build bleibt Pflicht im großen Falltest.
- **Dein Wort nötig, 235** (20.10.: „Wer die Freigabe des Chefs hört, führt den PR selbst zusammen (meist Sokrates; Merge, nie Squash/Rebase)“; Grund damals: jede Prüfung sieht nur die eigene Sitzung). Vorschlag: die Freigabe trägt der Haken D in die Vorgangsdatei, der Disponent startet den Build-Macher, der führt zusammen. Das ersetzt Checkliste 13 vom Anfang bis „(die Prüfliste ist seit 11 weg).“ (beide Sätze, Merge-Art und `CHANGELOG.md` stehen im neuen Text); der Rest von 13 bleibt ab „**`main` nur grün und vom Chef getestet**“ (919, samt Fettdruck). Ohne dein Wort bleibt 235, und der Absatz „Nach `main`“ in Teil A entfällt.

## Teil A: Profil Technik

```markdown
**Technik.** Godot-Technik, Licht, Shader, Leistung, Ladezeit, Build. Erst nachsehen, wie andere es lösen (`docs/LISTE-TECHNIK-PRAXIS.md`, Quelle in die Rückmeldung). Einen Fehler erst nachstellen (Test oder Vorschau zeigt ihn rot), dann beheben. Maß für Leistung ist das Handy A56, das Tablet nur Untergrenze. Rückmeldung: Messung vorher und nachher.

**Vor jedem Code-Commit** die Kerntests mit Exit-Code (`tools/t logik`). Ein Werkzeug (nicht Spielcode) geht nach grünem Lauf sofort nach `main`.

**Build.** Nennt dein Auftrag einen Build, bist du der Build-Macher: Regeln ganz in `docs/LISTE-CHECK-BUILD-TEST.md`. Vor dem Sammelbuild: gebaute Kaufmodelle je Block und Cache-Treffer da; nach dem Merge einer Änderung an einem Bauskript den Block zum Stand von `main` neu ablegen, damit der Bauserver ohne Blender läuft; Laufzeit in die Testbitte.

**Nach `main`** führst du zusammen, wenn dein Auftrag es nennt: nach der Freigabe des ganzen Builds (welche Worte gelten und was „mit Einschränkungen“ heißt: Checkliste 13) oder nach dem Ergebnis mit Durchfall (Checkliste 11, 12: Revert, Rest nach `main`), belegt in der Vorgangsdatei. Release nur auf Zuruf des Chefs (`docs/LISTE-RELEASE-NEUSTART.md`).
```

## Teil B: Checkliste, neue und geänderte Punkte

Wortlaut der Build-Kette (entschieden 19.11., 22:05) ohne Zusatz, nur „Spike“ → „Build-Macher“ (dazu die Grammatik); **neu** markiert, was nicht aus ihr stammt.

```markdown
**Build-Kette** (1727, Chef 19.11., 22:05):
- **Einfrieren:** Build-Auftrag B<n> nennt je Vorgang die Commit-Kennung; Konflikte zwischen Vorgängen löst der Besitzer des späteren Zweigs vor dem Einfrieren; was danach fertig wird, fährt im nächsten Build (wie heute `LISTE-CHECK-BUILD-TEST.md` 3).
- **Sicherung durch Vergleich statt Haken:** Werkzeug vergleicht vor der Testbitte und vor dem Merge die Spitze von `claude/build-<n>` mit dem, was der Build-Macher laut Auftrag gepusht hat; jeder fremde Commit, gleich auf welchem Weg, macht den Build ungültig (laut an den Chef, nicht senden). Haken bleibt nur gegen Versehen: Muster `claude/build-\S+`, unbekannte Rolle hält an. Regel auf GitHub gegen Force-Push und Löschen der Buildzweige (stellt der Chef ein, der Build-Macher prüft vorher, ob der Plan es hat).
- **Roter Build:** fremd ist rot in einem Test, den der Build-Macher nicht geändert hat → Vorgang zurück, nächster Build; selbst verursacht (Zusammenführen, Konflikt) → einmal nachbessern; zweites Rot → abgebrochen, Nummer verbraucht. Roter Start- oder Absturztest: Notfallweg (Eilt-Build darf überholen). **Neu:** sonst gilt weiter 918, 919 (Testbitte trotz Rot, rote Tests oben in der Prüfliste).
- **Nach `main` mit Nachweis:** vor dem Merge den Buildzweig noch einmal auf `main` bringen; Werkzeug vergleicht die Spielcode-Pfade (Pfadfilter von `godot.yml`) zwischen getesteter Spitze und Merge; leer → Merge; nicht leer → Kerntests auf dem Merge, rot → kein Merge. Dazu Commit-Prüfung: Spielcode-Pfade auf `main` nur über einen Buildzweig. Nach jedem Merge ein Kerntestlauf auf `main`. **Neu (Gesamtbetrachtung 21.11.):** dazu je gebilligtem Vorgang prüfen, ob seine Commits auf `main` sind und seine Änderung nicht zurückgenommen ist (Fall 1566).
- **Zug statt Einer-Sperre:** Build n+1 setzt auf Build n auf, solange n beim Chef liegt; höchstens zwei offen. Werkzeug hält an, wenn ein neuer Build einen früheren, nicht verworfenen Build nicht enthält (`git merge-base --is-ancestor`); „verworfen“ als feste Archivzeile. So kann Build 400 ohne 380 nicht entstehen, und wer nicht testet, hält nur den dritten Build auf.
- **Zeile in der Telegram-Meldung** „enthält alle früheren Builds: ja“ erzeugt das Werkzeug.

Punkt 12 ergänzt (Build-Kette 7): der durchgefallene Punkt fliegt per Revert heraus, auch im aufsetzenden Build; Kerntests; Rest nach `main`; ganz verwerfen nur, wenn er verflochten ist.
Punkt 13, Anfang bis „(die Prüfliste ist seit 11 weg).“ ersetzt, **neu, nur mit deinem Wort zu 235:** „**Nach der Freigabe des ganzen Builds** („gut“, „passt“, „freigegeben“; ein 👍 gilt nur für einen Punkt) oder dem Ergebnis nach 11 und 12 führt der Build-Macher, den der Disponent startet, den PR zusammen, sobald er grün ist (Merge, nie Squash/Rebase; 108a.1); die Freigabe steht in der Vorgangsdatei (aus fremder Sitzung trägt sie der Haken ein); bei Konflikt geht er ans Team zurück, das Team holt danach `main`. Ergebnis in `CHANGELOG.md` (die Prüfliste ist seit 11 weg).“ Der Rest von 13 bleibt ab „**`main` nur grün und vom Chef getestet**“ (samt Fettdruck).
Punkt 13, Zusatz am Ende von 13, **neu (Fall des Chefs 21.11., 15:04, „freigegeben und passt mit Einschränkungen“; gilt mit und ohne Wort zu 235):** „**Freigabe mit Einschränkungen:** was nach 12 durchfällt (in jeder Art, auch ✗ oder 👎), fliegt je Vorgang per Revert heraus; ein ✓, dessen Zusatz einen Mangel nennt, und ein Fund außerhalb der Prüfpunkte bleiben drin, und wer zusammenführt, legt sie vor dem Merge mit `vorgang.py neu` beim Besitzer an (sagt der Zusatz, dass noch nicht fertig geprüft ist, gilt 11). Das Chefwort steht vor dem Merge in der Vorgangsdatei (kam es in einer fremden Sitzung, trägt es der Haken ein, sonst wer zusammenführt; Archiv 1727, 21.11., 14:37); danach die Vollzugszeile „Vollzug <Vorgang>: Build <n> auf `main` ohne <Vorgänge>, Geprüft an: <Merge>“, ohne Abzug ohne den Zusatz „ohne …“. Lässt sich eine Einschränkung keinem Punkt und keinem Fund zuordnen, legt er eine Datei in `entscheiden/` an und führt erst nach der Antwort zusammen.“
```

## Eigene Prüfung (15:10)

- Größe (UTF-8, Inhalt der Codeblöcke, nachgemessen): Teil A etwa 1.220 Byte (Oberfläche 1.000); Teil B etwa 4.180 Byte (davon Zusatz Einschränkungen, Zitat allein, etwa 860; Format der Vollzugszeile nach Praxis „Vollzug 1724: Build 300 auf main ohne 760“), davon ersetzt Punkt 13 den alten Anfang von 13 bis „seit 11 weg“; dafür fällt `1727-muster/build-kette.md` als Ort weg (Regelbilanz). Teil B ist länger als F4, weil Werkzeug, Haken und GitHub-Regel wieder im Wortlaut stehen.
- Quellen je Satz: A = `ROLLE-TECHNIK.md` Haltung, Aufgabe 2 und 3 (Technikliste, A56 Maß, Tablet Untergrenze; Archiv 1270.6), `CLAUDE.md` „Jeder Schritt“ (Kerntests mit Exit-Code), Checkliste 11–13; Freigabeworte in B Punkt 13: „passt“, „freigegeben“ aus Checkliste 13, „gut“ aus Kern Büro (`1727-gesamtbild.md`, A14 in `1727-muster/ablauf.md`), 👍 je Punkt aus Checkliste 11; B sonst = Build-Kette 1–7 wörtlich, Gesamtbetrachtung (Prüfpunkt), Checkliste 12 (Revert), 918, 919.
- Fälle: Build 300 (Merge `3db05d4e5` ≠ getesteter Stand): Pfadvergleich fängt ihn · Build 400 ohne 380: Werkzeug hält an · 1566: Prüfung „Änderung nicht zurückgenommen“ (Build-Werkzeug, neu in Bauliste 7.1; bis dahin `git diff` je Vorgangs-Commit von Hand) · t300 (Ergebnis mit ✗, kein „passt“): Teil A deckt den Rest nach Revert (nur mit Wort zu 235; sonst bleibt das alte „Sonst:“ in 13) · 1664: ob er nicht auf `main` kam, ist unbelegt (Liste: „erledigt, t300 bestanden“), darum nicht als Beleg genannt.
- Offen: „Ohne dich“ und Kleinkram gehen nach Checkliste 3 und 9 ohne Test des Chefs nach `main`, unverändert; Kerntests vor dem Commit gelten für jede Fachkraft mit Code, nicht nur Technik: als Werkzeug (Commit-Haken) in die Bauliste. Neue Begriffe Build-Macher, Disponent, Vorgangsdatei kommen mit der Umstellung ins Glossar.

## Fall des Chefs 15:04 und Prüfung 15:06 (Fassung 8 → 9), mein Wort

Chef: „Wenn ich jetzt wie früher immer sage, ja, der Testbuild ist freigegeben und passt mit Einschränkungen.“ Prüfer: F8 hat eine Lücke (ohne ✗ wird alles samt Mangel zusammengeführt); im Archiv beides: t268, t269 ganz rein, Funde neu (vor Checkliste 12, 09.11.); 89, 298–300 mit Revert; seit 12 jedes ✗ Revert, Fund ohne ✗ bleibt (t299: neue Funde 1674–1676). Mein Entwurf 15:05 unvollständig: Fund, der drinbleibt (**stimmt**), Rückfrage nur mit Datei (**stimmt**), Build-Macher nur mit 235 (**stimmt**, neutral „wer zusammenführt“), Haken D (**stimmt**), „ohne Abzug“ (**stimmt**). Fassung des Prüfers übernommen als Zusatz zu 13.

## Nachprüfung 15:12 (Fassung 12): keine neuen Fehler

Prüfer: Einarbeitung 15:10 stimmt (Checkliste 11, 12; D; 3.3 Nr. 7; Vollzug 1724); Größen 1.220 / 4.182 / 861 Byte; Zitat 235 stimmt. Hinweis Aufbau „Haken D“ ohne Bedingung: im vorgeschlagenen Ablauf kommt die Freigabe immer aus fremder Sitzung, nicht falsch.

## Nachprüfung 15:10 (Fassung 11, 2 Befunde, beide neu von mir), mein Wort

1 jedes ✓ mit Zusatz würde neuer Vorgang (auch „noch nicht fertig geprüft“, gegen 11 und 412): **stimmt**, nur Zusatz mit Mangel, sonst 11 · 2 „Haken D, wie oben“ ohne 235 ins Leere, Haken nur für fremde Sitzung: **stimmt**, beide Fälle ausgeschrieben, auch im neuen Anfang von 13.

## Nachprüfung 15:09 (Fassung 10, 4 Befunde, alle neu von mir), mein Wort

1 „✗ oder 👎“ enger als 12 („in jeder Art“): **stimmt**, Verweis auf 12 · 2 „Vollzug t<n>“ gegen Praxis (Vollzug 1724: Build 300 auf main ohne 760), Revert je Vorgang: **stimmt**, Format nach Praxis · 3 Anführungszeichen: **stimmt** · 4 Haken doppelt: **stimmt**, „wie oben“.

## Nachprüfung 15:08 (Fassung 9, 6 Befunde, alle neu), mein Wort

1 „✓ mit Zusatz“ würde zum ✗ umgedeutet (298.3; nie Chefurteil umformulieren): **stimmt**, nur ✗ oder 👎 des Chefs ist Revert · 2 wer den Vorgang anlegt: **stimmt**, wer zusammenführt, `vorgang.py neu` · 3 Telegram-Zeile doppelt zum Vollzug: **stimmt**, eine Vollzugszeile mit Prüfpunkten n.k · 4 Beleg 298.2 falsch: **stimmt**, t299 · 5 Größe, Uhrzeit: **stimmt** · 6 Stelle in 13: **stimmt**, am Ende.

## Nachprüfung 15:02 (Fassung 8, keine Fehler in Tatsache, Regel, Quelle, Entscheid; 2 Formbefunde), mein Wort

1 Schnitt in 13 vor dem Fettdruck: **stimmt**, mit Sternchen · 2 t300-Satz ohne Bedingung 235: **stimmt**, Bedingung ergänzt.

## Nachprüfung 14:59 (Fassung 7, 2 Befunde, davon 1 neu von mir), mein Wort

1 Ersatz von 13 nimmt die Freigabeworte aus der Checkliste (gegen 903 B): **stimmt**, Worte in den neuen Satz 13, Teil A verweist · 2 „gut“ steht nicht in Checkliste 11–13: **stimmt**, Quelle Kern Büro (A14) ergänzt. „Grafik-Engine ausschöpfen“ bleibt draußen (Ziel, keine Regel).

## Nachprüfung 14:58 (Fassung 6, 3 Befunde, davon 1 neu von mir), mein Wort

1 Naht in 13: „Sonst“-Satz läuft bis „seit 11 weg“, Rest ohne Verb: **stimmt**, Ersatz bis dorthin, Merge-Art und `CHANGELOG.md` im neuen Satz · 2 Aufgabe 3 als Quelle fehlt, „am Rechner nur vorläufig“ ohne Quelle: **stimmt**, Quelle ergänzt, Satz gestrichen · 3 Kerntest-Warnung kommt aus `commit-pruefung.py`, nicht `tools/t`: **stimmt**, berichtigt.

## Nachprüfung 14:55 (Fassung 5, 4 Befunde, davon 2 neu von mir), mein Wort

1 Rest von 13 behielte „Konflikt zurück“ nicht, „Sonst:“ stünde ohne Bezug: **stimmt**, Konfliktsatz in den neuen Satz, „Sonst:“ ersetzt · 2 Bauliste ohne Kerntests auf dem Merge und Lauf auf `main`: **stimmt**, ergänzt, Stand „Lauf auf `main` fehlt“ · 3 Punkt 1 und 5 nicht wörtlich: **stimmt**, wörtlich · 4 Kerntest-Haken fehlt in 7.1: **stimmt**, Zeile nachgetragen.

## Nachprüfung 14:51 (Fassung 4, 5 Befunde, alle neu), mein Wort

1 Teil B nahm der Build-Kette „Werkzeug“, Haken und GitHub-Regel; Werkzeuge fehlen in Bauliste 7.1: **stimmt**, Wortlaut zurück, Zeile „Build-Werkzeug“ in 7.1 · 2 918/919 ohne „neu“: **stimmt** · 3 Rest nach Revert ohne Zuständigen (t300): **stimmt**, Teil A und 13 ergänzt · 4 Zitat 235 ohne „Merge, nie Squash/Rebase“, Umfang 13 unklar: **stimmt**, nur erster Satz · 5 Größe Teil B falsch: **stimmt**, neu gemessen.

## Nachprüfung 14:44 (Fassung 3, 13 Befunde), mein Wort

1 Eintragen der Freigabe dreimal verschieden, Haken D übersehen: **stimmt**, Haken · 2 Teil A ohne Bedingung 235: **stimmt** · 3 Build-Kette 7 unvollständig, an falscher Stelle: **stimmt**, als Ergänzung von Punkt 12 · 4 „Vorgang dieses Tests“ eigene Auslegung: **stimmt**, Wortlaut der Build-Kette · 5 Commit-Prüfung „nur über einen Buildzweig“ fehlte: **stimmt** · 6 Neues nicht abgesetzt: **stimmt** · 7 Kopf gegen Teil A bei 1311: **stimmt** · 8 doppelt zu Punkt 12: **stimmt** · 9 „misst der Chef“ ohne Quelle: **stimmt**, gestrichen · 10 Quelle fehlte: **stimmt** · 11 Kerntest-Marke als Warnung besteht: **stimmt**, Haken in der Bauliste nur verschärfen · 12 Übergang: **stimmt**, „gilt ab der Umstellung“ · 13 großer Test: **stimmt**.

## Nachprüfung 14:42 (Fassung 2, 8 Befunde, davon 2 neue Fehler von mir), mein Wort

1 `tools/t` ohne Befehl nur Übersicht, Kerntest ist `tools/t logik`: **stimmt** · 2 👍 gilt nur für einen Punkt: **stimmt** · 3 Rot gegen 918/919, Build-Kette 7 unvollständig: **stimmt**, 918/919 bleiben für Reste, 7 ergänzt · 4 Zug „setzt auf n auf“ und „verworfen“ fehlten: **stimmt** · 5 Ersatz von 235 muss dir ausdrücklich vorliegen, „Spike“ in der Checkliste: **stimmt** · 6 „laut, nichts senden“ missverständlich, Pfade, Handypunkt, Build-Auftrag neu: **stimmt** · 7 1311 Werkzeug sofort nach `main` fiele aus: **stimmt**, bis Profil Werkzeug hier · 8 Quellenangabe 1270.6 schärfen: **stimmt**.

## Gegenprüfung 14:40 (Fassung 1, 8 Befunde), mein Wort

1 Build-Kette nur im Profil gegen 903 B, Merge-Sätze doppelt: **stimmt**, Teil B in die Checkliste · 2 „steckt fest ans Büro“ gegen „laut an den Chef“ (Build-Kette 2, Gegenüberstellung Meldeweg): **stimmt**, zurück auf laut · 3 nur „gut“ zu eng: **stimmt** · 4 Zusammenführen doppelt (Checkliste 13 Sokrates): **stimmt**, Checkliste 13 wird angepasst · 5 fehlt Kaufmodelle und Cache, Notfallweg, Folge bei fehlendem „enthält“, „selbst verursacht“, A56 als Handypunkt, Kerntests vor Commit; Haken und Rulesets einmalig: **stimmt** · 6 Rot-Regel gegen 918/919, Revert ausdrücklich: **stimmt** · 7 1566 fängt Abstammung nicht, 1664 unbelegt: **stimmt** · 8 doppelt „Messung“, Begriffe: **stimmt**.
