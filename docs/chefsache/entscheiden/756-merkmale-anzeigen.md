# 756 · Merkmale der Ausrüstung anzeigen: Vorlage jetzt oder nach 644 und 3.5? · Sokrates · 09.11., 14:28
E Oberfläche

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/main/godot/skripte/menue.gd

**Anlass:** Chef 14:23: „wie wollen wir denn die anderen Kategorien … bei der Ausrüstung, die ich anlegen kann, anzeigen lassen“ (Wortlaut `ARBEIT-BERATUNG.md`, Zu 756).

**Befund:** sichtbar sind heute Seltenheit (Rahmen, Namensfarbe, Wort), Zweihänder („2H“, rote Zeile), Platz, Stufe, Rüstungsart, Grundwerte, Zusatzeigenschaften. Güte und Zustand (BRS Abschnitt 11, 644 B) gibt es im Code noch nicht, auch nicht in der alten Fassung; Werkstoff, Gewicht, Sperren werden nicht gezeigt. Im Kasten stehen noch SRD-Wörter: „RK“, „+ GES (max 2)“, „Übungsbonus“, „Finesse“, „+1“.

**Vorschlag:**
1. **Bild** (Tasche, Ausrüstungsplatz), feste Stellen: Rahmenfarbe = Seltenheit; oben rechts „2H“; oben links Güte (nichts, ein oder zwei Goldpunkte); unten Zustandsbalken nur bei Abnutzung (gelb beschädigt, rot defekt, Bild entsättigt); nicht Tragbares abgedunkelt.
2. **Kasten** in fester Folge: Name in Seltenheitsfarbe; Seltenheit · Güte · Art; Platz · Stufe (ab Heldenstufe n) · Rüstungsart · Werkstoff; Zustand als Wort mit Folge; Grundwerte; Zusatzeigenschaften; Sperren rot; Gewicht, Wert.
3. **Langdruck** auf ein Merkmal: ein Satz Erklärung (Homer, `LISTE-GLOSSAR.md`).

**Stärkstes Gegenargument:** vier Zeichen auf 48 dp werden Brei. **Antwort:** höchstens drei zugleich, Balken erst bei Abnutzung; Probe als Standbild in Endform vor dem Bau.

**Frage:**
- **A (Empfehlung Sokrates):** jetzt Vorlage mit Standbild (Probe Team Tom), dazu sofort Sperren zeigen und SRD-Wörter ersetzen; Güte und Zustand kommen ins Spiel mit 644 und Abnahme 3.5.
- **B:** alles erst nach 644 und 3.5.
