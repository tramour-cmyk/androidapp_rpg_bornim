# 340.6 · Rollenspiegel 13.11.: welche Änderungen je Rolle nimmst du an, und brauchst du jetzt eine neue Runde?
Sokrates · 15.11., 18:26 · B Abläufe · aus deinem Wort 18:24
Kurz: Alle sieben Rollen haben am Freitag 13.11. geantwortet; meine Auswertung fehlte. Drei Muster, vier Änderungen zur Wahl.
Beim Chef, weil: Rollen und Accounts

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/99032c7f5 (main; `LISTE-ROLLENSPIEGEL.md` Woche 13.11., Antworten 13.11., 00:10–08:51; Commits seit 13.11., 08:00: Perikles 208, Diogenes 96)

**Frage:** Du hast geschrieben (18:24): „Der Rollenspiegel vom Freitag ist, glaube ich, mal wieder entfallen. Insofern wäre es schön, wenn alle mal in sich gehen und jetzt was aufliefern würden.“ Entfallen sind nicht die Antworten, sondern meine Auswertung: drei Muster und Vorschläge an dich (`LISTE-ROLLENSPIEGEL.md`, Kopf). Darum hat keiner seine Schritte begonnen; sie warten auf dein Ja. Welche Änderungen sollen gelten, und willst du zusätzlich sofort eine neue Runde aller sieben?

**Votum:** „340.6 A“: V1 bis V4 annehmen, keine Sonderrunde; nächste Runde regulär Freitag 20.11., dann mit Ist gegen die erwarteten Zahlen.

**Berührt:** alle Rollen; Perikles (Werkzeuge), Diogenes (Zählung), Tom und Jerry (Tests vor dem Push), Homer und ich (Vorlagen), Ford.

**Begründung:** Die Antworten sind zwei Tage alt und ehrlich; die Muster darin sind dieselben, die heute noch zu sehen sind (Tom vergaß heute die Prüfliste t288 zu löschen; Vorräte Tom 35 KB, Jerry 34 KB). Eine neue Runde brächte dieselben Antworten; was fehlt, ist die Entscheidung.

**Sachverhalt:**
- **Muster 1, Abläufe statt Spiel:** Diogenes etwa 95 % Abläufe, Perikles etwa 70 % Werkzeuge (rund 460 Commits in der Woche), Ford 100 % Betrieb mit teuren Neustarts in der Nacht. Seit Freitag weiter: Perikles 208, Diogenes 96 Commits in 2½ Tagen. Beide nennen es selbst ihren typischen Fehler.
- **Muster 2, nicht am Ergebnis geprüft:** Jerry drei Filmläufe ohne Film (1043, Fehler in der eigenen Testschleife), Tom ein roter Lauf mit veralteten Tests, Perikles 981 (Werkzeug gab Hoch aus, die App zeigte Mittel), Diogenes prüft Werkzeuge an Kopien statt im echten Lauf, ich meldete t280 „bekannt“, ohne nachzusehen.
- **Muster 3, Vorlagen in mehreren Runden:** ich zehn Fehler 341 in zwei Tagen (gegen Beschlossenes nicht geprüft), seither vier weitere (13.11., 20:22, 21:44, 23:20; 15.11., 12:18); Homer 842 zweimal zurück; Tom 492 und 505 über 170 $ festgefahren.
- Dazu bei allen: Vorratsgrenzen gesehen, nicht gemeldet, „weil der Haken es jedem zeigt“.

**Auswertung:**
- **A (Empfehlung):** vier Änderungen, je eine erwartete Zahl, Prüfdatum Mo 23.11. (zählt Diogenes):
  - **V1, Perikles und Diogenes:** Werkzeugvorgang ohne Fund des Chefs ist Kür, außer er hält ein Team auf; die Doppelprüfung durch Diogenes nur für Regeln, die mehrere Rollen binden. Erwartet: höchstens 100 Commits „Perikles:“ an Werkzeugen je Woche, bei Diogenes mindestens ein Drittel Prüfung im Spiel (Build, Prüfliste).
  - **V2, Tom und Jerry:** vor jedem Push, der baut, und jedem Filmlauf die betroffenen Tests am Rechner bis zum Ende; Filmtests begrenzt nach Bildern, nie nach Uhrzeit, mit Abbruch, wenn der Prüfgegenstand nicht vorkam. Erwartet: 0 rote Läufe und 0 Filmläufe ohne Film durch eigene Testfehler.
  - **V3, Sokrates und Homer:** jede Vorlage vor dem Lauf gegen das gebilligte Muster und das Archiv der Nummer, als drei Prüfpunkte an das Team; bei Homer jede Wahl im Gespräch gegen den Knopf im Code. Erwartet: höchstens 2 Fehler 341 je Woche, keine Vorlage über zwei Runden.
  - **V4, Ford:** Lob; seine drei kleinen Schritte (Spiegelzeilen vom Fremdstart ausnehmen, feste Zeile für Betriebskosten, 60-Sekunden-Prüfung vor dem Archivieren im Werkzeug) gehen an Perikles als Kür.
  - Für jede neue Regel fällt eine alte: V1 ersetzt „Doppelpack für jede Ablaufänderung“, V2 die Testzeile aus Jerrys Vorrat, V3 meine Lehre 13.11. als Regel statt Satz.
- **B:** A und zusätzlich jetzt eine Runde aller sieben. Kosten etwa sechs Starts (5 bis 7 $ je Start), Inhalt seit Freitag fast gleich.
- **C:** nur neue Runde, keine Änderungen. Dann wartet alles bis zur nächsten Auswertung, die Muster laufen weiter.
- **Stärkstes Gegenargument gegen A:** die Zahlen kommen von den Rollen selbst; ohne frische Runde fehlt dir, was sich seit Freitag geändert hat. Antwort: das zählt Diogenes am 23.11. gegen die Zahlen, nicht die Rolle selbst.

**Folgerungen:** Nach „340.6 A“ trage ich V1 bis V4 als Vorgänge bei den Besitzern ein (Zeile in `LISTE-ROLLENSPIEGEL.md` „Änderungen“) und setze Freitag 20.11. als Prüfung der Runde; bei B startet Ford die sieben heute Abend mit `tools/rollenspiegel.sh`.

Antwort: …
