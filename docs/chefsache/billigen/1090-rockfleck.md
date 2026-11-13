# 1090 · Vorentscheid „Hose unter der Robe weglassen“ billigen?
Sokrates · 13.11., 02:46 · E Figuren · Vorentscheid in der Nacht (Archiv 1077), Vorlage Tom 02:44
Kurz: unter der Robe steckt bei den Leuten noch eine Hose dicht am Bein, die durch den Stoff stößt; sie fällt weg wie beim Helden im Zaubergewand

Geprüft an: [Lauf 411](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/43337224562) (Bild Lyra vorher/nachher, `billigen/1044-frauenstand.md`), Messung Tom am gebauten Modell `held_L_lyra_W` (Vorlage `entscheiden/1090-rockfleck.md`, gelöscht 13.11., 02:46, in Git)

**Frage:** Lyras Rock zeigt dunkle Flecken (an den Knien, mit geschlossenen Füßen noch einer zwischen den Schienbeinen). Was tun?

**Entschieden:** A. Bei allen sieben Leuten mit Robe (Lyra, Liska, Gwenna, Rowena, Morwen, Aldric, Osric) fällt die Hose unter der Robe weg, wie beim Helden im Zaubergewand seit 376.1. Ein Bildlauf vorher/nachher aller sieben nah; dazu je ein Bild im Gehen, damit man sieht, ob zwischen Saum und Schuh eine Lücke aufgeht. Passt es, fährt es im nächsten Build.

**Berührt:** 1090 (Tom), 1044 (Damenstand), 431 (Kleiderschrank, gleiche Regel)

**Begründung:** Tom hat die Ursache gemessen: die Robe liegt 15 bis 30 cm außen, die Hose aus dem Leutebau bis 4 cm am Bein; wo sich das Bein bewegt, sticht sie durch. Beim Helden ist dieselbe Ursache seit 376.1 auf diesem Weg behoben, ohne dass seither etwas aufgefallen ist. Eine Zeile Code statt eines neuen Modells.

**Sachverhalt:**
- Gemessen an Lyra zwischen 25 und 55 cm Höhe: etwa 100 Ecken je Bein bis 4 cm vom Bein, die Beinhaut ist dort schon weg; die innere Lage ist die Hose (`leute.json` „pants“).
- Der Held im Zaubergewand trägt sie nicht (`trachten.json` „ohne“: pants); der Leutebau übernimmt diese Liste nicht.
- Thessa trägt keine Robe und bleibt, wie sie ist.

**Auswertung:**
- **A (entschieden):** Hose unter der Robe weg.
- **B (verworfen):** Hose enger ans Bein. In Bewegung wieder Treffer möglich, schwer zu prüfen.
- **C (verworfen):** Robe weiter. Die Frauen würden breiter, der Damenstand verliert.
- **Stärkstes Gegenargument gegen A:** im Gehen kann zwischen Saum und Schuh eine Lücke aufgehen, dann sieht man ins Leere. Dagegen: die Robe reicht bis zu den Knöcheln, die Stiefel bis 18 cm hoch; das Bild im Gehen prüft genau das.

**Folgerungen:** Tom baut die Zeile, die Kaufmodelle der Leute werden einmal neu gebaut (Bauserver etwa 40 Minuten), dann der Bildlauf; Bild an Sokrates bzw. morgens an dich.

**Umgesetzt:** noch nichts.

**Rückbau:** sagst du „zurück“, kommt die Hose wieder (eine Zeile).

**Kosten:** eine Zeile Code, ein Neubau der Kaufmodelle, ein Bildlauf.

Antwort: …
