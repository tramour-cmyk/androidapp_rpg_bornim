# 1090 · Dunkle Flecken im Rock: Hose unter der Robe weglassen?
Tom · 13.11., 02:44 · E Figuren · aus Sokrates 13.11., 02:30 (zu 1044, Nacht 1077: Ursache je Rockträgerin nachstellen, Weg und Kosten vorschlagen, erst dann bauen)
Kurz: Unter der Robe der Frauen (und Männer in Robe) steckt noch eine Hose dicht am Bein; die stößt durch den Stoff. Beim Helden im Zaubergewand ist sie seit 376.1 weg, bei den Leuten nie. Vorschlag: bei allen mit Robe die Hose weglassen.

Geprüft an: [Lauf 411](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/43337224562) (Bilder, `ansehen/1044-damenstand.md`, Telegram 02:19); dazu Lyras gebautes Modell `held_L_lyra_W` aus dem Bauserver-Cache, am Rechner in Blender gemessen

**Frage:** Soll bei allen Leuten mit Robe (Lyra, Liska, Gwenna, Rowena, Morwen, Aldric, Osric) die Hose unter der Robe weggelassen werden, wie beim Helden im Zaubergewand?

**Votum:** „1090 A“: Hose unter der Robe weg, ein Bildlauf vorher/nachher aller sieben nah.

**Berührt:** 1044 (Damenstand, die Flecken stören dort), 431 (Kleiderschrank später, gleiche Regel), 376.1 (Held im Zaubergewand, Vorbild).

**Begründung:** Sokrates 02:30: „Ursache je Rockträgerin am Rechner nachstellen, Abhilfe vorschlagen (Weg und Kosten), erst dann bauen“.

**Sachverhalt:**
- Gemessen an Lyra auf Höhe der Schienbeine (25 bis 55 cm): das Netz „Kleid“ hat etwa 100 Ecken je Bein bis 4 cm vom Bein und weitere bis 8 cm, die Robe liegt 15 bis 30 cm außen; die Beinhaut ist dort schon entfernt (`beine_weg`). Die innere Lage ist die Hose aus dem Leutebau (`leute.json` „pants“, bei Lyra dunkelgrau).
- Gegenprobe im Bild am Rechner: stellt man die Füße weiter, wandern die Flecken mit den Knien; geschlossen bleibt einer zwischen den Schienbeinen.
- Beim Helden im Zaubergewand ist die Hose seit 376.1 weg (`trachten.json` „ohne“: pants, Grund damals: „unter der Robe stach die Hose im Lauf durch“). Der Leutebau (`held_klassen.py`, Leute auf dem Kaufkörper) übernimmt diese Liste nicht; alle sieben mit Robe tragen sie noch.
- Thessa trägt keine Robe (Rock „keiner“), sie ist nicht betroffen.

**Auswertung:**
- **A (Empfehlung):** bei Robe die Hose weglassen (eine Zeile im Leutebau, wie 376.1). Stärkstes Gegenargument: im Gehen kann zwischen Saum und Schuh eine Lücke aufgehen, dann sähe man ins Leere statt auf die Hose. Dagegen: die Robe reicht bis zu den Knöcheln, der Schaft der Stiefel bleibt bis 18 cm; beim Helden im Zaubergewand ist das seit 376.1 so und nie aufgefallen.
- **B:** Hose behalten, aber 2 bis 3 cm enger ans Bein ziehen. Gegen B: in Bewegung wieder Treffer möglich, schwer zu prüfen.
- **C:** Robe weiter machen. Gegen C: die Frauen würden breiter, der Damenstand verliert an Wirkung.

**Folgerungen:** A: Tom baut die Zeile, die Kaufmodelle der Leute werden einmal neu gebaut (Bauserver etwa 40 Minuten, danach im Cache), ein Bildlauf vorher/nachher aller sieben nah, Bild an Sokrates bzw. den Chef; fährt im nächsten Build. B oder C: neue Vorlage mit Probe.

**Kosten:** eine Zeile Code, ein Neubau der Kaufmodelle, ein Bildlauf.

Antwort: …
