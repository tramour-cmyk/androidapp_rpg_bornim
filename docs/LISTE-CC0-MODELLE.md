# Freie Modelle und Bewegungen (CC0)

Vorgang 348.12, Sokrates, angelegt am 26.10. Hier steht, was wir von fremder Hand übernehmen, was es kostet und was offen ist. Entschiedenes steht im Vorgangsarchiv, Stand und Zeilen im Vorrat (`ARBEIT-BERATUNG.md`, `ARBEIT-TEAM-JERRY.md`, `ARBEIT-TEAM-TOM.md`).

**Lizenzregel:** `CLAUDE.md` „Technik und Sicherheit“ (seit 348.12c auch gekaufte Modelle). Nie: CC-BY-NC, CC-BY-ND, „nur privat“.

## Stand

| Was | Stand | Quelle |
|---|---|---|
| Skelett Menschen (alle Völker) | übernommen: Gerüst der Universal Animation Library, 65 Knochen; Zwerg, Halbling, Elf, Halbork über Knochenlängen | Archiv 348.12 (25.10., 23:33); `LISTE-UMZUG-348.md` Punkt 4 |
| Körper und Kleidung | bleiben unsere eigenen (`held3.py`); der fremde Grundkörper ist rundlich, großer Kopf, passt nicht zu „düster, erwachsen“ | Chefsache 34812-cc0 in Git |
| Bewegungen Menschen | Freifassung im Einsatz (Stehen, Gehen, Rennen, Fackel); Stich, Ausweichen, Abwehr bauen wir selbst | `LISTE-UMZUG-348.md` Punkt 5 |
| Goblin, Grak, Zombie | noch auf eigenem Skelett (`rig.py`); Probe: ein Goblin aufs CC0-Gerüst, wenn Schamane, Kobold und Späher fertig sind; ist er besser, folgen Grak und Zombie | Archiv 348.12 (26.10., 11:33), an Jerry |
| Tiere, Monster | eigenes Skelett je Bauart (Vierbeiner, Vogel, Insekt, Spinne); Suche nach CC0-Modellen läuft (unten) | Archiv 348.12a (26.10., 11:40) |
| Pro-Fassung der Bewegungen | gekauft vom Chef (Vorgangsarchiv 348.12c) | – |

## Bewegungen: Universal Animation Library (Quaternius)

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
- **Im Spiel heute:**
  - Jede Person hat eine Stehbewegung (5 von 13 Idle_Talking, sonst Idle) und eine Gehbewegung (3 förmlich, sonst normal).
  - Dazu kommen eigene Armhaltungen über der Bewegung: Hände vorn gefaltet, Hände auf dem Rücken, Stab, Last auf der Schulter, Daumen am Gürtel.

**Was fehlt:** Abwechslung, nämlich mehrere Stehvarianten, Gesten (Hände in die Hüfte, Arme verschränken), mehrere Angriffe je Waffe und eigene Treffer und Tode (Chef 26.10., 11:42).

## Bewegungen gegen Geld: Protofactor-Animsets (385, Chef 27.10., 20:52–20:59)

Chef: „Zauberer, den finde ich genial“; „ziemlich gut und weich und geschmeidig und für fast alle Situationen. Aber halt Mensch“; „wenn das technisch nutzbar ist für uns“. Alle: Bewegungserfassung (Motion Capture), Unity „Mecanim Humanoid“, Lizenz Standard Unity Asset Store EULA (andere Engines erlaubt, siehe Lizenzen unten), Single Entity. Inhalte aus den Store-Seiten, im Browser gelesen 27.10., 20:5x (Sokrates; ein Helfer sah per Abruf nur leere Beschreibungen); Preise in $ ohne Steuer (Chef sah den Zauberer für 18,39, wohl Euro mit Steuer). Liste aller 24 Sets: Store-Suche „animset“, Anbieter Protofactor (Chef 21:00).

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

## Eigene Bewegungen: drei Wege

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

## Wirtschaftlich (Schätzung 26.10.)

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

## Tiere und Monster: Suche (348.12a)

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

### Dorf- und Kleintiere

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

### Monster

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

### Skelette je Bauart

| Bauart | Fundstelle | Lizenz | Bemerkung |
|---|---|---|---|
| Vierbeiner | Blender-Rigify, Vorlagen Vierbeiner, Katze, Wolf, Pferd | Rigify selbst ist GPL; das damit Erzeugte gehört uns, laut blender.org: „What you create with Blender is your sole property“ | Das Steuerskript `rig_ui.py` fällt wohl unter GPL, kommt aber nicht mit ins GLB. Nicht juristisch geprüft. |
| Vierbeiner (fertig) | crownjoshua „Wolf Low Poly (Rigged)“; „Rigged Horse“ (Pferd von Lyndon Daniels, CC0) | CC0 | – |
| Vogel | Teh_Bucket „Raven“; pistachio „Bird (Yellow-Billed Shrike)“ | CC0 | – |
| Insekt | MikeMoon „3D Hornet/Wasp“ | CC0 | auch Grundlage für die Stirge |
| Spinne | br-n518 „Spider“, CDmir „Alien Bug“ | CC0 | Skelett ohne Körper nicht gefunden |

### Lizenzfallen

1. **Quaternius ist nicht alles CC0:** Das neue „Bestiary – Dungeon Monsters Kit“ (Lycan, Goblin, Skelett) steht unter der QAL (Fassung vom 28.08.2026). Die übrigen 20 geprüften Quaternius-Seiten verlinken CC0. In der Freifassung stecken nur 60–70 % des Inhalts, den Goblin des Monsterpakets gibt es nur über Patreon.
2. **Remixe:** „WarWolf“, „Hazmat zombie“ und „Skeleton with rig“ stammen von Blendswap-Vorlagen mit ungeprüfter Lizenz, darum nicht nutzen. Danimals Modelle sind CC-BY-SA, ausgeschlossen.
3. **Mehrfachlizenz:** Bei tomek ist CC0 eine von mehreren Wahlmöglichkeiten. Wir wählen CC0 und halten das fest.
4. **Ausgeschlossen:**
   - „free personal and commercial“ ohne Lizenzname (ManNeko „Low Poly Wolf“)
   - „Quadruped Metarig“ (ohne Lizenz)
   - Hobgoblin von VWolfdog (CC-BY 3.0)
5. **Ungeprüft:** Poly Pizza und die itch.io-Suche sperren den Abruf. Sketchfab mit dem Filter CC0 liefert fast nur Scans ohne Skelett. Universal Animation Library 2 (über 130 Bewegungen) ist ebenfalls CC0; was davon frei ist, ist noch nicht geprüft.

### Folgerung (Sokrates)

- **Gut abgedeckt:** Dorftiere (Quaternius), Wolf, Keiler, Ratte, Rabe, Huhn, Fisch, Fledermaus, kleiner Drache, Goblin.
- **Am glaubwürdigsten:** CDmir, Teh_Bucket, die Vampirfledermaus und Cethiels Drache. Die Monsterpakete von Quaternius, KayKit und Kenney sind zu niedlich.
- **Eigenbau bleibt:** Kobold, Krogg, Grak, Ghul, Stirge, Hundertfüßer, Schamane, Libelle, Gallerte. Menschenartige entstehen auf dem CC0-Gerüst.
- **Nächster Schritt** (nicht entschieden): Eine Probe mit CDmirs Goblin und Teh_Buckets Keiler in unserem Look, neben Jerrys Goblin r6 und Wildschwein r3. Erst nach dem Bild entscheidet der Chef, ob wir übernehmen. Vorschaubilder der Suche liegen nicht im Repo, sie gingen mit der Sitzung verloren; die Quellseiten zeigen sie.

## Gegen Geld (348.12c)

Auftrag des Chefs (26.10., 11:59): Pakete auch gegen Geld, wenn der Verkauf des Spiels erlaubt ist; Monster dürfen von D&D abweichen. Entschieden: Vorgangsarchiv 348.12c (Chefsache 34812c in Git). Suche durch vier Helfer am 26.10.; [G] = Quellseite selbst gelesen, [S] = gefolgert oder nur Suchtreffer.

**Lizenzen** (entscheidende Sätze im Wortlaut):
- **QAL v1.0** (quaternius.com/license.html, Stand 28.08.2026) [G]: Verkauf frei („sell … without owing us any fee, royalty, or credit“), keine Namensnennung, keine Engine-Bindung, unbefristet; verboten: Weitergabe der Dateien als Asset, „regardless of how much the Assets have been modified“. Es gilt die Fassung zum Zeitpunkt des Downloads.
- **Synty EULA** (Stand 09.07.2026) [G]: „not limited by game engine“, je Kauf 5 Plätze, Quelldateien nicht außerhalb des Teams. **SyntyPass (Abo):** nach Ende keine neue Arbeit mit den Assets („substantially developed … required to have an active Subscription“), also nur Einzelkauf.
- **Unity Asset Store** [G]: andere Engines erlaubt (Hilfeseite Unity), „Extension Asset“ = ein Platz, höchstens 2 Rechner; Ausnahme „Restricted Assets“.
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

**Folgerung (Sokrates):** Protofactor ist der einzige Anbieter mit durchgehend düsterem, glaubwürdigem Stil, aber für den PC gebaut. Erst eine Probe (Ratte, 7.650 Dreiecke, kaum Ausdünnen), dann der Rest. Ghul und Hundertfüßer im Abschnitt „Folgerung“ oben (Eigenbau) sind damit überholt, falls der Chef 348.12c b billigt.

### Bestand: gekauft und hochgeladen

Steht jetzt nach Art geordnet in [`LISTE-BESTAND.md`](LISTE-BESTAND.md) (377.1, 27.10., 14:3x); dort nachsehen und eintragen. Die alte Tabelle je Datei steht in Git (vor „Sokrates: 377.1 Inventur eingestellt“).


### Dinge und Waffen (348.12h, Helfer 26.10., 16:27)

Liste: `LISTE-UMZUG-348.md` „Dinge im Dorf“, „Möbel der Grundrisse“, „Ausrüstung“ (rund 74 Posten). „[Bild]“ = Vorschau gesehen; Dreiecke bei Quaternius und Kenney aus den OBJ gezählt.

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

### Stufe 2: weg von D&D (26.10., 15:1x)

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

### Quaternius-Bausätze (Chef 27.10., 12:00, Vorgang 376; vier Helfer, Downloads geprüft)

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

**RenderHub „Asset Pack Vol 10 – Modular Dungeon Interior“** (JuanChee, 7 $, Extended Use; Chef 27.10., 12:34 „checken“): 40 Teile, 18 fertige Hallen, 16.686 Dreiecke gesamt, 4096-px-Atlas PBR (fotografisch abgenutzt), glTF dabei. Gemauert (Quader, Holz, Eisen), Rundbogentüren, Gittertür, Doppeltor, Treppen, Säulen, Fackel und Kerze mit Bildfolge; Fässer, Truhen, Kisten, Säcke, Tisch, Bank, Hocker, Spinnennetz, Trümmer. Kein Naturfels, also nicht für die Blutzahnhöhle; gemauerte Verliese hat Kapitel 1 nicht (48 Dungeons nach dem Meilenstein). Votum noch nicht: Requisiten erst gegen 348.12h (CC0) abgleichen; Fototexturen gegen „Farbe gemalt“ (Modellregel 6).

**RenderHub „Medieval Market Asset Pack“** (MagicCGIStudios, frei, Extended Use; Chef 27.10., 12:37 „check“): 100 Dinge, 127.056 Polygone gesamt (im Mittel etwa 1.300), nur .blend (Blender 2.79), Texturen 2K/1K PBR, realistisch gerendert. Brunnen offen in der Mitte, Satteldach auf zwei Pfosten, Kurbelwalze; 4 Marktstände, Dach auf vier Eckpfosten mit Streben (beides Chefbefund 25.10., 18:06); Kisten mit Obst und Gemüse, 16 Holzfässer, Körbe, Heu- und Fasswagen, Tische mit Käse, Brot, Fleisch, Flaschen, Holzstapel, Strohballen. Gegen: Fototexturen, Stoffe bunt wie Jahrmarkt. Votum ja: Chef lädt (Anmeldung nötig) ins private Repo; Tom nimmt Brunnen und Stände als Form, unsere gemalten Farben.

**Hinweis des Herstellers zur Source-Fassung** (Chef 27.10., 12:19, „Zum Merken“): Der erste Start eines Projekts dauert länger, weil die Zwischendateien fehlen. Modelle mit Skelett als glTF nehmen, nie als FBX: FBX aus Blender bringt wegen eines Einheitenfehlers falsche Maße und kann das Übertragen der Bewegungen (Retargeting) brechen. Darum auch beim Wiederausgeben glTF; Import: die `.gltf` hineinziehen. Gekaufte Rohdateien nur im privaten Zweit-Repo (CLAUDE.md „Fremde Inhalte“).
