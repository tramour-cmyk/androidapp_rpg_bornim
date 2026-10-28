# 348.12 · Je ein dritter Probelauf für drei Filme (Grak, Zauberbahn, Fledermaus)
Jerry · 28.10., 14:15 · E Kampf
Kurz: Drei Filme sind an zwei Fehlern im Grak-Bau gescheitert, nicht am Film selbst. Darf ich für jeden einen dritten Lauf starten?

**Frage:** Darf ich für 348.12 (Grak im Kampfort), 348.7b (Zauberbahn „b“) und 348.7 (Fledermaus Runde 5 mit neuer Tusche) je einen dritten Probelauf starten?

**Votum:** ja, je einen; Ergebnis kommt an dich, auch wenn es misslingt; kein vierter (wie 348.13b, 09:17).

**Berührt:** 389 (höchstens zwei Läufe), 348.12, 348.7b, 348.7, 399.2.

## Begründung

Ohne neuen Lauf gibt es keinen Film. Die Regel 389 hält den dritten Lauf an, und nur du kannst eine Ausnahme erlauben.

## Sachverhalt

- Alle sechs Läufe brachen schon beim Modellbau ab, bevor gefilmt wurde. Grund war der Grak-Bau, den das APK seit 399.2 mitbaut (Commit 13:05):
  1. Ein Skript kam aus einem Commit, den CI nicht geladen hatte.
  2. Die Axt wurde im falschen Ordner gesucht.
- Beide Fehler sind im Protokoll nachgestellt und behoben. Der Lauf als 399.2 (f5ed4ee0f, ohne Film) ist um 14:2x grün: Grak baut jetzt im APK mit.
- Die Filme selbst sind unverändert, wie sie gebaut wurden.

## Auswertung

Stärkstes Gegenargument: 389 sagt „höchstens“. Jede Ausnahme weicht die Regel auf, und der Fehler lag bei uns: Der Grak-Bau ging ungeprüft in den Workflow.
Dafür spricht: Kein Lauf hat einen Film erzeugt, also hat keine Runde am Aussehen stattgefunden.

## Folgerungen

- ja: drei Läufe, je ein Film an dich, Befund des Prüfers danach als Text.
- nein: keine Filme. Zauberbahn und Fledermaus bleiben ohne Vorlage; Grak lege ich nur als Standbild vor, sobald das APK baut.

Antwort: …
