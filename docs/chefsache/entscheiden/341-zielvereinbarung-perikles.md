# 341 · Zielvereinbarung Perikles bis zum Marktstart
Perikles · 23.10., 09:41 · B Abläufe
Kurz: Zielvereinbarung Perikles: sechs messbare Ziele, geprüft von Werkzeug und Diogenes (Empfehlung: ja)

**Frage** (Chef 09:39): „Wie können wir beide eine Zielvereinbarung treffen, die für dich gegenprüfbar ist und nachhaltig?“ Dazu: Perikles gehört zum Stab und muss selbst Verbesserungen finden und vorschlagen.

**Empfehlung: sechs Ziele, jedes messbar, keines prüfe ich selbst.**

| Nr. | Ziel | Maß | Wer prüft, wie |
|---|---|---|---|
| Z1 | Der Stand zum Marktstart ist aktuell | Der Stand (`LISTE-ABNAHME-KAPITEL1.md`) ist nie älter als 26 Stunden (Mo–Sa); montags ganz neu, mit den Schätzungen von Tom und Jerry | `regelcheck.py` warnt bei jedem Start jeder Sitzung, wenn der Zeitstempel zu alt ist (baue ich bis 26.10.) |
| Z2 | Zu jeder roten Ampel gibt es eine Entscheidungsvorlage | Steht ein Block (a)–(f) auf Rot, liegt binnen 24 Stunden eine Chefsache von Perikles mit „Block (x)“ in der Kurz-Zeile vor: zwei bis drei Wege, Kosten, Empfehlung | `regelcheck.py` warnt bei Rot ohne solche Datei (baue ich bis 26.10.) |
| Z3 | Meine Vorlagen sind fehlerfrei | 0 Fehler je Woche, die du als Erster in einer Vorlage von Perikles findest. Ein Fehler ist, was du „Fehler“ nennst; ich trage ihn sofort mit Uhrzeit in meinen Vorrat ein | Diogenes zählt montags aus dem Verlauf meines Vorrats |
| Z4 | Ich finde selbst Verbesserungen | mindestens 1 eigener Vorschlag je Woche, mit Wirkung, Kosten und Gegenargument, den du mit „ja“ oder „ja, aber“ annimmst | Diogenes zählt neue Chefsache-Dateien von Perikles im Verlauf (`git log`) und dein Wort im Vorgangsarchiv |
| Z5 | Mehr Guthaben fürs Spiel | Anteil Spiel (Tom, Jerry, Homer) an den Kosten der Woche: mindestens 60 % in der Woche ab 26.10., mindestens 70 % ab 02.11. (bisher gesamt 46 %) | Diogenes rechnet montags mit `kosten.py` |
| Z6 | Das Wochenziel wird erreicht | Wochenziel erreicht ja oder nein; Anteil Muss an den Kosten mindestens 70 % (wie bisher „Dein Maß“) | Diogenes zählt montags |

**Wie es hält:**
- Die sechs Ziele ersetzen „Dein Maß“ in `ROLLE-PROJEKT.md`. Jede neue Perikles-Sitzung liest sie beim Start.
- Z1 und Z2 prüft das Werkzeug, nicht mein Gedächtnis (Lehre 81r).
- Diogenes zählt montags und schreibt die Zahlen in seinen Prüfbericht. Ich melde sie dir unverändert, mit Link: „Zielvereinbarung Perikles: x von 6 erfüllt“.
- Verfehle ich ein Ziel zwei Wochen hintereinander, legt Sokrates dir eine Vorlage vor: Rolle ändern, anderes Modell oder Ziel ändern.
- Laufzeit bis zum Marktstart. Am 30.11. bewerten wir sie gemeinsam neu.

**Was dafür wegfällt (Regelbilanz):**
- Die Stichprobe 165 endet vor ihrer Probezeit (30.10.). Diogenes zählt statt der Ablaufabweichungen die Ziele Z3 bis Z6; seine Zeile zu 165 wird ersetzt.
- Der Tagesbericht (247) wird ab 24.10. durch den Stand zum Marktstart ersetzt. Oben auf der Seite steht dann eine Zeile „Heute für dich“ (Entscheiden, Ansehen, Testen). „Geschafft“ und „Heute geplant“ fallen weg, „Was hakt“ steckt in den Risiken.
- Neu sind dafür nur zwei Prüfungen im Werkzeug (Sekunden) und eine Montagszeile.

**Stärkstes Gegenargument:** Mehr Kennzahlen heißen mehr Ablauf, und das ist mein typischer Fehler. Außerdem gilt bis zum Meilenstein der Regelstopp (167.3). Darum steht die Vereinbarung nur gegen das, was wegfällt. Z5 hängt zudem vor allem an der Arbeit von Tom und Jerry. Ich kann es aber über den Betrieb steuern, denn dessen Anteil senke ich.

**Berührt:** 338.1 (Stand), 338.2 (fremde Prüfung), 340 (Rollenspiegel von Sokrates: Fragen an alle, darunter nach Verbesserungen wie Z4; 341 sind messbare Ziele nur für Perikles; beides passt zusammen), 165, 247, 167.3; Diogenes, Ford.

**Stellungnahme Sokrates** (23.10., 09:52; Chef 09:49: „können wir das auch für alle anderen nehmen?“):
- *Verhältnis zu 340:* 340 ist die Diagnose. Die Rollen sagen jede Woche, wo sie stehen, und je Rolle entsteht höchstens eine Änderung. 341 ist die Zielvereinbarung: feste Ziele, die ein anderer misst, mit Eskalation. 340 fehlt genau das; 341 fehlt der Blick der Rolle auf sich selbst. Beides zusammen ergibt einen Kreislauf.
- *Für alle Rollen:* Ja, das Gerüst. Je Rolle höchstens drei Ziele unter „Dein Maß“ der Rollendatei. Davon gelten zwei für alle, Z3 (0 Erstfunde des Chefs) und Z4 (ein angenommener Verbesserungsvorschlag je Woche); dazu ein eigenes Ziel je Rolle. Gemessen wird immer von außen (Werkzeug oder Diogenes), nie von der Rolle selbst. Eskalation wie bei 341. Heute haben Sokrates und Ford gar keine Kennzahl (Rollenspiegel, Frage 3).
- *Reihenfolge:* Perikles zuerst, als Probe zwei Wochen. Wenn bis 06.11. drei von sechs Zielen messbar laufen, für alle Rollen übernehmen.
- *Stärkstes Gegenargument:* Diogenes müsste je Rolle zählen; Zählen kostet und ersetzt kein gutes Arbeiten. Darum nur drei Ziele je Rolle, und mindestens eines prüft ein Werkzeug.
- *Mangel heute:* Hart erzwungen sind nur Z1 und Z2 über `regelcheck.py`, und gebaut ist davon noch nichts. Bis 26.10. ist also alles nur Papier.

**Was du sagen sollst:** „341 ja“ (dann gelten auch: 165 endet, 247 wird ersetzt), „341 ja, für alle nach der Probe“, „341 ja, aber …“ (z. B. andere Zahlen) oder „nein“.
