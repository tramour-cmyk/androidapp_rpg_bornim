# 1727, Profil Technik (Gesamtbild 5.3 Nr. 10; Fassung 4, Sokrates 21.11., 14:48)

Auftrag Chef 21.11., 14:37: „Dann lass doch mal das Profil Technik erstellen, von dem wir so viel reden … Leg mal vor, check selbst, lass es gegenchecken und dann lass es mich sehen.“

Geladen von: Fachkraft mit Profil Technik (Technik, Grafik, Leistung; Build-Macher), Arbeitsplaner und Prüfer bei Aufträgen dieser Art. Nicht hier: Firmenwerkzeuge im Einzelnen (Profil Werkzeug, Nr. 11; bis es steht, trägt Teil A die Regel 1311); wann ein Build fällig ist (Grobablauf 3.19.1) und wer den Build-Macher startet: Disponent. Was der Sockel trägt (Keystore, Zugangsdaten, App-Kennung, Verlauf, Spielcode nur nach Test), steht hier nicht. **Gilt ab der Umstellung;** bis dahin bleiben Checkliste und `ROLLE-TECHNIK.md` wie sie sind.

Quellen: `ROLLE-TECHNIK.md` (Haltung, Aufgabe 2), `LISTE-CHECK-BUILD-TEST.md` (einzige Stelle für Build und Test, 903 B), `LISTE-BAUEN-TESTEN.md`, `LISTE-TECHNIK-PRAXIS.md` (1270.5), `LISTE-RELEASE-NEUSTART.md`, `1727-muster/build-kette.md` (entschieden 19.11., 22:05: „Build Kette so, aber in großen Test am Samstag abend ebenfalls prüfen“), Gesamtbetrachtung (Prüfpunkt, entschieden 21.11., 11:17), Archiv 21.11., 14:37 D (Haken trägt Chefwort in die Vorgangsdatei).

## Aufbau

- **Build-Kette 1–7 kommt in die Checkliste** (Teil B), nicht ins Profil; „Spike“ heißt dort künftig „Build-Macher“. Ihr Fall Build bleibt Pflicht im großen Falltest.
- **Dein Wort nötig, 235** (20.10.: „Wer die Freigabe des Chefs hört, führt den PR selbst zusammen (meist Sokrates)“; Grund damals: jede Prüfung sieht nur die eigene Sitzung). Vorschlag: die Freigabe trägt der Haken D in die Vorgangsdatei, der Disponent startet den Build-Macher, der führt zusammen. Ohne dein Wort bleibt 235, und der Satz „Nach `main`“ in Teil A entfällt.

## Teil A: Profil Technik

```markdown
**Technik.** Godot-Technik, Licht, Shader, Leistung, Ladezeit, Build. Erst nachsehen, wie andere es lösen (`docs/LISTE-TECHNIK-PRAXIS.md`, Quelle in die Rückmeldung). Einen Fehler erst nachstellen (Test oder Vorschau zeigt ihn rot), dann beheben. Leistung misst du am Rechner nur vorläufig; es gilt die Messung auf dem Handy A56, das Tablet ist Untergrenze. Rückmeldung: Messung vorher und nachher.

**Vor jedem Code-Commit** die Kerntests mit Exit-Code (`tools/t logik`). Ein Werkzeug (nicht Spielcode) geht nach grünem Lauf sofort nach `main`.

**Build.** Nennt dein Auftrag einen Build, bist du der Build-Macher: Regeln ganz in `docs/LISTE-CHECK-BUILD-TEST.md`. Vor dem Sammelbuild: gebaute Kaufmodelle je Block und Cache-Treffer da; nach dem Merge einer Änderung an einem Bauskript den Block zum Stand von `main` neu ablegen, damit der Bauserver ohne Blender läuft; Laufzeit in die Testbitte.

**Nach `main`** führst du zusammen, wenn dein Auftrag es nennt: nach der Freigabe des ganzen Builds („gut“, „passt“, „freigegeben“; ein 👍 gilt nur für einen Punkt), belegt in der Vorgangsdatei. Release nur auf Zuruf des Chefs (`docs/LISTE-RELEASE-NEUSTART.md`).
```

## Teil B: Checkliste, neue und geänderte Punkte

Wortlaut der Build-Kette (entschieden 19.11., 22:05) ohne Zusatz; **neu** markiert, was nicht aus ihr stammt.

```markdown
**Build-Kette** (1727, Chef 19.11., 22:05):
- **Einfrieren:** der Build-Auftrag nennt je Vorgang die Commit-Kennung; Konflikte zwischen Vorgängen löst der Besitzer des späteren Zweigs vor dem Einfrieren; was danach fertig wird, fährt im nächsten Build.
- **Vergleich:** vor der Testbitte und vor dem Merge die Spitze von `claude/build-<n>` mit dem vergleichen, was der Build-Macher laut Auftrag gepusht hat; jeder fremde Commit macht den Build ungültig: laut an den Chef, keine Testbitte.
- **Roter Build:** fremd ist rot in einem Test, den der Build-Macher nicht geändert hat → Vorgang zurück, nächster Build; selbst verursacht (Zusammenführen, Konflikt) → einmal nachbessern; zweites Rot → abgebrochen, Nummer verbraucht. Roter Start- oder Absturztest: Notfallweg, ein Eilt-Build darf überholen. Sonst gilt weiter 918, 919 (Testbitte trotz Rot, rote Tests oben in der Prüfliste).
- **Nach `main` mit Nachweis:** vor dem Merge den Buildzweig noch einmal auf `main` bringen; ändern sich dabei Dateien unter den Pfaden, die `godot.yml` baut, gegen die getestete Spitze, Kerntests auf dem Merge, rot: kein Merge. Spielcode-Pfade kommen auf `main` nur über einen Buildzweig (Commit-Prüfung). Nach jedem Merge ein Kerntestlauf auf `main`; **neu (Gesamtbetrachtung 21.11.):** dazu je gebilligtem Vorgang prüfen, ob seine Commits auf `main` sind und seine Änderung nicht zurückgenommen ist (Fall 1566).
- **Zug:** Build n+1 setzt auf Build n auf, solange n beim Chef liegt; höchstens zwei offen. Fehlt einem neuen Build ein früherer, nicht verworfener (`git merge-base --is-ancestor`; „verworfen“ als feste Archivzeile): anhalten. Die Meldung trägt „enthält alle früheren Builds: ja“.

Punkt 12 ergänzt (Build-Kette 7): der durchgefallene Punkt fliegt per Revert heraus, auch im aufsetzenden Build; Kerntests; Rest nach `main`; ganz verwerfen nur, wenn er verflochten ist.
Punkt 13, **neu, nur mit deinem Wort zu 235:** „Nach der Freigabe des ganzen Builds führt der Build-Macher zusammen, den der Disponent startet; die Freigabe steht in der Vorgangsdatei (Haken).“
```

## Eigene Prüfung (14:45)

- Größe: Teil A etwa 1.150 Byte (Oberfläche 1.000); Teil B wächst die Checkliste um etwa 1.300 Byte, dafür fällt `1727-muster/build-kette.md` als Ort weg (Regelbilanz).
- Quellen je Satz: A = `ROLLE-TECHNIK.md` Haltung und Aufgabe 2, Archiv 1270.6 (A56 Maß; „Tablet Untergrenze“ nur in `ROLLE-TECHNIK.md`), `CLAUDE.md` „Jeder Schritt“ (Kerntests mit Exit-Code), Checkliste 13 und 11 (Wörter des Chefs); B = Build-Kette 1–7, Gesamtbetrachtung (Prüfpunkt), Checkliste 12 (Revert).
- Fälle: Build 300 (Merge `3db05d4e5` ≠ getesteter Stand): Pfadvergleich fängt ihn · Build 400 ohne 380: „Enthält“ hält an · 1566: Prüfung „Änderung nicht zurückgenommen“ (braucht Werkzeug, Bauliste 7.1, bis dahin `git diff` je Vorgangs-Commit von Hand) · 1664: ob er nicht auf `main` kam, ist unbelegt (Liste: „erledigt, t300 bestanden“), darum nicht als Beleg genannt.
- Offen: „Ohne dich“ und Kleinkram gehen nach Checkliste 3 und 9 ohne Test des Chefs nach `main`, unverändert; Kerntests vor dem Commit gelten für jede Fachkraft mit Code, nicht nur Technik: als Werkzeug (Commit-Haken) in die Bauliste.

## Nachprüfung 14:44 (Fassung 3, 13 Befunde), mein Wort

1 Eintragen der Freigabe dreimal verschieden, Haken D übersehen: **stimmt**, Haken · 2 Teil A ohne Bedingung 235: **stimmt** · 3 Build-Kette 7 unvollständig, an falscher Stelle: **stimmt**, als Ergänzung von Punkt 12 · 4 „Vorgang dieses Tests“ eigene Auslegung: **stimmt**, Wortlaut der Build-Kette · 5 Commit-Prüfung „nur über einen Buildzweig“ fehlte: **stimmt** · 6 Neues nicht abgesetzt: **stimmt** · 7 Kopf gegen Teil A bei 1311: **stimmt** · 8 doppelt zu Punkt 12: **stimmt** · 9 „misst der Chef“ ohne Quelle: **stimmt**, gestrichen · 10 Quelle fehlte: **stimmt** · 11 Kerntest-Marke als Warnung besteht: **stimmt**, Haken in der Bauliste nur verschärfen · 12 Übergang: **stimmt**, „gilt ab der Umstellung“ · 13 großer Test: **stimmt**.

## Nachprüfung 14:42 (Fassung 2, 8 Befunde, davon 2 neue Fehler von mir), mein Wort

1 `tools/t` ohne Befehl nur Übersicht, Kerntest ist `tools/t logik`: **stimmt** · 2 👍 gilt nur für einen Punkt: **stimmt** · 3 Rot gegen 918/919, Build-Kette 7 unvollständig: **stimmt**, 918/919 bleiben für Reste, 7 ergänzt · 4 Zug „setzt auf n auf“ und „verworfen“ fehlten: **stimmt** · 5 Ersatz von 235 muss dir ausdrücklich vorliegen, „Spike“ in der Checkliste: **stimmt** · 6 „laut, nichts senden“ missverständlich, Pfade, Handypunkt, Build-Auftrag neu: **stimmt** · 7 1311 Werkzeug sofort nach `main` fiele aus: **stimmt**, bis Profil Werkzeug hier · 8 Quellenangabe 1270.6 schärfen: **stimmt**.

## Gegenprüfung 14:40 (Fassung 1, 8 Befunde), mein Wort

1 Build-Kette nur im Profil gegen 903 B, Merge-Sätze doppelt: **stimmt**, Teil B in die Checkliste · 2 „steckt fest ans Büro“ gegen „laut an den Chef“ (Build-Kette 2, Gegenüberstellung Meldeweg): **stimmt**, zurück auf laut · 3 nur „gut“ zu eng: **stimmt** · 4 Zusammenführen doppelt (Checkliste 13 Sokrates): **stimmt**, Checkliste 13 wird angepasst · 5 fehlt Kaufmodelle und Cache, Notfallweg, Folge bei fehlendem „enthält“, „selbst verursacht“, A56 als Handypunkt, Kerntests vor Commit; Haken und Rulesets einmalig: **stimmt** · 6 Rot-Regel gegen 918/919, Revert ausdrücklich: **stimmt** · 7 1566 fängt Abstammung nicht, 1664 unbelegt: **stimmt** · 8 doppelt „Messung“, Begriffe: **stimmt**.
