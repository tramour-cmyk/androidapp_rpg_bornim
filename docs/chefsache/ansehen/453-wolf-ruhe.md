# 453 · Ruhebewegungen der Wölfe im Kampf · Tuffy (Team Jerry) · 01.11., 12:06

[Film von 01.11., 12:05](https://cdn.jsdelivr.net/gh/tramour-cmyk/androidapp_rpg_bornim@bilder/2026-11/01-1205-453-Tuffy.mp4) (eingetragen von meldung.sh, Tuffy)

Film 31 s am Rechner mit dem gekauften Wolf, aus der Kampfkamera, noch kein Build: jede Bewegung nacheinander mit Namen oben, ohne Ton (Laute erst im Spiel). Zweig `claude/tuffy-453-wolf-ruhe`, baut auf 438 auf.

- **Messung vorher** (Prüflauf `wolf_ruhe_453`, zwei Kämpfe gegen das Rudel, Autopilot): die Wölfe ruhten zu 96 % geduckt („Hocke“); diese Hocke war beim gekauften Wolf ein einziges gehaltenes Standbild. 0 Ruhebewegungen, je Wolf 31–77 s ohne jede Regung.
- **Neu:** Hocke atmet und wendet langsam den Kopf (Ruhe C der Quelle, geduckt); Stehen atmet sichtbar; Umblicken links und rechts (Kopf hoch, ±40°); Knurren (tiefer, Kopf vor, Maul offen, mit Knurrlaut `idle_wolf_2`); Hecheln nach dem eigenen Biss (Maul offen, schnelles Atmen, Schnauben `idle_wolf_3`); Scharren mit der Vorderpfote, die zur Kamera zeigt (stehend). Im Kampf alle 3–7 s zufällig, nie zweimal dieselbe hintereinander, im Rudel höchstens ein Laut je 1,8 s.
- **Messung nachher:** je Wolf höchstens 5,5–7,0 s ohne Regung, 4–6 verschiedene Bewegungen; Pfoten bleiben fest (außer der scharrenden), keine neuen Befunde in den Wolfsprüfläufen.
- Bestand geprüft: gekaufter Wolf (Janpec) Ruhe A und C genommen; Ruhe B legt sich hin, Fressen senkt die Nase auf den Boden: beides nicht für den Kampf.

**Prüferbefund nach dem Versand (01.11., 12:11), wichtig:** Aus der Kampfkamera erkennt man nur Umblicken nach rechts (Kopf wandert 46 px bei 1080 Breite) und das Ducken in die Hocke. Atmen (±2 px), Knurren und Hecheln (Maul nicht zu sehen, das Zittern wirkt als 1-px-Flimmern wie ein Darstellungsfehler), Lefzen und Scharren (Pfote 12–26 px, auf dem Handy 1–2 mm) sind nicht als solche erkennbar; Umblicken nach links dreht den Kopf zur Kamera (20 px) und wirkt eulenhaft, Schnauze um 7,3 s in der Schulter; Stehen und Lefzen wirken wie ein Hund, der zum Halter aufschaut. Wechsel Hocke ↔ Stand in 0,13 s um 20 px (ruckartig). Stillstand vor jedem Wechsel und gleicher Takt aller drei Wölfe sind Eigenheiten des Prüffilms, nicht des Spiels. Pfoten rutschen nicht.
**Vorschlag r2:** alles deutlich größer (Umblicken ±60° mit Rumpf, Knurren Kopf tief vor und Maul 25°, Scharren längere Züge mit Erde, Atmen 3 cm), Zittern weg, Wechsel Hocke ↔ Stand weich in 0,4 s; Film zusätzlich nah am Wolf. Probeläufe 453: 1 von 2.

**Zu sagen:** „passt“ (fährt im nächsten gemeinsamen Build mit) oder was an Art, Stärke oder Häufigkeit anders sein soll.
