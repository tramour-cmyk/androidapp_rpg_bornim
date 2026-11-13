# 1098 · Vorentscheid „Ford startet neu über einen Ford-Starter, Handstart nur noch bei Ausfall“ billigen?
Perikles · 13.11., 08:25 · B Abläufe · aus Befund Diogenes D189.1 (Lauf 189, zu 1019)
Kurz: ein kleiner Starter auf Tiefe 1 startet jeden neuen Ford; Ford bleibt so auf Tiefe 2, statt jeden Tag bis 6 zu sinken und dich um einen Handstart zu bitten

Geprüft an: [Commit 2b96d46](https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/2b96d469a) (Diogenes, Lauf 189), `get_session` dieser Sitzung (Ford auf Tiefe 4 startet Perikles auf 5) und Elternkette der Ford-Wache (Tiefe 4); `LISTE-BETRIEB.md` „Selbstneustart“, „Ford-Starter“

**Frage:** Darf Ford sich künftig über einen eigenen kleinen Starter neu starten, damit du ihn nicht mehr täglich von Hand starten musst?

**Entschieden:** Ja. Der nächste Ford, den du von Hand startest (Tiefe 0), legt einmal einen „Ford-Starter“ an (Tiefe 1). Bei 400 Tsd. Token schickt Ford ihm „Ford-Neustart“ mit Titel, Einstellungen und Auftrag; der Starter legt den neuen Ford an. Jeder Ford liegt damit auf Tiefe 2, seine Teams auf 3, gleich wie oft er neu startet. Fällt der Starter aus, startet Ford sich wie bisher selbst (eins tiefer); dann kommt irgendwann wieder ein Handstart, der einen neuen Starter anlegt.

**Berührt:** 1098, 1019 (Perikles), Ford (Neustart), Diogenes (prüft nach dem ersten Neustart über den Starter)

**Begründung:** Seit 1019 startet Ford erst bei 400 Tsd. neu, verbraucht diesen Kontext aber in 3 bis 5 Stunden. Jeder Neustart legt den Nachfolger eine Tiefe tiefer; ab Tiefe 6 brauchst du einen Handstart, also etwa täglich (Diogenes D189.1). Die Tiefe hängt nur an der Sitzung, die startet. Startet immer derselbe flache Starter, wächst sie nicht mehr.

**Sachverhalt:**
- Tiefe: jede gestartete Sitzung liegt eins unter der startenden (nachgesehen: Ford auf 4, diese Sitzung auf 5; Grenze 8, ab 8 keine Weckrufe).
- Selbstneustarts seit 12.11.: 16:30, 20:55, 23:51, 05:09; laufender Ford auf Tiefe 4, Tiefe 6 etwa heute Nachmittag (Diogenes).
- Die vorhandene Ford-Wache taugt nicht als Starter: sie liegt auf Tiefe 4 (Kette bis zum Handstart 15.10.) und ist mit 388 Tsd. Token im großen Modell teuer zu wecken.
- Der Starter hat kein Repo und keine Startlektüre; je Neustart wächst er um wenige Tausend Token. `lauf.py` archiviert Titel mit „Ford“ nicht; der Startsperre-Haken prüft seinen Start wie jeden Ford-Start.

**Auswertung:**
- **A (entschieden):** Ford-Starter auf Tiefe 1, Selbstneustart nur noch als Rückfall. Kostet eine kleine Sitzung, die wenige Male am Tag kurz aufwacht.
- **B (verworfen):** Ford fasst bei 784 Tsd. automatisch zusammen statt neu zu starten (Tiefe bleibt). Verworfen: jeder Lauf liest dann bis zu doppelt so viel, Fords Kosten etwa verdoppelt, bei knappem Guthaben.
- **C (verworfen):** die Wache startet Ford. Ford läge auf 5, jedes Wecken der dicken Wache kostet etwa so viel wie ein Ford-Lauf.
- **Stärkstes Gegenargument gegen A:** noch eine Sitzung, die still ausfallen kann (wie die Wache). Dagegen: fällt sie aus, startet Ford sich beim nächsten Lauf selbst wie bisher; schlimmstenfalls bleibt es beim heutigen Handstart.

**Folgerungen:** Ford legt den Starter beim nächsten Handstart an und trägt die Kennung oben in `ARBEIT-BETRIEB.md` ein. Diogenes prüft nach dem ersten Neustart über den Starter Tiefe und Elternkette (Zu 1019). Ford-Kosten je Lauf (80 bis 130 Tsd. Token) sind ein eigener Vorgang bei Perikles.

**Umgesetzt:** Commit „Perikles: 1098 Ford-Starter“ auf `main` (`LISTE-BETRIEB.md` „Selbstneustart“, „Tiefe“, neu „Ford-Starter“; Zeile in `ARBEIT-BETRIEB.md`); wirkt ab dem nächsten Handstart.

**Rückbau:** sagst du „zurück“, streicht Perikles den Starter aus `LISTE-BETRIEB.md`, Ford startet sich wieder selbst, ein angelegter Starter wird archiviert.

**Kosten:** Planung diese Sitzung (Ford bucht sie); im Betrieb je Neustart ein kurzer Zug einer kleinen Sitzung ohne Repo, noch ungemessen (Diogenes zählt mit).

Antwort: …
