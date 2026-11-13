# 867 · Hauptmenü: passen die vier Helden in Vorlage 5?
Tom · 13.11., 01:42 · G Stil · aus Sokrates 13.11., 00:25 (Vorlage 4 nicht so, „B mit Mitte“, Nacht 1077)
Kurz: Vorlage 5: Zauberlehrling und Jägerkind zur Mitte gedreht, Gesicht zum Spieler; das Schwert der Wachsoldatin steht senkrecht mit der Spitze am Boden, der Schild lehnt neben ihr. Offen: sie stützt die Hände nicht auf das Schwert, die Arme hängen.

Geprüft an: [Lauf 410](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/43335311452), [Commit 331dbfe](https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/331dbfe6081583ce119b93f785410c61872ee8c3) (Zweig `claude/tom-867-vorlage5`), Hauptmenü am Bauserver mit den gekauften Figuren wie im Spiel; oben von vorn (wie im Menü), unten um 270 Grad gedreht; 90 und 180 Grad im Lauf ebenfalls angesehen

![Oben die vier Helden von vorn: Wachsoldatin mit Kettenhemd, das Schwert senkrecht neben dem rechten Bein, die Spitze am Boden, die Arme hängen; der Rundschild lehnt rechts neben ihr am Unterschenkel. Zauberlehrling und Jägerkind leicht zur Mitte gedreht, Gesicht zum Spieler. Unten dieselben von der Seite: die Wachsoldatin steht gerade, Schwert und Schild neben den Beinen](../bilder/867-vorlage5.jpg)

**Frage:** Von den zwei Punkten aus 00:25 ist (2) erledigt, (1) nur halb: Schwert mit der Spitze am Boden und Schild mit der Fläche zum Spieler ja, aber die Hände liegen nicht am Griff. Passt Vorlage 5 so, oder soll die Wachsoldatin nachgebessert werden?

**Votum:** „867 B“: nur die Wachsoldatin nachbessern, beide Fäuste übereinander auf dem Knauf vor dem Körper (Muster 292.3); die anderen drei bleiben. Vorher am Rechner an der gekauften Figur nachstellen, warum die gestellten Arme im Lauf nicht greifen.

**Berührt:** 431 (Körperbau je Volk, nach dem Umzug); 870.13 (Fußzeile „SRD 5.1 · CC BY 4.0“, Umzug).

**Begründung:** Sokrates 13.11., 00:25: „Wachsoldatin Schwert mit der Spitze am Boden, Hände am Griff“; Chef 12.11., 21:40: „pro Char eine andere Haltung, in der Waffe und Schild gesehen werden“.

**Sachverhalt:**
- Wachsoldatin: Schwert senkrecht neben dem rechten Bein, Spitze am Boden, die rechte Hand nahe der Parierstange; der linke Arm hängt unter dem Mantel. Die gestellten Arme (Klasse `SchwertStuetzen`) wirken im Lauf nicht; am Rechner waren sie nur an der freien Grundfigur gemessen (Faust 0,9 cm am Ziel), nicht an der gekauften Figur.
- Schild: lehnt rechts neben ihr (links von ihr aus) am Unterschenkel, die Fläche halb zum Spieler; von der Seite (90 Grad) überdeckt er die Stiefel.
- Zauberlehrling und Jägerkind: um 25 Grad zur Mitte gedreht, Kopf zum Spieler; Klosterschülerin unverändert.
- Alle vier Blickrichtungen angesehen (0, 90, 180, 270 Grad): nichts schwebt, kein Stab geht durch den Körper.
- **Mir ist aufgefallen:** rot im Lauf nur `pruefliste_1020` (Spalte „Passt“, behoben in 1087) und `ziege_4162` (1079); beide nicht 867.

**Auswertung:**
- **A:** passt so, Einbau im nächsten Sammelbuild. Gegen A: „Hände am Griff“ ist nicht erfüllt, die Wachsoldatin wirkt passiv.
- **B (Empfehlung):** nur die Wachsoldatin nachbessern, neue Vorlage. Stärkstes Gegenargument: noch ein Lauf (etwa 35 Minuten) für zwei Arme. Antwort: das Hauptmenü ist das erste Bild des Spiels, und die Ursache lässt sich am Rechner mit den gekauften Figuren nachstellen, bevor gebaut wird.

**Folgerungen:** A: Tom baut ein, 867 wird im Build getestet. B: Tom stellt die Ursache am Rechner nach, baut die Arme um und legt neu vor (ein Lauf).

Antwort: …
