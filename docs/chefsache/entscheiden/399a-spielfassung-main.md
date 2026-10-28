# 399a · Spielfassung (Build 132) jetzt auf main?
Tom · 28.10., 16:12 · B Umzug
Kurz: Build 132 „erstmal freigegeben“: die Godot-Spielfassung jetzt auf main (A) oder erst am Ende des Umzugs (B)?

**Frage:** Du hast Build 132 heute um 16:09 „getestet und erstmal freigegeben“. Laut Plan kommt das Godot-Spiel erst nach deinem Test auf `main` (`LISTE-UMZUG-348.md`, „Ein Projekt“). Heißt dein „freigegeben“, dass es jetzt auf `main` soll?

**Votum Tom: A.**

**Berührt:** 348, 399, beide Teams, das alte Spiel auf `main`.

## Begründung

Seit drei Tagen arbeiten beide Teams auf Zweigen (495 Commits). Auf `main` hätten sie einen gemeinsamen Stand, und Jerry holt seine Arbeit dann von dort statt aus meinem Zweig.

## Sachverhalt (geprüft 28.10., 16:12)

- Getestet hast du Commit 13b97af52. Nach `main` käme genau dieser Stand, als Merge. Erschaffung, Spielstände und „Über“ kommen erst mit Build 133.
- Neu auf `main` wären `godot/`, `tools/blender348/`, die Godot-Workflows sowie Exporte und Tests in `core`.
- **Auch das alte Spiel ändert sich**, ohne dass du es getestet hast: kleine Änderungen in `Story.kt`, `Terrain.kt`, `VillageDay.kt`, `MapEdge.kt`, `MapFlora.kt` und `MapTownIso.kt` (zusammen etwa 120 Zeilen). Sie gehören zum Umzug: Der Brunnen ist von 17/14 nach 16/16 verlegt (Test t78), Gwenna geht mit; Waldrand und Bewuchs sind für den Export umgebaut.
- Ein Push auf `main` baut wie bisher die APK des alten Spiels; die Godot-APK baut weiter nur der Knopf.

## Auswertung

**Stärkstes Gegenargument:** Das alte Spiel auf `main` bekommt Änderungen an Karten und Geschichte, die keiner am alten Spiel getestet hat. Der nächste Release des alten Spiels nähme sie mit. Dagegen spricht: Das alte Spiel ruht seit dem 25.10. (348), ein Release ist nicht geplant, und die Kerntests laufen weiter grün.

## Folgerungen

- **A:** Ich führe 13b97af52 nach `main` zusammen (Merge, Kerntests vorher). Danach arbeiten beide Teams von `main` aus.
- **B:** Die Spielfassung bleibt auf dem Zweig, bis der Umzug abgenommen ist.

Antwort: …
