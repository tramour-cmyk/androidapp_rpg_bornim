# 724 · Werkzeugvorgänge nach „greift“ erledigt statt „wartet auf Test“ · Perikles · 09.11., 09:50
B Abläufe

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/main/docs/LISTE-VORGAENGE.md

**Anlass:** Rollenspiegel Perikles 06.11. (715), Frage 5. Neun meiner Vorgänge zu Werkzeugen und Abläufen stehen als „gebaut, wartet auf Test/Build“ in der Vorgangsliste (317.1, 464, 275, 627, 641, 646, 647, 651, 654.1). Sie sind kein Spielcode, du testest sie nie am Gerät; Diogenes hat die meisten schon mit „greift“ geprüft (z. B. 646 Lauf 86, 647 Lauf 87, 317.1 Lauf 91). Die Liste zeigt so Arbeit bei dir, die nicht bei dir liegt (vgl. deine Frage 08.11., 12:51 zu 625: „wartet es dann nicht auf mich?“).

**Frage:** Wann ist ein Vorgang zu Werkzeugen oder Abläufen (Bereich B) erledigt?

- **A (Empfehlung):** mit dem „greift“ von Diogenes. `vorgang.py` zeigt bei Bereich B mit „gebaut“ „wartet auf Diogenes“ statt „wartet auf Test“; nach „greift“ setzt der Besitzer „erledigt“, Lücken daraus werden eigene Vorgänge (wie D86.1, D87.1 heute schon). Kosten: eine kleine Änderung in `vorgang.py`, einmal die neun Zeilen nachziehen. Gegenargument: du siehst Regeländerungen nicht mehr in der Liste; sie stehen aber im Vorgangsarchiv und im Prüfbericht, und neue Regeln mit Wirkung auf dich kommen ohnehin als Chefsache.
- **B:** wie heute; die Zeilen bleiben, bis du sie ansiehst. Gegenargument: sie wachsen weiter (heute 9 von 22 meiner Zeilen) und verdecken, was wirklich auf dich wartet.

Antwort: „724 A“ oder „724 B“.
