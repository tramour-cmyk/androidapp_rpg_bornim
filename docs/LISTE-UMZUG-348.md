# Umzug nach Godot (348)

Entschieden 25.10., 00:30–01:04 (Vorgangsarchiv „348, Umstieg“, „348, Umzug Einzelheiten“, „338, Termin“): Umzug jetzt, altes Spiel ruht, kein Release-Termin. **Vorgabe ist das heutige Spiel**: was es zeigt und kann, muss es danach mindestens so gut zeigen und können. Der Chef prüft nur Vergleichsbilder alt/neu. Plan: Sokrates (Vertretung des Chefs, 25.10., 01:19), Abnahme und Wochenziel: Perikles.

## Grundsätze

- **Ein Projekt:** `godot/` im Repo (Arbeitszweige `claude/tom-348-…`, `claude/jerry-348-…`), App-Kennung bleibt `de.bornim.game`, Build über eigenen Workflow; `main` erst nach Test des Chefs.
- **Look aus der Probe** (`tools/godot348/`, Build 12, b71b9a47f): `toon.gdshader` (drei Lichtstufen, `fill` hellt den Helden im Schatten auf), `tusche.gdshader` (Tusche nach Licht, ohne MSAA; Schablone: 1 = ohne Linie wie Blüten, 2 = feinere Linie wie Held, `main.gd` `toon_mark`), Gras `halm.gdshader` ohne Linie, gemalte Texturen aus `tools/blender348/v3/tex.py`. Keiner stellt seine eigene Tusche ein.
- **Modellregel** (Jerry, 348.7): unten im Abschnitt „Modellregel“.
- **Regeln** (`core`) nach GDScript mit denselben Testfällen; Tom Welt, Leute, Story, Läden, Spielstand; Jerry Kampf, MARS, Höhle, Klang.
- **Abgleich:** je Ort und Figur ein Vergleichsbild alt/neu; was fehlt oder schlechter ist, ist ein Fehler.
- **Der Chef sieht mit** (Chef 25.10., 07:46: „wäre es nicht gut, wenn ich als Mensch zumindest mal irgendwo einen Blick auf ein paar Entwürfe werfen könnte, um zu sagen, ah, ja, nein, vielleicht“): jedes Modell (Held, Leute, Tiere, Monster, Häuser, Dinge; Chef 07:47 „betrifft … auch andere Modelle“) zuerst als grober Entwurf neben dem alten Bild, bevor es verfeinert wird; dazu spätestens alle zwei Stunden und nach jedem Abschnitt ein Vergleichsbild alt/neu, alles auf Telegram (`meldung.sh --bild`, Helfer prüft vorher); nach drei Prüferrunden ohne Urteil des Chefs keine vierte, sondern Bild an ihn. **Schläft der Chef** (nachts, Vertretung), urteilt Sokrates an seiner Stelle (362): Bild trotzdem auf Telegram, dazu Nachricht an Sokrates; ohne laufende Sokrates-Sitzung startet Ford eine. Der Chef sieht morgens die Bilder und kann „zurück“ sagen.

## Woche 1: Fundament (ab 25.10.)

| Nr. | Wer | Was | fertig, wenn |
|---|---|---|---|
| 348.6 | Tom | Godot-Projekt `godot/` mit Held, Steuerung (Tippen, Joystick), Kamera, Licht, Tusche aus der Probe; Kartenformat aus den heutigen Karten (Export aus `core`), Dorf Bornim als erste Gebietskarte mit Kollision und Ein- und Ausgängen | APK am Handy, Vergleichsbild Dorf alt/neu |
| 348.7 | Jerry | Modellregel (oben) schriftlich in dieser Datei; ein Kampfort in Godot: Wolfsrudel in MARS mit den echten Regeln (GDScript), Kamera, Ansagen, Ende | APK am Handy, Vergleichsbild Kampf alt/neu |
| 348.8 | Tom, Jerry | Bestandsliste: jede Gebietskarte, jeder Grundriss, jede Figur, jedes Tier, Monster, Ausrüstung, Gegenstand im alten Spiel, mit Quelle im Code; Spalte „Modell“, „Wer“ | Liste unten vollständig |

## Modellregel (348.7, Jerry, 25.10.)

Gilt für jedes Modell im neuen Spiel: Figur, Tier, Monster, Ausrüstung, Ding, Gebäude.

1. **Maß:** 1 Godot-Einheit = 1 m; 1 Feld der alten Karte = 1,16 m (`Karte.TS` in `godot/skripte/karte.gd`, Probe Build 11, Chef „Welt so ja“; Tom 25.10.), Kampfort mit demselben Maß. Held 1,8 m; alle anderen im Verhältnis wie im alten Spiel (Vorgabe: Vergleichsbild alt/neu nebeneinander), Tiere nach echter Größe (Wolf 0,8 m Schulterhöhe). Export in Metern; `held.glb` der Probe ist in Zentimetern und wird beim Übernehmen umgestellt, nie im Spiel mit 0,01 skaliert.
2. **Herkunft:** jedes Modell ist ein Python-Skript in `tools/blender348/` (Blender als Modul, Version wie im Workflow), das die `.glb` erzeugt; nie von Hand in Blender, nie eingecheckte `.glb` ohne Skript. Fremde Teile nur nach „Fremde Inhalte“ (`CLAUDE.md`).
3. **Ausrichtung:** Ursprung am Boden unter dem Schwerpunkt (Mensch: zwischen den Füßen), Blick nach glTF +Z (Blender −Y), oben +Y.
4. **Skelett:** Menschen und Menschenähnliche (Goblin, Grak, Zombie) mit dem Skelett aus `rig.py` und dessen Knochennamen; Tiere ein Skelett je Bauart (Vierbeiner, Vogel, Insekt, Spinne), in allen Modellen dieser Bauart gleich benannt. Waffen, Schilde, Fackel als eigene `.glb`, im Spiel an den Handknochen gehängt, nicht ins Netz gebacken; Griffpunkt = Ursprung.
5. **Bewegungen:** im Skript erzeugt, 30 Bilder je Sekunde, deutsche Namen wie im alten Spiel (Stehen, Gehen, Ausholen, Hieb, Stich, Biss, Sprung, Treffer, Ausweichen, Abwehr, Sturz, Aufstehen, Tod …); Schleifen nahtlos; Füße am Boden, Gehtempo in `<name>-info.json` (wie `held-info.json`), damit nichts gleitet. Schlagzeiten wie `DESIGN-ABNAHME.md` (Biss, Stich 0,6 s; Hieb 0,8 s).
6. **Aussehen:** Farbe gemalt wie `tex.py` (Textur oder in Eckfarben gebacken), höchstens 1024 px; kein Glanz außer Gold (Signatur); Licht und Tusche nur aus `toon.gdshader` und `tusche.gdshader`, nie im Modell. Mindestens drei Varianten (Fell, Statur, Kleidung) als Schalter im Skript; ebenso jedes Objekt, das mehrfach vorkommt (Blumenkästen, Fässer, Kisten, Zäune, Höhlenobjekte; Chef 25.10., 08:42: „Ist nur doof, wenn alle Blumenkästen gleich aussehen … denkt an die Varianten der Objekte auch“). Keine Kachelgrenzen sichtbar: Wege, Wiesen, Plätze, Pflaster unregelmäßig, nie gerade Linien oder rechte Winkel (Chef 08:46: „Natur ist wild, der Mensch ist eigentlich nicht in der Lage, gerade Linien zu ziehen“). Ebenso Hausfassaden und Dächer: Moos, kleine Schäden, Abnutzung, nie zwei gleich (Chef 08:48).
7. **Größe:** Figur höchstens 6000 Dreiecke, Ausrüstung höchstens 800, Ding höchstens 2000 (Samsung A56, `DESIGN-ABNAHME.md` Leistung); mehr nur nach Messung.
8. **Name:** Datei = Kennung im alten Spiel (`wolf.glb`, `hobgoblin_captain.glb`, `shortsword.glb`), angezeigter Name aus den Regeln, nie im Modell.
9. **Geprüft vor Abgabe:** Kontaktblatt aller Bewegungen (`blatt.py`), Durchdringung Waffe/Körper 0, Fußgleiten gemessen, Vergleichsbild alt/neu in der Bestandsliste vermerkt (Spalte „Modell“: Skript, Stand).

**Urteil Chef Wölfe (25.10., 08:57, Vergleichsbild 07:51):** „Die Richtung passt, aber im Moment ist es noch nicht so wirklich wolfig. Der am ehesten wolfig ist, ist der dunkelste Wolf.“ Ändern: (1) alle drei in exakt gleicher Haltung; (2) Körper nicht zum Gegner gedreht („wo die hinlaufen wollen, weg wahrscheinlich“); (3) Schnauze kommt nicht heraus; (4) Augen fehlen; (5) Ohren prägnanter; (6) Körper passt; (7) Textur gleich bis auf die Farbe, drei echte Varianten; (8) Animationen: atmen, mal Lefzen zeigen, mal scharren. Helden im Kampfort: „völlige Klone“, Rückansicht ohne Texturen, „schaut … wie eine Statue aus“ (gesprochen „Stute“).

## Ab Woche 2: Modelle und Orte nach Bestandsliste

Aufteilung nach Bereich (Tom: Leute, Häuser, Innenräume, Dorftiere wie Hühner, Katzen, Hunde; Jerry: Monster, Wald- und Höhlentiere wie Frösche, Libellen, Schmetterlinge, Höhle, Waffen und Rüstungen), Reihenfolge wie Kapitel 1 gespielt wird.

## Bestandsliste (348.8)

Pfade: `core/` = `core/src/main/kotlin/de/bornim/core/`, `art/` = `core/art/`, `ui/` = `app/src/main/java/de/bornim/game/ui/`. Spalte „Modell“: Skript in `tools/blender348/`, Stand (– = keins). Kartenformat für alle Karten: `MapExport.kt` → `godot/daten/karten.json`.

### Bereich Tom (Tom 25.10.)

**Gebietskarten und Grundrisse** (genau 8, `World.maps` `core/World.kt:205`; keine Ebenen, Kapitel 2 ohne Karte):

| Kennung | Name | Quelle | Zeichner alt | Modell | Wer |
|---|---|---|---|---|---|
| village | Bornim (36×32) | `Story.kt:129` | `MapGround`, `MapTownIso`, `MapWoodIso.fieldObjects`, `MapFlora`; verteilt in `WorldArt.buildObjects` | `v3/dorf.py`, im Bau (348.6) | Tom |
| inn | Zum Schlafenden Greif | `Story.kt:296` | `MapRoom`, `MapRoomIso.objects` | – | Tom |
| shop | Thessas Kramladen | `Story.kt:364` | wie inn | – | Tom |
| elder | Haus des Ältesten | `Story.kt:390` | wie inn | – | Tom |
| temple | Tempel des Morgenlichts | `Story.kt:478` | wie inn | – | Tom |
| forest | Flüsterwald | `Story.kt:524` | `MapGround`, `MapWoodIso`, `MapFlora`, `MapEdge` | – | Tom |
| deep_forest | Tiefer Flüsterwald (mit Morwens Hütte, `HUT`) | `Story.kt:619` | wie forest, Hütte `MapTownIso.houseObjects`; Anforderung 353a (Chef 25.10.): Held immer ganz sichtbar, Weg voraus erkennbar (Probe Zweig `claude/tom-353-sicht-probe`) | – | Tom |
| cave | Blutzahnhöhle | `Story.kt:731` | `MapCaveIso` | – | Jerry |

**Dinge im Dorf** (Kachelzeichen `core/World.kt:3-84`, Zeichner `art/MapTownIso.kt`, sonst genannt): Haus mit Gasthausschild, Markise, Glockenturm (`Story.kt:196-206`; `house` :77), Brunnen `w` (:734), Stand `m` (:772), Laterne `l` (:823; Sonderfälle Kaels Tür 24/6 :850, Brücke 19/27 :930), Bank `n` (:958), Fass `b` (`MapRoomIso.barrelOutside`), Brücke `h` (:945), Zaun `x` (:1255), Schlagbaum `z` (:1182), Schild `S` (:611), Anschlagbrett `!` (:646), Hof `p` (:975, :986: Heukarren 13/9, Waschzuber 11/11, Holzstapel 2/5 und 28/13, Netz 7/24 und 22/27), Korn `c`, Beet `v`, Heu `y`, Wäscheleine `q` (`MapWoodIso.fieldObjects`), Baum `T` (Eiche, Fichte, toter Baum, Stumpf, Busch; `MapFlora.kt:140-173`), Blumen `f`, Rauch (`ui/WorldScreen.kt:2109`, `MapTownIso.chimneyTops`). In `dorf.py` fehlen noch: Heukarren, Waschzuber, toter Baum, Sonderlaternen, Gasthausschild, Markise (Stand 25.10.).

**Möbel der Grundrisse** (`art/MapRoomIso.kt`): Theke `K`, Tisch `Y`, Bett `B`, Regal `Q` (Laden: Waren, Ältester: Bücher), Altar `A`, Kamin `Z` (Rauch `WorldScreen.kt:2274`), Kram `J` (:2184-2198), Pult `d`, Truhe `a`, Lehnstuhl `s`, Wandtuch `V`, Gestell `U`, Kerzen `N`, Weihwasser `&`, Kisten `u`, Bank, Fass; Wandschmuck `MapRoom.wallThing` (:268); Borins Hocker und Hammer (:2136). Modell: –, Tom.

**Leute** (Puppe `Doll` + Outfit `art/MapFolk.kt`, gezeichnet `MapFigure.render`; Tagesablauf `core/VillageDay.kt`, Stammplätze `core/MapPeople.kt`). Skelett für alle: `v3/rig.py` (Modellregel 4). Modell: –, Tom.

| Kennung | Name | Quelle | Aussehen (`MapFolk.kt`) |
|---|---|---|---|
| jorin | Wache Jorin | `Story.kt:209` | guard :59 |
| pim | Pim (Kind) | `Story.kt:225` | child :62 |
| bram | Bauer Bram | `Story.kt:233` | farmer :65 |
| liska | Liska | `Story.kt:241` | maid :68 |
| gwenna | Gwenna | `Story.kt:249` | villager :71 |
| rowena | Rowena | `Story.kt:313` | innkeeper :44 |
| borin | Borin (Zwerg, sitzt) | `Story.kt:341` | dwarf :74 |
| thessa | Thessa | `Story.kt:380` | merchant :50 |
| aldric | Ältester Aldric | `Story.kt:404` | elder :47 |
| osric | Bruder Osric | `Story.kt:495` | priest :53 |
| lyra_temple, lyra_cave | Lyra | `Story.kt:509`, `:776` | lyra :56 |
| garrick | Jäger Garrick | `Story.kt:579` | hunter :30 |
| morwen | Kräuterfrau Morwen | `Story.kt:681` | herbalist :77 |
| merc | Söldner (nur MARS-Probe) | `core/Skirmish.kt:1220` | wie Held (`Hero.create`) |
| Held | Held, vier Klassen | – | `v3/held3.py` + `rig.py`, im Bau (348.6) |

Grimmzahn, Krogg, Grak stehen auf Karten, sind aber Monster (Bereich Jerry).

**Dorftiere** (Modell: –, Tom): Huhn, 3 Gefieder, je 2 an jedem Heuballen (`art/MapHen.kt:474`); Katze im Gasthaus (`art/MapCat.kt:142`); Dorfhund (`art/MapDog.kt:144`: 24/10, 30/7, 19/9); Vögel (`art/MapBirds.kt:26`, Pixel). Keine Nutztiere, keine Tiere in Laden, Ältestenhaus, Tempel.

**Gegenstände** (Bilder, Modell nur, was der Held trägt): 21 Vorrat und Quest (`core/Items.kt:38-88`; Bild `art/SupplyArt.kt`, ohne eigenes Bild: spark_potion, gwenna_ring, grey_rag, smoke_bundle), Ladenwaren (`Story.kt:107`, `:42`; `Loot.shopGear`). Ausrüstung (57 Grundtypen `core/Gear.kt:269-336`, 9 Einzelstücke `:369-389`, Bild `art/ItemArt.kt`): Bereich Jerry.

**Oberfläche im Dorf** (`ui/WorldScreen.kt`, Tom): Leiste oben `HudChip` (LP, ZP, EP, Stufe, Uhr, Zustände, Beutel; :2827), Ausdauer `StaminaBar`, Handlungs- und Rennknopf `ActionButton` (:2955), Steuerkreuz (:2922), Gesprächsfenster `DialogBox` (:2900), Schwarzblende `MapVeil`; Menü `MenuScreen` (Held, Tasche, Ausrüstung, Karte, Chronik, System, Test); Laden, Anschlagbrett, Rast (:96-100). In Godot heute nur Knöpfe, Textfeld, Joystick (`steuerung.gd`).

### Bereich Jerry (Jerry 25.10.)

Wer: Jerry. Modell: – außer Wolf (`wolf.py`, Entwurf, 348.7) und Held (Tom). Vorkommen: Kapitel 1 endet bei Stufe 6, darum Ausrüstung bis Mindeststufe 6.

**Monster** (Regeln `core/Monsters.kt`, Rudel `core/Packs.kt`; Bild alt `art/FoeArt.kt` + Ausrüstung `core/MonsterKit.kt` für Menschenähnliche, `art/BeastArt.kt`/`WolfArt.kt` Tiere, `art/VerminArt.kt` Ungeziefer):

| Kennung | Name | Quelle | Bild alt | Wo | Skelett |
|---|---|---|---|---|---|
| wolf | Wolf | `Monsters.kt:91` | WolfArt | Flüsterwald, Tiefer Wald; Rudel, Leibwache Grimmzahns | Vierbeiner |
| dire_wolf | Grimmzahn | `:133` | WolfArt 1,45-fach | Endgegner Tiefer Wald (22,4) | Vierbeiner |
| boar | Wildschwein | `:145` | BeastArt | Wald am Tag | Vierbeiner |
| giant_rat | Riesenratte | `:87` | BeastArt | Wald am Tag, Höhle | Vierbeiner |
| goblin | Goblin | `:96` | FoeArt, Kit :34 | Wald, Höhle; mit Späher | Mensch |
| goblin_archer | Goblin-Späher | `:102` | FoeArt, Kit :41 | Wald am Tag, Höhle | Mensch |
| goblin_shaman | Goblin-Schamane | `:165` | FoeArt, Kit :78 | Tiefer Wald, Höhle | Mensch |
| kobold | Kobold | `:160` | FoeArt, Kit :47 | Wald; Rudel | Mensch |
| skeleton | Skelett | `:108` | FoeArt, Kit :84 | Wald nachts, Höhle | Mensch |
| zombie | Zombie | `:115` | FoeArt, Kit :53 | Wald nachts, Höhle | Mensch |
| ghoul | Ghul | `:175` | FoeArt, Kit :71 | Tiefer Wald nachts, Höhle | Mensch |
| bugbear | Krogg | `:127` | FoeArt, Kit :60 | Endgegner Höhle (16,9) | Mensch |
| hobgoblin_captain | Grak | `:139` | FoeArt, Kit :65 | Endgegner Höhle (10,2) | Mensch |
| giant_spider | Riesenspinne | `:121` | VerminArt | Tiefer Wald, Höhle | Spinne |
| giant_centipede | Riesen-Hundertfüßer | `:155` | VerminArt | Wald am Tag | Insekt |
| stirge | Stirge | `:150` | VerminArt | Wald | Insekt |
| giant_bat | Riesenfledermaus | `:170` | VerminArt | Wald nachts, Höhle | Vogel |
| ochre_jelly | Ockergallerte | `:180` | VerminArt | Höhle, selten | keins |

**Kleintiere** (nur Bild, keine Regeln): Frosch und Libelle an den Teichen (`art/PondLife.kt:75`, `:29`), Schmetterling auf Blumen (`ui/WorldScreen.kt:1675`, auch im Dorf), Glühwürmchen nachts (`WorldScreen.kt:1896`, Kampfort `art/BattleScene.kt:549`); Eule, Grille nur Ton (`audio/WildSound.kt:36`). Vögel: Tom (Dorftiere), im Wald gleiches Modell.

**Höhle** `cave` (Blutzahnhöhle, `Story.kt:731`, 22×20, eine Ebene; Bild `art/MapCaveIso.kt`, Boden `art/MapCave.kt:848`, Licht `MapLight.kt`): Eingang/Ausgang, Fels, Boden (`core/World.kt:22-25`); Wandfackel 2, Kristalle 2, Leuchtpilze 5, Stalagmit 3, Geröll 3, Felsblock 1, Knochen 4, Kisten 2, Schlafstätte 2, Lagerfeuer 1, Stützbalken 3 Paare, Lichtspalt 1, Gitter vor Graks Halle (öffnet `rusty_key`, `Game.kt:1093`), Truhen `cave_1`–`cave_3` (`Story.kt:762`), Wasser 5 (Kachelzeichen `World.kt:9-78`). Kampforte der Höhle `art/CaveScene.kt:24` (Eingang, Gang, Halle, Teich, Lager; Licht Fackel, Glimmen, Schacht, dunkel). Ketten gibt es im Spiel nicht (nur ungenutzt `MapCave.kt:593`; 356.1 braucht sie).

**Ausrüstung** (Regeln `core/Gear.kt:269-336`, Einzelstücke `:369-389`; Bild am Körper `art/Dress.kt`, Symbol `art/ItemArt.kt`; Laden Thessa `Loot.shopGear`; Beute ab Mindeststufe; als eigene `.glb`, Modellregel 4):
- **Waffen** (`:305-326`): dagger, shortsword, scimitar, handaxe, mace, spear, quarterstaff, rapier, longsword, battleaxe, morningstar, warhammer, wand, greatsword, greataxe, maul, halberd, staff, shortbow, longbow, light_crossbow. Startwaffen: Kämpfer longsword, Schurke shortsword, Magier und Kleriker quarterstaff. Von Gegnern getragen (`MonsterKit.kt`): dagger, shortsword, scimitar, handaxe, spear, morningstar (Krogg), greataxe (Grak), staff, shortbow.
- **Einzelstücke** (`:373-387`): longsword_oakford, staff_of_embers, rapier_whisper, mace_of_dawn (Truhe `cave_3` je Klasse), greataxe_grak (Grak), gauntlets_ogre (Krogg), cloak_protection (Spinne, 3 %); Schmuck amulet_grimfang, ring_protection u. a. nur als Symbol.
- **Schilde** (`:328-330`): shield (Start Kämpfer), round_shield (Start Kleriker; Goblin, Kobold, Skelett), tower_shield (ab 5).
- **Nebenhand** (`:332-335`): torch (Laden), orb, tome, holy_symbol.
- **Rüstung** (`:271-299`): Kopf hood, circlet, leather_cap, helmet, great_helm; Körper robe, leather, studded_leather, chain_shirt, scale_mail, breastplate, half_plate, chain_mail, splint (plate ab 7: nicht in Kapitel 1); Arme wraps, gloves, bracers, gauntlets; Beine leggings, boots, chain_leggings, greaves; Rücken cloak, mantle.
