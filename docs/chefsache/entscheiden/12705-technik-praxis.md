# 1270.5 · Welche Technik-Maßnahmen aus dem Abgleich mit fremder Praxis sollen in welcher Reihenfolge kommen?
Sokrates · 18.11., 10:48 · E Technik · aus deinem Wort 09:53/09:56 („mal bei anderen gucken … wie zaubern andere ihre Effekte, wo optimieren sie ihre Engine“)
Kurz: Erst messen, wo das Tablet die Zeit verliert, dann gezielt bauen; der Schattenfehler sofort.
Beim Chef, weil: Aussehen (Texturkompression, fernes Laub, Tusche) und neue Richtung im Spielgefühl (Bildrate fest 30)

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/05d2d54d2/docs/LISTE-TECHNIK-PRAXIS.md

**Frage:** Spike hat unsere ganze Technik gegen das gehalten, was Godot, Qualcomm, Arm, Unity, Unreal und Effektkünstler empfehlen, und neun Maßnahmen nach Gewinn für schwache Geräte gereiht. Ausgang ist deine Tabletmessung vom 17.11.: 10 Bilder je Sekunde im Flüsterwald auf Niedrig; Tusche, Lampen, Nebel und Schatten zusammen aus brachten nur 11. Die Grafikkarte ist der Engpass, nicht der Prozessor und nicht die Zahl der Dreiecke. Willst du die Reihenfolge unten?

**Votum:** „1270.5 A“: Messrunde zuerst (Nr. 1), Schattenfehler sofort (Nr. 6), dann Texturen und Laub nur mit Vergleichsbild in Spielkamera und Handygröße (Nr. 2, 3), Bildrate fest 30 ja (Nr. 5); Tusche, halbe Rechengenauigkeit und Hintergrundladen erst, wenn die Messung sie verlangt.

**Berührt:** Spike (Bau, Messung), 1484a (Welt in Zellen, Laub baut darauf), 1645 (Schattenkarte nach dem Kampf, Einstufung Perikles), 1270.4 (Glühen ab Hoch, entschieden), 1145 (Schalter), dich (eine Tabletmessung).

**Begründung:** Jede Gewinnzahl in der Liste ist geschätzt; für den Grafikchip des Tablets (Adreno 619) nennt keine Quelle eigene Werte. Was gebaut wird, soll sich an einer Messung entscheiden, nicht an Schätzungen. Die Messung kostet fast nichts, weil die Schalter schon im Testmenü stehen.

**Sachverhalt:**
- Tablet 17.11., 21:29: Grafikzeit 99 ms, Rechenzeit 2 ms; Effekte aus: 87 ms bei halben Dreiecken, 11 Bilder je Sekunde (Liste Spike, „Was die Messung schon sagt“).
- Nachgesehen: `kampf/kampfort.gd` setzt beim Verlassen die Schattenkarte auf den Projektwert von 4096 Bildpunkten, die Grafikstufe Niedrig will 1024 Bildpunkte (`skripte/grafik.gd` `SONNE_PX`). Fehler, kein Geschmack.
- Nachgesehen: `skripte/gebiet.gd` lädt `.bild` als PNG und packt glTF-Bilder in `mip()` sogar aus (`img.decompress()`); die Kompression im Projekt (`import_etc2_astc`) greift für diese Wege nicht.
- Glühen gibt es nach 1270.4 ohnehin erst ab Hoch; Spikes Vorschlag „Lichthof statt Glühen“ spart auf dem Tablet (Niedrig) also nichts.
- Godot steht bei uns schon auf 4.7.2; der Rat „Godot aktuell halten“ ist erfüllt.

**Auswertung:** je Maßnahme Votum und stärkstes Gegenargument.
1. **Messrunde: 3D-Auflösung 50 gegen 70 %, Renderer Kompatibilität gegen „mobile“** · Ja, zuerst. Steigt die Bildrate mit weniger Bildpunkten deutlich, liegt es an den Kosten je Bildpunkt, und Nr. 2 und 3 treffen. · Gegen: die Kompatibilitäts-Fassung kann anders aussehen (Tusche braucht die Tiefe, 348.5); als Messung harmlos, ein Wechsel im Spiel wäre eine neue Vorlage mit Bild. · Dazu von mir (fehlt in der Liste): Spike schaut am Rechner mit Godots Überzeichnungs-Ansicht in den Wald, bevor du misst; das zeigt ohne Tablet, wie oft jeder Bildpunkt gemalt wird.
2. **Texturen komprimiert** · Ja, nach der Messung. Spart Bandbreite und etwa drei Viertel Grafikspeicher (heute 615 MB), das hilft auch gegen Abstürze beim Ortswechsel (680). · Gegen: Kompression macht Farbsäume, gerade an harten Kanten im Zeichenstil; deshalb nur mit Vergleichsbild alt gegen neu.
3. **Laub ohne Durchsicht in der Ferne, Reihenfolge der Stoffe** · Ja, nach Nr. 1, auf 1484a (Welt in Zellen). Laut Qualcomm schaltet die Durchsicht das frühe Verwerfen ab, bis zu viermal Füllrate. · Gegen: 1484a (Welt in Zellen) selbst ist noch nicht auf dem Gerät geprüft; ferne deckende Blattkarten können als Klötze wirken. Vergleichsbild.
4. **Tusche billiger (etwa halbe Auflösung)** · Nein, jetzt nicht. Gemessen nur 4 von 99 ms, und die Tusche ist unsere Signatur. · Gegen mein Nein: auf Kachel-Grafikchips kostet jeder Vollbild-Durchgang Bandbreite, das kann nach Nr. 2 und 3 der nächste Engpass sein. Dann neu vorlegen.
5. **Bildrate fest 30** · Ja. Auf dem Tablet ohne Gewinn (unter 30), am A56 weniger Wärme und Akku, gleichmäßiger; Unity und Arm raten dazu. · Gegen: am A56 wirken Kamerafahrten mit 60 weicher. Für ein Spiel mit Rundenkampf wiegt Akku schwerer.
6. **Schattenkarte nach dem Kampf richtig (1645, Schattenfehler)** · Ja, sofort, Fehler. · Gegen: keins außer dem Bau; Perikles stuft 1645 (Schattenfehler) als Muss oder Kür ein, mein Votum Muss.
7. **Halbe Rechengenauigkeit in den Shadern** · Später. · Gegen: der Toon-Schnitt arbeitet mit harten Lichtstufen, dort zeigen sich Streifen zuerst; Gewinn unsicher.
8. **Ausgeblendete Leute und Tiere anhalten** · Ja, als Kür, Spike entscheidet die Art. · Gegen: der Prozessor ist nicht der Engpass, es spart nur Akku.
9. **Ortswechsel im Hintergrund laden** · Später. Dorf 10,6 s ist lang, aber der Umbau ist groß und fehleranfällig. · Gegen: Ladezeit ist das, was Spieler zuerst merken; nach Kapitel 1 als eigener Vorgang.
- Effekte (Bildfolgen für Feuer und Treffer, Zauber als bewegte Netze): als Idee an Jerry und Homer, kein Engpass belegt; jedes neue Effektbild ist Aussehen.
- **B:** alle neun auf einmal bauen lassen. Schneller fertig, aber ohne Messung weiß keiner, was gewirkt hat, und Aussehen ändert sich an drei Stellen zugleich.
- **Stärkstes Gegenargument gegen A:** die Messrunde kostet dich eine Tabletsitzung und einen Build mehr, bevor sich am Wald etwas bessert. Dagegen: ohne sie bauen wir womöglich an der falschen Stelle, wie die Probe „Effekte aus“ zeigte: halbe Dreiecke, nur 12 ms weniger.

**Folgerungen:** bei A: Spike baut Nr. 6 und die Messrunde (Überzeichnungs-Ansicht am Rechner, Schalter fürs Tablet) in einen Build, Testbitte an dich; mit dem Ergebnis legt Spike Nr. 2 und 3 mit Vergleichsbild vor; Nr. 5 baut Spike gleich mit; Nr. 4, 7, 9 als Kür bei Spike mit Bedingung „nach Messung“; Effektideen in `LISTE-IDEEN.md`. Drei Prüfpunkte für Spike: jede Zahl vorher und nachher am selben Ort und in derselben Stufe; Vergleichsbilder in Spielkamera und Handygröße (340.12); kein Wechsel des Renderers ohne neue Vorlage.

Antwort: …
