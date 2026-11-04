# 568 · Ernten als Handlung statt Einsaugen im Vorbeilaufen
Sokrates · 04.11., 19:3x · A Spiel · berührt DESIGN-SPIELSYSTEM-2-0 „Sammeln“ (Frage 13, Vorschlag), Team Tom (Welt), Team Jerry (Bewegung), 488 Durchspielregel

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/main/core/src/main/kotlin/de/bornim/core/Game.kt (alt `pickHerbs`, Zeile 751: „Walking onto a herb picks it; it grows back the next morning“)

**Frage:** Soll Sammeln eine sichtbare Handlung werden: hingehen, antippen, der Held bückt sich kurz und pflückt, die Stelle ist danach sichtbar abgeerntet, bis sie nachwächst?

**Votum:** Ja, als Grundsatz für alle Rohstoffe (Kräuter, Pilze, Erz, Holz, Fische, Zerlegen). In Kapitel 1 nur die Kräuter. Bauen erst, wenn Kapitel 1 durchspielbar ist (488), außer du sagst „jetzt“.

**Berührt:** `DESIGN-SPIELSYSTEM-2-0.md` „Sammeln“ (dort steht schon „Ernten ist eine kurze Aktion am Fundort … tippen, kurz warten, Ergebnis“, als Vorschlag), Pflücken im Wald (Tom), Bewegung (Bestand: Hocken, Knien), Fertigkeit Kräuterkunde.

**Begründung:** Heute läuft man wie in der alten Fassung über die Wiese, und die Kräuter verschwinden ohne Bewegung. Das widerspricht „lebendige Welt, keine Figur steht starr“ (DESIGN-STIL) und deinem Maßstab vom Jagen. Wer ein Fell will, muss ein Tier erlegen, also kostet auch ein Kraut eine Handlung. Die Handlung macht das Gefundene wertvoller, und die Fertigkeit wird sichtbar (mehr und bessere Kräuter je Griff).

**Sachverhalt:** Ablauf je Fundstelle:
1. Die Pflanze steht sichtbar in der Welt, nicht als Fleck im Gras.
2. Der Held steht nah dran, und der Aktionsknopf zeigt das Zeichen „Ernten“.
3. Tippen: Der Held geht in die Hocke und pflückt (etwa 1,5 s, Bewegung aus dem Bestand).
4. Die Meldung „Du pflückst Heilkräuter (+n)“ erscheint, die Pflanze ist abgeerntet (Stängel ohne Blüten) und wächst am nächsten Morgen nach wie heute.

Später kommen weitere Arten: Erz mit der Hacke, Holz mit dem Beil, Fische mit der Angel, Zerlegen nach dem Sieg, je eine kurze eigene Bewegung.

**Auswertung, stärkstes Gegenargument:** Zwanzig Kräuter einzeln zu ernten, je mit Bücken, wird zäh. Das ist Grinden, das man tun muss, statt es zu dürfen (Leitbild). Lösung:
- Weniger, aber ergiebigere Stellen: Ein Griff bringt ein bis drei Kräuter, je nach Kräuterkunde. Insgesamt kommt also gleich viel zusammen wie heute.
- Die Bewegung dauert höchstens 1,5 s, und Weiterlaufen bricht sie ab.
- Ein Tier in der Nähe kann den Sammler stören. Das schafft Spannung statt Mähen.

Zweites Gegenargument: Jede Art braucht eine eigene Bewegung, das kostet. Deshalb zuerst nur das Pflücken, die anderen erst, wenn ihr Rohstoff ins Spiel kommt.

**Folgerungen:** Bei Ja kommt der Grundsatz in `DESIGN-SPIELSYSTEM-2-0.md` „Sammeln“ (von Vorschlag zu entschieden), und der Bau geht an Tom mit einer Vorlage als Film. Bei Nein bleibt das Einsammeln im Vorbeilaufen.

**Zu sagen:** „568 ja“, „568 ja, jetzt“ oder „568 nein“.

Erledigt: Antwort ins Vorgangsarchiv, Datei löschen (Sokrates).
