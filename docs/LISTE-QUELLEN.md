# Quellen fremder Inhalte (Ressourcenseite)

Vorgang 623, Sokrates, angelegt 07.11. (Chef 07.11., 17:2x: „Wir bräuchten einerseits eine Ressourcenseite und andererseits eine Zuordnungsseite. Dieses Schema sollten wir auf bisher geprüfte Internetseiten … und kommende Internetseiten anwenden.“). Hier steht **jede geprüfte Quelle** mit Link und Urteil nach dem Prüfschema. Was wir besitzen, steht in `LISTE-BESTAND.md`; wofür wir es im Spiel nehmen, in `LISTE-EFFEKTE.md` (Zuordnung). Modelle und Bewegungen der Umzugszeit stehen noch in `LISTE-CC0-MODELLE.md` und ziehen nach und nach hierher (623.1).

**Lizenzregel:** `CLAUDE.md` „Technik und Sicherheit“: kommerziell, in jeder Engine, unbefristet, ohne Pflicht zur Nennung, ohne Umsatzgrenze; gekaufte Rohdateien nur im privaten Repo `bornim-kaufmodelle`, nie im öffentlichen (dieses Repo ist öffentlich).

## Prüfschema (für jede Quelle, jedes Paket)

| Nr. | Frage | Wie geprüft |
|---|---|---|
| F1 | **Technisch tauglich?** Läuft es in unserer Godot-Fassung (4.7.2), im Renderer Compatibility auf dem Handy des Chefs (Samsung, ANGLE), mit unserer Signatur (Toon-Licht, Tusche, Schablone), in unserer Bildrate? | Seite (Godot-Fassung, Renderer); Gratisprobe im Kampfort oder auf der Karte; Bildrate am Gerät |
| F2 | **Lizenz tauglich?** nach der Lizenzregel oben; Weitergabe, Maskottchen, fremde Teile (MIT, CC-BY) | Lizenztext auf der Seite und `LICENSE.txt` im Paket |
| F3 | **Erspart es Arbeit?** | Schätzung Eigenbau in Sitzungen gegen Einbau |
| F4 | **Ersetzt es Gebautes und ist besser?** | Liste unseres Eigenbaus (Shader, Skripte, Vorgänge) |
| F5 | **Gute Anwendungsfälle im Spiel** | `LISTE-EFFEKTE.md`, Bestiarium, Zauberliste 2.17 |
| F6 | **Was drücken wir damit besser aus?** (düster, Wucht, Leben der Welt, Lesbarkeit im Kampf) | Leitbild, `DESIGN-STIL.md` |
| F7 | **Preis-Leistung** | Preis je nutzbarem Stück, Überschneidung mit anderen Paketen |
| F8 | **Weitere Fragen** (unten) | |

**F8, weitere Fragen, die wir uns stellen sollten:**
- **Haben wir es schon?** (`LISTE-BESTAND.md`, Überschneidung mit anderen Paketen: zahlen wir zweimal für dasselbe?)
- **Bricht es unseren Stil?** Glänzende, bunte oder Science-Fiction-Effekte passen nicht zu schwarz-gold und düster; nur Gold glänzt.
- **Wer pflegt es?** Ein Händler, der gestern veröffentlicht hat, kann morgen weg sein: Dateien sofort im privaten Repo sichern, Fassung notieren.
- **Was kostet es an Leistung?** Partikel, Durchsicht und Bildschirm-Lesen kosten am Handy; Messung, nicht Vermutung.
- **Wie fest binden wir uns?** Ein Paket mit eigenem Steuerknoten (Addon) bindet mehr als eine einzelne Shaderdatei.
- **Gibt es eine Gratisprobe?** Dann erst die Probe, dann kaufen (Regel 621 A: eine Probe je Thema).

## REEBOO Labs (geprüft 07.11.)

Händler: [reeboolabs.itch.io](https://reeboolabs.itch.io/). Alle Pakete: Godot 4.4 und neuer, getestet auf 4.4.1 unter Windows; Android nicht getestet. Lizenz aller elf gleichlautend: „Royalty-free for commercial and non-commercial games and apps“, ändern erlaubt, Nennung „appreciated, not required“, Weitergabe der Dateien verboten (auch geändert, auch in Paketen), Maskottchen „Oho“ nicht nutzbar. Unsere Gratisproben 415 und 572 liefen in Godot 4.7 und Compatibility (Archiv 02.11., 04.11.).

**Urteil:** ✓ ja · ~ mit Einschränkung · ✗ nein · ? ungeprüft. Preise in US-Dollar, Mindestpreis.

| Nr. | Paket | Preis | F1 technisch | F2 Lizenz | F3 Arbeit | F4 ersetzt Gebautes | F5 Anwendung (Auswahl) | F6 Ausdruck | F7 Preis-Leistung | Votum |
|---|---|---|---|---|---|---|---|---|---|---|
| R1 | [Combat VFX Mega Pack](https://reeboolabs.itch.io/godot-combat-vfx-mega) (106) | 19,99 | ✓ Compatibility genannt | ✓ | sehr viel | nichts Fertiges; MARS hat kaum Effekte | Treffer je Waffe, Hiebbögen, Parade, kritischer Treffer, Bodenstoß (Krogg), Auren (Elite, Boss) | Wucht und Lesbarkeit jedes Treffers | sehr gut (0,19 je Effekt) | **ja, Kern** |
| R2 | [Stylized Projectiles](https://reeboolabs.itch.io/stylized-projectiles-godot) (36) | 7,99 | ✓ | ✓ | viel | nichts | je Element Wirken, Flug, Einschlag: Feuer, Eis, Blitz, Arkan, Säure, Heilig, Leere, Erde, Wind, Natur → Zauber bis Stufe 6 (2.17) | jeder Zauber sichtbar aus einem Guss | sehr gut | **ja, Kern** |
| R3 | [Weapon & Motion Trails](https://reeboolabs.itch.io/godot-weapon-trails) (25) | 6,99 | ✓ (Compatibility im Browser gesehen) | ✓ | mittel | nichts | Spur der Klinge beim Hieb, **Pfeilspur des Spähers (601)**, Ansturm des Keilers, Ausweichen | Tempo und Wucht | sehr gut | **ja** |
| R4 | [Stylized VFX Pack 3](https://reeboolabs.itch.io/stylized-vfx-pack-3-godot) (24) | 6,99 | ~ Compatibility nur kurz angesehen | ✓ | mittel | nichts | **Blutsaugen (Drain Beam) beim Egel**, Blut-Treffer, Bodenriss, Felswurf, Geisterlichter, Todesstoß der Untoten, Kristalle der Höhle, **Federn beim Huhn (591)** | düster, Leben | gut (5 Stück Science-Fiction unnütz) | **ja** |
| R5 | [Character Shaders](https://reeboolabs.itch.io/godot-character-shaders) (15) | 6,99 | ~ nur als Zusatzschicht über unserem Material | ✓ | mittel | **Toon, Umriss, Randlicht nein**: unsere Signatur | Trefferblitz, Auflösen beim Sterben (Geister, Untote), Versteinern, Gefrieren, **Schatten des Spähers (566)**, Zielwahl leuchtet | Zustände am Körper lesbar | gut | **ja, nur Zusatzschicht** |
| R6 | [Beams & Lasers](https://reeboolabs.itch.io/godot-beams-lasers) (22) | 6,99 | ✓ (Probe 415 gesehen) | ✓ | mittel | nichts | Heiliger Strahl (Kleriker), Heilband, Leerenstrahl, Feuerstrom, Säurestrahl; 11 Stück Science-Fiction unnütz | Magie hat Gewicht | mittel (Überschneidung mit R1, 10 Strahlen) | ~ **nach R1 entscheiden** |
| R7 | [Stylized VFX Pack 2](https://reeboolabs.itch.io/stylized-vfx-pack-2-godot) (61, **enthält Pack 1**) | 20,00 | ? Compatibility nicht getestet (Pack 1 lief bei uns, 572) | ✓ | viel | Glühwürmchen (514) und Flamme bleiben eigen | Kaminrauch, Fackel, Lagerfeuer, fallendes Laub, Staub im Licht, Fußstaub, Wiederkehr im Tempel, Heilung, Frostnova, Betäubung | lebendige Welt, Rast | gut, **ersetzt den Kauf von Pack 1 (7 $) aus 415d.1** | **ja statt Pack 1** |
| R8 | [Weather FX 2D+3D](https://reeboolabs.itch.io/godot-weather-fx) (69) | 6,99 | ✓ (Regen, Schnee ohne Rechenlast je Teilchen) | ✓ | viel | nichts: Wetter gibt es noch nicht | Nebel im Tiefen Wald, Regen, Sturm mit Blitz, Blätter im Wind, Asche und Glut | Stimmung, düster, Abnahme 6 „Wetter je nach Ort“ | sehr gut | **ja, mit der Welt** (Wetter ist neues Spielgefühl: dein Wort) |
| R9 | [Grass & Wind Kit](https://reeboolabs.itch.io/godot-grass-wind) | 6,99 | ✓ | ✓ | mittel | unser Gras (`halm.gdshader`) wiegt schon; neu: **Gras weicht dem Helden aus**, Böen, ein Wind für alles | Flüsterwald, Weizenfeld (612), Wind gleich für Gras, Bäume, Klang (598) | Welt reagiert auf den Helden | sehr gut | **ja; Chef 07.11.: „sah schon wirklich sehr gut aus“, darf unser Gras ersetzen (Probe)** |
| R10 | [Water Shader Kit](https://reeboolabs.itch.io/godot-water-kit) (35) | 7,99 | ~ Spiegelung und Lichtbrechung am Handy fraglich | ✓ | mittel | unser Fluss (`wasser.gdshader`, wie alt, dunkel) bleibt; neu nur, was fehlt | **Teich der Höhle (507)**, Teiche mit Regenringen, Wasserfall, später Sumpf und Lava | Wasser lebt | gut | **ja; Chef 07.11.: Fluss „ernsthaft etwas besser“, darf unseren ersetzen (Probe am Dorfbach)** |
| R11 | [Stylized Surface Shaders](https://reeboolabs.itch.io/godot-surface-shaders) (30) | 19,99 | ? Compatibility nicht getestet; Gratisprobe mit 4 Shadern | ✓ (MIT-Teil genannt) | mittel | Boden bleibt eigen (Signatur) | Glühende Runen (Steinkreis, Tempel), Moos, Schlamm, Pfützen, Säureschleim der Schnecke, Fels der Höhle, Fahne im Wind | Orte bekommen Stoff | mittel | **erst Gratisprobe** |

**Summe aller elf:** 117,90 $. **Nicht in der Liste, aber zu wissen:** Status Effects VFX (6,99, 23 Zustände; schon in 415d.1), [AoE Telegraphs](https://reeboolabs.itch.io/) (9 Formen, Ansage von Flächenangriffen im Ring), Loot & Pickup VFX (Beute). Klangpakete des Händlers prüfen wir nicht: Klang kommt aus echten Aufnahmen (`DESIGN-LEITBILD.md` 6).

**Allen gemeinsam (F1, F2):** Android ungetestet, Godot 4.5 und neuer ungetestet (wir haben 4.7.2; die Proben liefen); Dateien nie in dieses öffentliche Repo, der Bau holt sie aus dem privaten.

## Werkzeuge: Blender und Godot (aus `alt/LISTE-GRAFIKWEG.md`, 650.1)

Beide kostenlos, auch für den Verkauf; was wir mit Blender bauen, gehört uns (die Lizenz von Blender gilt nicht für unsere Modelle). Godot: MIT-Lizenz (Version 4.7.2, geprüft 24.10.).
