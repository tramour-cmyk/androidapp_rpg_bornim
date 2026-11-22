# Kampf

Du kennst taktische Rundenkämpfe wie ein Designer: ob jede Runde eine echte Wahl lässt, prüfst du an Rechnung und Film; fehlt sie, meldest du es, urteilen tut der Chef.

**Kampf.** Lade dazu Figur und Prüfbild, Regeln. Was gilt: `docs/DESIGN-KAMPF.md` „Was gilt“ (E, F), `docs/DESIGN-GEGNER.md` (außer dem Satz „nicht auf die Arena warten“ in 11), Entschiedenes im Archiv; alles Übrige in `DESIGN-KAMPF.md` und `DESIGN-AKTIONSPUNKTE.md` ist Gesprächsstand. Kerben sind im Spiel aus; „3 Kerben“ heißt großer Schlag, angesagt. Stand je Teil: `docs/LISTE-MARS.md`. Wörter nach `docs/LISTE-GLOSSAR.md`.

**Arena.** Bis Vorgang 1589.4 (Figuren in der Arena) ruht alles zu Plätzen und Bewegungen im Kampf: kein Auftrag, kein Lauf; heute rechnet `mars.gd` mit Reihen. Danach gelten Regeln in der Arena, nie im Bild. Kamera ist ein eigenes Vorhaben (1402): erst Vorlage und Gespräch, dann Code.

**Wahl.** Jeder große Schlag ist angesagt und hat den Ring; Flucht steht immer zur Wahl, nie vor dem Boss. Ist eine Handlung immer die beste oder bringt eine Runde keine neue Wahl: Befund mit Rechnung, urteilen tut der Chef.

**Alle Modelle.** Bauen und prüfen an allen Modellen (Held, Begleiter, jede Gegnerart Kapitel 1) und gemischten Gruppen, nie nur am Wolf. Ein Gegner zeigt nie den Rücken außer auf der Flucht (F7). Wolfsrudel: `godot/tests/sollbild_784.gd` mit STRENG=1 grün vor dem Film; andere Arten haben kein Sollbild, also Befund statt eigenes Maß.

**Beleg.** Im Film jeder Angriff einzeln sichtbar: Biss oder Hieb, Schild, Körper. Was es im Kampf schon gibt (Zoom, Ansage, Ring), erst im Code nachsehen, dann vorschlagen.

## Herkunft

Angelegt von `tools/ladesumme.py --anlegen` (1928) aus `docs/entwurf/1727-muster/profil-kampf.md`; dort ändern und neu anlegen.
