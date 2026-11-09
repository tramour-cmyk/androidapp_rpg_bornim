# 341.1 · Sollen Tom und Jerry sich daran messen, dass jede Woche mindestens ein Punkt deiner Abnahmeliste fertig wird?
Sokrates · 09.11., 20:41 (Vorlage 18:22, neu geschrieben 20:41) · B Abläufe · 341
Kurz: Woran sich jede Rolle ab dieser Woche messen lässt; neu für die Teams: ein Punkt der Abnahmeliste je Woche

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/5cf0b3243

**Frage:** Seit dem 23.10. soll jede Rolle höchstens drei Ziele haben, an denen sie sich messen lässt. Zwei sind für alle gleich, das dritte ist eigen. Die eigenen Ziele habe ich heute festgelegt und schon eingebaut (das darf ich bei Abläufen vorab, du kannst es zurücknehmen). Neu ist eigentlich nur das Ziel der Teams. Bist du damit einverstanden?

**Votum:** „gebilligt“.

**Berührt:** 341 (Zielvereinbarung), 620 (Stärken und Schwächen), 338.1 (Wochenziel)

**Begründung:** Du hast am 09.11., 08:50 gefragt: „0 von 41 … Warum schaffen wir da nicht mal einen einzigen Punkt?“ Bisher hat sich kein Team daran gemessen, ob etwas von der Abnahmeliste fertig wird. Mit diesem Ziel muss jedes Team jede Woche etwas Fertiges bei dir zur Abnahme vorlegen.

**Sachverhalt:** So sieht es jetzt aus. Diogenes zählt montags, Perikles meldet dir eine Zeile je Rolle.

| Rolle | Ziel 1, alle | Ziel 2, alle | Ziel 3, eigen |
|---|---|---|---|
| Tom, Jerry | kein Fehler, den du als Erster findest | jede Woche ein Vorschlag, den du annimmst | **neu:** jede Woche mindestens ein Punkt oder Teilpunkt der Abnahmeliste aus ihrem Bereich, vom Prüfer abgehakt |
| Ford | wie oben | wie oben | keine Stunde, in der Arbeit da ist und durch seinen Fehler keiner arbeitet |
| Homer | wie oben | wie oben | kein Team wartet länger als einen Tag auf einen Text |
| Diogenes | wie oben | wie oben | möglichst wenige seiner Befunde werden als falsch verworfen |
| Sokrates | wie oben | wie oben | möglichst viele meiner Empfehlungen gelten nach einer Woche noch |
| Perikles | behält seine sechs Ziele aus der bestandenen Probe | | |

Wer zwei Wochen hintereinander dasselbe Ziel verfehlt, über den lege ich dir eine Vorlage vor (Aufgabe, Modell oder Ziel ändern). Stand der Abnahmeliste heute: 0 von 41 Punkten ganz fertig; Teilpunkte: Gegner 6 von 19, Orte 3 von 8, Stationen 3 von 8. Drei Punkte (1.1, 1.3, 1.4) sind seit Build 204 gebaut, aber nie bei dir zur Abnahme gewesen.

**Auswertung:** Stärkstes Gegenargument: Ein Team könnte etwas vorlegen, das nur „gut genug“ ist, um das Wochenziel zu schaffen. Antwort: Abhaken darf nur der Prüfer des Punktes, oft du selbst; das Ziel zwingt nur, Fertiges vorzulegen, statt es liegen zu lassen. Verworfen: die Zahl der Funde, die du schon einmal gemeldet hast, als drittes Ziel der Teams; das deckt Ziel 1 schon ab.

**Folgerungen:** Bei „gebilligt“ gilt alles ab der Woche 09.–15.11., die erste Zählung ist Montag, 16.11. Bei „zurück“ messen sich die Teams wieder nur an Fehlern; ich baue das zurück, das ist eine Zeile in `ROLLE-ENTWICKLUNG.md`.
**Umgesetzt:** Commit 5cf0b3243 (Ziele in `LISTE-PRUEFUNG.md` und in jeder Rollendatei).
**Kosten:** keine laufenden; Diogenes zählt montags drei Zahlen je Rolle.

Antwort: „gebilligt“ oder „zurück“.
