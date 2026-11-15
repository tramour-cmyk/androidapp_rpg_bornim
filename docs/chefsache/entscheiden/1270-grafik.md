# 1270 · Welche ungenutzten Möglichkeiten von Godot sollen wir für Tempo und Aussehen nutzen?
Sokrates · 15.11., 10:27 · E Technik · aus deinem Wort 10:22 und 10:26 („nachhalten, zeitnah nochmal vorlegen“)
Kurz: Vier Tempo-Hebel ohne neues Aussehen, drei für das Aussehen als Probe; Bau nach dem Umzug.
Beim Chef, weil: Aussehen (Punkte 5 bis 7) und Code auf `main` (Punkte 1 bis 4, Prüfart Messung am Handy)

Geprüft an: [Stand `994049df0`](https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/994049df0/godot) (Suche im Code am Rechner, kein Lauf)

**Frage:** Sollen wir die sieben Godot-Möglichkeiten nutzen, die wir heute nicht nutzen, und welche zuerst?

**Votum:** „1270 A“: Punkte 1 und 4 als erste (schneller, kein neues Aussehen), vorher Ladezeit eines Kampfs am Handy messen; Punkte 5 und 7 als Vergleichsbild alt gegen neu an dich; 2 und 6 danach; 3 entfällt. Bau ab dem Ende des Umzugs (870.13).

**Berührt:** Team Jerry (Figuren, Kampfort), Team Tom (Dorf, Innenräume, Laden), Homer (Stil, Signatur), 1268 (Messung Bildrate), 1215 (Jolt-Physik, läuft schon).

**Begründung:** Du: „damit das ganze Spiel effizient und grafisch ansprechend dargestellt werden kann“. Schneller zuerst, weil es das Aussehen nicht ändert und am Handy jeder spürt.

**Sachverhalt (was wir nutzen):** Mobile-Renderer, Texturen komprimiert (150 von 152), eigene Tusche-Shader (28), Nebel, Farbkorrektur, wenige Partikel; Jolt in Messung (1215).
**Sachverhalt (was fehlt):**
- **(1)** Figuren und Kampfort-Wald werden bei jedem Kampf aus der Modelldatei neu gebaut (`figur.gd` 542, 788; `kampfort.gd` 360), weil die gekauften Modelle verschlüsselt liegen (Lizenz) und erst zur Laufzeit entschlüsselt werden (`figur.gd` 404). Abhilfe ohne Lizenzfrage: einmal je Spielstart lesen und im Speicher behalten.
- **(2)** Kein Laden im Hintergrund (nirgends `load_threaded_request`).
- **(3)** Keine Sichtweite, Detailstufen oder Verdeckung (0 Treffer `visibility_range`, `OccluderInstance3D`). **Entfällt** (Einwand des Chefs 10:41, nachgesehen): die Kamera zeigt von oben ohne Fluchtpunkt 9 bis 11,8 m Bildbreite (`kamera.gd` 6–8, 35), was außerhalb liegt, lässt Godot ohnehin weg; Detailstufen sparen nur bei Ferne, die es nicht gibt. Bleibt zu messen in 806: Schattenweite 20 bzw. 40 m (`licht.gd` 83, `signatur.gd` 44) gegen die Bildbreite.
- **(4)** Shader-Vorbau beim Export nicht eingestellt (`export_presets.cfg`); erster Zauber oder Effekt kann kurz hängen. Ob unsere Godot-Fassung es kann, prüft das Team vorher.
- **(5)** Glühen der Umgebung aus (Gold, Fackeln, Zauber).
- **(6)** Keine Abziehbilder (Blut, Brandspuren, Risse am Boden).
- **(7)** Kein vorberechnetes Licht (Innenräume, Höhle).
- Nicht geeignet: Echtzeit-Lichtverteilung, Raumschatten, Spiegelungen; der Mobile-Renderer kann sie nicht oder zu teuer.

**Auswertung:**
- **A (Empfehlung):** wie Votum. Kosten geschätzt: Messung 5 $, (1) 10 bis 20 $, (4) 5 $, je Vergleichsbild 5 bis 10 $; (2), (6) je 10 bis 25 $, Schätzung.
- **B:** nur Tempo (1 bis 4), Aussehen bleibt, wie es ist.
- **C:** alles nach „Kapitel 1 fertig“.
- **Stärkstes Gegenargument gegen A:** 5 bis 7 können mit der Tusche zusammenstoßen, die ihr eigenes Licht rechnet; ein Glühen kann den schwarz-goldenen Stil billig wirken lassen. Darum nur als Probe, gebaut wie später, und dein Urteil am Vergleichsbild.

**Folgerungen:** A: 1270.1 Messung Ladezeit (Jerry), 1270.2 Modelle im Speicher (Jerry), 1270.3 Shader-Vorbau (Tom), Vergleichsbilder Glühen und Höhlenlicht (Jerry, Homer sieht vorher auf Stil); Perikles ordnet hinter „Kampf passt“; Sokrates hält nach. B: nur 1270.1 bis 1270.3. C: 1270 ruht bis Meilenstein 1.

Antwort: …
