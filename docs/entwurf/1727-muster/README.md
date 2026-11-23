# 1727 · Muster: zwei Vorgänge in der neuen Ordnung

Auftrag Chef 19.11., 20:22: „aus den Altdaten einen Mustervorgang neu … zwei Mustervorgänge … mit ein paar Musteraufträgen … damit ich das Datenmodell mal sehen kann“. Gebaut von Sokrates aus den echten Daten zu 1694 und 1535 (Vorgangsliste, „Zu“-Absätze in `ARBEIT-TEAM-SPIKE.md` und `ARBEIT-TEAM-TOM.md`, Vorgangsarchiv, Probeaufträge `auftraege-19-11.md`), Stand 19.11., 20:25. **Nur Anschauung, nicht in Betrieb.** Ordnung dazu: `1727-gesamtbild.md` 0a.

| Datei | entspricht künftig | Inhalt |
|---|---|---|
| [LISTE-VORGAENGE.md](LISTE-VORGAENGE.md) | `docs/LISTE-VORGAENGE.md` | je Vorgang eine Zeile (Verwaltung) |
| [vorgang/1694.md](vorgang/1694.md) | `docs/vorgang/1694.md` | Vorgang „Griff“ mit vier Aufträgen |
| [vorgang/1535.md](vorgang/1535.md) | `docs/vorgang/1535.md` | Vorgang „Kleidung bei gehobenem Arm“ mit drei Aufträgen |
| [vorgang/9001.md](vorgang/9001.md) | – | fiktiv: „Zwerg steht in der Schänke auf dem Tisch“, nach dem ersten Auftrag |
| [durchlauf-zwerg.md](durchlauf-zwerg.md) | – | 9001 durchgespielt, fünf Lücken |
| [ablauf.md](ablauf.md) | – | Ablauftabelle: Stand, wer, Werkzeug, wer erfährt es, wann weiter, Frist |

So liest man es: Die Zeile in der Liste sagt, wie wichtig und wie weit. Die Vorgangsdatei sagt, was der Chef will und was bisher geschah; darunter stehen die Aufträge, der offene oben. Verknüpft über die Nummer: Auftrag **1694**-4 gehört zu Vorgang **1694**.

Was „(Werkzeug)“ heißt: Diese Felder schreibt keine Sitzung von Hand, sondern `vorgang.py` oder `lauf.py`. Kosten je Auftrag sind hier nicht aufgeteilt, weil die Altdaten nur die Summe je Vorgang kennen.
