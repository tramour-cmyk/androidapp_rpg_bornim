# 158 · Ford-2-Lauf wie Fords Lauf fassen: wann archiviert Ford 2 eine Jerry-Sitzung?

Perikles · 17.10., 18:3x · B Abläufe · von Ford 2 (Chef 17.10., 18:3x: „Vorgang 158 ist wichtig“)

Kurz: Ford 2 archiviert fertige Jerry-Sitzungen wie Ford, mit festem Kriterium „fertig“ (Empfehlung A: Regel einmal in `LISTE-BETRIEB.md`, Ford 2 verweist darauf)

**Lage.** Ford 2 hat am 17.10., 18:2x in `LISTE-BETRIEB.md` „Ford 2“ (Absatz „Pause“) ergänzt: der Lauf archiviert zuerst fertige Jerry-Sitzungen ohne Nachfolger mit Kosten. Ohne Perikles, Diogenes, Chef. Beim Gegenlesen der Texte fand ich fünf Brüche:

1. „fertig“ ist nirgends erklärt. Fords Regel („Erledigte Sitzungen ohne Nachfolger archiviert der nächste Lauf“, Neustart auf Meldung) nennt kein Kriterium.
2. Der Absatz endet weiter mit „sonst schreibt er nichts“, obwohl der Lauf jetzt archiviert, Kosten und Besetzung schreibt.
3. Das Archivieren steht nur unter „Pause“. Ohne Pause sagt die Ford-2-Regel nur „erfasst Kosten wie oben (Neustart)“, also nur auf Meldung einer Sitzung, die nie kommt, wenn sie ohne Nachfolger endet.
4. „Besetzung pflegen“: `ARBEIT-BESETZUNG.md` wird bei jedem Lauf neu aus `list_sessions` geschrieben; im Pausenlauf nicht (siehe 2). Eine beendete Jerry-Sitzung bliebe bis Montag als „laufend“ stehen.
5. Fragen des Chefs: Fords Lehre (81v, 15.10.) und „nichts Neues anfangen“ (16.10.) stehen nur in `ROLLE-BETRIEB.md`, nicht bei Ford 2 (die Klammer „außer Test des Chefs“ in `LISTE-NIEDERLASSUNG.md` steht nur in der einmaligen Startnachricht; schwacher Bruch, Diogenes D24.6). `ARBEIT-BETRIEB.md` sagt außerdem „Lauf ohne Tat nur Kopfzeilen“ und für Ford 2 noch „99h: Uhr aus, nichts schreiben“ (von 147.2 ersetzt); Archivieren braucht `list_sessions`.
6. **Wurzel (Diogenes D24.1, hoch):** Jerrys „Neustart“-Meldung geht laut `LISTE-RELEASE-NEUSTART.md` 1a an Ford, der auf Pro nichts erreicht („Jerry ohne Ford: weiter mit 2“). Ford 2 ist nirgends Empfänger, „Kosten wie oben (Neustart)“ läuft ins Leere. Darum muss der Lauf selbst archivieren; im ersten Entwurf fehlte das.

**Frage:** Soll Ford 2 so archivieren wie Ford, und nach welchem Kriterium?

- **A Eine Regel für beide, mit Kriterium (Entwurf unten).** In `LISTE-BETRIEB.md` „Neustart auf Meldung“ steht einmal, was „fertig“ heißt und was vor dem Archivieren geprüft wird; „Ford 2“ verweist darauf und zählt den Ablauf jedes Laufs auf (mit und ohne Pause). Der Pausen-Satz schrumpft auf den Takt.
- **B Zurück auf den Stand vor 18:2x.** Archiviert wird nur auf Meldung („Neustart Jerry, …“) und von Hand durch den Chef. Pausenläufe bleiben bei Kopfzeilen.
- **C Nur Ford 2s Satz bereinigen** (Widerspruch „schreibt nichts“ streichen, „fertig“ undefiniert lassen).
- **D Noch nicht:** erst nach der Messung 20.–21.10. (99h.4) und der Entscheidung, ob Ford 2 bleibt (22.10.).

**Votum: A.** Ohne Archivieren fehlen Jerrys Kosten je Vorgang (124, Spalte „Kosten“ = „fehlt“), und die Messung „Ford 2 unter 10 % von Jerrys Woche“ (99f) und die Auswertung 99h am 22.10. rechnen mit Lücken. Ein festes Kriterium schützt vor dem Fehler, der 81v erzeugt hat (Sitzung mit Frage des Chefs archiviert). A ersetzt Sätze, es kommt keine neue Regel dazu (90a).

**Entwurf (nach Prüfung Diogenes, Lauf 24; Wortlaut, den ich eintrage, wenn du ja sagst; ersetzt den letzten Satz von „Neustart auf Meldung“ und den Absatz „Pause“):**

> **Fertig** (158): eine Sitzung ist fertig, wenn (1) sie nicht läuft (Schritt 3: weder `working`/`blocked` mit `updated_at` jünger als 60 Minuten noch offener Wecker) und (2) kein Hindernis besteht: keine eigene Datei in `docs/chefsache/entscheiden/` (Frage an den Chef), keine Zeile ihres Vorrats „wartet auf Chef“, keine offene Frage in ihrer letzten Nachricht (`list_events`, `kinds` `assistant`). Ein ausstehender Test des Chefs ist kein Hindernis; sein Ergebnis trägt, wer es hört, in den Vorrat ein. Fertige Sitzungen ohne Neustart-Meldung archiviert der nächste Lauf ebenso: Kosten in die Zeile ihres Vorgangs, Besetzungszeile streichen; Team Jerry vorher „nichts Neues anfangen“ (`ROLLE-BETRIEB.md`). Weder laufend noch fertig (Hindernis): archivieren nicht, und sie zählt als laufender Jerry, Ford 2 startet keinen zweiten.
>
> **Ford 2, jeder Lauf** (mit und ohne Pause): 1. fertige Jerry-Sitzungen archivieren; 2. `ARBEIT-BESETZUNG.md` aus `list_sessions` nur schreiben, wenn sie abweicht; 3. Schwelle, Vorrat, Start (bei Pause nur bei Luft und offener Muss-Zeile, Pause dann streichen); 4. etwas getan → Protokollzeile, sonst nichts schreiben. **Pause** ändert nur den Takt: Uhr alle 4 Stunden, bei 100 % Pro aus bis Fr 03:00 (einmalige Aufgabe „Uhr an“).
>
> **Neustart-Meldung von Jerry** (`LISTE-RELEASE-NEUSTART.md` 1a): „Neustart Jerry, <Commit>“ geht an Ford 2 (Kennung in `ARBEIT-BETRIEB.md`), nicht an Ford.

Folgeänderungen: `ARBEIT-BETRIEB.md` Eintrag Ford 2 („Lauf ohne Tat nur Kopfzeilen“, „nichts schreiben“) auf „Kopfzeilen und `list_sessions`“ ändern; `ROLLE-BETRIEB.md` Lehre „nichts Neues anfangen“ verweist auf die Regel. Kriterium „Übergabe/erledigt“ aus dem ersten Entwurf entfällt (D24.3: es gibt nur eine Übergabe je Rolle, Erledigtes wird gestrichen); der Test an Jerrys Zeile 155 hindert nicht (D24.4), Fragen stehen in der Chefsache statt nur im Verlauf.

**Mehrkosten (Diogenes D24.7):** nicht beziffert. Bis Montag etwa 12 Pausenläufe zu je einem `list_sessions`; bei einer Jerry-Sitzung kommen `list_events` und ein Archivieren dazu. Die Messung 20.–21.10. (99h) liefert die Zahl; Sparhebel, falls zu teuer: `list_events` nur bei einer Jerry-Sitzung ohne Chefsache-Datei. Der Entwurf ändert damit auch Fords Maßstab für „fertig“ (gleiche Regel für Ford und Ford 2), nicht nur Ford 2.

**Ergebnis Prüfung Diogenes (Lauf 24):** Ablauf der Niederlassung klappt noch nicht wie in der Zentrale; A trägt nur mit D24.1–D24.3 (oben eingearbeitet: 1 Empfänger, 2 Wecker, 3/4 Kriterium, 5 Sperre für zweiten Jerry, 6 Texte, 7 Kosten), sonst B. Brüche 1–4 und Datum stimmen, Gegenargument fair dargestellt.

<details><summary>Warum, und das stärkste Gegenargument</summary>

**Warum A:** Die Regel gehört an einen Ort (65.4). Ford 2 kopiert sonst Fords Satz sinngemäß und die zwei Fassungen laufen auseinander; der Fehler „Satz gilt nur in der Pause“ ist genau so entstanden.

**Stärkstes Gegenargument (für B oder D):** Archivieren ist Aufräumen, keine Pflicht. Eine fertige Sitzung kostet im Leerlauf nichts, Besetzung rechnet sich ohnehin neu, und jede neue Prüfung ist ein Fehlerrisiko: ein falsch archivierter Jerry mit Frage des Chefs ist schlimmer als zehn stehengebliebene Sitzungen (81v). Dazu kostet der Pausenlauf jetzt einen `list_sessions`-Aufruf und gelegentlich `list_events` je 4 Stunden, während 99h gerade Läufe verkürzen wollte; Ford 2 steht ab 22.10. zur Entscheidung (99h.4). Was dagegen spricht: die Kosten je Vorgang. Kostenzahl wird nur beim Archivieren gelesen (`usage.cost_usd`); wer später nachträgt, hat sie nicht mehr. Kriterium (3) darf in keinem Fall wegfallen; wem das Risiko trotzdem zu hoch ist, nimmt B.

**Nicht geklärt, Entscheid bei dir:** „nichts Neues anfangen“ gilt in der Lehre nur für Jerry (Weiter-Haken); Ford archiviert Zentrale-Sitzungen ohne diese Nachricht. Entwurf übernimmt das so. Soll es für alle gelten, wäre das eine Änderung an Fords Lauf.

</details>

Berührt: 158, 81 (1a), 147.2, 99f, 99h (.2, .4), 81r, 81v, 124, 128, 98.5 (Besetzung), 65.4, 90a
