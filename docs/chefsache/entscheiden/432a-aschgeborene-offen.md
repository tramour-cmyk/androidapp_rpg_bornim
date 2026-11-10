# 432a · Aschgeborene: wie entscheidest du die drei offenen Storyfragen und den Zeitpunkt des Baus?
Homer · 10.11., 11:58 · G Story · aus deinem Wort 11:55 („wenn du das jetzt erledigen kannst, kannst du es doch erledigen“)
Kurz: Vesks Liste eindeutig machen, Kael Nachfahre ohne Mal, Lyra keine Aschgeborene, Bau als Vorgang an Tom nach Kapitel 1

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/4cc6ebfee (Quellen gelesen; Helfer prüfte die Vorlage 11:57)

**Frage:** Die Aschgeborenen sind ein Volk, das du am 01.11. als sechstes wählbares Volk beschlossen hast (432). Es sind Nachfahren der Überlebenden der Stadt Aschfurt, erkennbar an einer aschgrauen Haarsträhne und einem goldenen Ring um die Iris. Werte (432.2) und Merkmal „Aschenerbe“ (432.3) stehen fest. Offen sind drei Storyfragen aus dem Storyplan und die Frage, wann gebaut wird. Wie entscheidest du die vier?

**Votum:** Sag „432a A“, dann gilt meine Empfehlung bei allen vieren (1 „Ehering fehlt“, 2 Kael ohne Mal, 3 Lyra keine, 4 Bauvorgang ruht bis Kapitel 1 fertig). Willst du einzeln entscheiden, zum Beispiel „432a 1A, 2B, 3A, 4B“.

**Berührt:** 432 (Homer), 41 (Texte Kapitel 2), `[41.schanze.liste]`, Kael (Kapitel 2), Lyra (Kapitel 1), Bau bei Tom (Modell, Volk in der Erschaffung, Zeichen am Bildrand)

**Begründung:** Mein Maßstab: Der Faden der Aschgeborenen soll in Kapitel 2 nichts verraten und Kapitel 1 nicht ändern.

**Sachverhalt:**
- Laut Storyplan (`STORY-PLAN.md`, Zeilen 21–27) ist der goldene Ring der Rest eines Siegels, das in der Nacht von Aschfurt geschlossen wurde, und er wird im Blut weitergegeben. Der Kult des Grauen Propheten lernt erst aus seinem gescheiterten Ritual in Kapitel 2, dass er dieses Blut braucht. Ab Kapitel 3 jagt er die Aschgeborenen.
- Vesk ist der Menschenhändler in der Rabenschanze (Kapitel 2). Auf seinem Tisch liegt eine Liste (`kapitel2/STORY-K2-ENTWURF.md`, `[41.schanze.liste]`), darin der Eintrag „Tobin, Fischer, Bornim – Ring fehlt“. Gemeint ist Tobins Ring: Gwenna, Tobins Frau, trägt ihn an einer Schnur um den Hals, Tobin hat einen leeren Ringfinger (`LISTE-FIGUREN.md`). Bringt der Held Gwennas Ring zurück, erkennt er Tobin auf der Liste (`[41.schanze.liste.gwenna]`).
- Kael ist ein alter Mann in Bornim. In Kapitel 2 erzählt er, dass sein Großvater den Brand von Aschfurt überlebt hat (`kapitel2/STORY-PLAN-K2.md`, 2c, 3d). Laut Storyplan jagt der Kult deshalb ab Kapitel 3 auch in Bornim.
- Lyra ist die Priesterin, die in Kapitel 1 mit dem Amulett geraubt wird. Graks Brief sagt, der Prophet wollte „Amulett und Priesterin“ (`STORY-PLAN-K1.md`, Zeile 9). Ihr Modell trägt Stirnreif und weiße Robe, keine Strähne und keinen Ring.
- Gebaut ist von den Aschgeborenen noch nichts, weder ein Vorgang bei einem Team noch etwas im Godot-Code. Laut 432 wird nach dem Meilenstein Kapitel 1 gebaut. 432.3 verlangt außerdem, die Werte vorher in der Simulation 444 zu messen. Das geht auch ohne Bau.

**Auswertung:**

1. **Vesks Liste: „Ring fehlt“**
   - A: so lassen. Das war bisher mein Vorschlag (im Storyplan: „als Fährte, die erst in Kapitel 3 umkippt“).
   - **B (Empfehlung, ich ändere meinen Vorschlag):** „Ehering fehlt“ schreiben. Wer das Mal kennt, kann „Ring fehlt“ als „hat keinen Ring im Auge“ lesen, als hätte der Kult schon in Kapitel 2 nach dem Mal sortiert. Das widerspräche dem Storyplan. Mit „Ehering“ ist die Liste eindeutig, und Gwennas Ring bleibt die Verbindung zu Tobin.
   - Stärkstes Gegenargument gegen B: Es geht eine stille Fährte verloren, die genaue Leser in Kapitel 3 belohnen würde. Dagegen: In Kapitel 2 kann sie niemand richtig deuten, sie wirkt dort nur wie ein Fehler.

2. **Trägt Kael das Mal sichtbar?**
   - **A (Empfehlung):** nein. Das Blut aus Aschfurt tragen viele Nachfahren, das Mal zeigt sich aber nur bei manchen. „Aschgeborene“ heißen nur die mit dem Mal, und als Volk wählt der Spieler genau so einen. Kael ist Nachfahre ohne Mal. Weil der Kult das Blut nicht von außen erkennt, jagt er ab Kapitel 3 alle Nachfahren, auch Kael.
   - B: ja, Kael trägt Strähne und Ring. Dann versteht der Spieler das Mal schon in Kapitel 2, und Kael müsste dort schon in Gefahr sein.
   - Stärkstes Gegenargument gegen A: Das ist eine neue Regel der Welt (Blut ohne Mal). Sie macht aus dem Volk eher eine Abstammung, und der Storyplan muss sie festhalten. Dagegen: Sie erklärt, warum es so wenige Aschgeborene gibt, und sie stärkt „in Bornim gejagt“. Mein früherer Vorschlag aus dem Storyplan, das Mal verblasse mit jeder Geburt, schwächte genau das und fällt weg.

3. **Ist Lyra eine Aschgeborene?**
   - **A (Empfehlung):** nein. Der Kult wollte sie als Priesterin des Amuletts, das reicht als Grund. Kapitel 1 bleibt, wie es ist.
   - B: ja. Das wäre eine starke Wendung. Aber Lyras Modell in Kapitel 1 bekäme Strähne und Ring, Kapitel 1 würde also geändert, und der Faden wäre schon im ersten Kapitel verraten.
   - Stärkstes Gegenargument gegen A: Die Wendung geht verloren. Dagegen: Für spätere Kapitel bleiben Kael und die offene Frage, ob der Prophet selbst einer ist (Kapitel 3 oder 4).

4. **Wann wird gebaut?** Zu bauen sind das Modell (Mensch mit Strähne und Iris-Ring), das Volk in der Erschaffung des Helden und das Zeichen am Bildrand an den Orten aus 432.3.
   - **A (Empfehlung):** Ich lege jetzt einen Bauvorgang bei Tom an, Stand „ruht bis Kapitel 1 fertig“, die Messung in der Simulation 444 gleich mit. So geht nichts verloren, und Kapitel 1 bleibt vorn (Oberste Direktive: Kapitel 1 geht jeder Kür und allem Neuen vor).
   - B: Bau jetzt. Dann kostet ein sechstes Volk Arbeit an Erschaffung, Werten und Tests, die die Abnahmeliste für Kapitel 1 nicht fordert.
   - Stärkstes Gegenargument gegen A: Ein weiterer ruhender Vorgang, und wählen kann man das Volk erst nach Kapitel 1. Dagegen: Kapitel 1 kommt ohne die Aschgeborenen aus, der Faden trägt laut Storyplan auch ohne das Volk.

**Folgerungen:** Ich trage deine Antworten in den Storyplan und in `[41.schanze.liste]` ein. Bei 4A lege ich den Bauvorgang für Tom an. Danach ist 432 bei mir erledigt.

Antwort: …
