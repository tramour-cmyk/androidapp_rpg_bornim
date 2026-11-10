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

**Gekauft 09.11. (Chef, 623):** R1, R2, R8, R9, R10, R11 und Status Effects VFX (76,93 $; Dateien und Lizenzen in `LISTE-BESTAND.md` „Effekte“). **Gekauft 09.11., 21:05:** R3, R4, R7 (33,98 $; hochgeladen 21:07, `LISTE-BESTAND.md` „Effekte“). Zusammen 10 Pakete, 110,91 $. **Zurückgestellt (Chef 21:08):** R5, R6 (`LISTE-IDEEN.md` „Welt“).

**Summe aller elf:** 117,90 $. **Nicht in der Liste, aber zu wissen:** Status Effects VFX (6,99, 23 Zustände; schon in 415d.1), [AoE Telegraphs](https://reeboolabs.itch.io/) (9 Formen, Ansage von Flächenangriffen im Ring), Loot & Pickup VFX (Beute). Klangpakete des Händlers prüfen wir nicht: Klang kommt aus echten Aufnahmen (`DESIGN-LEITBILD.md` 6).

**Allen gemeinsam (F1, F2):** Android ungetestet, Godot 4.5 und neuer ungetestet (wir haben 4.7.2; die Proben liefen); Dateien nie in dieses öffentliche Repo, der Bau holt sie aus dem privaten.

## Alle Quellen im Bestand (623.1, Sokrates 09.11.)

Eine Zeile je Quelle, die wir nutzen oder gekauft haben; was wir davon haben, steht in `LISTE-BESTAND.md`, der Nachweis je Datei für Klang in `tools/klang/QUELLEN.md`, für Schriften in `tools/schrift/QUELLEN.md`. Gesucht und verworfen: unten „Gesucht und geprüft 26.–29.10.“. F2 = Lizenz nach der Lizenzregel oben; „fehlt“ = steht in keiner Datei.

| Quelle | Link | Lizenz | bezahlt | wofür | F2 |
|---|---|---|---|---|---|
| Quaternius: Universal Animation Library 1 (Pro, Standard, Source) | https://quaternius.itch.io/universal-animation-library | CC0 | Pro 9,99 $ (Chefsache 348.12b), 26.10., 13:36 (Stufe 1); Source liegt mit im Bestand, Preis fehlt | Bewegungen, Gerüst 65 Knochen | ja |
| Quaternius: Universal Base Characters (Source) | https://quaternius.itch.io/universal-base-characters | CC0 | etwa 20 $, 27.10. | Körper, Köpfe | ja |
| Quaternius: Modular Character Outfits – Fantasy (Source) | https://quaternius.itch.io/modular-character-outfits-fantasy | CC0 | 20 $ (Source laut Seite), 27.10. | Trachten (Krogg, Grak) | ja |
| Quaternius: Medieval Village MegaKit, Stylized Nature MegaKit, Fantasy Props MegaKit (Standard) | https://quaternius.com/packs/medievalvillagemegakit.html, https://quaternius.com/packs/stylizednaturemegakit.html, https://quaternius.com/packs/fantasypropsmegakit.html | CC0 (Seiten geprüft 09.11.) | frei | Raumteile, Einrichtung, Steine | ja |
| Protofactor: Animset Wizard | https://assetstore.unity.com/packages/3d/animations/animset-wizard-208236 | Unity Asset Store EULA | 19,98 $, 27.10., 21:10 | Zauber | ja (Protofactor schriftlich 10.11., 04:48, unten 1) |
| Protofactor: Animsets Sword & Shield, 1 Handed, 2 Handed, Bow & Arrow, Injured | https://assetstore.unity.com/packages/3d/animations/animset-sword-shield-207043, https://assetstore.unity.com/packages/3d/animations/animset-1-handed-melee-weapon-195757, https://assetstore.unity.com/packages/3d/animations/animset-2-handed-melee-weapon-197400; Bow & Arrow und Injured: Store-Nummer fehlt, Herstellerseite https://protofactor.biz/product-category/3d-game-models/animations/ | Unity Asset Store EULA | zusammen etwa 110 $ (24,99 + 19,98 + 19,98 + 24,99 + 19,98 laut Chefsache 348.12c), 01.11., 12:03 | Schwert, Schild, Bogen, Verletzt | ja (Protofactor schriftlich 10.11., 04:48, unten 1) |
| Protofactor: Riesenratte | https://protofactor.biz/product/giant-rat/ | Protofactor EULA | 14,99 $, 26.10., 13:36 (Stufe 1; Warenkorb gab 10 % Nachlass) | Riesenratte | ja |
| Protofactor: Darkness Spider, Skeleton Knight, Barghest, Giant Slug | https://protofactor.biz/product/darkness-spider/, https://protofactor.biz/product/skeleton-knight/, https://protofactor.biz/product/barghest/, https://protofactor.biz/product/monster-giant-slug/ | Protofactor EULA | 19,99 + 24,99 + 19,99 + 24,99 = 89,96 $ (Stand 03.11., 08:54), 03.11., 15:40 | Riesenspinne, Skelett, Grabhund, Säureschnecke | ja |
| Janpec: Animal Pack Deluxe (erste Fassung, nicht v2) | https://assetstore.unity.com/packages/3d/characters/animals/animal-pack-deluxe-99702 | Unity Asset Store EULA | 5 $, 26.10., 13:36 (Stufe 1) | 25 Tiere, Wolf, Wildschwein, Bärenkopf (Krogg) | **offen** (unten 1, 780) |
| RenderHub: MadeCG Low Poly Animated Centipede | https://www.renderhub.com/madecg/low-poly-animated-centipede | RenderHub Extended Use | 14 $ (Rabatt), 26.10., 13:41 | Hundertfüßer | ja |
| RenderHub: wernerkurt Evil Undead, Game Ready Studios Mobile Leeches Collection | https://www.renderhub.com/wernerkurt/evil-undead, https://www.renderhub.com/game-ready-studios/mobile-leeches-collection | RenderHub Extended Use | 21 $ (statt 35) und 17,99 $ laut Chefsache 03.11., 08:54; bezahlter Betrag fehlt; 03.11., 15:40 | Wiedergänger, Riesenegel | ja |
| RenderHub: MagicCGI Medieval Market Asset Pack | https://www.renderhub.com/magiccgistudios/medieval-market-asset-pack | RenderHub, Lizenz auf der Seite ungeprüft | frei | Brunnen | **offen** |
| RenderHub: Animated3D Leopard Hybrid A2 | https://www.renderhub.com/animated3d/leopard-hybrid-a2 | RenderHub Extended Use, Volltext geprüft 10.11. (kommerziell, Spiele, unbefristet, ohne Nennung, nicht weitergeben) | frei, 28.10., 16:38 | Idee ab Kapitel 2 (Begleiter, `LISTE-IDEEN.md`) | **offen** |
| rubberduck: Vampire Bat (OpenGameArt) | https://opengameart.org/content/vampire-bat-animated | CC0 | frei | Riesenfledermaus | ja |
| Omie's Assets, Anker's Assets, Avramania (frei), PolyMech (itch) | https://omies-assets.itch.io/3d-medieval-weapon-pack, https://ankersassets.itch.io/low-poly-medieval-weapons, https://avramania.itch.io/weapons-shields, https://polymech.itch.io/medieval-pack-low-poly-shields | CC0 | Omie 1,99 $, übrige frei; 29.10. | Waffen, Schilde | ja |
| REEBOO Labs | oben | eigene, ohne Nennungspflicht | 76,93 $, 09.11.; R3, R4, R7 33,98 $, 09.11., 21:05 | Effekte | ja; MIT-Teil unten 2 |
| Klang: Kenney, OpenGameArt- und Freesound-Urheber, BigSoundBank, VSCO 2 CE | `tools/klang/QUELLEN.md` | CC0 | frei | Klänge, Musik | ja |
| Schriften: EB Garamond, Alegreya, Cinzel, IM Fell, Fondamento | `tools/schrift/QUELLEN.md` | OFL 1.1 | frei | Schrift | ja |
| Blender, Godot, fontTools | https://www.blender.org, https://godotengine.org, https://github.com/fonttools/fonttools | Blender GPL (gilt nicht für unsere Modelle), Godot MIT, fontTools MIT | frei | Werkzeuge | ja (Godot im Spiel genannt, 497) |

**Lücken und Widersprüche (zur Klärung):**
1. **Unity Asset Store:** unten „Ausrüstung genau“, „Lizenzrahmen“ sagt „Unity Asset Store nein“ (2.2.1 verbietet Assets als Eingabe für KI-Programme), unten „Gegen Geld“ nennt ihn zulässig; gekauft wurden danach Protofactor-Animsets und Janpec unter dieser EULA. Ob unsere Arbeitsweise (KI-Sitzungen bearbeiten die Dateien mit Skripten) darunter fällt, ist eine Rechtsfrage für den Chef; Weg: Zustimmung der Händler einholen (780 A, Brief `tun/780`). **Protofactor (alle sechs Animsets) 10.11., 04:48**, Antwort an info@bornwire.de auf die Anfrage vom 09.11. (beschrieben: KI-Assistenten führen Skripte auf den Dateien aus, Übertragen, Vorschaubilder, Import; kein Training, keine Weitergabe): „Looks like the license already covers that usage.“ Das ist die schriftliche Aussage des Anbieters, dass unsere Nutzung erlaubt ist; E-Mail bewahrt der Chef auf (nicht ins Repo). Janpec offen.
2. **MIT-Teil in REEBOO** (David Hoskins, Hashfunktionen in Grass, Water, Surface): MIT verlangt den Lizenzhinweis; die Lizenzregel sagt „ohne Pflicht zur Nennung“. Lösung: Hinweis in „Über das Spiel“ wie bei Godot (497).
3. Links, Preise, Daten nachgetragen 09.11. aus Chefsache-Dateien in Git und den Seiten. Noch offen: Store-Nummer Bow & Arrow und Injured; bezahlter Betrag bei Nachlässen (Ratte, Protofactor 03.11., RenderHub 03.11.) steht nur in den Belegen des Chefs; Preis UAL Source; Lizenz Medieval Market auf der Seite. `reebo0.itch.io` in `LISTE-BESTAND.md` ist der alte Name des Händlers und leitet auf `reeboolabs.itch.io` um (geprüft 09.11.); `LISTE-EFFEKTE.md` steht noch auf „Vorschlag“ und nennt nicht gekaufte R3–R7.
4. Schriften: Kopf von `tools/schrift/QUELLEN.md` sagt „kein Reserved Font Name“, die Zeile Fondamento nennt einen (OFL erlaubt Nutzung, verbietet nur geänderte Fassungen unter dem Namen).

## Werkzeuge: Blender und Godot (aus `alt/LISTE-GRAFIKWEG.md`, 650.1)

Beide kostenlos, auch für den Verkauf; was wir mit Blender bauen, gehört uns (die Lizenz von Blender gilt nicht für unsere Modelle). Godot: MIT-Lizenz (Version 4.7.2, geprüft 24.10.).

## Gesucht und geprüft 26.–29.10. (Modelle, Bewegungen; 348.12)

Bis 09.11. eigene Datei `LISTE-CC0-MODELLE.md` (650.2 C2, Verlauf in Git). Suchergebnisse, Kaufkandidaten und Verworfenes vor dem Prüfschema; was davon gekauft ist, steht oben unter „Alle Quellen im Bestand“ und in `LISTE-BESTAND.md`. Entschiedenes im Vorgangsarchiv. Nie: CC-BY-NC, CC-BY-ND, „nur privat“.

### Stand 26.10.

| Was | Stand | Quelle |
|---|---|---|
| Skelett Menschen (alle Völker) | übernommen: Gerüst der Universal Animation Library, 65 Knochen; Zwerg, Halbling, Elf, Halbork über Knochenlängen | Archiv 348.12 (25.10., 23:33); `LISTE-UMZUG-348.md` Punkt 4 |
| Körper und Kleidung | bleiben unsere eigenen (`held3.py`); der fremde Grundkörper ist rundlich, großer Kopf, passt nicht zu „düster, erwachsen“ | Chefsache 34812-cc0 in Git |
| Bewegungen Menschen | Freifassung im Einsatz (Stehen, Gehen, Rennen, Fackel); Stich, Ausweichen, Abwehr bauen wir selbst | `LISTE-UMZUG-348.md` Punkt 5 |
| Goblin, Grak, Zombie | noch auf eigenem Skelett (`rig.py`); Probe: ein Goblin aufs CC0-Gerüst, wenn Schamane, Kobold und Späher fertig sind; ist er besser, folgen Grak und Zombie | Archiv 348.12 (26.10., 11:33), an Jerry |
| Tiere, Monster | eigenes Skelett je Bauart (Vierbeiner, Vogel, Insekt, Spinne); Suche nach CC0-Modellen (unten) | Archiv 348.12a (26.10., 11:40) |
| Pro-Fassung der Bewegungen | gekauft vom Chef (Vorgangsarchiv 348.12c) | – |

### Bewegungen: Universal Animation Library (Quaternius)

Quellseite: <https://quaternius.itch.io/universal-animation-library>. Lizenz laut Seite: „Creative Commons Zero v1.0 Universal“; die Lizenzdatei im Paket prüft `tools/blender348/v3/cc0_laden.sh`.

| Fassung | Preis | Inhalt |
|---|---|---|
| Standard | frei | 43 Bewegungen im Paket (die Seite nennt 45), etwa 15 MB |
| Pro | ab 9,99 $ | „120+“ Bewegungen, FBX und GLB, auch für Godot; welche genau, sieht man erst nach dem Kauf |
| Source | ab 14,99 $ | dazu die Blender-Datei; brauchen wir nicht |

**Freifassung, ausgelesen 26.10.:**
- **Stehen:** Idle, Idle_Talking, Idle_Torch, Sword_Idle; dazu Sitzen (Ansatz, Halten, Reden, Aufstehen), Hocken (Stand, vorwärts), Tanzen.
- **Fortbewegung:** Walk, Walk_Formal, Jog, Sprint, Sprung (Ansatz, Flug, Landung), Rolle, Schwimmen, Schieben.
- **Kampf:**
  - Sword_Attack, Punch_Jab, Punch_Cross
  - Zauber in vier Teilen (Ansatz, Halten, Wurf, Ende)
  - Hit_Head, Hit_Chest, Death01
- **Sonst:** Interact (Benutzen), PickUp_Table, Fixing_Kneeling.
- **Unbrauchbar:** 7 von 43, nämlich sechs Pistolenbewegungen und das Fahren.
- **Im Spiel (26.10.):**
  - Jede Person hat eine Stehbewegung (5 von 13 Idle_Talking, sonst Idle) und eine Gehbewegung (3 förmlich, sonst normal).
  - Dazu kommen eigene Armhaltungen über der Bewegung: Hände vorn gefaltet, Hände auf dem Rücken, Stab, Last auf der Schulter, Daumen am Gürtel.

**Was fehlt:** Abwechslung, nämlich mehrere Stehvarianten, Gesten (Hände in die Hüfte, Arme verschränken), mehrere Angriffe je Waffe und eigene Treffer und Tode (Chef 26.10., 11:42).

### Bewegungen gegen Geld: Protofactor-Animsets (385, Chef 27.10., 20:52–20:59)

Chef: „Zauberer, den finde ich genial“; „ziemlich gut und weich und geschmeidig und für fast alle Situationen. Aber halt Mensch“; „wenn das technisch nutzbar ist für uns“. Alle: Bewegungserfassung (Motion Capture), Unity „Mecanim Humanoid“, Lizenz Standard Unity Asset Store EULA (andere Engines erlaubt; KI-Klausel siehe „Lücken und Widersprüche“ 1 oben), Single Entity. Inhalte aus den Store-Seiten, im Browser gelesen 27.10., 20:5x (Sokrates; ein Helfer sah per Abruf nur leere Beschreibungen); Preise in $ ohne Steuer (Chef sah den Zauberer für 18,39, wohl Euro mit Steuer). Liste aller 24 Sets: Store-Suche „animset“, Anbieter Protofactor (Chef 21:00).

| Set | $ | Inhalt laut Seite | wofür bei uns |
|---|---|---|---|
| Wizard | 19,98 | über 100: Stehen, Gehen, Ducken, Rennen, Zauber, Treffer, Tod | Magier, Kleriker, Goblin-Schamane |
| Sword & Shield | 24,99 | ungelesen | Kämpfer, Jorin (Schildabwehr fehlt in der UAL) |
| 1 Handed Melee Weapon | 19,98 | ungelesen | Kämpfer, Schurke, Goblins (Stich fehlt in der UAL) |
| 2 Handed Melee Weapon | 19,98 | ungelesen | Krogg (Morgenstern), Grak |
| Dual Swords | 24,99 | 185: Stehen, Gehen, Rennen, Ducken, Angriffe, Treffer, Parade | Schurke |
| Bow & Arrow | 24,99 | ungelesen | Goblin-Späher, Waldläufer |
| Campfire | 14,99 | 25: Stehen, Feuer anzünden, Rasten, Schlafen; dazu Lagerfeuer und Spieß | Garrick, Rast im Wald |
| Crowd | 34,99 | ungelesen | Dorfleben |
| Injured | 19,98 | ungelesen | Verwundete (72c) |
| Female Basic Locomotion | 19,98 | ungelesen | Frauen im Dorf |
| Zombie | 19,98 | 56 (20 mit Wurzelbewegung): Stehen, Gehen, Angriff, Fressen, Treffer, Tod | Untote; Wiedergänger hat eigene 34 (348.12c) |
| vielleicht | 9,99–24,99 | Basic Locomotion, Fencing, Combat Bare Fists, Creature, Hostage | Raufen in der Schänke, Lyra verschleppt |
| nicht | 19,98–29,99 | Climbing, Push & Pull Cube, sechs Schusswaffen-Sets | – |
| Ultimate Animation Collection | 259,99 | alle 24 Sets, über 2.400 Bewegungen | die zehn oben zusammen kosten einzeln etwa 225 $ |

**Offen (technisch):** Übertragen von „Mecanim Humanoid“ auf unsere Körper in Godot (Kaufkörper 376.1, UAL-Gerüst, CC0-Goblin); erst an einem Set prüfen, dann mehr kaufen.

### Eigene Bewegungen: drei Wege

Das Gerüst gehört uns. Jede selbstgebaute Bewegung läuft darauf wie eine gekaufte (Chef 26.10., 11:47: „können wir die Bewegungen nicht selbst bauen … Garrick am Feuer …?“).

1. **Eigene Haltung über eine fremde Bewegung legen.**
   - Das ist billig und läuft schon. Die Bewegung liefert Atmen, Gewicht und Kopf, unser Skript setzt die Arme darüber (`leute.json` „arme“, `geruest.py`).
   - Beispiele: gefaltete Hände, Stab, Speer, Gürtel. Neue Haltungen wie „Hände in die Hüfte“ kosten eine Zeile je Person.
2. **Fremde Bewegung abwandeln.**
   - Garrick am Feuer: Sitzen oder Hocken, dazu Hände zum Feuer (Weg 1).
   - Rowena wischt: „Interact“ wiederholt.
   - Borin hebt den Becher: Sitzen, dazu ein eigener Arm.
3. **Ganz eigene Bewegung im Skript.**
   - So entstand vor dem CC0-Gerüst alles (`rig.py`: Gehen, Stehen, Rennen). Das kostet viele Runden.
   - Der Chef bemängelte: Das Rennen sei „nur beschleunigtes Gehen“, und im Stand zuckten die Figuren alle 3 bis 4 Sekunden.
   - Darum nur für das, was es nirgends gibt; schon festgelegt sind Stich, Ausweichen und Abwehr.

### Wirtschaftlich (Schätzung 26.10.)

**Grundlage:**
- Commits der Zweige `claude/tom-348-fundament` und `claude/jerry-348-kampf` seit 24.10., nach Bewegungswörtern gefiltert: Gehen, Rennen, Zucken, Schritt, Haltung, Hieb, Biss, Sprung, Tod und Ähnliches.
- Die Kosten je Sitzung aus `KOSTEN-GEBUCHT.tsv` sind nach dem Anteil der Bewegungs-Commits verteilt.
- Das ist eine Schätzung, keine Buchung.

| | Sitzungen | Kosten gesamt | davon Bewegung | Sitzungen überwiegend Bewegung |
|---|---|---|---|---|
| Tom | 79 | 685 $ | 160–190 $ | 24 (191 $) |
| Jerry | 82 | 644 $ | 80–90 $ | 11 (89 $) |
| **zusammen** | | | **240–280 $** | rund 35 |

**Gegenrechnung:**
- Pro kostet 9,99 $, das ist etwa eine Sitzung (rund 8 $).
- Ersetzt sie zwei selbstgebaute Bewegungen, hat sie sich bezahlt gemacht.
- Bei 120 Bewegungen, davon geschätzt 60–80 für uns brauchbar, ist der Hebel groß.

**Stärkstes Gegenargument:** Auch gekaufte Bewegungen kosten Anpassung. Ein guter Teil von Toms Kosten nach dem CC0-Wechsel war genau das:
- den Schritt unter langen Röcken dämpfen
- die gehaltenen Arme mitschwingen lassen
- die Füße am Boden halten

Diese Werkzeuge stehen jetzt, darum fällt die Anpassung kleiner aus. Pro spart also den teuersten Teil, die Natürlichkeit, aber nicht alles.

**Folgerung:** Das gesparte Guthaben geht in das, was nur wir können: Gesichter, Kleidung, Welt, Geschichte.

### Tiere und Monster: Suche (348.12a)

Auftrag des Chefs (26.10., 11:40): Hund, Katze, andere kleinere Tiere, die nicht kämpfen, vielleicht ein kleiner Drache, dazu alle Monster; nur CC0, „am Schluss kein Lizenzproblem“.

**Bekannt aus der Sichtung vom 25.10.** (Chefsache 34812-cc0 in Git):
- **Quaternius:** „Ultimate Animated Animals“ und „Animal Pack Vol. 2“ (unter anderem Wolf, Hund, Katze, animiert).
- **KayKit:** Abenteurer und Skelette, sehr niedlich, keine Tiere; Lizenz je Paket prüfen.
- **Kenney:** CC0, Höhlen- und Dorfbausteine, Tiere nur als Würfel.
- Wolf und Ratte stehen bei uns schon, auf eigenem Skelett.

**Suche 26.10.** (Helfer von Sokrates):
- Die Lizenz ist auf jeder Quellseite geprüft. Bei Quaternius ist zusätzlich die License.txt gelesen (Ultimate Animals, Farm, Animated Monsters, Easy Enemy, Ultimate Monsters: alle „CC0 1.0 Universal“).
- „[Bild]“ heißt: Das Vorschaubild ist gesehen; sonst stammt das Stilurteil nur aus der Beschreibung.
- **Bei Übernahme wird die Lizenz je Datei erneut geprüft und festgehalten.** Dreiecke nach dem Import zählen, denn die meisten Quellen nennen keine.

#### Dorf- und Kleintiere

| Figur | Fundstelle | Lizenz | animiert | Stil | Eignung |
|---|---|---|---|---|---|
| Hund | Quaternius Ultimate Animated Animals (Husky, ShibaInu), quaternius.com/packs/ultimateanimatedanimals.html | CC0 | über 12 Bewegungen je Tier (u. a. Angriff, Tod, Gehen, Galopp, Sprung), mit Skelett | Low-Poly, glaubwürdige Proportionen [Bild] | gut |
| Katze | Quaternius Animal Pack Vol. 2, opengameart.org/content/animated-animales-low-poly | CC0 | ja | Low-Poly, ungeprüft | mit Umbau |
| Huhn, Hahn | CDmir „Chicken (animated)“, „Rooster (animated)“, opengameart.org/content/chicken-animated | CC0 | ja, mit Skelett | realistisch [Bild] | gut |
| Pferd, Esel | Quaternius Ultimate Animated Animals | CC0 | ja | glaubwürdig [Bild] | gut; Kutsche: Lotnik „horse drawn carriage“, CC0, unbewegt |
| Kuh, Schaf, Ziege | Kuh: Quaternius Ultimate Animated Animals; Schaf: Quaternius Farm Animal Pack; Ziege: tomek „3D goat animation for game“ (OpenGameArt, CC0 zur Wahl) | CC0 | ja (Ziege: Stehen, Gehen, Laufen, Sprung, Fressen, Angriff, Tod) | Farm-Paket eher niedlich [Bild] | gut bis mit Umbau |
| Rabe | Teh_Bucket „Raven“, opengameart.org/content/raven-0 | CC0 | Skelett, Flug; etwa 2000 Dreiecke | schlicht, realistisch [Bild] | gut |
| Frosch | „Frog low poly animated“, opengameart.org/content/frog-low-poly-animated-3d-model | CC0 | ja; 600 Dreiecke | comichaft [Bild] | mit Umbau |
| Libelle | kein CC0-Modell; nur „styly dragonfly“ unter OGA-BY 3.0 (Namensnennung) | – | – | – | Eigenbau |
| Schmetterling | CDmir „Butterfly (animated)“ | CC0 | ja | Low-Poly | gut |
| Fisch | CDmir „Esox“ (Hecht), Quaternius Animated Fish | CC0 | Stehen, zwei Schwimmbewegungen; 1632 Dreiecke | realistisch | gut |
| Maus | „Mouse basemesh“ (noway), unbewegt; etwa 700 Dreiecke | CC0 | nein | Rohform | mit Umbau |
| Kleiner Drache | Drummyfish „Cethiel's Dragon 3D“, opengameart.org/content/cethiels-dragon-3d (Vorlage Cethiels 2D-Drache, ebenfalls CC0) | CC0 | ja, mit Skelett | düster, stachelig [Bild] | gut |

#### Monster

| Figur | Fundstelle | Lizenz | animiert | Stil | Eignung |
|---|---|---|---|---|---|
| Wolf, Grimmzahn | Quaternius Ultimate Animated Animals; tomek „3D wolf animation for game“ (CC0 zur Wahl neben GPL) | CC0 | ja | glaubwürdig [Bild] | gut; steht bei uns schon |
| Keiler | Teh_Bucket „Boar“, opengameart.org/content/boar | CC0 | Gehen, Angriff; etwa 1000 Dreiecke | realistisch [Bild] | gut |
| Riesenratte | CDmir „Evil Giant Rat“, opengameart.org/content/evil-giant-rat | CC0 | ja | düster, realistisch [Bild] | **sehr gut**; steht bei uns schon |
| Riesenspinne | CDmir „Alien Bug Animated“ (Skorpionschwanz); br-n518 „Spider“ (222 Dreiecke) | CC0 | Stehen, Laufen, zwei Angriffe | [Bild] | mit Umbau |
| Riesenfledermaus | rubberduck „Vampire Bat (Animated)“, opengameart.org/content/vampire-bat-animated | CC0 | ja; 7732 Dreiecke | realistisch [Bild] | gut, vereinfachen |
| Ockergallerte | PINKCANNON „Slime“; Quaternius Animated Monster Pack | CC0 | ja | niedlich [Bild] | Eigenbau einfacher |
| Skelett | KevDev „Skeleton Outlaw“, opengameart.org/content/skeleton-outlaw-3d-character | CC0 (die Fassung im Unity-Store ist eine andere, bezahlte) | 13 Bewegungen (3 Stehen, 3 Angriffe, 2 Treffer, 2 Tode …); 6174 Flächen | handgemalt, Comic, Irokese [Bild] | mit Umbau |
| Zombie | Rikindle3D „Male City Zombie“; Quaternius Animated Zombie | CC0 | 2 Gehen, 3 Angriffe, Tod, Schrei … | realistisch, heutige Kleidung [Bild] | mit Umbau |
| Goblin | CDmir „Goblin“, opengameart.org/content/goblin-1 | CC0 | ja, mit Skelett | düster, realistisch [Bild] | gut (Vergleich mit unserem Goblin r6) |
| **Fehlt ganz** | Kobold, Grottenschrat (Krogg), Ghul, Stirge, Riesen-Hundertfüßer, Goblin-Schamane (Danimals Schamane ist CC-BY-SA, ausgeschlossen); Hobgoblin nur CC-BY | – | – | – | Eigenbau; Menschenartige auf dem CC0-Gerüst |

#### Skelette je Bauart

| Bauart | Fundstelle | Lizenz | Bemerkung |
|---|---|---|---|
| Vierbeiner | Blender-Rigify, Vorlagen Vierbeiner, Katze, Wolf, Pferd | Rigify selbst ist GPL; das damit Erzeugte gehört uns, laut blender.org: „What you create with Blender is your sole property“ | Das Steuerskript `rig_ui.py` fällt wohl unter GPL, kommt aber nicht mit ins GLB. Nicht juristisch geprüft. |
| Vierbeiner (fertig) | crownjoshua „Wolf Low Poly (Rigged)“; „Rigged Horse“ (Pferd von Lyndon Daniels, CC0) | CC0 | – |
| Vogel | Teh_Bucket „Raven“; pistachio „Bird (Yellow-Billed Shrike)“ | CC0 | – |
| Insekt | MikeMoon „3D Hornet/Wasp“ | CC0 | auch Grundlage für die Stirge |
| Spinne | br-n518 „Spider“, CDmir „Alien Bug“ | CC0 | Skelett ohne Körper nicht gefunden |

#### Lizenzfallen

1. **Quaternius ist nicht alles CC0:** Das neue „Bestiary – Dungeon Monsters Kit“ (Lycan, Goblin, Skelett) steht unter der QAL (Fassung vom 28.08.2026). Die übrigen 20 geprüften Quaternius-Seiten verlinken CC0. In der Freifassung stecken nur 60–70 % des Inhalts, den Goblin des Monsterpakets gibt es nur über Patreon.
2. **Remixe:** „WarWolf“, „Hazmat zombie“ und „Skeleton with rig“ stammen von Blendswap-Vorlagen mit ungeprüfter Lizenz, darum nicht nutzen. Danimals Modelle sind CC-BY-SA, ausgeschlossen.
3. **Mehrfachlizenz:** Bei tomek ist CC0 eine von mehreren Wahlmöglichkeiten. Wir wählen CC0 und halten das fest.
4. **Ausgeschlossen:**
   - „free personal and commercial“ ohne Lizenzname (ManNeko „Low Poly Wolf“)
   - „Quadruped Metarig“ (ohne Lizenz)
   - Hobgoblin von VWolfdog (CC-BY 3.0)
5. **Ungeprüft:** Poly Pizza und die itch.io-Suche sperren den Abruf. Sketchfab mit dem Filter CC0 liefert fast nur Scans ohne Skelett. Universal Animation Library 2 (über 130 Bewegungen) ist ebenfalls CC0; was davon frei ist, ist noch nicht geprüft.

#### Folgerung (Sokrates, 26.10.)

- **Gut abgedeckt:** Dorftiere (Quaternius), Wolf, Keiler, Ratte, Rabe, Huhn, Fisch, Fledermaus, kleiner Drache, Goblin.
- **Am glaubwürdigsten:** CDmir, Teh_Bucket, die Vampirfledermaus und Cethiels Drache. Die Monsterpakete von Quaternius, KayKit und Kenney sind zu niedlich.
- **Eigenbau bleibt:** Kobold, Krogg, Grak, Ghul, Stirge, Hundertfüßer, Schamane, Libelle, Gallerte. Menschenartige entstehen auf dem CC0-Gerüst.
- **Nächster Schritt** (nicht entschieden): Eine Probe mit CDmirs Goblin und Teh_Buckets Keiler in unserem Look, neben Jerrys Goblin r6 und Wildschwein r3. Erst nach dem Bild entscheidet der Chef, ob wir übernehmen. Vorschaubilder der Suche liegen nicht im Repo, sie gingen mit der Sitzung verloren; die Quellseiten zeigen sie.

### Gegen Geld (348.12c)

Auftrag des Chefs (26.10., 11:59): Pakete auch gegen Geld, wenn der Verkauf des Spiels erlaubt ist; Monster dürfen von D&D abweichen. Entschieden: Vorgangsarchiv 348.12c (Chefsache 34812c in Git). Suche durch vier Helfer am 26.10.; [G] = Quellseite selbst gelesen, [S] = gefolgert oder nur Suchtreffer.

**Lizenzen** (entscheidende Sätze im Wortlaut):
- **QAL v1.0** (quaternius.com/license.html, Stand 28.08.2026) [G]: Verkauf frei („sell … without owing us any fee, royalty, or credit“), keine Namensnennung, keine Engine-Bindung, unbefristet; verboten: Weitergabe der Dateien als Asset, „regardless of how much the Assets have been modified“. Es gilt die Fassung zum Zeitpunkt des Downloads.
- **Synty EULA** (Stand 09.07.2026) [G]: „not limited by game engine“, je Kauf 5 Plätze, Quelldateien nicht außerhalb des Teams. **SyntyPass (Abo):** nach Ende keine neue Arbeit mit den Assets („substantially developed … required to have an active Subscription“), also nur Einzelkauf.
- **Unity Asset Store** [G]: andere Engines erlaubt (Hilfeseite Unity), „Extension Asset“ = ein Platz, höchstens 2 Rechner; Ausnahme „Restricted Assets“. KI-Klausel 2.2.1 unten unter „Ausrüstung genau“ und oben „Lücken und Widersprüche“ 1 (780).
- **Fab Standard** [S, EULA gesperrt]: nicht auf Unreal beschränkt, außer „UE-Only“.
- **Sketchfab Standard** [G]: Engine frei, Verkauf ja, nicht als Einzeldatei weitergeben; „Editorial“ verbietet Verkauf.
- **Protofactor EULA** [G]: verkaufte Echtzeitanwendungen frei, „single computer“; Lieferung als Unity-, UE4-Paket und Rohdateien. Umbau erlaubt (1e, gelesen 26.10., 16:1x): „modify the content (bigger alteration of the model's geometry, UVs, textures, rig, animations etc…)“; Umbauten bleiben Eigentum von Protofactor, nie einzeln weiterverkaufen. Varianten im eigenen Spiel also frei.
- **RenderHub „Extended Use“** (MadeCG) [G]: Handyspiele ausdrücklich, Firma, unbegrenzt.
- **Mixamo** [S, Adobe-Seite gesperrt]: Spiele frei, nur Rohdateien nicht weitergeben; nur Zweibeiner.
- **Alle außer CC0 verbieten die Weitergabe der Rohdateien**; unser Repo ist öffentlich (109). Bezahlte Rohdateien nur in ein privates Repo.

**Kandidaten:**

| Modell | Anbieter, Preis | Dreiecke | Bewegungen | Stil | Eignung |
|---|---|---|---|---|---|
| Riesenratte | Protofactor 14,99 $ | 7.650 | 18 | düster, rote Augen | sehr gut |
| Riesenspinne | Protofactor „Darkness Spider“ 19,99 $ | 6.200 | 22 | düster | sehr gut |
| Ghul | Protofactor 24,99 $ | 19.200 | 33 | düster | gut, ausdünnen |
| Skelett | Protofactor Skelettritter 24,99 $ | 10.600 | 62 | düster | gut, ausdünnen |
| Zombie | Protofactor „Undead“ 34,99 $ | 24.600 | 55 | düster | gut, stark ausdünnen |
| Keiler | Protofactor 14,99 $ | 9.550 (Stufe 4.970) | 24 | realistisch | sehr gut |
| Wolf; „Fantasy Wolf“ als Grimmzahn | Protofactor 14,99 $ je | 10.100 (Stufe 5.300); 7.560 | 29 | realistisch | sehr gut |
| Goblin, Kobold, Hobgoblin | Protofactor 24,99 $ je | 13.000–29.200 | 30–82 | Warcraft-Comic | nein |
| Riesenfledermaus | Protofactor 24,99 $ | 13.100 | 28 | fast komisch | nein |
| Tiere (Wolf, Keiler, Kuh, Ziege, Huhn, Frosch, Fisch, Ratte u. a., 26) | Janpec Animal Pack Deluxe 5 $ (Unity) | Wolf etwa 5.600 [S] | Stehen, Gehen, Laufen, Fressen, Angriff, Tod | naturalistisch | gut |
| Hundertfüßer | MadeCG 14 $ (Rabatt bis etwa 27.10., sonst 20 $) | 660 Polygone | 6 | glaubwürdig, schlicht | einzige Quelle |
| Wolf, Keiler, Krähe, Hund, Katze, Huhn | MadeCG 5–13 $ | 160–2.450 Polygone | 5–10 | schlicht, ältere Handygrafik | Ersatz |
| Goblin, Ghul („Rake“) | HATOGAME, Sketchfab, je etwa 20 $ | 7.000; 4.400 | 9–10 | grimmig | Reserve |
| Bestiary: Imp, Puglin, Skelett, Lycan, Dämonenritter, Koloss | Quaternius, Source 20 $ (frei nur Imp, Puglin), QAL | ungenannt | keine (UAL nötig) | bunt, comichaft | nein |
| Skelette, Goblins, Geister | Synty Dungeon 149,99 $, Dark Fantasy 100 $ | ungenannt | keine | Spielzeug, Flachfarben | nein |
| Wald-Kit (Wolf, Keiler, Bär, Reh) | Silver Delivery, itch 4,99 $ | 1.000–1.600 | 36 | ernst | Lizenz fehlt auf der Seite |
| Skelette, Zombies | Hotstrike, itch je 9,99 $ | ungenannt | 5 | comicartig; Bewegungen passen laut Käufer in Godot nicht | nein |
| KayKit, Dungeon Mason, Overaction, Meshtint, Standout 7, SheepInTry, Infinity PBR | 0–70 $ | – | – | niedlich, bunt oder nur Unity-Paket ohne Lizenz | nein |

**Nicht gefunden:** Goblin-Schamane, Bugbear, Stirge, Ockergallerte, Libelle in passendem Stil. CGTrader, TurboSquid, Humble Bundle, Fab und Poly Pizza sperrten den Abruf.

**Folgerung (Sokrates):** Protofactor ist der einzige Anbieter mit durchgehend düsterem, glaubwürdigem Stil, aber für den PC gebaut. Erst eine Probe (Ratte, 7.650 Dreiecke, kaum Ausdünnen), dann der Rest. Ghul und Hundertfüßer in der „Folgerung“ oben (Eigenbau) sind damit überholt, falls der Chef 348.12c b billigt. Gekauft und hochgeladen: `LISTE-BESTAND.md` (377.1).

#### Dinge und Waffen (348.12h, Helfer 26.10., 16:27)

Liste: `LISTE-ABGLEICH-ALT.md` 6 „Dinge im Dorf“, „Möbel der Grundrisse“, „Ausrüstung“ (rund 74 Posten). „[Bild]“ = Vorschau gesehen; Dreiecke bei Quaternius und Kenney aus den OBJ gezählt.

| Paket | Fundstelle | Lizenz | Preis | Deckt ab | Dreiecke | Stil | Eignung |
|---|---|---|---|---|---|---|---|
| Quaternius Fantasy Props MegaKit | quaternius.com/packs/fantasypropsmegakit.html | CC0 | Standard frei; Pro 9,99 $ (Inhalt ungeprüft) | Möbel etwa 15/20, Dorf 4 (Stand, Wandlaterne, Bank, Fass), Fackel, Buch, Holzschild | Amboss 750, Fass 824, Bett 1600, Regal 2148, Truhe 2546, Laterne 2822, Tisch 986 | neutral, leicht überzeichnet [Bild] | gut (Möbel) |
| Tedium „melee weapons 0“ | opengameart.org/content/melee-weapons-0 | CC0 | frei | 11/21 Waffen | sehr wenige (ungezählt) | glaubwürdig, schlicht [Bild] | gut |
| System G6 „medieval weapon pack“ | opengameart.org/content/medieval-weapon-pack | CC0 | frei | Bogen, Armbrust, Stab, Zauberstab, Schild, Buch | 36–198 (Autor) | ungeprüft | ungeprüft |
| Poly Haven | polyhaven.com | CC0 | frei | etwa 12 (Fass, Laterne, Wappenschild, Stumpf …) | hoch, stark ausdünnen | Fotoscan (ungeprüft) | mit Umbau |
| Quaternius Medieval Village | quaternius.com | CC0 | frei | 3 (Wagen, Zaun, Kiste) | – | handgemalt [Bild] | wenig Nutzen |
| Kenney Survival Kit | kenney.nl | CC0 | frei | etwa 8 | 56–900 | ungeprüft | mit Umbau |
| Quaternius Medieval Weapons; Kenney Fantasy Town; KayKit | – | CC0 | frei | – | – | niedlich, Spielzeug [Bild] | nein |
| Synty POLYGON Fantasy Kingdom | syntystore.com | EULA: jede Engine, unbefristet; Quelldateien nur im Team; **KI-Klausel** („third party services for … 3D model generation“, „datasets utilised by Generative AI“) | 349,99 $ | vermutlich über 50 | – | glaubwürdig, kantig [Bild] | nein (Preis, KI-Klausel) |

**Folgerung (Sokrates):** CC0 deckt etwa 40 von 74 (Quaternius Props für Möbel, Tedium und G6 für Waffen, Poly Haven als Lückenfüller); kein Kauf nötig. Fehlt danach: Ziehbrunnen, Schlagbaum, Anschlagbrett, Waschzuber, Netz, Heu, Gasthausschild, Brücke, Bäume; Altar, Kamin, Lehnstuhl, Theke; rapier, morningstar, greatsword, greataxe, maul, longbow; Turmschild, Kugel, heiliges Symbol (Eigenbau `dorf.py`, `waffen.py`). **Stärkstes Gegenargument:** der Shader gleicht Farbe an, nicht Form; drei Formensprachen geben ungleich dichte Tusche. Darum fremd nur, wo viele gleiche Teile stehen (Möbel, Kram, Waffen); erst Probeblatt mit Tusche 348.13 nach der Rattenprobe.

#### Stufe 2: weg von D&D (26.10., 15:1x)

Anlass: Chef 15:04 (Vorgangsarchiv „348.12c, Monster“): Modell zählt, nicht die D&D-Vorlage. Zwei Helfer: ganzer Protofactor-Katalog (Kreaturen, Humanoide, Tiere, Pakete; Produktseiten einzeln geöffnet) und andere Anbieter (RenderHub-Lizenz im Wortlaut gelesen). Sci-Fi, Meerestiere, Afrika, Comic ausgeschlossen. [G] bei RenderHub = Vorschaubild gesehen; bei Protofactor nur Seitentext.

**Lizenz RenderHub „Extended Use“** [G, `renderhub.com/info/3d-content-licensing` III]: „non-exclusive, perpetual, worldwide“, Spiele ausdrücklich, ohne Umsatzgrenze, ohne Nennung; Artikel mit „Editorial Use Only (IP Restricted)“ ausgenommen (keiner der unten).

**Protofactor, handytauglich (unter etwa 14.000 Dreiecke), düster:**

| Modell | $ | Dreiecke | Bewegungen | Seitentext |
|---|---|---|---|---|
| Death Skull | 19,99 | 3.600 | 12 | fliegender Totenschädel |
| Crasc | 19,99 | 4.650 | 21 | Höhlenfischmonster, Giftstachel |
| Giant Viper | 14,99 | 4.520 | 21 | Riesenviper |
| Darkness Spider | 19,99 | 6.200 | 22 | Monsterspinne |
| Mummy | 24,99 | 10.700 | 44 | Mumie, Gruft |
| Skeleton Knight | 24,99 | 10.600 | 62 | Skelettritter |
| Golem | 34,99 | 11.200 | 38 | Steingolem |
| Giant Slug | 24,99 | 11.240 | 28 | schleimige Riesenschnecke |
| Basilisk | 24,99 | 11.300 | 19 | Hahn-Schlange |
| Hellrot | 24,99 | 13.100 | 37 | fliegender Dämon, Klauen |
| Giant Worm | 39,99 | 13.500 (Brut 1.500) | 36 | Riesenwurm mit Brut |
| Demon Minion | 24,99 | 13.620 | 21 | kleiner Dämon |

**Protofactor, größer (ausdünnen):** Ghoul 24,99 $ 19.200/33, Fungoid (Pilzleiche) 24,99 $ 16.000/38, Undead 24.600/55, Undertaker 18.000/27, Vampire 15.150/33, Barghest (Friedhofshund) 19.170/19, Werewolf 14.900/26, Werehog 14.730/30, Weregoat 27.620/33, Troll 16.400/31, Witch 20.400/17, Cavecrawler 21.000/24, Giant Beetle 21.300/18, Giant Scorpion 19.900/31, Gargoyle 17.800/47, Evil Watcher 16.830/16, Oak Tree Ent 36.060/44; je 24,99–34,99 $. Rüstung als Baukasten nur beim Zwerg (44,99 $). Rigs sind Unity-Generic; Import nach Godot zeigt die Rattenprobe.

**Mengenrabatt Protofactor** (Bundle-Seite): 3–4 Teile 10 %, 5–6 20 %, 7–9 30 %, 10–19 40 %, 20–29 50 %, ab 30 60 %; nicht während Sonderaktionen. Pakete (Inhalt nicht geöffnet): Monster Pack Vol 1–18 je 84,99–94,99 $, Were Creatures 119,99 $, Demons Vol 1 84,99 $, Horror-Reihe „MONSTER: …“ (rund 130 Teile) als Alien und Körperhorror ausgeschlossen.

**Andere Anbieter (RenderHub, Extended Use):**

| Modell | Anbieter, $ | Dreiecke | Bewegungen | Aussehen [G] |
|---|---|---|---|---|
| 20 Creatures Mega Pack | Maksim_Bugrimov, 29,99 (sonst 49,99; Frist etwa 04.11.) | 4.526–9.444 je | 198 (8–12 je) | bleiche, sehnige Fleischwesen, Hörner, Klauen, Kokon |
| Evil Undead | Wernerkurt, 35 | 13.350 | 34 | ausgemergelte Leiche, Schädelkopf, Glutaugen |
| Corrupted Rat 01 | Game-Ready Studios, 17,99 (Frist etwa 30.10.) | 1.958 | 21; 4 Körper (heil bis zerfetzt) | haarlose Riesenratte, Eiterbeulen |
| Arachnid Monster | Game-Ready Studios, 17,99 (Frist etwa 30.10.) | 3.276 | 22 | klingenbeinige Chitinspinne |
| Mobile Leeches Collection | Game-Ready Studios, 17,99 (Frist etwa 30.10.) | 800 (4 Netze) | 10 | gepanzerte Blutegel, rot glühende Ringe |
| Wood Monster | Tanchik, 30 | unbekannt (9.744 Flächen) | 7 | lebender Baumstumpf, Glutaugen, Pilze |
| Hell Dog Monster | Coffeemill, 12,59 | 11.144 | 25 | augenloser Fleischhund, Hauer |
| Reptile Beast | Tselueva, 29 | 13.055 | 18 | graue Krötenechse, Zahnmaul |
| Monster Flesh | Coffeemill, 12 | 19.962 | 31 | aufgeplatzter Fleischkoloss |

Nicht abrufbar: gamedevmarket (403), CGTrader, TurboSquid, Fab, Poly Pizza; Sketchfab-Store geschlossen (Verkauf jetzt über Fab); ArtStation, Kenney, itch ohne Treffer mit Lizenz, Skelett und Bewegungen.

Vorlage an den Chef: Chefsache 348.12c (Stufe 2).

#### Quaternius-Bausätze (Chef 27.10., 12:00, Vorgang 376; vier Helfer, Downloads geprüft)

| Paket | Lizenz (Seite und Datei) | Befund | Eignung |
|---|---|---|---|
| Medieval Village MegaKit (Standard frei, 176 Teile) | CC0 | Wände Putz/Bruchstein, Fachwerk, Ecken, Böden, Hohlziegel- und Holzdächer, Gauben, Vorkragungen, Balkone, 4 Innentreppen, Außentreppen; Raster 2,0 m, Wand 3,12 m hoch (×1,16 = 2 Kacheln, 3,6 m hoch); Wand 56–166, Dach 2.000–6.400 Dreiecke; gemalte Bahnen mit UV, also unsere Texturen möglich; streng rechtwinklig; bunt, märchenhaft, Hohlziegel südländisch, Detail dichter als unser Dorf. Wohl dasselbe wie „Medieval Village“ oben | Teile, nicht ganze Häuser: Treppen, Vorkragung, Gauben, Innenböden; nur nach Probehaus |
| Stylized Nature MegaKit (Standard frei, 68 von 116) | CC0 | Bäume 1.600–10.100 Dreiecke (zu schwer), grell, „Ghibli-inspired“; Felsen 244–522, Kiesel, Pilze (880), Farn, Totholz; UV und gemalte Texturen, Blattkarten teils weiß | Felsen, Kiesel, Pilze, Farn für Wald; Bäume nein |
| 150 Lowpoly Nature Models | CC0 | keine UVs, nur Flächenfarben, harte Kanten, Comic | nein |
| Lowpoly Modular Dungeon Pack (48 Teile, 2019) | CC0 | keine UVs, Flächenfarben, Raster 2 m, spielzeughaft; kein Naturfels | nein; Fackel, Gitter, Truhe als Rohform höchstens nach dem Meilenstein |
| Modular Character Outfits – Fantasy (Source 20 $) und Universal Base Characters (Source 19,99 $) | CC0 (Seite, `License_Standard.txt`) | Gerüst wie unsere Leute (65 Knochen); Befund und Votum in Chefsache 376 „Figuren“ (Git) | gekauft 12:20, Probeblatt 376.1 |

Chef 27.10., 12:42 „376 ja“: aus dem Dorfbausatz nur ein Probehaus (Tom), Natur wie oben, die beiden „nein“ gelten.

**Omie's Assets „Medieval Village Kit“** (Chef 28.10., 23:1x, [itch.io](https://omies-assets.itch.io/medieval-village-kit); Sokrates): PRO 5,50 $ (Aktion 2,75 $), „the full 37-mesh kit, commercial use, no credit required“; Frei-Fassung nur privat mit Nennung. Unbefristet, jede Engine, Weiterverkauf nicht geregelt (nur „Compatible with Unity, Godot, Unreal“). „No generative AI was used.“ 37 Teile: Steinwände, Dächer, Schornsteine, Zierleisten, Tunnel; keine Türen, Fenster, Möbel, Waffen genannt. 2–2.110, Schnitt 320 Dreiecke; FBX, PBR-Texturen 2K. Eignung: Bauteile für Häuser wie der Quaternius-Bausatz oben, nichts für Ausrüstung; Häuser „so lassen“ (Archiv 376, 27.10., 19:08).

**Omie's Assets „3D Medieval Weapon Pack“** (Chef 28.10., 23:1x, [itch.io](https://omies-assets.itch.io/3d-medieval-weapon-pack); Sokrates): „Creative Commons Zero v1.0 Universal“, „free for personal and commercial use, no attribution required“; Bitte: „please don't resell unmodified copies“ (nur Bitte, CC0 gilt). Mindestpreis 1,99 $ (sonst 3,99 $). „No generative AI was used.“ 20 Modelle: Schwerter, Äxte, Bogen, Armbrust, Speer, Hellebarde, Flegel, Kriegshammer, drei Schildarten „and more“ (nicht einzeln genannt). 644–1.764, Schnitt 1.236 Dreiecke (an der Grenze, ausdünnen); OBJ, Godot-Zip 167 MB, PBR 2K. Eignung: Kandidat für 348.12h Waffen und Schilde; Stil erst am Vorschaubild prüfen.

**Anker's Assets „Low Poly Medieval Weapons“** (Chef 28.10., 23:1x, [itch.io](https://ankersassets.itch.io/low-poly-medieval-weapons); Sokrates): „Creative Commons Zero v1.0 Universal“, „Completely free to use, personal or commercial.“; „No generative AI was used“. Frei (Preis nach Wahl). „over 60 meshes“: Schwerter, Äxte, Hämmer, Speere, Streitkolben, Schilde, Bogen, Magie (zwei Bilder), Bauerngerät, Belagerungsgerät; FBX, Zip 1,5 MB, also sehr wenige Dreiecke, vermutlich Flächenfarben („Colorful“). Eignung: frei, darum laden und neben Omie prüfen; Gefahr spielzeughaft wie Quaternius' Waffen; Magie-Teile könnten Kugel, Stab, Zauberstab füllen.

#### Ausrüstung genau (348.12h, Chef 28.10., 23:1x; Helfer 23:2x, Lizenzen auf den Seiten gelesen)

**Lizenzrahmen:** Unity Asset Store nein (2.2.1 verbietet Assets „as inputs for artificial intelligence or machine learning model programs“; fällt wie Synty; offen als 780, oben „Lücken und Widersprüche“ 1); Fab nur ohne NoAI-Kennzeichen, EULA vor Kauf im Browser prüfen; CGTrader „Royalty Free“ ja, „Royalty Free, No AI“ nein; RenderHub „perpetual, unless terminated“.

| Paket | Lizenz | Preis | Deckt | Urteil |
|---|---|---|---|---|
| System G6 „Medieval Weapon Pack“ (opengameart) | CC0 | frei | 14 Teile, 36–198 Dreiecke, Textur 512: Langschwert, Bastardschwert, Dolch, Doppelaxt, Handaxt, großer Hammer, Morgenstern (Stachelkugel), Heater-Schild mit Adler, Bogen, Armbrust, Stab, Grimoire, Kristallstab, Zauberstab | gut, Stil dunkel, glaubwürdig (Vorschau) |
| Avramania „Weapons & Shields“ frei (itch) | CC0 | frei | 19: Schwert, Kurzschwert, Dolch, Handaxt, Streitkolben, Speer, Stab, Kurzbogen, Armbrust, Rund-, Faustschild; 166–1.156, glb, Griffpunkt | gut |
| Avramania Premium | „Royalty-free licence“, Nennung, KI offen | 7,99 $ | 73 (Rapier, Zweihänder, Kugel, Turmschild …) | nein: Händler 20 Tage alt, Netze teils KI (Tripo), Lizenz dünn |
| PolyMech „Medieval Pack Low Poly Shields“ (itch) | CC0 | frei | 9 Schilde (Kite, Heater, Rund, Faust) | gut |
| Hetchler „19 Low-Poly Fantasy Weapons“ (opengameart 32331) | CC0 | frei | Rapier, Zweihänder, Krummschwert, Hellebarde, Streitaxt, Kriegshammer, Bogen; .blend | mit Umbau, Stil ungeprüft |
| Tedium „Melee Weapons“ | CC0 | frei | 12, schlicht | mit Umbau |
| mrleap „Low Poly Weapon Pack“ | CC0 | frei | 20, 30–200 Dreiecke, Textur 8×8 | Notlösung |
| Lucian Pavel (opengameart) | CC0 | frei | Kite, Rund, Zweihänder, Morgenstern, Topfhelm | mit Umbau |
| Omie, Anker (oben) | CC0 | 1,99 $; frei | Waffen, Schilde, Magie | prüfen |
| Polytope Modular Armors, Panchenko Helme, quin-gs Knights, JustCreate3D, CH0SAN | – | – | – | nein (Skelett, Dreiecke, Chibi, KI-Verbot, keine Lizenz) |

**Rüstung:** keine freie oder käufliche Quelle passt aufs Quaternius-Gerüst außer Quaternius selbst; „Modular Character Outfits – Fantasy“ Source haben wir (Bestand 681373666): Robe, Leder, Kapuze, Krone, Platte, Handschuhe, Armschienen, Stiefel, Hose, Umhang. Beschlagenes Leder, Kette, Schuppe, Schiene: gleiches Netz, neue Textur; Lederkappe, Helm, Topfhelm, Kettenbeinlinge, Beinschienen, Wickel, Mantel: Eigenbau auf UAL.

**Folgerung (Sokrates):** Waffen, Schilde, Nebenhand zu etwa 90 % CC0 (G6, Avramania frei, PolyMech, Hetchler; Omie für 1,99 $ als Ergänzung); Einzelstücke, Heiligensymbol, Kugel, Turmschild Eigenbau; Rüstung aus dem Bestand plus Eigenbau; Kauf nur Omie. **Stärkstes Gegenargument:** vier Quellen, vier Stile; Ausweg: Jerry gleicht alles mit einer Palette und unserer Tusche an, und G6 (dunkel, texturiert) ist das Maß; reicht das nicht, Waffen ganz selbst bauen (unter 1.500 Dreiecke, schnell).

**RenderHub „Asset Pack Vol 10 – Modular Dungeon Interior“** (JuanChee, 7 $, Extended Use; Chef 27.10., 12:34 „checken“): 40 Teile, 18 fertige Hallen, 16.686 Dreiecke gesamt, 4096-px-Atlas PBR (fotografisch abgenutzt), glTF dabei. Gemauert (Quader, Holz, Eisen), Rundbogentüren, Gittertür, Doppeltor, Treppen, Säulen, Fackel und Kerze mit Bildfolge; Fässer, Truhen, Kisten, Säcke, Tisch, Bank, Hocker, Spinnennetz, Trümmer. Kein Naturfels, also nicht für die Blutzahnhöhle; gemauerte Verliese hat Kapitel 1 nicht (48 Dungeons nach dem Meilenstein). Votum noch nicht: Requisiten erst gegen 348.12h (CC0) abgleichen; Fototexturen gegen „Farbe gemalt“ (Modellregel 6).

**RenderHub „Medieval Market Asset Pack“** (MagicCGIStudios, frei, Extended Use; Chef 27.10., 12:37 „check“): 100 Dinge, 127.056 Polygone gesamt (im Mittel etwa 1.300), nur .blend (Blender 2.79), Texturen 2K/1K PBR, realistisch gerendert. Brunnen offen in der Mitte, Satteldach auf zwei Pfosten, Kurbelwalze; 4 Marktstände, Dach auf vier Eckpfosten mit Streben (beides Chefbefund 25.10., 18:06); Kisten mit Obst und Gemüse, 16 Holzfässer, Körbe, Heu- und Fasswagen, Tische mit Käse, Brot, Fleisch, Flaschen, Holzstapel, Strohballen. Gegen: Fototexturen, Stoffe bunt wie Jahrmarkt. Votum ja: Chef lädt (Anmeldung nötig) ins private Repo; Tom nimmt Brunnen und Stände als Form, unsere gemalten Farben.

**Hinweis des Herstellers zur Source-Fassung** (Chef 27.10., 12:19, „Zum Merken“): Der erste Start eines Projekts dauert länger, weil die Zwischendateien fehlen. Modelle mit Skelett als glTF nehmen, nie als FBX: FBX aus Blender bringt wegen eines Einheitenfehlers falsche Maße und kann das Übertragen der Bewegungen (Retargeting) brechen. Darum auch beim Wiederausgeben glTF; Import: die `.gltf` hineinziehen. Gekaufte Rohdateien nur im privaten Zweit-Repo (CLAUDE.md „Fremde Inhalte“).
