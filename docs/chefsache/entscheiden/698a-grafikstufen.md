# 698a · Was soll jede Grafikstufe abschalten, und startet das Spiel auf „Automatisch“?
Spike · 16.11., 00:45 · E Technik · aus 698 (dein Wunsch 28.10., 08:31 und 08.11., 19:46: Grafikstufen im Systemmenü, Niedrig, Mittel, Hoch, Automatisch per Leistungstest)
Kurz: Drei Stufen plus Automatisch; Tuschelinie, Licht aus Quelle und Gold bleiben in jeder Stufe, gespart wird an Schatten, Bildschärfe und den gekauften Effekten.
Beim Chef, weil: Aussehen (was auf schwächeren Handys fehlt)

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/274ec030b/godot (`main`): `godot/project.godot` (Renderer mobile, Sonnenschatten 4096 px weich, Kantenglättung FXAA), `godot/skripte/testmodus.gd` (Messschalter 1145: Tusche, Tusche nach Lampen, Nebel, Schatten), `grasbausatz.gd` und `dorfeffekte.gd` (Schalter `an`, schon für 698 vorgesehen), `menue.gd` `system()` (Systemmenü); deine Messungen 14.11. (alles aus: 94 Bilder/s bei 120 Hz, hakelt trotzdem) und 15.11., 13:47 (Höhle, Grafikzeit 17,6 ms, Grafikkarte begrenzt)

**Frage:** Du wolltest Grafikstufen im Systemmenü, damit das Spiel auch auf schwächeren Handys flüssig läuft (Maßgerät ist das Galaxy A22 von Tester 1, daneben dein A56). Bevor ich baue, brauche ich dein Wort, was jede Stufe weglässt, denn das ist Aussehen. Mein Vorschlag steht unten in der Tabelle. Grundsatz: Was unsere Signatur ausmacht (Tuschelinie, Licht aus sichtbaren Quellen, Gold als einziger Glanz, Nebel am Rand), bleibt in jeder Stufe. Gespart wird dort, wo es am meisten Rechenzeit kostet und am wenigsten auffällt: Schatten, Schärfe des Spielbilds (Schrift und Menüs bleiben immer scharf), die Effekte aus den Kits.

| | Hoch | Mittel | Niedrig |
|---|---|---|---|
| Tuschelinie, Licht aus Quelle, Gold, Nebel am Rand | ja | ja | ja |
| Tusche nach Lampen (Linie dicker auf der Schattenseite) | ja | ja | nein, nur nach Helligkeit |
| Sonnenschatten | sehr fein, weiche Kanten | fein, weiche Kanten | grob, harte Kanten |
| Schatten in Innenräumen (Kamin, Fackel, Tageslicht am Fenster) | ja | ja | nein |
| Schärfe des Spielbilds | voll | 85 % | 70 % |
| Gras und Blumen aus dem gekauften Paket | ja | ja | nein, unser eigenes Gras wie bisher |
| gekaufte Effekte (Rauch, Fackeln, Staub im Licht) | ja | ja | nein, unser eigener Rauch und die Lichtinseln wie bisher |

**Automatisch:** Das Spiel misst beim Spielen mit. Ruckelt es zehn Sekunden lang, geht es eine Stufe herunter und sagt es einmal unten am Rand („Grafik: Mittel“). Herauf geht es nie von selbst, das tust du im Systemmenü. Neu installiert startet das Spiel auf „Automatisch“, beginnend bei „Hoch“ (auf schwachen Handys ruckelt es darum beim ersten Spielen kurz).

**Votum:** „698a A“: Stufen wie in der Tabelle, „Automatisch“ als Vorgabe. Im Systemmenü ein neues Zeichen „Grafik“ in der Gruppe „Spiel“ (Antippen wechselt: Automatisch, Hoch, Mittel, Niedrig; Gedrückthalten erklärt).

**Berührt:** 698 (Spike baut); 1145 (Hakeln in der Höhle: die Messung am Gerät zeigt, welche Stufe dein A56 braucht, Spike); 623.8 A (Effekte Szene für Szene hängen an der Grafikstufe: Dorf am Abend 816 Tom, Wolfskampf und Höhle Jerry); 1270.1 (dein A56 nutzt womöglich einen Notfall-Darstellungsmodus, dort wirkt manches anders, Spike).

**Begründung:** Deine Messung vom 15.11. zeigt, dass die Grafikkarte begrenzt, nicht die Rechnung. Schatten und Bildschärfe entlasten die Grafikkarte am meisten; die Tuschelinie wird über das ganze Bild gezeichnet und kostet auch, sie ist aber die Signatur (`DESIGN-STIL.md` „Signatur“, 302) und bleibt darum.

**Sachverhalt:**
- Heute gibt es keine Grafikeinstellung für Spieler; die vier Messschalter im Reiter „Test“ (1145) gelten nur bis zum Neustart.
- Gekauftes Gras (804) und gekaufte Effekte (814) lassen sich schon heute abschalten, gebaut für 698; fehlt das Paket, bleibt es wie bisher.
- Sonnenschatten 4096 px mit weichem Filter Stufe 2 (`project.godot`) ist für Handys hoch angesetzt; draußen wirft nur die Sonne Schatten (`licht.gd`), drinnen Kamin, Fackel und Tageslicht (`raumlicht.gd`).
- Wie viel jede Zeile auf deinem A56 und dem A22 spart, ist noch nicht gemessen (1145 wartet auf die Messung am Gerät mit den Schaltern).

**Auswertung:**
- **A (Empfehlung):** Tabelle wie oben, Automatisch als Vorgabe. Bauen etwa eine Sitzung, dazu ein Bild je Stufe am selben Ort (Dorf am Abend, Höhle) zum Vergleich an dich, dann Testbitte.
- **B:** nur Hoch und Niedrig, ohne Automatisch. Weniger zu prüfen; aber wer ein mittleres Handy hat, muss zwischen hässlich und ruckelig wählen, und du wolltest den Leistungstest.
- **C:** in Niedrig auch die Tuschelinie aus. Spart am meisten; aber dann sieht das Spiel auf schwachen Handys nicht mehr nach uns aus.
- **Stärkstes Gegenargument gegen A:** ohne Messung am Gerät ist die Tabelle geschätzt; vielleicht spart „Mittel“ kaum etwas. Darum messe ich jede Stufe bei jedem Bau und am A22, und die Werte passe ich innerhalb der Zeilen an (z. B. 80 statt 85 %), ohne neue Zeilen.

**Folgerungen:** Nach „A“ baut Spike das Zeichen „Grafik“, die drei Stufen und Automatisch auf `claude/spike-698-grafikstufen`, misst je Stufe Grafikzeit in Dorf und Höhle, legt je Ort ein Bild Hoch gegen Niedrig vor und bittet dann zum Test. Bei B oder C ebenso mit der gewählten Tabelle.

Antwort: …
