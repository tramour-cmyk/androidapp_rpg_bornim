# 620.1 · Wiederholte Funde zuerst, Grenze angefangener Arbeit je Team · Perikles · 07.11., 20:4x

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/main/docs/ARBEIT-TAGESBERICHT.md

**Frage (Chef 07.11., 14:3x zu 620: „Jetzt muss man es nur noch nachhalten und schauen, wie wir es umsetzen“):** Gelten ab sofort die zwei Regeln A und B?

- **A Wiederholte Funde zuerst:** Meldest du einen Fund zum zweiten Mal, bekommt seine Zeile im Vorrat das Wort „wiederholt“. Diese Zeilen startet Ford vor jedem anderen Muss; nur dein „jetzt“ geht noch davor.
- **B Grenze angefangener Arbeit:** Je Team höchstens 6 Muss-Vorgänge „gebaut“, die noch auf deinen Test warten. Bei 6 bittet das Team um den gemeinsamen Build und nimmt bis zu deinem Test nur Wiederholtes und „jetzt“.

**Votum Perikles:** A und B ja.

**Berührt:** 620, 317 (gemeinsamer Build, `LISTE-BAUEN-TESTEN.md`), `tools/startbar.py`, `tools/lauf.py`, `ROLLE-ENTWICKLUNG.md`, 536 (fünfmal gemeldet).

## Begründung

Wiederholte Funde kosten dich am meisten: im Build 268 waren 6 Funde schon einmal gemeldet (Lagebild Sokrates zu 620); das Erklärfenster im Kampf (536) hast du fünfmal gemeldet. Gleichzeitig warten laut Werkzeug 35 gebaute Änderungen auf deinen Test (Tom 21, Jerry 14; ein Teil davon sind überholte Stände). Je mehr angefangen und nicht getestet ist, desto später erfährt ein Team, dass ein Fund nicht behoben ist.

## Sachverhalt

- Heute gilt: Rückläufer aus deinen Tests sind Muss, aber gleichrangig mit allem anderen Muss; ob ein Fund zum ersten oder zum fünften Mal kommt, sieht kein Werkzeug.
- 317 lässt einen Build mit 4–6 Punkten beider Teams zu, unter 4 nur, wenn der älteste 2 Tage wartet; eine Obergrenze für angefangene Arbeit gibt es nicht.

## Auswertung

**Stärkstes Gegenargument:** Neue Funde warten länger, und B kann ein Team anhalten, wenn du ein paar Tage nicht testest. **Entkräftet:** jeder Fund bekommt sofort seine Nummer, gebaut wird der Reihe nach; ein Team bei 6 bittet um den Build, statt weiter zu stapeln, und hat mit Wiederholtem, „jetzt“ und Übernahmen vom anderen Team weiter Arbeit. Bleibt dein Test aus, wäre ein siebter ungetesteter Punkt ohnehin Arbeit auf Vorrat.

**Regelbilanz:** B ersetzt in 317 den Satz „unter 4 nur, wenn der älteste 2 Tage wartet (dann mindestens 3)“; A ersetzt nichts, ordnet nur innerhalb von Muss.

## Folgerungen

Bei „620.1 A B“: `startbar.py` und `lauf.py` ordnen „wiederholt“ vor Muss und sperren neues Muss ab 6 Wartenden je Team; Text in `ROLLE-ENTWICKLUNG.md` und `LISTE-BAUEN-TESTEN.md` (Perikles, etwa eine Sitzung); Sokrates setzt „wiederholt“ beim Eintragen deiner Funde; Diogenes zählt die Wiederholquote je Build montags.

**Zu sagen:** „620.1 A B“, nur A oder B, oder „nein“.
