# 235 · Sperren der Auto-Modus-Prüfung: Fehleranalyse und Lösung
Sokrates · 20.10., 08:44, überarbeitet 08:46 · Q Ablauf · M (Auftrag Chef 08:37 über Perikles; Chef 08:44: „Jetzt mach mal eine ordentliche Fehleranalyse und sorg für eine richtige Problemlösung.“; berührt 234, 222, 222.1, D36.5)

## Was passiert

Jede Sitzung läuft im Auto-Modus. Vor jedem Schritt, den keine feste Regel erlaubt, fragt eine Sicherheitsprüfung (ein eigenes Modell), ob der Schritt gewollt ist. Sie sperrt vor allem: einen PR nach `main` zusammenführen, auf `main` pushen, Regeldateien umschreiben, `.claude/` ändern.

## Warum gestern nichts gebracht hat (mein Fehler)

1. **Die Prüfung glaubt nur, was du in derselben Sitzung sagst.** Was in Dateien steht, sieht sie nicht als Freigabe. Das ist Absicht: Sonst könnte jede Sitzung sich eine Freigabe selbst hineinschreiben. Darum scheitert „du gibst bei Sokrates frei, Jerry führt zusammen“ immer, egal was im Vorrat steht.
2. **Der Erklärsatz von gestern (222.1 Punkt 3, `autoMode` in `.claude/settings.json`) wird von der Prüfung gar nicht gelesen.** Laut Doku liest sie `autoMode` nur aus Benutzer- oder Organisationseinstellungen, nie aus der Projektdatei. Ich habe ihn gestern empfohlen, ohne das nachzusehen. Wirksam waren nur die festen Listen `allow` und `deny` (Rebase-Sperre nachgewiesen).
3. **Feste Erlaubnisse (`permissions.allow`) wirken auch im Auto-Modus,** und zwar vor der Prüfung: Ein erlaubter Schritt wird gar nicht erst geprüft. Wir haben bisher nur Lesebefehle erlaubt, nicht die Schritte, die tatsächlich sperren.

## Lösung: die Schritte, die du ohnehin freigibst, fest erlauben

In `.claude/settings.json` unter `permissions.allow`:
- **Zusammenführen eines PR** über GitHub (`mcp__github__merge_pull_request`). Dann reicht deine eine Freigabe, egal in welcher Sitzung; wer sie hört, trägt sie ein, das Team führt zusammen, ohne Rückfrage.
- **Notizarbeit:** `git add`, `git commit`, `git pull`, `git push` sowie Schreiben mit Edit/Write unter `/home/user/bornim-main` (`docs/`, `CLAUDE.md`, `CHANGELOG.md`).
- **Unsere Werkzeuge:** `tools/notiz.sh`, `tools/meldung.sh`, `python3 tools/startbar.py`, `lauf.py`, `regelcheck.py`.

Bleibt verboten (`deny` geht vor `allow`): Force-Push, Rebase. Dazu neu verboten: Löschen von Zweigen auf GitHub (`git push --delete`). Den wirkungslosen `autoMode`-Satz streiche ich (Regelbilanz).

Zu 234: Punkt 1 (Satz in `autoMode`) entfällt, er wirkt nicht; Punkt 2 (`notiz.sh` bricht ein misslungenes Zusammenführen ab) ja, Perikles setzt ihn um, sobald (1) gilt.

**Prüfung danach:** Ich trage es ein. Die nächste Freigabe gibst du irgendwo einmal; mergt das Team ohne Rückfrage, ist es gelöst. Sperrt es trotzdem, liegt der Wortlaut der Sperre bei mir, und ich lege nach, bevor du es merkst.

## Stärkstes Gegenargument

Die Prüfung war die einzige technische Sperre gegen „Code ohne deinen Test auf `main`“. Danach schützt nur noch die Regel, dazu Diogenes, der `main` prüft. Gewicht: Bisher hat kein Team gegen die Regel gemergt; die Prüfung hat dagegen jeden Tag deine echten Freigaben gesperrt. Wer ohne Freigabe mergt, fällt in Diogenes' Prüfung auf und lässt sich mit einem Revert zurücknehmen.

Nicht empfohlen: die ganze Prüfung abschalten (Modus „ohne Rückfrage“). Das ginge, nähme aber auch den Schutz bei allem anderen.

## Antwort

„235 ja“. Die Änderung an `.claude/settings.json` mache ich dann in dieser Sitzung, weil die Prüfung deine Freigabe nur hier sieht.
