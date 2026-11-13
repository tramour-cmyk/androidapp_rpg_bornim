# 1189 · Soll Diogenes die Vorgangsliste alle 48 Stunden auf Leichen prüfen, mit Kostengrenze?
Sokrates · 13.11., 17:06 · B Abläufe · aus deinem Wort 16:48 zu 1186 (neu gefasst nach dem Werkzeug von Perikles 16:5x)
Kurz: Leichenprüfung alle 48 h durch Diogenes (Prüfer) anhand der neuen Werkzeugtreffer, höchstens 10 $ je Lauf, nach zwei Wochen Rückstufung, wenn kaum noch Funde.
Beim Chef, weil: Geld (laufend, je Lauf bis etwa 10 $) und Rollen (neue feste Pflicht für Diogenes)

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/24b01a1d5 (Werkzeug `startbar.py --leichen`, Perikles); Funde 1186 im Vorrat Sokrates (Liste 13.11., 16:45, 370 offen)

**Frage:** Heute fandest du zum dritten Mal einen Mangel im System erst durch Nachfragen: 12:53 die blinden Flecken (1129), 15:18 Verlorenes im Archiv, 16:28 die Leichen in der Vorgangsliste (1186); um 17:03 dazu 756.1, das in der Übersicht noch als Muss stand. Du fragst, ob Perikles oder Diogenes die Liste spätestens alle 48 Stunden auf Erledigtes, Überholtes und Hängendes prüfen soll. Soll das so eingeführt werden, und von wem?

**Votum:** „1189 A“: Diogenes prüft alle 48 Stunden, höchstens 10 $ je Lauf; die Besitzer schließen.

**Berührt:** Diogenes (`ROLLE-PRUEFUNG.md`, neue Pflicht), Ford (Start alle 48 h über `lauf.py`), Perikles (Werkzeug `startbar.py --leichen`, gebaut), alle Besitzer (schließen).

**Begründung:** Chef 16:48: „Müsste sowas Perikles oder Diogenes nicht alle 48 Stunden spätestens prüfen? Auf Leichen, auf Erledigtes und das irgendwie nachhalten, weil die ganzen Helfer, die wir haben, alle Tools, die wir haben, nutzen ja anscheinend nichts.“ Unsere Werkzeuge prüften bisher die Form der Liste, keines, ob eine Zeile noch stimmt. Diogenes prüft den Code auf `main`, die Buchführung prüfte niemand.

**Sachverhalt:**
- 1186: unter 700 waren 45 von 164 offenen Vorgängen erledigt oder überholt, ab 700 waren 33 von 202 auffällig (zusammen 78 von 366).
- Ursachen: Urteil im Chat oder Archiv, Zeile nie nachgezogen (348.1, 461.1, 453); Arbeit unter anderer Nummer erledigt, die alte offen (302.3, 70, 134, 802); Richtungswechsel ohne Durchsicht (257, 267, 304, 839); „greift“ von Diogenes schließt nur Betrieb (866, 896); was nur der Bauserver prüft, bleibt „zu testen“ (1079, 1122, 1058, 1062); der Wiederholungswächter legt Zeilen für Fehlalarme an (850, 869, 985).
- 17:03 dazu: die Übersicht „Offen je Rolle“ in der Chefsache ist seit 14:19 eingefroren, weil ihr stündlicher Zeitplan nie lief (0 Läufe); 756.1 war seit 16:59 erledigt, stand dort aber noch. Von Hand neu angestoßen 17:05; Ursache bei Tom (1191).
- Seit 16:5x (Perikles): `startbar.py --leichen [Tage]` meldet je Besitzer gebaute oder zu testende Zeilen mit schon getestetem Build, offene Mütter mit erledigten Unternummern und jede Zeile ohne Bewegung seit n Tagen; montags legt `lauf.py` je Besitzer „Urteil alte Zeilen“ an (14 Tage, ab 16.11.). Nicht gebaut: Urteil im Archiv zu offener Zeile (Perikles: frische Entscheidungen hätten fast immer beides; nach 14 Tagen fängt es die Liegezeit).
- Diogenes ist Prüfer, „ändert nichts“ und wird nur von dir oder Ford gestartet; er zählt montags (Wochenzählung).

**Auswertung:**
- **A (Empfehlung): Diogenes, alle 48 h, auf den Werkzeugtreffern.** Diogenes liest alle 48 h die Treffer von `startbar.py --leichen 7` gegen Archiv und Code und zusätzlich jedes Urteil des Chefs der letzten 48 h gegen die Zeile (die Lücke, die das Werkzeug offen lässt, genau der Fall 756.1); die Funde gehen als Vorgang an die Besitzer, die schließen. Grenze 10 $ je Lauf. Nach zwei Wochen: findet er je Lauf höchstens drei Leichen, nur noch montags. Kosten: geschätzt 10 bis 25 $ je Woche (das Werkzeug liest vor, er liest nur Treffer); die echte Zahl je Lauf trage ich nach dem ersten Lauf nach.
- **B: Perikles statt Diogenes.** Kein neuer Start nötig, er führt die Liste und hat das Werkzeug gebaut. Dagegen: er legt die meisten Zeilen an und setzt den Vorrang, prüfte also seine eigene Buchführung.
- **C: nur das Werkzeug, Urteil montags durch die Besitzer.** Am billigsten, ab 16.11. schon gebaut. Dagegen: 14 Tage Liegezeit, bis eine Leiche auffällt; die Besitzer übersahen ihre eigenen Zeilen bisher, und Urteile wie 756.1 fängt es nicht.
- **Stärkstes Gegenargument gegen A:** Das Werkzeug macht den größten Teil schon; Diogenes kostet, um wenig zu finden. Antwort: genau das misst die Rückstufung nach zwei Wochen; findet er dann wenig, bleibt C.

**Folgerungen:** Bei A: Perikles nimmt die Prüfung in `ROLLE-PRUEFUNG.md` und den Start alle 48 h in `ROLLE-BETRIEB.md` auf (1189.1); erster Lauf nach dem Abschluss von 1186 (16.11.); ich prüfe am 27.11. Funde je Lauf und Kosten und schlage die Rückstufung vor oder nicht. Bei C: nichts weiter, `lauf.py` legt ab 16.11. die Montagszeilen an.

Antwort: …
