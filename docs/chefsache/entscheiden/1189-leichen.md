# 1189 · Soll Diogenes die Vorgangsliste alle 48 Stunden auf Leichen prüfen, mit Kostengrenze?
Sokrates · 13.11., 16:50 · B Abläufe · aus deinem Wort 16:48 zu 1186
Kurz: Leichenprüfung alle 48 h durch Diogenes (Prüfer), Werkzeug-Hinweise vorweg, höchstens 10 $ je Lauf, nach zwei Wochen Rückstufung, wenn kaum noch Funde.
Beim Chef, weil: Geld (laufend, je Lauf bis etwa 10 $) und Rollen (neue feste Pflicht für Diogenes)

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/e33078f76 (Liste 13.11., 16:45, 370 offen; Funde 1186; `tools/*.py` nach „Leiche“ durchsucht)

**Frage:** Heute fandest du zum dritten Mal einen Mangel im System erst durch Nachfragen: 12:53 die blinden Flecken (1129), 15:18 Verlorenes im Archiv, 16:28 die Leichen in der Vorgangsliste (1186). Du fragst, ob Perikles oder Diogenes die Liste spätestens alle 48 Stunden auf Erledigtes, Überholtes und Hängendes prüfen soll. Soll das so eingeführt werden, und von wem?

**Votum:** „1189 A“: Diogenes prüft alle 48 Stunden, höchstens 10 $ je Lauf; die Besitzer schließen.

**Berührt:** Diogenes (`ROLLE-PRUEFUNG.md`, neue Pflicht), Ford (Start alle 48 h über `lauf.py`), Perikles 1188 (Werkzeug-Hinweise), Tom (Bau der Hinweise in `startbar.py`), alle Besitzer (schließen).

**Begründung:** Chef 16:48: „Müsste sowas Perikles oder Diogenes nicht alle 48 Stunden spätestens prüfen? Auf Leichen, auf Erledigtes und das irgendwie nachhalten, weil die ganzen Helfer, die wir haben, alle Tools, die wir haben, nutzen ja anscheinend nichts.“ Unsere Werkzeuge prüfen die Form der Liste (Größe, Zeilenlänge, Rest ohne Folgevorgang), keines prüft, ob eine Zeile noch stimmt. Diogenes prüft den Code auf `main`, die Buchführung prüft niemand. Diese Lücke schließt die Prüfung.

**Sachverhalt:**
- 1186: von 164 offenen Vorgängen unter 700 waren 45 erledigt oder überholt (27 %), 17 unklar. Die 202 ab 700 prüfen seit 16:46 drei Helfer.
- Ursachen der Leichen (Zu 1188 bei Perikles): Urteil im Chat oder Archiv, Zeile nie nachgezogen (348.1, 461.1, 453); Arbeit unter anderer Nummer erledigt, die alte bleibt offen (302.3, 70, 134); Richtungswechsel Kotlin → Godot und alte Regeln → Bornimer Rollenspielsystem ohne Durchsicht (257, 267, 304, 49, 50). Auch Muss-Vorgänge ruhten so (376.1, 513).
- Werkzeuge: `startbar.py` meldet als Leiche nur „wartet auf Chef“ ohne Datei; `regelcheck.py` zählt Größen und Formen; `vorgang.py` sperrt seit 1143 das Schließen mit Rest ohne Folgevorgang. Nichts vergleicht Zeile, Archiv und Code.
- Diogenes ist Prüfer, „ändert nichts“ und wird nur von dir oder Ford gestartet; er zählt montags (Wochenzählung).

**Auswertung:**
- **A (Empfehlung): Diogenes, alle 48 h, mit Werkzeug vorweg.** Ein Skript (1188, gebaut von Tom) meldet bei jedem Lauf von `startbar.py` die mechanischen Fälle: Urteil im Archiv zu offener Zeile, alle Unternummern erledigt bei offener Mutter, „zu testen“/„gebaut“ mit längst getestetem Build, alte Wörter nach einem Richtungswechsel (Kotlin, alte Regeln). Diogenes liest alle 48 h nur diese Treffer und die Zeilen ohne Bewegung seit 7 Tagen gegen Archiv und Code; die Funde gehen als Vorgang an die Besitzer, die schließen. Grenze 10 $ je Lauf. Nach zwei Wochen: findet er je Lauf höchstens drei Leichen, nur noch montags in der Wochenzählung. Kosten: geschätzt 15 bis 35 $ je Woche in den ersten zwei Wochen; die echte Zahl je Lauf messe ich am laufenden Durchgang ab 700.
- **B: Perikles statt Diogenes.** Kein neuer Start nötig, er führt die Liste ohnehin. Dagegen: er legt die meisten Zeilen an und setzt den Vorrang, prüfte also seine eigene Buchführung; derselbe blinde Fleck.
- **C: Diogenes liest jedes Mal die ganze Liste.** Am gründlichsten, aber etwa dreimal so teuer wie A, und die meisten Zeilen sind frisch und unverdächtig.
- **D: nur montags in der Wochenzählung.** Am billigsten; aber zwischen zwei Zählungen wachsen wieder fünf Tage Leichen, und du findest sie zuerst.
- **Stärkstes Gegenargument gegen A:** Wieder eine Runde, die nur das Symptom behandelt; wenn die Werkzeug-Hinweise wirken, findet Diogenes nichts und kostet trotzdem. Antwort: genau das misst die Rückstufung nach zwei Wochen; findet er dann noch viel, wirken die Hinweise nicht, und das kommt als Befund zu dir.

**Folgerungen:** Bei A: Perikles nimmt die Prüfung in `ROLLE-PRUEFUNG.md` und den Start in `ROLLE-BETRIEB.md` auf (1189.1); Tom baut die Hinweise aus 1188 (über Perikles); erster Lauf nach dem Abschluss von 1186 (16.11.); ich prüfe nach zwei Wochen (27.11.) die Funde je Lauf und die Kosten und schlage dann die Rückstufung vor oder nicht.

Antwort: …
