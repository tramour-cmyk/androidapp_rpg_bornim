# 471 · Soll Spike jetzt „Fertigkeiten steigen durch Tun“ (BRS 1.2) fertig machen, mit Testbitte zusammen mit 762?
Sokrates · 09.11., 20:49 · E Kampf · aus deiner Frage 20:47
Kurz: Spike holt 471 vom Nebenzweig, schreibt Übung am Kampfende gut, zeigt es in 762

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/20505f1a2

**Frage:** Soll Spike (Zusatzentwickler Team Tom) 471 jetzt fertig machen, obwohl 471 seit 03.11. „Kampf zuerst“ ruht?

**Votum:** „471 A“: Spike übernimmt 471, eng gefasst wie unten.

**Berührt:** 471 (Tom), 762 (Tom, Heldenreiter Fertigkeiten), Planpunkt 1.2, Kampfteil mit Jerry erst nach t272.

**Begründung:** 762 zeigt die Fertigkeiten, aber sie steigen nicht, weil die Regeln nie auf `main` kamen. Damit kann 1.2 keinen Haken bekommen (720: 1.3 und Fertigkeiten offen). Ein Haken wäre das Erfolgserlebnis, das du am 09.11., 08:50 vermisst hast (654 f).

**Sachverhalt:**
- Regeln gebaut 03.11. auf `claude/tom-471-fertigkeiten`: `regeln/brs_fertigkeit.gd` wie `sim.py` (Übung je Benutzung mal Gegnerfaktor, Halt am Rangende mit Puffer 15, Bewährungsprobe zum Gesellen, Kapitel 1 bis Geselle), Test `brs_471` grün. 180 Zeilen, nie auf `main`, Zweig 4830 Commits hinter `main`.
- Im Spiel nicht angeschlossen: kein Kampf ruft die Übung auf.
- 762 (`ansehen/762-fertigkeiten.md`) zeigt Wert, Rang und Balken, aber nur Startwerte.
- Projektplan führt 1.2 als „gebaut“; das stimmt nur für den Zweig.

**Auswertung:**
- **A (Empfehlung):** Spike (1) bringt die Regeln auf den heutigen Stand, (2) schreibt Übung nur am Kampfende (Sieg) gut, nicht im Rundenablauf, (3) zeigt das Steigen in 762 mit Hinweis beim Aufstieg, (4) eine Testbitte für 471 und 762 zusammen. Kosten: eine Spike-Sitzung, ein Build.
- **B:** 471 ruht weiter bis nach dem Kampf; 762 zeigt bis dahin feste Werte.
- **Stärkstes Gegenargument gegen A:** „Kampf zuerst“ und eine zusätzliche Sitzung kosten Geld; Eingriff in Jerrys Kampfcode während t272. **Weg:** Spike hängt nur am Kampfende an und fasst den Rundenablauf nicht an; Feinheiten im Kampf (Übung je Schlag sichtbar) übernimmt Jerry nach t272.

**Nachtrag 20:52 (Chef 20:51: „Es gibt keine Fertigkeiten, die losgelöst vom Kampf sind … Schleichen … Wahrnehmung“):** Das BRS (abgenommen 01.11., Abschnitt 3 in `DESIGN-SPIELSYSTEM-2-0-ENTWURF.md`) hat 37 Fertigkeiten, 17 davon ohne Kampf: Schatten (Schleichen, Spähen, Schlösser knacken, Fallen entschärfen), Wildnis, Gesellschaft (Überreden, Einschüchtern, Handeln), Sammeln, Meisterschaften. Der Code von 471 kann jede Fertigkeit üben (`uebe`), angeschlossen wäre in A aber nur der Kampf; nach der Prüfregel gibt es eine Fertigkeit erst, wenn das Spiel eine Tätigkeit dafür hat. Darum gehört zu A: (5) Spike listet je Fertigkeit, ob Godot in Kapitel 1 schon eine Tätigkeit hat (etwa Laden → Handeln, Truhe → Schlösser), schließt die vorhandenen gleich mit an; fehlende Tätigkeiten (Schleichen, Spähen) kommen als eigene Vorlage über Homer, weil sie Spielgefühl sind.

**Folgerungen:** Bei A setzt Sokrates 471 auf „startbar, in Arbeit bei Spike“, Ford startet Spike; Perikles zieht Planpunkt 1.2 auf „Zweig“ nach. Bei B bleibt alles, 1.2 im Plan wird trotzdem berichtigt.

Antwort: …
