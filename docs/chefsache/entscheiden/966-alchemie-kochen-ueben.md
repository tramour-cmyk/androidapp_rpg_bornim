# 966 · Wodurch üben Alchemie und Kochen?
Sokrates · 11.11., 15:46 · E Welt · Rückfrage nach „zurück“ zum Vorentscheid A (15:36)
Kurz: Üben nur mit eigener Leistung des Helden; Vorschlag Ring wie beim Schlösserknacken, unter dem Rang ohne Ring und ohne Übung.

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/9a34fec2a (Umzugszweig `claude/tom-870-4-held`)

**Chef (11.11., 15:44, im Chat):** „für Schlösser knacken muss ich ja auch was tun, um meine Fertigkeit zu verbessern. Um besserer Schwertkämpfer zu werden, muss ich auch kämpfen. Also bloß, weil ich jetzt am Lagerfeuer bin und dann plötzlich 20 gebratene Hähnchen habe, das haut so nicht hin. Also da muss schon auch irgendeine Form der Leistung dahinter stehen. Und das darf in höheren Level auch nichts mehr geben, weil … ein Fleischputzeln ist jetzt ja kein hohes Gut.“

**Frage:** Verstanden als „zurück“ zu A (Morwen braut, Fleisch brät von selbst): (1) Üben nur mit eigener Leistung; (2) Leichtes bringt mit steigender Fertigkeit weniger, unter dem eigenen Rang nichts; (3) Menge zählt nicht, 20 Braten = eine Übung. Richtig verstanden, und wie üben beide?

**Votum:** A neu (Ring), Antwort „ja“, „ohne Ring“ oder anders.

**Berührt:** 966.1 (Homer: Satz am Kessel `[966.1.kessel]` passt nur, wenn der Held selbst braut), 966.2 (Tom, angehalten), 954a (D), 481, 857a

**Begründung:** Beide bleiben nach 954a D wählbar und brauchen eine Tätigkeit (Prüfregel `DESIGN-BRS.md` 3). A (15:36) übte ohne eigenes Tun; das widerspricht „du wirst, was du tust“, wie der Chef es beim Knacken (15:26) und beim Schwert fasst.

**Sachverhalt:**
- Alchemie wirkt in `laden.gd` 19 und 202 (`brau_chance`); heute braut nur Morwen (`braue`, ×5 `braue_mehr`), der Held tut nichts.
- Kochen wirkt in `laden.gd` 26 und `menue.gd` 718 (`essen_bonus`); bei der Rast wird rohes Fleisch von selbst zu Braten (`rast.gd` 76–80), jedes Stück.
- `uebe` rufen heute nur Handeln (`laden.gd` 87, 97) und Kräutersammeln; Knacken mit Ring ist entschieden, nicht gebaut.

**Auswertung:**
- **A neu (Votum):** wie Knacken (`DESIGN-BRS.md` 8, Chef 15:26). **Kochen:** der Held brät selbst, ein Ring wie im MARS (wenden im richtigen Moment, etwa 3 s); gelungen gibt der Braten mehr Leben, daneben verkohlt das Stück; Übung einmal je Mahlzeit nach Schwierigkeit (Spieß wenig, Wildschwein oder Rezept mit Kraut mehr); unter dem Rang ohne Ring und ohne Übung. **Alchemie:** der Held braut selbst am Kessel, Morwen lehrt je Trank ein Rezept; Ring für die Hitze, daneben ist der Sud verdorben und die Kräuter sind weg; Übung nur am eigenen Sud nach Schwierigkeit des Rezepts; Heiltrank unter dem Rang übt nicht.
- **B ohne Ring:** Übung nur durch seltene, schwere Rezepte; Leistung = Zutaten beschaffen. Billiger, aber kein eigenes Tun am Kessel.
- **Stärkstes Gegenargument gegen A neu:** dritter Ring nach Kampf und Schloss, kann ermüden. **Weg:** unter dem Rang fällt der Ring weg, er kommt nur bei Neuem; ein Bedienmuster für alles.
- **Abgleich:** BRS 3 „Durch Tun“, „Zu leichte Ziele bringen kaum etwas“ (verschärft: unter dem Rang nichts); Leitbild 3 (Grinden freiwillig) passt; 954a D (beide wählbar) bleibt.

**Folgerungen:** nach dem Umzug, nicht in B1; Tom baut (966.2 neu), Homer Rezeptnamen (966.1 neu); Text in `DESIGN-BRS.md` 8 wie Knacken.

**Kosten:** etwa eine bis zwei Sitzungen Tom, Homer klein.

Antwort: …
