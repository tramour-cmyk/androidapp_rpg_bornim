# 1727: Build-Kette (19.11., 21:14–21:25)

Chef 21:12: „Wie stellen wir sicher, dass wenn ein Build läuft, nicht wieder irgendwelche Commits irgendwo landen und der Runner das 15. Mal anfangen darf … wie stellen wir sicher, dass die Sachen ordentlich auf Main gepusht sind … ich Build 400 teste, aber die Commits oder die Pull Requests von Build 380 noch nicht mal drin sind.“ Chef 21:22: „Ist deine Bildkette jetzt auch gegengeprüft oder ist das wieder nur deine Idee?“ (war sie nicht; Gegenprüfung 21:23).

## Befund der Gegenprüfung (frischer Helfer, 21:23; von Sokrates nachgeprüft)

- Auf `main` in zwei Tagen rund 1390 Commits, fast alles Notizen, Werkzeug, Bot (`zug-index.yml` pusht `HEAD:main`). Ein Fast-Forward eines Buildzweigs nach `main` ist darum praktisch nie möglich.
- Build 300 kam als Merge `3db05d4e5` nach `main`; gegen die getestete Spitze `dbdff8bc2` sind `godot.yml` und `godot/tests/durchstich_1631.gd` verändert (nachgeprüft 21:23). Nach dem Merge prüft kein Lauf `main` (`godot.yml` Z. 8 baut nur Team- und Buildzweige).
- Mischschaden belegt: `0170669af` „das Einmischen von main nahm Jerrys 1566 heraus“.
- Haken `buildzweig-haken.py`: Muster `claude/build-\d+` verfehlt `claude/build-496a`; unbekannte Rolle und Fehler lassen durch; wirkt nicht in der Weboberfläche, nicht für Bot-Token. Ein Account: GitHub kann Sitzungen nicht unterscheiden; Regeln gegen Force-Push und Löschen helfen nur gegen Versehen (unsicher, ob der Plan Rulesets für private Repos hat).

Wort je Punkt des ersten Vorschlags (21:14): 1 Kennungen einfrieren **stimmt** · 2 Haken nach Auftrag **Einwand** (Sitte, keine Sperre) · 3 einmal nachbessern **stimmt mit Lücke** (wer stellt „selbst verursacht“ fest; Notfall fehlt) · 4 „ohne Änderung nach main“ **Einwand, technisch falsch** · 5 Einer-Sperre **Lücke** (Chef testet tagelang nicht = Stillstand, gegen 1312, 324) · 6 Zeile „enthält n-1“ **stimmt**, Werkzeug statt Prüfer · 7 Revert **stimmt** (geübt bei 760).

## Neuer Vorschlag (Sokrates 21:25)

1. **Einfrieren:** Build-Auftrag B<n> nennt je Vorgang die Commit-Kennung; Konflikte zwischen Vorgängen löst der Besitzer des späteren Zweigs vor dem Einfrieren; was danach fertig wird, fährt im nächsten Build (wie heute `LISTE-CHECK-BUILD-TEST.md` 3).
2. **Sicherung durch Vergleich statt Haken:** Werkzeug vergleicht vor der Testbitte und vor dem Merge die Spitze von `claude/build-<n>` mit dem, was der Build-Macher laut Auftrag gepusht hat; jeder fremde Commit, gleich auf welchem Weg, macht den Build ungültig (laut an den Chef, nicht senden). Haken bleibt nur gegen Versehen: Muster `claude/build-\S+`, unbekannte Rolle hält an. Regel auf GitHub gegen Force-Push und Löschen der Buildzweige (stellt der Chef ein, Spike prüft vorher, ob der Plan es hat).
3. **Roter Build:** fremd ist rot in einem Test, den der Build-Macher nicht geändert hat → Vorgang zurück, nächster Build; selbst verursacht (Zusammenführen, Konflikt) → einmal nachbessern; zweites Rot → abgebrochen, Nummer verbraucht. Roter Start- oder Absturztest: Notfallweg (Eilt-Build darf überholen).
4. **Nach `main` mit Nachweis:** vor dem Merge den Buildzweig noch einmal auf `main` bringen; Werkzeug vergleicht die Spielcode-Pfade (Pfadfilter von `godot.yml`) zwischen getesteter Spitze und Merge; leer → Merge; nicht leer → Kerntests auf dem Merge, rot → kein Merge. Dazu Commit-Prüfung: Spielcode-Pfade auf `main` nur über einen Buildzweig. Nach jedem Merge ein Kerntestlauf auf `main`.
5. **Zug statt Einer-Sperre:** Build n+1 setzt auf Build n auf, solange n beim Chef liegt; höchstens zwei offen. Werkzeug hält an, wenn ein neuer Build einen früheren, nicht verworfenen Build nicht enthält (`git merge-base --is-ancestor`); „verworfen“ als feste Archivzeile. So kann Build 400 ohne 380 nicht entstehen, und wer nicht testet, hält nur den dritten Build auf.
6. **Zeile in der Telegram-Meldung** „enthält alle früheren Builds: ja“ erzeugt das Werkzeug.
7. **Fund in einem Teil:** X per Revert heraus (auch im aufsetzenden Build), Kerntests, Rest nach `main`; ganz verwerfen nur, wenn X verflochten ist.

Größere Alternative (nicht empfohlen): Notizen auf eigenen Zweig oder eigenes Repo, dann wäre Fast-Forward möglich (Merge-Queue); zu teuer für den Nutzen, solange 4 den Unterschied nachweist.
