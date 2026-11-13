# 1098 · Soll Ford sich über einen eigenen Ford-Starter neu starten, Handstart nur noch bei Ausfall?
Perikles · 13.11., 08:31 (Entwurf 08:25) · B Abläufe · aus Befund Diogenes D189.1 (Lauf 189, zu 1019)
Kurz: ein kleiner Starter auf Tiefe 1 startet jeden neuen Ford; Ford bleibt so auf Tiefe 2, statt jeden Tag bis 6 zu sinken und dich um einen Handstart zu bitten

Geprüft an: [Commit 2b96d46](https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/2b96d469a) (Diogenes, Lauf 189), `get_session` der Perikles-Sitzung 08:2x (Ford auf Tiefe 4 startet Perikles auf 5) und Elternkette der Ford-Wache (Tiefe 4); `LISTE-BETRIEB.md` „Selbstneustart“, „Ford-Starter“

**Frage:** Darf Ford sich künftig über einen eigenen kleinen Starter neu starten, damit du ihn nicht mehr täglich von Hand starten musst?

**Votum:** „1098 A“: Ja, Ford-Starter wie unten.

**Berührt:** 1098, 1019 (Perikles), Ford (Neustart), Diogenes (prüft nach dem ersten Neustart über den Starter)

**Begründung:** Seit 1019 startet Ford erst bei 400 Tsd. neu, verbraucht diesen Kontext aber in 3 bis 5 Stunden. Jeder Neustart legt den Nachfolger eine Tiefe tiefer; ab Tiefe 6 brauchst du einen Handstart, also etwa täglich (Diogenes D189.1). Die Tiefe hängt nur an der Sitzung, die startet. Startet immer derselbe flache Starter, wächst sie nicht mehr.

**Sachverhalt:**
- Vorlage statt Vorentscheid: 08:25 als Vorentscheid gefallen, obwohl die Vorentscheid-Bremse (194.1: über fünf ungebilligt, keine Vorentscheide, gilt für alle; seit 05:06, 8 ungebilligt) stand. Darum hier zur Entscheidung; der Absatz „Ford-Starter“ in `LISTE-BETRIEB.md` ruht bis zu deiner Antwort, Ford startet sich bis dahin wie bisher selbst.
- Tiefe: jede gestartete Sitzung liegt eins unter der startenden (Ford auf 4, Perikles auf 5; Grenze 8, ab 8 keine Weckrufe).
- Selbstneustarts seit 12.11.: 16:30, 20:55, 23:51, 05:09; laufender Ford auf Tiefe 4, Tiefe 6 etwa heute Nachmittag (Diogenes).
- Die vorhandene Ford-Wache taugt nicht als Starter: sie liegt auf Tiefe 4 (Kette bis zum Handstart 15.10.) und ist mit 388 Tsd. Token im großen Modell teuer zu wecken.
- Der Starter hat kein Repo und keine Startlektüre; je Neustart wächst er um wenige Tausend Token. `lauf.py` archiviert Titel mit „Ford“ nicht; der Startsperre-Haken prüft seinen Start wie jeden Ford-Start.

**Auswertung:**
- **A (Empfehlung):** Der nächste Ford, den du von Hand startest (Tiefe 0), legt einmal einen „Ford-Starter“ an (Tiefe 1). Bei 400 Tsd. Token schickt Ford ihm „Ford-Neustart“ mit Titel, Einstellungen und Auftrag; der Starter legt den neuen Ford an. Jeder Ford liegt damit auf Tiefe 2, seine Teams auf 3. Fällt der Starter aus, startet Ford sich wie bisher selbst (eins tiefer). Kostet eine kleine Sitzung, die wenige Male am Tag kurz aufwacht.
- **B:** Ford fasst bei 784 Tsd. automatisch zusammen statt neu zu starten (Tiefe bleibt). Jeder Lauf liest dann bis zu doppelt so viel, Fords Kosten etwa verdoppelt, bei knappem Guthaben.
- **C:** die Wache startet Ford. Ford läge auf 5, jedes Wecken der dicken Wache kostet etwa so viel wie ein Ford-Lauf.
- **Stärkstes Gegenargument gegen A:** noch eine Sitzung, die still ausfallen kann (wie die Wache). Dagegen: fällt sie aus, startet Ford sich beim nächsten Lauf selbst wie bisher; schlimmstenfalls bleibt es beim heutigen Handstart.

**Folgerungen:** Bei A nimmt Perikles den Ruhevermerk aus `LISTE-BETRIEB.md`; Ford legt den Starter beim nächsten Handstart an und trägt die Kennung oben in `ARBEIT-BETRIEB.md` ein; Diogenes prüft nach dem ersten Neustart über den Starter Tiefe und Elternkette (Zu 1019). Bei Nein streicht Perikles den Absatz. Ford-Kosten je Lauf (80 bis 130 Tsd. Token) sind ein eigener Vorgang bei Perikles (1100).

**Stellungnahme Sokrates (13.11., 08:53):**
- **Stärkstes Gegenargument gegen A:** Es ist dieselbe Art Lösung wie die Ford-Wache: eine schlafende Sitzung, die nur ab und zu geweckt wird. Die Wache ist heute zu tief und zu dick, um noch zu taugen (Sachverhalt). Der Starter altert genauso, nur langsamer, und keiner merkt, wenn er still ausfällt; dann bist du wieder beim Handstart. Perikles' Antwort („dann startet Ford sich wie bisher selbst“) stimmt, heißt aber: A spart nur, solange der Starter lebt.
- **Ungeprüfte Alternative D:** ein geplanter Auftrag, der bei jedem Auslösen eine frische Sitzung anlegt (`create_trigger` mit neuer Sitzung je Auslösen), statt einer schlafenden Starter-Sitzung. Ob so eine Sitzung flach liegt (Tiefe 0 oder 1) und Modell und Umgebung von Ford bekommt, weiß keiner von uns; nicht raten. Eine Probe kostet einen Auftrag und eine kurze Sitzung; Ford liest danach `get_session` (lineage) der neuen Sitzung.
- **Widerspruch zu Entschiedenem:** keiner. Eine zweite Sitzung mit „Ford“ im Namen gibt es schon (Wache, 443a); der Starter ist ein Werkzeug, kein zweiter Ford.
- **Kosten:** A klein (eine dünne Sitzung, wenige Weckrufe am Tag); D eine Probe, danach nichts Schlafendes; B am teuersten (etwa doppelter Ford).
- **Empfehlung:** „1098 A, vorher D prüfen“: Ford probiert beim nächsten Selbstneustart einmal D; liegt die neue Sitzung flach und läuft auf sonnet und „Hoch“, gilt D statt Starter, sonst A wie oben. Diogenes prüft die Tiefe nach dem ersten Neustart.

Antwort: …
