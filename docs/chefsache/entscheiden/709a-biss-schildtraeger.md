# 709a · Wie soll ein Wolf einen Helden mit Schild sichtbar beißen?
Jerry · 10.11., 14:16 · E Kampf · aus 709 (dein Wort 08.11., 21:36: „dass die Angriffe so sind, dass sie den Gegner treffen“)
Kurz: Wölfe und Schnecke beißen vor dem Schild in die Luft (0,2–0,4 m); tiefer Biss in die Beine, in den Schildrand oder weiter seitlich?

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/86ec1c874 (Messung `tests/treffen_709.gd` am Rechner, alle Gruppen, 10.11., 14:12)

**Frage:** Der Held und der Söldner treffen jetzt fast immer mit der Klinge (32 von 38 Treffern), die Fledermaus 10 von 10. Wölfe, Grimmzahn und die Säureschnecke treffen den Helden mit Schild aber fast nie sichtbar: Der Schild steht vor dem Körper, der einzige Biss des Wolfs geht gerade nach vorn in Kopfhöhe, die Schnauze bleibt 0,2–0,4 m vor dem Körper. Seitlich um den Schild herum geht nur, wenn dort Platz ist, sonst nicht (andere Wölfe, Bildrand). Wie soll der Biss aussehen?

**Votum:** „709a A“: tiefer Biss nach den Beinen, unter dem Schild durch. Ich baue ihn aus der Fressbewegung des gekauften Wolfs und schicke dir einen Film, bevor er in eine Testfassung kommt.

**Berührt:** 709 (Jerry), 595 (Bewegungen der gekauften Gegner), 406.2 (Schild des Helden immer vorn, 406.2 B von heute)

**Begründung:** Ein Treffer zieht im Kampfsystem MARS Leben ab. Sichtbar ist er nur, wenn die Zähne den Körper erreichen. Ein Biss in den Schild sähe abgewehrt aus, trotzdem verlöre der Held Leben.

**Sachverhalt:**
- Der gekaufte Wolf hat genau eine Angriffsbewegung (Attack, bei uns „Biss“, gerade, Kopfhöhe) und dazu „Eat“ (Fressen, Kopf am Boden; von mir noch nicht angesehen), bisher nicht eingebaut (`tools/blender348/kaufwolf.py` 6, 52).
- Messung 14:12, Abstand der Schnauze zum Körper im Moment des Bisses: Wolf 0,19–0,42 m, Grimmzahn 0,33–0,35 m, Schnecke 0,27–0,36 m, jeweils vor dem Schild.
- Nur seitlich um den Schild treffen die Wölfe auf 0,05 m. Dort steht aber oft ein anderer Wolf, oder der Platz liegt außerhalb des Bildes; dann fiele der Wolf in den Helden oder in den Nachbarn (die Prüfung `wolf_mess_438` schlägt dann fehl).

**Auswertung:**
- **A (Empfehlung):** tiefer Biss in Wade oder Oberschenkel, gebaut aus „Eat“ (Kopf runter) und dem Vorstoß aus „Attack“. Wirkt wie ein Wolf, der von unten schnappt. Etwa eine Sitzung.
- **B:** der Wolf beißt sichtbar in den Schildrand und zerrt daran. Billig, aber der Held verliert dabei Leben, obwohl der Schild hält.
- **C:** so lassen wie heute: der Wolf schnappt vor dem Schild ins Leere, wenn kein Platz seitlich frei ist.
- **Stärkstes Gegenargument gegen A:** Aus einer Fressbewegung gebaut, kann der Biss wie Schnuppern oder Grasen aussehen; das zeigt erst der Film. Die Schnecke braucht dafür ihren eigenen Weg.

**Folgerungen:** bei A: Jerry baut den tiefen Biss für Wolf und Grimmzahn, ein Film an dich, erst danach in eine Testfassung; die Schnecke folgt mit eigenem tiefem Stoß. Bei B oder C: Jerry legt 709 mit dem Stand von heute in die nächste gemeinsame Testfassung.

Antwort: …
