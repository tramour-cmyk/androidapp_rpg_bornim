# 414: Godot-Pakete von itch.io: kaufen, probieren oder lassen?

**Frage:** Welche der 14 Pakete (Chef 31.10., 20:2x) sollen wir probieren oder kaufen? Gekauft wird nur auf deinen Befehl (CLAUDE.md „Fremde Inhalte“).
**Votum Sokrates:** Nichts jetzt kaufen (Oberste Direktive: Fehler ausmerzen, Kapitel 1 fertig). Gratis-Probe der Beams jetzt zulässig; Kür-Kandidaten nach Meilenstein; drei Pakete ausschließen.
**Berührt:** Kampf (Team Jerry), Figuren (Team Tom), `LISTE-IDEEN.md` (Handwerk), Lizenzliste je Datei.

## Befund (Seiten gelesen 31.10., 20:3x; nur was dort steht)

Für alle gilt: **Android/Handy ist nirgends getestet** (Desktop, teils nur Lauf der Renderer Mobile/Compatibility ohne Blick auf die Optik). Die volle Lizenz (LICENSE.md/.txt) liegt erst im Kauf; die Seiten zeigen nur Auszüge. Maßstab unserer Regel (348.12c: Verkauf in jeder Engine, unbefristet, ohne Nennung, ohne Umsatzgrenze) erfüllt keine Seite ausdrücklich; „Nennung erwünscht, nicht Pflicht“ und „keine Umsatzgrenze genannt“ ist das Beste, was vorkommt.

| Paket | Preis | Lizenz laut Seite | Godot | Eignung für uns |
|---|---|---|---|---|
| Physical Hit Reactions (dangalg) | 4,19 $ (Sale, sonst 5,99) | kommerziell ja, Weitergabe des Add-ons nein, Nennung egal | 4.4+ | Trefferreaktion mit Teil-Ragdoll auf humanoiden Skeletten. Passt zu Kampf. Jolt empfohlen, 120 Physik-Ticks empfohlen: Handy-Kosten unbekannt |
| Foot IK Grounder (dangalg) | 4,19 $ | wie oben | 4.4+ | Füße auf Stufen und Hängen, erkennt Quaternius-Skelette. Nutzen hängt davon ab, ob wir überhaupt Stufen und Hänge mit Figuren haben |
| Legged Walker Kit (dangalg) | 4,19 $ | wie oben | 4.4+ | Spinne, Mech, Vierbeiner. Für Kapitel 1 nur, wenn ein Vielbeiner vorkommt; Körper kinematisch, ohne Wegfindung |
| EffectBlocks (bukkbeek) | ab 9,99 $ | kommerziell ja, Pack nicht weitergeben | „4.x“, gebaut in 4.4, Nutzer meldet Fehler in 4.2 | 100+ Effekte (Feuer, Blitz, Magie, Wasser, Einschläge, Blut), stilisiert Low-Poly. Größter Umfang. Teile mit KI-Hilfe geschrieben (Seite) |
| Sci-Fi Effects (hovl) | ab 15 $ | **keine Angabe** | „4“ | Sci-Fi: passt nicht zu Bornim; Lizenz offen. Nein |
| Glowing Orbs Pack 1 und 2 (hovl) | je ab 15 $ | **keine Angabe** | „4“ | Leuchtkugeln, „für Handy geeignet“ (Selbstauskunft). Lizenz offen: erst beim Autor klären |
| Wardrobe Workshop (studio-yeol) | 2,99 $, Kern gratis | Kunst CC0, Code MIT; Quaternius | 4.6.3 | Dreht sich um Quaternius-Charakter in Browser-Werkbank, ZIP 431 MB, kein Spiel. Nur lehrreich als Vorbild, nicht als Baustein |
| Quest Log and Map Kit (juliusschmidt) | 1,79 $ (Sale) | kommerziell ja, Dateien nicht weitergeben | 4.3+ | Quests mit Schritten, Verzweigung, Zeitlimit; Weltkarte mit Nebel und Schnellreise. **Layout nur Querformat ab 1280×720, Maus/Tastatur/Gamepad, Touch nicht erwähnt.** Hat Landkarte nur als prozedurale Insel; unsere Landkarte ist gezeichnet |
| Inventory and Crafting Kit (juliusschmidt) | 1,79 $ (Sale) | wie oben | 4.3+ | Grid-Inventar, 6 Ausrüstungsplätze, Rezepte (.tres), Werkbank, Truhen. **Reparatur nicht enthalten, keine Haltbarkeit.** Touch nicht beschrieben |
| Beams & Lasers (reeboolabs) | 5,59 $ (Sale) | kommerziell ja, Nennung erwünscht, nicht unverändert weitergeben | 4.3+, getestet 4.3/4.4.1 | 22 Strahlen als 2D und 3D, darunter 5 Magie (Heiligstrahl, Leerestrahl, Heilband, Schallwelle, Prisma), Blitz, Feuerstrom. Shader und GPU-Partikel, Renderer Mobile/Compatibility **nur als Lauf geprüft** |
| Beams Free Sample (reeboolabs) | gratis | wie oben | 4.3+ | 3 Strahlen (Blauer Laser, Feuerstrom, Blitzbogen), 2D und 3D |
| Status Effects VFX (reeboolabs) | 5,59 $ (Sale) | wie oben | 4.4+, nur 4.4.1 geprüft | 23 Statuseffekte als Dauerschleifen (Gift, Frost, Blitz, Fluch, Blutung, Schlaf, Verwirrt, Spott, Segen, Rüstung …) plus 4 Einmaleffekte. Für 3D-Figuren 1,8 m; **Glow im WorldEnvironment nötig**, Optik auf Handy ungeprüft |
| Isometric Survival RPG Template (jdcrow) | ab 4,99 $ | **keine Angabe**, Fremdassets ohne Lizenzangabe | 4.3 | Ein ganzes Spiel (Basisbau, vier Klassen), 822 MB, „on hold“, Teile mit KI. Passt nicht, Lizenz offen. Nein |

## Auswertung

**Stärkstes Gegenargument gegen alles Kaufen:** Der Kampf hat noch eigene Effekte und Reaktionen (Jerry), Kapitel 1 ist nicht abgenommen; ein fremdes Paket bringt Einbau, Lizenzpflege je Datei, Stilbruch (stilisiertes Low-Poly gegen unseren gezeichneten Look, 373 Aussehen urteilt der Chef) und ungeprüfte Handy-Leistung. Was wir als Eigenbau schon haben, kauft man nicht zweimal.

**Stärkstes Argument dafür:** Die Preise sind klein (zusammen unter 30 $), die Pakete sind in GDScript ohne Plugins, und Statuseffekte, Magie-Strahlen und Trefferreaktionen sind genau die Stellen, an denen der Kampf lebendiger wird (Leitbild: Kampf nie langweilig).

**Reihenfolge, wenn du freigibst:**
1. **Beams Free Sample** (gratis): erst auf dem Handy messen, ob GPU-Partikel und Strahl-Shader laufen. Das beantwortet die Handyfrage für alle drei Reeboolabs-Pakete.
2. **Status Effects VFX** und **Beams & Lasers**: erst nach 1 und nur, wenn Jerry die Statusanzeige im Kampf (Gift, Schlaf, Spott usw.) tatsächlich vermisst.
3. **Physical Hit Reactions**: erst wenn die Figuren einen Rig haben, der passt, und der Kampf stabil ist. Foot IK nur, wenn die Karten Stufen und Hänge für Figuren haben (Tom: ja oder nein?).
4. **Inventory and Crafting Kit** als Vorbild für Idee „Herstellen und Reparieren“ (siehe unten): nicht als Baustein, weil Touch, Reparatur und Haltbarkeit fehlen und unser Inventar ohnehin eigene Regeln (SRD) braucht. Eigenbau, Kit höchstens zum Abgucken (1,79 $).
5. **Quest Log and Map Kit**: Antwort auf „Können wir das brauchen?“: **nicht als Baustein.** Ein Quest-Tagebuch bauen wir selbst, weil Layout, Touch und der gezeichnete Look fehlen. Als Abgucke für Datenmodell (Schritte, Zähler, Verzweigung) tauglich.
6. **EffectBlocks**: nur wenn Eigenbauten der Effekte nach Kapitel 1 nicht reichen; Stil gegen Leitbild prüfen.
7. **Nein:** Sci-Fi Effects, Glowing Orbs 1/2 (Lizenz offen), Isometric Template, Legged Walker, Wardrobe Workshop.

**Idee Herstellen und Reparieren (Chef 31.10.)** gehört nach `LISTE-IDEEN.md`: Tränke und Gegenstände herstellen und reparieren, an geeigneten Orten oder mit Stufe und Rezepten; nie Pflicht, kann Gold sparen (Leitbild: Grinden darf man, muss man nie). Prüfen steht an, bauen nicht.

## Folgerung

Bei „ja zu 1“: Vorgang für Team Jerry (Probe auf dem Handy). Kauf nur auf dein Wort und im privaten Zweit-Repo; Lizenz je Datei in die Lizenzliste, vorher die LICENSE.md des Pakets lesen.
