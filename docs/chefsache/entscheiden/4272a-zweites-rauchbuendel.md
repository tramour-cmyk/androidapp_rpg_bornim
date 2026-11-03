# 427.2a · Gibt Morwen ein zweites Rauchbündel, wenn man Krogg mit dem ersten verliert?
Homer · 03.11., 08:14 · D Design

Kurz: Zweites Rauchbündel nach einer Niederlage gegen Krogg?

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/main/godot/regeln/klassisch.gd

**Frage:** Das Rauchbündel fliegt beim Auftauchen Kroggs von selbst und ist danach weg; Morwen gibt es nur einmal. Wer mit Bündel verliert, kämpft danach immer ohne, also gegen Kroggs vollen ersten Hieb. Soll Morwen nach einer Niederlage ein neues geben?

**Votum:** „427.2a ja“: nach jeder Niederlage gegen Krogg gibt Morwen beim nächsten Besuch ein neues Bündel, mit eigener Zeile in drei Wortlauten.

**Berührt:** 427.1 (Krogg erst abnehmen, wenn der Rauch zu bekommen ist), 427.2 (Hinweis nach der Niederlage), D4.1 (Weg über Morwen).

**Begründung:** Du hast Kroggs Werte unter der Bedingung abgenommen, dass der Rauch im Spiel zu bekommen ist (427.1). Nach einer Niederlage mit Bündel ist er es nicht mehr; der zweite Versuch ist schwerer als der erste.

**Sachverhalt:** Bündel verbraucht beim Auftauchen Kroggs (`godot/regeln/klassisch.gd` 412–416); Morwen gibt es nur, solange `SMOKE_GIVEN` fehlt (`godot/skripte/geschichte.gd`, `wants_smoke`). Prüfer-Befund 03.11.

**Auswertung:** Stärkstes Gegenargument: Ein Bündel nach jeder Niederlage macht Krogg zum Abnutzungskampf ohne Preis. Trägt nur halb: der Preis ist der Weg zurück in den Tiefen Flüsterwald und die verlorenen Stunden; ohne Bündel bleibt dagegen nur Grinden bis zur nächsten Stufe, gegen „Grinden darf man, muss man nie“. Alternative „nein“: Hinweis nach der Niederlage rät zum Stärkerwerden (Zeilen stehen schon).

**Folgerungen:** Bei „ja“ schreibt Homer Morwens Zeilen, Tom baut sie mit 504.1. Bei „nein“ bleibt alles, wie es ist.

Antwort:
